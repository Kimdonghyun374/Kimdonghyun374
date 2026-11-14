local TweenService = game:GetService("TweenService")
local GalleryWorld = require(script.Parent.GalleryWorld)
local TycoonData = require(game:GetService("ReplicatedStorage").PetMissiles.TycoonData)

local World = {}
World.__index = World

-- 빈 기지 표현 (2026-11-10): 차지하기 전에는 바닥과 차지 발판만 보이고,
-- 차지하면 시설(Layout·생산기·전시대)이 나타납니다. Edit 배치는 그대로 두고 Play 중 속성만 바꿉니다.
local BUILD_TWEEN = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local activeVisualTweens = {}
local function cancelVisualTween(instance)
    local tween = activeVisualTweens[instance]
    if tween then
        activeVisualTweens[instance] = nil
        tween:Cancel()
    end
end

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
            cancelVisualTween(instance)
            if shown and animate then
                instance.Transparency = 1
                local tween = TweenService:Create(instance, BUILD_TWEEN, { Transparency = record.transparency })
                activeVisualTweens[instance] = tween
                tween.Completed:Once(function()
                    if activeVisualTweens[instance] == tween then
                        activeVisualTweens[instance] = nil
                    end
                end)
                tween:Play()
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

-- 반투명 '구매 가능' 표시: 보이되 부딪히지 않고, 안의 프롬프트·조명은 끕니다.
local GHOST_TRANSPARENCY = 0.75
local LOCKED_STATION_TRANSPARENCY = 0.6
local function setVisualsGhost(records)
    for _, record in records do
        local instance = record.instance
        if record.canCollide ~= nil then
            instance.CanCollide = false
            instance.CanQuery = false
            instance.CanTouch = false
        end
        if record.transparency ~= nil then
            cancelVisualTween(instance)
            instance.Transparency = math.max(record.transparency, GHOST_TRANSPARENCY)
        end
        if record.enabled ~= nil then
            instance.Enabled = false
        end
    end
end

-- 0 = 숨김, 1 = 반투명(살 수 있음), 2 = 설치됨
local function applyStage(records, stage, previousStage)
    if stage == 2 then
        setVisualsShown(records, true, previousStage ~= 2)
    elseif stage == 1 then
        setVisualsGhost(records)
    else
        setVisualsShown(records, false, false)
    end
end

local function createPrompt(parent, name, objectText, holdDuration, distance)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = name
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt.HoldDuration = holdDuration or 0.5
    prompt.MaxActivationDistance = distance or 6
    prompt.RequiresLineOfSight = false
    prompt.Style = Enum.ProximityPromptStyle.Custom
    prompt.ObjectText = objectText
    prompt.Enabled = false
    prompt.Parent = parent
    return prompt
end

-- 제작대 칸: Generator(원래 생산기)와 Layout.Production의 칸을 TycoonData 순서로 묶고,
-- 각 칸에 제작 프롬프트·안내판을 붙입니다(원래 생산기의 것을 복제).
local function setupStations(model, generator, rollPrompt)
    local production = model.Layout:FindFirstChild("Production")
    local sign = generator:FindFirstChild("GeneratorSign")
    local stations = {}
    for index, name in ipairs(TycoonData.StationOrder) do
        local part = name == "Generator" and generator or (production and production:FindFirstChild(name))
        assert(part and part:IsA("BasePart"), "제작대 칸 확인: " .. model.Name .. "." .. name)
        local prompt = part:FindFirstChild("Roll")
        if not prompt then
            prompt = rollPrompt:Clone()
            prompt.Parent = part
        end
        local stationSign = part:FindFirstChild("GeneratorSign")
        if not stationSign and sign then
            stationSign = sign:Clone()
            stationSign.Parent = part
        end
        prompt:SetAttribute("Station", index)
        prompt.MaxActivationDistance = 6
        stations[index] = {
            part = part,
            prompt = prompt,
            label = stationSign and stationSign:FindFirstChild("Text"),
            transparency = part.Transparency,
            artVisuals = collectVisuals({ part:FindFirstChild("ArtDetails") }),
        }
    end
    return stations
end

