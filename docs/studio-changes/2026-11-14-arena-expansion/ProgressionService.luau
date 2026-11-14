-- 낮/밤은 공유하고 건물 인스턴스와 완파 기록은 플레이어마다 분리합니다.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local network = game.ReplicatedStorage:WaitForChild("PetMissiles")
local Config = require(network.WorldConfig)
local VehicleConfig = require(network.VehicleConfig)
local SalvageConfig = require(network.SalvageConfig)
local CombatConfig = require(network.Config)
local Rules = require(script.Parent.ProgressionRules)
local BaseService = require(script.Parent.BaseService)
local CombatService = require(script.Parent.Service)
local SalvageService = require(script.Parent.SalvageService)
local Service = {}
local sessions, sources, definitions, buildingIds, lastRequests = {}, {}, {}, {}, {}
local zoneBuildingIds = {}
local root, cycle, testTime
local started, elapsed, broadcastElapsed = false, 0, 0
local function clock()
    return testTime or workspace:GetServerTimeNow()
end
local function dataFor(player)
    return BaseService.GetProgression(player)
end
local function clearBuildings(session)
    for _, model in session.folder:GetChildren() do
        SalvageService.ForgetBuilding(model)
        model:Destroy()
    end
end
-- 기지 번호와 같은 번호의 진격 대로 입구입니다. 기지가 없거나 대로가 없으면 nil.
local function laneEntry(plotId)
    local lanes = workspace:FindFirstChild(Config.LaneFolder)
    local lane = lanes and plotId ~= 0 and lanes:FindFirstChild("Lane_" .. plotId)
    return lane and lane:FindFirstChild("Entry") or nil
end
-- 월드1 템플릿(기준 대로에 배치)을 내 대로로 옮기는 변환입니다.
local function laneTransform(session)
    if session.worldId ~= 1 then
        return nil
    end
    local ownEntry = laneEntry(session.plotId)
    local templateEntry = laneEntry(Config.TemplateLane)
    if not ownEntry or not templateEntry then
        return nil
    end
    return ownEntry.CFrame * templateEntry.CFrame:Inverse()
end
local function spawnBuildings(player, ignoreProgress, appendOnly)
    local session = sessions[player]
    if not session then
        return
    end
    if not appendOnly then
        clearBuildings(session)
    end
    local transform = laneTransform(session)
    if session.worldId == 1 and not transform then
        -- 기지를 차지해야 내 진격 대로에 도시가 생깁니다.
        return
    end
    local data = dataFor(player)
    local destroyed = not ignoreProgress and data and data.Destroyed[tostring(session.worldId)]
        or {}
    for _, source in sources[session.worldId]:GetChildren() do
        if not source:IsA("Model") then
            continue
        end
        local id = source:GetAttribute("BuildingId") or source.Name
        local zoneId = source:GetAttribute("ZoneId") or 1
        if session.worldId == 1 and zoneId > 1 and (not data or not Rules.IsZoneUnlocked(data, 1, zoneId)) then
            continue
        end
        if appendOnly and session.folder:FindFirstChild(source.Name) then
            continue
        end
        if destroyed[id] then
            continue
        end
        local model = source:Clone()
        model:SetAttribute("WorldTemplate", nil)
        model:SetAttribute("PersonalBuilding", true)
        model:SetAttribute("CycleId", cycle.id)
        model:SetAttribute("OwnerUserId", player.UserId)
        model:SetAttribute("WorldId", session.worldId)
        model:SetAttribute("BuildingId", id)
        local health = source:GetAttribute("BuildingHealth") or SalvageConfig.DefaultHealth
        model:SetAttribute(
            "BuildingHealth",
            math.max(1, math.ceil(health * definitions[session.worldId].healthMultiplier))
        )
        if transform then
            model:PivotTo(transform * source:GetPivot())
        end
        model.Parent = session.folder
        SalvageService.WatchBuilding(model)
    end
