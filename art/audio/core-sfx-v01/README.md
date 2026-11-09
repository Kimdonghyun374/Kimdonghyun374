# ProjectMS 필수 효과음 v01

2026-11-10 KST. 첫 제작과 파괴 루프를 들리게 만드는 원본 합성 효과음 10종. 외부 샘플 미사용. 모두 44.1kHz, 모노, 16비트 PCM WAV. 포맷·파일별 신호·클리핑·중복 검증 완료. 게임에서의 청취와 믹스 검증은 Studio 연결 후 진행한다.

| 파일 | 역할 | Claude 적용 지점 | 길이 (초) | 초기 Volume | 재생 |
|---|---|---|---:|---:|---|
| [missile-launch.wav](missile-launch.wav) | 미사일 발사 | `PetMissileClient` / `Visual("Spawn", data)`에서 실제 신규 비행만. 입장 동기화로 받은 기존 비행과 중복 ID는 제외. | .30 | 0.20 | 공간 |
| [missile-impact.wav](missile-impact.wav) | 미사일 명중 | `PetMissileClient` / `Visual("End", data)`의 명중일 때만, `data.position` 기준. | .27 | 0.22 | 공간 |
| [building-collapse.wav](building-collapse.wav) | 건물 붕괴 | `SalvageClient` / `Visual("BuildingCollapse", data)` 처리 지점. 건물별 실제 붕괴 1회. | 1.15 | 0.38 | 공간 |
| [focus-reload.wav](focus-reload.wav) | 전탄 재장전 | `PetMissileClient` / 서버가 승인해 내 집중 공격 게이지가 가득 → 소진될 때 1회. 초기 동기화·거절·개별 미사일 재장전 제외. | .54 | 0.30 | 로컬 |
| [craft-start.wav](craft-start.wav) | 제작 시작 | `MissileBaseClient.handleBaseState` / 서버가 승인한 제작 예약이 새로 생길 때 1회. 최초 동기화에서 이미 진행 중인 작업은 제외. | .32 | 0.24 | 로컬 |
| [craft-ready.wav](craft-ready.wav) | 제작 완료 | `MissileBaseClient.handleBaseState` / 서버가 새 제작 결과 `result`를 전달할 때 1회. | .56 | 0.28 | 로컬 |
| [coin-pickup.wav](coin-pickup.wav) | 코인 획득 | `SalvageClient` / 기존 획득 알림에서 확정된 코인 수령. 초기 잔액 동기화와 구매·환급 제외. | .23 | 0.18 | 로컬 |
| [research-pickup.wav](research-pickup.wav) | 연구자료 획득 | `SalvageClient` / 기존 획득 알림에서 확정된 연구자료 수령. | .36 | 0.24 | 로컬 |
| [ui-confirm.wav](ui-confirm.wav) | UI 클릭 확인 | 실제로 열린 보관함·차고 또는 닫기 같은 즉시 처리 버튼. 제작·발사 등 전용음이 있는 액션은 생략. | .13 | 0.13 | 로컬 |
| [ui-denied.wav](ui-denied.wav) | 행동 불가 | 기존 HUD가 서버의 실제 거절 결과를 표시할 때 1회. 정보·성공 메시지는 제외. | .24 | 0.17 | 로컬 |

## Claude 적용 순서

1. WAV 10개를 ProjectMS 소유자로 업로드하고 심사 승인된 Audio ID를 기록한다. Studio Asset Manager 또는 승인된 MCP 업로드를 사용할 수 있다. 오디오의 경험 사용 권한을 확인한 다음 각 SoundId를 `rbxassetid://<Audio ID>`로 연결한다. 현재 MCP 업로드는 이 폴더 권한을 기다리는 중이다.
2. 발사 → 명중 → 붕괴 → 코인 획득을 먼저 연결한다. 공간 음원은 로컬에서 발사 원점과 명중·붕괴 위치의 Attachment나 임시 고정 파트에 놓고 짧은 거리 감쇠를 준다. UI, 제작, 전탄 재장전, 획득 확인은 해당 플레이어에게만 재생한다.
3. 같은 연사에서 발사음은 최소 0.12초, 명중음은 최소 0.10초 간격을 권장한다. 건물 붕괴는 개별 파편마다 재생하지 않는다. 같은 종류의 획득음은 0.12초 창에서 묶고, 코인과 연구자료를 동시에 얻으면 연구자료 소리를 우선한다. `SalvageClient`의 기존 `volume_slider.ogg`를 중복 재생하지 않도록 교체한다.
4. 기존 상태·이벤트에서 재생 조건을 확정한다. 실제 승인된 제작·획득·전탄 재장전만 사용하고, 게이지를 채우는 모든 일반 명중에 재장전음을 붙이지 않는다. 같은 이벤트를 별도 스크립트에서도 재생 중인지 확인한다.
5. Play에서 첫 제작, 전탄 재장전, 10발 연사, 동시 명중·붕괴, 코인 묶음 획득, 연구자료 획득, 거리 감쇠, 다른 플레이어의 개인 도시를 확인한다. 모바일 스피커와 헤드폰에서 붕괴 소리가 UI를 덮는지도 듣고 초기 볼륨을 조정한다.

현행 Studio 확인 결과는 Workspace의 기존 Acid Factory 음원과 SalvageClient의 임시 획득음이다. 배경음과 미구현 보스 음향은 후속 범위다.

## Roblox Audio ID (2026-11-10 Claude 업로드, 크리에이터 = 게임 소유자 계정)

업로드 직후 심사 상태는 모두 Reviewing. Studio 연결: `ReplicatedStorage.PetMissiles.GameSounds`.

| 파일 | Audio ID |
|---|---|
| missile-launch.wav | 94657847914345 |
| missile-impact.wav | 77079096464259 |
| building-collapse.wav | 72243191624765 |
| focus-reload.wav | 126163575722020 |
| craft-start.wav | 116872432641263 |
| craft-ready.wav | 111699975181294 |
| coin-pickup.wav | 82821946308198 |
| research-pickup.wav | 109467954291666 |
| ui-confirm.wav | 79822285221419 |
| ui-denied.wav | 94748098678438 |
