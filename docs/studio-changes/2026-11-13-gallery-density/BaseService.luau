-- 유효한 프로필 세션을 가진 플레이어만 기지 요청과 재화 변경을 처리합니다.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local network = ReplicatedStorage:WaitForChild("PetMissiles")
local BaseConfig = require(network.BaseConfig)
local CombatConfig = require(network.Config)
local MissileCatalog = require(network.MissileCatalog)
local BaseDomain = require(script.Parent.BaseDomain)
local BaseWorld = require(script.Parent.BaseWorld)
local ProgressionRules = require(script.Parent.ProgressionRules)
local VehicleRules = require(script.Parent.VehicleRules)
local VehicleConfig = require(network.VehicleConfig)
local travelHandler
local CombatService = require(script.Parent.Service)
local Service = {}
local baseDomain = BaseDomain.new(BaseConfig, MissileCatalog)
local profiles, loading, lastRequests, travelReadyAt = {}, {}, {}, {}
local baseWorld, profileStore, profileStoreLibrary, isStarted, isShuttingDown
local random = Random.new()
local function levelLimit(player)
    local stats = player:FindFirstChild("leaderstats")
    local level = stats and stats:FindFirstChild(CombatConfig.LevelValueName)
    local value = level and (level:IsA("IntValue") or level:IsA("NumberValue")) and level.Value
        or player:GetAttribute(CombatConfig.LevelAttribute)
        or CombatConfig.DefaultLevel
    return CombatConfig.Count(value)
end

local function isWithinDistance(player, part, distance)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not part or not rootPart or not humanoid or humanoid.Health <= 0 then
        return false
    end
    local delta = rootPart.Position - part.Position
    return delta.Magnitude == delta.Magnitude and delta.Magnitude <= distance
end

local function hasActiveProfile(player)
    local profile = profiles[player]
    return profile and profile:IsActive() and baseDomain.players[player.UserId] ~= nil
end

function Service.GetLoadout(player, limit)
    if not hasActiveProfile(player) then
        return {}
    end
    return baseDomain:Loadout(player.UserId, limit)
end

-- 서버 진행 서비스만 이 프로필 데이터를 수정합니다. RemoteEvent에 직접 노출하지 않습니다.
function Service.GetProgression(player)
    local record = hasActiveProfile(player) and baseDomain.players[player.UserId]
    return record and record.data.Progression or nil
end

-- 진행 서비스가 개인 도시를 놓을 대로를 고를 때 씁니다. 기지가 없으면 0.
function Service.GetPlotId(player)
    local record = hasActiveProfile(player) and baseDomain.players[player.UserId]
    return record and record.plot or 0
end

function Service.GetState(player)
    local playerRecord = hasActiveProfile(player) and baseDomain.players[player.UserId]
    local items = {}
    if playerRecord then
        for _, item in ipairs(playerRecord.data.Inventory) do
            local definition = baseDomain.definitions[item.key]
            table.insert(items, {
                id = item.id,
                key = item.key,
                name = definition.name,
                rarity = definition.rarity,
                multiplier = definition.multiplier,
                color = definition.color,
                equipped = table.find(playerRecord.data.Equipped, item.id) ~= nil,
            })
        end
    end
    return {
        ready = playerRecord ~= nil,
        plot = playerRecord and playerRecord.plot or 0,
        inventory = items,
        capacity = BaseConfig.InventoryCapacity,
        gallerySlots = playerRecord and playerRecord.data.GallerySlots or 1,
        galleryCapacity = BaseConfig.GalleryCapacity,
        galleryUpgradeCost = BaseConfig.GalleryUpgradeCost,
        limit = levelLimit(player),
        nextRoll = playerRecord and playerRecord.nextRoll or 0,
        serverClock = workspace:GetServerTimeNow(),
        rollCost = BaseConfig.RollCost,
        productionDuration = BaseConfig.ProductionDuration,
        production = playerRecord and playerRecord.data.PendingRoll and {
            startedAt = playerRecord.data.PendingRoll.startedAt,
            readyAt = playerRecord.data.PendingRoll.readyAt,
        } or nil,
        totalRolls = playerRecord and playerRecord.data.TotalRolls or 0,
        testData = RunService:IsStudio() and BaseConfig.StudioMockData,
        canTestTravel = RunService:IsStudio() and BaseConfig.StudioTestTravel == true,
        scrap = playerRecord and playerRecord.data.Scrap or 0,
        researchData = playerRecord and playerRecord.data.ResearchData or 0,
        cooldown = BaseConfig.RollCooldown,
    }
