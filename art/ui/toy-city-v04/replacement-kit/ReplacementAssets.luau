-- 72개 이미지 부품의 실제 픽셀 좌표. 각 Images 항목에 업로드한 Image asset ID를 넣습니다.
-- ImageRect 좌표만 제공하며 9-slice SliceCenter는 실제 UI 크기에서 검증해야 합니다.
-- 2026-11-14 Claude 업로드: Roblox 이미지 한도(긴 변 1024px)에 맞춰 각 아틀라스를 미리 줄여 올렸습니다.
-- 아래 Sprites 좌표는 원본 픽셀 기준이므로 실제로 쓸 때는 Offset·Size에 AtlasScale을 곱해야 합니다(Assets.Rect 사용).
local Assets = {
    Images = {
        ["panels-atlas"] = "rbxassetid://99924773812428",
        ["buttons-atlas"] = "rbxassetid://92891561815809",
        ["controls-atlas"] = "rbxassetid://140727097324649",
        ["rarity-cards-atlas"] = "rbxassetid://98788508085513",
        ["utility-icons-atlas"] = "rbxassetid://90453225345501",
        ["core-icons-atlas"] = "rbxassetid://117548738752799",
    },
    -- 업로드본 크기 / 원본 크기 (원본 1448×1086 → 1024×768 등)
    AtlasScale = {
        ["panels-atlas"] = Vector2.new(1024 / 1448, 768 / 1086),
        ["buttons-atlas"] = Vector2.new(1024 / 1448, 768 / 1086),
        ["controls-atlas"] = Vector2.new(1024 / 1448, 768 / 1086),
        ["rarity-cards-atlas"] = Vector2.new(1024 / 1774, 512 / 887),
        ["utility-icons-atlas"] = Vector2.new(1024 / 1254, 1024 / 1254),
        ["core-icons-atlas"] = Vector2.new(1024 / 1448, 768 / 1086),
    },
    -- RPG·버기 아이콘(Codex outputs/ui-rpg-v02 투명본을 512px 칸별로 잘라 개별 업로드, 축소 없음)
    Icons = {
        rpg = "rbxassetid://81808321300866",
        rpg_equipped = "rbxassetid://127325095571385",
        rpg_fire = "rbxassetid://97729511215410",
        buggy = "rbxassetid://121910566868594",
        buggy_riding = "rbxassetid://99824442589377",
        buggy_dismount = "rbxassetid://109535864539713",
    },
    Sprites = {
        modal_blue = { Atlas = "panels-atlas", Offset = Vector2.new(39, 126), Size = Vector2.new(307, 297) },
        modal_gold = { Atlas = "panels-atlas", Offset = Vector2.new(393, 126), Size = Vector2.new(308, 297) },
        modal_red = { Atlas = "panels-atlas", Offset = Vector2.new(747, 126), Size = Vector2.new(308, 297) },
        modal_slate = { Atlas = "panels-atlas", Offset = Vector2.new(1102, 126), Size = Vector2.new(307, 297) },
        hud_blue = { Atlas = "panels-atlas", Offset = Vector2.new(30, 536), Size = Vector2.new(323, 160) },
        hud_slate = { Atlas = "panels-atlas", Offset = Vector2.new(385, 535), Size = Vector2.new(323, 159) },
        toast_blue = { Atlas = "panels-atlas", Offset = Vector2.new(737, 547), Size = Vector2.new(326, 139) },
        toast_green = { Atlas = "panels-atlas", Offset = Vector2.new(1091, 547), Size = Vector2.new(329, 139) },
        toast_red = { Atlas = "panels-atlas", Offset = Vector2.new(28, 836), Size = Vector2.new(329, 137) },
        prompt_blue = { Atlas = "panels-atlas", Offset = Vector2.new(389, 819), Size = Vector2.new(317, 168) },
        boss_banner = { Atlas = "panels-atlas", Offset = Vector2.new(738, 816), Size = Vector2.new(325, 172) },
        resource_capsule = { Atlas = "panels-atlas", Offset = Vector2.new(1090, 839), Size = Vector2.new(331, 131) },
        blue_normal = { Atlas = "buttons-atlas", Offset = Vector2.new(22, 130), Size = Vector2.new(331, 164) },
        blue_pressed = { Atlas = "buttons-atlas", Offset = Vector2.new(380, 133), Size = Vector2.new(330, 157) },
        blue_disabled = { Atlas = "buttons-atlas", Offset = Vector2.new(737, 131), Size = Vector2.new(330, 163) },
        yellow_normal = { Atlas = "buttons-atlas", Offset = Vector2.new(1094, 130), Size = Vector2.new(332, 164) },
        yellow_pressed = { Atlas = "buttons-atlas", Offset = Vector2.new(23, 470), Size = Vector2.new(331, 157) },
        yellow_disabled = { Atlas = "buttons-atlas", Offset = Vector2.new(379, 468), Size = Vector2.new(332, 162) },
        red_normal = { Atlas = "buttons-atlas", Offset = Vector2.new(737, 466), Size = Vector2.new(332, 165) },
        red_pressed = { Atlas = "buttons-atlas", Offset = Vector2.new(1094, 469), Size = Vector2.new(332, 159) },
        red_disabled = { Atlas = "buttons-atlas", Offset = Vector2.new(22, 807), Size = Vector2.new(332, 163) },
        green_normal = { Atlas = "buttons-atlas", Offset = Vector2.new(379, 804), Size = Vector2.new(332, 166) },
        green_pressed = { Atlas = "buttons-atlas", Offset = Vector2.new(737, 808), Size = Vector2.new(332, 159) },
        green_disabled = { Atlas = "buttons-atlas", Offset = Vector2.new(1093, 807), Size = Vector2.new(334, 162) },
        focus_normal = { Atlas = "controls-atlas", Offset = Vector2.new(45, 61), Size = Vector2.new(284, 295) },
        focus_pressed = { Atlas = "controls-atlas", Offset = Vector2.new(403, 61), Size = Vector2.new(286, 295) },
        focus_disabled = { Atlas = "controls-atlas", Offset = Vector2.new(756, 61), Size = Vector2.new(288, 296) },
        gauge_track = { Atlas = "controls-atlas", Offset = Vector2.new(1096, 146), Size = Vector2.new(332, 117) },
        gauge_blue = { Atlas = "controls-atlas", Offset = Vector2.new(26, 496), Size = Vector2.new(315, 91) },
        gauge_gold = { Atlas = "controls-atlas", Offset = Vector2.new(385, 496), Size = Vector2.new(316, 91) },
        gauge_red = { Atlas = "controls-atlas", Offset = Vector2.new(743, 496), Size = Vector2.new(319, 91) },
        raid_badge_blank = { Atlas = "controls-atlas", Offset = Vector2.new(1124, 404), Size = Vector2.new(277, 294) },
        tab_active = { Atlas = "controls-atlas", Offset = Vector2.new(27, 823), Size = Vector2.new(314, 162) },
        tab_inactive = { Atlas = "controls-atlas", Offset = Vector2.new(386, 824), Size = Vector2.new(314, 161) },
        selection_gold = { Atlas = "controls-atlas", Offset = Vector2.new(756, 752), Size = Vector2.new(294, 298) },
        keycap_blank = { Atlas = "controls-atlas", Offset = Vector2.new(1142, 788), Size = Vector2.new(240, 233) },
        card_common = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(106, 23), Size = Vector2.new(328, 406) },
        card_uncommon = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(519, 23), Size = Vector2.new(327, 406) },
        card_rare = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(929, 23), Size = Vector2.new(328, 406) },
        card_epic = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(1340, 23), Size = Vector2.new(329, 406) },
        card_legendary = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(104, 459), Size = Vector2.new(331, 407) },
        card_mythic = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(517, 459), Size = Vector2.new(330, 407) },
        card_cosmic = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(926, 459), Size = Vector2.new(332, 407) },
        card_locked = { Atlas = "rarity-cards-atlas", Offset = Vector2.new(1339, 459), Size = Vector2.new(331, 407) },
        world = { Atlas = "utility-icons-atlas", Offset = Vector2.new(26, 34), Size = Vector2.new(274, 272) },
        pistol = { Atlas = "utility-icons-atlas", Offset = Vector2.new(339, 65), Size = Vector2.new(262, 220) },
        sun = { Atlas = "utility-icons-atlas", Offset = Vector2.new(643, 36), Size = Vector2.new(282, 270) },
        moon = { Atlas = "utility-icons-atlas", Offset = Vector2.new(965, 60), Size = Vector2.new(254, 239) },
        clock = { Atlas = "utility-icons-atlas", Offset = Vector2.new(42, 337), Size = Vector2.new(244, 297) },
        lock = { Atlas = "utility-icons-atlas", Offset = Vector2.new(356, 347), Size = Vector2.new(228, 265) },
        unlock = { Atlas = "utility-icons-atlas", Offset = Vector2.new(663, 344), Size = Vector2.new(256, 267) },
        close = { Atlas = "utility-icons-atlas", Offset = Vector2.new(967, 352), Size = Vector2.new(259, 256) },
        check = { Atlas = "utility-icons-atlas", Offset = Vector2.new(37, 688), Size = Vector2.new(267, 222) },
        back = { Atlas = "utility-icons-atlas", Offset = Vector2.new(344, 685), Size = Vector2.new(254, 216) },
        equipped = { Atlas = "utility-icons-atlas", Offset = Vector2.new(649, 653), Size = Vector2.new(260, 260) },
        sell = { Atlas = "utility-icons-atlas", Offset = Vector2.new(957, 673), Size = Vector2.new(269, 230) },
        warning = { Atlas = "utility-icons-atlas", Offset = Vector2.new(26, 974), Size = Vector2.new(275, 243) },
        touch = { Atlas = "utility-icons-atlas", Offset = Vector2.new(354, 952), Size = Vector2.new(225, 282) },
        jump = { Atlas = "utility-icons-atlas", Offset = Vector2.new(650, 965), Size = Vector2.new(262, 266) },
        raid = { Atlas = "utility-icons-atlas", Offset = Vector2.new(959, 958), Size = Vector2.new(272, 282) },
        icon_shop = { Atlas = "core-icons-atlas", Offset = Vector2.new(0, 0), Size = Vector2.new(362, 362) },
        icon_missiles = { Atlas = "core-icons-atlas", Offset = Vector2.new(362, 0), Size = Vector2.new(362, 362) },
        icon_codex = { Atlas = "core-icons-atlas", Offset = Vector2.new(724, 0), Size = Vector2.new(362, 362) },
        icon_research = { Atlas = "core-icons-atlas", Offset = Vector2.new(1086, 0), Size = Vector2.new(362, 362) },
        icon_craft = { Atlas = "core-icons-atlas", Offset = Vector2.new(0, 362), Size = Vector2.new(362, 362) },
        icon_base = { Atlas = "core-icons-atlas", Offset = Vector2.new(362, 362), Size = Vector2.new(362, 362) },
        icon_garage = { Atlas = "core-icons-atlas", Offset = Vector2.new(724, 362), Size = Vector2.new(362, 362) },
        icon_upgrade = { Atlas = "core-icons-atlas", Offset = Vector2.new(1086, 362), Size = Vector2.new(362, 362) },
        icon_coins = { Atlas = "core-icons-atlas", Offset = Vector2.new(0, 724), Size = Vector2.new(362, 362) },
        icon_research_data = { Atlas = "core-icons-atlas", Offset = Vector2.new(362, 724), Size = Vector2.new(362, 362) },
        icon_focus = { Atlas = "core-icons-atlas", Offset = Vector2.new(724, 724), Size = Vector2.new(362, 362) },
        icon_settings = { Atlas = "core-icons-atlas", Offset = Vector2.new(1086, 724), Size = Vector2.new(362, 362) },
    },
}

-- 스프라이트 이름 → (이미지 ID, 업로드본 기준 ImageRectOffset, ImageRectSize)
function Assets.Rect(spriteName)
    local sprite = Assets.Sprites[spriteName]
    if not sprite then
        return nil
    end
    local scale = Assets.AtlasScale[sprite.Atlas]
    local offset = Vector2.new(math.floor(sprite.Offset.X * scale.X + 0.5), math.floor(sprite.Offset.Y * scale.Y + 0.5))
    local size = Vector2.new(math.floor(sprite.Size.X * scale.X + 0.5), math.floor(sprite.Size.Y * scale.Y + 0.5))
    return Assets.Images[sprite.Atlas], offset, size
end

return Assets
