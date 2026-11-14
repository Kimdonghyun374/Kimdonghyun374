-- 업로드 전 이미지 패키지 좌표표. Studio에는 미설치.
local Assets = {}
Assets.Atlases = {
    ["button-backgrounds"] = { Image = "", SourceSize = Vector2.new(1536, 1024), UploadedSize = nil },
    ["resource-backgrounds"] = { Image = "", SourceSize = Vector2.new(1774, 887), UploadedSize = nil },
    ["hoverboard"] = { Image = "", SourceSize = Vector2.new(1774, 887), UploadedSize = nil },
    ["core-icons"] = { Image = "rbxassetid://117548738752799", SourceSize = Vector2.new(1448, 1086), UploadedSize = Vector2.new(1024, 768) },
    ["rpg"] = { Image = "rbxassetid://81808321300866", SourceSize = Vector2.new(512, 512), UploadedSize = Vector2.new(512, 512) },
    ["rpg_equipped"] = { Image = "rbxassetid://127325095571385", SourceSize = Vector2.new(512, 512), UploadedSize = Vector2.new(512, 512) },
    ["rpg_fire"] = { Image = "rbxassetid://97729511215410", SourceSize = Vector2.new(512, 512), UploadedSize = Vector2.new(512, 512) },
}
Assets.Sprites = {
    ["circle_blue"] = { Atlas = "button-backgrounds", Offset = Vector2.new(78, 67), Size = Vector2.new(405, 416) },
    ["circle_yellow"] = { Atlas = "button-backgrounds", Offset = Vector2.new(561, 67), Size = Vector2.new(405, 416) },
    ["circle_red"] = { Atlas = "button-backgrounds", Offset = Vector2.new(1044, 67), Size = Vector2.new(408, 416) },
    ["menu_blue"] = { Atlas = "button-backgrounds", Offset = Vector2.new(79, 553), Size = Vector2.new(406, 405) },
    ["menu_yellow"] = { Atlas = "button-backgrounds", Offset = Vector2.new(562, 553), Size = Vector2.new(405, 405) },
    ["menu_red"] = { Atlas = "button-backgrounds", Offset = Vector2.new(1043, 553), Size = Vector2.new(413, 405) },
    ["resource_coins"] = { Atlas = "resource-backgrounds", Offset = Vector2.new(329, 166), Size = Vector2.new(1116, 262) },
    ["resource_research"] = { Atlas = "resource-backgrounds", Offset = Vector2.new(329, 476), Size = Vector2.new(1116, 262) },
    ["hoverboard"] = { Atlas = "hoverboard", Offset = Vector2.new(260, 221), Size = Vector2.new(1294, 525) },
    ["icon_shop"] = { Atlas = "core-icons", Offset = Vector2.new(0, 0), Size = Vector2.new(362, 362) },
    ["icon_missiles"] = { Atlas = "core-icons", Offset = Vector2.new(362, 0), Size = Vector2.new(362, 362) },
    ["icon_codex"] = { Atlas = "core-icons", Offset = Vector2.new(724, 0), Size = Vector2.new(362, 362) },
    ["icon_research"] = { Atlas = "core-icons", Offset = Vector2.new(1086, 0), Size = Vector2.new(362, 362) },
    ["icon_craft"] = { Atlas = "core-icons", Offset = Vector2.new(0, 362), Size = Vector2.new(362, 362) },
    ["icon_base"] = { Atlas = "core-icons", Offset = Vector2.new(362, 362), Size = Vector2.new(362, 362) },
    ["icon_garage"] = { Atlas = "core-icons", Offset = Vector2.new(724, 362), Size = Vector2.new(362, 362) },
    ["icon_upgrade"] = { Atlas = "core-icons", Offset = Vector2.new(1086, 362), Size = Vector2.new(362, 362) },
    ["icon_coins"] = { Atlas = "core-icons", Offset = Vector2.new(0, 724), Size = Vector2.new(362, 362) },
    ["icon_research_data"] = { Atlas = "core-icons", Offset = Vector2.new(362, 724), Size = Vector2.new(362, 362) },
    ["icon_focus"] = { Atlas = "core-icons", Offset = Vector2.new(724, 724), Size = Vector2.new(362, 362) },
    ["icon_settings"] = { Atlas = "core-icons", Offset = Vector2.new(1086, 724), Size = Vector2.new(362, 362) },
    ["rpg"] = { Atlas = "rpg", Offset = Vector2.new(0, 0), Size = Vector2.new(512, 512) },
    ["rpg_equipped"] = { Atlas = "rpg_equipped", Offset = Vector2.new(0, 0), Size = Vector2.new(512, 512) },
    ["rpg_fire"] = { Atlas = "rpg_fire", Offset = Vector2.new(0, 0), Size = Vector2.new(512, 512) },
}
function Assets.Configure(atlasName, imageId, uploadedSize)
    local atlas = assert(Assets.Atlases[atlasName], "Unknown atlas")
    assert(typeof(uploadedSize) == "Vector2" and uploadedSize.X > 0 and uploadedSize.Y > 0, "Actual uploaded dimensions required")
    assert(type(imageId) == "string" and imageId:match("^rbxassetid://%d+$"), "Image asset URI required")
    atlas.Image = imageId
    atlas.UploadedSize = uploadedSize
end
function Assets.Rect(name)
    local sprite = assert(Assets.Sprites[name], "Unknown sprite")
    local atlas = Assets.Atlases[sprite.Atlas]
    if atlas.Image == "" or not atlas.UploadedSize then
        return nil -- 새 이미지는 업로드 전 옛 ID로 대체하지 않습니다.
    end
    local scale = atlas.UploadedSize / atlas.SourceSize
    local function round(value)
        return math.floor(value + 0.5)
    end
    local left = round(sprite.Offset.X * scale.X)
    local top = round(sprite.Offset.Y * scale.Y)
    local right = round((sprite.Offset.X + sprite.Size.X) * scale.X)
    local bottom = round((sprite.Offset.Y + sprite.Size.Y) * scale.Y)
    return atlas.Image, Vector2.new(left, top), Vector2.new(right - left, bottom - top)
end
return Assets