end

local function sendState(player, message, result, open)
    if player.Parent == Players then
        network.BaseState:FireClient(player, Service.GetState(player), message, result, open)
    end
end
function Service.SetTravelHandler(handler)
    assert(type(handler) == "function")
    travelHandler = handler
end

function Service.PrepareTravel(player)
    if travelHandler then
        travelHandler(player, false)
    end
end

function Service.UpgradeBuggy(player, expectedLevel)
    if not hasActiveProfile(player) then
        return false, "보관함을 불러오는 중입니다"
    end
    local ok, result =
        VehicleRules.Upgrade(baseDomain.players[player.UserId].data, VehicleConfig, expectedLevel)
    if ok then
        sendState(player)
    end
    return ok, result
end

-- Server-only: never dispatch this method from a RemoteEvent.
function Service.GrantResources(player, scrap, research)
    if not hasActiveProfile(player) then
        return false
    end
    local ok = baseDomain:Credit(player.UserId, scrap, research)
    if ok then
        sendState(player)
    end
    return ok
end

-- Server-only: 구역 해금 등 서버가 조건을 확인한 뒤 코인을 차감합니다. RemoteEvent로 노출하지 않습니다.
function Service.SpendScrap(player, amount)
    if not hasActiveProfile(player) then
        return false
    end
    local ok = baseDomain:Spend(player.UserId, amount)
    if ok then
        sendState(player)
    end
    return ok
end

local function release(player)
    local playerRecord = baseDomain.players[player.UserId]
    local plot = playerRecord and playerRecord.plot
    baseDomain:Close(player.UserId)
    if plot and baseWorld then
        baseWorld:SetOwner(plot, nil)
    end
    player:SetAttribute("MissileBaseId", nil)
end

local function consumeRequestAllowance(player)
    local time = os.clock()
    if time - (lastRequests[player] or -math.huge) < BaseConfig.RequestInterval then
        return false
    end
    lastRequests[player] = time
    return true
end
-- 클라이언트가 보내는 좌표/기지 번호는 사용하지 않고 서버에서 목적지를 선택합니다.
function Service.TestTravel(player)
    if not RunService:IsStudio() or BaseConfig.StudioTestTravel ~= true then
        return
    end
    if not hasActiveProfile(player) or not baseWorld then
        return
    end
    local now = os.clock()
    if now < (travelReadyAt[player] or 0) then
        return
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not humanoid or humanoid.Health <= 0 then
        return
    end
    local playerRecord = baseDomain.players[player.UserId]
    local plot = playerRecord.plot and baseWorld.plots[playerRecord.plot]
    local owned = plot ~= nil
    if not plot then
        for id = 1, BaseConfig.PlotCount do
            if not baseDomain.owners[id] then
                plot = baseWorld.plots[id]
                break
            end
        end
    end
    if not plot then
        sendState(player, "이동할 빈 기지가 없습니다", nil, true)
        return
    end
    travelReadyAt[player] = now + 1
    local target = owned and plot.generator or plot.pad
    local height = humanoid.HipHeight + rootPart.Size.Y / 2 + 0.5
    local floor = plot.floor
    local point = target.CFrame:PointToWorldSpace(Vector3.new(0, 0, owned and 6 or 0))
    local position = Vector3.new(point.X, floor.Position.Y + floor.Size.Y / 2 + height, point.Z)
    local forward = Vector3.new(target.CFrame.LookVector.X, 0, target.CFrame.LookVector.Z)
    if forward.Magnitude < 0.001 then
        forward = Vector3.new(0, 0, -1)
    end
    Service.PrepareTravel(player)
    humanoid.Sit = false
    local destination = CFrame.lookAt(position, position + forward)
    character:PivotTo(destination * rootPart.CFrame:Inverse() * character:GetPivot())
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    sendState(player)
end

function Service.Claim(player, id)
    if not consumeRequestAllowance(player) then
        return
    end
    if not hasActiveProfile(player) then
        sendState(player, "보관함을 불러오는 중입니다")
        return
    end
    local plot = baseWorld.plots[id]
    local ok, message = baseDomain:Claim(
        player.UserId,
        id,
        plot and isWithinDistance(player, plot.pad, BaseConfig.ClaimDistance)
    )
    if ok then
        baseWorld:SetOwner(id, player, baseDomain.players[player.UserId].data.GallerySlots)
        player:SetAttribute("MissileBaseId", id)
        message = "기지를 차지했습니다! 생산기에서 E로 첫 미사일을 만드세요"
    end
    sendState(player, message)
