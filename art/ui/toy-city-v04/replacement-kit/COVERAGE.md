# 현재 UI → 교체 이미지 사용표

2026-11-14 Studio Edit StarterGui/StarterPlayerScripts 읽기 전용 조사 기준. 아래는 이미지 적용 계획이며 현재 UI 코드를 바꾼 결과가 아니다.

| 현재 화면/요소 | 사용할 이미지 부품 | 네이티브로 유지할 내용 |
| --- | --- | --- |
| MissileBaseHUD 메뉴/보관함 열기 | blue_normal, icon_missiles, icon_base | 메뉴 이름·키 배지 |
| Popup Inventory 보관함 | modal_blue, card_common~card_cosmic/card_locked, selection_gold, close, equipped, sell, yellow_normal, red_normal | 실제 미사일 그림/ViewportFrame, 이름·등급·가격·장착/판매 상태 |
| Popup Toast 결과/오류 | toast_blue, toast_green, toast_red, check, warning | 서버 결과 문구 |
| ScoutBuggyHUD 탈것 소환 | blue_normal/yellow_normal, icon_garage | 타기/내리기·잠금 상태 |
| Popup Garage 차고 | modal_gold, blue_normal, yellow_normal, icon_garage, lock | 탈것 단계·가격·속도·조건 |
| SalvageHUD 재화 | resource_capsule, icon_coins, icon_research_data | 실제 보유량 |
| Popup PickupNotice 회수 알림 | toast_green/toast_blue, icon_coins/icon_research_data | 획득량·지속 시간 |
| WorldProgressHUD 월드/출격/귀환 | hud_blue, world, icon_base, blue_normal/red_normal, blue_disabled | 월드/구역 이름·완파 수·해금 조건 |
| DayNightHUD 낮밤 | resource_capsule, sun, moon, clock | 실제 서버 시간과 남은 시간 |
| PetMissileHUD 집중 공격 | focus_normal/pressed/disabled, icon_focus, gauge_track, gauge_gold | 실제 충전량·F·사용 가능 상태 |
| Popup FocusHint 집중 공격 안내 | prompt_blue, icon_focus, warning | 조건부 도움말 |
| Popup PromptCard 상호작용 | prompt_blue, keycap_blank, gauge_blue, touch | E/F/G/패드 키·대상·행동·누르기 진행량 |
| PrankPistolHUD 장난 권총 | red_normal/red_pressed/blue_disabled, pistol, check | 장착/해제·키 표시 |
| RaidHUD 공동 레이드 | boss_banner, raid, gauge_track, gauge_red, clock | 보스 이름·HP·시간·기여도·결과 |
| MissileSimulatorHUD 구형 보조 HUD | hud_slate/modal_slate, gauge_blue, blue_normal | 기존 표시를 유지할지 정리할지 적용 단계에서 확인 |
| 연구/상점/도감 확장 창 | modal_blue/gold/red, tab_active/inactive, icon_research/shop/codex, yellow_normal | 기능 구현과 별개인 재사용 이미지. 실제 데이터는 게임 명세에 따름 |

## 적용 순서

1. 기존 UI 구조·서버 Remote 요청을 유지하고 이미지 배경/아이콘만 연결한다.
2. 각 글자·수치·게이지 Fill은 네이티브 TextLabel/Frame로 유지한다. 그림의 버튼 외곽과 터치 hitbox는 분리한다.
3. ImageRectOffset/Size는 manifest/ReplacementAssets.luau의 개별 실측값을 쓴다. 생성 아틀라스는 정확한 등간격 배열이 아니다.
4. 창/버튼 9-slice 경계는 실제 크기에서 확인한다. 카드와 아이콘은 Fit으로 비율 유지, 게이지는 부모 Frame로 잘라 진행량 표시.
5. StarterGui.UIPreview_* 및 팝업 Edit 사본을 함께 갱신하고 RemoveInPlay 규칙을 지킨다.
6. PC/모바일 safe area·한국어 폰트/외곽선·입력 겹침·가격/등급 동적 표시를 검증한다.

이미지나 원래 UI 시트의 예시 수치를 실제 가격·보상·능력치로 적용하지 않는다.
