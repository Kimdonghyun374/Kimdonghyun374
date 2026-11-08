# AGENTS.md — ProjectMS 에이전트 시작 안내

Codex 등 AI 에이전트가 이 저장소에서 작업을 시작할 때 자동으로 읽는 파일입니다.
상세 작업 규칙의 원문은 [agent.md](agent.md)이며, 이 파일과 충돌하면 agent.md를 따릅니다.

## 작업 시작 전 (매번)

1. 실행 컴퓨터(hostname)와 실제 프로젝트 절대 경로를 확인합니다.
   - Windows 주 작업 레포: `C:\ProjectMS` / Mac 레포: `/Users/dongdong/projectMS`
2. `git fetch` → `git status -sb`. 원격이 앞서 있으면 `git pull --ff-only`. 미커밋·미푸시 변경이 있으면 먼저 사용자에게 알립니다.
3. 아래 순서로 읽습니다.
   - [TODO.md](TODO.md) — 현재 할 일의 기준 목록 (모든 에이전트 공용)
   - [HISTORY.md](HISTORY.md) 끝부분 — 최근 작업과 남은 일
   - [CLAUDE.md](CLAUDE.md) 2~4절 — 위치·게임 현재 상태·미검증 항목 (Claude용이지만 상태 정리는 공용으로 사용)
   - 기획: [docs/GDD_v0.3.md](docs/GDD_v0.3.md), [docs/LEVEL_DESIGN_v0.3.md](docs/LEVEL_DESIGN_v0.3.md)

## 작업 중

- TODO.md의 항목을 맡으면 **진행 중**으로 옮기고 `(담당, 시작일)`을 적어 바로 커밋·푸시합니다. 다른 에이전트가 같은 폴더·같은 파일을 동시에 고치지 않게 하기 위함입니다.
- 게임의 진실의 원천은 **Roblox Studio Place 122289987934213의 Edit DataModel**입니다. 레포의 문서·사본을 고쳐도 Studio에는 반영되지 않습니다.
- Studio 수정 전에는 `ServerStorage.ProjectMSBackups.Before*_<timestamp>`에 백업하고, Play 검증 후 Edit 복귀·임시 러너 제거를 확인합니다.
- Studio Save/Publish, 게시 설정 변경은 사용자 지시 없이 하지 않습니다.

## 작업 후

- `HISTORY.md`에 KST 날짜·실행 컴퓨터·목적·변경 파일·검증 결과·남은 작업을 덧붙입니다. 실행하지 않은 검증은 성공으로 쓰지 않습니다.
- TODO.md 항목을 **완료**로 옮기고 `(담당, 날짜, 커밋)`을 적습니다. 새로 발견한 일은 다음 후보·보류에 추가합니다.
- 작업 단위 하나가 끝나면 커밋하고 바로 푸시합니다. 푸시가 거절되면 강제 푸시하지 말고 pull 후 다시 시도합니다.

## 올리지 않는 것

- `*.rbxl`, `*.rbxlx` (Part_Icles 재배포 금지 라이선스), `.mcp.json`(컴퓨터별 설정)
- 비밀번호·토큰·API 키·실제 플레이어 데이터(사용자 ID·이름 포함)
