-- 기지/수동 뽑기 설정. 자동 뽑기는 구현하지 않습니다.
return {
    PlotCount = 6, -- Workspace의 Base_1 ~ Base_6(링 광장, 60° 간격)과 일치시킵니다. 서버 정원도 6명(2026-11-10 사용자 결정).
    -- 아래 세 항목은 최초 Edit 배치 전용(현재 미사용). 링 광장 위치는 Workspace에서 직접 편집합니다.
    PlotColumns = 3,
    PlotSpacing = 56,
    OriginOffset = { 0, 0, 140 },
    RollCost = 20, -- 기존 Scrap 재화를 코인으로 사용합니다.
    ProductionDuration = 5, -- 결제 후 실제 미사일 지급까지 걸리는 시간(초).
    StarterScrap = 20, -- 첫 제작용 코인. 자격을 갖춘 플레이어에게 한 번만 지급합니다.
    RollCooldown = 2, -- 제작 완료 후 다음 제작까지의 대기시간.
    RevealDuration = 1.2, -- 이전 버전 호환 설정. 지급을 늦추는 용도로 사용하지 않습니다.
    InventoryCapacity = 100,
    GalleryCapacity = 96,
    GalleryUpgradeCost = 50, -- 임시 밸런스: 전시장 1칸 확장 비용(코인).
    GalleryLockedTransparency = 0.82,
    InteractionDistance = 11,
    ClaimDistance = 13, -- 기지 차지 E 프롬프트 거리(12)보다 조금 넓게. 발판 밟기 차지는 2026-11-10 제거.
    RequestInterval = 0.15,
    StoreName = "ProjectMS_ManualBases_v1",
    StudioTestTravel = true, -- Studio 전용 이동 버튼. 게시 서버에서는 항상 비활성.
    StudioMockData = true, -- Studio에서는 테스트 데이터. 게시된 서버에서는 실제 저장.
    ProfileLoadTimeout = 45,
}
