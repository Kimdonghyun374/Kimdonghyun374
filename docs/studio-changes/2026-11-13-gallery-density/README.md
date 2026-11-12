# 전시장 확장·도시 밀집 배치 (2026-11-13)
실제 원본: Studio Place 122289987934213 Edit DataModel. 이 폴더는 적용한 모듈의 검토용 사본이며 자동 동기화되지 않습니다.
실행 컴퓨터: DESKTOP-RLF93FA, 작업 저장소: C:\ProjectMS.

- 백업: ServerStorage.ProjectMSBackups.BeforeGalleryUnlockDensity_1794500165.
- ServerScriptService.PetMissiles: BaseDomain, BaseService, BaseWorld 교체, GalleryWorld 추가.
- ReplicatedStorage.PetMissiles: BaseConfig 교체.
- ProjectMS_City 기존 8채의 피벗 X/Z만 이동. HP·보상·건물 ID는 유지.
- 6개 기지 모두 Edit에서 왼쪽 1층 첫 칸만 불투명, 나머지는 Transparency 0.82. 잠긴 시설 충돌 없음.
- GalleryWorld는 GalleryOriginal* 속성으로 원래 외형·충돌을 보관하고 해금 시 복원.
- 초기 GallerySlots=1, 순서 L1 24칸 → R1 24칸 → L2 24칸 → R2 24칸. 해당 2층 첫 칸을 열면 경사로·바닥도 활성화.
- 왼쪽 첫 Display의 UpgradeGallery 프롬프트(E 0.5초/터치)로 확장. 임시 비용은 BaseConfig.GalleryUpgradeCost=50코인, 한 번에 한 칸. 확정 밸런스 아님.
- 저장 키 GallerySlots를 기존 Version 1에 추가. 기존 저장값에 키가 없으면 1로 보완. 미사일 장착 수나 인벤토리 용량과 별개.
- 추가 전시칸의 보유 미사일 배치·도감·AFK 수익은 아직 미구현. 기존 첫 Display 제작 결과 미리보기는 유지.
- 파티클 플러그인은 사용자 취소로 변경 없음.

## 건물 피벗 (X, Z)
주택 (-24,-280), 주택B (24,-286), 상가 (24,-330), 상가B (-24,-336),
사무실 (-24,-380), 사무실B (24,-386), 연구동 (26,-430), 창고 (-24,-436).
앞뒤 중심 분포 230 → 156 stud(약 32% 축소). 4개 건물쌍 기준 간격 약 75 → 50.
중앙 도로 폭 22 stud 유지. 모든 건물 바운딩박스 비겹침 확인.

## 실제 검증
- 도메인: 기존 데이터 기본값, 소유권/거리/중복 이전 단계/잔액 부족/상한, 정확한 50 차감, JSON 직렬화 후 Normalize 유지, 잘못된 값 거절.
- 시각 상태: 1/2/24/25/48/49/72/73/96 단계의 불투명 칸 수, 2층 경사로 충돌, 소유 해제/재차지.
- Play Mock: 빈 기지 숨김 → 차지 1/96 → 잔액 부족 거절 → 서버 업그레이드 2/96 → 클라이언트 실제 프롬프트 InputHoldBegin/End로 3/96. 먼 거리/다른 기지 거절, 잔액 보존 확인.
- 도구의 직접 require는 실행 중 서비스 상태와 달라 ready=false로 나왔음. 정상 서버 Script에서 검증해 통과. 임시 서버 러너 제거 후 Play 종료.
- Transparency는 float32이므로 0.82 비교는 오차 허용 검증.
- 게시 서버 실제 재접속 저장, 다인 접속, 모바일 실기기 미검증. Save/Publish 수행 안 함.
