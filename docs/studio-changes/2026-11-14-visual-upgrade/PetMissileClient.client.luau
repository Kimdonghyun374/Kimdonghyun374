-- 서버 상태를 미사일 모델과 HUD로 표현합니다. 발사 수와 피해 판정은 서버가 결정합니다.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local network = ReplicatedStorage:WaitForChild("PetMissiles")
local Config = require(network.Config)
local playerStates, playerRacks, activeFlights = {}, {}, {}
local UIAssets = require(network:WaitForChild("UIAssets"))
local GameSounds = require(network:WaitForChild("GameSounds"))
local MissileVFX = require(network:WaitForChild("MissileVFX"))
local FX_QUALITY = UserInputService.TouchEnabled and 0.4 or 0.65
local impactWindow, impactBursts = 0, 0
-- 입장 동기화로 받은 오래된 비행에는 발사음을 내지 않습니다(초).
local LAUNCH_SOUND_MAX_AGE = 0.3
local selectedTarget, localPlayerState
local message, messageUntil = "", 0
local lastRequest = -math.huge
local visualFolder = Instance.new("Folder")
visualFolder.Name = "PetMissileVisuals"
visualFolder.Parent = workspace
MissileVFX.Container = visualFolder

local function createVisualPart(name, size, color, frame, parent)
    local partInstance = Instance.new("Part")
    partInstance.Name = name
    partInstance.Size = size
    partInstance.Color = color
    partInstance.CFrame = frame
    partInstance.Anchored = true
    partInstance.CanCollide = false
    partInstance.CanTouch = false
    partInstance.CanQuery = false
    partInstance.Material = Enum.Material.SmoothPlastic
    partInstance.Parent = parent
    return partInstance
end

local MissileModels = require(network:WaitForChild("MissileModels"))
local READY_LENGTH, FLYING_LENGTH = 1.9, 2.4

-- 자산 미사일 모델로 만든 모습(2026-11-13). 없으면 아래 기본 모양을 씁니다.
local function attachFlightVFX(model)
    local flyingCount = 0
    for _ in pairs(activeFlights) do
        flyingCount += 1
    end
    MissileVFX.Quality = flyingCount >= 24 and FX_QUALITY * 0.5 or FX_QUALITY
    model:SetAttribute("Scale", 0.65)
    MissileVFX.attach(model)
    visualFolder:SetAttribute("FlightVFXCount", (visualFolder:GetAttribute("FlightVFXCount") or 0) + 1)
end

local function createAssetMissile(flying, color, assetName)
    local model = MissileModels.Build(assetName, flying and FLYING_LENGTH or READY_LENGTH)
    if not model then
        return nil
    end
    model.Name = flying and "FlyingMissile" or "ReadyMissile"
    model.Parent = visualFolder
    if flying then
        attachFlightVFX(model)
    end
    return model
end

local function createMissileModel(flying, color, assetName)
    local assetModel = assetName and createAssetMissile(flying, color, assetName)
    if assetModel then
        return assetModel
    end
    local model = Instance.new("Model")
    model.Name = flying and "FlyingMissile" or "ReadyMissile"
    local body = createVisualPart(
        "Body",
        Vector3.new(0.42, 0.42, 1.6),
        Color3.fromRGB(215, 231, 240),
        CFrame.identity,
        model
    )
    model.PrimaryPart = body
    local tint = color and Color3.fromRGB(table.unpack(color)) or Color3.fromRGB(75, 231, 210)
    local nose = createVisualPart("Nose", Vector3.one * 0.46, tint, CFrame.new(0, 0, -0.9), model)
    if color then
        body.Color = tint:Lerp(Color3.new(1, 1, 1), 0.45)
    end
    nose.Shape = Enum.PartType.Ball
    nose.Material = Enum.Material.Neon
    createVisualPart(
        "Fin",
        Vector3.new(0.95, 0.09, 0.6),
        Color3.fromRGB(41, 72, 105),
        CFrame.new(0, 0, 0.65),
        model
    )
    createVisualPart(
        "FinVertical",
        Vector3.new(0.09, 0.8, 0.6),
        Color3.fromRGB(41, 72, 105),
        CFrame.new(0, 0, 0.65),
        model
    )
    if flying then
        attachFlightVFX(model)
    end
    model.Parent = visualFolder
    return model
