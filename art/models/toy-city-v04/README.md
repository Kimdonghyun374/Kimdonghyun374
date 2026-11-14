# Toy City v04 제작 키트

Studio에 적용한 Part 조형을 기반으로 만든 Blender5.2.3LTS 제작 원본. 주택·사무실·기술실·AFK 연구동·제작기5종, Part248개. art/references/toy-city-v03의 흰 외벽·파란 프레임·원색 포인트 기준.

- toy-city-v04-kit.blend: 별도 ProjectMS_ToyCity_v04 장면. 기존 Scene/Cube/Camera/Light는 별도 장면에 보존.
- toy-city-v04-kit.glb: 새 제작 장면의 메시만 내보낸 컬러 모델. 기존 Cube·무대 바닥/조명/카메라는 제외.
- toy-city-v04-kit.png: Blender 렌더이며 실제 Studio 화면과 구분.
- kit-specs.json: 게임 Part의 상대 CFrame·크기·색상·Shape.
- build_kit.py: Blender에서 새 제작 장면과 파일을 다시 만드는 스크립트.

게임에는 docs/studio-changes/2026-11-14-visual-upgrade/ArtKit.luau의 Part 조립 외형이 적용됐다. Blender의 추가 베벨을 포함한 GLB를 Roblox에 업로드/대체 삽입한 것으로 표기하지 않는다. 1stud=0.18 Blender unit은 제작 키트 비교용이며 게임 판정 치수는 변경하지 않았다. 미사일 메시·Part_Icles는 이 키트에 포함하지 않는다.
