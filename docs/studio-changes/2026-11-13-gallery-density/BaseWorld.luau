local TweenService = game:GetService("TweenService")
local GalleryWorld = require(script.Parent.GalleryWorld)

local World = {}
World.__index = World

-- 빈 기지 표현 (2026-11-10): 차지하기 전에는 바닥과 차지 발판만 보이고,
-- 차지하면 시설(Layout·생산기·전시대)이 나타납니다. Edit 배치는 그대로 두고 Play 중 속성만 바꿉니다.
local BUILD_TWEEN = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- 보이기/숨기기에 필요한 원래 속성값을 기록합니다.
local function collectVisuals(roots, skipPrompt)
    local records = {}
    local function add(instance)
        if instance:IsA("BasePart") then
            table.insert(records, {
                instance = instance,
                transparency = instance.Transparency,
                canCollide = instance.CanCollide,
                canQuery = instance.CanQuery,
                canTouch = instance.CanTouch,
            })
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            table.insert(records, { instance = instance, transparency = instance.Transparency })
        elseif instance:IsA("ProximityPrompt") then
            if instance ~= skipPrompt then
                table.insert(records, { instance = instance, enabled = instance.Enabled })
            end
        elseif
            instance:IsA("LayerCollector")
            or instance:IsA("Light")
            or instance:IsA("ParticleEmitter")
            or instance:IsA("Beam")
            or instance:IsA("Trail")
        then
            table.insert(records, { instance = instance, enabled = instance.Enabled })
        end
    end
    for _, root in roots do
        if root then
            add(root)
            for _, descendant in root:GetDescendants() do
                add(descendant)
            end
        end
    end
    return records
end

local function setVisualsShown(records, shown, animate)
    for _, record in records do
        local instance = record.instance
        if record.canCollide ~= nil then
            instance.CanCollide = shown and record.canCollide or false
            instance.CanQuery = shown and record.canQuery or false
            instance.CanTouch = shown and record.canTouch or false
        end
        if record.transparency ~= nil then
            if shown and animate then
                instance.Transparency = 1
                TweenService:Create(instance, BUILD_TWEEN, { Transparency = record.transparency }):Play()
            else
                instance.Transparency = shown and record.transparency or 1
            end
        end
        if record.enabled ~= nil then
            instance.Enabled = shown and record.enabled or false
        end
    end
end
local function createPart(parent, name, size, position, color)
    local partInstance = Instance.new("Part")
    partInstance.Name = name
    partInstance.Size = size
    partInstance.Position = position
    partInstance.Color = color
    partInstance.Anchored = true
    partInstance.TopSurface = Enum.SurfaceType.Smooth
    partInstance.BottomSurface = Enum.SurfaceType.Smooth
    partInstance.Parent = parent
    return partInstance
end

local function createBillboard(parent, name, text)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = name
    billboardGui.Size = UDim2.fromOffset(280, 76)
    billboardGui.StudsOffset = Vector3.new(0, 5, 0)
    billboardGui.MaxDistance = 100
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = parent
    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(15, 25, 40)
    label.BackgroundTransparency = 0.15
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(230, 240, 250)
    label.TextWrapped = true
    label.Text = text
    label.Parent = billboardGui
    return label
end
-- Workspace에 배치한 기지에 기능을 연결합니다. 지형/기지 부품을 생성하지 않습니다.
local function requireChild(parent, name, className)
    local childInstance = parent and parent:FindFirstChild(name)
    assert(
        childInstance and childInstance:IsA(className),
        "기지 구조 확인: "
            .. (parent and parent:GetFullName() or "Workspace")
            .. "."
            .. name
            .. " ("
            .. className
            .. ")"
    )
    return childInstance
end

