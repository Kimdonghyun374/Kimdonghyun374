-- 광장 공동 레이드 (2026-11-14 1차). 광장 가운데에 보스가 주기적으로 등장하고,
-- 모두가 미사일로 공격합니다. 처치하면 피해 기여도에 따라 코인·연구자료를 줍니다.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local network = ReplicatedStorage:WaitForChild("PetMissiles")
local RaidConfig = require(network.RaidConfig)
local CombatConfig = require(network.Config)
local CombatService = require(script.Parent.Service)
local BaseService = require(script.Parent.BaseService)
local SocialService = require(script.Parent.SocialService)

local Service = {}

-- 상태: "Idle"(대기) → "Warning"(예고) → "Active"(전투) → "Idle"
local state = {
    phase = "Idle",
    warningAt = 0, -- 다음 예고 시작 시각(서버 시각)
    startsAt = 0,
    endsAt = 0,
    maxHealth = 0,
    damage = {}, -- [player] = 누적 피해
    nextAttackAt = 0,
}
local root, boss, bossHumanoid, warningFolder
local started = false
local broadcastElapsed = 0

local function now()
    return workspace:GetServerTimeNow()
end

local function arenaCenter()
    local arena = workspace:FindFirstChild("ProjectMS_Lanes") and workspace.ProjectMS_Lanes:FindFirstChild("RaidArena")
    local floor = arena and arena:FindFirstChild("RaidFloor")
    return floor and floor.Position or Vector3.new(0, 0, 0), arena
end

local function setArenaMarkerVisible(visible)
    local _, arena = arenaCenter()
    local marker = arena and arena:FindFirstChild("RaidBossMarker")
    if marker then
        marker.Transparency = visible and 0.6 or 1
    end
end

-- 보스 모형(프로토타입): 빨간 코어 + 비행 요새 원반 + 회전 장갑판 + 아래 미사일 포대. 형태로 '보스'임을 알 수 있게.
local function part(parent, name, shape, size, cframe, color, material, transparency)
    local piece = Instance.new("Part")
    piece.Name = name
    piece.Shape = shape or Enum.PartType.Block
    piece.Size = size
    piece.CFrame = cframe
    piece.Color = color
    piece.Material = material or Enum.Material.Metal
    piece.Transparency = transparency or 0
    piece.Anchored = true
    piece.CanCollide = false
    piece.CanTouch = false
    piece.CanQuery = true -- 미사일 충돌 판정용
    piece.CastShadow = false
    piece.Parent = parent
    return piece
end

local function buildBoss(center)
    local model = Instance.new("Model")
    model.Name = "RaidBoss"
    local origin = CFrame.new(center)
    local core = part(model, "Core", Enum.PartType.Ball, Vector3.one * 12, origin, Color3.fromRGB(235, 40, 50), Enum.Material.Neon)
    part(model, "Hull", Enum.PartType.Cylinder, Vector3.new(5, 34, 34), origin * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(55, 60, 72))
    part(model, "HullRim", Enum.PartType.Cylinder, Vector3.new(1.2, 36, 36), origin * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 120, 40), Enum.Material.Neon)
    part(model, "Dome", Enum.PartType.Ball, Vector3.new(18, 18, 18), origin * CFrame.new(0, 4, 0), Color3.fromRGB(80, 88, 104), Enum.Material.Metal, 0.35)
    -- 아래 미사일 포대 4개(주황 끝)
    for index = 1, 4 do
        local angle = math.rad(45 + index * 90)
        local offset = Vector3.new(math.cos(angle) * 9, -5, math.sin(angle) * 9)
        part(model, "Pod", Enum.PartType.Cylinder, Vector3.new(6, 2.4, 2.4), origin * CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(45, 48, 56))
        part(model, "PodTip", Enum.PartType.Ball, Vector3.one * 2.2, origin * CFrame.new(offset + Vector3.new(0, -3, 0)), Color3.fromRGB(255, 150, 40), Enum.Material.Neon)
    end
    -- 회전 장갑판(클라이언트가 돌림)
    local ring = Instance.new("Model")
    ring.Name = "ArmorRing"
    for index = 1, 6 do
        local angle = math.rad(index * 60)
        local offset = Vector3.new(math.cos(angle) * 20, 0, math.sin(angle) * 20)
        part(ring, "Plate", Enum.PartType.Block, Vector3.new(2, 8, 9), CFrame.lookAt(center + offset, center), Color3.fromRGB(150, 40, 45), Enum.Material.DiamondPlate)
    end
    ring.Parent = model
    model.PrimaryPart = core
    -- 체력(전투 시스템은 Humanoid 체력을 깎습니다)
    local humanoid = Instance.new("Humanoid")
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    humanoid.RequiresNeck = false
    humanoid.Parent = model
    -- 보조 이름표
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BossTag"
    billboard.Size = UDim2.fromOffset(260, 40)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 16, 0)
    billboard.MaxDistance = 400
    billboard.AlwaysOnTop = true
    billboard.Parent = core
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(40, 10, 14)
    label.BackgroundTransparency = 0.2
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 120, 110)
    label.Text = RaidConfig.BossName
    label.Parent = billboard
    model:SetAttribute("RaidBoss", true)
    require(network.ArtKit).Boss(model)
    return model, humanoid
