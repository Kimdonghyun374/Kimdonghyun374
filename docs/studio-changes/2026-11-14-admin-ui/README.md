# 관리자 흑백 UI · 11시 패널 제거 · 장난 RPG · 옛 오브젝트 치우기 (2026-11-14 KST, Claude)

게임 Place 122289987934213, Edit. 사용자 요청:
11시 월드 패널(기지로 귀환 등) 필요 없음 → 테스트용 기능(순간이동·돈 얻기·1월드 가기 등)을 **주인만 여는 흑백 관리자 UI**로,
쓰지 않는 오브젝트(공동 목표 지점)는 잠시 치우기, 발사 버튼은 모바일에서만, **권총 → RPG 런처(범위 폭발·피해 없음·밀려나며 래그돌)**.

백업: `ServerStorage.ProjectMSBackups.BeforeAdminUI_1794655706`(WorldProgressClient·MissileBaseClient·미리보기 2개),
`BeforePrankRpg_1794655925`(SocialService·SocialConfig·SocialClient·장난 권총 도구, 원본 도구 `장난 권총_원본` 포함).

## 관리자 UI
- 서버 `ServerScriptService.PetMissiles.AdminController`(Script) + RemoteEvent `ReplicatedStorage.PetMissiles.AdminRequest`. 사본: [AdminController.server.luau](AdminController.server.luau)
  - 관리자 = 개인 소유 게임의 주인(`game.CreatorId` 8824476855). Studio 로컬 가짜 플레이어(음수 Id)는 Studio에서만.
  - **모든 요청을 서버에서 다시 확인**, 정해진 항목만 실행(클라이언트 좌표·금액 안 받음), 0.25초 간격 제한.
  - 이동: 광장 스폰·레이드 자리(가장자리)·내 기지·빈 기지 발판·1월드 입구(내 대로 Entry)·2월드(기존 진입 규칙)·구역2·구역3(잠겨 있으면 문 앞으로 밀려남)
  - 자원: 코인 +100/+1000, 연구자료 +10 (BaseService.GrantResources)
  - 이벤트: 레이드 지금 예고(10초)
  - 시간(Studio 전용): 낮 고정/밤 고정/정상
- 클라이언트 `StarterPlayerScripts.AdminClient`: 서버가 준 `ProjectMSAdmin` 속성이 있을 때만 오른쪽 위 흑백 **ADMIN** 버튼과 창을 만듦. 사본: [AdminClient.client.luau](AdminClient.client.luau)

## 11시 패널·테스트 버튼 제거
- `WorldProgressClient`의 월드 패널은 `Visible = false`(코드·통신은 그대로). 일반 플레이어는 대로를 걸어서 1월드 도시로 감(세션 기본 월드 1).
  **2월드로 가는 일반 버튼은 이제 없음**(2월드 섬 입구 프롬프트만 남음, 관리자 창에서 이동 가능).
- `MissileBaseClient`의 Studio 테스트 이동 버튼(빈 기지로 이동) 항상 숨김 → 관리자 창 "빈 기지 발판".
- 코인 패널은 왼쪽 패널 줄 맨 위로 올라감(HudLayout). 미리보기에서도 두 요소 제거·코인 패널 위치 조정.

## 옛 오브젝트 치우기
- `Workspace.MissileSimulator`(옛 시스템의 "공동 목표 지점" 과녁·기둥·안내판, TargetPoint) → `ServerStorage.ProjectMS_Parked.MissileSimulator`.
  이것을 쓰는 스크립트(MissileHUD·MissileVisualClient·SSS.MissileSimulator.Controller)는 모두 꺼져 있음을 확인. 되돌리려면 Workspace로 다시 옮김.

## 장난 RPG
- 도구 `StarterPack.장난 RPG`(회색 발사관·노란 띠·빨간 로켓, 앞=-Z, Muzzle (0,0.5,-2.9)). 서버 판정 표식 `PrankPistol` 속성은 호환 위해 유지.
- `SocialConfig`: ToolName "장난 RPG", 재사용 2초, 래그돌 1.6초, 로켓 140 stud/초, 폭발 반경 12, 밀기 55·띄우기 28(가장자리는 절반), 사거리 160, 피격 보호 6초.
- `SocialService`: 레이캐스트로 착탄점 → 클라이언트에 로켓 연출 → 같은 속도로 도착 시각 계산 후 `GetPartBoundsInRadius`로 반경 안 플레이어(Studio 시험 대상 포함, 쏜 사람 제외)를 바깥으로 밀며 래그돌. 잠긴 기지·진입로 보호 유지. 피해 없음.
- `SocialClient`: 버튼 글자 RPG, 로켓(꼬리 불꽃)·폭발 구·충격파 고리·시각 전용 Explosion(밀기·관절 끊기 0). **발사 버튼은 모바일에서 장착 중일 때만**(PC는 화면 클릭).

## 검증 (Play 1인, PC 1918×1080)
- 주인 계정 관리자 판정 true, ADMIN 창 버튼 15개(Studio), 실제 클릭으로 코인 +1000(20→1020)·레이드 자리 이동. 수정 뒤 레이드 이동 위치 (0, 3.2, -60) 바닥 확인.
- 월드 패널·테스트 버튼 숨김, 장착 도구 "장난 RPG", PC 발사 버튼 숨김.
- RPG: 더미(PrankTestTarget) 옆 4 stud 바닥 조준 → 범위 폭발로 래그돌, 0.6초 뒤 속도 28·이동 14.8 stud, 2.5초 뒤 일어남. 클라이언트 로켓 1·폭발 1 수신, "명중 1명" 알림.
- 콘솔 기존 203785492 경고만. 열린 탭 편집기=Source. Save/Publish 안 함.
- 미검증: 실제 다른 플레이어 2인 명중, 모바일 발사 버튼 실제 터치, 게시 서버에서 주인 외 계정에 창이 안 보이는지(코드상 서버 판정), RPG 화면 연출 눈 확인(캡처 안 함).
