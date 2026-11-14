-- 업로드 전 UI 아트 좌표표. Image에는 아틀라스의 실제 Image asset ID를 넣습니다.
local Atlas = {
    Image = "",
    CellSize = Vector2.new(362, 362),
    Icons = {
        shop = { Offset = Vector2.new(0, 0), Size = Vector2.new(362, 362) }, -- 상점
        missiles = { Offset = Vector2.new(362, 0), Size = Vector2.new(362, 362) }, -- 미사일
        codex = { Offset = Vector2.new(724, 0), Size = Vector2.new(362, 362) }, -- 도감
        research = { Offset = Vector2.new(1086, 0), Size = Vector2.new(362, 362) }, -- 연구
        craft = { Offset = Vector2.new(0, 362), Size = Vector2.new(362, 362) }, -- 제작
        base = { Offset = Vector2.new(362, 362), Size = Vector2.new(362, 362) }, -- 기지
        garage = { Offset = Vector2.new(724, 362), Size = Vector2.new(362, 362) }, -- 차고
        upgrade = { Offset = Vector2.new(1086, 362), Size = Vector2.new(362, 362) }, -- 강화
        coins = { Offset = Vector2.new(0, 724), Size = Vector2.new(362, 362) }, -- 코인
        research_data = { Offset = Vector2.new(362, 724), Size = Vector2.new(362, 362) }, -- 연구자료
        focus = { Offset = Vector2.new(724, 724), Size = Vector2.new(362, 362) }, -- 집중 발사
        settings = { Offset = Vector2.new(1086, 724), Size = Vector2.new(362, 362) }, -- 설정
    },
}
return Atlas