end
function Service.GetState(player)
    local data = dataFor(player)
    local session = sessions[player]
    local worldId = session and session.worldId or 1
    local worlds = {}
    for _, definition in ipairs(Config.Worlds) do
        table.insert(worlds, {
            id = definition.id,
            name = definition.name,
            requiredWins = definition.requiredWins,
            unlocked = data and Rules.CanEnter(data, definition) or false,
        })
    end
    local zoneId = 1
    local character = player.Character
    local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
    if worldId == 1 and playerRoot then
        local distance = Vector3.new(playerRoot.Position.X, 0, playerRoot.Position.Z).Magnitude
        zoneId = distance >= 800 and 3 or distance >= 560 and 2 or 1
    end
    local activeIds = worldId == 1 and zoneBuildingIds[zoneId] or buildingIds[worldId]
    return {
        zoneId = zoneId,
        zoneClears = data and data.ZoneClears or {},
        worldCompleted = data and (data.FullWorldClears[tostring(worldId)] or 0) > 0 or false,
        ready = data ~= nil and session ~= nil,
        phase = cycle.phase,
        cycleId = cycle.id,
        phaseEndsAt = cycle.endsAt,
        serverClock = clock(),
        wins = data and data.Wins or 0,
        worldId = worldId,
        worldName = definitions[worldId].name .. (worldId == 1 and (" · 구역" .. zoneId) or ""),
        destroyed = data and Rules.Count(data, worldId, activeIds) or 0,
        total = #activeIds,
        cleared = data and (worldId == 1 and data.Awarded[tostring(worldId) .. ":zone:" .. zoneId] == true or worldId ~= 1 and data.Awarded[tostring(worldId)] == true) or false,
        worlds = worlds,
    }
end
local function sendState(player, message)
    if player.Parent == Players then
        network.ProgressionState:FireClient(player, Service.GetState(player), message)
    end
end
local function teleportToWorld(player, worldId)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local point = workspace[Config.WorldFolder]:FindFirstChild("World_" .. worldId)
    point = point and point:FindFirstChild("Entry")
    -- 월드1로 돌아올 때는 광장 대신 내 대로 입구로 보냅니다.
    local session = sessions[player]
    local ownEntry = worldId == 1 and session and laneEntry(session.plotId)
    point = ownEntry or point
    if not point or not humanoid or humanoid.Health <= 0 then
        return false
    end
    BaseService.PrepareTravel(player)
    humanoid.Sit = false
    character:PivotTo(point.CFrame + Vector3.new(0, 4, 0))
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end
    return true
end
-- 밤에는 도시(대로·월드2 섬)에 있을 수 없습니다(2026-11-10). 광장 중심에서 이 거리 밖이 도시 구역입니다.
-- 기지 바닥 끝은 약 225, 대로 입구(Entry)는 240.
local NIGHT_SAFE_RADIUS = 306

