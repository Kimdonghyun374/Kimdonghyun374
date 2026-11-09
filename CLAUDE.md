# ProjectMS (프로젝트MS) — Claude 인수인계

작성: 2026-11-03 KST, Claude Code (Windows `DESKTOP-RLF93FA`, 작업 폴더 `C:\ProjectMs`)
출처: Codex 프로젝트 미러 `C:\Users\USER\.codex\.chatgpt-projects\g-p-6ac3c11c5bb48191bf25e3ca5623ab52`
(ChatGPT 프로젝트 "미사일시뮬레이터"). 아래 내용은 그곳의 `agent.md`, `HISTORY.md`,
`MAC_HANDOFF_2026-11-03.md`, `outputs/gdd-v02/*`를 읽고 정리한 것이며,
**이번 Claude 세션에서 게임을 실행하거나 Studio에 연결해 검증한 결과가 아닙니다.**

## 1. 작업 규칙 (Codex `agent.md` 계승)

원문은 저장소 루트의 [agent.md](agent.md)에 있다 (Claude·GPT 등 모든 에이전트 공용). 아래는 요약이며, 충돌하면 agent.md 원문을 따른다.

- 한국어로 소통한다.
- 작업 시작 시 실제 실행 컴퓨터(hostname)와 절대 프로젝트 경로를 확인한다. 과거 경로를 현재 경로로 추정하지 않는다.
- 기존 파일과 사용자 변경을 보존한다. 오래된 사본으로 덮어쓰지 않는다.
- 작업 후 history 파일에 KST 날짜·목적·변경 파일·검증 결과·남은 작업을 누적 기록한다.
- 실제 검증 결과와 전달받은 과거 이력을 구분한다. 실행하지 않은 테스트를 성공으로 기록하지 않는다.
- 비밀번호·토큰·API 키·실제 플레이어 데이터를 기록하지 않는다.
- Roblox Studio 연결과 Rojo 매핑은 실제 작업 환경에서 확인한다.
- Studio Save/Publish는 사용자 지시 없이 하지 않는다 (지금까지 한 번도 수행되지 않음).
- 코드 가독성: 한 줄 한 동작, 의미 있는 이름(한 글자 변수 지양), 책임별 함수 분리,
  서비스→설정·상태→보조 함수→주요 기능→이벤트 연결 순서, 의도를 설명하는 간결한 한국어 주석.
  공개 함수·RemoteEvent·모델 이름을 바꾸면 사용처를 모두 확인한다.
- Codex 미러의 `sources/`는 읽기 전용이다.

## 1-1. Git 동기화 규칙 (사용자 지시, 2026-11-03)

원격: `origin` = https://github.com/Kimdonghyun374/Kimdonghyun374 (공개), 브랜치 `main`. 여러 컴퓨터(Windows/Mac)에서 작업할 수 있으므로:

- **작업 시작 전 항상**: `git fetch` → `git status -sb`로 받을 것/올릴 것 확인. 원격이 앞서 있으면 `git pull --ff-only` 후 작업. 로컬에 미커밋·미푸시 변경이 있으면 먼저 사용자에게 알린다.
- **커밋 시점**: 요청 하나(작업 단위)가 끝나고 HISTORY.md 기록까지 마친 뒤 한 번. 검증 실패·작업 중간 상태는 커밋하지 않는다. 서로 다른 작업은 커밋을 나눈다.
- **푸시 시점**: 커밋 직후 바로 푸시 (다른 컴퓨터와 갈라지지 않게). 푸시 실패(원격 앞섬)면 강제 푸시하지 말고 pull 후 다시.
- 세션을 끝낼 때 미커밋 변경이 남아 있으면 알린다.
- `*.rbxl`/`*.rbxlx`는 올리지 않는다 (Part_Icles 재배포 금지). 비밀값·실제 플레이어 데이터도 금지.
- 이 세션처럼 PATH에 git이 없으면 `C:\Program Files\Git\cmd\git.exe` 전체 경로 사용.

## 2. 위치 정리

