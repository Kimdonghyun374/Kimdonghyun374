-- 버튼은 서버에 요청만 보내며 내 미사일 목록과 뽑기 결과는 서버 상태를 바탕으로 표시합니다.
-- 2026-11-10: 위쪽 기지 안내띠(12시)는 삭제(그 자리는 낮·밤 표시). "보관함" 개념을 없애고
-- 화면 오른쪽 "내 미사일" 버튼(B)으로 어디서나 목록을 봅니다. 서버 안내는 잠깐 뜨는 알림으로 보여 줍니다.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local network = ReplicatedStorage:WaitForChild("PetMissiles")
local baseConfig = require(network.BaseConfig)
local GameSounds = require(network:WaitForChild("GameSounds"))
local baseState, rollReadyAt, productionReadyAt, requestAt = nil, 0, 0, -math.huge
local gui = Instance.new("ScreenGui")
gui.Name = "MissileBaseHUD"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
gui.DisplayOrder = 30
gui.Parent = player:WaitForChild("PlayerGui")
local function addCorner(parent)
    local cornerInstance = Instance.new("UICorner")
    cornerInstance.CornerRadius = UDim.new(0, 12)
    cornerInstance.Parent = parent
end

local function createLabel(parent, name, position, size, text, textSize)
    local labelInstance = Instance.new("TextLabel")
    labelInstance.Name = name
    labelInstance.Position = position
    labelInstance.Size = size
    labelInstance.Text = text
    labelInstance.BackgroundTransparency = 1
    labelInstance.TextColor3 = Color3.fromRGB(225, 237, 247)
    labelInstance.Font = Enum.Font.Gotham
    labelInstance.TextSize = textSize or 14
    labelInstance.TextWrapped = true
    labelInstance.Parent = parent
    return labelInstance
end

local function createButton(parent, name, position, size, text)
    local buttonInstance = Instance.new("TextButton")
    buttonInstance.Name = name
    buttonInstance.Position = position
    buttonInstance.Size = size
    buttonInstance.Text = text
    buttonInstance.BackgroundColor3 = Color3.fromRGB(35, 143, 147)
    buttonInstance.TextColor3 = Color3.new(1, 1, 1)
    buttonInstance.Font = Enum.Font.GothamBold
    buttonInstance.TextSize = 14
    buttonInstance.Parent = parent
    addCorner(buttonInstance)
    return buttonInstance
end
-- 오른쪽 세로 버튼 줄: 내 미사일 아이콘(144), 버기 소환(216, ScoutBuggyClient)
-- (UIScaleClient가 1.2배로 키움. 56px 아이콘 버튼 → 약 67px)
-- 2026-11-10: 내 미사일 버튼은 글자 없이 아이콘 + 단축키(B) 배지만.
-- 2026-11-14: 크기 56→64, 아래 글자 "미사일", 자리는 HudLayout(오른쪽 메뉴 줄 첫 번째, 화면 배율 반영).
local HudLayout = require(network:WaitForChild("HudLayout"))
local ICON_BUTTON_SIZE = HudLayout.ButtonSize.MenuIcon
local UIAssets = require(network:WaitForChild("UIAssets"))
local openButton = createButton(
    gui,
    "OpenInventory",
    UDim2.new(1, -12, 0, 144),
    UDim2.fromOffset(ICON_BUTTON_SIZE, ICON_BUTTON_SIZE),
    ""
)
HudLayout.Place(openButton, "MenuInventory")
local inventoryCaption = Instance.new("TextLabel")
inventoryCaption.Name = "Caption"
inventoryCaption.AnchorPoint = Vector2.new(0.5, 0)
inventoryCaption.Position = UDim2.new(0.5, 0, 1, 2)
inventoryCaption.Size = UDim2.new(1, 24, 0, 18)
inventoryCaption.BackgroundTransparency = 1
inventoryCaption.Font = Enum.Font.GothamBlack
inventoryCaption.TextSize = 14
-- 글자는 진한 남색 + 흰 외곽선(밝은 바닥·하늘 모두에서 읽히게, 테마 색 치환 대상 아님)
inventoryCaption.TextColor3 = Color3.fromRGB(16, 39, 94)
inventoryCaption.TextStrokeTransparency = 0
inventoryCaption.TextStrokeColor3 = Color3.new(1, 1, 1)
inventoryCaption.Text = "미사일"
inventoryCaption.Parent = openButton
-- 흰 바탕(테마 치환표에 없는 색이라 그대로 유지)
openButton.BackgroundColor3 = Color3.fromRGB(250, 252, 255)
local inventoryIcon = Instance.new("ImageLabel")
inventoryIcon.Name = "Icon"
inventoryIcon.AnchorPoint = Vector2.new(0.5, 0.5)
inventoryIcon.Position = UDim2.fromScale(0.5, 0.5)
inventoryIcon.Size = UDim2.fromScale(0.72, 0.72)
inventoryIcon.BackgroundTransparency = 1
inventoryIcon.ScaleType = Enum.ScaleType.Fit
-- 2026-11-14: 업로드한 v04 미사일 아이콘. 실패하면 옛 아이콘.
local UIImages = require(network:WaitForChild("UIImages"))
if not UIImages.Apply(inventoryIcon, "icon_missiles") then
    inventoryIcon.Image = UIAssets.inventory
