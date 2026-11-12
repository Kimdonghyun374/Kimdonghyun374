-- 수치 조절의 단일 진입점. 기존 MissileSimulator 설정과 분리합니다.
local Config = {
    -- 기본 장착 한도 3발. 연구 성장 연결 전까지 레벨과 관계없이 같은 한도를 사용합니다.
    MinMissiles = 3,
    MaxMissiles = 3,
    MissilesPerLevel = 1,
    DefaultLevel = 1,
    LevelAttribute = "Level",
    LevelValueName = "Level",

    -- 자동 발사, 재장전과 서버 요청 간격입니다.
    AutoEnabled = true,
    AutoInterval = 1.6,
    ShotInterval = 0.1,
    ReloadTime = 3,
    Range = 90,
    Damage = 15,
    RequestInterval = 0.18,
    SyncInterval = 0.15,
    -- 서버 공용 상한. 재장전(3초) > 최대 비행(2.5초)이라 1인 동시 비행은 최대 MaxMissiles(3)발.
    -- 정원 6명 × 3 = 18 < 150 (2026-11-10, 8명일 때 80). 정원·슬롯을 늘리면 다시 계산합니다.
    MaxActiveFlights = 150,

    -- 미사일 비행 궤적과 충돌 판정에 사용하는 값입니다.
    FlightSpeed = 70,
    MinFlightTime = 0.45,
    MaxFlightTime = 2.5,
    FlightSpread = 9,
    FlightLift = 7,
    ImpactRadius = 3,

    -- 실제 적 판별과 이전 훈련 표적 호환 설정입니다.
    EnemyTag = "MissileEnemy",
    EnemyFolder = "Enemies",
    DemoFolder = "ProjectMS_MissileDemo",
    DemoHealth = 300,
    DemoRespawnTime = 5,

    -- 클라이언트의 장착 미사일 추적과 입력 설정입니다.
    FollowResponse = 12,
    BobAmplitude = 0.25,
    BobSpeed = 2.5,
    FocusKey = Enum.KeyCode.F,

    -- 집중 공격 게이지 (2026-11-10). 접속하면 가득 찬 상태로 시작합니다.
    -- 가득 찼을 때 쓰면 모든 슬롯을 즉시 재장전하고 전탄을 한 목표에 쏜 뒤 0으로 돌아갑니다.
    -- 일반 공격(자동 포함) 명중 1발마다 충전. 집중 공격 자신의 명중은 충전하지 않습니다.
    FocusChargeMax = 100,
    FocusChargePerHit = 2, -- 일반 공격 50발 명중이면 가득
}

function Config.Count(level)
    if typeof(level) ~= "number" or level ~= level or math.abs(level) == math.huge then
        level = Config.DefaultLevel
    end
    return math.clamp(
        math.floor(level * Config.MissilesPerLevel),
        Config.MinMissiles,
        Config.MaxMissiles
    )
end

-- 슬롯 순서 자체가 왼쪽/오른쪽 교대입니다. 5개 초과 시 두 줄로 배치합니다.
function Config.Offset(slot, count)
    if count == 1 then
        return Vector3.new(0, 1.3, 3)
    end
    local rows = count <= 5 and { count } or { math.ceil(count / 2), math.floor(count / 2) }
    local layout = {}
    for pair = 1, 3 do
        for row, rowCount in rows do
            if pair <= math.floor(rowCount / 2) then
                local horizontalOffset = (pair - (rowCount % 2 == 0 and 0.5 or 0)) * 1.45
                table.insert(
                    layout,
                    Vector3.new(-horizontalOffset, 1.3 + (row - 1) * 1.55, 3 + (row - 1) * 0.8)
                )
                table.insert(
                    layout,
                    Vector3.new(horizontalOffset, 1.3 + (row - 1) * 1.55, 3 + (row - 1) * 0.8)
                )
            end
        end
    end
    for row, rowCount in rows do
        if rowCount % 2 == 1 then
            table.insert(layout, Vector3.new(0, 1.3 + (row - 1) * 1.55, 3 + (row - 1) * 0.8))
        end
    end
    return layout[slot]
end

function Config.Position(flight, now, targetPosition)
    local progress = math.clamp((now - flight.startedAt) / flight.duration, 0, 1)
    local startPoint = flight.origin
    local outgoingControlPoint = startPoint
        + flight.right * flight.side * Config.FlightSpread
        + Vector3.yAxis * Config.FlightLift
    local endPoint = targetPosition
    local incomingControlPoint = endPoint
        + flight.right * flight.side * Config.FlightSpread * 0.35
        + Vector3.yAxis * Config.FlightLift
    local inverseProgress = 1 - progress
    return startPoint * inverseProgress ^ 3
        + outgoingControlPoint * 3 * inverseProgress ^ 2 * progress
        + incomingControlPoint * 3 * inverseProgress * progress ^ 2
        + endPoint * progress ^ 3,
        progress
end

Config.RequireOwnedMissiles = true
return Config