| 구분 | 경로 | 비고 |
| --- | --- | --- |
| Claude 작업 폴더 | `C:\ProjectMs` | 현재 `Copy\asd.rbxl`(578 KB, 2026-10-29) 하나만 있음. 내용 미확인 |
| Codex 미러(Windows) | `C:\Users\USER\.codex\.chatgpt-projects\g-p-6ac3c11c5bb48191bf25e3ca5623ab52` | HISTORY.md, agent.md, outputs/ |
| Mac 실제 개발 폴더 | `/Users/dongdong/Documents/ChatGPT/ProjectMS` (`dongdong-ui-MacBookPro.local`) | 로컬 `src/`, 설치기, 테스트, verification/ 원본은 여기에만 있음 |
| Roblox Place | **122289987934213** (연결 이름 `프로젝트MS`, game.Name `Place1`, gameId 10767294709) | 최종 적용·검증 Place. 134593398924034에도 일부 적용 이력 → 혼동 주의 |
| 과거 로그 | `C:\RobloxDD\DEVELOPMENT_LOG.md` | 존재 시 보존 |
| Notion | 워크스페이스 `개인창고`, 상위 페이지 [미사일 시뮬레이터 DRAFT](https://app.notion.com/p/0608abb5061282f8a62e81a77697ea61) | 하위: [게임 기획서 v0.1](https://app.notion.com/p/1df8abb506128308bf4f819dc005a839), [기획서 목차](https://app.notion.com/p/9fd8abb5061282c08d76019f7993a75b), [개발 계획](https://app.notion.com/p/04f8abb5061282c486bb81e5d58db4f8). Claude 커넥터로 연결됨. 무료 블록 한도로 새 페이지 생성이 막힐 수 있음 |
| 구글 시트 | `MS_MASTER` (데이터 기준표, 링크는 사용자에게 받음) | README 탭에 규칙. 사용자 탭(PLAYERDATA·MISSILES·InfrastructureLevel·시트4)은 AI가 덮어쓰지 않음. 값 변경 → "시트 반영" 요청 시 Studio에 옮김. Claude 커넥터(Google Sheets)로 연결됨 |

Windows에는 Mac의 `src/`·설치기·패키지가 복사되지 않았다. 현재 Windows에 있는 코드 사본은
`outputs/gdd-v02/source/` 47개(2026-11-03 Studio와 길이·지문 대조, **정적 분석용 — 수정해도 Studio 반영 안 됨**)뿐이다.
진실의 원천은 **Studio Place 122289987934213의 Edit DataModel**이다.

## 3. 게임 현재 상태 (Mac 최종 2026-10-29 기준)

핵심 루프: 기지 차지 → 부품으로 미사일 제작 → 장착 → 자동 공격/집중 발사로 개인 도시 파괴 → 부품·연구자료 회수 → 재제작.

- **전투** (`ReplicatedStorage.PetMissiles.Config`, `ServerScriptService.PetMissiles.Service`):
  슬롯 Min/Max 10 (사용자 설정, 보존), 자동 탐색 1.6초, 연사 0.1초, 슬롯 재장전 3초, 사거리 90, 기본 피해 15.
  클릭/터치로 목표 선택, F 또는 버튼으로 집중 발사. 서버가 대상·거리·Raycast·피해를 검증.
- **기지/제작** (`BaseConfig`, `BaseDomain`, `BaseService`, `BaseWorld`):
  `Workspace.ProjectMS_Bases` Base_1~6 링 광장 60° 배치(2026-11-10, PlotCount 6, 서버 정원 목표 6. 처음 8에서 축소), 1인 1기지. 제작비 부품 20, 5초 후 지급, 완료 후 2초 쿨다운,
  시작 부품 20개 1회. 희귀도 60/25/10/4/1%, 피해 배율 1/1.3/1.8/2.5/4. 보관함 100칸(초과 정리 기능 없음).
- **도시 파괴/회수** (`SalvageService/Rules`, `SalvageClient`, `BuildingCollapse`):
  피해 기여도로 잔해 분배, 개인 드롭, 수집거리 8, 90초 만료, 연구자료 15%. 정육면체 붕괴 연출(클라이언트 전용).
  최신 변경: SalvageClient 이름표(110stud AlwaysOnTop)·Highlight 24개·연구자료 빛기둥·획득 알림 1.8초·효과음.
- **월드 진행** (`WorldConfig`, `ProgressionRules/Service`, `WorldProgressClient`):
  개인 도시, 공유 낮 180초/밤 25초(밤엔 공격 거절, 새 낮에 수리). 1월드 HP 배율 0.25, 완파 시 Win+1,
  Win1 + 1월드 완파 1회로 2월드 해금(소비 없음). 각 월드 건물 4개.
- **맵 (2026-11-09 Claude 적용)**: 링 광장(반지름 108, 가운데 공동 레이드 자리 반지름 60) + 큰 기지 6개 80×110(60° 간격)(제작 라인·전시장·기지 차고·AFK 연구 자리, 기지 차고만 작동) + 기지별 진격 대로 `Workspace.ProjectMS_Lanes.Lane_1~6`(d 225~1140).
  월드1 개인 도시는 `Lane_N.Entry` 기준으로 자기 기지 대로에 복제(템플릿 `ProjectMS_City`는 Lane_1 좌표로 편집).
  기지 없으면 월드1 도시 없음. 구역2·3은 바닥·표지만. UI는 `UITheme`+`UIThemeClient`로 v03 밝은 테마. 월드2는 X+1720 섬, TravelRoad는 백업으로 이동.
  상세: `docs/LEVEL_DESIGN_v0.3.md`.
- **정찰 버기** (`Vehicle*`, `ScoutBuggyClient`): 부품 50 구매, 100/200 업그레이드, 속도 32/44/58,
  1인 1대, 재호출 5초, WASD/E, 월드 이동 시 하차. 템플릿 `ServerStorage.ProjectMS_VehicleTemplates.ScoutBuggy`.
- **저장**: ProfileStore, 저장소 `ProjectMS_ManualBases_v1`. Studio에서는 Mock만 검증됨.
- **백업**: 변경 때마다 `ServerStorage.ProjectMSBackups.Before*_<timestamp>`에 원본 보관. 옛 MissileSimulator 코드는 Disabled 상태로 보존.

## 4. 미검증 / 남은 일

- 게시 서버 실제 저장·재접속·강제 종료, 실제 2클라이언트 이상, 모바일 실기기, 효과음 청취, 루트 이름표 최종 픽셀 표시.
- Save/Publish 미실행.
- 보관함 100칸 초과 처리, ResearchData 소비처, 레벨 기반 슬롯 해금 없음.
- v0.2 기획서(`outputs/gdd-v02/GDD_v0.2.md`, `LEVEL_DESIGN_v0.2.md`, `CODE_ANALYSIS.md`)의 새 수치·도시 구조·보스·3월드는 **제안이며 미구현**.
  2026-11-03 Claude가 Notion `미사일 시뮬레이터 DRAFT` 아래에 3개 페이지로 업로드함 (HISTORY.md 참고).
- 2026-11-09 v0.3 문서: `docs/GDD_v0.3.md`, `docs/LEVEL_DESIGN_v0.3.md` (Notion의 v0.2 두 페이지를 v0.3으로 갱신).
  다음 후보는 LEVEL_DESIGN_v0.3 15절(B0 기록, 6명 대비 비행·드롭 상한(검토 완료), 신규 이용자 테스트). 서버 정원 6은 사용자가 게시 설정에서 변경해야 함.
- Codex 미러 `outputs/studio-audit/REVIEW_KO.md`에 2026-10-26 코드 감사 결과(정원 60/기지 6, 10슬롯 설정과 기존 테스트 불일치 등)가 있음.

**현재 할 일의 기준 목록은 [TODO.md](TODO.md)** (모든 에이전트 공용). 작업을 맡거나 끝내면 TODO.md도 갱신한다.

## 5. Claude에서 이어갈 때 먼저 할 것

1. `hostname`과 실제 경로 확인, 사용자가 어느 컴퓨터에서 Studio를 여는지 확인.
2. Roblox Studio MCP가 이 세션에 연결돼 있는지 확인 (현재 Claude 세션 도구 목록에는 없음 → 연결 필요).
3. 연결되면 Place 122289987934213 Edit 상태와 소스를 읽고, `outputs/gdd-v02/source/`와 대조해 이후 변경 여부 확인.
4. 수정 전 ServerStorage 백업 → 적용 → Play 검증 → Edit 복귀·임시 러너 제거 확인 → 기록.
5. 기록은 `C:\ProjectMs\HISTORY.md`에 남기고, 필요 시 Codex 미러 HISTORY.md에도 병합(덮어쓰기 금지).
