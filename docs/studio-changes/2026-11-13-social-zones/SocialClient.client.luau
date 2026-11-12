local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local network = game.ReplicatedStorage:WaitForChild("PetMissiles")
local Config = require(network:WaitForChild("SocialConfig"))
local remotes = network:WaitForChild("SocialNetwork")
local gui = player.PlayerGui:WaitForChild("PrankPistolHUD")
gui.Enabled = true
local status = gui.Panel.Status
local equipButton = gui.Panel.Equip
local lastShot = -math.huge
local touchStarts = {}
local visuals = Instance.new("Folder")
visuals.Name = "PrankTracers"
visuals.Parent = workspace
local constructionHint = Instance.new("Highlight")
constructionHint.Name = "TechLabConstructionHint"
constructionHint.FillColor = Color3.fromRGB(40, 230, 210)
constructionHint.OutlineColor = Color3.new(1, 1, 1)
constructionHint.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
constructionHint.Enabled = false
constructionHint.Parent = workspace
local clearedZone1 = false
local messageId = 0
local function notice(text)
    messageId += 1
    local id = messageId
    status.Text = text
    task.delay(3, function()
        if id == messageId then
            status.Text = "클릭/터치 발사 · 건물 선택 / 플레이어 장난"
        end
    end)
end
local function toggleEquip()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end
    if character:FindFirstChild(Config.ToolName) then
        humanoid:UnequipTools()
    else
        local tool = player.Backpack:FindFirstChild(Config.ToolName)
        if tool then
            humanoid:EquipTool(tool)
        end
    end
end
equipButton.Activated:Connect(toggleEquip)
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.UserInputType == Enum.UserInputType.Touch then
        touchStarts[input] = {position = input.Position, time = os.clock()}
    end
    if not processed and input.KeyCode == Enum.KeyCode.G then
        toggleEquip()
    end
end)
-- 기존 건물 목표 선택 입력은 그대로 둡니다. 터치 이동·카메라 드래그는 발사하지 않습니다.
UIS.InputEnded:Connect(function(input, processed)
    if processed or not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        return
    end
    if input.UserInputType == Enum.UserInputType.Touch then
        local start = touchStarts[input]
        touchStarts[input] = nil
        if not start or (input.Position - start.position).Magnitude > 12 or os.clock() - start.time > 0.45 then
            return
        end
    end
    local character = player.Character
    if not character or not character:FindFirstChild(Config.ToolName) or os.clock() - lastShot < Config.FireCooldown then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
    local ignored = { character, visuals }
    local missileVisuals = workspace:FindFirstChild("PetMissileVisuals")
    if missileVisuals then
        table.insert(ignored, missileVisuals)
    end
    local cities = workspace:FindFirstChild("ProjectMS_PersonalCities")
    for _, folder in ipairs(cities and cities:GetChildren() or {}) do
        if folder:GetAttribute("OwnerUserId") ~= player.UserId then
            table.insert(ignored, folder)
        end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignored
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    lastShot = os.clock()
    remotes.Shoot:FireServer(hit and hit.Position or ray.Origin + ray.Direction * Config.Range)
end)
local function visualPart(position)
    local part = Instance.new("Part")
    part.Size = Vector3.one * 0.1
    part.CFrame = CFrame.new(position)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Parent = visuals
    Debris:AddItem(part, 0.7)
    return part
end
remotes.Trace.OnClientEvent:Connect(function(origin, endpoint)
    local first = visualPart(origin)
    local last = visualPart(endpoint)
    local a = Instance.new("Attachment", first)
    local b = Instance.new("Attachment", last)
    for _, width in ipairs({0.35, 0.12}) do
        local beam = Instance.new("Beam")
        beam.Name = "VisiblePistolTrajectory"
        beam.Attachment0 = a
        beam.Attachment1 = b
        beam.Width0 = width
        beam.Width1 = width
        beam.FaceCamera = true
        beam.LightEmission = 1
        beam.Color = ColorSequence.new(width > 0.2 and Color3.fromRGB(255, 178, 30) or Color3.new(1, 1, 1))
        beam.Parent = first
        task.delay(Config.TraceLifetime, function()
            beam.Enabled = false
        end)
    end
    local bullet = visualPart(origin)
    bullet.Name = "VisiblePistolBullet"
    bullet.Shape = Enum.PartType.Ball
    bullet.Size = Vector3.one * 0.55
    bullet.Transparency = 0
    bullet.Material = Enum.Material.Neon
    bullet.Color = Color3.fromRGB(255, 234, 120)
    local duration = math.clamp((endpoint - origin).Magnitude / 400, 0.1, 0.35)
    local flight = TweenService:Create(bullet, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = endpoint})
    flight:Play()
    flight.Completed:Once(function()
        bullet:Destroy()
        local spark = visualPart(endpoint)
        spark.Transparency = 0
        spark.Material = Enum.Material.Neon
        spark.Color = Color3.fromRGB(255, 220, 70)
        spark.Shape = Enum.PartType.Ball
        TweenService:Create(spark, TweenInfo.new(0.18), {Size = Vector3.one * 0.9, Transparency = 1}):Play()
    end)
    gui:SetAttribute("TracesSeen", (gui:GetAttribute("TracesSeen") or 0) + 1)
end)
remotes.Notice.OnClientEvent:Connect(notice)
network.ProgressionState.OnClientEvent:Connect(function(state)
    clearedZone1 = state.zoneClears and (state.zoneClears["1-1"] or 0) > 0 or false
end)
local elapsed = 0
RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.15 then
        return
    end
    elapsed = 0
    local ownBase
    for _, base in ipairs(workspace.ProjectMS_Bases:GetChildren()) do
        local owner = base:GetAttribute("OwnerUserId")
        local locked = base:GetAttribute("VisitLocked") and owner and owner ~= 0 and owner ~= player.UserId
        local gate = base:FindFirstChild("VisitGate")
        if gate then
            local front = gate:FindFirstChild("Barrier")
            local rear = gate:FindFirstChild("LaneBarrier")
            local control = gate:FindFirstChild("Control")
            if front then
                front.CanCollide = locked == true
            end
            if rear then
                rear.CanCollide = locked == true
            end
            local prompt = control and control:FindFirstChild("ToggleVisitLock")
            if prompt then
                prompt.Enabled = owner == player.UserId
            end
        end
        if owner == player.UserId then
            ownBase = base
        end
    end
    constructionHint.Adornee = ownBase and ownBase:FindFirstChild("Layout") and ownBase.Layout:FindFirstChild("TechLab")
    constructionHint.Enabled = ownBase ~= nil and clearedZone1 and (ownBase:GetAttribute("Facility_TechLab") or 0) == 0
    constructionHint.FillTransparency = 0.7 + math.sin(os.clock() * 3) * 0.15
    local character = player.Character
    local key = UIS.KeyboardEnabled and " [G]" or ""
    equipButton.Text = (character and character:FindFirstChild(Config.ToolName) and "권총 해제" or "권총 장착") .. key
end)
pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)
