# Project MS UI v06 — 확정 시안 기반 에셋

이미지 파일 패키지이며 Studio에는 적용하지 않았다. 새 이미지 업로드도 수행하지 않았다.
사용자 지시: 다른 Codex가 Studio 작업 중일 때 이쪽에서 동시에 수정하지 않는다. 적용 전 반드시 사용 상태를 확인한다.

## 구성
- button-backgrounds.png: 파랑/노랑/빨강 원형 3종 + 메뉴 바탕 3종. 집중 발사도 RPG처럼 단일 원형 바탕.
- resource-backgrounds.png: 코인·연구자료용 남색 캡슐 2종. 최신 첨부처럼 얇은 파란 테두리와 가벼운 광택.
- hoverboard.png: 새 타기 아이콘. 노랑 데크·파랑 발판·청록 추진부, 자동차/버기 아님.
- existing-icons/: 기존 메뉴 12종 아틀라스 + RPG 기본/장착/발사 3종. 원본 파일을 그대로 복사, 재생성하지 않음.
- approved-reference.png: 사용자 확정 시트. 시트의 아이콘 세부 차이는 예시이며 이 그림에서 기존 아이콘을 다시 추출하지 않는다.
- manifest.json / measured-bounds.json: 신규9+재사용15 = 24스프라이트, 원본 픽셀 좌표.
- UIAssetPack.luau: 좌표 조회용 사본. 신규 이미지 ID는 공란. 기존 4개 텍스처의 ID·업로드 크기는 기존 연결표 기준.
- preview.html: 실제 원본 아이콘과 새 바탕을 조합한 로컬 미리보기.
- prompts.md: 내장 ImageGen 생성 프롬프트.

## 적용할 때 교체할 항목

| 용도 | 바탕 | 아이콘 |
| --- | --- | --- |
| 집중 발사 | circle_blue | 기존 icon_missiles |
| RPG 장착 | circle_yellow | 기존 rpg / rpg_equipped |
| 모바일 RPG 발사 | circle_red | 기존 rpg_fire |
| 미사일 메뉴 | menu_blue | 기존 icon_missiles |
| 타기 | menu_blue | 새 hoverboard |
| 상점 / 도감(해당 UI 사용 시) | menu_yellow / menu_blue | 기존 icon_shop / icon_codex |
| 코인 | resource_coins | 기존 icon_coins |
| 연구자료 | resource_research | 기존 icon_research_data |

## 적용 담당자 안내
1. 이 폴더의 PNG만 업로드하고 반환 ID 및 실제 다운로드 가로/세로 크기를 기록한다. UIAssetPack.Configure로 둘 다 지정한 뒤 Rect를 얻는다. 원본 좌표를 축소 업로드에 그대로 쓰지 않는다.
2. 기존 UIImages/UIAppearance를 최신 Studio 소스와 대조해 필요한 항목만 교체한다. 이 패키지의 사본으로 게임 모듈 전체를 덮어쓰지 않는다.
3. 바탕·아이콘·글자·키 배지·게이지를 분리한다. 코인/청사진은 캡슐 왼쪽에 일부 걸치게 배치하고, 흰 숫자는 충분한 왼쪽 여백을 둔다. 숫자를 PNG에 굽지 않는다.
4. 원형 바탕은 1:1 버튼에 맞춘다. 아이콘은 Fit. 캡슐은 전체를 과도하게 찌그러뜨리지 않도록 9-slice 후보를 실제 업로드 좌표로 변환해 확인한다. manifest의 후보는 런타임 미검증이다.
5. 현재 HudLayout 기준을 유지한다: 최신 Claude 작업의 좌우 HUD 세로 가운데 정렬, RPG 아래 가운데·숫자1, PC 발사 버튼 숨김, 모바일 장착 중에만 발사 표시. 예전 시트 배치로 되돌리지 않는다.
6. docs/UI_BUTTON_INTERACTIONS.md의 고정 판정 영역/내부 그림만 애니메이션 규칙과 통합한다. 신규 hoverboard는 기본 타기용이며 탑승 중 '내리기'는 같은 보드 + 네이티브 상태표시로 처리한다. 버기 아이콘으로 되돌리지 않는다.
7. UIAppearance의 NoTheme와 Global ZIndex 계층을 보존하고, Edit 미리보기와 PC/모바일 가로·세로에서 실제 크기 검증 후 적용 완료로 기록한다.

## 검증 범위
- PNG 알파·원본 크기, alpha>=32 영역 +2px 좌표, 24개 영역의 이미지 내부 여부 점검.
- 기존 아이콘 4파일은 SHA256 원본 일치 확인.
- 새 이미지 생성은 내장 ImageGen 사용. 기존 PNG 픽셀을 코드로 다시 그리거나 수정하지 않음.
- Studio 접근·소스 변경·Play·업로드·Save/Publish를 수행하지 않음. 신규 ID와 최종 9-slice는 적용 단계에서 확정.
