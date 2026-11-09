# 작업 기록 (Claude)

시간 기준 KST. 2026-11-03 이전 이력은 `C:\Users\USER\.codex\.chatgpt-projects\g-p-6ac3c11c5bb48191bf25e3ca5623ab52\HISTORY.md` 참고.

## 2026-11-03 — Codex → Claude 인수인계 시작
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMs`.
- 목적: Codex 프로젝트 미러의 agent.md, HISTORY.md, MAC_HANDOFF_2026-11-03.md, outputs/gdd-v02 문서를 읽고 Claude용 인수인계 작성.
- 변경 파일: `C:\ProjectMs\CLAUDE.md`, `C:\ProjectMs\HISTORY.md` 신규 생성. Codex 미러, 게임 코드, Studio는 변경하지 않음.
- 검증: 문서 읽기만 수행. Studio 연결·Play·테스트는 실행하지 않음. `C:\ProjectMs\Copy\asd.rbxl` 내용은 확인하지 않음.
- 남은 작업: Roblox Studio MCP를 Claude 세션에 연결, Place 122289987934213 현재 소스 대조, 다음 작업 선정.

## 2026-11-03 — Claude Code에 Roblox Studio MCP 등록
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMs`.
- 배경: Studio의 MCP 빠른 연결 목록에 Claude Code가 나타나지 않음(정해진 클라이언트만 감지). 수동 등록으로 대체.
- 변경 파일: `C:\ProjectMs\.mcp.json` 신규(서버 이름 `Roblox_Studio`, `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat`). Codex config.toml과 같은 실행기를 사용하며 Codex 설정은 변경하지 않음.
- 검증: 같은 명령으로 StudioMCP를 직접 실행해 initialize 응답(serverInfo RobloxStudio 1.0.0) 확인. RobloxStudioBeta 프로세스 실행 중 확인. Claude 세션에 도구가 노출되는지와 Place 조회는 세션 재시작 후 확인 필요(미검증).
- 남은 작업: 새 세션에서 .mcp.json 서버 승인 → list_roblox_studios / get_studio_state로 Place 122289987934213 확인.

## 2026-11-03 — 새 세션에서 Studio MCP 연결 확인
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMs`.
- 검증(실제 실행): Claude 세션에 Roblox_Studio 도구 노출됨. list_roblox_studios → 1개, "프로젝트MS (placeId: 122289987934213)". get_studio_state → Edit 모드, DataModel Edit만 존재.
- 변경: Studio·게임 코드 변경 없음. 이 기록만 추가.
- 남은 작업: Place 소스를 `outputs/gdd-v02/source/` 47개와 대조해 이후 변경 여부 확인, 다음 작업 선정.

## 2026-11-03 — Studio 소스와 Codex 사본 47개 대조
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 대상: Place 122289987934213, Edit DataModel (읽기 전용 execute_luau).
- 방법: 각 LuaSourceContainer.Source의 바이트 길이 + base31 mod 2147483647 지문. 로컬 사본은 UTF-8 BOM 제거, CRLF→LF, **끝 개행 유지**(Studio Source에도 끝 개행이 있음) 후 같은 지문 계산.
  스크립트: 세션 scratchpad `local_fingerprints.ps1` (프로젝트에 저장하지 않음).
- 결과(실제 실행): 게임 코드 47개 모두 길이·지문 일치 → 사본 작성 이후 Studio 변경 없음.
  Studio 전체 302개 = 게임 코드 47 + `ReplicatedStorage.Part_Icles` 외부 모듈 164 + ServerStorage 보관본 91(MissileSimulatorAssets 22, ProjectMSBackups 69). Codex README의 302/164/91 집계와 동일.
  Disabled: `ServerScriptService.MissileSimulator.Controller`, `StarterPlayer.StarterPlayerScripts.MissileHUD`, `MissileVisualClient` (옛 MissileSimulator 보존 상태 그대로).
  Part_Icles(Qwinkle 라이선스: 재배포 금지, 수익화 시 크레딧)는 게임 코드 어디에서도 참조되지 않음.
- 참고: Codex `source-comparison.json`의 MissileConfig·SalvageClient `match:false`는 끝 개행 처리 차이로 보이며, 이번 대조에서는 둘 다 일치.
- 변경: Studio·게임 코드 변경 없음. 이 기록만 추가.
- 남은 작업: 다음 작업 선정 (후보: LEVEL_DESIGN_v0.2 13절 "바로 시작할 작업 3개", 보관함 100칸 초과 처리 등).

## 2026-11-03 — Claude 세션 Notion 연결 확인
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMs`.
- 검증(실제 실행): Notion 커넥터 get-self → 워크스페이스 `개인창고`, 사용자 본인 계정. 검색으로 `미사일 시뮬레이터 DRAFT` 아래 `게임 기획서 v0.1`·`기획서 목차`·`개발 계획` 확인.
- 참고: Codex CODE_ANALYSIS.md의 v0.1 링크 ID(4044227f…)는 이번 검색 결과 ID(1df8abb5…)와 다름. 같은 문서인지 미확인.
- 변경: CLAUDE.md 위치 표에 Notion 항목 추가, 이 기록 추가. Notion 페이지는 생성·수정하지 않음.
- 남은 작업: v0.2 문서 3개(`outputs/gdd-v02/notion-import/`) Notion 업로드는 블록 한도 확인 후 사용자 지시 시 진행.