end
inventoryIcon.Size = UDim2.fromScale(0.86, 0.86)
inventoryIcon.Parent = openButton
local inventoryKey = Instance.new("TextLabel")
inventoryKey.Name = "KeyBadge"
inventoryKey.AnchorPoint = Vector2.new(0.5, 0.5)
inventoryKey.Position = UDim2.fromScale(0.9, 0.1)
inventoryKey.Size = UDim2.fromOffset(22, 22)
inventoryKey.BackgroundColor3 = Color3.fromRGB(16, 39, 94)
inventoryKey.TextColor3 = Color3.fromRGB(250, 252, 255)
inventoryKey.Font = Enum.Font.GothamBlack
inventoryKey.TextSize = 13
inventoryKey.Text = "B"
inventoryKey.ZIndex = 3
inventoryKey.Visible = not HudLayout.IsTouch()
inventoryKey.Parent = openButton
local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0.5, 0)
keyCorner.Parent = inventoryKey

-- Studio 전용 "내 기지로 이동": 12시 낮·밤 표시 바로 밑
local travelButton = createButton(
    gui,
    "TestTravel",
    UDim2.new(0.5, 0, 0, 62),
    UDim2.fromOffset(200, 30),
    "빈 기지로 이동 · 테스트"
)
travelButton.AnchorPoint = Vector2.new(0.5, 0)
travelButton.TextSize = 12
travelButton.Visible = false

-- 서버 안내(차지 완료, 코인 부족 등)를 낮·밤 표시 아래에 3초 동안 보여 줍니다.
local toast = createLabel(
    gui,
    "Toast",
    UDim2.new(0.5, 0, 0, 104), -- 낮·밤 표시와 테스트 이동 버튼 아래
    UDim2.fromOffset(420, 34),
    "",
    14
)
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.BackgroundTransparency = 0
toast.BackgroundColor3 = Color3.fromRGB(17, 28, 44)
toast.Font = Enum.Font.GothamBold
toast.Visible = false
addCorner(toast)
local toastVersion = 0
local function showToast(text)
    toast.Text = text
    toast.Visible = true
    toastVersion += 1
    local version = toastVersion
    task.delay(3, function()
        if version == toastVersion then
            toast.Visible = false
        end
    end)
end
local panel = Instance.new("Frame")
panel.Name = "Inventory"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.94, 0, 0.72, 0)
panel.BackgroundColor3 = Color3.fromRGB(17, 28, 44)
panel.Visible = false
panel.Parent = gui
local inventorySizeConstraint = Instance.new("UISizeConstraint")
inventorySizeConstraint.MaxSize = Vector2.new(560, 500)
inventorySizeConstraint.Parent = panel
addCorner(panel)
local inventoryTitle = createLabel(
    panel,
    "Title",
    UDim2.fromOffset(12, 4),
    UDim2.new(1, -200, 0, 38),
    "내 미사일",
    18
)
local closeButton =
    createButton(panel, "Close", UDim2.new(1, -48, 0, 8), UDim2.fromOffset(36, 30), "×")
-- 2026-11-13: 커먼(가장 낮은 희귀도) 미사일 일괄 판매(장착·전시 제외). 두 번 눌러 확정합니다.
local sellCommonButton =
    createButton(panel, "SellCommon", UDim2.new(1, -190, 0, 8), UDim2.fromOffset(134, 30), "커먼 모두 판매")
