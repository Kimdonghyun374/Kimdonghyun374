-- 개인 도시의 표시만 클라이언트에서 처리합니다. 피해/해금은 서버가 결정합니다.
-- 11시 패널(월드 정보·출격·귀환)은 나중에 스테이터스/할 일 목록 UI로 옮길 예정입니다(TODO.md).
-- 낮·밤은 12시(화면 위 가운데)에 표시하고, 시간이 되면 해가 바로 뜨고 집니다(2026-11-10).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local network = game.ReplicatedStorage:WaitForChild("PetMissiles")
local Config = require(network:WaitForChild("WorldConfig"))
local state, phaseDeadline, lastRequest = nil, 0, -math.huge
-- 낮/밤 하늘 시각. 서서히 바뀌지 않고 단계가 바뀌는 순간 이 값으로 바로 바뀝니다.
local DAY_CLOCK_TIME = 14
local NIGHT_CLOCK_TIME = 0
local appliedPhase
local gui = Instance.new("ScreenGui")
gui.Name = "WorldProgressHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 16
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
gui.Parent = player:WaitForChild("PlayerGui")
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Position = UDim2.fromOffset(12, 140)
panel.Size = UDim2.new(0.45, 0, 0, 176)
panel.BackgroundColor3 = Color3.fromRGB(17, 28, 44)
panel.BackgroundTransparency = 0.08
-- 2026-11-14 사용자 요청: 11시 월드 패널(진행·1월드 출격·2월드·기지 귀환)은 화면에서 뺍니다.
-- 이동은 관리자 창(AdminClient)으로 옮겼고, 일반 플레이어는 대로를 걸어서 1월드 도시로 갑니다.
-- 코드·통신은 그대로 두고 보이지만 않게 합니다(왼쪽 패널 줄에서도 빠짐).
panel.Visible = false
panel.Parent = gui
local size = Instance.new("UISizeConstraint")
size.MaxSize = Vector2.new(280, 176)
size.Parent = panel
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel
local function label(name, y, height)
    local item = Instance.new("TextLabel")
    item.Name = name
    item.Position = UDim2.fromOffset(10, y)
    item.Size = UDim2.new(1, -20, 0, height)
    item.BackgroundTransparency = 1
    item.Font = Enum.Font.GothamBold
    item.TextColor3 = Color3.fromRGB(229, 240, 250)
    item.TextSize = 14
    item.TextWrapped = true
    -- 서버 상태가 오기 전에 Roblox 기본 글자 "Label"이 보이지 않게 비워 둡니다.
    item.Text = ""
    item.Parent = panel
    return item
end
local progressLabel = label("Progress", 8, 42)
local messageLabel = label("Message", 150, 22)
messageLabel.TextSize = 11

-- 12시 낮·밤 표시
local phaseGui = Instance.new("ScreenGui")
phaseGui.Name = "DayNightHUD"
phaseGui.ResetOnSpawn = false
phaseGui.DisplayOrder = 16
phaseGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
phaseGui.Parent = player.PlayerGui
local phaseLabel = Instance.new("TextLabel")
phaseLabel.Name = "Phase"
phaseLabel.AnchorPoint = Vector2.new(0.5, 0)
phaseLabel.Position = UDim2.new(0.5, 0, 0, 10)
phaseLabel.Size = UDim2.fromOffset(260, 40)
phaseLabel.BackgroundColor3 = Color3.fromRGB(250, 252, 255)
phaseLabel.TextColor3 = Color3.fromRGB(16, 39, 94)
phaseLabel.Font = Enum.Font.GothamBlack
phaseLabel.TextSize = 18
phaseLabel.Text = ""
phaseLabel.Parent = phaseGui
local phaseCorner = Instance.new("UICorner")
phaseCorner.CornerRadius = UDim.new(0.5, 0)
phaseCorner.Parent = phaseLabel
local phaseStroke = Instance.new("UIStroke")
phaseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
phaseStroke.Thickness = 2
phaseStroke.Color = Color3.fromRGB(195, 213, 250)
phaseStroke.Parent = phaseLabel
local function request(payload)
    if os.clock() - lastRequest < 0.25 then
        return
    end
    lastRequest = os.clock()
    network.ProgressionRequest:FireServer(payload)
