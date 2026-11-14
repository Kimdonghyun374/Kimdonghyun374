-- 관리자(게임 주인) 전용 테스트 기능: 순간이동·자원 지급·레이드 시작·시간 고정(2026-11-14).
-- 모든 요청은 서버에서 주인인지 다시 확인합니다. 클라이언트가 보낸 좌표·금액은 쓰지 않고 정해진 항목만 실행합니다.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local petMissiles = script.Parent
local BaseService = require(petMissiles:WaitForChild("BaseService"))
local ProgressionService = require(petMissiles:WaitForChild("ProgressionService"))
local RaidService = require(petMissiles:WaitForChild("RaidService"))
local network = ReplicatedStorage:WaitForChild("PetMissiles")

local REQUEST_INTERVAL = 0.25
local ADMIN_ATTRIBUTE = "ProjectMSAdmin"
-- 낮·밤 고정용 시험 시각(초). 낮 180초 + 밤 25초 주기에서 낮 한가운데·밤 한가운데.
local FIXED_DAY_TIME = 90
local FIXED_NIGHT_TIME = 192

-- 정해진 지급량만 허용합니다.
local GRANTS = {
    coins100 = { scrap = 100, research = 0 },
    coins1000 = { scrap = 1000, research = 0 },
    research10 = { scrap = 0, research = 10 },
}

local adminEvent = network:FindFirstChild("AdminRequest") or Instance.new("RemoteEvent")
adminEvent.Name = "AdminRequest"
adminEvent.Parent = network

local lastRequests = {}

-- 게임 주인(개인 소유 게임의 CreatorId)만 관리자. Studio 로컬 시험의 가짜 플레이어(음수 Id)는 Studio에서만 허용.
local function isAdmin(player)
    if game.CreatorType == Enum.CreatorType.User and player.UserId == game.CreatorId then
        return true
    end
    return RunService:IsStudio() and player.UserId <= 0
end

local function reply(player, text)
    adminEvent:FireClient(player, { message = text })
end

local function rootOf(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not rootPart then
        return nil
    end
    return character, humanoid, rootPart
end

-- 기준 파트 위로 순간이동합니다(탈것에서 먼저 내립니다). offset은 파트 중심에서 옆으로 옮길 거리.
local function teleportTo(player, part, label, offset)
    local character, humanoid, rootPart = rootOf(player)
    if not character then
        reply(player, "캐릭터가 없습니다")
        return
    end
    if not part then
        reply(player, label .. ": 위치를 찾을 수 없습니다")
        return
    end
    BaseService.PrepareTravel(player)
    humanoid.Sit = false
    character:PivotTo(CFrame.new(part.Position + (offset or Vector3.zero) + Vector3.new(0, part.Size.Y / 2 + 4, 0)))
    rootPart.AssemblyLinearVelocity = Vector3.zero
    reply(player, label .. "(으)로 이동")
end

local function myLane(player)
    local plotId = BaseService.GetPlotId(player)
    local lanes = workspace:FindFirstChild("ProjectMS_Lanes")
    return plotId and lanes and lanes:FindFirstChild("Lane_" .. plotId), plotId
end

local function emptyBasePad()
    local bases = workspace:FindFirstChild("ProjectMS_Bases")
    for _, base in bases and bases:GetChildren() or {} do
        local owner = base:GetAttribute("OwnerUserId")
        if not owner or owner == 0 then
            return base:FindFirstChild("ClaimPad")
        end
    end
    return nil
end

local TELEPORTS = {
    plaza = function(player)
        teleportTo(player, workspace:FindFirstChildOfClass("SpawnLocation"), "광장 스폰")
    end,
    raid = function(player)
        local lanes = workspace:FindFirstChild("ProjectMS_Lanes")
        local arena = lanes and lanes:FindFirstChild("RaidArena")
        -- 가운데는 보스 표지가 있어 그 위에 서게 되므로 스폰 쪽 가장자리 바닥으로 갑니다.
        teleportTo(player, arena and arena:FindFirstChild("RaidFloor"), "레이드 자리", Vector3.new(0, 0, -60))
    end,
    myBase = function(player)
        local _, plotId = myLane(player)
        local bases = workspace:FindFirstChild("ProjectMS_Bases")
        local base = plotId and bases and bases:FindFirstChild("Base_" .. plotId)
        if not base then
            reply(player, "차지한 기지가 없습니다")
            return
        end
        teleportTo(player, base:FindFirstChild("Generator") or base:FindFirstChild("Floor"), "내 기지")
    end,
    emptyBase = function(player)
        teleportTo(player, emptyBasePad(), "빈 기지 발판")
    end,
    world1 = function(player)
        local lane = myLane(player)
        local entry = lane and lane:FindFirstChild("Entry")
        if not entry then
            local worlds = workspace:FindFirstChild("ProjectMS_Worlds")
            local world1 = worlds and worlds:FindFirstChild("World_1")
            entry = world1 and world1:FindFirstChild("Entry")
        end
        teleportTo(player, entry, "1월드 입구")
    end,
    zone2 = function(player)
        local lane = myLane(player)
        teleportTo(player, lane and lane:FindFirstChild("Zone2_Ground"), "구역2(잠겨 있으면 문 앞으로 밀려남)")
    end,
    zone3 = function(player)
        local lane = myLane(player)
        teleportTo(player, lane and lane:FindFirstChild("Zone3_Ground"), "구역3(잠겨 있으면 문 앞으로 밀려남)")
    end,
    world2 = function(player)
        -- 진행 조건·낮밤 규칙은 기존 EnterWorld를 그대로 따릅니다.
        if not ProgressionService.EnterWorld(player, 2) then
            reply(player, "2월드 진입 실패(조건·밤 확인)")
        end
    end,
}

local function handle(player, request)
    if type(request) ~= "table" or type(request.action) ~= "string" then
        return
    end
    if request.action == "teleport" and TELEPORTS[request.target] then
        TELEPORTS[request.target](player)
    elseif request.action == "grant" and GRANTS[request.kind] then
        local grant = GRANTS[request.kind]
        if BaseService.GrantResources(player, grant.scrap, grant.research) then
            reply(player, string.format("지급: 코인 %d · 연구자료 %d", grant.scrap, grant.research))
        else
            reply(player, "지급 실패(프로필 불러오는 중?)")
        end
    elseif request.action == "raidNow" then
        reply(player, RaidService.StartWarningNow(10) and "레이드 예고 시작(10초)" or "이미 레이드 진행 중")
    elseif request.action == "time" and RunService:IsStudio() then
        local fixed = request.mode == "day" and FIXED_DAY_TIME or request.mode == "night" and FIXED_NIGHT_TIME or nil
        ProgressionService.SetStudioTime(fixed)
        reply(player, fixed and ("시간 고정: " .. (request.mode == "day" and "낮" or "밤")) or "시간 정상 흐름")
    end
end

adminEvent.OnServerEvent:Connect(function(player, request)
    if not isAdmin(player) then
        return
    end
    local now = os.clock()
    if now - (lastRequests[player] or -math.huge) < REQUEST_INTERVAL then
        return
    end
    lastRequests[player] = now
    handle(player, request)
end)

local function onPlayerAdded(player)
    if isAdmin(player) then
        -- Studio 여부를 먼저 넣어야 창을 만들 때 시간 버튼 표시가 맞습니다.
        player:SetAttribute("ProjectMSAdminStudio", RunService:IsStudio())
        player:SetAttribute(ADMIN_ATTRIBUTE, true)
    end
end
for _, player in Players:GetPlayers() do
    onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    lastRequests[player] = nil
end)
