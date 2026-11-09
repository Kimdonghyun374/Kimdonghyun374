# Toy City v03 UI 아이콘

2026-11-09 KST · 현재 사용자 채택 기준은 art/references/toy-city-v03/ui/01-gameplay-hud.png.
기존 simple-scifi-ui-sheet-v02의 남색 패널안보다 이 밝은 UI 기준을 우선한다.

## 파일

- coin.png → SalvageHUD.Resources.Scrap (표시 이름 코인, 매핑 키 scrap)
- research-blueprint.png → SalvageHUD.Resources.ResearchData
- base.png → WorldProgressHUD.Panel.Home
- inventory.png → MissileBaseHUD.BaseBanner.OpenInventory
- world.png → WorldProgressHUD.Panel.World1 / World2
- focus.png → PetMissileHUD.Panel.Focus
- garage.png → ScoutBuggyHUD.OpenGarage
- craft.png → MissileBaseHUD.Inventory.Roll

현재 매핑의 9개 모두 1254×1254 RGBA PNG, 투명 배경. 미사일·탈것 이미지 없음. preview.html에서 흰 패널과 32px 표시 예시를 열 수 있다. 생성 원본을 수정 없이 복사했다.

## Roblox 적용 기준

- 패널 #FAFCFF, 텍스트 #10275E, 경계 #C3D5FA, 주요 버튼 #2479F7, 확인 #29B928, 닫기 #F14D60. 레퍼런스를 바탕으로 정한 구현용 근사값.
- 패널/버튼은 Frame/TextButton + UICorner + UIStroke. 텍스트, 가격, 상태, 단축키, 수량은 네이티브 UI.
- 아이콘은 ImageLabel.BackgroundTransparency=1, ScaleType=Fit, ImageColor3=white. 기본 표시 32~48px, 터치 버튼 영역은 48px 이상 권장.
- 흰 패널과 남색 글자, 파랑 기본 행동, 초록 확인/장착, 빨강 닫기. 큰 모서리 반경과 얕은 그림자. HUD 위치/동작/Remote는 별도 승인 없이 변경하지 않는다.
- 보관함 기호는 미사일 이미지 제외 지시에 따라 파란 장비 상자로 대체했다.

## 업로드 상태 / 검증

8종 생성 결과 시각 검토 및 PNG 크기/알파 확인. 브라우저 도구의 로컬 파일 접근 제한으로 preview.html 렌더 검증은 미실행. 원본 확대 미리보기의 일부 잔색은 알파 1/255 표본으로 확인했으며, 실제 게임 크기의 최종 표시는 Studio 적용 후 확인해야 한다.

2026-11-09 폴더 권한 저장 후 8종 업로드 성공, 모든 operation done=true 및 moderation Approved 확인. manifest.json의 assetId/image는 ImageLabel용 실제 이미지 ID, decalAssetId는 업로드된 Decal ID. InsertService로 Decal.Texture를 읽고 임시 모델을 Destroy하여 매핑 확인. UIAssets.luau를 복사해 ImageLabel.Image에 사용 가능. 2026-11-10 동전 교체용 PNG를 추가해 업로드 및 Approved 확인. 저장소 UIAssets.luau의 scrap 키는 rbxassetid://72200879387099로 갱신. Studio UI 연결은 후속 작업.

업로드 경로: C:\\ProjectMS\\art\\ui\\toy-city-v01\\toy-v03-icons

## Claude 인수인계

사용자는 이번 밝은 토이 v03 UI를 채택했다. TODO의 simple-scifi 테마 작업에는 이 디자인 변경을 반영할 것. 본 작업은 Studio 코드/화면을 변경하지 않았다. 위 target은 이전 실제 UI 소스 조사 기준이므로 현재 UI 생성부를 재확인 후 이미지 배치. 등록된 UIAssets.luau / manifest.json의 image 값을 ImageLabel.Image에 연결한다. 기존 서버 검증·저장·경제·버튼 Activated 연결은 보존한다. Save/Publish 없음.

2026-11-10 변경: 연구자료는 평면 파란 설계도(rbxassetid://105888631454719), 집중 공격 버튼은 일제사격 아이콘(rbxassetid://109239933150633). Studio UIAssets의 research를 갱신하고 focusSkill 키를 추가한다. PetMissileClient는 focusSkill을 우선 사용하며 focus는 기본 조준 아이콘으로 남는다. 흰색/주황색 배경과 모바일 크기는 적용 후 확인.

2026-11-10 재장전 수정: 화살표 두 개와 미사일 세 발로 집중 공격 버튼의 전탄 재장전 기능을 표현. focusSkill은 rbxassetid://72548406471009 사용. 기존 조준 링 버전을 대체한다.
