# UI 이미지 연결·레이아웃 재점검 — 2026-11-14 KST

- 실행: DESKTOP-RLF93FA, C:\ProjectMS. Studio Place 122289987934213 Edit가 기준.
- 시작 커밋: ac15f56 (작업 선점), Claude 이미지 1·2차 적용본 보존.
- 백업: ServerStorage.ProjectMSBackups.BeforeUIReview_1794662859. 원본 UI 스크립트·StarterGui 보관.
- Save/Publish 미실행. 완료 후 Edit 복귀.

## 변경
- 새 UIAppearance 모듈과 얇은 UISkinClient: Play/Edit가 같은 이미지·여백·레이어 규칙 사용.
- 어두운 재화 캡슐/낮밤 표시의 글자를 흰색으로, 연구자료는 기존 청사진 아이콘 유지. NoTheme 요소에 기존 테마가 재차 어두운 글자색을 덮지 않게 수정.
- Global ZIndex에서 부모 바탕이 버튼·체력 게이지를 가리던 순서 수정. 긴 버튼 normal/pressed/disabled 아틀라스, 닫기 이미지, 보스 게이지, 토스트 연결.
- 집중 발사: 세 미사일 아이콘 + 짧은 이름 + 충전 게이지. RPG 장착은 노랑, 모바일 발사는 빨강. PC 발사 버튼은 숨김 유지, G/클릭 조작 유지.
- PC 배율 0.9~1.25(짧은 변/800), 오른쪽 메뉴 높이72·왼쪽 재화82. 모바일 배율은 기존 짧은 변/520 유지, 재화110으로 CoreGui 공간 확보.
- 세로 모바일은 낮밤60·레이드는 재화 아래로 내려 위쪽 메뉴와 겹치지 않게 함. 화면 회전 시 갱신.
- 보관함/차고는 HUD 배율 중복 적용 없이 실제 화면 여백으로 크기 결정. 헤더·내용·목록 간격 재배치, 희귀도 확률의 밝은 글자 대비 보정.
- 닫기44×44, 장착/판매44 높이, 커먼 판매40 높이. 기존 구매/판매/장착 판정은 변경하지 않음.
- StarterGui 미리보기14개 EditPreviewOnly·RemoveInPlay 유지, 메인/팝업 이미지 갱신. 제거된 월드 패널은 되살리지 않음. 관리자 흑백 UI 보존.

## 검증
- 실제 Studio Play: PC 1918×1080, 기기 에뮬레이터 가로749×381, 세로400×776에서 주요 HUD 좌표 점검. 보고된 겹침/화면 이탈0. CoreGui와의 배치는 native 화면도 확인.
- 모바일 RPG G 해제: fireVisible=false / RPG 글자, 재장착: rpg_equipped 이미지·fireVisible=true. 모바일 F/G/B 배지 숨김 확인.
- 보관함 열기/닫기(B), 이미지 표시와 목록 높이(가로133px, PC/세로296px) 확인. 동적 플레이어 데이터/게임 경제 값은 수정하지 않음.
- 실제 레이드 예고(StartWarningNow) 및 Active 배너·금색 체력 채움 화면 확인.
- 최종 44×44 닫기·버튼/낮밤 아틀라스 ID 확인. Play에서 UIPreview 사본0.
- 모든 수정 소스 UpdateSourceAsync + Source, 종료 시 열린 편집기 불일치0. 임시 미리보기 모듈 제거.
- 새 Play 오류 없음. 기존203785492 타입 불일치 경고만 남음.

## 검증 한계 / 다음
- 실제 휴대폰 터치·게임패드 조작·2인 RPG 명중·게시 저장은 검증하지 않음.
- 탈것 버튼의 기본/내리기 이미지 매핑은 기존 연결 유지; 실제 구매·탑승 전환은 이번에 수행하지 않음.
- 희귀도 카드/탭 기반 보관함으로 구조 변경하지 않음. 현재 목록형 UI 유지.
- CheckLayout.client.luau와 JSON은 실제 세션 확인용 기록이며 자동 CI 테스트가 아님. TouchGui의 서로 다른 inset 원점은 native 시각 확인을 함께 사용.


## 공용 문서 반영
- MS_MASTER README A40:B42 업데이트·값/줄바꿈 메타데이터 재읽기 완료. Google Sheets 자체 native 렌더의 행 높이/맞춤은 미검증.
- 기존 Notion 게임 기획서·레벨디자인 상단에 UI 구현 리뷰 추가 성공(경고 없음).
- Studio 소스7개와 사본의 UTF8 길이/base31 해시 일치 확인.
