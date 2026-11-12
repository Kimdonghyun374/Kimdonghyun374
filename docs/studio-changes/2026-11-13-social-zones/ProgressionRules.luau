-- 저장/완파 규칙. Roblox 서비스와 분리해 중복 보상과 해금 조건을 검증합니다.
local Rules = {}
local function integer(value, minimum)
    return type(value) == "number"
        and value == value
        and value % 1 == 0
        and value >= minimum
        and value <= 1000000000000
end
local function copyCounts(raw, booleanValues)
    assert(raw == nil or type(raw) == "table", "잘못된 월드 기록")
    local result = {}
    local count = 0
    for key, value in pairs(raw or {}) do
        count += 1
        assert(
            count <= 10000
                and type(key) == "string"
                and #key <= 128
                and (booleanValues and value == true or not booleanValues and integer(value, 0)),
            "잘못된 월드 기록 항목"
        )
        result[key] = value
    end
    return result
end
function Rules.Normalize(raw)
    assert(raw == nil or type(raw) == "table", "잘못된 진행 데이터")
    raw = raw or {}
    local wins = raw.Wins == nil and 0 or raw.Wins
    local cycle = raw.CycleId == nil and -1 or raw.CycleId
    assert(integer(wins, 0) and integer(cycle, -1), "잘못된 Win 또는 주기")
    local buggyLevel = raw.BuggyLevel == nil and 0 or raw.BuggyLevel
    assert(integer(buggyLevel, 0) and buggyLevel <= 1000, "잘못된 버기 소유 등급")
    local result = {
        BuggyLevel = buggyLevel,
        Wins = wins,
        WorldClears = copyCounts(raw.WorldClears),
        ZoneClears = copyCounts(raw.ZoneClears),
        FullWorldClears = copyCounts(raw.FullWorldClears),
        LegacyWorldAccess = copyCounts(raw.LegacyWorldAccess, true),
        CycleId = cycle,
        Destroyed = {},
        Awarded = copyCounts(raw.Awarded, true),
        -- 해금한 구역. 키는 "월드-구역"(예: "1-2"). 낮·밤 주기가 바뀌어도 유지됩니다.
        UnlockedZones = copyCounts(raw.UnlockedZones, true),
    }
    assert(raw.Destroyed == nil or type(raw.Destroyed) == "table", "잘못된 파괴 기록")
    local count = 0
    for key, destroyed in pairs(raw.Destroyed or {}) do
        count += 1
        assert(count <= 1000 and type(key) == "string" and #key <= 128, "잘못된 월드 ID")
        result.Destroyed[key] = copyCounts(destroyed, true)
    end
    -- 옛 월드2 접근 권한은 보존하며, 새 프로필은 3구역 완료를 따릅니다.
    if raw.FullWorldClears == nil and (result.WorldClears["1"] or 0) > 0 then
        result.LegacyWorldAccess["2"] = true
    end
    return result
end
function Rules.Cycle(now, config)
    assert(type(now) == "number" and now == now and now >= 0 and now < math.huge)
    assert(config.DayDuration > 0 and config.NightDuration > 0)
    local length = config.DayDuration + config.NightDuration
    local id = math.floor(now / length)
    local elapsed = now - id * length
    local day = elapsed < config.DayDuration
    return {
        id = id,
        phase = day and "Day" or "Night",
        endsAt = id * length + (day and config.DayDuration or length),
    }
end
function Rules.ApplyCycle(data, cycleId)
    if data.CycleId ~= cycleId then
        data.CycleId = cycleId
        data.Destroyed = {}
        data.Awarded = {}
    end
end
function Rules.Count(data, worldId, buildingIds)
    local destroyed = data.Destroyed[tostring(worldId)] or {}
    local count = 0
    for _, id in ipairs(buildingIds) do
        if destroyed[id] then
            count += 1
        end
    end
    return count
end
function Rules.RecordDestroyed(data, worldId, buildingId, buildingIds, cycleId)
    if not table.find(buildingIds, buildingId) or #buildingIds == 0 then
        return false
    end
    Rules.ApplyCycle(data, cycleId)
    local key = tostring(worldId)
    data.Destroyed[key] = data.Destroyed[key] or {}
    if data.Destroyed[key][buildingId] then
        return false
    end
    data.Destroyed[key][buildingId] = true
    if data.Awarded[key] or Rules.Count(data, worldId, buildingIds) < #buildingIds then
        return false
    end
    -- 파괴 기록과 Win을 같은 프로필에서 함께 갱신합니다. 클라이언트 완료 요청은 없습니다.
    data.Awarded[key] = true
    data.Wins += 1
    data.WorldClears[key] = (data.WorldClears[key] or 0) + 1
    return true
end
function Rules.ZoneKey(worldId, zoneId)
    return tostring(worldId) .. "-" .. tostring(zoneId)
end

function Rules.IsZoneUnlocked(data, worldId, zoneId)
    return data.UnlockedZones[Rules.ZoneKey(worldId, zoneId)] == true
end

-- 코인 잔액은 호출하는 쪽에서 따로 확인합니다. 여기서는 선행 조건만 봅니다.
function Rules.CanUnlockZone(data, worldId, zone)
    if Rules.IsZoneUnlocked(data, worldId, zone.id) then
        return false, "이미 해금한 구역입니다"
    end
    if zone.requiresWorldClear and (data.WorldClears[tostring(zone.requiresWorldClear)] or 0) < 1 then
        return false, "먼저 1구역 건물을 모두 부수세요(완파 1회)"
    end
    if zone.requiresZoneClear and (data.ZoneClears[Rules.ZoneKey(worldId, zone.requiresZoneClear)] or 0) < 1 then
        return false, "먼저 구역" .. zone.requiresZoneClear .. "를 완파하세요"
    end
    if zone.requiresZone and not Rules.IsZoneUnlocked(data, worldId, zone.requiresZone) then
        return false, "먼저 구역" .. zone.requiresZone .. "를 해금하세요"
    end
    return true
end

function Rules.UnlockZone(data, worldId, zoneId)
    data.UnlockedZones[Rules.ZoneKey(worldId, zoneId)] = true
end

-- 구역별 완료는 영구 기록, 건물 파괴 목록은 기존처럼 낮 주기마다 초기화합니다.
function Rules.RecordZoneDestroyed(data, worldId, zoneId, buildingId, zoneIds, cycleId)
    if not table.find(zoneIds, buildingId) or #zoneIds == 0 then
        return false
    end
    Rules.ApplyCycle(data, cycleId)
    local worldKey = tostring(worldId)
    local zoneKey = Rules.ZoneKey(worldId, zoneId)
    local awardKey = worldKey .. ":zone:" .. zoneId
    data.Destroyed[worldKey] = data.Destroyed[worldKey] or {}
    if data.Destroyed[worldKey][buildingId] then
        return false
    end
    data.Destroyed[worldKey][buildingId] = true
    if data.Awarded[awardKey] or Rules.Count(data, worldId, zoneIds) < #zoneIds then
        return false
    end
    data.Awarded[awardKey] = true
    data.ZoneClears[zoneKey] = (data.ZoneClears[zoneKey] or 0) + 1
    if zoneId == 1 then
        -- 기존 시설 조건 WorldClears["1"]은 첫 구역 완료의 뜻으로 유지합니다.
        data.WorldClears[worldKey] = (data.WorldClears[worldKey] or 0) + 1
        data.Wins += 1
    end
    local allCleared = true
    for zone = 1, 3 do
        if (data.ZoneClears[Rules.ZoneKey(worldId, zone)] or 0) < 1 then
            allCleared = false
        end
    end
    if allCleared then
        data.FullWorldClears[worldKey] = math.max(1, data.FullWorldClears[worldKey] or 0)
    end
    return true
end

function Rules.CanEnter(data, world)
    if world.previousWorld ~= 0 then
        return data.LegacyWorldAccess[tostring(world.id)] == true
            or (data.FullWorldClears[tostring(world.previousWorld)] or 0) >= 1
    end
    return data.Wins >= world.requiredWins
        and (
            world.previousWorld == 0
            or (data.WorldClears[tostring(world.previousWorld)] or 0) >= 1
        )
end
return Rules
