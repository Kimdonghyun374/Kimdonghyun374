# 모바일 UI 수정 준비 (2026-11-14 KST, Claude)

상태: **계획만. 아직 고치지 않음.** Codex가 그래픽 개선 중이며 같은 UI 스크립트를 만지고 있어
(ServerStorage 백업 `BeforeToyCityVisuals_1794646284`에 MissileBaseClient·PromptClient·UIScaleClient·
PetMissileClient·ScoutBuggyClient 포함), **Codex 작업이 끝나고 커밋된 뒤** 착수한다.

근거: Studio Place 122289987934213 스크립트를 읽기만 해서 확인(Codex가 Play 중이라 실행·화면 캡처는 안 함).
사용자 보고: "모바일 창 화면으로 보면 UI가 다 뭉개진다".

## 1. 원인 (코드 확인)

| # | 원인 | 위치 |
| --- | --- | --- |
| 1 | HUD 크기가 **픽셀 고정(Offset)** 이고, 화면 크기와 상관없이 **전부 1.2배**로 키움. 폰 가로 화면은 대략 650~930 × 340~430 px라 PC 기준 배치가 들어가지 않음 | `UITheme.HudScale = 1.2`, `UIScaleClient` |
| 2 | UIScale을 HUD **맨 위 요소마다 따로** 붙여서 각자 자기 기준점에서 커짐 → 작은 화면에서는 이웃 요소와 겹침 | `UIScaleClient.scaleElement` |
| 3 | 터치 화면 분기가 거의 없음: 집중 발사 패널 높이(-140)와 탈것 버튼 숨김 2곳뿐. Roblox 기본 조이스틱(왼쪽 아래)·점프 버튼(오른쪽 아래)·위쪽 메뉴/채팅 영역을 피하는 배치 규칙이 없음 | `PetMissileClient:132`, `ScoutBuggyClient:207` |
| 4 | 키 안내 배지(F·E·G 등)가 터치에서도 자리를 차지 | `PetMissileClient`, `PromptClient`, `MissileBaseClient` |
| 5 | RaidHUD 등 나중에 생긴 화면은 배율 목록(`SCALED_GUIS`)에 없어 다른 HUD와 크기 기준이 다름 | `UIScaleClient.SCALED_GUIS` |

## 2. 고치는 방법 (순서대로)

1. **측정 먼저**: Studio 기기 에뮬레이터로 3가지 화면(작은 폰 가로 667×375, 큰 폰 가로 844×390, 태블릿 1024×768)에서
   HUD별 겹침·잘림 목록과 스크린샷을 남긴다. 고친 뒤 같은 조건으로 비교.
2. **화면 기준 배율**: 고정 1.2 대신 화면 짧은 변 기준으로 계산
   (예: `배율 = clamp(짧은변 / 720 × 1.2, 0.7, 1.2)`), `ViewportSize`가 바뀌면 다시 계산. 수치는 측정 후 결정.
   단 버튼은 배율 적용 후에도 **최소 44px** 이상(손가락 크기).
3. **화면 구역 정하기** (`UITheme`에 한곳에서 정의):
   - 왼쪽 위: 코인·연구자료 / 가운데 위: 레이드·알림 / 오른쪽 위: 메뉴 버튼
   - 가운데 아래: 장착·집중 발사 / **왼쪽 아래 조이스틱 자리·오른쪽 아래 점프 자리는 비움**
   - 노치·홈 표시줄은 `ScreenGui.ScreenInsets`(DeviceSafeInsets/CoreUISafeInsets)로 피함
4. **모바일 전용 정리**: 터치에서는 키 배지 숨김, 자주 안 쓰는 패널(보관함·차고·연구 등)은 메뉴 버튼 하나로 접기,
   집중 발사 버튼은 점프 버튼 위 엄지 닿는 곳.
5. **팝업 창**: 보관함·차고·연구·제작대 등급 창을 화면 비율 크기 + `UISizeConstraint`(최대·최소) + 스크롤로.
6. **글자**: 크기를 배율에 맞추고 너무 작아지지 않게 하한(약 12~14px). `TextScaled`를 쓰면 `UITextSizeConstraint` 함께.
7. **Edit 미리보기 유지**: StarterGui `UIPreview_*` 사본도 같이 갱신(기존 규칙).

검증: 에뮬레이터 3가지 화면 전·후 스크린샷, PC 화면이 나빠지지 않았는지, 실제 폰 1대 이상(사용자).

## 3. 한국어 폰트 점검

- 이 PC의 Roblox 설치본(`version-4ea8e85481e34f46`)의 기본 글꼴 43종 중 **한글이 들어 있는 것은
  `NotoSansCJK Fallback` 하나, 굵기는 Regular(400) 한 가지뿐**이다. Gotham·BuilderSans·FredokaOne 등은 한글이 없다.
- 지금 게임 글자는 전부 `Enum.Font.Gotham/GothamBold/GothamBlack`. 한글은 이 글꼴에 없어서 **모두 같은 대체 글꼴(보통 굵기)로 나온다**.
  즉 GothamBold·Black을 지정해도 **한글은 굵어지지 않고 영어·숫자만 굵어진다**(파일 구성으로 추정, 화면 비교는 아직 안 함).
- 선택지:
  1. 기본 글꼴 유지 + 강조는 `UIStroke`(외곽선)·크기·색으로. 비용 거의 없음. **우선 추천.**
  2. 제목·로고·큰 버튼처럼 **글자가 정해진 곳만 이미지 글자(PNG)**. 장난감 스타일을 살리기 좋지만 글자를 바꿀 때마다 다시 만들어야 함.
  3. 숫자·영어만 장난감 느낌 글꼴(예: FredokaOne, LuckiestGuy)로 바꾸고 한글은 대체 글꼴 그대로.
  4. 직접 한글 글꼴 올리기: Roblox가 지금 사용자 글꼴 업로드를 허용하는지 **확인하지 못함**. 착수 전 Creator Hub 문서로 확인 필요.
- 확인할 것: Studio에서 같은 한글 문장을 Gotham / GothamBlack / BuilderSans Bold로 나란히 띄워 굵기 차이가 실제로 없는지 화면으로 확인.
