# 맵 색감 수정 — 밝은 하이키·차가운 콘크리트·Baseplate 체크 바닥 (2026-11-14 KST, Claude)

게임 Place 122289987934213, Edit. 사용자 요청: "푸르딩딩함"을 없애고, 보내 준 예시처럼
**밝고 깨끗한 바탕 + 넓은 곳에 Baseplate 같은 체크 바닥 + 색은 물체에만**. 벽은 차가운 콘크리트.

전후 화면: `before-city.jpg`·`before-plaza.jpg` → `after-city.jpg`·`after-street.jpg`.

## 바꾼 것

### Lighting
| 항목 | 전 | 후 |
| --- | --- | --- |
| Ambient | 105,122,153 | 160,164,172 |
| OutdoorAmbient | 144,158,184 | 212,215,221 |
| ColorShift_Top | 0,0,0 | 255,244,226 (햇빛 살짝 따뜻하게) |
| Brightness | 2.5 | 2.6 |
| ExposureCompensation | 0.05 | 0.25 |
| EnvironmentDiffuseScale | 0.7 | 0.25 (파란 하늘이 그늘을 물들이는 것 줄임) |
| Atmosphere Color / Decay | 192,216,250 / 151,181,222 | 226,234,243 / 205,216,230 |
| Atmosphere Density / Haze / Glare | 0.18 / 0.6 / ? | 0.3 / 1.2 / 0 (먼 곳을 흰빛으로) |
| 새 ColorCorrectionEffect `MapColorGrade` | 없음 | Saturation 0.12, Contrast 0.03 |

### 색 (Workspace + ServerStorage 템플릿, 백업 폴더 제외. Codex 팔레트와 **정확히 같은 색**만)
| 전 | 후 | 주로 쓰인 곳 |
| --- | --- | --- |
| 240,245,251 흰 | 214,217,221 밝은 차가운 콘크리트 | 건물 외벽(HumanoidRootPart), 기지 2층 바닥, 연석 |
| 221,231,243 연청 | 234,236,239 | 광장·구역 바닥, 층 띠, 지붕 테두리 |
| 198,212,229 | 174,178,183 | 기초 테두리, 기지 둘레, 차고 발판 |
| 108,177,232 하늘색 유리 | 126,146,163 청회색 유리 | 창문, 구역 문 |
| 48,112,224 파랑 | 76,82,92 짙은 슬레이트 | 창틀·창턱·문 기둥 등 |
| 48,112,224 (이름 Roof·ResearchRoofCap·GarageAwning) | 빨강·노랑·초록·하늘·주황 5종을 위치로 돌려 씀 | 지붕 37개 |
| 30,65,123 / 62,80,108 | 54,60,70 / 68,72,79 | 문틀, 로봇 팔 |
| 98,117,145 | 122,126,132 | 도로 |
| 209,224,235 / 179,200,226 | 231,233,236 / 206,210,216 | 구역3 바닥 / 레이드 바닥 |
| 166,197,170 연녹 | 228,231,235 | Baseplate·BaseplateExtension |

바뀐 파트 5,567개 + 지붕 37개. 빨강·노랑·초록 포인트는 그대로.

### Baseplate 체크 바닥
Roblox 기본 Baseplate 텍스처 `rbxassetid://6372755229`(8×8 stud, 투명도 0.6)를 윗면에 깜:
Baseplate(기존 Texture 투명도 1→0.6), BaseplateExtension 4, PlazaFloor, RaidFloor, Zone1~4_Ground(대로 6개), Base_1~6.Floor. 새 Texture 이름은 `BaseGrid`(속성 MapColorGrade=true).

### ArtKit (`ReplicatedStorage.PetMissiles.ArtKit`)
`Kit.Colors`의 White·Concrete·Pale·Blue·DeepBlue·Glass·Dark·Road를 위 새 값으로(줄마다 옛 값 주석). 실행 중 만들어지는
장식도 같은 색이 되게 하기 위함. 키 이름은 다른 스크립트 호환 때문에 그대로(Blue가 이제 슬레이트색). UpdateSourceAsync + .Source, 편집기=Source 확인.

## 백업·되돌리기
`ServerStorage.ProjectMSBackups.BeforeMapColorGrade_1794650905`: LightingValues(속성), LightingChildren(복제), ArtKit 원본, ColorMapNote(매핑).
색은 매핑을 거꾸로 적용하면 되돌아감. 단 지붕 37개는 사탕색 중 일부가 기존 포인트 색과 같아 이름(Roof 등)+위치로 골라 되돌려야 함.

## 검증
- Edit 화면 캡처 전후 비교(도시·거리). 광장 전체 캡처는 중간에 Studio 뷰포트가 검게 나와 **후 화면은 도시·거리만** 확보.
- Play 1회: 서버에서 새 Lighting·ArtKit 값·BaseGrid 36개 확인, 콘솔은 기존 203785492 경고만. Play 화면 3D 캡처는 도구가 HUD만 반환.
- 실제 플레이 동선·밤 화면·모바일 화면은 미확인. Save/Publish 안 함.

## Codex에게 (사용자 요청)
**지금 이 맵을 기준으로 컨셉아트(레퍼런스)를 다시 뽑아 주세요.** v03(흰 외벽·파란 프레임·푸른 낮빛)은 더 이상 기준이 아닙니다.
- 바탕: 밝은 하이키, 넓은 바닥 전체에 Baseplate 같은 연회색 체크, 먼 곳은 흰빛 안개
- 건물: 밝은 차가운 콘크리트 벽 + 슬레이트 창틀 + 사탕색 지붕·차양
- 파랑은 하늘과 일부 포인트에만, 그늘은 푸르지 않게
- 사용자 예시 느낌: 흰 체크 바닥 위에 노랑·하늘·분홍 사탕색 물체가 또렷한 Roblox 시뮬레이터 화면
- UI 레퍼런스(왼쪽 세로 큰 아이콘 버튼, 두꺼운 남색 테두리, 흰 글자+검은 외곽선)도 이 바탕 위에서 보이게