end

-- 보스를 위아래로 옮기는 연출(서버에서 짧게 PivotTo)
local function moveBoss(model, fromHeight, toHeight, seconds)
    local center = arenaCenter()
    local steps = math.max(1, math.floor(seconds / 0.05))
    for step = 0, steps do
        if not model.Parent then
            return
        end
        local alpha = step / steps
        local height = fromHeight + (toHeight - fromHeight) * (1 - (1 - alpha) ^ 2)
        model:PivotTo(CFrame.new(center + Vector3.new(0, height, 0)))
        task.wait(0.05)
    end
end

local function clearWarnings()
    if warningFolder then
        warningFolder:ClearAllChildren()
    end
end

local function despawnBoss()
    clearWarnings()
    if boss then
        boss:Destroy()
    end
    boss, bossHumanoid = nil, nil
    setArenaMarkerVisible(true)
end

-- 클라이언트에 보낼 공통 상태
local function publicState()
    return {
        phase = state.phase,
        warningAt = state.warningAt,
        startsAt = state.startsAt,
        endsAt = state.endsAt,
        health = bossHumanoid and bossHumanoid.Health or 0,
        maxHealth = state.maxHealth,
        serverTime = now(),
    }
end

local function broadcast()
    local snapshot = publicState()
    for _, player in Players:GetPlayers() do
        local personal = table.clone(snapshot)
        personal.myDamage = state.damage[player] or 0
        network.RaidEvent:FireClient(player, "state", personal)
    end
end

local function startWarning()
    state.phase = "Warning"
    state.startsAt = state.warningAt + RaidConfig.WarningDuration
    broadcast()
end