end
-- 6시 집중 공격 버튼 (2026-11-10 축소): 동그란 버튼 하나 + 아이콘 + F 표시 + 게이지.
-- 색은 UITheme v03 팔레트 값을 직접 씁니다(이 HUD는 UIThemeClient 치환 대상에서 빠짐).
local FOCUS_BUTTON_SIZE = 84
local COLOR_PANEL = Color3.fromRGB(250, 252, 255)
local COLOR_STROKE = Color3.fromRGB(195, 213, 250)
local COLOR_CHARGING = Color3.fromRGB(150, 190, 250)
local COLOR_READY = Color3.fromRGB(255, 165, 30)
local COLOR_TEXT_DARK = Color3.fromRGB(16, 39, 94)
local COLOR_DISABLED = Color3.fromRGB(205, 213, 226)

local gui = Instance.new("ScreenGui")
gui.Name = "PetMissileHUD"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, UserInputService.TouchEnabled and -140 or -24)
panel.Size = UDim2.fromOffset(FOCUS_BUTTON_SIZE, FOCUS_BUTTON_SIZE)
panel.BackgroundTransparency = 1
panel.Parent = gui

local button = Instance.new("ImageButton")
button.Name = "Focus"
button.Size = UDim2.fromScale(1, 1)
button.BackgroundColor3 = COLOR_PANEL
button.AutoButtonColor = true
button.Image = ""
button.Parent = panel
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0.5, 0)
buttonCorner.Parent = button
local buttonStroke = Instance.new("UIStroke")
buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
buttonStroke.Thickness = 3
buttonStroke.Color = COLOR_STROKE
buttonStroke.Parent = button

-- 게이지: 버튼 아래 둥근 막대. (CanvasGroup 둥근 잘라내기는 화면에서 네모로 보여서 2026-11-10 교체)
local gaugeTrack = Instance.new("Frame")
gaugeTrack.Name = "Gauge"
gaugeTrack.AnchorPoint = Vector2.new(0.5, 0)
gaugeTrack.Position = UDim2.new(0.5, 0, 1, 6)
gaugeTrack.Size = UDim2.new(1, 0, 0, 8)
gaugeTrack.BackgroundColor3 = COLOR_DISABLED
gaugeTrack.BorderSizePixel = 0
gaugeTrack.Parent = panel
local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(0.5, 0)
trackCorner.Parent = gaugeTrack
local gaugeFill = Instance.new("Frame")
gaugeFill.Name = "Fill"
gaugeFill.Size = UDim2.fromScale(1, 1)
gaugeFill.BorderSizePixel = 0
gaugeFill.BackgroundColor3 = COLOR_READY
gaugeFill.Parent = gaugeTrack
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0.5, 0)
fillCorner.Parent = gaugeFill

local focusIcon = Instance.new("ImageLabel")
focusIcon.Name = "Icon"
focusIcon.AnchorPoint = Vector2.new(0.5, 0.5)
focusIcon.Position = UDim2.fromScale(0.5, 0.5)
focusIcon.Size = UDim2.fromScale(0.68, 0.68)
focusIcon.BackgroundTransparency = 1
focusIcon.ScaleType = Enum.ScaleType.Fit
focusIcon.Image = UIAssets.focusSkill or UIAssets.focus
focusIcon.ZIndex = 3
focusIcon.Parent = button

