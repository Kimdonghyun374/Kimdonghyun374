-- 관리자(게임 주인) 전용 흑백 테스트 창(2026-11-14). 서버가 ProjectMSAdmin 속성을 준 사람에게만 보입니다.
-- 버튼은 서버(AdminController)에 정해진 항목 이름만 보내고, 서버가 주인인지 다시 확인합니다.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local network = ReplicatedStorage:WaitForChild("PetMissiles")
local HudLayout = require(network:WaitForChild("HudLayout"))
local adminEvent = network:WaitForChild("AdminRequest")

-- 흑백 팔레트
local COLOR_BACK = Color3.fromRGB(14, 14, 14)
local COLOR_BUTTON = Color3.fromRGB(40, 40, 40)
local COLOR_BUTTON_STROKE = Color3.fromRGB(120, 120, 120)
local COLOR_LINE = Color3.fromRGB(235, 235, 235)
local COLOR_TEXT = Color3.fromRGB(245, 245, 245)
local COLOR_MUTED = Color3.fromRGB(165, 165, 165)

local PANEL_WIDTH = 300
local PANEL_MAX_HEIGHT = 430
local BUTTON_HEIGHT = 34

-- 화면 구성 -------------------------------------------------------------
local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = parent
end

local function buildGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdminHUD"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 60
    gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    gui.Parent = player:WaitForChild("PlayerGui")
    return gui
end

local function createButton(parent, name, text, order)
    local button = Instance.new("TextButton")
    button.Name = name
    button.LayoutOrder = order
    button.Size = UDim2.new(0.5, -4, 0, BUTTON_HEIGHT)
    button.BackgroundColor3 = COLOR_BUTTON
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextSize = 13
    button.TextColor3 = COLOR_TEXT
    button.TextWrapped = true
    button.Parent = parent
    addCorner(button, 6)
    addStroke(button, COLOR_BUTTON_STROKE, 1)
    return button
end

local function createHeader(parent, text, order)
    local header = Instance.new("TextLabel")
    header.Name = "Header_" .. order
    header.LayoutOrder = order
    header.Size = UDim2.new(1, 0, 0, 20)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBlack
    header.Text = text
    header.TextSize = 12
    header.TextColor3 = COLOR_MUTED
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = parent
    return header
end

-- 항목 정의: {머리글} 또는 {이름, 글자, 요청}
local function buildEntries(isStudio)
    local entries = {
        { header = "이동" },
        { "TpPlaza", "광장 스폰", { action = "teleport", target = "plaza" } },
        { "TpRaid", "레이드 자리", { action = "teleport", target = "raid" } },
        { "TpMyBase", "내 기지", { action = "teleport", target = "myBase" } },
        { "TpEmptyBase", "빈 기지 발판", { action = "teleport", target = "emptyBase" } },
        { "TpWorld1", "1월드 입구", { action = "teleport", target = "world1" } },
        { "TpWorld2", "2월드", { action = "teleport", target = "world2" } },
        { "TpZone2", "구역2", { action = "teleport", target = "zone2" } },
        { "TpZone3", "구역3", { action = "teleport", target = "zone3" } },
        { header = "자원" },
        { "GrantCoins100", "코인 +100", { action = "grant", kind = "coins100" } },
        { "GrantCoins1000", "코인 +1000", { action = "grant", kind = "coins1000" } },
        { "GrantResearch10", "연구자료 +10", { action = "grant", kind = "research10" } },
        { header = "이벤트" },
        { "RaidNow", "레이드 지금 예고", { action = "raidNow" } },
    }
    if isStudio then
        table.insert(entries, { header = "시간 (Studio 전용)" })
        table.insert(entries, { "TimeDay", "낮 고정", { action = "time", mode = "day" } })
        table.insert(entries, { "TimeNight", "밤 고정", { action = "time", mode = "night" } })
        table.insert(entries, { "TimeNormal", "시간 정상", { action = "time", mode = "normal" } })
    end
    return entries
end

