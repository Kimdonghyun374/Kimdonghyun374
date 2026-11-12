-- Roblox 인스턴스에 의존하지 않는 기지 소유권/보관함 규칙. 모든 메서드는 yield하지 않습니다.
local Domain = {}
Domain.__index = Domain
local function isFiniteInteger(value)
    return type(value) == "number"
        and value == value
        and value % 1 == 0
        and math.abs(value) < math.huge
end

function Domain.new(config, catalog)
    local self = setmetatable(
        { config = config, catalog = catalog, definitions = {}, players = {}, owners = {} },
        Domain
    )
    assert(isFiniteInteger(config.RollCost) and config.RollCost > 0, "잘못된 제작 비용")
    assert(
        isFiniteInteger(config.StarterScrap) and config.StarterScrap >= 0,
        "잘못된 시작 부품"
    )
    assert(
        type(config.ProductionDuration) == "number"
            and config.ProductionDuration > 0
            and config.ProductionDuration < math.huge,
        "잘못된 제작 시간"
    )
    self.totalWeight = 0
    for _, definition in ipairs(catalog) do
        assert(
            type(definition.key) == "string"
                and not self.definitions[definition.key]
                and definition.weight > 0
        )
        self.definitions[definition.key] = definition
        self.totalWeight += definition.weight
    end
    assert(self.totalWeight > 0)
    return self
end

function Domain:Normalize(storedData)
    assert(
        type(storedData) == "table" and (storedData.Version == nil or storedData.Version == 1),
        "지원하지 않는 저장 데이터 버전"
    )
    assert(
        storedData.Inventory == nil or type(storedData.Inventory) == "table",
        "잘못된 보관함 데이터"
    )
    assert(
        storedData.Equipped == nil or type(storedData.Equipped) == "table",
        "잘못된 장착 데이터"
    )
    local normalizedData = {
        Version = 1,
        Progression = storedData.Progression,
        GallerySlots = storedData.GallerySlots == nil and 1 or storedData.GallerySlots,
        Inventory = {},
        Equipped = {},
        NextId = 1,
        TotalRolls = storedData.TotalRolls or 0,
        Scrap = storedData.Scrap == nil and 0 or storedData.Scrap,
        ResearchData = storedData.ResearchData == nil and 0 or storedData.ResearchData,
        StarterScrapGranted = storedData.StarterScrapGranted == true,
    }
    assert(
        isFiniteInteger(normalizedData.GallerySlots)
            and normalizedData.GallerySlots >= 1
            and normalizedData.GallerySlots <= self.config.GalleryCapacity,
        "잘못된 전시장 해금 데이터"
    )
    local limit = self.config.ResourceBalanceLimit or 1000000000000
    assert(
        isFiniteInteger(normalizedData.Scrap)
            and normalizedData.Scrap >= 0
            and normalizedData.Scrap <= limit,
        "Invalid Scrap balance"
    )
    assert(
        isFiniteInteger(normalizedData.ResearchData)
            and normalizedData.ResearchData >= 0
            and normalizedData.ResearchData <= limit,
        "Invalid ResearchData balance"
    )
    assert(
        isFiniteInteger(normalizedData.TotalRolls) and normalizedData.TotalRolls >= 0,
        "잘못된 누적 횟수"
    )
    local seenItemIds = {}
    for _, item in ipairs(storedData.Inventory or {}) do
        assert(
            type(item) == "table"
                and isFiniteInteger(item.id)
                and item.id > 0
                and self.definitions[item.key]
                and not seenItemIds[item.id],
            "잘못된 미사일 저장 데이터"
        )
        seenItemIds[item.id] = true
        table.insert(normalizedData.Inventory, { id = item.id, key = item.key })
        normalizedData.NextId = math.max(normalizedData.NextId, item.id + 1)
    end
    if storedData.NextId ~= nil then
        assert(
            isFiniteInteger(storedData.NextId) and storedData.NextId >= 1,
            "잘못된 미사일 번호"
        )
        normalizedData.NextId = math.max(normalizedData.NextId, storedData.NextId)
    end
    assert(
        storedData.StarterScrapGranted == nil or type(storedData.StarterScrapGranted) == "boolean",
        "잘못된 시작 부품 지급 기록"
    )
    if storedData.PendingRoll ~= nil then
        local pending = storedData.PendingRoll
        assert(
            type(pending) == "table"
                and isFiniteInteger(pending.id)
                and pending.id > 0
                and not seenItemIds[pending.id]
                and self.definitions[pending.key]
                and type(pending.startedAt) == "number"
                and pending.startedAt == pending.startedAt
                and pending.startedAt >= 0
                and pending.startedAt < math.huge
                and type(pending.readyAt) == "number"
                and pending.readyAt == pending.readyAt
                and pending.readyAt > pending.startedAt
                and pending.readyAt < math.huge,
            "잘못된 제작 대기 데이터"
        )
        normalizedData.PendingRoll = {
            id = pending.id,
            key = pending.key,
            startedAt = pending.startedAt,
            readyAt = pending.readyAt,
        }
        normalizedData.NextId = math.max(normalizedData.NextId, pending.id + 1)
    end
    local equipped = {}
    for _, id in ipairs(storedData.Equipped or {}) do
        assert(seenItemIds[id] and not equipped[id], "잘못된 장착 소유권")
        equipped[id] = true
        table.insert(normalizedData.Equipped, id)
    end
    return normalizedData