-- 키보드가 있을 때만 오른쪽 위에 F 표시
local keyBadge = Instance.new("TextLabel")
keyBadge.Name = "KeyBadge"
keyBadge.AnchorPoint = Vector2.new(0.5, 0.5)
keyBadge.Position = UDim2.fromScale(0.88, 0.12)
keyBadge.Size = UDim2.fromOffset(26, 26)
keyBadge.BackgroundColor3 = COLOR_TEXT_DARK
keyBadge.TextColor3 = COLOR_PANEL
keyBadge.Font = Enum.Font.GothamBlack
keyBadge.TextSize = 15
keyBadge.Text = "F"
keyBadge.ZIndex = 4
keyBadge.Visible = UserInputService.KeyboardEnabled
keyBadge.Parent = button
local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0.5, 0)
keyCorner.Parent = keyBadge

-- 거절 이유 등 서버 안내는 버튼 위에 2초만 띄웁니다.
local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 0, -8)
hint.Size = UDim2.fromOffset(260, 26)
hint.BackgroundColor3 = COLOR_PANEL
hint.TextColor3 = COLOR_TEXT_DARK
hint.Font = Enum.Font.GothamBold
hint.TextSize = 13
hint.Visible = false
hint.Parent = panel
local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 10)
hintCorner.Parent = hint
local highlight = Instance.new("Highlight")
highlight.Name = "SelectedMissileEnemy"
highlight.FillTransparency = 0.8
highlight.OutlineColor = Color3.fromRGB(255, 196, 80)
highlight.Enabled = false
highlight.Parent = visualFolder

local function getTargetRoot(model)
    return model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
end

local function isValidEnemy(model)
    if
        not model
        or not model:IsA("Model")
        or not model:IsDescendantOf(workspace)
        or Players:GetPlayerFromCharacter(model)
        or model:GetAttribute("WorldTemplate")
        or (
            model:GetAttribute("PersonalBuilding")
            and model:GetAttribute("OwnerUserId") ~= player.UserId
        )
    then
        return false
    end
    local personalCities = workspace:FindFirstChild("ProjectMS_PersonalCities")
    if
        model:GetAttribute("PersonalBuilding")
        and personalCities
        and personalCities:GetAttribute("Phase") == "Night"
    then
        return false
    end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 or not getTargetRoot(model) then
        return false
    end
    local enemies, demo =
        workspace:FindFirstChild(Config.EnemyFolder), workspace:FindFirstChild(Config.DemoFolder)
    return CollectionService:HasTag(model, Config.EnemyTag)
        or (enemies and model:IsDescendantOf(enemies))
        or (demo and model:IsDescendantOf(demo))
end

