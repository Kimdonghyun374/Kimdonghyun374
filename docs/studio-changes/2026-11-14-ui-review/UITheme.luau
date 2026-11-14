-- UI 색·모양 테마 (Codex art/references/toy-city-v03/ui/01-gameplay-hud.png 기준, 밝은 장난감 스타일).
-- 기존 UI 스크립트가 만든 화면에 색 치환·테두리·모서리·아이콘만 입힙니다. 버튼 동작·통신·경제 로직은 바꾸지 않습니다.
-- 색값은 Codex art/ui/toy-city-v01/toy-v03-icons/README.md의 구현용 근사값을 따릅니다.
local Theme = {}

local UIAssets = require(script.Parent:WaitForChild("UIAssets"))
local UIImages = require(script.Parent:WaitForChild("UIImages"))

local function rgb(red, green, blue)
    return Color3.fromRGB(red, green, blue)
end

Theme.Palette = {
    Panel = rgb(250, 252, 255), -- #FAFCFF
    PanelStroke = rgb(195, 213, 250), -- #C3D5FA
    Card = rgb(236, 243, 253),
    CardStroke = rgb(195, 213, 250),
    Primary = rgb(36, 121, 247), -- #2479F7
    Confirm = rgb(41, 185, 40), -- #29B928
    Warning = rgb(255, 165, 30),
    Danger = rgb(241, 77, 96), -- #F14D60
    Secondary = rgb(226, 235, 250),
    Disabled = rgb(205, 213, 226),
    TextDark = rgb(16, 39, 94), -- #10275E
    TextMuted = rgb(95, 112, 150),
    TextOnColor = rgb(255, 255, 255),
    Accent = rgb(215, 135, 0),
    Research = rgb(30, 150, 60),
}

Theme.CornerRadius = UDim.new(0, 12)
-- 화면 UI 전체 크기 배율(2026-11-10 사용자: "전체적으로 조금씩 키워주세요"). UIScaleClient가 HUD마다 적용.
Theme.HudScale = 1.2
Theme.PanelStrokeThickness = 2

-- 아이콘을 붙일 곳: ScreenGui 이름부터의 경로 → 아이콘 키와 크기(px)
Theme.IconTargets = {
    -- 2026-11-14: sprite가 있으면 업로드한 v04 아이콘(UIImages), 없으면 key의 옛 아이콘.
    ["SalvageHUD.Resources.Scrap"] = { key = "scrap", sprite = "icon_coins", size = 30 },
    ["SalvageHUD.Resources.ResearchData"] = { key = "research", sprite = "icon_research_data", size = 30 },
    ["WorldProgressHUD.Panel.Home"] = { key = "base", size = 22 },
    ["WorldProgressHUD.Panel.World1"] = { key = "world", size = 22 },
    ["WorldProgressHUD.Panel.World2"] = { key = "world", size = 22 },
    ["MissileBaseHUD.Inventory.Roll"] = { key = "craft", sprite = "icon_craft", size = 30 },
    -- ScoutBuggyHUD.SummonBuggy는 2026-11-14부터 스스로 아이콘 버튼을 만듭니다(여기서 아이콘 붙이지 않음).
}

local ICON_MARGIN = 6
local ICON_GAP = 6
local PREVIEW_PREFIX = "UIPreview_"

local palette = Theme.Palette