end

function Domain:Open(playerId, storedData)
    assert(not self.players[playerId], "이미 열린 플레이어 세션")
    local data = self:Normalize(storedData)
    self.players[playerId] = { data = data, nextRoll = 0 }
    return data
end

function Domain:Claim(playerId, plotId, nearby)
    local playerRecord = self.players[playerId]
    if not playerRecord then
        return false, "보관함을 불러오는 중입니다"
    end
    if
        not isFiniteInteger(plotId)
        or plotId < 1
        or plotId > self.config.PlotCount
        or not nearby
    then
        return false, "기지 입구 발판 가까이 이동하세요"
    end
    if playerRecord.plot then
        return false, "이미 내 기지가 있습니다"
    end
    if self.owners[plotId] then
        return false, "다른 플레이어의 기지입니다"
    end
    self.owners[plotId], playerRecord.plot = playerId, plotId
    return true
end

function Domain:Draw(unit)
    assert(type(unit) == "number" and unit == unit and unit >= 0 and unit <= 1, "잘못된 난수")
    local value = unit * self.totalWeight
    for _, definition in ipairs(self.catalog) do
        value -= definition.weight
        if value < 0 then
            return definition
        end
    end
    return self.catalog[#self.catalog]
end

-- 지급 여부를 프로필에 남겨 재접속으로 시작 부품을 반복 수령하지 못하게 합니다.
function Domain:GrantStarterScrap(playerId)
    local playerRecord = self.players[playerId]
    if not playerRecord or playerRecord.data.StarterScrapGranted then
        return false
    end
    local data = playerRecord.data
    data.StarterScrapGranted = true
    if #data.Inventory > 0 or data.TotalRolls > 0 or data.PendingRoll then
        return false
    end
    local limit = self.config.ResourceBalanceLimit or 1000000000000
    local amount = math.min(self.config.StarterScrap, math.max(0, limit - data.Scrap))
    data.Scrap += amount
    return amount > 0
end

-- 결제와 제작 예약은 yield 없이 함께 처리합니다. 보관함에는 아직 지급하지 않습니다.
function Domain:Roll(playerId, plotId, nearby, time, unit)
    local playerRecord = self.players[playerId]
    if not playerRecord then
        return false, "보관함을 불러오는 중입니다"
    end
    if not playerRecord.plot or playerRecord.plot ~= plotId or self.owners[plotId] ~= playerId then
        return false, "먼저 빈 기지를 차지하세요"
    end
    if not nearby then
        return false, "내 기지의 생산기 가까이 이동하세요"
    end
    if playerRecord.data.PendingRoll then
        return false, "이미 미사일을 제작하고 있습니다"
    end
    if time < playerRecord.nextRoll then
        return false, "잠시 기다린 뒤 다시 뽑아주세요"
    end
    if #playerRecord.data.Inventory >= self.config.InventoryCapacity then
        return false, "보관함이 가득 찼습니다"
    end
    if playerRecord.data.Scrap < self.config.RollCost then
        return false,
            string.format(
                "코인이 부족합니다. 제작에 %d개가 필요합니다",
                self.config.RollCost
            )
    end
    local definition = self:Draw(unit)
    local pending = {
        id = playerRecord.data.NextId,
        key = definition.key,
        startedAt = time,
        readyAt = time + self.config.ProductionDuration,
    }
    playerRecord.data.Scrap -= self.config.RollCost
    playerRecord.data.NextId += 1
    playerRecord.data.PendingRoll = pending
    playerRecord.nextRoll = pending.readyAt + self.config.RollCooldown
    return true, pending
end

-- 저장된 절대 시간을 사용하므로 재접속해도 제작 시간이 초기화되지 않습니다.
function Domain:CompleteRoll(playerId, time, equipLimit)
    local playerRecord = self.players[playerId]
    local pending = playerRecord and playerRecord.data.PendingRoll
    if not pending or time < pending.readyAt then
        return false
    end
    local item = { id = pending.id, key = pending.key }
    table.insert(playerRecord.data.Inventory, item)
    if #playerRecord.data.Equipped < equipLimit then
        table.insert(playerRecord.data.Equipped, item.id)
    end
    playerRecord.data.TotalRolls += 1
    playerRecord.data.PendingRoll = nil
    playerRecord.nextRoll = pending.readyAt + self.config.RollCooldown
    return true, item
end

function Domain:Equip(playerId, id, enabled, limit)
    local playerRecord = self.players[playerId]
    if not playerRecord then
        return false, "보관함을 불러오는 중입니다"
    end
    if not isFiniteInteger(id) or type(enabled) ~= "boolean" then
        return false, "잘못된 장착 요청"
    end
    local ownsItem = false
    for _, item in ipairs(playerRecord.data.Inventory) do
        if item.id == id then
            ownsItem = true
            break
        end
    end
    if not ownsItem then
        return false, "보유한 미사일만 장착할 수 있습니다"
    end
    local index = table.find(playerRecord.data.Equipped, id)
    if enabled and not index then
        if #playerRecord.data.Equipped >= limit then
            return false,
                "장착 슬롯이 가득 찼습니다. 기존 미사일을 해제하세요"
        end
        table.insert(playerRecord.data.Equipped, id)
    elseif not enabled and index then
        table.remove(playerRecord.data.Equipped, index)
    end
    return true
end

function Domain:Loadout(playerId, limit)
    local playerRecord = self.players[playerId]
    local loadout = {}
    if not playerRecord then
        return loadout
    end
    local itemsById = {}
    for _, item in ipairs(playerRecord.data.Inventory) do
        itemsById[item.id] = item
    end
    for _, id in ipairs(playerRecord.data.Equipped) do
        if #loadout >= limit then
            break
        end
        local item = itemsById[id]
        if item then
            local definition = self.definitions[item.key]
            table.insert(loadout, {
                id = id,
                key = item.key,
                name = definition.name,
                rarity = definition.rarity,
                multiplier = definition.multiplier,
                color = definition.color,
            })
        end
    end
    return loadout
end

function Domain:Credit(playerId, scrap, research)
    local playerRecord = self.players[playerId]
    if
        not playerRecord
        or not isFiniteInteger(scrap)
        or not isFiniteInteger(research)
        or scrap < 0
        or research < 0
        or scrap + research <= 0
    then
        return false
    end
    local limit = self.config.ResourceBalanceLimit or 1000000000000
    if
        playerRecord.data.Scrap + scrap > limit
        or playerRecord.data.ResearchData + research > limit
    then
        return false
    end
    playerRecord.data.Scrap += scrap
    playerRecord.data.ResearchData += research
    return true
end

-- 코인(Scrap) 차감. 잔액이 모자라면 아무것도 바꾸지 않고 false.
function Domain:Spend(playerId, scrap)
    local playerRecord = self.players[playerId]
    if not playerRecord or not isFiniteInteger(scrap) or scrap <= 0 then
        return false
    end
    if playerRecord.data.Scrap < scrap then
        return false
    end
    playerRecord.data.Scrap -= scrap
    return true
end

-- 소유권·거리·현재 해금 수·잔액 확인과 결제/해금을 yield 없이 처리합니다.
function Domain:UpgradeGallery(playerId, plotId, nearby, expectedSlots)
    local record = self.players[playerId]
    if not record or not record.plot or record.plot ~= plotId or self.owners[plotId] ~= playerId then
        return false, "내 기지에서만 확장할 수 있습니다"
    end
    if not nearby then
        return false, "왼쪽 첫 전시대 가까이 이동하세요"
    end
    local data = record.data
    if not isFiniteInteger(expectedSlots) or expectedSlots ~= data.GallerySlots then
        return false, "전시장 상태가 바뀌었습니다. 다시 시도하세요"
    end
    if data.GallerySlots >= self.config.GalleryCapacity then
        return false, "전시장을 모두 확장했습니다"
    end
    local cost = self.config.GalleryUpgradeCost
    assert(isFiniteInteger(cost) and cost > 0, "잘못된 전시장 확장 비용")
    if data.Scrap < cost then
        return false, string.format("코인이 부족합니다. 확장에 %d개가 필요합니다", cost)
    end
    data.Scrap -= cost
    data.GallerySlots += 1
    return true, data.GallerySlots
end

function Domain:Close(playerId)
    local playerRecord = self.players[playerId]
    if playerRecord and playerRecord.plot then
        self.owners[playerRecord.plot] = nil
    end
    self.players[playerId] = nil
end

return Domain
