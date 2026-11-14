-- 이미지 연결과 내부 여백을 Play/Edit에 함께 적용합니다.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIImages = require(ReplicatedStorage.PetMissiles.UIImages)
local HudLayout = require(ReplicatedStorage.PetMissiles.HudLayout)

local Appearance = {}
local NAVY = Color3.fromRGB(16, 31, 65)
local WHITE = Color3.fromRGB(255, 255, 255)
local watched = setmetatable({}, { __mode = "k" })
local layoutBound = setmetatable({}, { __mode = "k" })

local function ensure(parent, className, name)
    local child = parent:FindFirstChild(name)
    if not child then
        child = Instance.new(className)
        child.Name = name
        child.Parent = parent
    end
    return child
end

local function protect(object)
    object:SetAttribute("NoTheme", true)
end

local function textStyle(label, size, light)
    if not label then
        return
    end
    protect(label)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = size
    label.TextColor3 = light and WHITE or NAVY
    label.TextStrokeColor3 = NAVY
    label.TextStrokeTransparency = light and 0.2 or 1
end

local function background(object, sprite, slice, sliceScale)
    protect(object)
    object.BackgroundTransparency = 1
    for _, child in object:GetChildren() do
        if child:IsA("UIStroke") then
            child.Enabled = false
        end
    end
    local skin = ensure(object, "ImageLabel", "Skin")
    protect(skin)
    skin.BackgroundTransparency = 1
    skin.AnchorPoint = Vector2.zero
    skin.Position = UDim2.fromOffset(0, 0)
    skin.Size = UDim2.fromScale(1, 1)
    skin.ZIndex = math.max(0, object.ZIndex - 1)
    local padding = object:FindFirstChildOfClass("UIPadding")
    if padding then
        local left, right = padding.PaddingLeft.Offset, padding.PaddingRight.Offset
        local top, bottom = padding.PaddingTop.Offset, padding.PaddingBottom.Offset
        skin.Position = UDim2.fromOffset(-left, -top)
        skin.Size = UDim2.new(1, left + right, 1, top + bottom)
    end
    UIImages.Apply(skin, sprite)
    skin.ScaleType = slice and Enum.ScaleType.Slice or Enum.ScaleType.Stretch
    if slice then
        skin.SliceCenter = slice
        skin.SliceScale = sliceScale or 0.5
    end
    -- 글자·아이콘은 바탕보다 위에 둡니다.
    for _, child in object:GetChildren() do
        if child:IsA("GuiObject") and child ~= skin then
            child.ZIndex = math.max(child.ZIndex, skin.ZIndex + 1)
        end
    end
    return skin
end

local function capsule(object)
    return background(object, "resource_capsule", Rect.new(47, 30, 187, 63), 0.45)
end

local function watch(object, property, callback)
    local properties = watched[object]
    if not properties then
        properties = {}
        watched[object] = properties
    end
    if properties[property] then
        return
    end
    properties[property] = true
    object:GetPropertyChangedSignal(property):Connect(callback)
end

local function constrainText(label, maximum)
    if not label or not (label:IsA("TextLabel") or label:IsA("TextButton")) then
        return
    end
    label.TextScaled = true
    local limit = ensure(label, "UITextSizeConstraint", "ReadableText")
    limit.MinTextSize = 11
    limit.MaxTextSize = maximum
end

local function styleLongButton(button)
    button.ZIndex = 20
    if button.Name == "Equip" or button.Name == "Sell" then
        button.Size = UDim2.fromOffset(84, 44)
    end
    local pressed = false
    local function refresh()
        local color = button.BackgroundColor3
        local family = color.R > 0.65 and (color.G < 0.4 and "red" or "yellow") or "blue"
        if button.Name == "Upgrade" or button.Name == "Equip" then
            family = "green"
        elseif button.Name == "Roll" then
            family = "yellow"
        end
        background(button, family .. (not button.Active and "_disabled" or pressed and "_pressed" or "_normal"), Rect.new(42, 24, 190, 83), 0.3)
        textStyle(button, 15, true)
        constrainText(button, 16)
    end
    refresh()
    watch(button, "Active", refresh)
    watch(button, "BackgroundColor3", refresh)
    if not layoutBound[button] then
        layoutBound[button] = true
        button.MouseButton1Down:Connect(function()
            pressed = true
            refresh()
        end)
        button.MouseButton1Up:Connect(function()
            pressed = false
            refresh()
        end)
        button.MouseLeave:Connect(function()
            pressed = false
            refresh()
        end)
    end
