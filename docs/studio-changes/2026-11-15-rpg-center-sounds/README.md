# RPG 1번 키·가운데 버튼 + 효과음 음량 (2026-11-15 KST, Claude)

Place 122289987934213 Edit. 백업 `ServerStorage.ProjectMSBackups.BeforeRpgCenterSounds_1794670262`.

- `ReplicatedStorage.PetMissiles.HudLayout`: `PistolEquip`은 PC·모바일 모두 `(화면 가운데, 아래 여백 + 버튼 반지름)`.
- `StarterPlayerScripts.SocialClient`: `EQUIP_KEYS = { One, KeypadOne }`(옛 G 대신), 배지 "1". 로켓 발사 때 `GameSounds.PlayAt("RpgLaunch", origin)`, 폭발 때 `PlayAt("RpgExplosion", position)`.
- `ReplicatedStorage.PetMissiles.GameSounds`: `GameSounds.MasterVolume = 3`, `sound.Volume = min(volume × MasterVolume, 3)`, 공간 감쇠 30~260 stud, RpgLaunch/RpgExplosion 정의 추가.
- 소리가 아직 작거나 크면 `MasterVolume` 하나만 바꾸면 됨(개별 값은 각 정의의 volume).
