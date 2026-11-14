# Toy City v04 그래픽·미사일 VFX 적용

2026-11-14 KST, 게임 Place122289987934213. 승인 레퍼런스 art/references/toy-city-v03와 최신 Studio 배치·GDD·레벨 문서, MS_MASTER BASE_CRAFT/BUILDINGS/RAID를 대조했다. Notion의 과거 8기지/반경60 설명은 현행 배치로 해석하지 않았다.

## 적용 범위

- 광장 r168·레이드 r120·기지 중심r230 보존. 광장 경계/횡단 표시·가로수·벤치·가로등, 6기지의 밝은 포장·경계·전시장·차고·제작기 로봇 팔, 파란 기술실/레이더와 초록 AFK 캐노피/태양광 패널.
- 6개 대로 차선/횡단보도·가로등/가로수·구역 문. 중앙22stud 통행과 서버 벽 판정 유지.
- 월드1 22채 + 월드2 4채: 흰 외벽·파란 창틀·붉은 차양·도로 방향 문·옥상 탱크/관측실. 기존 루트/창 이름·위치·크기·체력·보상 보존. 추가 Window도 기존 손상 시스템이 찾는다.
- 보스의 흰 요새 장갑/파란 링·경고 포인트, 탈것 팬/범퍼, 권총 흰 본체/파란 슬라이드/노란 총구, 미사일 복제본의 흰 동체/등급별 탄두/노란 날개. UI 배치·서버 전투 수치·권총 궤적은 그대로.
- 자산 Place127014821326220의 23종과 게임 MissileAssets의 파트 이름/클래스/크기/색 구성 일치 확인. 중복 모델을 만들지 않음. MissileVFX는 자산의 독립 모듈을 그대로 복사, Part_Icles 코드 변경/재배포 없음.
- 실제 미사일 비행에 attach, 명중에 explode 연결. PC 품질0.65·터치0.4, 동시 비행24개 이상은 반감. 카메라 주변240stud·초당10착탄까지만 추가 폭발 효과. 피해 판정 제한이 아니다.
- 낮/밤 ClockTime 전환 유지, 푸른 환경광·약한 Bloom·선명한 배경. Edit 보스 사본 RaidBossPreview는 RaidService.Start가 삭제.

## 파일 매핑·재현

ArtKit → ReplicatedStorage.PetMissiles.ArtKit(ModuleScript), MissileVFX/MissileModels → 같은 폴더. BaseWorld/RaidService/VehicleService → ServerScriptService.PetMissiles. PetMissileClient → StarterPlayerScripts의 기존 LocalScript.

스크립트는 ScriptEditorService.UpdateSourceAsync와 .Source를 함께 갱신하고 편집기=Source를 확인해야 한다. 이 폴더는 검토/재현 사본이며 자동 Rojo 적용을 뜻하지 않는다. 백업 뒤 새로 로드한 ArtKit으로 ApplyWorld → PolishWorld → CreateBossPreview를 Edit에서 실행한다. Edit require 캐시 때문에 모듈을 바꿨다면 새 복제 모듈을 require해 사용한다. 이미 적용된 맵에서 무작정 전체 재실행하지 않는다.

백업: ServerStorage.ProjectMSBackups.BeforeToyCityVisuals_1794646284. 서비스 컨테이너는 직접 Clone이 안 되어 StarterPack/Lighting/StarterPlayerScripts의 자식을 폴더에 보관했다. Lighting 후처리 자식과 초기 Brightness/Ambient/OutdoorAmbient/Exposure 값은 보관했으나, 환경광 스케일·ShadowSoftness의 초기값은 기록하지 못했다.

## 실제 검증

- 최초 Play: 빈 기지 제작대 장식 숨김·Edit 보스 사본 제거·ArtKit/VFX 로드.
- Mock 차지→실제 제작1개, 열린 장식12개 표시. 잠긴 제작대 장식이 건설 Tween 때문에 불투명해지는 문제를 발견해 이전 Tween 취소 추가 후 재검증 통과.
- 실제 미사일로 주택 파괴, 클라이언트 FlightVFXCount=2·ImpactVFXCount=2. 단순 효과 함수만 직접 호출한 검증이 아니다.
- 탈것1단계 구매→탑승→장식6개 모두 WeldConstraint/비고정/Massless 확인→하차. 첫 검증의 expectedLevel1 인자는 현재단계0으로 바로잡았다.
- 실제 RaidService 예고→Active, 장식36개·흰 Hull·HP3000, Edit 사본 부재 확인.
- 미사일23종 2.4stud 복제 생성, PrimaryPart·비충돌/비조회/고정 검증.
- 도시22채 좌표/루트 크기/체력/보상 기존 백업과 일치. ToyCityArt 장식 중 충돌·조회·접촉 켜짐0.
- 최종 파트 수: 기지 전체2964, 대로/광장1359, 월드1 템플릿2427. 6인·모바일 성능 실측은 아직 필요하다.
- native Studio 창에서 도시/기지 전체 외형 확인. Studio screen_capture는 HUD만 캡처해 native Computer Use로 보완. 기존203785492 경고 외 Play 새 오류 없음.
- 테스트 러너/Remote 제거, 두 Studio Edit. Save/Publish 미실행. 실제 다인·모바일·자연 공략·게시 저장 검증 미완료.

## Blender

art/models/toy-city-v04에 게임 Part 조형에서 만든 5종(주택/사무실/기술실/AFK/제작기)의 .blend·.glb·렌더·재현 JSON/Python이 있다. 기존 Blender Scene/Cube는 별도 원본 장면으로 보존. GLB는 새 제작 장면만 내보냈다. Blender 베벨 렌더는 게임에 업로드된 메시가 아니며, 게임에는 Part 기반 조립 외형이 적용됐다.

시트 README A37:B39, 기존 Notion GDD/레벨 문서 상단에 구현·검증·한계 기록. Sheet 값/줄바꿈은 API 재읽기로 확인했고 Google 화면 시각 검증은 미실행.
