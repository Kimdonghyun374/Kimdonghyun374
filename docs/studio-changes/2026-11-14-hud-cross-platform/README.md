# HUD 크로스 플랫폼 정리 (2026-11-14 KST, Claude)

게임 Place 122289987934213, Edit. 사용자 요청: 모바일에서 UI가 너무 큼 → PC·모바일 둘 다 맞게, 버튼은 전체적으로 더 크게,
탈것 타기를 인벤토리처럼 작은 아이콘 버튼으로, UI 통일, 권총을 F 버튼 옆으로 + 장착 상태가 보이게,
액션 버튼(권총 발사·특수 스킬)은 PC 왼쪽 아래 / 모바일 점프 버튼 주변.

백업: `ServerStorage.ProjectMSBackups.BeforeHudCrossPlatform_1794654855`
(UIScaleClient·PetMissileClient·SocialClient·ScoutBuggyClient·MissileBaseClient·UIThemeClient·RaidClient·UITheme, StarterGui PrankPistolHUD와 미리보기 4개).

## 바꾼 것

| 대상 | 내용 |
| --- | --- |
| 새 `ReplicatedStorage.PetMissiles.HudLayout` | 화면 짧은 변 기준 배율(PC 600 기준 1.15~1.5배, 모바일 480 기준 0.75~1.1배, 화면 비율 큰 창은 1배 이하)과 버튼 자리 계산. 사본: [HudLayout.luau](HudLayout.luau) |
| `UIScaleClient` | 고정 1.2배 → HudLayout 배율, 화면 크기·기기 바뀌면 다시 계산. PrankPistolHUD·RaidHUD도 포함 |
| `PetMissileClient` | 집중 발사(F) 84→96px, 자리 HudLayout "Focus". 안내 글은 화면 안쪽으로 펼침, F 배지는 PC만 |
| `SocialClient` | 옛 가로 패널(글자 버튼) 숨김 → 동그란 **권총** 버튼(장착 중이면 주황 + "장착 중", 아니면 흰색 + "장착", PC는 G 배지)과 **발사** 버튼(장착 중에만, 화면 가운데로 발사). 화면 클릭·터치 발사는 그대로 |
| `ScoutBuggyClient` | "탈것 타기" 긴 글자 버튼 → 내 미사일 버튼과 같은 64px 아이콘 버튼 + 아래 글자(타기/내리기), 타는 중이면 주황 |
| `MissileBaseClient` | 내 미사일 버튼 56→64px + 아래 글자 "미사일", 자리 HudLayout |
| `UITheme` | SummonBuggy 아이콘 자동 부착 항목 제거(버튼이 직접 아이콘을 만듦) |
| StarterGui 미리보기 | UIPreview_PetMissileHUD·PrankPistolHUD·MissileBaseHUD·ScoutBuggyHUD를 새 PC 배치로 |

### 자리
- **PC**: 왼쪽 아래 가로 한 줄 `[F 집중 발사] [권총] [발사]`. 오른쪽 위 메뉴 줄 `[미사일] [타기]`.
- **모바일**: 점프 버튼 왼쪽 = F, 위 = 권총, 왼쪽 위 대각선 = 발사. 점프 버튼 실제 위치(TouchGui)를 읽고, 없으면 Roblox 기본 위치로 짐작.
- 시험용 속성: LocalPlayer `HudForceTouch`(bool)·`HudForceViewport`(Vector2)로 기기·화면 크기를 흉내 낼 수 있음.

## 검증 (Play 1인)
- PC(뷰포트 1918×1080): 배율 1.5, F 144px·권총 117px 왼쪽 아래, 미사일·타기 오른쪽 위 96px, 겹침 없음. 화면 캡처 확인.
- 권총: 버튼 클릭으로 장착(주황 "장착 중"), 해제 시 흰색 "장착"·발사 버튼 숨김. 발사 버튼 클릭 → 서버 궤적 수신 1, 화면 클릭 → 2. 콘솔은 기존 203785492 경고만.
- 모바일 흉내(HudForceTouch + 844×390): 배율 0.81, F·권총·발사가 점프 자리 주변에 겹침 없이 배치. **실제 휴대폰·Studio 기기 에뮬레이터·실제 TouchGui 점프 버튼 위치로는 미확인.**
- Edit 미리보기 화면 확인, 열린 탭 16개 편집기=Source. Save/Publish 안 함.

## 추가 수정 (같은 날)
- 2026-11-14 추가 수정(사용자: "모바일에서 엄청 겹침", 실행해도 큼): 원인 ① Studio 기기 에뮬레이터는 터치+키보드가 둘 다 켜져 있어 PC로 판정 → 최소 1.15배. ② 월드 패널(위 140)과 코인 패널(가운데 고정)이 작은 화면에서 겹침. 수정: HudLayout 모바일 판정을 "터치 + (키보드 없음 또는 점프 버튼 있음 또는 짧은 변 520 이하)"로, 모바일 배율 0.65~1.1(520 기준)·PC 1.0~1.5, 왼쪽 패널 줄(LeftWorld→LeftResources)을 실제 크기 기준으로 위아래로 붙임, 메뉴 줄 시작 높이 모바일 60. UIScaleClient가 두 패널 자리 등록. Edit 미리보기 두 패널 위치도 맞춤.
- 검증: 에뮬레이터 Play(749×381, 터치+키보드) → 모바일 판정·배율 0.73, 모든 HUD 요소 좌표 겹침 없음, 점프 버튼(654,233 70×70) 왼쪽 F·위 권총·대각선 발사 캡처(mobile-emulator-749x381.jpg). PC는 이번 수정 뒤 다시 실행하지 않음(배치 로직은 그대로, 최소 배율만 1.15→1.0, 왼쪽 패널 붙이기 추가).