-- 내 기지 생산기 앞(기지가 없으면 스폰 지점)으로 돌려보냅니다.
local function sendHome(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    local plotId = BaseService.GetState(player).plot
    local bases = workspace:FindFirstChild("ProjectMS_Bases")
    local base = bases and bases:FindFirstChild("Base_" .. plotId)
    local point = base and base:FindFirstChild("Generator")
        or workspace:FindFirstChildOfClass("SpawnLocation")
    if not point then
        return false
    end
    BaseService.PrepareTravel(player)
    humanoid.Sit = false
    character:PivotTo(point.CFrame * CFrame.new(0, 4, 6))
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.zero
    end
    return true
end

local function isInCityArea(player)
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end
    local flat = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
    return flat.Magnitude > NIGHT_SAFE_RADIUS
end

-- 구역 해금 (2026-11-10)
-- 각 대로(Lane_N)의 Gate_Zone2/3 벽은 그 대로 주인(Base_N 소유자)이 해금하면 열립니다.
-- 벽을 돌아서 가는 것도 막기 위해 잠긴 구역 경계를 넘으면 벽 앞으로 되돌립니다.
local ZONE_WORLD_ID = 1
local GATE_PROMPT_DISTANCE = 18
local ZONE_PUSHBACK = 10
local gates = {}
local gateElapsed = 0

local function zoneById(zoneId)
    for _, zone in Config.Zones or {} do
        if zone.id == zoneId then
            return zone
        end
    end
    return nil
end

local function playerByUserId(userId)
    return userId and userId ~= 0 and Players:GetPlayerByUserId(userId) or nil
end

-- 벽 하나의 열림/잠김 모양과 안내 글자를 주인 상태에 맞춥니다.
local function refreshGate(gate)
    local lanePlot = workspace:FindFirstChild("ProjectMS_Bases")
        and workspace.ProjectMS_Bases:FindFirstChild("Base_" .. gate.laneId)
    local owner = lanePlot and playerByUserId(lanePlot:GetAttribute("OwnerUserId"))
    local data = owner and dataFor(owner)
    local isOpen = data ~= nil and Rules.IsZoneUnlocked(data, ZONE_WORLD_ID, gate.zone.id)
    if gate.isOpen == isOpen and gate.ownerId == (owner and owner.UserId) then
        return
    end
    gate.isOpen = isOpen
    gate.ownerId = owner and owner.UserId
    gate.wall.CanCollide = not isOpen
    gate.wall.CanQuery = not isOpen
    gate.wall.Transparency = isOpen and 1 or gate.closedTransparency
    gate.prompt.Enabled = not isOpen and owner ~= nil
    if gate.sign then
        gate.sign.Enabled = not isOpen
    end
    local requirement = gate.zone.requiresWorldClear and "1구역 완파"
        or gate.zone.requiresZoneClear and ("구역" .. gate.zone.requiresZoneClear .. " 완파")
        or ("구역" .. tostring(gate.zone.requiresZone) .. " 해금")
    gate.prompt.ObjectText = string.format("코인 %d · %s 필요", gate.zone.cost, requirement)
end

function Service.UnlockZone(player, laneId, zoneId)
    local zone = zoneById(zoneId)
    local data = dataFor(player)
    if not zone or not data then
        return false
    end
    if BaseService.GetPlotId(player) ~= laneId then
        sendState(player, "내 기지의 대로에서만 해금할 수 있습니다")
        return false
    end
    local ok, reason = Rules.CanUnlockZone(data, ZONE_WORLD_ID, zone)
    if not ok then
        sendState(player, reason)
        return false
    end
    -- 코인 차감과 해금 기록은 한 프로필에서 yield 없이 이어서 처리합니다.
    if not BaseService.SpendScrap(player, zone.cost) then
        sendState(player, string.format("코인이 부족합니다 (%d개 필요)", zone.cost))
        return false
    end
    Rules.UnlockZone(data, ZONE_WORLD_ID, zone.id)
    spawnBuildings(player, false, true)
    for _, gate in gates do
        refreshGate(gate)
    end
    sendState(player, zone.name .. " 해금 완료!")
    return true
end

-- 잠긴 구역 경계를 넘었으면 그 벽 앞(광장 쪽)으로 되돌립니다.
local function enforceZones(player)
    local data = dataFor(player)
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not data or not rootPart then
        return
    end
    -- 방문자는 그 대로 주인의 열린 구역까지 이동할 수 있습니다.
    for _, base in ipairs(workspace.ProjectMS_Bases:GetChildren()) do
        local point = base.Floor.CFrame:PointToObjectSpace(rootPart.Position)
        if math.abs(point.X) < 75 and point.Z > base.Floor.Size.Z / 2 and point.Z < 1120 then
            local owner = Players:GetPlayerByUserId(base:GetAttribute("OwnerUserId") or 0)
            data = owner and dataFor(owner) or data
            break
        end
    end
    local flat = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
    local distance = flat.Magnitude
    if distance > (Config.ZoneEnforceMaxDistance or math.huge) or distance < 1 then
        return
    end
    for _, zone in Config.Zones or {} do
        if distance > zone.boundary and not Rules.IsZoneUnlocked(data, ZONE_WORLD_ID, zone.id) then
            local direction = flat.Unit
            local back = direction * (zone.boundary - ZONE_PUSHBACK)
            BaseService.PrepareTravel(player)
            character:PivotTo(CFrame.new(back.X, rootPart.Position.Y + 2, back.Z))
            rootPart.AssemblyLinearVelocity = Vector3.zero
            sendState(player, zone.name .. ": 아직 잠겨 있습니다. 벽에서 E로 해금하세요")
            return
        end
    end
end

local function connectGates()
    local lanes = workspace:FindFirstChild(Config.LaneFolder)
    for _, lane in lanes and lanes:GetChildren() or {} do
        for _, wall in lane:GetChildren() do
            local zone = wall:IsA("BasePart") and zoneById(wall:GetAttribute("ZoneId"))
            local prompt = zone and wall:FindFirstChild("Unlock", true)
            if prompt then
                local gate = {
                    wall = wall,
                    prompt = prompt,
                    sign = wall:FindFirstChild("GateSign"),
                    zone = zone,
                    laneId = wall:GetAttribute("LaneId"),
                    closedTransparency = wall.Transparency,
                }
                table.insert(gates, gate)
                prompt.Triggered:Connect(function(player)
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local promptPoint = prompt.Parent:IsA("Attachment") and prompt.Parent.WorldPosition
                        or wall.Position
                    if rootPart and (rootPart.Position - promptPoint).Magnitude <= GATE_PROMPT_DISTANCE then
                        Service.UnlockZone(player, gate.laneId, zone.id)
                    end
                end)
                refreshGate(gate)
            end
        end
    end
end

function Service.EnterWorld(player, worldId)
    if type(worldId) ~= "number" or worldId ~= worldId or worldId % 1 ~= 0 then
        return false
    end
    if cycle.phase == "Night" then
        sendState(player, "밤에는 도시에 갈 수 없습니다. 낮이 되면 출격하세요")
        return false
    end
    local data, session = dataFor(player), sessions[player]
    local definition = definitions[worldId]
    if not data or not session or not definition or not Rules.CanEnter(data, definition) then
        sendState(player, "이전 월드를 먼저 완파하세요")
        return false
    end
    if not teleportToWorld(player, worldId) then
        return false
    end
    if session.worldId ~= worldId then
        session.worldId = worldId
        player:SetAttribute("CurrentWorldId", worldId)
        spawnBuildings(player, cycle.phase == "Night")
    end
    sendState(player, definition.name .. "에 진입했습니다")
    return true
end
local function onDestroyed(model)
    local owner = Players:GetPlayerByUserId(model:GetAttribute("OwnerUserId") or 0)
    local session = owner and sessions[owner]
    local data = owner and dataFor(owner)
    local worldId = model:GetAttribute("WorldId")
    -- 오래된 도시/밤의 파괴 이벤트로 Win을 얻지 못하도록 현재 주기와 소유자를 확인합니다.
    local current = Rules.Cycle(clock(), Config)
    if
        not data
        or not session
        or session.worldId ~= worldId
        or current.phase ~= "Day"
        or model:GetAttribute("CycleId") ~= current.id
    then
        return
    end
    local zoneId = model:GetAttribute("ZoneId") or 1
    local awarded
    if worldId == 1 then
        awarded = Rules.RecordZoneDestroyed(
            data, worldId, zoneId, model:GetAttribute("BuildingId"),
            zoneBuildingIds[zoneId], current.id
        )
    else
        awarded = Rules.RecordDestroyed(
            data, worldId, model:GetAttribute("BuildingId"), buildingIds[worldId], current.id
        )
    end
    if awarded and worldId == 1 then
        local research = Config.ZoneClearResearch[zoneId] or 0
        BaseService.GrantResources(owner, 0, research)
        if zoneId == 1 then
            owner:SetAttribute("TechLabConstructionHint", true)
        end
        sendState(owner, "구역" .. zoneId .. " 완파! 연구자료 +" .. research
            .. (zoneId == 1 and " · 기지 기술 개발실 건설 위치를 확인하세요" or zoneId == 3 and " · 1월드 3구역 공략 완료!" or " · 다음 구역 벽에서 E로 해금"))
    else
        sendState(owner, awarded and "도시 완파!" or nil)
    end
end
local function addPlayer(player)
    if sessions[player] or not dataFor(player) then
        return
    end
    local data = dataFor(player)
    Rules.ApplyCycle(data, cycle.id)
    local folder = Instance.new("Folder")
    folder.Name = "Player_" .. player.UserId
    folder:SetAttribute("OwnerUserId", player.UserId)
    folder.Parent = root
    sessions[player] = { folder = folder, worldId = 1, plotId = BaseService.GetPlotId(player) }
    player:SetAttribute("CurrentWorldId", 1)
    spawnBuildings(player, cycle.phase == "Night")
    player.CharacterAdded:Connect(function()
        task.delay(0.25, function()
            local session = sessions[player]
            if session and session.worldId ~= 1 then
                teleportToWorld(player, session.worldId)
            end
        end)
    end)
    sendState(player)
end
local function targetAllowed(player, target)
    if target:GetAttribute("WorldTemplate") then
        return false
    end
    if not target:GetAttribute("PersonalBuilding") then
        return true
    end
    local session = sessions[player]
    local current = Rules.Cycle(clock(), Config)
    return current.phase == "Day"
        and target:GetAttribute("CycleId") == current.id
        and session ~= nil
        and target:GetAttribute("OwnerUserId") == player.UserId
        and target:GetAttribute("WorldId") == session.worldId
        and ((target:GetAttribute("ZoneId") or 1) == 1 or Rules.IsZoneUnlocked(dataFor(player), session.worldId, target:GetAttribute("ZoneId")))
end
local function ignoredCities(player)
    local ignored = {}
    local vehicles = workspace:FindFirstChild(VehicleConfig.FolderName)
    if vehicles then
        table.insert(ignored, vehicles)
    end
    for _, folder in root:GetChildren() do
        if folder:GetAttribute("OwnerUserId") ~= player.UserId then
            table.insert(ignored, folder)
        end
    end
    return ignored
end

function Service.Step(deltaTime)
    elapsed += deltaTime
    broadcastElapsed += deltaTime
    if elapsed < 0.1 then
        return
    end
    elapsed = 0
    local nextCycle = Rules.Cycle(clock(), Config)
    local changed = nextCycle.id ~= cycle.id or nextCycle.phase ~= cycle.phase
    cycle = nextCycle
    root:SetAttribute("Phase", cycle.phase)
    for _, player in ipairs(Players:GetPlayers()) do
        addPlayer(player)
        -- 기지를 새로 차지하거나 잃으면 도시를 그 대로로 다시 놓습니다.
        local session = sessions[player]
        local plotId = BaseService.GetPlotId(player)
        if session and session.plotId ~= plotId then
            session.plotId = plotId
            spawnBuildings(player, cycle.phase == "Night")
        end
        local data = dataFor(player)
        if changed and data and sessions[player] then
            Rules.ApplyCycle(data, cycle.id)
            spawnBuildings(player, cycle.phase == "Night")
        end
        enforceZones(player)
        -- 밤에 도시 구역에 있으면(걸어서 들어간 경우 포함) 기지로 돌려보냅니다.
        if cycle.phase == "Night" and isInCityArea(player) and sendHome(player) then
            sendState(player, "밤에는 도시에 있을 수 없어 기지로 돌아왔습니다")
        elseif changed or broadcastElapsed >= 1 then
            sendState(player)
        end
    end
    if broadcastElapsed >= 1 then
        broadcastElapsed = 0
    end
    -- 기지 주인이 바뀌거나 나갈 때도 벽 상태를 맞춥니다.
    gateElapsed += 0.1
    if gateElapsed >= 0.5 then
        gateElapsed = 0
        for _, gate in gates do
            refreshGate(gate)
        end
    end
end
function Service.SetStudioTime(time)
    assert(RunService:IsStudio(), "Studio 검증 전용")
    assert(
        time == nil or type(time) == "number" and time == time and time >= 0 and time < math.huge
    )
    testTime = time
    Service.Step(0.1)
end
function Service.Start()
    if started then
        return
    end
    started = true
    BaseService.Start()
    SalvageService.Start()
    cycle = Rules.Cycle(clock(), Config)
    root = Instance.new("Folder")
    root.Name = Config.PersonalCityFolder
    assert(not workspace:FindFirstChild(root.Name), "개인 도시 폴더 충돌")
    root:SetAttribute("ProjectMSManaged", true)
    root:SetAttribute("Phase", cycle.phase)
    root.Parent = workspace
    local templateRoot = Instance.new("Folder")
    templateRoot.Name = "ProjectMS_RuntimeWorldTemplates"
    assert(not ServerStorage:FindFirstChild(templateRoot.Name), "월드 템플릿 폴더 충돌")
    templateRoot.Parent = ServerStorage
    for _, definition in ipairs(Config.Worlds) do
        definitions[definition.id] = definition
        local source = definition.id == 1 and workspace:FindFirstChild(SalvageConfig.CityFolder)
            or workspace[Config.WorldFolder]["World_" .. definition.id]:FindFirstChild("Buildings")
        assert(source, "월드 건물 배치를 확인하세요")
        buildingIds[definition.id] = {}
        local seen = {}
        for _, model in source:GetChildren() do
            if model:IsA("Model") then
                local id = model:GetAttribute("BuildingId") or model.Name
                assert(not seen[id], "중복 BuildingId: " .. id)
                seen[id] = true
                table.insert(buildingIds[definition.id], id)
                if definition.id == 1 then
                    local zone = model:GetAttribute("ZoneId") or 1
                    zoneBuildingIds[zone] = zoneBuildingIds[zone] or {}
                    table.insert(zoneBuildingIds[zone], id)
                end
            end
        end
        assert(#buildingIds[definition.id] > 0, "월드에 건물이 필요합니다")
        source.Name = "World_" .. definition.id
        source.Parent = templateRoot
        sources[definition.id] = source
    end
    CombatService.SetTargetPolicy(targetAllowed, ignoredCities)
    SalvageService.SetDestroyedObserver(onDestroyed)
    for _, definition in ipairs(Config.Worlds) do
        local entry = workspace[Config.WorldFolder]["World_" .. definition.id].Entry
        local prompt = entry:FindFirstChild("EnterWorld")
        if prompt then
            prompt.Triggered:Connect(function(player)
                local rootPart = player.Character
                    and player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and (rootPart.Position - entry.Position).Magnitude <= 14 then
                    Service.EnterWorld(player, definition.id)
                end
            end)
        end
    end
    connectGates()
    network.ProgressionRequest.OnServerEvent:Connect(function(player, request)
        if type(request) ~= "table" then
            return
        end
        local now = os.clock()
        if now - (lastRequests[player] or -math.huge) < Config.RequestInterval then
            return
        end
        lastRequests[player] = now
        if request.action == "enter" and type(request.worldId) == "number" then
            Service.EnterWorld(player, request.worldId)
        elseif request.action == "home" then
            sendHome(player)
        elseif request.action == "sync" then
            sendState(player)
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        local session = sessions[player]
        if session then
            clearBuildings(session)
            session.folder:Destroy()
        end
        sessions[player] = nil
        lastRequests[player] = nil
    end)
    RunService.Heartbeat:Connect(Service.Step)
    for _, player in ipairs(Players:GetPlayers()) do
        addPlayer(player)
    end
end
return Service
