-- 탈것(차고) 서비스. 2026-11-13: '걷기와 같은 조작' — 탈것 모형을 캐릭터 발밑에 붙이고
-- 이동 속도(WalkSpeed)만 올립니다. 이동·카메라·점프·모바일 조이스틱은 기본 캐릭터 그대로입니다.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local network = game.ReplicatedStorage:WaitForChild("PetMissiles")
local Config = require(network.VehicleConfig)
local Rules = require(script.Parent.VehicleRules)
local Base = require(script.Parent.BaseService)
local Service = {}
local records, lastActions, nextSummon = {}, {}, {}
local root, started, broadcastElapsed = nil, false, 0

local function ownerHumanoid(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local part = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not part then
        return nil
    end
    return humanoid, part
end

local function levelFor(player)
    return Rules.Level(Base.GetProgression(player))
end

local function definitionFor(level)
    return Config.Levels[math.clamp(level, 1, #Config.Levels)]
end

function Service.GetState(player)
    local baseState = Base.GetState(player)
    local level = levelFor(player)
    local nextLevel = Config.Levels[level + 1]
    local record = records[player]
    return {
        ready = baseState.ready,
        scrap = baseState.scrap,
        researchData = baseState.researchData,
        level = level,
        owned = level > 0,
        name = level > 0 and definitionFor(level).name or nil,
        maxLevel = #Config.Levels,
        nextName = nextLevel and nextLevel.name,
        nextCost = nextLevel and nextLevel.cost,
        nextResearch = nextLevel and nextLevel.research,
        nextSpeed = nextLevel and nextLevel.speed,
        topSpeed = level > 0 and definitionFor(level).speed or 0,
        spawned = record ~= nil,
        driving = record ~= nil,
        speed = record and definitionFor(level).speed or 0,
        summonRemaining = math.max(0, (nextSummon[player] or 0) - os.clock()),
    }
end

local function sendState(player, message, open)
    if player.Parent == Players then
        network.VehicleState:FireClient(player, Service.GetState(player), message, open)
    end
end

-- 단계별 모형: 보드(1·2단계)는 판 + 추진기, 3단계는 앞부분이 있는 호버바이크. 색으로 단계 구분.
local function buildMount(level)
    local definition = definitionFor(level)
    local color = Color3.fromRGB(table.unpack(definition.color))
    local model = Instance.new("Model")
    local function part(name, size, offset, partColor, material)
        local piece = Instance.new("Part")
        piece.Name = name
        piece.Size = size
        piece.CFrame = CFrame.new(offset)
        piece.Color = partColor
        piece.Material = material or Enum.Material.SmoothPlastic
        piece.CanCollide = false
        piece.CanQuery = false
        piece.CanTouch = false
        piece.Massless = true
        piece.Parent = model
        return piece
    end
    local deck = part("Deck", Vector3.new(2.6, 0.35, 5), Vector3.zero, color)
    part("Stripe", Vector3.new(0.6, 0.05, 4.6), Vector3.new(0, 0.2, 0), Color3.fromRGB(245, 245, 250), Enum.Material.Neon)
    part("GlowL", Vector3.new(0.4, 0.25, 4.4), Vector3.new(-1.3, -0.2, 0), Color3.fromRGB(120, 230, 255), Enum.Material.Neon)
    part("GlowR", Vector3.new(0.4, 0.25, 4.4), Vector3.new(1.3, -0.2, 0), Color3.fromRGB(120, 230, 255), Enum.Material.Neon)
    if level >= 2 then
        part("ThrusterL", Vector3.new(0.7, 0.7, 1.1), Vector3.new(-0.8, 0.1, 2.7), Color3.fromRGB(60, 65, 75), Enum.Material.Metal)
        part("ThrusterR", Vector3.new(0.7, 0.7, 1.1), Vector3.new(0.8, 0.1, 2.7), Color3.fromRGB(60, 65, 75), Enum.Material.Metal)
        part("FlameL", Vector3.new(0.45, 0.45, 0.4), Vector3.new(-0.8, 0.1, 3.4), Color3.fromRGB(255, 160, 60), Enum.Material.Neon)
        part("FlameR", Vector3.new(0.45, 0.45, 0.4), Vector3.new(0.8, 0.1, 3.4), Color3.fromRGB(255, 160, 60), Enum.Material.Neon)
    end
    if level >= 3 then
        part("Nose", Vector3.new(2.2, 1.2, 1.4), Vector3.new(0, 0.6, -2.6), color)
        part("Handle", Vector3.new(2.4, 0.25, 0.25), Vector3.new(0, 2.6, -2.2), Color3.fromRGB(40, 40, 45), Enum.Material.Metal)
        part("Stem", Vector3.new(0.3, 2.2, 0.3), Vector3.new(0, 1.5, -2.3), Color3.fromRGB(40, 40, 45), Enum.Material.Metal)
    end
    model.PrimaryPart = deck
    require(network.ArtKit).Vehicle(model)
    for _, piece in model:GetDescendants() do
        if piece:IsA("BasePart") then
            piece.Anchored = false
            piece.Massless = true
        end
        if piece:IsA("BasePart") and piece ~= deck then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = deck
            weld.Part1 = piece
            weld.Parent = piece
        end
    end
    return model
end

function Service.Exit(player)
    local record = records[player]
    if not record then
        return
    end
    records[player] = nil
    if record.model.Parent then
        record.model:Destroy()
    end
    local humanoid = record.humanoid
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = Config.WalkSpeed
        humanoid.HipHeight = record.hipHeight
    end
    sendState(player)
end

function Service.Despawn(player)
    Service.Exit(player)
end

-- 탑승: 보드를 발밑에 붙이고 속도만 올립니다.
function Service.Summon(player)
    local level = levelFor(player)
    if level <= 0 then
        sendState(player, "먼저 차고에서 탈것을 구매하세요")
        return false
    end
    local humanoid, rootPart = ownerHumanoid(player)
    if not humanoid then
        return false
    end
    if humanoid.SeatPart then
        sendState(player, "먼저 자리에서 일어나세요")
        return false
    end
    if os.clock() < (nextSummon[player] or 0) then
        sendState(player, "잠시 후 다시 타세요")
        return false
    end
    Service.Exit(player)
    local definition = definitionFor(level)
    local model = buildMount(level)
    model.Name = "Mount_" .. player.UserId
    model:SetAttribute("OwnerUserId", player.UserId)
    model:SetAttribute("VehicleLevel", level)
    local hipHeight = humanoid.HipHeight
    humanoid.HipHeight = hipHeight + Config.BoardLift
    -- 발 높이(루트 아래 HipHeight + 루트 절반) 바로 밑에 보드를 둡니다.
    local footOffset = -(rootPart.Size.Y / 2 + hipHeight + Config.BoardLift - 0.2)
    model:PivotTo(rootPart.CFrame * CFrame.new(0, footOffset, 0))
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = rootPart
    weld.Part1 = model.PrimaryPart
    weld.Parent = model.PrimaryPart
    model.Parent = root
    humanoid.WalkSpeed = definition.speed
    records[player] = { model = model, humanoid = humanoid, hipHeight = hipHeight }
    nextSummon[player] = os.clock() + Config.SummonCooldown
    sendState(player, definition.name .. " 탑승! 평소처럼 움직이면 됩니다 (내리기 버튼)")
    return true
end

function Service.Upgrade(player, expectedLevel)
    local ok, result = Base.UpgradeBuggy(player, expectedLevel)
    if ok then
        local definition = definitionFor(result)
        if records[player] then
            Service.Exit(player)
            nextSummon[player] = 0
            Service.Summon(player)
        end
        sendState(player, result == 1 and (definition.name .. "을(를) 구매했습니다") or (definition.name .. "(으)로 업그레이드했습니다"))
    else
        sendState(player, result)
    end
    return ok
end

function Service.Step(deltaTime)
    for player, record in pairs(records) do
        local humanoid = ownerHumanoid(player)
        if not Base.GetProgression(player) or not record.model.Parent or humanoid ~= record.humanoid then
            Service.Exit(player)
        end
    end
    broadcastElapsed += deltaTime
    if broadcastElapsed >= 1 then
        broadcastElapsed = 0
        for _, player in Players:GetPlayers() do
            sendState(player)
        end
    end
end

local function connectGaragePrompt(prompt, pad, baseModel)
    prompt.Triggered:Connect(function(player)
        local humanoid, part = ownerHumanoid(player)
        if not humanoid or (part.Position - pad.Position).Magnitude > 16 then
            return
        end
        if baseModel and baseModel:GetAttribute("OwnerUserId") ~= player.UserId then
            sendState(player, "내 기지의 차고에서만 열 수 있습니다")
            return
        end
        sendState(player, nil, true)
    end)
end

function Service.Start()
    if started then
        return
    end
    started = true
    Base.Start()
    Base.SetTravelHandler(Service.Exit)
    root = Instance.new("Folder")
    root.Name = Config.FolderName
    assert(not workspace:FindFirstChild(root.Name), "차량 폴더 충돌")
    root:SetAttribute("ProjectMSManaged", true)
    root.Parent = workspace
    local garage = workspace:FindFirstChild(Config.GarageFolder)
    if garage and garage:FindFirstChild("Pad") and garage.Pad:FindFirstChild("OpenGarage") then
        connectGaragePrompt(garage.Pad.OpenGarage, garage.Pad, nil)
    end
    -- 기지 차고: 각 기지의 Layout.VehiclePad에서 같은 메뉴를 엽니다. 남의 기지 차고는 열지 않습니다.
    local bases = workspace:FindFirstChild("ProjectMS_Bases")
    for _, baseModel in bases and bases:GetChildren() or {} do
        local layout = baseModel:FindFirstChild("Layout")
        local basePad = layout and layout:FindFirstChild("VehiclePad")
        local basePrompt = basePad and basePad:FindFirstChild("OpenGarage")
        if basePrompt then
            connectGaragePrompt(basePrompt, basePad, baseModel)
        end
    end
    network.VehicleRequest.OnServerEvent:Connect(function(player, request)
        if type(request) ~= "table" or request.action == "drive" then
            return
        end
        local now = os.clock()
        if now - (lastActions[player] or -math.huge) < Config.RequestInterval then
            return
        end
        lastActions[player] = now
        if request.action == "upgrade" then
            Service.Upgrade(player, request.level)
        elseif request.action == "summon" then
            Service.Summon(player)
        elseif request.action == "exit" then
            Service.Exit(player)
        elseif request.action == "sync" then
            sendState(player)
        end
    end)
    local function trackCharacter(player)
        player.CharacterRemoving:Connect(function()
            Service.Exit(player)
        end)
    end
    Players.PlayerAdded:Connect(trackCharacter)
    for _, player in Players:GetPlayers() do
        trackCharacter(player)
    end
    Players.PlayerRemoving:Connect(function(player)
        Service.Exit(player)
        lastActions[player], nextSummon[player] = nil, nil
    end)
    RunService.Heartbeat:Connect(Service.Step)
end
return Service
