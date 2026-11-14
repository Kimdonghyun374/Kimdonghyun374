# Roblox 업로드한 UI 이미지 (2026-11-14 KST, Claude)

사용자 지시("업로드해보세요")로 Studio MCP `upload_image`를 써서 주인 계정에 올림. 모두 Studio에서 내려받기 성공(AssetFetchStatus.Success)·화면 표시(투명 배경) 확인.
**아직 게임 UI에 연결하지 않음** — 이미지 ID만 확보.

## 교체 키트 아틀라스 6장 (`replacement-kit/`)
Roblox 이미지 한도(긴 변 1024px) 때문에 미리 줄여서 올림. 좌표는 `ReplacementAssets.luau`의 `AtlasScale`을 곱해야 함(`Assets.Rect(이름)` 함수가 계산).

| 아틀라스 | 원본 → 업로드 | asset ID |
| --- | --- | --- |
| panels-atlas | 1448×1086 → 1024×768 | rbxassetid://99924773812428 |
| buttons-atlas | 1448×1086 → 1024×768 | rbxassetid://92891561815809 |
| controls-atlas | 1448×1086 → 1024×768 | rbxassetid://140727097324649 |
| rarity-cards-atlas | 1774×887 → 1024×512 | rbxassetid://98788508085513 |
| utility-icons-atlas | 1254×1254 → 1024×1024 | rbxassetid://90453225345501 |
| core-icons-atlas | 1448×1086 → 1024×768 | rbxassetid://117548738752799 |

## RPG·버기 아이콘 6장 (`rpg-buggy-v02/`, 원본: Codex 미러 outputs/ui-rpg-v02 투명본)
512×512 칸별로 잘라 개별 업로드(축소 없음).

| 아이콘 | asset ID |
| --- | --- |
| rpg | rbxassetid://81808321300866 |
| rpg_equipped | rbxassetid://127325095571385 |
| rpg_fire | rbxassetid://97729511215410 |
| buggy | rbxassetid://121910566868594 |
| buggy_riding | rbxassetid://99824442589377 |
| buggy_dismount | rbxassetid://109535864539713 |

`current-map-ui-example.png`, `pc-hud-rpg-v02.png`, `mobile-hud-rpg-v02.png`는 컨셉 예시라 올리지 않음.

## 게임 연결 (2026-11-14, 1차: 아이콘)
- 새 모듈 `ReplicatedStorage.PetMissiles.UIImages` (위 ID·AtlasScale·Sprites·Icons + `Rect`/`Apply`).
- 연결: 집중 발사 → icon_focus, RPG 버튼 → rpg / 장착 중 rpg_equipped(+"장착 중"), 모바일 발사 → rpg_fire, 미사일 메뉴 → icon_missiles,
  탈것 메뉴 → buggy / 타는 중 buggy_dismount, 코인 → icon_coins, 연구자료 → icon_research_data, 제작 버튼 → icon_craft. 실패하면 옛 아이콘으로 돌아감.
- Edit 미리보기도 같은 아이콘. 화면: [applied-pc-2026-11-14.jpg](applied-pc-2026-11-14.jpg)
- 아직 안 쓴 것: 패널·버튼·게이지·희귀도 카드·레이드 배너 등 바탕 이미지(9-slice 크기 검증 필요).
