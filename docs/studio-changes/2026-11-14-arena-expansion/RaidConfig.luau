-- 광장 공동 레이드 시험값 (2026-11-14). 시트 MS_MASTER RAID 탭과 같게 유지합니다.
return {
    -- 일정: 서버 시작 FirstDelay초 뒤 첫 예고, 이후 Interval초마다(예고 시작 기준) 반복
    FirstDelay = 60,
    Interval = 600,
    WarningDuration = 30, -- 예고(카운트다운) 시간
    Duration = 300, -- 제한 시간 5분(사용자 결정)

    -- 보스: 체력 = HealthPerPlayer × 서버 인원(최소 1명), 등장 순간 기준
    HealthPerPlayer = 3000,
    BossName = "레이드 보스 · 요새",
    BossHeight = 26, -- 광장 바닥 위 보스 중심 높이(stud)
    ArenaRadius = 120,

    -- 공격: AttackInterval초마다 경고 원 AttackCount개, WarningTime초 뒤 폭발. 맞으면 넘어짐(체력 피해 없음)
    AttackInterval = 6,
    AttackCount = 3,
    AttackWarningTime = 2,
    AttackRadius = 7,
    AttackPlayerRange = 135, -- 이 거리 안 플레이어를 우선 노림(광장 중심 기준)

    -- 보상(처치 때만): 보스 체력의 ParticipationRatio 이상 피해 = 참여
    ParticipationRatio = 0.01,
    ParticipationCoins = 200,
    ParticipationResearch = 4,
    ContributionCoins = 600, -- 피해 비율대로 나눔
    TopDamageResearch = 2,
}