local function startBattle()
    local center = arenaCenter()
    state.phase = "Active"
    state.startsAt = now()
    state.endsAt = state.startsAt + RaidConfig.Duration
    state.damage = {}
    state.maxHealth = RaidConfig.HealthPerPlayer * math.max(1, #Players:GetPlayers())
    state.nextAttackAt = state.startsAt + RaidConfig.AttackInterval
    boss, bossHumanoid = buildBoss(center + Vector3.new(0, 120, 0))
    bossHumanoid.MaxHealth = state.maxHealth
    bossHumanoid.Health = state.maxHealth
    boss.Parent = root
    setArenaMarkerVisible(false)
    task.spawn(moveBoss, boss, 120, RaidConfig.BossHeight, 3)
    -- 내려온 뒤 전투 대상으로 등록(내려오는 중에는 쏘지 않음)
    task.delay(3, function()
        if boss and boss.Parent then
            CollectionService:AddTag(boss, CombatConfig.EnemyTag)
        end
    end)
    broadcast()
end

-- 처치 보상: 참여(1% 이상) 기본 + 기여 비례 + 최고 피해자 추가
local function payRewards()
    local threshold = state.maxHealth * RaidConfig.ParticipationRatio
    local total, topPlayer, topDamage = 0, nil, 0
    for player, amount in state.damage do
        if player.Parent == Players and amount >= threshold then
            total += amount
            if amount > topDamage then
                topPlayer, topDamage = player, amount
            end
        end
    end
    for player, amount in state.damage do
        if player.Parent == Players and amount >= threshold then
            local share = total > 0 and amount / total or 0
            local coins = RaidConfig.ParticipationCoins + math.floor(RaidConfig.ContributionCoins * share + 0.5)
            local research = RaidConfig.ParticipationResearch + (player == topPlayer and RaidConfig.TopDamageResearch or 0)
            BaseService.GrantResources(player, coins, research)
            network.RaidEvent:FireClient(player, "result", {
                won = true,
                coins = coins,
                research = research,
                share = share,
                top = player == topPlayer,
            })
        else
            network.RaidEvent:FireClient(player, "result", { won = true, notParticipated = true })
        end
    end
end

local function finishBattle(won)
    state.phase = "Idle"
    if won then
        payRewards()
    else
        for _, player in Players:GetPlayers() do
            network.RaidEvent:FireClient(player, "result", { won = false })
        end
    end
    local leaving = boss
    if leaving then
        CollectionService:RemoveTag(leaving, CombatConfig.EnemyTag)
    end
    clearWarnings()
    task.spawn(function()
        if leaving and not won then
            moveBoss(leaving, RaidConfig.BossHeight, 140, 2.5)
        end
        if boss == leaving then
            despawnBoss()
        end
    end)
    state.warningAt = state.warningAt + RaidConfig.Interval
    broadcast()
end

-- 경고 원: 플레이어 근처를 먼저, 모자라면 광장 안 아무 곳. AttackWarningTime 뒤 폭발해 넘어뜨립니다.
local function pickAttackPoints(center)
    local points = {}
    local candidates = {}
    for _, player in Players:GetPlayers() do
        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local flat = Vector3.new(rootPart.Position.X - center.X, 0, rootPart.Position.Z - center.Z)
            if flat.Magnitude <= RaidConfig.AttackPlayerRange then
                table.insert(candidates, Vector3.new(rootPart.Position.X, center.Y, rootPart.Position.Z))
            end
        end
    end
    local random = Random.new()
    for index = 1, RaidConfig.AttackCount do
        local base = candidates[index]
        if base then
            table.insert(points, base + Vector3.new(random:NextNumber(-3, 3), 0, random:NextNumber(-3, 3)))
        else
            local angle = random:NextNumber(0, math.pi * 2)
            local distance = random:NextNumber(8, RaidConfig.ArenaRadius - 5)
            table.insert(points, center + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance))
        end
    end
    return points
end

local function explodeAt(position)
    local blast = Instance.new("Explosion")
    blast.Position = position + Vector3.new(0, 1, 0)
    blast.BlastRadius = RaidConfig.AttackRadius
    blast.BlastPressure = 0
    blast.DestroyJointRadiusPercent = 0
    blast.ExplosionType = Enum.ExplosionType.NoCraters
    blast.Parent = workspace
    for _, player in Players:GetPlayers() do
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local offset = rootPart.Position - position
            local flat = Vector3.new(offset.X, 0, offset.Z)
            if flat.Magnitude <= RaidConfig.AttackRadius and math.abs(offset.Y) < 12 then
                local direction = flat.Magnitude > 0.1 and flat.Unit or Vector3.new(1, 0, 0)
                SocialService.Ragdoll(character, direction)
            end
        end
    end
end