end

function Service.UpgradeGallery(player, plotId)
    if not consumeRequestAllowance(player) or not hasActiveProfile(player) then
        return false
    end
    local record = baseDomain.players[player.UserId]
    local plot = baseWorld.plots[plotId]
    local ok, result = baseDomain:UpgradeGallery(
        player.UserId,
        plotId,
        plot and isWithinDistance(player, plot.display, BaseConfig.InteractionDistance),
        record.data.GallerySlots
    )
    if ok then
        baseWorld:SetGallery(plotId, result)
        sendState(player, string.format("전시장이 %d칸으로 확장되었습니다", result))
    else
        sendState(player, result)
    end
    return ok
end

function Service.Roll(player)
    if not consumeRequestAllowance(player) then
        return
    end
    if not hasActiveProfile(player) then
        sendState(player, "보관함을 불러오는 중입니다")
        return
    end
    local playerRecord = baseDomain.players[player.UserId]
    local plot = playerRecord and playerRecord.plot and baseWorld.plots[playerRecord.plot]
    local ok, result = baseDomain:Roll(
        player.UserId,
        playerRecord and playerRecord.plot,
        plot and isWithinDistance(player, plot.generator, BaseConfig.InteractionDistance),
        workspace:GetServerTimeNow(),
        random:NextNumber()
    )
    if ok then
        baseWorld:SetProduction(playerRecord.plot, result)
        sendState(
            player,
            string.format(
                "코인 %d개를 사용했습니다. 제작을 시작합니다",
                BaseConfig.RollCost
            )
        )
    else
        sendState(player, result)
    end
end

local function updateProduction(player)
    if not hasActiveProfile(player) then
        return
    end
    local playerRecord = baseDomain.players[player.UserId]
    local completed, item =
        baseDomain:CompleteRoll(player.UserId, workspace:GetServerTimeNow(), levelLimit(player))
    if playerRecord.plot then
        baseWorld:SetProduction(playerRecord.plot, playerRecord.data.PendingRoll)
    end
    if not completed then
        return
    end
    local definition = baseDomain.definitions[item.key]
    if playerRecord.plot then
        baseWorld:Preview(playerRecord.plot, definition)
    end
    sendState(player, "미사일 제작이 완료되었습니다", {
        id = item.id,
        name = definition.name,
        rarity = definition.rarity,
        color = definition.color,
        multiplier = definition.multiplier,
    })
end

local function findProfileModule()
    local server = ServerScriptService:FindFirstChild("Server")
    local packages = server and server:FindFirstChild("Packages")
    local profileStoreModule = packages and packages:FindFirstChild("ProfileStore")
        or ServerScriptService:FindFirstChild("ProfileStore")
    assert(
        profileStoreModule and profileStoreModule:IsA("ModuleScript"),
        "기지 저장용 ProfileStore를 찾지 못했습니다"
    )
    return profileStoreModule
end