end
local function button(name, y, text, callback)
    local item = Instance.new("TextButton")
    item.Name = name
    item.Position = UDim2.fromOffset(10, y)
    item.Size = UDim2.new(1, -20, 0, 28)
    item.BackgroundColor3 = Color3.fromRGB(35, 130, 145)
    item.TextColor3 = Color3.new(1, 1, 1)
    item.Font = Enum.Font.GothamBold
    item.TextSize = 12
    item.TextWrapped = true
    item.Text = text
    item.Parent = panel
    item.Activated:Connect(callback)
    return item
end
local firstButton = button("World1", 56, "1월드 출격", function()
    request({ action = "enter", worldId = 1 })
end)
local secondButton = button("World2", 87, "2월드 · 잠김", function()
    request({ action = "enter", worldId = 2 })
end)
button("Home", 118, "기지로 귀환", function()
    request({ action = "home" })
end)
network.ProgressionState.OnClientEvent:Connect(function(nextState, message)
    state = nextState
    phaseDeadline = os.clock() + math.max(0, state.phaseEndsAt - state.serverClock)
    progressLabel.Text = string.format(
        "%s\n파괴 %d / %d%s",
        state.worldName,
        state.destroyed,
        state.total,
        state.cleared and " · 완파!" or ""
    )
    local nextWorld = state.worlds[2]
    local unlocked = nextWorld and nextWorld.unlocked
    -- 밤에는 서버가 출격을 거절하므로 버튼도 회색으로 보여 줍니다.
    local isNight = state.phase == "Night"
    firstButton.Text = isNight and "밤 · 출격 불가" or "1월드 출격"
    firstButton.BackgroundColor3 = isNight and Color3.fromRGB(65, 77, 96)
        or Color3.fromRGB(35, 130, 145)
    firstButton.Active = not isNight
    secondButton.Text = isNight and "밤 · 출격 불가"
        or unlocked and "2월드로 바로 이동"
        or "2월드 · 1월드 완파 필요"
    local canEnterSecond = unlocked == true and not isNight
    secondButton.BackgroundColor3 = canEnterSecond and Color3.fromRGB(35, 155, 130)
        or Color3.fromRGB(65, 77, 96)
    secondButton.Active = canEnterSecond
    if message then
        messageLabel.Text = message
    end
end)
-- 다른 소유자의 도시를 숨기고 로컬 이동/클릭을 방해하지 않도록 합니다.
local cities = workspace:WaitForChild(Config.PersonalCityFolder)
local function hideOtherCity(instance)
    local ancestor = instance
    local owner
    while ancestor and ancestor ~= cities do
        local id = ancestor:GetAttribute("OwnerUserId")
        if id ~= nil then
            owner = id
            break
        end
        ancestor = ancestor.Parent
    end
    if owner == nil or owner == player.UserId then
        return
    end
    if instance:IsA("BasePart") then
        instance.LocalTransparencyModifier = 1
        instance.CanCollide = false
        instance.CanQuery = false
        instance.CanTouch = false
    elseif instance:IsA("BillboardGui") then
        instance.Enabled = false
    end
end
for _, instance in cities:GetDescendants() do
    hideOtherCity(instance)
end
local added = cities.DescendantAdded:Connect(hideOtherCity)
local render = RunService.RenderStepped:Connect(function()
    if not state then
        phaseLabel.Text = "월드 정보 연결 중…"
        return
    end
    local remaining = math.max(0, phaseDeadline - os.clock())
    local isDay = state.phase == "Day"
    phaseLabel.Text = string.format(
        "%s  %d:%02d",
        isDay and "낮" or "밤 · 도시 수리",
        math.floor(remaining / 60),
        math.floor(remaining % 60)
    )
    phaseLabel.BackgroundColor3 = isDay and Color3.fromRGB(250, 252, 255) or Color3.fromRGB(16, 39, 94)
    phaseLabel.TextColor3 = isDay and Color3.fromRGB(16, 39, 94) or Color3.fromRGB(250, 252, 255)
    -- 단계가 바뀐 순간에만 하늘을 바꿉니다.
    if appliedPhase ~= state.phase then
        appliedPhase = state.phase
        Lighting.ClockTime = isDay and DAY_CLOCK_TIME or NIGHT_CLOCK_TIME
    end
end)
script.Destroying:Connect(function()
    added:Disconnect()
    render:Disconnect()
    gui:Destroy()
    phaseGui:Destroy()
end)
request({ action = "sync" })