local function launchAttack()
    local center = arenaCenter()
    for _, point in pickAttackPoints(center) do
        local ground = Vector3.new(point.X, center.Y + 0.25, point.Z)
        local circle = part(warningFolder, "WarningCircle", Enum.PartType.Cylinder, Vector3.new(0.2, RaidConfig.AttackRadius * 2, RaidConfig.AttackRadius * 2), CFrame.new(ground) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 40, 40), Enum.Material.Neon, 0.45)
        circle.CanQuery = false
        local fill = part(warningFolder, "WarningFill", Enum.PartType.Cylinder, Vector3.new(0.25, 1, 1), CFrame.new(ground + Vector3.new(0, 0.02, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 200, 60), Enum.Material.Neon, 0.3)
        fill.CanQuery = false
        -- 안쪽 원이 바깥 원만큼 커지면 폭발(시간 표시)
        game:GetService("TweenService"):Create(fill, TweenInfo.new(RaidConfig.AttackWarningTime, Enum.EasingStyle.Linear), {
            Size = Vector3.new(0.25, RaidConfig.AttackRadius * 2, RaidConfig.AttackRadius * 2),
        }):Play()
        task.delay(RaidConfig.AttackWarningTime, function()
            circle:Destroy()
            fill:Destroy()
            if state.phase == "Active" then
                explodeAt(ground)
            end
        end)
    end
end

local function recordDamage(player, target, amount)
    if state.phase ~= "Active" or target ~= boss or type(amount) ~= "number" or amount ~= amount or amount <= 0 then
        return
    end
    state.damage[player] = (state.damage[player] or 0) + amount
end

local function step(deltaTime)
    local time = now()
    if state.phase == "Idle" and time >= state.warningAt then
        startWarning()
    elseif state.phase == "Warning" and time >= state.startsAt then
        startBattle()
    elseif state.phase == "Active" then
        if not bossHumanoid or bossHumanoid.Health <= 0 then
            finishBattle(true)
        elseif time >= state.endsAt then
            finishBattle(false)
        elseif time >= state.nextAttackAt then
            state.nextAttackAt = time + RaidConfig.AttackInterval
            launchAttack()
        end
    end
    broadcastElapsed += deltaTime
    if broadcastElapsed >= 0.5 then
        broadcastElapsed = 0
        broadcast()
    end
end

-- Studio 테스트용: 예고를 지금부터 바로 시작합니다(서버 전용, RemoteEvent에 노출하지 않음).
function Service.StartWarningNow(warningSeconds)
    if state.phase ~= "Idle" then
        return false
    end
    state.warningAt = now()
    startWarning()
    if warningSeconds then
        state.startsAt = now() + warningSeconds
    end
    return true
end

function Service.GetState()
    local snapshot = publicState()
    snapshot.damage = state.damage
    snapshot.boss = boss
    return snapshot
end

function Service.Start()
    if started then
        return
    end
    started = true
    -- Edit에서 보이는 보스 외형 사본은 실제 레이드 시작 전에 제거합니다.
    local arena = workspace.ProjectMS_Lanes:FindFirstChild("RaidArena")
    local editPreview = arena and arena:FindFirstChild("RaidBossPreview")
    if editPreview then
        editPreview:Destroy()
    end
    root = Instance.new("Folder")
    root.Name = "ProjectMS_Raid"
    root:SetAttribute("ProjectMSManaged", true)
    root.Parent = workspace
    warningFolder = Instance.new("Folder")
    warningFolder.Name = "Warnings"
    warningFolder.Parent = root
    state.warningAt = now() + RaidConfig.FirstDelay
    CombatService.AddDamageObserver(recordDamage)
    RunService.Heartbeat:Connect(step)
    Players.PlayerRemoving:Connect(function(player)
        state.damage[player] = nil
    end)
    Players.PlayerAdded:Connect(function(player)
        network.RaidEvent:FireClient(player, "state", publicState())
    end)
end

return Service