## 2026-11-03 — v0.2 문서 3개 Notion 업로드
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 사용자 지시("올려줘")로 진행.
- 원본: Codex 미러 `outputs/gdd-v02/notion-import/` CODE_ANALYSIS.md, GDD_v0.2.md, LEVEL_DESIGN_v0.2.md (원본 파일은 수정하지 않음).
- 생성(실제 실행, 오류·경고 없음): `미사일 시뮬레이터 DRAFT` 하위
  - [프로젝트MS 코드 분석 — v0.2 기획 근거](https://app.notion.com/p/40c8abb506128120b46bff60d5f6f7c1)
  - [게임 기획서 v0.2](https://app.notion.com/p/40c8abb506128166ba6cf47fe0f2d745)
  - [레벨디자인 실행안 v0.2](https://app.notion.com/p/40c8abb5061281228d59de6d5b9e02bc)
- 변경점: 원문의 옛 워크스페이스 링크(v0.1 4044227f…, 프로젝트 3a74227f…)를 현재 워크스페이스 페이지(v0.1 1df8abb5…, DRAFT 0608abb5…) 멘션으로 교체. 문서 간 로컬 .md 링크는 새 페이지 멘션으로 바꿔 각 페이지 맨 위에 추가. 본문 내용은 그대로.
- 이번에는 블록 한도 거절 없음. 기존 v0.1·목차·개발 계획 페이지는 수정하지 않음.
- 남은 작업: 사용자가 Notion에서 표·코드 블록 표시 확인.

## 2026-11-03 — GitHub 저장소 업로드
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 대상: https://github.com/Kimdonghyun374/Kimdonghyun374 (빈 공개 저장소, main 브랜치).
- 준비: Git 미설치 → 사용자 승인으로 `winget install Git.Git`(2.56.0.4) 설치. `C:\ProjectMs`를 git 저장소로 초기화, 저장소 로컬 user.name `Kimdonghyun374`, email `Kimdonghyun374@users.noreply.github.com`(실제 이메일 비공개).
- 제외: 사용자 선택으로 `.gitignore`에 `*.rbxl`, `*.rbxlx` 추가 → `Copy\asd.rbxl` 미업로드 (Part_Icles 재배포 금지 라이선스).
- 커밋 d0cdddb: `.gitignore`, `.mcp.json`, `CLAUDE.md`, `HISTORY.md`. 사용자가 터미널에서 브라우저 GitHub 로그인 후 push 성공. `git ls-remote`로 원격 main = d0cdddb 확인.
- 이 기록은 이후 커밋 6387f2a로 푸시함.

## 2026-11-03 — Mac에서 GitHub 저장소 pull
- 실행 컴퓨터: Mac `dongdong-ui-MacBookPro.local`. 작업 폴더: `/Users/dongdong/projectMS`.
- 작업: 빈 폴더를 git 저장소(main)로 초기화하고 origin `https://github.com/Kimdonghyun374/Kimdonghyun374.git` 연결 후 `git pull origin main` → 6387f2a까지 받음.
- 참고(실제 확인): Mac 개발 폴더 `/Users/dongdong/Documents/ChatGPT/ProjectMS` 존재(src/, tests/, studio/, verification/, history.md 등). 이번 작업에서는 읽기·수정하지 않음.
- 참고: Claude Code 사용자 설정에 `Roblox_Studio`(`/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`)를 등록함. 저장소의 `.mcp.json`은 Windows 전용(`cmd.exe`) 명령이라 Mac에서는 실행되지 않으며, 같은 이름으로 사용자 설정을 가릴 수 있음(미검증).
- 저장소 공개 여부: GitHub API 기준 `private: false` (공개).
- 변경(사용자 지시): `.mcp.json`을 저장소에서 제거(`git rm`, Mac 로컬 파일도 삭제)하고 `.gitignore`에 `.mcp.json` 추가. 이전 내용은 git 기록 d0cdddb에 남아 있음.
- ⚠️ Windows에서 이 변경을 pull하면 `C:\ProjectMs\.mcp.json`이 삭제됨 → 그 전에 같은 내용(`cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat`)을 Windows Claude Code 사용자 설정(`claude mcp add --scope user ...`)으로 옮겨야 Studio MCP가 유지됨.
- 이 기록과 위 변경은 아직 커밋·푸시하지 않음.

## 2026-11-03 — Windows에서 Mac 변경 반영 및 agent.md 공유
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMs`.
- Git 동기화 규칙 추가(CLAUDE.md, 커밋 6fba16d). 첫 push가 Mac 커밋 32dd27b 때문에 거절됨 → `.mcp.json`을 세션 scratchpad에 백업 후 `git pull --rebase`, pull로 삭제된 `.mcp.json`을 복원. 현재 Windows `.mcp.json`은 로컬 전용(.gitignore 대상)이며 Studio MCP 설정 유지. 사용자 설정으로 옮기지는 않음.
- 사용자 지시(다른 AI 에이전트도 함께 작업): Codex 미러의 `agent.md` 원문을 그대로 `C:\ProjectMs\agent.md`로 복사(SHA256 일치 확인). 원본은 그대로 둠.
- 변경 파일: `agent.md`(신규), `CLAUDE.md`(agent.md 위치 안내), `HISTORY.md`.
- 검증: 작업 전 fetch → 원격 변경 없음 확인.

## 2026-11-09 — 링 광장 + 기지별 진격 대로 그레이박스, 서버 8명 기준, v0.3 문서
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMs`. 대상: Studio Place 122289987934213 (Edit).
- 목적(사용자 지시): 서버 정원 8명으로 정하고, 기존 에셋으로 "링 광장 + 기지별 진격 대로" 구조를 Place에 그레이박스로 적용, 기획서 갱신.
- 작업 전: git fetch → 원격 변경 없음. 수정 대상 4개 스크립트 지문이 11-03 대조값과 같음을 확인.
- 백업: `ServerStorage.ProjectMSBackups.BeforeRingPlaza_1794155422` (ProjectMS_Bases, ProjectMS_City, ProjectMS_Worlds, ProjectMS_Garage, SpawnLocation, Baseplate, pixel_missile, ProgressionService, BaseService, BaseConfig, WorldConfig 복제본 + 원본 TravelRoad 이동 보관).
- Studio 배치 변경: Baseplate 2048×2048. Base_1~8을 반지름 72 링에 45° 간격·발판이 중심을 향하게 배치(Base_7·8은 Base_1 복제). 새 폴더 `ProjectMS_Lanes`(PlazaFloor + Lane_1~8: Road d88~1000 폭22, Entry d100, 구역 바닥 4개·표지, 보스 선 3개). ProjectMS_City 4건물을 Lane_1 기준 A1 동선 좌표로 이동(HP·보상 유지). 스폰(0,26)·World_1.Entry(26,0)·차고(-26,0)·pixel_missile 중앙. World_2 전체 X+1300(입구 1720). TravelRoad는 백업 폴더로 이동.
- Studio 코드 변경: BaseConfig `PlotCount = 8`; WorldConfig `LaneFolder`, `TemplateLane = 1` 추가; BaseService 공개 함수 `GetPlotId(player)` 추가; ProgressionService에 `laneEntry`/`laneTransform` 추가 — 월드1 개인 도시를 자기 기지 대로로 변환 복제, 기지 없으면 생성 안 함, 기지 변경 시 재생성, 월드1 진입은 내 대로 입구로.
- 검증(실제 실행, Studio Play 1인 Mock): 기지 8개 인식. 기지 차지 전 도시 0개 → 발판 3 접촉으로 기지 3 차지 후 도시 4개가 Lane_3에 회전 배치(주택 (140,-24) 등). ProgressionRequest enter(1) → Lane_3 입구 (100,0) 도착, home → 기지 3. 제작 후 대로 입구에서 자동 공격으로 주택 파괴·드롭 3개 확인. Play 종료 후 Edit 복귀, 런타임 폴더 잔존 없음, 기지 소유 0 확인. 임시 러너 스크립트는 만들지 않음.
- 콘솔: Studio DataStore 접근 불가 경고(기존, Mock 사용), `rbxassetid://203785492` 에셋 타입 불일치 경고 3회(이번 변경 전부터인지 미확인).
- 미검증: 2인 이상 동시 접속, 월드2 실제 진입(Win 조건), 버기 대로 주행, 모바일, 게시 서버. 서버 정원 8은 사용자가 게시 설정에서 변경해야 함(미변경). Save/Publish 안 함.
- 참고: 옛 MissileSimulator(Disabled)의 Range 표시가 Lane_1 입구 근처(0,-105)에 보임. 건드리지 않음.
- 문서: `docs/GDD_v0.3.md`, `docs/LEVEL_DESIGN_v0.3.md`(Codex 미러 v0.2를 복사해 개정, 미러 원본은 변경 안 함), `docs/ring-plaza-graybox-top.jpg`. CLAUDE.md 3·4절 갱신.
- Notion: `레벨디자인 실행안 v0.2` 페이지를 v0.3 내용으로 교체하고 제목 변경, `게임 기획서 v0.2` 페이지는 해당 부분만 수정하고 제목을 `게임 기획서 v0.3`으로 변경. 경고 없음. 스크린샷은 Notion에 올리지 않음.
- 남은 작업: LEVEL_DESIGN_v0.3 15절 — B0 기록, 비행·드롭 상한 8명 기준 조정, 신규 이용자 테스트.

## 2026-11-09 — 주 작업 레포 C:\ProjectMS 연결·푸시 확인
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS` (Windows는 대소문자를 구분하지 않으므로 기존 `C:\ProjectMs`와 같은 폴더).
- 배경: 사용자가 Codex를 통해 주 작업 레포를 `C:\ProjectMS`로 통일했다고 알림. Codex는 기존 `Kimdonghyun374` 폴더(같은 레포의 다른 사본으로 추정)를 백업으로 옮겼다고 보고함. 백업 위치는 이 레포에 기록되지 않음 → Codex 쪽 기록 필요.
- 확인(실제 실행): origin = https://github.com/Kimdonghyun374/Kimdonghyun374.git, fetch 후 로컬 HEAD = 원격 main = 1407f74, 작업 트리 깨끗함.
- 사용자 지시로 이 기록을 커밋·푸시해 push 동작을 시험함.

## 2026-11-09 KST — Codex에서 GitHub push 연결 시험

- 사용자 요청으로 C:\ProjectMS의 origin과 main 연결을 재확인하고 이 기록을 테스트 커밋 대상으로 추가.
- origin: https://github.com/Kimdonghyun374/Kimdonghyun374.git. 작업 시작 시 fetch 성공, 로컬 HEAD 및 origin/main 모두 8fb3fd0, ahead/behind 0/0, 미커밋 변경 없음.
- 이번 변경은 이력 문서 한 건이며 게임 코드와 Studio는 변경하지 않음. 이 커밋의 push 성공 여부는 실행 결과 및 원격 main의 커밋 ID 대조로 별도 확인.

## 2026-11-09 — 공용 할 일 목록 TODO.md 추가
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 목적(사용자 지시): Claude·Codex가 같은 할 일 목록을 보도록 `TODO.md` 작성.
- 변경 파일: `TODO.md`(신규: 사용 방법, 진행 중, 사용자가 직접 할 일, 다음 후보 5개, 보류, 완료), `CLAUDE.md`(4절 끝에 TODO.md 기준 안내 한 줄), `HISTORY.md`.
- 내용 출처: LEVEL_DESIGN_v0.3 11·14·15절, GDD_v0.3, 이 HISTORY의 미검증·남은 작업.
- 미적용: `agent.md`는 "AGENTS.md 자동 지침으로 간주하지 않는다"고 명시돼 있어 수정하지 않았고, `AGENTS.md`도 만들지 않음. Codex가 TODO.md를 자동으로 읽게 하려면 사용자 결정 필요.
- 검증: 작업 전 fetch → 원격 변경 없음. 문서 작업이라 실행 검증 대상 없음.

## 2026-11-09 — AGENTS.md 추가 (에이전트 자동 시작 안내)
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 목적(사용자 지시): Codex 등이 작업 시작 시 TODO.md를 자동으로 읽도록 `AGENTS.md` 작성.
- 내용: 시작 전 확인(hostname·경로·git fetch/pull), 읽는 순서(TODO → HISTORY 끝 → CLAUDE.md 2~4절 → v0.3 기획서), TODO 진행 중 표시로 동시 작업 충돌 방지, Studio 백업·Save/Publish 금지, 작업 후 HISTORY·TODO 갱신과 커밋·푸시, 올리지 않는 파일. 상세 규칙은 `agent.md` 원문을 따르도록 명시(agent.md는 수정 안 함).
- 변경 파일: `AGENTS.md`(신규), `TODO.md`(완료 항목 추가), `HISTORY.md`.
- 검증: 작업 전 fetch → 원격 변경 없음. Codex가 실제로 AGENTS.md를 읽는지는 Codex 세션에서 확인 필요(미검증).

## 2026-11-09 KST — 아트 콘셉트 3종 제작
- 실행 Windows DESKTOP-RLF93FA, C:\ProjectMS. v0.3 기획에 기반해 토이 시티·인더스트리얼 프런티어·네온 리액터 비교 이미지 3종을 내장 ImageGen으로 생성.
- art/references/concepts-v01에 PNG 3개, README와 전체 프롬프트 저장. 원본/복사본 SHA256 일치 확인 및 생성 이미지 시각 검토.
- 승인 전 제안이며 정확한 배치도·게임 구현 완료로 간주하지 않음. 사용자 스타일 선택이 남음. 게임/Studio 변경·실행 테스트 없음.

## 2026-11-09 — 8명 상한 검토, 붕괴 대상 확인, 체력 단계별 손상 연출
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213 (Edit).
- 목적(사용자 지시): TODO 다음 후보 1·2 진행 + 건물이 체력에 따라 무너져 가는 모습 제작. 보스장은 구현하지 말고 계획만 보고.
- 백업: `ServerStorage.ProjectMSBackups.BeforeDamageStages_1794157543` (Config, SalvageConfig).
- 상한 검토(코드 확인): `MaxActiveFlights 150` 서버 공용, 재장전 3초 > 최대 비행 2.5초 → 1인 최대 10발, 8명 80 < 150. `MaxDrops 150` 서버 공용, 8명×4건물×4드롭=128 < 150, 초과 시 합치기/직접 지급으로 손실 없음. **값은 유지**하고 근거 주석만 추가.
- 붕괴 대상: 개인 건물 붕괴는 `SalvageService`가 소유자에게만 FireClient → 자기 도시만 그림(코드 확인).
- Studio 변경: `ReplicatedStorage.PetMissiles.Config`(주석), `SalvageConfig`(주석 + `DamageStageRatios`·`DamageLeanDegrees`·`DamageDebrisPerStage`·`DamageMaxDebris`·`DamageDebrisLifetime`), 신규 LocalScript `StarterPlayer.StarterPlayerScripts.BuildingDamageClient`(맞을 때 흔들림, 75/50/25%에서 창문 소등·그을음·파편·연기·불·기울기, 파괴 시 정리).
- 검증(실제 실행, Studio Play 1인 Mock): ① 서버에서 연구동 체력을 70/45/20%로 낮춤 → 클라이언트에서 창문 48/48 소등, 연기·불 이미터 2개, 기울기 4.00°, 다른 건물 변화 없음. ② 실제 미사일 1개로 사무실 공격 → HP 45/30/15에서 창문 12/24/36 소등, 파괴 후 효과 부착물 제거 확인. Play 종료 후 Edit 복귀, 런타임·효과 폴더 잔존 없음, 기지 소유 0.
- 참고: 이번 Play 콘솔에 `[ProfileStore]: Roblox API services available` 표시(지난번엔 unavailable). Studio는 `StudioMockData=true`로 Mock 저장소 사용(BaseService 451행)이라 실제 저장소 기록 없음.
- 미검증: 모바일 프레임, 2인 이상, 연기·불의 실제 시각 품질(스크린샷은 낮은 각도라 연기가 잘 안 보임).
- 문서: `docs/LEVEL_DESIGN_v0.3.md` 7절(손상 연출 표), 10절(보스장 구현안, 검토 대기 — 바닥 선 순서가 반대로 놓인 오류 기록), 11절(상한 검토 결과). `TODO.md` 갱신.
- 보스장 메모(미구현): 대로별 개인 장벽(Humanoid 구조로 기존 전투·손상·붕괴 재사용), 도전 패드 d≈900(지금은 월드1 완파 조건), 서버가 장벽을 초당 약 2.6으로 안쪽 이동, 체력 = 실측 DPS×25초, 성공 시 BossCleared 저장·다음 월드 조건, 실패 시 손실 없이 5초 뒤 재도전, 밤 처리 방식은 사용자 결정 필요. 그레이박스 선은 실패선이 바깥에 있어 순서 재배치 필요.


## 2026-11-09 KST — 토이 시티 확정 및 뉴욕풍 확장 아트 6종
- 실행 Windows DESKTOP-RLF93FA, C:\ProjectMS. 사용자 확정 1안과 후반 뉴욕풍 도시 방향을 art/references/toy-city-v02에 문서화.
- 환경 2장, PC/모바일 UI 1장, 건물/미사일/이펙트 각 1장 생성. 내장 ImageGen과 기존 1안 스타일 참조 사용. 미사일 랙 개수 표기 오류는 S/M/L/XL 크기 표기로 수정.
- PNG 6개 원본 해시 대조, 전체 시각 검토, README·프롬프트·브라우저 갤러리 작성. 모델/텍스처 구현물 아닌 참고 시안. UI 이름·수치·손상 비율은 예시, 현행 게임 코드 변경 없음.
- 작업 시작 시 타 작업의 TODO/레벨디자인 미커밋 변경을 보존. 완료 시 깨끗한 상태 재확인 후 TODO 완료 기록만 추가. 게임/Studio/Save/Publish 변경·성능 테스트 없음.

## 2026-11-09 — 보스 설계를 핵미사일 요격으로 변경 (문서만)
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 사용자 결정: 보스는 "체력이 높은 핵미사일이 소환돼 기지에 닿기 전에 격추"로 한다. 검토한 후보(보스 방 돌진 빌딩·찌부, 도망가는 보스)는 보류. 월드별 보스는 규칙을 통일하고 숫자와 추가 요소 하나만 바꿈(월드2 약점, 월드3 분리).
- 변경 파일: `docs/LEVEL_DESIGN_v0.3.md`(머리말, 0·2·4·5·9·10·11·13·15절), `docs/GDD_v0.3.md`(한 줄 피치, 변경 요약, 7절 월드표, 10절, 11절 아트), `TODO.md`, `HISTORY.md`.
- Notion: 레벨디자인 v0.3 페이지에 같은 수정 + 지난번 누락된 손상 연출 표·상한 검토 결과 반영. 게임 기획서 v0.3 페이지는 해당 부분 수정, 10절은 새 내용 아래에 v0.2 장벽안 원문을 "보류, 참고용"으로 남김(저장소 GDD에서는 교체). 첫 시도에서 서식 차이로 2곳 미일치 → 다시 읽고 반영, 최종 경고 없음.
- Studio·게임 코드 변경 없음. 대로 끝 보스 선(d 905/960/992)은 쓰지 않으며 보스 구현 때 제거 예정.
- 남은 작업: 보스 구현 착수 시점·밤 처리(기본안: 밤에도 가능) 사용자 확인.

## 2026-11-09 — 구글 시트 MS_MASTER에 현재 게임 데이터 입력
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 연결: Claude 커넥터 Google Sheets·Google Drive (사용자 로그인). 대상 시트 `MS_MASTER` (링크는 사용자가 제공, 저장소에는 ID를 적지 않음).
- 사용자 지시: 데이터 관련 내용을 이 시트에 모두 적고, ① 현재 값 채우기 ② 시트를 기준으로 게임 반영 ③ 6맵 구조 검토를 모두 진행.
- 이번에 한 것(①): Studio Edit에서 설정 모듈(Config·BaseConfig·SalvageConfig·WorldConfig·VehicleConfig·MissileCatalog)과 건물 속성을 읽기 전용으로 읽어 입력. 새 탭 README·COMBAT·MISSILES_CURRENT·BASE_CRAFT·BUILDINGS·WORLDS·SALVAGE·BOSS_PLAN·PROFILE_SCHEMA 추가, 비어 있던 Vehicles 탭 채움. 각 행에 값·단위·설명·게임 위치·상태(구현/기획/미정)·메모 열. 머리글 굵게·고정.
- 보존: 사용자 탭 PLAYERDATA·MISSILES·InfrastructureLevel·시트4는 수정하지 않음(다시 읽어 확인). 실제 플레이어 데이터는 적지 않음(PROFILE_SCHEMA는 항목·기본값만).
- 검증: MISSILES_CURRENT·MISSILES·PLAYERDATA를 다시 읽어 값 확인. Studio·게임 코드 변경 없음.
- ② 방식: 사용자가 시트 값을 고치고 "시트 반영"을 요청하면 백업 후 Studio 설정에 옮기고 Play 확인(README에 명시). 아직 반영 요청 없음.
- 남은 일: MISSILES 1맵 숫자 의미, InfrastructureLevel 용도, 6맵 채택 여부 사용자 결정(TODO).

## 2026-11-09 KST — 기본색 토이 시티 v03 및 탈것 제안
- 실행 컴퓨터 Windows DESKTOP-RLF93FA, C:\ProjectMS. 시작 전 fetch 및 HEAD/origin 동일(0/0), 깨끗한 상태 확인. 시작 기록 d98e12a.
- 사용자 선택인 푸른빛 보정 전 기본색 시안을 참조하여 환경2/UI1/건물1/미사일1/이펙트1 재제작, 추가 요청 탈것 비교1 생성. 내장 ImageGen 사용. art/references/toy-city-v03에 PNG 7종 + 승인 스타일 기준 PNG, 갤러리, 전체 프롬프트, 조사·학습 메모 보관. 이전 버전 보존.
- 시각 검토 후 광장 버기를 호버보드로, 이펙트 번개 보상을 너트·볼트로 수정. 생성 원본/저장본 SHA256 대조 성공. 치수·UI 수치·랙 개수는 구현 명세가 아님을 README 기록.
- Google Sheets: 사용자 지정 MS_MASTER 메타데이터 및 Vehicles(gid 680897878) A1:N15/A16:Z40 조회 성공, 해당 범위 값 없음. MISSILES A1:L8 값 읽기 성공. 문서 전체 빈 상태로 단정하지 않음. 시트 쓰기 없음.
- Pet Simulator 99/Skateboard Obby/Jailbreak 공식 페이지 조사 후 낮은 호버보드·짧은 점프·대시를 제안. 직접 플레이·인기순위·물리 성능 검증 아님. 호버보드부터 시작하는 아트 후보만 반영. 버기 교체 구현/수치/해금 확정 아님.
- 학습 제안: Luau 기본, Explorer 구조, 호버보드 작은 값 변경 실험, 클라이언트/서버, 구매·보상·저장·Remote 검증. 별도 learning-next.md.
- Studio·게임 코드·GDD 수정, Save/Publish, 실행 테스트 없음. Mac 레포 동기화는 별도 pull 필요.
## 2026-11-09 — 시트 도감 탭·서식 정리, 탈것 방향 변경 기록
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 사용자 설명: MISSILES 탭 숫자는 도감의 희귀도별 미사일 종류 수(1맵 8종: 커먼2·언커먼1·레어2·에픽2·레전더리1).
- 시트 변경: 새 탭 CODEX_PLAN(맵별 구성, 1맵 8종 목록 — 기존 5종은 각 희귀도 첫 칸, 새로 필요한 3종 표시, 희귀도 안 균등 확률 제안, 결정 항목), MISSILES_CURRENT 참고 문구 수정, README 탭 목록에 추가, PROFILE_SCHEMA에 기획 항목 Discovered 추가.
- 서식(사용자 요청): 모든 표에 테두리, 머리글 파란 배경·흰 글자, 사용자 MISSILES 탭 맵 제목 주황, 상태 색(구현 초록·기획 노랑·미정 회색·필요 주황, 조건부 서식), 탭 색(README 파랑, 사용자 탭·CODEX 주황, BOSS 노랑), 열 너비 조정. 사용자 탭은 내용 변경 없이 서식만. 첫 시도는 조건부 서식을 여러 탭에 한 규칙으로 넣어 거절(전체 미적용) → 탭별로 나눠 재적용 성공.
- 탈것 방향 변경(사용자 결정, 기획): 정찰 버기 → 호버보드 → 추진기 보드 → 소형 호버바이크. 시트 Vehicles 이름·메모 변경(상태 기획, 비용·속도는 현재 값), GDD v0.3 변경 요약과 LEVEL_DESIGN v0.3 0절에 한 줄 추가. Studio·코드 변경 없음.

## 2026-11-09 — 현재 UI를 Edit 화면에서 미리 볼 수 있게 함
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213.
- 배경: StarterGui가 비어 있고 HUD 5개는 LocalScript가 Play 때 만들어 Edit 화면에서 UI를 볼 수 없었음. TODO에 "Studio 사용 중" 표시 후 작업(Codex는 레포의 art/ui 작업 중, Studio 미사용).
- 방법: Play에서 기지 1 차지 + 제작 1회 후 PlayerGui의 MissileBaseHUD·SalvageHUD·ScoutBuggyHUD·PetMissileHUD·WorldProgressHUD 모양(클래스·크기·위치·색·글자·UICorner 등)을 직렬화 → Edit의 StarterGui에 `UIPreview_<이름>` ScreenGui 5개로 재구성. 각 사본에 속성 `EditPreviewOnly`와 LocalScript `RemoveInPlay`(Play 때 자기 자신 삭제). 보관함 패널은 화면을 가려 Visible=false로 둠, 회수 알림에 예시 글자 "부품 +20".
- 기존 코드·UI 스크립트는 수정하지 않음(백업 대상 없음, 새 오브젝트만 추가).
- 검증(실제 실행): Edit 스크린샷에서 월드 패널·자원·버기 버튼·미사일 패널 표시 확인(`docs/ui-preview-edit.jpg`). 빈 글자가 "Label"로 보이던 2곳 수정. Play 시 PlayerGui에 미리보기 사본 0개, 실제 HUD 5개만 존재 확인 후 Stop.
- 주의: 미리보기는 캡처 시점 사본이라 UI 코드가 바뀌면 다시 캡처해야 함(TODO 보류에 기록). Save 안 함.

## 2026-11-09 KST — 단순 SF UI 방향 시트와 Claude 인수인계
- Windows DESKTOP-RLF93FA, C:\ProjectMS. 시작 전 fetch/status 동기화 확인. 시작 bf0beec.
- 사용자 수정: 입체 토이 아이콘 대신 아주 단순한 SF UI, Pet Simulator 99 구조 참고, 패널/버튼/글자는 Roblox에서 제작. 이후 모든 이용 가능한 미사일/탈것도 개별 UI 이미지 제작으로 명확화.
- art/ui/toy-city-v01/simple-scifi-ui-sheet-v02.png, README, prompts, CLAUDE_HANDOFF 작성. 내장 ImageGen 사용, 생성 이미지 시각 검토 및 원본 SHA256 일치. 초기 16종 입체 아이콘안은 미채택/미업로드.
- Studio Edit에서 실제 UI 생성부와 Disabled 여부 읽음: PetMissileClient/MissileBaseClient/SalvageClient/WorldProgressClient/ScoutBuggyClient 활성, 옛 MissileHUD 비활성. 인수인계에 GUI 경로/기존 Remote 흐름/적용 순서 기록.
- 초기 토이 테마 모듈을 DataModel에 붙이지 않은 임시 Instance로만 구성 검증 후 Destroy. 변경된 디자인용 배포 코드나 실제 렌더 검증으로 간주하지 않음.
- 사용자 업로드 폴더 허용 완료 응답 있음. 최신 요청이 방향 시트 검토로 변경되어 업로드/asset ID 발급/기존 게임 UI 교체는 하지 않음. Studio Save/Publish 없음.
- 다음: UI 시트 피드백, 전체 장비 목록 대조 및 개별 PNG 생성, 실제 업로드/ID 매핑, Claude 적용 및 PC/모바일 검증. 현재 시트 숫자/탭/희귀도는 예시.
## 2026-11-09 KST — Roblox 홍보 아트 2종
- Windows DESKTOP-RLF93FA, C:\ProjectMS. 시작 fetch/status 동기화 확인, 시작 1bcffdd. Claude의 Studio 사용 중 작업 보존.
- 사용자 첨부 3장의 연출을 참고해 미사일·호버보드·도시 파괴 가로 홍보 아트와 정사각 게임 아이콘을 내장 ImageGen으로 제작. art/marketing/launch-v01에 PNG2, README, 전체 프롬프트 저장.
- 검증: 2장 시각 검토, 생성 원본/복사본 SHA256 일치. 가로 원본 1672×941(16:9 구도, 정확 비율과 약 0.05% 차이), 아이콘 1254×1254(정확 1:1). 가로의 정확한 최종 출력 규격 조정 필요는 README에 기록.
- 게임·Studio 변경, 업로드·게시 없음. 사용자 참고 원본은 공개 레포에 복사하지 않음.
## 2026-11-09 — 큰 기지(타이쿤) 재배치와 공동 레이드 자리 그레이박스
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시 후 작업(Codex는 레포 art/ui 작업).
- 사용자 요청: 공동 보스 레이드 자리, 기지별 탈것 소환 자리, 너무 작은 기지, 미사일 전시 대폭 확대, 높은 등급 제작 시간 증가로 제작기 여러 대, AFK 연구시설 → 기획서·레벨디자인 수정 + 그레이박스 재작업.
- 백업: `ServerStorage.ProjectMSBackups.BeforeBigBases_1794161033` (ProjectMS_Bases·Lanes·City·Garage·Worlds, SpawnLocation, Baseplate).
- 발견: `pixel_missile`이 이미 Workspace에 없었음(제 작업 아님, 복구하지 않음, TODO에 기록).
- Studio 변경: 기지 8개 80×110, 중심 d=170(앞 끝 115·뒤 끝 225). 기존 부품(Floor·ClaimPad·Generator·Display·Storage)은 이름 유지·위치 이동. 기지마다 `Layout` 폴더(코드 미참조): GeneratorSlot_2~6, GalleryFloor + Pedestal_2~50, VehiclePad, AFKLab, LaneExit, 안내 표지. 광장 반지름 108, `ProjectMS_Lanes.RaidArena`(반지름 60, 표시 기둥). 스폰 (0,84), World_1.Entry (84,0), 공용 차고 (-84,0). 대로 재생성 d 225~1140, 입구 240, 구역 260~540/580~780/820~1020/대로 끝 1040~1140, 보스 선 제거. `BaseplateExtension_N/S/E/W` 추가. ProjectMS_City 4건물 -Z 140 이동(Lane_1 기준 유지). 코드 변경 없음. 기지 파트 합계 536.
- 검증(실제 실행, Play 1인 Mock): 스폰 (0,80). 발판 접촉으로 기지 3 차지 → 도시 4개가 Lane_3에 (280..510) 생성. 기지 귀환 → 제작기 옆 도착. 제작 → Display에 미리보기 생성. 월드1 진입 → Lane_3 입구 (240,0). 자동 공격으로 주택 파괴(HP 0). Stop 후 Edit 런타임 폴더 없음·기지 소유 0.
- 사고와 조치: 스크린샷 하나가 시간 초과되면서 Edit 카메라가 Scriptable로 남아 사용자 카메라가 움직이지 않았음 → CameraType Fixed로 복구, 광장 위로 위치. 문서 스크린샷 동안 UI 미리보기 Enabled를 잠시 끄고 다시 켬.
- 문서: `docs/LEVEL_DESIGN_v0.3.md`(머리말, 0절, 2절 재작성 + 2-1 기지 구획 + 2-2 레이드 자리, 4·5·9·10·11·12·13절 수치), `docs/GDD_v0.3.md`(변경 요약, 4절 맵, 7절 공간 구조, 12절 후순위), 스크린샷 `docs/big-bases-top.jpg`·`docs/big-bases-closeup.jpg`. Notion 두 페이지 같은 내용 반영(첫 시도 1곳 미일치 → 다시 읽고 반영). 시트 WORLDS 탭 대로 거리 갱신 + 기지 구획 표 추가.
- 미검증: 2인 이상, 모바일, 탈것 대로 주행. Save 안 함.

## 2026-11-09 — 기지 차고 연결
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시 후 작업.
- 백업: `ServerStorage.ProjectMSBackups.BeforeBaseGarage_1794161957` (VehicleService, 기지 8개 VehiclePad).
- Studio 변경: Base_1~8의 `Layout.VehiclePad`를 불투명·두께 0.3으로 바꾸고 ProximityPrompt `OpenGarage`(E, 즉시, 거리 14, "기지 N 차고") 추가, 표지 "기지 차고 · E". `ServerScriptService.PetMissiles.VehicleService.Start`에 기지 차고 프롬프트 연결: 16 이내 + 그 기지 `OwnerUserId`가 본인이면 기존 공용 차고와 같은 메뉴 열기(`sendState(player, nil, true)`), 아니면 "내 기지의 차고에서만 열 수 있습니다". 공용 차고 코드는 그대로.
- 검증(실제 실행, Play 1인 Mock): 기지 3 차지 후 Base_3 차고에서 프롬프트 실행 → Garage 패널 표시. Base_4 차고 → 패널 안 열림 + 안내 문구. 탈것 없이 소환 → "먼저 정찰 버기를 구매하세요"(기존 동작). Stop 후 Edit 복귀.
- 미검증: 탈것 구매 후 발판 위 소환(부품 50 필요, 이번엔 확인 안 함), 2인 동시, 모바일 프롬프트 터치.
- 문서: LEVEL_DESIGN_v0.3 2-1절 기지 차고 행을 구현으로, 2절 공용 차고 설명 수정. 시트 WORLDS 기지 차고 행 상태 구현. TODO 갱신.

## 2026-11-09 KST — 베이컨 보이 홍보 아트 수정
- Windows DESKTOP-RLF93FA, C:\ProjectMS. fetch/status 원격 동기화 확인.
- 사용자 피드백에 따라 중간 디테일의 베이컨 보이, 도시 파괴와 공중 동행 미사일 3종으로 수정. art/marketing/bacon-fleet-v02에 가로/정사각 PNG와 프롬프트/README 저장. 이전 버전 보존.
- 검증: 두 생성 이미지 시각 검토. 가로 정확 비율 조정 필요는 README 기록. Studio 변경/업로드/게시 없음.
- TODO 확인: 큰 기지 재배치/차고 연결 완료. 다음은 B0 첫 반복 측정, 신규 이용자 테스트, 이후 구역2·3.

## 2026-11-09 KST — UI 미사일 이미지 생성 취소
- Windows DESKTOP-RLF93FA. 사용자 확인에 따라 이번 UI 작업의 스탠더드/스파크/코멧 생성 PNG 원본 3개 삭제 및 부재 확인. 노바 생성 중단, 추가 결과 파일 없음.
- 메뉴 아이콘과 이전 홍보/컨셉아트 보존. 삭제 대상은 레포 복사/Roblox 업로드 전이므로 에셋 삭제나 Git 이미지 삭제 없음. 이후 UI 작업에서 미사일 이미지 생성 제외.

## 2026-11-09 KST — 이전 UI 아이콘 8개 폐기
- 사용자 추가 삭제 지시에 따라 이번 작업의 메뉴/재화 아이콘 PNG 원본 8개 삭제 및 부재 확인. 미사일 3개는 앞서 삭제됨. 레포 복사/Roblox 업로드 전 파일.
- art/references/toy-city-v03/ui/01-gameplay-hud.png와 이전 컨셉/홍보 아트 보존. 새 UI 기준은 toy-city-v03 흰 패널/남색 글자/파란 버튼/기본색 아이콘. 새 기준 재제작은 아직 미완료.

## 2026-11-09 — UI 색·모양을 Codex UI 시트 스타일로
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시(Codex는 레포에서 아이콘 PNG 작업 중).
- 기준: `art/ui/toy-city-v01/simple-scifi-ui-sheet-v02.png`, `CLAUDE_HANDOFF.md`(사용자 지시: 색과 모양 위주).
- 백업: `ServerStorage.ProjectMSBackups.BeforeUITheme_1794162905` (UI 스크립트 5개 + UI 미리보기 사본).
- 방식: 기존 UI 스크립트 5개(MissileBase·Salvage·ScoutBuggy·PetMissile·WorldProgress Client)는 수정하지 않음. 새 ModuleScript `ReplicatedStorage.PetMissiles.UITheme`(색표, 기존 색→시트 색 치환표, 패널·카드·버튼 판별, UIStroke·UICorner 6, 버튼 GothamBlack) + 새 LocalScript `StarterPlayerScripts.UIThemeClient`(PlayerGui의 HUD 5개에 적용, 새 요소·상태별 색 변경도 계속 치환). Edit 미리보기 사본 5개에도 `Theme.Apply` 1회 적용.
- 검증(실제 실행, Play 1인 Mock): 기지 1 차지·제작 후 Inventory 남색(28,36,52)+테두리+모서리 6, Close 빨강, Roll(부품 부족) 회색, 아이템 카드(40,50,68), 장착 해제 보조색, Focus·World1 파랑, World2(잠김) 회색, 부품 글자 노랑. 화면 `docs/ui-theme-play.jpg`. Stop 후 Edit 복귀. Edit 미리보기 촬영은 캡처 시간 초과로 실패, 카메라 Fixed 확인.
- 발견: 월드 패널 메시지 줄에 기본 글자 "Label"이 Play에서도 보임(기존 버그) → TODO 보류에 기록.
- 미적용: 아이콘 이미지(Codex 제작 중), 아래 메뉴 바·HP/재장전 막대·카드 격자·영어 표기 등 배치 변경.
- 문서: GDD_v0.3 11절에 UI 테마 한 단락. Save 안 함.

## 2026-11-09 — UI 테마를 v03 밝은 스타일로 교체
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시.
- 사용자 결정: Codex 진행 항목과 같은 `art/references/toy-city-v03/ui/01-gameplay-hud.png`(밝은 장난감 스타일)로 맞춤.
- 백업: `ServerStorage.ProjectMSBackups.BeforeUIThemeV03_1794163558` (v02 어두운 SF UITheme).
- Studio 변경: `ReplicatedStorage.PetMissiles.UITheme` 소스 교체 — 흰 패널+연한 파랑 테두리, 남색 글자, 파랑 알약 버튼(테두리 없음), 초록/주황/빨강/연회색, 모서리 12, 버튼 글자색을 배경 밝기에 따라 흰색/남색으로, 표에 없는 밝은 글자(희귀도 색)는 같은 색조로 45% 어둡게, 스크롤바 색. `UIThemeClient`는 그대로. Edit 미리보기 5개는 테마 전 원본(`BeforeUITheme_1794162905`)에서 다시 복제해 v03 적용.
- 검증(실제 실행, Play 1인 Mock): 기지 1 차지·제작 후 Inventory 흰색+남색 제목, Roll(부족) 연회색+남색 글자, Close 빨강+흰 글자, 아이템 카드 연파랑, 희귀도 글자 (105,116,124), 장착 해제 밝은 보조색+남색 글자, Focus 파랑, 부품 (215,135,0)·연구자료 (20,140,210), 차고 버튼 밝은 보조색. 화면 `docs/ui-theme-play.jpg`(v03로 교체). Stop 후 Edit 카메라 정상.
- 문서: GDD_v0.3 11절 UI 단락을 v03 기준으로 수정. TODO 갱신. Save 안 함.

## 2026-11-09 KST — 토이 v03 UI 아이콘 재제작
- Windows DESKTOP-RLF93FA, C:\ProjectMS. fetch/status 동기화 확인. 기존 Claude UI 작업 보존.
- 사용자 지정 art/references/toy-city-v03/ui/01-gameplay-hud.png 기반 메뉴·재화 8종 생성. art/ui/toy-city-v01/toy-v03-icons에 PNG, prompts, preview.html, manifest, README. 미사일 제외. 밝은 패널·남색 글자·파랑/노랑 기본색 기준 기록.
- 검증: 생성 이미지 시각 검토, 8개 PNG 1254x1254/코너 alpha=0. 잔색 픽셀 표본 alpha=1. 브라우저 로컬 파일 접근 제한으로 HTML 렌더 검증 미실행. 게임 크기/모바일/Studio 이미지 표시 검증 미실행.
- Open Cloud asset:read/write 권한 probe 성공. 로컬 PNG 업로드는 directory approved 오류. 사용자 폴더 허용 완료 응답 이후 같은 경로 재시도도 동일. 에셋 ID 미발급, manifest null. 업로드 차단 우회 없음. Studio 수정/Save/Publish 없음.

## 2026-11-09 KST — UI 아이콘 업로드 완료
- Windows DESKTOP-RLF93FA, C:\ProjectMS. fetch/status 원격 동기화 확인. 사용자 폴더 권한 저장 후 업로드 재시도.
- 8종 Decal 업로드 모두 HTTP200, operation done=true, moderation Approved. InsertService.LoadAsset로 각 Decal.Texture 실제 이미지 ID 읽고 미부모화 임시 모델 Destroy.
- art/ui/toy-city-v01/toy-v03-icons/manifest.json 실제 Image ID/Decal ID와 상태 기록, UIAssets.luau 추가, README/TODO 업데이트.
- 영구 Studio 변경/Save/Publish 없음. UI 연결 및 화면/모바일 표시 검증은 후속.

## 2026-11-09 — "Label" 기본 글자 버그 수정
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시.
- 원인: `WorldProgressClient`·`ScoutBuggyClient`의 `label()` 함수가 TextLabel을 만들 때 Text를 지정하지 않아 Roblox 기본값 "Label"이 메시지가 올 때까지 보였음(월드 패널 맨 아래, 차고 창 메시지 줄).
- 백업: `ServerStorage.ProjectMSBackups.BeforeLabelFix_1794164615` (두 스크립트).
- 변경: 두 스크립트의 `label()`에 `item.Text = ""` 한 줄과 이유 주석 추가. 다른 로직 변경 없음.
- 검증(실제 실행, Play 1인 Mock): 접속 후 Phase·Wins는 정상 값, World Message·Garage Message는 빈 글자. PlayerGui 전체에서 "Label"은 SalvageHUD.PickupNotice 1곳만 남음 — 평소 숨김이고 표시할 때 글자를 채우므로 화면에 안 보여 수정하지 않음. Stop 후 Edit 복귀.
- Edit의 UI 미리보기는 이미 빈 글자로 고쳐져 있어 변경 없음. Save 안 함.

## 2026-11-09 — Codex v03 UI 아이콘 8종 화면 연결
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. 사용자 지시로 Codex 진행 항목(아이콘 UI 연결)을 Claude가 맡음, TODO에 "Studio 사용 중" 표시.
- 입력: `art/ui/toy-city-v01/toy-v03-icons/` (UIAssets.luau, manifest.json, README.md — Codex 업로드·moderation Approved).
- 백업: `ServerStorage.ProjectMSBackups.BeforeUIIcons_1794164752` (UITheme, UI 미리보기 5개).
- Studio 변경: 새 ModuleScript `ReplicatedStorage.PetMissiles.UIAssets`(Codex 파일 내용 그대로 + 출처 주석). `UITheme` 소스 갱신 — 색값을 Codex README 근사값으로(#FAFCFF 패널, #10275E 글자, #C3D5FA 테두리, #2479F7 주요, #29B928 확인, #F14D60 닫기), `Theme.IconTargets`(9곳: Resources.Scrap/ResearchData 22, Panel.Home/World1/World2 22, BaseBanner.OpenInventory 26, Inventory.Roll 30, PetMissileHUD Focus 36, OpenGarage 28)와 아이콘 부착(왼쪽 ImageLabel `ThemeIcon` + UIPadding `ThemeIconPadding`). `UIThemeClient`·기존 UI 스크립트 변경 없음. Edit 미리보기 5개는 테마 전 원본에서 재복제 후 적용(빈 "Label" 글자 정리 포함).
- 검증(실제 실행, Play 1인 Mock): 기지 1 차지·제작 후 PlayerGui에서 ThemeIcon 9개, `PreloadAsync` 후 모두 IsLoaded=true, 크기 22~36px, 부모 Visible. 스크린샷 `docs/ui-theme-play.jpg` 교체. Stop 후 Edit 카메라 정상, 임시 probe 모듈 제거 확인.
- 미검증: 아이콘의 실제 보기 품질(스크린샷 해상도가 낮음), 집중 공격 남색 아이콘의 파란 버튼 위 대비, 모바일 화면 글자 줄바꿈 → TODO 보류.
- 문서: GDD_v0.3 11절 UI 단락에 아이콘 문장 추가. Save 안 함.

## 2026-11-09 KST — 작업 시작 알림 등록
- Windows DESKTOP-RLF93FA, C:\ProjectMS. fetch/status 동기화 확인.
- TODO 사용자 할 일에 전시 공간 좌우 분리/2층 구조 변경, 프로토타입 모델 식별성 등록. AGENTS.md와 agent.md에 시작 알림 명시.
- 문서만 변경, Studio 모델 수정 없음.

## 2026-11-10 — 타이쿤 전시장 좌우·2층 개편과 기지 모델 식별성
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시.
- 시작 알림(AGENTS.md): 전시장 좌우·2층 개편, 프로토타입 모델 식별성 — 둘 다 이번 작업 범위.
- 사용자: Studio 자동저장을 쓰므로 저장 걱정 말 것 → TODO 저장 항목 완료 처리. Studio가 다시 열려 MCP studio id가 바뀜(`프로젝트MS` 외에 다른 Place `자산` 127014821326220도 열려 있었으나 손대지 않음). 다시 열린 Place에서 2026-11-09 변경(큰 기지·대로·레이드·UI 테마/아이콘·손상 연출·Label 수정·기지 차고·백업 8개)이 모두 남아 있음 확인.
- 백업: `ServerStorage.ProjectMSBackups.BeforeGalleryTwoFloor_1794235490` (ProjectMS_Bases 전체).
- Studio 변경(기지 8개 동일): `Layout`을 VehiclePad만 남기고 재구성 — `Gallery`(좌우 가장자리 x ±28~40, z -21~52, 1층 바닥 표시 + 2층 바닥 높이 12.65, 안쪽 난간·뒤 난간·기둥, 앞쪽 경사로 z -44→-21 약 28°, 받침 95개 + Display 1개 = 96칸, 흰 받침+파란 테두리, 각 층·측면 첫 칸 미사일 견본, 이름표), `Production`(제작 라인 x ±8/±16/±24, 예정 5칸 반투명 기계 + 6칸 모두 굴뚝·신호등), `Garage`(노란 문틀 게이트, VehiclePad 22×18로 이동), `AFKLab`(유리 건물+돔+안테나), 보관함·출구 이름표. 기존 부품 `Generator`(-8,-32), `Display`(왼쪽 1층 1번, 3×3), `Storage`(-15,+24) 위치 이동. 코드 변경 없음. 기지 파트 합계 2,032.
- 검증(실제 실행, Play 1인 Mock): 기지 1 차지 → 제작 후 Display 위 미리보기 생성. 경사로 낮은 끝에서 MoveTo로 걸어 올라 2층 도착(root y 15.9 > 2층 윗면 12.9). 첫 시도는 시험 코드가 경사로 위아래를 반대로 잡아 실패한 것으로 확인. 기지 차고 E → 탈것 메뉴 열림. Stop 후 Edit 복귀·카메라 정상·런타임 폴더 없음.
- 문서: LEVEL_DESIGN_v0.3 2-1절 재작성(그림·표·식별 방법), 스크린샷 `docs/gallery-two-floor.jpg`. 시트 WORLDS 제작 라인·전시장·차고·AFK 행 갱신. TODO: 전시장 알림은 "사용자 완료 확인 대기"로 표시.
- 미검증: 모바일에서 경사로·2층 이동, 2인 이상, 2층 난간 사이 낙하 위험(뒤·안쪽만 난간, 바깥쪽은 기지 가장자리).

## 2026-11-10 — 전시장 개편 완료 확인, 시작 알림 삭제
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 사용자 확인: 타이쿤 전시장 좌우·2층 개편을 완료로 처리.
- 변경 파일: `TODO.md`(시작 알림 항목 삭제, 완료 항목에 확인 표시), `AGENTS.md`·`agent.md`(시작 알림 문단에서 전시장 항목 삭제, 프로토타입 식별성 알림은 유지). Studio 변경 없음.

## 2026-11-10 — 월드2(2맵) 해금 동작 확인
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. Studio 변경 없음(Play 시험만).
- 조건(코드 확인, `ProgressionRules.CanEnter`): Wins ≥ 1 그리고 WorldClears["1"] ≥ 1. 월드1 건물 4개를 같은 낮 주기에 모두 파괴하면 `RecordDestroyed`가 Win+1·WorldClears+1을 함께 기록.
- 검증(실제 실행, Play 1인 Mock): 기지 1 차지 → 낮에 서버에서 개인 건물 4개 Humanoid.Health=0(실제 사망 경로로 파괴 처리) → 패널 "누적 Win 1 / 입문 도시 파괴 4/4 · 완파!", World2 버튼 "2월드로 바로 이동", 메시지 "월드 완파! Win +1". ProgressionRequest enter 2 → (1720,3,25) 월드2 입구 도착, "산업 도시 파괴 0/4", 월드2 건물 4개 섬 위 생성. enter 1 → Lane_1 입구 (0,-240) 복귀. Stop.
- 참고: 시험은 미사일 공격 대신 체력 0으로 파괴. 실제 미사일로 월드2 건물(HP 4배) 공격과 월드2의 레벨 구조(링·대로 미적용)는 별도 결정 항목(TODO 보류).

## 2026-11-09 KST — PLAYERDATA 기준값 정리
- Windows DESKTOP-RLF93FA, C:\ProjectMS. fetch/status 동기화 확인.
- 사용자 범위 확인 후 MS_MASTER PLAYERDATA!A1:B20에 기존 키 포함 기본값 19개와 B열 셀 메모 입력. 시트 재조회 19개 대조 완료. 코드와 기획 단계 값은 메모에서 구분.
- 처음에 Studio 코드로 오해하여 수정했다가 자체 테스트를 종료하고 BaseDomain/BaseService 원본 일치와 신규 모듈 제거를 검증했다.

## 2026-11-10 — 서버 정원·기지 8 → 6
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시. 시작 알림(프로토타입 식별성): 시설 모양·이름표 유지.
- 사용자 결정: 6명으로 줄임(기지 사이가 너무 좁아 보여서).
- 백업: `ServerStorage.ProjectMSBackups.BeforeSixBases_1794237772` (ProjectMS_Bases, ProjectMS_Lanes, BaseConfig) + 같은 폴더 `RemovedBase7_8`에 Base_7·8, Lane_7·8 이동(삭제 아님).
- Studio 변경: Base_2~6과 Lane_2~6을 광장 중심 기준으로 회전해 60° 간격(Base_1·Lane_1·월드1 템플릿은 그대로). BaseConfig `PlotCount = 6` + 주석. Config·SalvageConfig 상한 근거 주석을 6명 기준(60 / 96)으로. 기지 크기 80×110 유지, 앞 끝 간격 약 8 → 약 35.
- 검증(실제 실행, Play 1인 Mock): 기지 6개 인식. 회전한 Base_2 차지 → Lane_2에 도시 4개 생성, 제작 → Display 미리보기, 월드1 진입 → Lane_2 입구 (208,-120), 자동 공격으로 주택 파괴, 기지 차고 E → 탈것 메뉴. Stop 후 Edit 복귀. 위에서 본 화면 `docs/six-bases-top.jpg`.
- 문서: LEVEL_DESIGN_v0.3(정원·기지 수·각도·간격 공식 d×1.0·파트 수·성능 표·상한 계산·작업 순서·아트 표), GDD_v0.3(머리말·변경 요약·맵·공간 구조·실행 순서·결정 표), CLAUDE.md, TODO(정원 6명 변경 항목). 시트 BASE_CRAFT PlotCount 6, WORLDS 기지 크기, COMBAT·SALVAGE 상한 설명. Notion 레벨디자인 맨 위에 변경 안내, 게임 기획서 정원 행·결정 표 수정.
- 남은 일: 서버 정원 6 게시 설정(사용자). Save는 사용자 자동저장.

## 2026-11-10 — Win 제거 결정 기록 (문서만)
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 사용자 결정: Win 제거. 논의 근거: 현재 Win은 월드 완파 기록과 같은 시점에 같이 쌓여 해금 조건 외 쓰임이 없음. 완파 보상은 연구자료 확정 지급으로, 다음 월드는 이전 월드 완파(이후 보스 격파)로 열기 권장. 펫시뮬99 다이아 사용처(영구 업그레이드·상인·편의 아이템·거래) 웹 조사 결과를 대화로 공유.
- 변경 파일: `docs/GDD_v0.3.md` 14절 결정 표(Win 제거, 지역 해금 재화 미정), `TODO.md`(Win 제거 구현 항목), `HISTORY.md`. Studio·코드 변경 없음.

## 2026-11-10 — 일반 재화 "부품" → 코인(골드) 결정 기록 (문서만)
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`.
- 사용자 결정: 부품을 코인(골드)으로 교체(직관성). 권장 구현: 화면 표시만 바꾸고 저장 키 `Scrap` 유지, 아이콘을 동전으로 교체. 지역 해금 재화는 추천안(구역=완파+코인, 월드=보스 격파) 기록, 확정 대기.
- 변경 파일: `docs/GDD_v0.3.md` 14절 결정 표, `TODO.md`, `HISTORY.md`. Studio·코드 변경 없음.

## 2026-11-10 — 일반 재화 "부품" → "코인" 화면 글자 교체
- 실행 컴퓨터: Windows `DESKTOP-RLF93FA`. 작업 폴더: `C:\ProjectMS`. 대상: Studio Place 122289987934213. TODO에 "Studio 사용 중" 표시.
- 사용자 결정: 화면 이름 "코인".
- 백업: `ServerStorage.ProjectMSBackups.BeforeCoinRename_1794240472` (스크립트 9개).
- Studio 변경: BaseConfig·SalvageService·BaseDomain·BaseWorld·BaseService·VehicleRules·SalvageClient·MissileBaseClient·ScoutBuggyClient 소스의 "부품" 24곳 → "코인"(BaseWorld 주석 "지형/기지 부품"은 재화 뜻이 아니라 유지). 이미 만들어진 글자 21곳(기지 생산기 간판 6, 공용 차고 간판, UI 미리보기, 프롬프트) 교체. 저장 키 `Scrap`·변수명·RemoteEvent 변경 없음.
- 검증(실제 실행, Play 1인 Mock): 자원 "코인 20", 기지 안내 "제작 · 코인 20개 · 5초", 탈것 버튼·차고 구매 "코인 50개", 생산기 간판·프롬프트 "코인 20개", PlayerGui에 "부품" 0개. 실제 미사일로 상가 파괴 → 드롭 이름표 "■ 코인 ×12/12/11". (체력 0 직접 파괴는 피해 기여자가 없어 드롭이 생기지 않음 — 기존 동작.) Stop 후 Edit 복귀.
- 문서: 시트 전체 "부품"→"코인" 9곳(findReplace, 사용자 탭에는 해당 없음) + README 용어 행. GDD·LEVEL_DESIGN 맨 위 용어 안내(본문 "부품"=코인), GDD 결정 표 "결정·적용", CLAUDE.md 3절 재화 이름 줄. TODO: 동전 아이콘 Codex 요청 항목.

## 2026-11-10 KST — 토이 v03 코인 아이콘
- Windows DESKTOP-RLF93FA, C:\ProjectMS. 기존 노란 아이콘과 같은 재질의 별 문양 금색 동전 제작. art/ui/toy-city-v01/toy-v03-icons/coin.png, 1254×1254 RGBA. 모서리 알파 0~1/255, 중앙 알파 253/255 표본 확인.
- Roblox Decal 79230387751043 업로드 및 심사 Approved, Studio에서 Decal.Texture rbxassetid://72200879387099 확인. 저장소 UIAssets/manifest/미리보기 매핑 갱신. Studio HUD 연결은 후속.

## 2026-11-10 KST — 재화 역할 결정 정리 (Claude)
- 컴퓨터 DESKTOP-RLF93FA, C:\ProjectMs. 사용자 결정: "레벨업은 연구자료, 그 외 시설 확대는 코인", 고급 뽑기도 코인.
- 문서: GDD_v0.3 6절에 "재화 역할 결정" 표(얻는 곳·쓰는 곳), 14절 "연구자료 소비=레벨업 전용", "지역 해금 재화=코인(월드는 보스 격파)", "고급 뽑기 재화=코인" 결정 행. TODO 완료 항목, 줄머리 오타(n- [ ]) 수정.
- 시트 MS_MASTER: ECONOMY 탭 새로 추가(재화·구분·항목·값·상태·메모 19행, 상태 색 규칙), README 탭 목록에 ECONOMY 행. 사용자 탭은 건드리지 않음.
- Studio 변경 없음(문서만). 남은 일: 비용 숫자는 밸런스 계산표에서, 버기 업그레이드(현재 코인)를 연구자료로 바꾸는 것은 구현 때.

## 2026-11-10 KST — 코인 동전 아이콘 Studio 연결 (Claude)
- 컴퓨터 DESKTOP-RLF93FA, C:\ProjectMs. Codex가 올린 동전(Decal 79230387751043 → 이미지 rbxassetid://72200879387099, InsertService로 Decal.Texture 일치 확인)을 HUD에 연결.
- 백업: ServerStorage.ProjectMSBackups.BeforeCoinIcon_1794241300 (UIAssets).
- Studio 변경: ReplicatedStorage.PetMissiles.UIAssets `scrap` 값 77913723342034(톱니) → 72200879387099(동전), StarterGui.UIPreview_SalvageHUD 코인 아이콘 Image 교체. 옛 ID를 쓰는 곳 0개(백업 제외).
- 검증(실제 실행, Play 1인): 첫 Play에서 HUD 코인 아이콘이 빈 칸(새로 승인된 이미지의 첫 요청 실패로 보임, Image 다시 지정하자 표시) → Play를 새로 시작하니 처음부터 "코인 20" 옆에 동전 표시(docs/coin-icon-hud.jpg). Stop 후 Edit 복귀.
- 남은 일: 게시 서버·휴대폰에서 첫 접속 때 빈 칸이 다시 생기는지 확인.

## 2026-11-10 KST — 집중 공격 게이지 + 6시 UI 축소 (Claude)
- 컴퓨터 DESKTOP-RLF93FA, C:\ProjectMs. 사용자 지시: 집중 공격은 접속 시 가득, 사용 시 전탄 재장전. 6시 UI는 F와 아이콘 하나만 남기고 삭제. 아이콘은 Codex가 생성(프롬프트 작성).
- 백업: ServerStorage.ProjectMSBackups.BeforeFocusGauge_1794243976 (Service, Config, UITheme, PetMissileClient, UIThemeClient, UIPreview_PetMissileHUD).
- Studio 변경:
  - Config: FocusChargeMax 100, FocusChargePerHit 2.
  - Service: 플레이어 상태에 focusCharge(처음 가득), 상태 동기화에 focusCharge/focusMax. RequestFocus는 게이지 가득·미사일 있음·목표 유효일 때만 → 모든 슬롯 즉시 재장전 → 전탄 일제 발사 → 게이지 0. 자동 발사 중이면 끊고 집중 공격으로 바꿈. 일반 공격 명중만 충전(flight.focus로 구분).
  - PetMissileClient: 6시 큰 패널(상태·목표·안내 글자, 긴 버튼) 삭제 → 지름 84px 동그란 버튼(아이콘, 키보드일 때 F 배지, CanvasGroup 게이지 아래→위 채움, 가득 차면 주황+테두리 깜빡임). 서버 거절 안내는 버튼 위에 2초만. 아이콘은 UIAssets.focusSkill이 있으면 그것, 없으면 기존 focus.
  - UIThemeClient 대상에서 PetMissileHUD 제외(동그란 모양 유지), UITheme IconTargets의 PetMissileHUD.Panel.Focus 줄 삭제. StarterGui 미리보기 UIPreview_PetMissileHUD를 새 버튼으로 다시 만듦(RemoveInPlay 유지).
- 검증(실제 실행, Play 1인 Mock): 기지 차지·제작 1발 장착 → 개인 도시 옆. 처음 게이지 100/100, 재장전 중(준비 0발)에도 집중 공격 발사(launched 3→4), 게이지 0. 바로 다시 누르면 거절 "집중 게이지 충전 중". 8초 자동 공격 후 4/100(명중 2발). 화면: 6시에 동그란 버튼+F 배지만 표시(docs/focus-button-play.jpg). Stop 후 Edit 복귀.
- 문서: GDD 결정 표 1행, 시트 COMBAT 3행(FocusChargeMax, FocusChargePerHit, 피해 보너스 미정), Codex 아이콘 프롬프트(art/ui/toy-city-v01/toy-v03-icons/prompts.md `focusSkill`), TODO에 Codex 요청.
- 미검증: 10발 장착 상태 일제 사격, 휴대폰 터치 위치(TouchEnabled면 아래에서 140), 게이지 가득 상태의 깜빡임 화면.

## 2026-11-10 KST — 연구자료·집중 공격 아이콘
- C:\ProjectMS. 평면 설계도 수정안과 집중 공격 투명 PNG 저장, 원본 SHA256 일치 및 1254×1254/코너 alpha=0 확인.
- Roblox 두 Decal 심사 Approved, Studio에서 실제 Image ID 연구자료 rbxassetid://105888631454719, 집중 공격 rbxassetid://109239933150633 확인. 저장소 매핑과 미리보기 갱신. Studio 적용과 흰색/주황색·모바일 검증은 Claude TODO에 등록.

## 2026-11-10 KST — 필수 효과음 10종 및 전탄 재장전 아이콘
- C:\ProjectMS. 현재 Studio의 임시 획득음과 전투·제작 이벤트 확인. art/audio/core-sfx-v01에 10개 원본 합성 WAV와 연결/검증 안내 저장. 44.1kHz·모노·16비트, 비어 있지 않고 클리핑 및 중복 없음 확인. 오디오 업로드 폴더 허용 오류, SoundId/게임 청취 미검증.
- 화살표 두 개·미사일 세 발 PNG 저장, Decal 122460028099487 Approved 및 실제 Image ID rbxassetid://72548406471009 확인. 저장소 focusSkill 매핑과 TODO의 Claude 연결 항목 갱신.

## 2026-11-10 KST — 화면·기지 개편 9가지 + Codex 아이콘 연결 (Claude)
- 컴퓨터 DESKTOP-RLF93FA, C:\ProjectMs. 사용자 지시 1~9 + "코덱스 이미지 끝나면 적용".
- 백업: ServerStorage.ProjectMSBackups.BeforeUIBaseRework_1794244413 (BaseWorld, BaseService, BaseDomain, MissileBaseClient, ScoutBuggyClient, WorldProgressClient, SalvageClient, UITheme, UIAssets, 옛 UIPreview 4개, 프롬프트 원래 Style 목록).
- Studio 변경:
  1. 기지 차지: ClaimPad.Touched 차지 제거, Claim 프롬프트 E·0.4초·거리 12, BaseConfig.ClaimDistance 10→13. 새 LocalScript StarterPlayerScripts.PromptClient: Style=Custom 프롬프트에 밝은 카드(남색 키 배지, 행동·대상 글자, 누르기 게이지, 터치 시 카드 누르기). Workspace 프롬프트 27개 Style Custom. OwnerSign 높이 5→8.
  2. 빈 기지: BaseWorld가 Layout(보관함 표지 제외)·Generator·Display를 Play 시작 때 숨기고(투명·충돌 끔·프롬프트/표지 끔), 차지하면 0.6초에 걸쳐 나타남. 주인이 나가면 다시 숨김. Edit 배치는 그대로.
  3. 보관함: Storage·Label_Storage 항상 숨김, Inventory 프롬프트 연결 제거. 화면 오른쪽 "내 미사일 [B]" 버튼(어디서나). 글자 "보관함" → "내 미사일"/"내 데이터"(서버 메시지 11곳).
  4. Win: WorldProgressClient의 "누적 Win" 줄 삭제, 2월드 버튼 "2월드 · 1월드 완파 필요". (서버 Win 규칙은 그대로 — 제거 구현은 밸런스 작업 때)
  5·6. 낮·밤: 12시 알약 표시(☀ 낮 / 🌙 밤 · 도시 수리 + 남은 시간, 밤엔 남색). Lighting.ClockTime을 단계가 바뀌는 순간 14 / 0으로 바로 바꿈(서서히 바뀌는 계산 제거).
  7. 버기: 항상 보이던 "정찰 버기" 버튼 제거 → 보유 시에만 오른쪽 "버기 소환"(타는 중이면 "하차 [E]"). 구매 창은 기지 차고 E로.
  8. 11시 UI 이동 예정은 TODO 보류 맨 위와 WorldProgressClient 머리 주석에 기록.
  9. 코인·연구자료: 왼쪽 옆 세로 가운데, 글자 15→19, 아이콘 22→28.
  - 기타: 12시 기지 안내띠 삭제(서버 안내는 12시 아래 3초 알림), 남아 있던 서버 "부품" 글자 5곳 → 코인, 집중 공격 게이지를 동그라미 안 채우기(화면에서 네모로 보임) → 버튼 아래 둥근 막대. UIPreview 4개(옛 배치) 삭제, PetMissileHUD 미리보기 갱신.
  - Codex 아이콘: UIAssets focusSkill=rbxassetid://109239933150633(미사일 3발), research=rbxassetid://105888631454719(평면 설계도).
- 검증(실제 실행, Play 1인 Mock): 시작 때 Base_1 Layout 0/249 보임·생산기 숨김·차고 프롬프트 꺼짐 → E 차지 후 238개 보임·생산기·차고 프롬프트 켜짐·보관함 계속 숨김, 알림 "기지를 차지했습니다!…"(docs/base-built-after-claim.jpg). 프롬프트 카드 생성(기지 차지/빈 기지 1/E) — 화면 캡처는 AlwaysOnTop 표시를 못 찍어 잠시 끄고 확인. 제작 1회 → "내 미사일 1개 · 장착 1/10"(docs/hud-layout-v2.jpg). Win 글자 0개. 낮 ClockTime 14 유지 → 밤 되는 순간 0(docs/night-instant.jpg). 버기 미보유 시 소환 버튼 숨김. 새 아이콘 두 개 표시(집중 공격 아이콘은 첫 Play에서 빈 칸, 다시 Play하니 표시 — 새 이미지 첫 요청 현상). Stop 후 Edit 복귀.
- 미검증: 버기 구매 후 소환 버튼, 휴대폰 터치로 프롬프트 카드 누르기, 2인 이상에서 남의 기지 표시, 왼쪽 패널과 코인 칸이 작은 화면에서 겹치는지. 콘솔의 rbxassetid://203785492 형식 오류는 이번 변경 전부터 있던 것(출처 미확인).
- 추가(같은 날): Codex 최종안으로 Studio UIAssets focusSkill을 rbxassetid://72548406471009(화살표 2개 + 미사일 3발 = 전탄 재장전)로 교체, PetMissileHUD 미리보기 아이콘도 교체. Play에서 6시 버튼에 표시 확인. Stop 후 Edit 복귀.