local function loadPlayer(player)
    if loading[player] or profiles[player] then
        return
    end
    loading[player] = true
    local began = os.clock()
    local ok, profile = pcall(function()
        return profileStore:StartSessionAsync("Player_" .. player.UserId, {
            Cancel = function()
                return isShuttingDown
                    or player.Parent ~= Players
                    or os.clock() - began > BaseConfig.ProfileLoadTimeout
            end,
        })
    end)
    loading[player] = nil
    if not ok or not profile then
        if player.Parent == Players then
            player:Kick(
                "미사일 보관함을 불러오지 못했습니다. 다시 접속해 주세요"
            )
        end
        return
    end
    if player.Parent ~= Players or isShuttingDown then
        profile:EndSession()
        return
    end
    if
        not (RunService:IsStudio() and BaseConfig.StudioMockData)
        and profileStoreLibrary.DataStoreState ~= "Access"
    then
        profile:EndSession()
        player:Kick(
            "저장 서버에 연결하지 못했습니다. 잠시 후 다시 접속해 주세요"
        )
        return
    end
    if player.UserId > 0 then
        profile:AddUserId(player.UserId)
    end
    profile:Reconcile()
    local valid, data = pcall(function()
        local normalized = baseDomain:Open(player.UserId, profile.Data)
        normalized.Progression = ProgressionRules.Normalize(normalized.Progression)
        return normalized
    end)
    if not valid then
        profile:EndSession()
        player:Kick(
            "보관함 데이터 확인이 필요합니다. 잠시 후 다시 접속해 주세요"
        )
        warn("ProjectMS: 저장 데이터 검증 실패")
        return
    end
    profile.Data = data
    profiles[player] = profile
    local receivedStarterScrap = baseDomain:GrantStarterScrap(player.UserId)
    profile.OnSessionEnd:Connect(function()
        if profiles[player] ~= profile then
            return
        end
        profiles[player] = nil
        release(player)
        if player.Parent == Players and not isShuttingDown then
            player:Kick("보관함 연결이 종료됐습니다. 다시 접속해 주세요")
        end
    end)
    local message = receivedStarterScrap
            and string.format(
                "첫 제작용 코인 %d개를 받았습니다. 빈 기지에서 E로 차지하세요",
                BaseConfig.StarterScrap
            )
        or "빈 기지 입구에서 E로 내 기지를 차지하세요"
    sendState(player, message)
    updateProduction(player)
end

local function connectPlotInteractions(id, plot)
    -- 기지 차지는 E 프롬프트로만 합니다(2026-11-10, 발판 밟기 제거).
    plot.claimPrompt.Triggered:Connect(function(player)
        Service.Claim(player, id)
    end)
    plot.rollPrompt.Triggered:Connect(function(player)
        local playerRecord = baseDomain.players[player.UserId]
        if playerRecord and playerRecord.plot == id then
            Service.Roll(player)
        end
    end)
    plot.galleryPrompt.Triggered:Connect(function(player)
        Service.UpgradeGallery(player, id)
    end)
    -- 보관함 시설 프롬프트는 2026-11-10 제거. 미사일 목록은 화면 오른쪽 버튼(B)으로 엽니다.
end

local function handleBaseRequest(player, request)
    if type(request) ~= "table" then
        return
    end
    if request.action == "roll" then
        Service.Roll(player)
    elseif request.action == "testTravel" then
        Service.TestTravel(player)
    elseif request.action == "equip" then
        if not consumeRequestAllowance(player) or not hasActiveProfile(player) then
            return
        end
        local _, message =
            baseDomain:Equip(player.UserId, request.id, request.enabled, levelLimit(player))
        sendState(player, message)
    elseif request.action == "sync" and consumeRequestAllowance(player) then
        sendState(player)
    end
end

function Service.Start()
    if isStarted then
        return
    end
    isStarted = true
    CombatService.SetLoadoutProvider(Service.GetLoadout)
    local ProfileStore = require(findProfileModule())
    profileStoreLibrary = ProfileStore
    profileStore = ProfileStore.New(BaseConfig.StoreName, {
        Version = 1,
        Inventory = {},
        Equipped = {},
        NextId = 1,
        TotalRolls = 0,
        Scrap = 0,
        ResearchData = 0,
        StarterScrapGranted = false,
        GallerySlots = 1,
    })
    if RunService:IsStudio() and BaseConfig.StudioMockData then
        profileStore = profileStore.Mock
    end
    baseWorld = BaseWorld.new(BaseConfig)
    for id, plot in pairs(baseWorld.plots) do
        connectPlotInteractions(id, plot)
    end
    local productionElapsed = 0
    RunService.Heartbeat:Connect(function(deltaTime)
        productionElapsed += deltaTime
        if productionElapsed < 0.1 then
            return
        end
        productionElapsed = 0
        for player in pairs(profiles) do
            updateProduction(player)
        end
    end)
    network.BaseRequest.OnServerEvent:Connect(handleBaseRequest)
    Players.PlayerAdded:Connect(loadPlayer)
    Players.PlayerRemoving:Connect(function(player)
        local profile = profiles[player]
        profiles[player] = nil
        release(player)
        lastRequests[player] = nil
        travelReadyAt[player] = nil
        if profile then
            profile:EndSession()
        end
    end)
    game:BindToClose(function()
        isShuttingDown = true
        for player, profile in pairs(profiles) do
            profiles[player] = nil
            release(player)
            profile:EndSession()
        end
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(loadPlayer, player)
    end
end

return Service