function World.new(config)
    local root = requireChild(workspace, "ProjectMS_Bases", "Folder")
    local self = setmetatable({ root = root, plots = {}, config = config }, World)
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
        local layout = requireChild(model, "Layout", "Folder")
        local rollPrompt = requireChild(generator, "Roll", "ProximityPrompt")
        -- 보관함 시설은 2026-11-10 개념 제거: 항상 숨깁니다(미사일 목록은 화면 UI에서 봄).
        local removedVisuals = collectVisuals({
            storage,
            layout:FindFirstChild("Label_Storage"),
        })
        setVisualsShown(removedVisuals, false, false)
        -- 시설·꾸밈은 레벨/구매에 따라 따로 표시합니다.
        local separate = { Label_Storage = true, Gallery = true, Decor = true }
        local facilities = {}
        for _, name in ipairs(TycoonData.FacilityOrder) do
            local facility = TycoonData.Facilities[name]
            -- 시설은 Model(TechLab) 또는 Folder(AFKLab)일 수 있습니다.
            local facilityModel = requireChild(layout, facility.layoutName, "Instance")
            separate[facility.layoutName] = true
            facilities[name] = {
                visuals = collectVisuals({ facilityModel }),
                stage = -1,
                model = facilityModel,
            }
        end
        local buildRoots = { generator }
        for _, child in layout:GetChildren() do
            if not separate[child.Name] then
                table.insert(buildRoots, child)
            end
        end
        local decorFolder = layout:FindFirstChild("Decor")
        local decors = {}
        for _, decor in ipairs(TycoonData.Decor) do
            local decorModel = decorFolder and decorFolder:FindFirstChild(decor.id)
            if decorModel then
                decors[decor.id] = { visuals = collectVisuals({ decorModel }), stage = -1, model = decorModel }
            end
        end
        -- 제작대 등급 외형 대상: 제작대 6칸 + 표시등 + 단말 화살표. 1등급은 원래 색으로 되돌립니다.
        local tierParts = { { part = generator, kind = "slot", color = generator.Color, material = generator.Material } }
        local production = layout:FindFirstChild("Production")
        for _, part in production and production:GetChildren() or {} do
            if part:IsA("BasePart") and part.Name:match("^GeneratorSlot_") then
                table.insert(tierParts, { part = part, kind = "slot", color = part.Color, material = part.Material })
            elseif part:IsA("BasePart") and part.Name:match("^Light_") then
                table.insert(tierParts, { part = part, kind = "light", color = part.Color, material = part.Material })
            end
        end
        local upgradeModel = requireChild(layout, "ProductionUpgrade", "Model")
        for _, name in { "ArrowStem", "ArrowHeadL", "ArrowHeadR" } do
            local part = upgradeModel:FindFirstChild(name)
            table.insert(tierParts, { part = part, kind = "arrow", color = part.Color, material = part.Material })
        end
        local plot = {
            buildVisuals = collectVisuals(buildRoots, rollPrompt),
            model = model,
            floor = floor,
            pad = pad,
            generator = generator,
            display = display,
            galleryPrompt = GalleryWorld.Configure(model),
            facilities = facilities,
            decors = decors,
            tierParts = tierParts,
            upgradePrompt = requireChild(requireChild(upgradeModel, "Console", "BasePart"), "UpgradeProduction", "ProximityPrompt"),
            upgradeConsole = upgradeModel.Console,
            upgradeLabel = upgradeModel.Label_ProductionUpgrade.FacilitySign.Text,
            storage = storage,
            idlePadColor = pad.Color,
            ownerLabel = ownerLabel,
            claimPrompt = requireChild(pad, "Claim", "ProximityPrompt"),
            rollPrompt = rollPrompt,
            inventoryPrompt = requireChild(storage, "Inventory", "ProximityPrompt"),
        }
        -- 모든 기록을 만든 뒤 새 프롬프트를 붙입니다(차지/숨김 처리가 이 프롬프트를 켜지 않게).
        plot.stations = setupStations(model, generator, rollPrompt)
        -- 2번 이후 제작대 칸은 SetStations가 직접 보이기/반투명을 정하므로 차지 연출 목록에서 뺍니다.
        local stationParts = {}
        for index, station in plot.stations do
            if index > 1 then
                stationParts[station.part] = true
            end
        end
        for index = #plot.buildVisuals, 1, -1 do
            if stationParts[plot.buildVisuals[index].instance] then
                table.remove(plot.buildVisuals, index)
            end
        end
        plot.stationPrompt = createPrompt(generator, "BuyStation", "제작 라인")
        for name, facility in facilities do
            local anchor = facility.model:FindFirstChild(TycoonData.Facilities[name].anchor, true)
            facility.prompt = createPrompt(anchor, "UpgradeFacility", TycoonData.Facilities[name].label, 0.5, 4)
            facility.prompt:SetAttribute("Facility", name)
        end
        local techLab = facilities.TechLab.model
        plot.researchPrompt = createPrompt(requireChild(techLab, "Workbench", "BasePart"), "Research", "기술 개발 · 장착 슬롯", 0.5, 4)
        plot.researchPrompt:SetAttribute("ResearchId", "EquipSlots")
        for decorId, decor in decors do
            local anchor = decor.model.PrimaryPart or decor.model:FindFirstChildWhichIsA("BasePart", true)
            decor.prompt = createPrompt(anchor, "BuyDecor", "꾸밈")
            decor.prompt:SetAttribute("DecorId", decorId)
        end
        self.plots[id] = plot
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
    if not player then
        for name in plot.facilities do
            self:SetFacility(id, name, 0, nil)
        end
        for decorId in plot.decors do
            self:SetDecor(id, decorId, false, nil)
        end
        self:SetCraftTier(id, 1)
        self:SetStations(id, 0, nil)
        self:SetResearch(id, nil)
    end
    plot.inventoryPrompt.Enabled = false
    if not player then
        local preview = plot.model:FindFirstChild("Preview")
        if preview then
            preview:Destroy()
        end
    end