-- 기존 UI 스크립트의 배경색 → 시안 색. 값은 0~255 정수 "R,G,B" 키로 비교합니다.
local BACKGROUND_MAP = {
    ["17,28,44"] = palette.Panel,
    ["15,25,40"] = palette.Panel,
    ["30,44,64"] = palette.Card,
    ["35,143,147"] = palette.Primary,
    ["37,153,153"] = palette.Primary,
    ["35,130,145"] = palette.Primary,
    ["49,113,145"] = palette.Primary,
    ["35,155,130"] = palette.Confirm,
    ["49,133,101"] = palette.Confirm,
    ["143,94,49"] = palette.Warning,
    ["49,113,91"] = palette.Secondary,
    ["78,91,112"] = palette.Secondary,
    ["65,77,96"] = palette.Disabled,
    ["63,78,96"] = palette.Disabled,
}
-- 밝은 바탕 위 글자: 원래 밝은 글자는 진한 남색, 강조색은 밝은 바탕에서 읽히는 색으로
local LABEL_TEXT_MAP = {
    ["225,237,247"] = palette.TextDark,
    ["230,240,247"] = palette.TextDark,
    ["221,233,244"] = palette.TextDark,
    ["229,240,250"] = palette.TextDark,
    ["235,245,240"] = palette.TextDark,
    ["235,173,73"] = palette.Accent,
    ["255,226,143"] = palette.Accent,
    ["72,229,245"] = palette.Research,
}
-- 버튼 글자: 진한 색 버튼은 흰 글자, 밝은 색 버튼은 남색 글자
local LIGHT_BUTTONS = {
    palette.Secondary,
    palette.Disabled,
    palette.Panel,
}