function World.new(config)
    local root = requireChild(workspace, "ProjectMS_Bases", "Folder")
    local self = setmetatable({ root = root, plots = {}, config = config }, World)
    -- 전체 구조를 확인한 뒤 소유권 상태만 초기화합니다.
    for id = 1, config.PlotCount do
        local model = requireChild(root, "Base_" .. id, "Model")
        assert(model:GetAttribute("PlotId") == id, "Base_" .. id .. "의 PlotId를 확인하세요")
        local floor = requireChild(model, "Floor", "BasePart")
        local pad = requireChild(model, "ClaimPad", "BasePart")
        local generator = requireChild(model, "Generator", "BasePart")
        local display = requireChild(model, "Display", "BasePart")
        local storage = requireChild(model, "Storage", "BasePart")
        local ownerLabel =
            requireChild(requireChild(pad, "OwnerSign", "BillboardGui"), "Text", "TextLabel")
        local layout = model:FindFirstChild("Layout")
        local rollPrompt = requireChild(generator, "Roll", "ProximityPrompt")
        -- 보관함 시설은 2026-11-10 개념 제거: 항상 숨깁니다(미사일 목록은 화면 UI에서 봄).
        local removedVisuals = collectVisuals({
            storage,
            layout and layout:FindFirstChild("Label_Storage"),
        })
        setVisualsShown(removedVisuals, false, false)
        local buildRoots = { generator }
        for _, child in layout and layout:GetChildren() or {} do
            if child.Name ~= "Label_Storage" and child.Name ~= "Gallery" then
                table.insert(buildRoots, child)
            end
        end
        self.plots[id] = {
            buildVisuals = collectVisuals(buildRoots, rollPrompt),
            model = model,
            floor = floor,
            pad = pad,
            generator = generator,
            display = display,
            galleryPrompt = GalleryWorld.Configure(model),
            storage = storage,
            idlePadColor = pad.Color,
            ownerLabel = ownerLabel,
            claimPrompt = requireChild(pad, "Claim", "ProximityPrompt"),
            rollPrompt = rollPrompt,
            inventoryPrompt = requireChild(storage, "Inventory", "ProximityPrompt"),
        }
    end
    for id = 1, config.PlotCount do
        self:SetOwner(id, nil)
    end
    return self
end

function World:SetOwner(id, player, gallerySlots)
    local plot = self.plots[id]
    if not plot then
        return
    end
    local wasBuilt = plot.model:GetAttribute("OwnerUserId") ~= 0
        and plot.model:GetAttribute("OwnerUserId") ~= nil
    plot.model:SetAttribute("OwnerUserId", player and player.UserId or 0)
    plot.ownerLabel.Text = player and (player.DisplayName .. "의 미사일 기지")
        or ("빈 기지 " .. id .. "\nE로 차지")
    plot.pad.Color = player and Color3.fromRGB(65, 185, 225) or plot.idlePadColor
    plot.claimPrompt.Enabled = player == nil
    -- 차지하면 시설이 생기고, 비면 다시 빈 바닥으로 돌아갑니다.
    setVisualsShown(plot.buildVisuals, player ~= nil, player ~= nil and not wasBuilt)
    GalleryWorld.SetState(plot.model, gallerySlots or 1, player ~= nil, self.config)
    self:SetProduction(id, nil)
    plot.inventoryPrompt.Enabled = false
    if not player then
        local preview = plot.model:FindFirstChild("Preview")
        if preview then
            preview:Destroy()
        end
    end
end

-- 사전 배치된 안내판/프롬프트의 문구만 갱신하며, 기지 배치는 건드리지 않습니다.
function World:SetGallery(id, unlockedSlots)
    local plot = self.plots[id]
    if plot then
        GalleryWorld.SetState(plot.model, unlockedSlots, plot.model:GetAttribute("OwnerUserId") ~= 0, self.config)
    end
end

function World:SetProduction(id, pending)
    local plot = self.plots[id]
    if not plot then
        return
    end
    local remaining = pending and math.max(0, pending.readyAt - workspace:GetServerTimeNow()) or 0
    local text = pending and string.format("미사일 제작 중\n남은 시간 %.1f초", remaining)
        or string.format(
            "미사일 제작\n코인 %d개 · %g초",
            self.config.RollCost,
            self.config.ProductionDuration
        )
    local sign = plot.generator:FindFirstChild("GeneratorSign")
    local label = sign and sign:FindFirstChild("Text")
    if label and label:IsA("TextLabel") then
        label.Text = text
    end
    plot.rollPrompt.ActionText = pending and "미사일 제작 중"
        or string.format("제작 · 코인 %d개", self.config.RollCost)
    plot.rollPrompt.Enabled = plot.model:GetAttribute("OwnerUserId") ~= 0 and pending == nil
end

function World:Preview(id, definition)
    local plot = self.plots[id]
    local existingPreview = plot.model:FindFirstChild("Preview")
    if existingPreview then
        existingPreview:Destroy()
    end
    local model = Instance.new("Model")
    model.Name = "Preview"
    model.Parent = plot.model
    local color = Color3.fromRGB(table.unpack(definition.color))
    local origin = plot.display.Position + Vector3.new(0, 2.5, 0)
    createPart(model, "Body", Vector3.new(0.8, 2.8, 0.8), origin, color)
    local nose = createPart(model, "Nose", Vector3.one, origin + Vector3.new(0, 1.65, 0), color)
    nose.Shape = Enum.PartType.Ball
    nose.Material = Enum.Material.Neon
    createPart(
        model,
        "Fins",
        Vector3.new(2, 0.25, 1),
        origin - Vector3.yAxis,
        Color3.fromRGB(80, 105, 140)
    )
    createBillboard(nose, "Result", definition.rarity .. " · " .. definition.name)
    for _, childPart in model:GetChildren() do
        if childPart:IsA("BasePart") then
            childPart.CanCollide = false
        end
    end
end

return World