sellCommonButton.TextSize = 13
sellCommonButton.BackgroundColor3 = Color3.fromRGB(196, 120, 40)
local rollButton = createButton(
    panel,
    "Roll",
    UDim2.fromOffset(12, 48),
    UDim2.new(1, -24, 0, 44),
    "미사일 제작 · 코인 20개"
)
local resultLabel = createLabel(
    panel,
    "Result",
    UDim2.fromOffset(12, 98),
    UDim2.new(1, -24, 0, 42),
    "생산기에서 E 또는 터치로 한 개씩 뽑으세요",
    14
)
-- 2026-11-13: 현재 제작대 등급의 등장 확률(확률 공개). 시트 CRAFT_POOL.
local oddsLabel = createLabel(
    panel,
    "Odds",
    UDim2.fromOffset(12, 140),
    UDim2.new(1, -24, 0, 22),
    "",
    12
)
oddsLabel.RichText = true
local inventoryList = Instance.new("ScrollingFrame")
inventoryList.Name = "Items"
inventoryList.Position = UDim2.fromOffset(12, 166)
inventoryList.Size = UDim2.new(1, -24, 1, -176)
inventoryList.BackgroundTransparency = 1
inventoryList.BorderSizePixel = 0
inventoryList.ScrollBarThickness = 5
inventoryList.CanvasSize = UDim2.new()
inventoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
inventoryList.Parent = panel
local itemListLayout = Instance.new("UIListLayout")
itemListLayout.Padding = UDim.new(0, 6)
itemListLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemListLayout.Parent = inventoryList
local function sendRequest(payload)
    if os.clock() - requestAt < 0.2 then
        return
    end
    requestAt = os.clock()
    network.BaseRequest:FireServer(payload)
end

local function setInventoryVisible(value)
    panel.Visible = value
end
travelButton.Activated:Connect(function()
    if baseState and baseState.ready and baseState.canTestTravel then
        sendRequest({ action = "testTravel" })
    end
end)
openButton.Activated:Connect(function()
    setInventoryVisible(true)
    GameSounds.Play("UIConfirm")
    sendRequest({ action = "sync" })
end)
closeButton.Activated:Connect(function()
    setInventoryVisible(false)
    GameSounds.Play("UIConfirm")
end)
ContextActionService:BindAction("MissileBaseInventory", function(_, input)
    if UserInputService:GetFocusedTextBox() then
        return Enum.ContextActionResult.Pass
    end
    if input == Enum.UserInputState.Begin then
        setInventoryVisible(not panel.Visible)
        sendRequest({ action = "sync" })
    end
    return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.B)
rollButton.Activated:Connect(function()
    if baseState and baseState.ready and not baseState.production and os.clock() >= rollReadyAt then
        sendRequest({ action = "roll" })
    end
end)
-- 판매 확인: 같은 버튼을 3초 안에 한 번 더 누르면 판매합니다.
local SELL_COLOR = Color3.fromRGB(196, 120, 40)
local CONFIRM_COLOR = Color3.fromRGB(200, 60, 60)
local pendingConfirm, pendingOriginalText = nil, nil
local function resetConfirm()
    local button = pendingConfirm
    pendingConfirm = nil
    if button and button.Parent then
        button.Text = pendingOriginalText
        button.BackgroundColor3 = SELL_COLOR
    end
end
local function confirmThen(button, confirmText, action)
    if pendingConfirm == button then
        resetConfirm()
        action()
        return
    end
    resetConfirm()
    pendingConfirm, pendingOriginalText = button, button.Text
    button.Text = confirmText
    button.BackgroundColor3 = CONFIRM_COLOR
    task.delay(3, function()
        if pendingConfirm == button then
            resetConfirm()
        end
    end)
end

sellCommonButton.Activated:Connect(function()
    if not baseState then
        return
    end
    local count, coins = 0, 0
    for _, item in ipairs(baseState.inventory) do
        if item.rarity == "커먼" and not item.equipped and not item.displayed then
            count += 1
            coins += item.sellPrice or 0
        end
    end
    if count == 0 then
        resultLabel.Text = "팔 수 있는 커먼 미사일이 없습니다(장착·전시 제외)"
        return
    end
    confirmThen(sellCommonButton, string.format("%d개 +%d 확인?", count, coins), function()
        sendRequest({ action = "sellRarity", rarity = "커먼" })
    end)
end)

