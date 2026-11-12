-- 초기 레벨 디자인 수치입니다. 1월드 첫 진출 테스트 후 이 파일에서 조절합니다.
return {
    DayDuration = 180,
    NightDuration = 25,
    WorldFolder = "ProjectMS_Worlds",
    PersonalCityFolder = "ProjectMS_PersonalCities",
    -- 기지별 진격 대로. Lane_N.Entry 기준으로 Base_N 소유자의 월드1 도시를 복제합니다.
    LaneFolder = "ProjectMS_Lanes",
    TemplateLane = 1, -- ProjectMS_City 템플릿을 실제로 배치해 둔 대로 번호.
    RequestInterval = 0.25,
    -- 월드1 대로의 구역 해금(2026-11-10). boundary는 광장 중심에서 벽까지 거리(스터드).
    -- 재화 결정: 구역 해금 = 이전 구역 조건 + 코인. 비용은 밸런스 계산표에서 다시 정함.
    -- 구역2는 구역1 완파, 구역3는 구역2 완파 후 코인으로 해금합니다.
    Zones = {
        { id = 2, name = "구역2", boundary = 560, cost = 200, requiresWorldClear = 1 },
        { id = 3, name = "구역3", boundary = 800, cost = 500, requiresZone = 2, requiresZoneClear = 2 },
    },
    ZoneClearResearch = { [1] = 4, [2] = 6, [3] = 10 }, -- 완파 확정 연구자료(시험값)
    ZoneEnforceMaxDistance = 1300, -- 이보다 먼 곳(월드2 섬)은 구역 검사 제외
    Worlds = {
        {
            id = 1,
            name = "입문 도시",
            requiredWins = 0,
            previousWorld = 0,
            healthMultiplier = 0.25,
        },
        {
            id = 2,
            name = "산업 도시",
            requiredWins = 1,
            previousWorld = 1,
            healthMultiplier = 1,
        },
    },
}
