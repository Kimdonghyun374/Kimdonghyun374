# RPG 1번 키·가운데 버튼 + 효과음 음량 (2026-11-15 KST, Claude)

Place 122289987934213 Edit. 백업 `ServerStorage.ProjectMSBackups.BeforeRpgCenterSounds_1794670262`.

- `ReplicatedStorage.PetMissiles.HudLayout`: `PistolEquip`은 PC·모바일 모두 `(화면 가운데, 아래 여백 + 버튼 반지름)`.
- `StarterPlayerScripts.SocialClient`: `EQUIP_KEYS = { One, KeypadOne }`(옛 G 대신), 배지 "1". 로켓 발사 때 `GameSounds.PlayAt("RpgLaunch", origin)`, 폭발 때 `PlayAt("RpgExplosion", position)`.
- `ReplicatedStorage.PetMissiles.GameSounds`: `GameSounds.MasterVolume = 3`, `sound.Volume = min(volume × MasterVolume, 3)`, 공간 감쇠 30~260 stud, RpgLaunch/RpgExplosion 정의 추가.
- 소리가 아직 작거나 크면 `MasterVolume` 하나만 바꾸면 됨(개별 값은 각 정의의 volume).

## 추가: 사실적인 바주카 외형 + 진지한 소리 (같은 날)
- 백업 `ServerStorage.ProjectMSBackups.BeforeRealBazooka_1794671167`(도구·GameSounds).
- `StarterPack.장난 RPG.ArtDetails`를 파트 26개로 새로 만듦: 올리브 금속 발사관, 나무 열 차폐판 + 강철 고리, 3단으로 벌어지는 뒤 분사구, 관 밖으로 나온 성형작약 탄두(목·몸통·테이퍼·신관·띠), 검은 앞뒤 손잡이·방아쇠, 왼쪽 조준경(렌즈 Glass)·가늠쇠·가늠자, 멜빵 고리. 모두 Handle에 WeldConstraint, Massless·충돌/조회 끔. Muzzle (0,0.5,-3.0).
- Blender MCP는 연결돼 있지만(애드온 프로토콜 13, 최신 16) 메시를 Roblox로 올리는 도구가 없어 Studio 파트로 제작.
- 소리: RpgLaunch·RpgExplosion을 Roblox 기본 내장 `rbxasset://sounds/impact_explosion_03.mp3`로 교체(발사 속도 1.55·0.35, 폭발 속도 0.8·0.75). 다른 게임에서 뜯어 온 듯한 마켓 소리는 쓰지 않음. GameSounds가 글자 id·`speed`를 받도록 확장.
- 화면: [bazooka-real-pc.jpg](bazooka-real-pc.jpg)