local function buildAdminUi()
    local gui = buildGui()

    -- 여는 버튼: 오른쪽 위 작은 흑백 버튼
    local toggle = Instance.new("TextButton")
    toggle.Name = "AdminToggle"
    toggle.AnchorPoint = Vector2.new(1, 0)
    toggle.Position = UDim2.new(1, -20, 0, 12)
    toggle.Size = UDim2.fromOffset(96, 32)
    toggle.BackgroundColor3 = COLOR_BACK
    toggle.Font = Enum.Font.GothamBlack
    toggle.Text = "ADMIN"
    toggle.TextSize = 14
    toggle.TextColor3 = COLOR_TEXT
    toggle.Parent = gui
    addCorner(toggle, 6)
    addStroke(toggle, COLOR_LINE, 1.5)

    local panel = Instance.new("Frame")
    panel.Name = "AdminPanel"
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.Position = UDim2.new(1, -20, 0, 52)
    panel.Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_MAX_HEIGHT)
    panel.BackgroundColor3 = COLOR_BACK
    panel.BackgroundTransparency = 0.04
    panel.Visible = false
    panel.Parent = gui
    addCorner(panel, 8)
    addStroke(panel, COLOR_LINE, 1.5)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Position = UDim2.fromOffset(12, 8)
    title.Size = UDim2.new(1, -56, 0, 24)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "ADMIN · 관리자 테스트"
    title.TextSize = 15
    title.TextColor3 = COLOR_TEXT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    local close = createButton(panel, "Close", "×", 0)
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(1, -8, 0, 6)
    close.Size = UDim2.fromOffset(30, 28)
    close.TextSize = 18

    local list = Instance.new("ScrollingFrame")
    list.Name = "List"
    list.Position = UDim2.fromOffset(10, 40)
    list.Size = UDim2.new(1, -20, 1, -78)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = COLOR_MUTED
    list.CanvasSize = UDim2.new()
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = panel
    local grid = Instance.new("UIGridLayout")
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.CellPadding = UDim2.fromOffset(8, 6)
    grid.CellSize = UDim2.new(0.5, -4, 0, BUTTON_HEIGHT)
    grid.Parent = list

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.AnchorPoint = Vector2.new(0, 1)
    status.Position = UDim2.new(0, 12, 1, -8)
    status.Size = UDim2.new(1, -24, 0, 24)
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = "주인 계정에서만 보이는 창입니다"
    status.TextSize = 12
    status.TextColor3 = COLOR_MUTED
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextTruncate = Enum.TextTruncate.AtEnd
    status.Parent = panel

    -- 격자는 한 줄에 두 칸. 머리글은 새 줄 왼쪽 칸에 놓고 오른쪽 칸은 비웁니다.
    local cellCount = 0
    local function addSpacer()
        cellCount += 1
        local spacer = Instance.new("Frame")
        spacer.Name = "Spacer_" .. cellCount
        spacer.LayoutOrder = cellCount
        spacer.BackgroundTransparency = 1
        spacer.Parent = list
    end
    for _, entry in buildEntries(player:GetAttribute("ProjectMSAdminStudio") == true) do
        if entry.header then
            if cellCount % 2 == 1 then
                addSpacer()
            end
            cellCount += 1
            createHeader(list, entry.header, cellCount)
            addSpacer()
        else
            cellCount += 1
            local name, text, request = entry[1], entry[2], entry[3]
            createButton(list, name, text, cellCount).Activated:Connect(function()
                status.Text = text .. " 요청…"
                adminEvent:FireServer(request)
            end)
        end
    end

    -- 크기: 화면 배율(최대 1배) 적용
    local panelScale = Instance.new("UIScale")
    panelScale.Parent = panel
    local toggleScale = Instance.new("UIScale")
    toggleScale.Parent = toggle
    local function applyScale()
        local scale = math.min(HudLayout.GetScale(), 1)
        panelScale.Scale = scale
        toggleScale.Scale = scale
    end
    applyScale()
    HudLayout.Changed:Connect(applyScale)

    toggle.Activated:Connect(function()
        panel.Visible = not panel.Visible
    end)
    close.Activated:Connect(function()
        panel.Visible = false
    end)
    adminEvent.OnClientEvent:Connect(function(payload)
        if type(payload) == "table" and type(payload.message) == "string" then
            status.Text = payload.message
        end
    end)
end

-- 관리자 속성이 생기면(서버가 판정) 한 번만 만듭니다.
local built = false
local function tryBuild()
    if built or player:GetAttribute("ProjectMSAdmin") ~= true then
        return
    end
    built = true
    buildAdminUi()
end
tryBuild()
player:GetAttributeChangedSignal("ProjectMSAdmin"):Connect(tryBuild)