end

-- 제작대 칸: 열린 칸(openCount)은 실제 제작대, 나머지는 반투명. nextInfo가 있으면 다음 칸에 구매 프롬프트.
-- nextInfo = { costText, available, missing }
function World:SetStations(id, openCount, nextInfo, pendingByStation)
    local plot = self.plots[id]
    if not plot then
        return
    end
    local owned = plot.model:GetAttribute("OwnerUserId") ~= 0
    plot.model:SetAttribute("ProductionLevel", openCount)
    local openTransparency = plot.stations[1].transparency -- 원래 생산기 투명도(차지 연출 중간값이 아닌 Edit 원본)
    for index, station in plot.stations do
        local open = owned and index <= openCount
        if index > 1 then
            -- 열린 칸 = 실제 제작대(1번과 같은 불투명), 잠긴 칸 = 반투명 예정 칸, 빈 기지 = 숨김
            station.part.Transparency = not owned and 1 or open and openTransparency or LOCKED_STATION_TRANSPARENCY
            station.part.CanCollide = open
            station.part.CanQuery = owned
        end
        -- 제작대 부속 장식도 잠금/빈 기지 상태를 따라갑니다.
        if open then
            setVisualsShown(station.artVisuals, true, false)
        elseif owned then
            setVisualsGhost(station.artVisuals)
        else
            setVisualsShown(station.artVisuals, false, false)
        end
        local pending = pendingByStation and pendingByStation[tostring(index)]
        self:SetProduction(id, index, pending, open)
    end
    local productionSign = plot.model.Layout:FindFirstChild("Production")
    productionSign = productionSign and productionSign:FindFirstChild("Label_Production")
    local signLabel = productionSign and productionSign:FindFirstChildWhichIsA("TextLabel", true)
    if signLabel then
        signLabel.Text = string.format("제작 라인 · %d대 사용 / %d칸", math.max(openCount, 1), #plot.stations)
    end
    local nextStation = plot.stations[openCount + 1]
    local prompt = plot.stationPrompt
    if owned and nextStation and nextInfo then
        prompt.Parent = nextStation.part
        prompt.ObjectText = string.format("제작대 %d대째", openCount + 1)
        prompt.ActionText = nextInfo.available and ("열기 · " .. nextInfo.costText)
            or (nextInfo.missing .. " 필요")
        prompt.Enabled = true
    else
        prompt.Enabled = false
    end
end

-- 시설: level 0이면 조건 충족 시 반투명(살 수 있음), 아니면 숨김. 1 이상이면 설치.
-- nextInfo = { label, costText, available, missing } 또는 nil(최고 레벨)
function World:SetFacility(id, name, level, nextInfo)
    local plot = self.plots[id]
    local facility = plot and plot.facilities[name]
    if not facility then
        return
    end
    local owned = plot.model:GetAttribute("OwnerUserId") ~= 0
    local stage = not owned and 0 or level >= 1 and 2 or (nextInfo and nextInfo.available) and 1 or 0
    if stage ~= facility.stage then
        applyStage(facility.visuals, stage, facility.stage)
        facility.stage = stage
    end
    plot.model:SetAttribute("Facility_" .. name, level)
    local prompt = facility.prompt
    if owned and nextInfo and (stage == 1 or (stage == 2 and nextInfo.available)) then
        prompt.ActionText = (level == 0 and "짓기 · " or string.format("%d레벨로 · ", level + 1)) .. nextInfo.costText
        prompt.Enabled = true
    elseif owned and stage == 2 and nextInfo then
        prompt.ActionText = string.format("%d레벨 · %s 필요", level + 1, nextInfo.missing)
        prompt.Enabled = true
    else
        prompt.Enabled = false
    end
end

-- 연구 프롬프트(기술 개발실 작업대). info = { text, enabled } 또는 nil
function World:SetResearch(id, info)
    local plot = self.plots[id]
    if not plot then
        return
    end
    local techLabStage = plot.facilities.TechLab.stage
    plot.researchPrompt.Enabled = info ~= nil and techLabStage == 2
    if info then
        plot.researchPrompt.ObjectText = info.objectText
        plot.researchPrompt.ActionText = info.actionText
    end
end

-- 꾸밈: 구매하면 표시, 조건을 만족하면 반투명 + 구매 프롬프트, 아니면 숨김.
function World:SetDecor(id, decorId, bought, info)
    local plot = self.plots[id]
    local decor = plot and plot.decors[decorId]
    if not decor then
        return
    end
    local owned = plot.model:GetAttribute("OwnerUserId") ~= 0
    local stage = not owned and 0 or bought and 2 or (info and info.available) and 1 or 0
    if stage ~= decor.stage then
        applyStage(decor.visuals, stage, decor.stage)
        decor.stage = stage
    end
    decor.prompt.Enabled = owned and stage == 1
    if info then
        decor.prompt.ObjectText = info.label
        decor.prompt.ActionText = "사기 · " .. info.costText
    end
end

-- 제작대 등급 외형을 모든 제작대(생산기·라인 칸)와 표시등에 한 번에 적용합니다.
-- nextInfo = { available, missing } (다음 등급 조건)
function World:SetCraftTier(id, tier, nextInfo)
    local plot = self.plots[id]
    if not plot then
        return
    end
    local tiers = self.config.CraftTiers
    local definition = tiers[tier] or tiers[1]
    plot.model:SetAttribute("CraftTier", tier)
    for _, record in plot.tierParts do
        local part = record.part
        if tier <= 1 then
            part.Color = record.color
            part.Material = record.material
        elseif record.kind == "slot" then
            part.Color = Color3.fromRGB(table.unpack(definition.slotColor))
            part.Material = Enum.Material[definition.slotMaterial]
        else
            part.Color = Color3.fromRGB(table.unpack(definition.lightColor))
        end
    end
    local nextDefinition = tiers[tier + 1]
    plot.upgradeConsole.Color = nextDefinition and Color3.fromRGB(40, 170, 190) or Color3.fromRGB(225, 170, 50)
    if nextDefinition then
        local costText = nextDefinition.cost.research > 0
                and string.format("코인 %d · 연구자료 %d", nextDefinition.cost.coin, nextDefinition.cost.research)
            or string.format("코인 %d", nextDefinition.cost.coin)
        local newText = ""
        if nextDefinition.newRarity then
            local catalog = require(game:GetService("ReplicatedStorage").PetMissiles.MissileCatalog)
            newText = "\n새로 등장: " .. (catalog.RarityLabels[nextDefinition.newRarity] or nextDefinition.newRarity)
        end
        plot.upgradeLabel.Text = string.format("제작대 %s → %s\n%s%s", definition.name, nextDefinition.name, costText, newText)
        plot.upgradePrompt.ObjectText = "제작대 " .. definition.name .. " (모든 제작대)"
        if nextInfo and not nextInfo.available then
            plot.upgradePrompt.ActionText = nextDefinition.name .. " · " .. nextInfo.missing .. " 필요"
        else
            plot.upgradePrompt.ActionText = nextDefinition.name .. " 올리기 · " .. costText
        end
    else
        plot.upgradeLabel.Text = "제작대 " .. definition.name .. "\n최고 등급"
    end
    plot.upgradePrompt.Enabled = plot.model:GetAttribute("OwnerUserId") ~= 0 and nextDefinition ~= nil
    if plot.model:GetAttribute("OwnerUserId") ~= 0 then
        for station = 1, plot.model:GetAttribute("ProductionLevel") or 1 do
            local stationLabel = plot.stations[station] and plot.stations[station].label
            if stationLabel and not stationLabel.Text:find("제작 중", 1, true) then
                self:SetProduction(id, station, nil, true)
            end
        end
    end
end

function World:SetGalleryDisplays(id, displayedDefinitions)
    local plot = self.plots[id]
    if plot then
        GalleryWorld.SetDisplays(plot.model, displayedDefinitions)
    end
end

function World:SetGallery(id, unlockedSlots)
    local plot = self.plots[id]
    if plot then
        GalleryWorld.SetState(plot.model, unlockedSlots, plot.model:GetAttribute("OwnerUserId") ~= 0, self.config)
    end
end

-- 제작대 1칸의 안내판·프롬프트. open이 아니면 끕니다.
function World:SetProduction(id, station, pending, open)
    local plot = self.plots[id]
    local slot = plot and plot.stations[station]
    if not slot then
        return
    end
    if open == nil then
        open = station <= (plot.model:GetAttribute("ProductionLevel") or 1)
    end
    local remaining = pending and math.max(0, pending.readyAt - workspace:GetServerTimeNow()) or 0
    local tier = self.config.CraftTiers[plot.model:GetAttribute("CraftTier") or 1] or {}
    local rollCost = tier.rollCost or self.config.RollCost
    local duration = tier.duration or self.config.ProductionDuration
    local text = pending and string.format("제작대 %d · 제작 중\n남은 시간 %.1f초", station, remaining)
        or string.format("제작대 %d · %s\n코인 %d개 · %g초", station, tier.name or "", rollCost, duration)
    if slot.label and slot.label:IsA("TextLabel") then
        slot.label.Text = text
        slot.label.Parent.Enabled = open
    end
    slot.prompt.ActionText = pending and "미사일 제작 중"
        or string.format("제작 · 코인 %d개 · %s", rollCost, tier.name or "")
    slot.prompt.ObjectText = string.format("제작대 %d", station)
    slot.prompt.Enabled = plot.model:GetAttribute("OwnerUserId") ~= 0 and open and pending == nil
end

function World:Preview(id, definition, station)
    local plot = self.plots[id]
    local existingPreview = plot.model:FindFirstChild("Preview")
    if existingPreview then
        existingPreview:Destroy()
    end
    -- 자산 미사일 모델이 있으면 제작대 위에 세워 보여 줍니다(2026-11-13).
    local anchorStation = plot.stations[station or 1] and plot.stations[station or 1].part or plot.generator
    local MissileModels = require(game:GetService("ReplicatedStorage").PetMissiles.MissileModels)
    local assetModel = MissileModels.Build(definition.model, 3)
    if assetModel then
        assetModel.Name = "Preview"
        local top = anchorStation.Position.Y + anchorStation.Size.Y / 2
        assetModel:PivotTo(CFrame.new(anchorStation.Position.X, top + 2, anchorStation.Position.Z) * CFrame.Angles(math.rad(90), 0, 0))
        local tagPart = assetModel.PrimaryPart or assetModel:FindFirstChildWhichIsA("BasePart", true)
        local resultSign = createBillboard(tagPart, "Result", definition.rarity .. " · " .. definition.name).Parent
        resultSign.StudsOffset = Vector3.zero
        resultSign.StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0)
        assetModel.Parent = plot.model
        return
    end
    local model = Instance.new("Model")
    model.Name = "Preview"
    model.Parent = plot.model
    local color = Color3.fromRGB(table.unpack(definition.color))
    local anchor = plot.stations[station or 1] and plot.stations[station or 1].part or plot.generator
    local origin = anchor.Position + Vector3.new(0, anchor.Size.Y / 2 + 2.5, 0)
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