end

local function styleMenu(button)
    button.ZIndex = 10
    local key = button:FindFirstChild("KeyBadge")
    if key then
        key.ZIndex = 13
        key.Visible = not HudLayout.IsTouch()
        if not layoutBound[key] then
            layoutBound[key] = true
            HudLayout.Changed:Connect(function()
                if key.Parent then
                    key.Visible = not HudLayout.IsTouch()
                end
            end)
        end
    end
    background(button, "keycap_blank")
    local icon = button:FindFirstChild("Icon")
    if icon then
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromScale(0.86, 0.86)
        icon.ZIndex = 12
    end
    local caption = button:FindFirstChild("Caption")
    if caption then
        caption.ZIndex = 12
        textStyle(caption, 16, true)
        caption.Position = UDim2.new(0.5, 0, 1, 3)
        caption.Size = UDim2.new(1, 20, 0, 20)
    end
end

local function styleAction(button)
    protect(button)
    local isFire = button.Name == "PistolFire"
    button.BackgroundTransparency = 0
    button.AutoButtonColor = false
    local corner = ensure(button, "UICorner", "ActionCorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    local border = ensure(button, "UIStroke", "ActionBorder")
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Color = NAVY
    border.Thickness = 3
    for _, child in button:GetChildren() do
        if child:IsA("UIStroke") and child ~= border then
            child.Enabled = false
        end
    end
    local gradient = ensure(button, "UIGradient", "ActionGloss")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new(WHITE, Color3.fromRGB(210, 175, 130))
    local function refresh()
        button.BackgroundColor3 = isFire and Color3.fromRGB(255, 65, 81) or Color3.fromRGB(255, 204, 32)
    end
    refresh()
    watch(button, "BackgroundColor3", refresh)
    local icon = button:FindFirstChild("Icon")
    if icon then
        icon.Size = UDim2.fromScale(0.84, 0.74)
        icon.Position = UDim2.fromScale(0.5, 0.39)
        icon.ZIndex = 3
    end
    local title = button:FindFirstChild("Title")
    textStyle(title, 16, true)
    if title then
        title.Position = UDim2.fromScale(0.5, 0.8)
        title.Size = UDim2.fromScale(0.96, 0.26)
        watch(title, "TextColor3", function()
            title.TextColor3 = WHITE
        end)
    end
    local state = button:FindFirstChild("State")
    if state then
        state.Visible = false
    end
end

local function styleResources(panel)
    protect(panel)
    panel.BackgroundTransparency = 1
    for _, child in panel:GetChildren() do
        if child:IsA("UIStroke") then
            child.Enabled = false
        end
    end
    panel.Size = UDim2.fromOffset(226, 94)
    local constraint = panel:FindFirstChildOfClass("UISizeConstraint")
    if constraint then
        constraint.MaxSize = Vector2.new(226, 94)
    end
    for index, name in { "Scrap", "ResearchData" } do
        local line = panel:FindFirstChild(name)
        if line then
            local old = panel:FindFirstChild("Skin_" .. name)
            if old then
                old:Destroy()
            end
            line.Position = UDim2.fromOffset(0, (index - 1) * 48)
            line.Size = UDim2.new(1, 0, 0, 42)
            line.ZIndex = 10
            textStyle(line, 20, true)
            constrainText(line, 20)
            local padding = ensure(line, "UIPadding", "ThemeIconPadding")
            padding.PaddingLeft = UDim.new(0, 46)
            padding.PaddingRight = UDim.new(0, 14)
            capsule(line)
            local icon = ensure(line, "ImageLabel", "ThemeIcon")
            protect(icon)
            icon.BackgroundTransparency = 1
            icon.AnchorPoint = Vector2.new(0, 0.5)
            icon.Position = UDim2.new(0, -38, 0.5, 0)
            icon.Size = UDim2.fromOffset(32, 32)
            icon.ScaleType = Enum.ScaleType.Fit
            icon.ZIndex = 12
            UIImages.Apply(icon, index == 1 and "icon_coins" or "icon_research_data")
        end
    end
    HudLayout.Place(panel, "LeftResources")
end

local function stylePhase(label)
    label.ZIndex = 10
    label.Size = UDim2.fromOffset(224, 40)
    constrainText(label, 18)
    local function placePhase()
        local available = label.Parent.AbsoluteSize
        local portrait = available.X < available.Y
        label.Position = UDim2.new(0.5, 0, 0, HudLayout.IsTouch() and portrait and 60 or 8)
    end
    placePhase()
    watch(label.Parent, "AbsoluteSize", placePhase)
    if not layoutBound[label] then
        layoutBound[label] = true
        HudLayout.Changed:Connect(function()
            if label.Parent then
                placePhase()
            end
        end)
    end
    textStyle(label, 18, true)
    local padding = ensure(label, "UIPadding", "PhasePadding")
    padding.PaddingLeft = UDim.new(0, 34)
    padding.PaddingRight = UDim.new(0, 12)
    capsule(label)
    local icon = ensure(label, "ImageLabel", "PhaseIcon")
    protect(icon)
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.fromOffset(30, 30)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Position = UDim2.new(0, -26, 0.5, 0)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = 12
    local function refresh()
        UIImages.Apply(icon, string.find(label.Text, "밤") and "moon" or "sun")
        label.TextColor3 = WHITE
        label.BackgroundTransparency = 1
    end
    refresh()
    watch(label, "Text", refresh)
    watch(label, "TextColor3", refresh)
    watch(label, "BackgroundTransparency", refresh)
end

local function styleRaid(panel)
    panel.ZIndex = 10
    local function placeRaid()
        local available = panel.Parent.AbsoluteSize
        local scale = HudLayout.GetScale()
        local portrait = available.X < available.Y
        local top = HudLayout.IsTouch() and portrait and (110 + 94 * scale + 16) or 68
        panel.Size = UDim2.fromOffset(math.min(400, (available.X - 32) / scale), 102)
        panel.Position = UDim2.new(0.5, 0, 0, top)
    end
    placeRaid()
    watch(panel.Parent, "AbsoluteSize", placeRaid)
    if not layoutBound[panel] then
        layoutBound[panel] = true
        HudLayout.Changed:Connect(function()
            if panel.Parent then
                placeRaid()
            end
        end)
    end
    local padding = panel:FindFirstChildOfClass("UIPadding")
    if padding then
        padding:Destroy()
    end
    background(panel, "boss_banner", Rect.new(48, 50, 182, 92), 0.6)
    local title, timer, detail = panel:FindFirstChild("Title"), panel:FindFirstChild("Timer"), panel:FindFirstChild("Detail")
    if title then
        title.ZIndex = 20
        title.Position = UDim2.fromOffset(24, 8)
        title.Size = UDim2.new(1, -104, 0, 26)
        textStyle(title, 18, true)
        constrainText(title, 18)
    end
    if timer then
        timer.ZIndex = 20
        timer.Position = UDim2.new(1, -76, 0, 8)
        timer.Size = UDim2.fromOffset(50, 26)
        textStyle(timer, 18, true)
    end
    if detail then
        detail.ZIndex = 20
        detail.Position = UDim2.fromOffset(24, 66)
        detail.Size = UDim2.new(1, -48, 0, 26)
        textStyle(detail, 14, true)
        constrainText(detail, 14)
    end
    local bar = panel:FindFirstChild("HealthBar")
    if bar then
        bar.ZIndex = 12
        bar.Position = UDim2.fromOffset(24, 42)
        bar.Size = UDim2.new(1, -48, 0, 16)
        background(bar, "gauge_track", Rect.new(40, 25, 195, 58), 0.16)
        local fill = bar:FindFirstChild("Fill")
        if fill then
            fill.ZIndex = 14
            background(fill, "gauge_gold", Rect.new(32, 20, 191, 44), 0.16)
        end
    end
end

local function resizePopup(panel)
    local available = panel.Parent.AbsoluteSize
    local inventory = panel.Name == "Inventory"
    panel.Size = UDim2.fromOffset(math.min(available.X - 28, inventory and 620 or 440), math.min(available.Y - 24, inventory and 520 or 340))
    local limit = panel:FindFirstChildOfClass("UISizeConstraint")
    if limit then
        limit.MaxSize = Vector2.new(inventory and 620 or 440, inventory and 520 or 340)
    end
end

local function stylePopup(panel)
    panel.ZIndex = 10
    for _, child in panel:GetDescendants() do
        if child:IsA("GuiObject") and child.Name ~= "Skin" then
            child.ZIndex = 20
        end
    end
    background(panel, "modal_blue", Rect.new(26, 60, 191, 184), 0.55)
    resizePopup(panel)
    watch(panel.Parent, "AbsoluteSize", function()
        resizePopup(panel)
    end)
    local title = panel:FindFirstChild("Title")
    textStyle(title, 20, true)
    if title then
        title.Position = UDim2.fromOffset(20, 8)
        title.Size = UDim2.new(1, -84, 0, 32)
        constrainText(title, 20)
    end
    local close = panel:FindFirstChild("Close")
    if close then
        close.Position = UDim2.new(1, -58, 0, 2)
        close.Size = UDim2.fromOffset(44, 44)
    end
    if panel.Name == "Inventory" then
        local positions = {
            SellCommon = { UDim2.new(1, -172, 0, 48), UDim2.fromOffset(152, 40) },
            Roll = { UDim2.fromOffset(20, 86), UDim2.new(1, -40, 0, 44) },
            Result = { UDim2.fromOffset(20, 136), UDim2.new(1, -40, 0, 28) },
            Odds = { UDim2.fromOffset(20, 166), UDim2.new(1, -40, 0, 36) },
            Items = { UDim2.fromOffset(20, 208), UDim2.new(1, -40, 1, -224) },
        }
        for name, layout in positions do
            local child = panel:FindFirstChild(name)
            if child then
                child.Position, child.Size = layout[1], layout[2]
                if child:IsA("TextLabel") then
                    child.TextWrapped = true
                    textStyle(child, name == "Odds" and 12 or 14, false)
                end
            end
        end
    else
        for name, y in { Info = 50, Upgrade = 98, Summon = 154, Exit = 210 } do
            local child = panel:FindFirstChild(name)
            if child then
                child.Position = UDim2.fromOffset(20, y)
                child.Size = UDim2.new(1, -40, 0, name == "Info" and 40 or 44)
            end
        end
        for name, bottom in { Message = 58, Controls = 30 } do
            local child = panel:FindFirstChild(name)
            if child then
                child.Position = UDim2.new(0, 20, 1, -bottom)
                child.Size = UDim2.new(1, -40, 0, 26)
                textStyle(child, 12, false)
            end
        end
    end
end

local function logicalPath(object)
    local names = {}
    local current = object
    while current and not current:IsA("ScreenGui") do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    if not current then
        return ""
    end
    local screen = current.Name:gsub("^UIPreview_", "")
    local popups = { Popup_Inventory = "MissileBaseHUD", Popup_Garage = "ScoutBuggyHUD", Popup_Toast = "MissileBaseHUD", Popup_PickupNotice = "SalvageHUD", Popup_FocusHint = "PetMissileHUD" }
    screen = popups[screen] or screen
    table.insert(names, 1, screen)
    return table.concat(names, ".")
end

function Appearance.Style(object)
    if not object:IsA("GuiObject") or object.Name == "Skin" then
        return
    end
    local path = logicalPath(object)
    if path == "SalvageHUD.Resources" then
        styleResources(object)
    elseif path == "DayNightHUD.Phase" then
        stylePhase(object)
    elseif path == "RaidHUD.RaidPanel" then
        styleRaid(object)
    elseif path == "MissileBaseHUD.OpenInventory" or path == "ScoutBuggyHUD.SummonBuggy" then
        styleMenu(object)
    elseif path == "PrankPistolHUD.PistolEquip" or path == "PrankPistolHUD.PistolFire" then
        styleAction(object)
    elseif path == "MissileBaseHUD.Inventory" or path == "ScoutBuggyHUD.Garage" then
        stylePopup(object)
    elseif object:IsA("TextButton") and (path:find("^MissileBaseHUD.Inventory%.") or path:find("^ScoutBuggyHUD.Garage%.")) then
        if object.Name == "Close" then
            object.ZIndex = 20
            object.Text = ""
            local skin = background(object, "close")
            skin.ScaleType = Enum.ScaleType.Fit
        else
            styleLongButton(object)
        end
    elseif object:IsA("TextLabel") and (path:find("^MissileBaseHUD.Inventory%.") or path:find("^ScoutBuggyHUD.Garage%.")) then
        object.ZIndex = 20
    elseif path == "MissileBaseHUD.Toast" or path == "SalvageHUD.PickupNotice" then
        object.ZIndex = 10
        background(object, "toast_blue", Rect.new(40, 30, 188, 65), 0.32)
        textStyle(object, 16, true)
        object.Size = UDim2.fromOffset(400, 52)
        constrainText(object, 16)
    end
end

function Appearance.Apply(root)
    for _, object in root:GetDescendants() do
        Appearance.Style(object)
    end
end

function Appearance.Watch(root)
    Appearance.Apply(root)
    return root.DescendantAdded:Connect(function(object)
        task.defer(function()
            if object.Parent then
                Appearance.Style(object)
            end
        end)
    end)
end

return Appearance