local function selectTargetAt(position)
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local ray = camera:ScreenPointToRay(position.X, position.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = player.Character
            and { player.Character, visualFolder }
        or { visualFolder }
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    local model = hit and hit.Instance:FindFirstAncestorOfClass("Model")
    while model and not isValidEnemy(model) do
        model = model.Parent and model.Parent:FindFirstAncestorOfClass("Model")
    end
    if model then
        selectedTarget = model
    end
end

local function requestFocus()
    local time = workspace:GetServerTimeNow()
    if time - lastRequest < Config.RequestInterval then
        return
    end
    lastRequest = time
    network.Focus:FireServer({ target = selectedTarget })
end
button.Activated:Connect(requestFocus)
ContextActionService:BindAction("PetMissileFocus", function(_, state)
    if state == Enum.UserInputState.Begin then
        requestFocus()
    end
    return Enum.ContextActionResult.Sink
end, false, Config.FocusKey)
UserInputService.InputEnded:Connect(function(input, processed)
    if processed then
        return
    end
    if
        input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        selectTargetAt(input.Position)
    end
end)
network.Status.OnClientEvent:Connect(function(value)
    message, messageUntil = tostring(value), workspace:GetServerTimeNow() + 2
    -- 서버가 거절한 경우에만 오는 안내입니다.
    GameSounds.Play("UIDenied")
end)
network.State.OnClientEvent:Connect(function(list)
    local nextStates = {}
    for _, playerState in list do
        nextStates[playerState.owner] = playerState
        if playerState.owner == player.UserId then
            if localPlayerState and localPlayerState.character ~= playerState.character then
                selectedTarget = nil
            end
            -- 게이지가 가득 → 0으로 떨어지면 서버가 집중 공격(전탄 재장전)을 승인한 것입니다.
            if
                localPlayerState
                and localPlayerState.focusMax
                and (localPlayerState.focusCharge or 0) >= localPlayerState.focusMax
                and (playerState.focusCharge or 0) < (localPlayerState.focusCharge or 0)
            then
                GameSounds.Play("FocusReload")
            end
            localPlayerState = playerState
        end
    end
    playerStates = nextStates
end)
network.Visual.OnClientEvent:Connect(function(kind, data)
    if kind == "Spawn" then
        if activeFlights[data.id] then
            return
        end
        data.model = createMissileModel(true, data.color, data.asset)
        data.model:PivotTo(CFrame.new(data.origin))
        activeFlights[data.id] = data
        if workspace:GetServerTimeNow() - data.startedAt <= LAUNCH_SOUND_MAX_AGE then
            GameSounds.PlayAt("MissileLaunch", data.origin)
        end
        local playerState = playerStates[data.owner]
        if playerState and playerState.slots[data.slot] then
            playerState.slots[data.slot] = data.startedAt + Config.ReloadTime
        end
    elseif kind == "End" then
        local flight = activeFlights[data.id]
        local rarity = flight and flight.model:GetAttribute("Rarity") or "common"
        if flight then
            flight.model:Destroy()
            activeFlights[data.id] = nil
        end
        if data.position then
            local flash = createVisualPart(
                "Impact",
                Vector3.one * (data.hit and 2 or 0.7),
                data.hit and Color3.fromRGB(255, 188, 74) or Color3.fromRGB(95, 166, 180),
                CFrame.new(data.position),
                visualFolder
            )
            flash.Shape = Enum.PartType.Ball
            flash.Material = Enum.Material.Neon
            Debris:AddItem(flash, 0.18)
            if data.hit then
                GameSounds.PlayAt("MissileImpact", data.position)
                -- 화면 주변 폭발만 표시하고 동시 집중 사격의 파티클 양을 제한합니다.
                local camera = workspace.CurrentCamera
                local time = os.clock()
                if time - impactWindow >= 1 then
                    impactWindow, impactBursts = time, 0
                end
                if camera and (camera.CFrame.Position - data.position).Magnitude <= 240 and impactBursts < 10 then
                    impactBursts += 1
                    MissileVFX.Quality = FX_QUALITY
                    MissileVFX.explode(data.position, rarity, 0.65)
                    visualFolder:SetAttribute("ImpactVFXCount", (visualFolder:GetAttribute("ImpactVFXCount") or 0) + 1)
                end
            end
        end
    end
end)
local function updateMissileRacks(time, deltaTime)
    for owner, rack in pairs(playerRacks) do
        local playerState = playerStates[owner]
        if not playerState or playerState.character ~= rack.character or not playerState.alive then
            for _, missileModel in pairs(rack.models) do
                missileModel:Destroy()
            end
            playerRacks[owner] = nil
        end
    end
    for owner, playerState in pairs(playerStates) do
        local rootPart = playerState.alive
            and playerState.character
            and playerState.character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local rack = playerRacks[owner]
            if not rack then
                rack = { character = playerState.character, models = {} }
                playerRacks[owner] = rack
            end
            for i, missileModel in pairs(rack.models) do
                if i > playerState.count or (playerState.slots[i] or math.huge) > time then
                    missileModel:Destroy()
                    rack.models[i] = nil
                end
            end
            for i = 1, playerState.count do
                if playerState.slots[i] and playerState.slots[i] <= time then
                    local offset = Config.Offset(i, playerState.count)
                        + Vector3.yAxis
                            * math.sin(time * Config.BobSpeed + i)
                            * Config.BobAmplitude
                    local targetFrame = rootPart.CFrame
                        * CFrame.new(offset)
                        * CFrame.Angles(math.rad(-12), 0, 0)
                    local missileModel = rack.models[i]
                    local item = playerState.equipment and playerState.equipment[i]
                    local itemId = item and tostring(item.id) or "default"
                    if missileModel and missileModel:GetAttribute("ItemId") ~= itemId then
                        missileModel:Destroy()
                        missileModel = nil
                    end
                    if not missileModel then
                        missileModel = createMissileModel(false, item and item.color, item and item.model)
                        missileModel:SetAttribute("ItemId", itemId)
                        missileModel:PivotTo(targetFrame)
                        rack.models[i] = missileModel
                    end
                    missileModel:PivotTo(
                        missileModel
                            :GetPivot()
                            :Lerp(targetFrame, 1 - math.exp(-Config.FollowResponse * deltaTime))
                    )
                end
            end
        end
    end
end

local function updateFlightVisuals(time)
    for id, flight in pairs(activeFlights) do
        local rootPart = getTargetRoot(flight.target)
        if
            not rootPart
            or not flight.target:IsDescendantOf(workspace)
            or time > flight.startedAt + flight.duration + 1
        then
            flight.model:Destroy()
            activeFlights[id] = nil
        else
            local position = Config.Position(flight, time, rootPart.Position)
            local ahead = Config.Position(flight, time + 0.015, rootPart.Position)
            local delta = ahead - position
            local frame = delta.Magnitude > 0.001 and CFrame.lookAt(position, ahead)
                or CFrame.new(position)
            flight.model:PivotTo(frame)
        end
    end
end

-- 게이지 높이와 버튼 색만 바꿉니다. 글자는 안내가 있을 때만 띄웁니다.
local function updateCombatHud(time)
    local charge, chargeMax = 0, 1
    local hasMissiles, isAlive = false, false
    if localPlayerState then
        charge = localPlayerState.focusCharge or 0
        chargeMax = localPlayerState.focusMax or 1
        hasMissiles = localPlayerState.count > 0
        isAlive = localPlayerState.alive
    end
    local ratio = math.clamp(charge / chargeMax, 0, 1)
    local isReady = ratio >= 1 and hasMissiles and isAlive
    gaugeFill.Size = UDim2.fromScale(ratio, 1)
    gaugeFill.Visible = ratio > 0
    gaugeFill.BackgroundColor3 = ratio >= 1 and COLOR_READY or COLOR_CHARGING
    if isReady then
        -- 가득 찬 때 테두리가 천천히 깜빡입니다.
        local pulse = (math.sin(time * 5) + 1) / 2
        buttonStroke.Color = COLOR_READY:Lerp(COLOR_PANEL, pulse * 0.5)
        buttonStroke.Thickness = 3 + pulse * 2
        focusIcon.ImageTransparency = 0
    else
        buttonStroke.Color = hasMissiles and COLOR_STROKE or COLOR_DISABLED
        buttonStroke.Thickness = 3
        focusIcon.ImageTransparency = 0.45
    end
    hint.Visible = time < messageUntil and message ~= ""
    hint.Text = message
end

RunService.RenderStepped:Connect(function(deltaTime)
    local time = workspace:GetServerTimeNow()
    if selectedTarget and not isValidEnemy(selectedTarget) then
        selectedTarget = nil
    end
    highlight.Adornee = selectedTarget
    highlight.Enabled = selectedTarget ~= nil
    updateMissileRacks(time, deltaTime)
    updateFlightVisuals(time)
    updateCombatHud(time)
end)
script.Destroying:Connect(function()
    ContextActionService:UnbindAction("PetMissileFocus")
    visualFolder:Destroy()
    gui:Destroy()
end)
network.Sync:FireServer()