local function createInventoryRow(item, layoutOrder)
    local row = Instance.new("Frame")
    row.Name = "Item_" .. item.id
    row.Size = UDim2.new(1, -8, 0, 58)
    row.LayoutOrder = layoutOrder
    row.BackgroundColor3 = Color3.fromRGB(30, 44, 64)
    row.Parent = inventoryList
    addCorner(row)
    local itemLabel = createLabel(
        row,
        "Name",
        UDim2.fromOffset(10, 4),
        UDim2.new(1, -200, 1, -8),
        item.rarity .. " · " .. item.name .. "\n피해 ×" .. item.multiplier .. (item.displayed and " · 전시 중" or ""),
        13
    )
    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemLabel.TextColor3 = Color3.fromRGB(table.unpack(item.color))
    local equipButton = createButton(
        row,
        "Equip",
        UDim2.new(1, -94, 0, 9),
        UDim2.fromOffset(84, 40),
        item.equipped and "장착 해제" or "장착"
    )
    equipButton.BackgroundColor3 = item.equipped and Color3.fromRGB(78, 91, 112)
        or Color3.fromRGB(35, 143, 147)
    equipButton.Activated:Connect(function()
        sendRequest({ action = "equip", id = item.id, enabled = not item.equipped })
    end)
    -- 판매: 장착·전시 중이면 먼저 해제해야 합니다.
    local locked = item.equipped or item.displayed
    local sellButton = createButton(
        row,
        "Sell",
        UDim2.new(1, -184, 0, 9),
        UDim2.fromOffset(84, 40),
        locked and "판매 불가" or string.format("판매 +%d", item.sellPrice or 0)
    )
    sellButton.BackgroundColor3 = locked and Color3.fromRGB(78, 91, 112) or SELL_COLOR
    sellButton.AutoButtonColor = not locked
    sellButton.Activated:Connect(function()
        if locked then
            resultLabel.Text = (item.equipped and "장착" or "전시") .. " 중인 미사일은 먼저 해제하세요"
            return
        end
        confirmThen(sellButton, "확인?", function()
            sendRequest({ action = "sell", id = item.id })
        end)
    end)
end

local function renderOdds()
    if not baseState or not baseState.craftOdds or #baseState.craftOdds == 0 then
        oddsLabel.Text = ""
        return
    end
    local parts = {}
    for _, entry in ipairs(baseState.craftOdds) do
        local color = Color3.fromRGB(table.unpack(entry.color))
        -- 밝은 창 바탕에서도 확률의 희귀도 글자가 읽히게 합니다.
        if color.R * 0.299 + color.G * 0.587 + color.B * 0.114 > 0.6 then
            color = color:Lerp(Color3.fromRGB(16, 39, 94), 0.5)
        end
        table.insert(parts, string.format('<font color="#%s">%s %s %g%%</font>', color:ToHex(), entry.rarity, entry.name, entry.chance))
    end
    local text = string.format("제작대 %d등급 확률: %s", baseState.craftTier or 1, table.concat(parts, " · "))
    if baseState.craftGuarantee then
        text ..= "  |  다음 제작 확정: " .. baseState.craftGuarantee
    end
    oddsLabel.Text = text
end

