-- 전시장 해금 수에 맞춰 실제 시설과 반투명 예정 시설을 표시합니다.
local Gallery = {}

local SECTION_OFFSETS = {
    L1 = 0,
    R1 = 24,
    L2 = 48,
    R2 = 72,
}

local function remember(instance, property)
    local attribute = "GalleryOriginal" .. property
    if instance:GetAttribute(attribute) == nil then
        instance:SetAttribute(attribute, instance[property])
    end
    return instance:GetAttribute(attribute)
end

local function requiredSlots(name)
    local section, number = name:match("^Pedestal_([LR][12])_(%d+)")
    if section then
        return SECTION_OFFSETS[section] + tonumber(number)
    end
    local isRight = name:find("right", 1, true) ~= nil
    if name:match("^Floor1_") or name:match("^Label_[a-z]+1$") then
        return isRight and 25 or 1
    end
    return isRight and 73 or 49
end

local function paint(root, threshold, unlockedSlots, owned, ghostTransparency)
    local unlocked = owned and unlockedSlots >= threshold
    root:SetAttribute("GalleryRequiredSlots", threshold)
    root:SetAttribute("GalleryUnlocked", unlocked)

    local descendants = root:GetDescendants()
    table.insert(descendants, root)
    for _, instance in ipairs(descendants) do
        if instance:IsA("BasePart") then
            local originalTransparency = remember(instance, "Transparency")
            local originalCollision = remember(instance, "CanCollide")
            local originalQuery = remember(instance, "CanQuery")
            local originalTouch = remember(instance, "CanTouch")
            instance.Transparency = not owned and 1
                or unlocked and originalTransparency
                or math.max(originalTransparency, ghostTransparency)
            instance.CanCollide = unlocked and originalCollision
            instance.CanQuery = unlocked and originalQuery
            instance.CanTouch = unlocked and originalTouch
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            local originalTransparency = remember(instance, "Transparency")
            instance.Transparency = not owned and 1
                or unlocked and originalTransparency
                or math.max(originalTransparency, ghostTransparency)
        elseif instance:IsA("LayerCollector") or instance:IsA("Light") then
            local originalEnabled = remember(instance, "Enabled")
            instance.Enabled = unlocked and originalEnabled
        end
    end
end

function Gallery.Configure(model)
    local display = model:FindFirstChild("Display")
    local layout = model:FindFirstChild("Layout")
    local folder = layout and layout:FindFirstChild("Gallery")
    assert(display and folder, "전시장 구조가 없습니다: " .. model.Name)

    local prompt = display:FindFirstChild("UpgradeGallery")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.Name = "UpgradeGallery"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        prompt.HoldDuration = 0.5
        prompt.MaxActivationDistance = 9
        prompt.RequiresLineOfSight = false
        prompt.Style = Enum.ProximityPromptStyle.Custom
        prompt.Parent = display
    end
    return prompt
end

function Gallery.SetState(model, unlockedSlots, owned, config)
    local prompt = Gallery.Configure(model)
    local capacity = config.GalleryCapacity
    local count = math.clamp(math.floor(unlockedSlots), 1, capacity)
    model:SetAttribute("GallerySlots", count)
    paint(model.Display, 1, count, owned, config.GalleryLockedTransparency)
    for _, child in ipairs(model.Layout.Gallery:GetChildren()) do
        paint(child, requiredSlots(child.Name), count, owned, config.GalleryLockedTransparency)
    end
    prompt.ObjectText = string.format("미사일 전시장 · %d/%d칸", count, capacity)
    prompt.ActionText = string.format("1칸 확장 · 코인 %d", config.GalleryUpgradeCost)
    prompt.Enabled = owned and count < capacity
    return prompt
end

return Gallery