local function colorKey(color)
    return string.format(
        "%d,%d,%d",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

local function luminance(color)
    return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
end

local function ensureChild(parent, className)
    local child = parent:FindFirstChildOfClass(className)
    if not child then
        child = Instance.new(className)
        child.Parent = parent
    end
    return child
end

-- 패널: ScreenGui 바로 아래 프레임(또는 배경이 있는 알림 글자). 카드: 스크롤 목록 안 프레임.
local function roleOf(guiObject)
    if guiObject:IsA("GuiButton") then
        return "Button"
    end
    if guiObject.BackgroundTransparency >= 1 then
        return nil
    end
    if guiObject.Parent and guiObject.Parent:IsA("ScrollingFrame") then
        return "Card"
    end
    if guiObject.Parent and guiObject.Parent:IsA("LayerCollector") then
        return "Panel"
    end
    return nil
end

local function styleButtonText(button)
    if button:GetAttribute("NoTheme") then
        return
    end
    local backgroundKey = colorKey(button.BackgroundColor3)
    local isLight = false
    for _, color in LIGHT_BUTTONS do
        if colorKey(color) == backgroundKey then
            isLight = true
            break
        end
    end
    button.TextColor3 = isLight and palette.TextDark or palette.TextOnColor
end

local function remapBackground(guiObject)
    if guiObject:GetAttribute("NoTheme") then
        return
    end
    if guiObject.Name == "Close" and guiObject:IsA("GuiButton") then
        guiObject.BackgroundColor3 = palette.Danger
    else
        local mapped = BACKGROUND_MAP[colorKey(guiObject.BackgroundColor3)]
        if mapped then
            guiObject.BackgroundColor3 = mapped
        end
    end
    if guiObject:IsA("TextButton") then
        styleButtonText(guiObject)
    end
end

local function remapLabelText(label)
    if label:GetAttribute("NoTheme") then
        return
    end
    local mapped = LABEL_TEXT_MAP[colorKey(label.TextColor3)]
    if mapped then
        label.TextColor3 = mapped
    elseif luminance(label.TextColor3) > 0.7 then
        -- 희귀도 색처럼 정해진 밝은 색은 흰 바탕에서 안 보이므로 같은 색조로 어둡게
        label.TextColor3 = label.TextColor3:Lerp(Color3.new(0, 0, 0), 0.45)
    end
end

local function styleShape(guiObject, role)
    local corner = guiObject:FindFirstChildOfClass("UICorner")
    if corner or role then
        ensureChild(guiObject, "UICorner").CornerRadius = Theme.CornerRadius
    end
    if not role then
        return
    end
    local stroke = ensureChild(guiObject, "UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    if role == "Panel" then
        stroke.Color = palette.PanelStroke
        stroke.Thickness = Theme.PanelStrokeThickness
        stroke.Transparency = 0
    elseif role == "Card" then
        stroke.Color = palette.CardStroke
        stroke.Thickness = 1.5
        stroke.Transparency = 0
    else
        -- 알약 버튼은 테두리 없이 색면으로
        stroke.Transparency = 1
    end
end

-- ScreenGui부터의 경로. Edit 미리보기 사본은 "UIPreview_" 접두를 떼고 같은 경로로 봅니다.
local function pathOf(guiObject)
    local names = {}
    local current = guiObject
    while current and not current:IsA("LayerCollector") do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    if not current then
        return nil
    end
    local guiName = current.Name
    if guiName:sub(1, #PREVIEW_PREFIX) == PREVIEW_PREFIX then
        guiName = guiName:sub(#PREVIEW_PREFIX + 1)
    end
    table.insert(names, 1, guiName)
    return table.concat(names, ".")
end

-- 왼쪽에 아이콘을 두고, 글자는 UIPadding으로 아이콘만큼 오른쪽으로 밉니다.
local function attachIcon(guiObject)
    local path = pathOf(guiObject)
    local spec = path and Theme.IconTargets[path]
    local image = spec and UIAssets[spec.key]
    if not image or guiObject:FindFirstChild("ThemeIcon") then
        return
    end
    local padding = Instance.new("UIPadding")
    padding.Name = "ThemeIconPadding"
    padding.PaddingLeft = UDim.new(0, ICON_MARGIN + spec.size + ICON_GAP)
    padding.Parent = guiObject

    local icon = Instance.new("ImageLabel")
    icon.Name = "ThemeIcon"
    icon.BackgroundTransparency = 1
    if not (spec.sprite and UIImages.Apply(icon, spec.sprite)) then
        icon.Image = image
    end
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Size = UDim2.fromOffset(spec.size, spec.size)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    -- UIPadding이 아이콘 위치도 밀어내므로 그만큼 되돌립니다.
    icon.Position = UDim2.new(0, -(spec.size + ICON_GAP), 0.5, 0)
    icon.ZIndex = guiObject.ZIndex + 1
    icon.Parent = guiObject
end

-- 한 개의 GUI 요소에 테마를 입힙니다.
function Theme.StyleObject(guiObject)
    -- NoTheme 속성: 업로드 이미지로 바탕을 입힌 요소(UISkinClient)는 색·모양 치환을 하지 않습니다(2026-11-14).
    if not guiObject:IsA("GuiObject") or guiObject.Name == "ThemeIcon" or guiObject:GetAttribute("NoTheme") then
        return
    end
    remapBackground(guiObject)
    if guiObject:IsA("TextLabel") then
        remapLabelText(guiObject)
    end
    if guiObject:IsA("TextButton") then
        guiObject.Font = Enum.Font.GothamBlack
    end
    if guiObject:IsA("ScrollingFrame") then
        guiObject.ScrollBarImageColor3 = palette.TextMuted
    end
    styleShape(guiObject, roleOf(guiObject))
    attachIcon(guiObject)
end

-- root 아래 전체에 한 번 입힙니다. Edit 미리보기에도 같은 함수를 씁니다.
function Theme.Apply(root)
    for _, descendant in root:GetDescendants() do
        Theme.StyleObject(descendant)
    end
end

-- Play 중: 새로 생기는 요소와 스크립트가 바꾸는 색(상태별 버튼 색, 희귀도 글자 등)도 계속 치환합니다.
function Theme.Watch(root)
    local function watch(guiObject)
        if not guiObject:IsA("GuiObject") or guiObject.Name == "ThemeIcon" or guiObject:GetAttribute("NoTheme") then
            return
        end
        Theme.StyleObject(guiObject)
        guiObject:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            remapBackground(guiObject)
        end)
        if guiObject:IsA("TextLabel") then
            guiObject:GetPropertyChangedSignal("TextColor3"):Connect(function()
                remapLabelText(guiObject)
            end)
        elseif guiObject:IsA("TextButton") then
            guiObject:GetPropertyChangedSignal("TextColor3"):Connect(function()
                styleButtonText(guiObject)
            end)
        end
    end
    for _, descendant in root:GetDescendants() do
        watch(descendant)
    end
    root.DescendantAdded:Connect(function(descendant)
        -- 부모·속성이 다 정해진 뒤 적용하도록 한 프레임 미룹니다.
        task.defer(watch, descendant)
    end)
end

return Theme
