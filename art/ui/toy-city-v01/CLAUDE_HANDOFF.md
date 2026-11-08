# Claude 인수인계 — 단순 SF UI 시트 v02
작성: 2026-11-09 KST, Windows DESKTOP-RLF93FA, C:\ProjectMS.

## 사용자 최신 방향
입체 장난감 아이콘 시안은 채택하지 않음. 아주 단순한 UI. 메뉴 기호와 플레이어가 이용 가능한 모든 미사일·탈것을 개별 UI 이미지로 제작하고, 패널·버튼·글자·수치·상태는 Roblox 네이티브 UI로 제작.
Pet Simulator 99의 읽기 쉬운 정보·인벤토리 구성을 참고하되, 미사일 게임에 맞게 조금 더 각지고 단단한 SF 장비 느낌.
이는 시안 단계. 이전 16종 입체 아이콘과 작성 중이던 토이 테마 모듈을 적용하지 말 것.
업로드 폴더 C:\ProjectMS\art\ui\toy-city-v01 허용 완료라는 사용자 응답은 받음. 새 방향의 아이콘 업로드는 아직 하지 않음.

## 제작 분담
- 이미지로 등록: 부품(육각 너트), 연구자료(플라스크), 미사일, 기지, 보관함, 월드, 호버보드, 집중 표적 — 8개 단순 단색/2색 기호 후보.
- Roblox로 제작: Frame/TextButton/TextLabel, UIStroke, UICorner(작은 반경), UIListLayout/UIGridLayout, UIPadding, ScrollingFrame, UISizeConstraint, 진행 막대.
- X·체크·화살표는 글리프/단순 선으로 충분하면 별도 업로드하지 않음.
- 사용자 추가 확정: 모든 이용 가능한 미사일·탈것에 개별 UI 이미지를 제작한다. 인벤토리·도감·제작 결과·장착 슬롯·차고·구매 화면에서 같은 장비 이미지 매핑을 재사용한다. ViewportFrame을 기본 대안으로 사용하지 않는다. 현재 시트의 흰 실루엣은 자리 표시이며 최종 이미지가 아니다. 게임 월드의 3D 모델까지 이미지로 바꾼다는 뜻은 아니다.
- 패널 통째 PNG, 이미지에 박힌 글자/가격/수치, 9-slice 장식 프레임, 과도한 네온/금속/나사/경고 줄무늬는 불필요.

## 색/형태 후보 (승인 전)
짙은 남색/슬레이트 패널, 밝은 글자, 파란 선택·주요 액션, 작은 노랑 상태 표시, 초록 확인, 빨강 닫기/경고.
작은 모서리 반경, 얇은 경계선, 큰 글씨와 누르기 쉬운 버튼. 원본 도시 아트의 밝은 기본색은 유지.
단순 SF는 정보가 많은 항공기 계기판을 뜻하지 않음. 화면 중심은 게임 장면에 양보.

## 실제 Studio 읽기 결과
Place 122289987934213, Edit에서 확인. StarterPlayer.StarterPlayerScripts 아래:
- PetMissileClient (Enabled): PetMissileHUD.Panel.Focus. requestFocus → network.Focus:FireServer({target=selectedTarget}), F/Activated 흐름 유지.
- MissileBaseClient (Enabled): MissileBaseHUD.BaseBanner.OpenInventory, Inventory.Close/Roll/Items/Item_<id>. BaseRequest, BaseState 사용. 장착·제작의 서버 검증/요청 간격 유지.
- SalvageClient (Enabled): SalvageHUD.Resources.Scrap/ResearchData, PickupNotice. BaseState의 scrap/researchData로 표시.
- WorldProgressClient (Enabled): WorldProgressHUD.Panel.Phase/Wins/Progress/World1/World2/Home. ProgressionRequest/State 유지.
- ScoutBuggyClient (Enabled): ScoutBuggyHUD.OpenGarage/Garage, Garage.Close/Upgrade/Summon/Exit. VehicleRequest/State, BaseState. 아직 실제 버기 코드이며 호버보드 외형 아이콘만 바꾼다고 이동 방식이 교체되지 않음.
- MissileHUD는 Disabled(옛 리모컨 UI). 활성화하거나 새 UI와 섞지 말 것.
런타임에 GUI를 생성하므로 StarterGui에 그림만 넣어서는 기존 UI가 바뀌지 않음.

## 후속 적용 순서
1. 새 시트에 대한 사용자 피드백 반영 → 단순 아이콘 형태 확정.
2. 메뉴 기호 8종 후보와 이용 가능한 미사일·탈것 전체 목록을 현재 Studio/기준 시트에서 대조하고, 장비별 개별 PNG를 제작·업로드한 뒤 ID별 asset ID 매핑을 기록. 미확정 장비 이름·수량은 임의로 채우지 않는다. 이 시트 자체는 게임 UI 텍스처로 업로드하지 않음.
3. 사용자 지시 하에 Studio UI 생성부 백업, 공통 테마 모듈 도입. 위 스크립트의 UI 생성/색 갱신 부분만 단계적으로 교체.
4. 동적 Text 변경과 상태별 BackgroundColor3 변경도 테마 적용 대상. 기존 네트워크·경제·저장 로직은 보존.
5. PC 1920x1080/1280x720, 모바일 가로·세로에서 터치 영역/안전 여백/인벤토리 스크롤/기본 점프 버튼 가림 점검.
6. 로딩/빈 보관함/장착/해제/제작 중/재화 부족/잠긴 월드/밤/재접속 테스트. 화면 상태는 서버 상태를 따름.
7. Claude가 직접 적용한 변경과 테스트를 HISTORY/TODO에 기록. Save/Publish는 별도 사용자 지시 전 하지 않음.

## 참고와 검증 범위
[Pet Simulator 99 공식 Update 99 — Inventory Upgrades](https://www.biggames.io/post/pet-simulator-99-update-99)
[Roblox ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel)
레퍼런스는 구조 참고이며 자산 복사 아님. UI 시트의 문구·숫자·탭·레이아웃은 시각 제안, 새 기능 승인 아님.
현재 게임 수정/이미지 업로드/실제 Play UI 검증 없음.


## 장비 이미지 제작 계약
- 투명 배경 정사각형 PNG, 기본 512px 후보. 같은 시점·광원·여백, 작은 카드에서도 식별 가능한 실루엣.
- 이름·가격·수량·희귀도·장착 체크·잠금·배경 프레임을 이미지에 굽지 않음. Roblox에서 겹쳐 표시.
- 매핑 키는 실제 MissileCatalog/VehicleConfig의 안정적인 장비 ID를 조사해서 사용. 색만 다르게 하지 않고 형태로도 구분.
- 미발견 도감은 같은 이미지의 실루엣/가림 표시, 장착은 테두리/체크, 잠금은 오버레이 처리.
- 실제 아이템 목록 확인과 개별 이미지 생성은 다음 작업. 현재 완료물은 UI 방향 시트와 인수인계임.