local function renderInventoryItems()
    renderOdds()
    for _, childObject in inventoryList:GetChildren() do
        if childObject:IsA("GuiObject") then
            childObject:Destroy()
        end
    end
    if not baseState then
        return
    end
    local equipped = 0
    for _, item in ipairs(baseState.inventory) do
        if item.equipped then
            equipped += 1
        end
    end
    inventoryTitle.Text = string.format(
        "내 미사일 %d개 · 장착 %d/%d",
        #baseState.inventory,
        equipped,
        baseState.limit
    )
    if #baseState.inventory == 0 then
        createLabel(
            inventoryList,
            "Empty",
            UDim2.new(),
            UDim2.new(1, -8, 0, 70),
            "아직 미사일이 없습니다.\n빈 기지를 차지하고 생산기에서 첫 미사일을 뽑아보세요",
            14
        )
    end
    for i = #baseState.inventory, 1, -1 do
        createInventoryRow(baseState.inventory[i], #baseState.inventory - i)
    end
end
local function handleBaseState(nextState, message, result, open)
    -- 제작 예약이 새로 생긴 순간만 제작 시작음(접속 직후 이미 진행 중이던 제작은 제외)
    local hadState = baseState ~= nil
    local wasProducing = baseState and baseState.production ~= nil
    if hadState and not wasProducing and nextState.production then
        GameSounds.Play("CraftStart")
    end
    if result then
        GameSounds.Play("CraftReady")
    end
    baseState = nextState
    -- 2026-11-14: Studio 테스트 이동 버튼은 관리자 창(빈 기지 발판)으로 옮겨 항상 숨깁니다.
    travelButton.Visible = false
    travelButton.Text = baseState.plot == 0 and "빈 기지로 이동 · 테스트"
        or "내 기지로 이동 · 테스트"
    rollReadyAt = os.clock() + math.max(0, baseState.nextRoll - baseState.serverClock)
    productionReadyAt = baseState.production
            and (os.clock() + math.max(0, baseState.production.readyAt - baseState.serverClock))
        or 0
    renderInventoryItems()
    if message then
        resultLabel.Text = message
        if not panel.Visible then
            showToast(message)
        end
    end
    if open then
        setInventoryVisible(true)
    end
    if result then
        setInventoryVisible(true)
        resultLabel.TextColor3 = Color3.fromRGB(table.unpack(result.color))
        resultLabel.Text = result.rarity
            .. " · "
            .. result.name
            .. " 획득!  피해 ×"
            .. result.multiplier
    end
end

network.BaseState.OnClientEvent:Connect(handleBaseState)
local function updateBaseHud()
    if not baseState or not baseState.ready then
        return
    end
    local remaining = math.max(0, rollReadyAt - os.clock())
    local productionRemaining = math.max(0, productionReadyAt - os.clock())
    if baseState.production then
        local text = productionRemaining > 0
                and string.format("미사일 제작 중 · %.1f초 남음", productionRemaining)
            or "제작 완료 확인 중…"
        resultLabel.TextColor3 = Color3.fromRGB(225, 237, 247)
        resultLabel.Text = text
    end
    local bases = workspace:FindFirstChild("ProjectMS_Bases")
    local plot = bases and bases:FindFirstChild("Base_" .. baseState.plot)
    local generator = plot and plot:FindFirstChild("Generator")
    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local nearby = generator
        and rootPart
        and (generator.Position - rootPart.Position).Magnitude <= baseConfig.InteractionDistance
    if baseState.production then
        rollButton.Text = productionRemaining > 0
                and string.format("제작 중 · %.1f초 남음", productionRemaining)
            or "제작 완료 확인 중…"
    elseif baseState.plot == 0 then
        rollButton.Text = "먼저 빈 기지를 차지하세요"
    elseif not nearby then
        rollButton.Text = "내 기지의 생산기 가까이 이동하세요"
    elseif #baseState.inventory >= baseState.capacity then
        rollButton.Text = "미사일이 가득 찼습니다(최대 100개)"
    elseif baseState.scrap < baseState.rollCost then
        rollButton.Text =
            string.format("코인 부족 · %d/%d개", baseState.scrap, baseState.rollCost)
    elseif remaining > 0 then
        rollButton.Text = string.format("다음 뽑기까지 %.1f초", remaining)
    else
        rollButton.Text = string.format(
            "미사일 제작 · 코인 %d개 · %g초",
            baseState.rollCost,
            baseState.productionDuration
        )
    end
    local canRoll = nearby
        and not baseState.production
        and baseState.scrap >= baseState.rollCost
        and remaining <= 0
        and #baseState.inventory < baseState.capacity
    rollButton.Active = canRoll == true
    rollButton.AutoButtonColor = canRoll == true
    rollButton.BackgroundColor3 = canRoll
            and #baseState.inventory < baseState.capacity
            and Color3.fromRGB(35, 143, 147)
        or Color3.fromRGB(65, 77, 96)
end

RunService.RenderStepped:Connect(updateBaseHud)
script.Destroying:Connect(function()
    ContextActionService:UnbindAction("MissileBaseInventory")
    gui:Destroy()
end)
sendRequest({ action = "sync" })
