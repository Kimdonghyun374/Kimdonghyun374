-- 화면 크기·기기(PC/모바일)에 맞춘 HUD 배율과 버튼 자리를 한곳에서 정합니다(2026-11-14).
-- 배율: UIScaleClient가 모든 HUD에 적용. 자리: 각 스크립트가 HudLayout.Place(버튼, 자리이름)로 등록.
-- PC는 액션 버튼(집중 발사·권총)을 왼쪽 아래, 모바일은 점프 버튼 주변에 둡니다.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local HudLayout = {}

-- 배율 기준: 화면 짧은 변(px)을 이 값으로 나눈 뒤 범위 안으로 자릅니다.
local PC_SHORT_SIDE_BASE = 600
local PC_SCALE_MIN, PC_SCALE_MAX = 1, 1.5
local TOUCH_SHORT_SIDE_BASE = 520
local TOUCH_SCALE_MIN, TOUCH_SCALE_MAX = 0.65, 1.1
-- 이 짧은 변(px) 이하 화면은 키보드가 있어도 모바일 배치로 봅니다(Studio 기기 에뮬레이터는 키보드도 켜져 있음).
local SMALL_SCREEN_SHORT_SIDE = 520
-- 화면 비율 크기(팝업 창)는 이 배율을 넘지 않게 합니다.
local POPUP_SCALE_MAX = 1

-- 버튼 기본 크기(px, 배율 적용 전)
HudLayout.ButtonSize = {
    Focus = 96,
    PistolEquip = 78,
    PistolFire = 78,
    MenuIcon = 64,
}
local SCREEN_MARGIN = 20
local BUTTON_GAP = 14
local FOCUS_GAUGE_SPACE = 16 -- 집중 발사 버튼 아래 게이지 자리
local MENU_TOP_PC = 144 -- 오른쪽 메뉴 버튼 줄 시작 높이(px)
local MENU_TOP_TOUCH = 60
local LEFT_TOP_PC = 120 -- 왼쪽 패널 줄(월드 패널 → 코인 패널) 시작 높이(px)
local LEFT_TOP_TOUCH = 56
local LEFT_GAP = 10 -- 왼쪽 패널 사이 간격(배율 적용 전)
local MENU_CAPTION_SPACE = 18 -- 메뉴 버튼 아래 글자 자리

local player = Players.LocalPlayer
local placed = {} -- [GuiObject] = 자리이름
local changedEvent = Instance.new("BindableEvent")
HudLayout.Changed = changedEvent.Event

-- 시험용: LocalPlayer 속성 HudForceTouch(bool)·HudForceViewport(Vector2)로 기기·화면을 흉내 냅니다.
local function viewportSize()
    local forced = player and player:GetAttribute("HudForceViewport")
    if typeof(forced) == "Vector2" then
        return forced
    end
    local camera = workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function hasJumpButton()
    local playerGui = player and player:FindFirstChild("PlayerGui")
    local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
    local jump = touchGui and touchGui:FindFirstChild("JumpButton", true)
    return jump ~= nil and jump.Visible
end

-- 모바일 배치 여부: 터치 전용 기기, 또는 터치가 되고(점프 버튼이 있거나 화면이 작은) 경우.
function HudLayout.IsTouch()
    local forced = player and player:GetAttribute("HudForceTouch")
    if forced ~= nil then
        return forced
    end
    if not UserInputService.TouchEnabled then
        return false
    end
    if not UserInputService.KeyboardEnabled then
        return true
    end
    local size = viewportSize()
    return hasJumpButton() or math.min(size.X, size.Y) <= SMALL_SCREEN_SHORT_SIDE
end

function HudLayout.GetScale()
    local size = viewportSize()
    local shortSide = math.min(size.X, size.Y)
    if HudLayout.IsTouch() then
        return math.clamp(shortSide / TOUCH_SHORT_SIDE_BASE, TOUCH_SCALE_MIN, TOUCH_SCALE_MAX)
    end
    return math.clamp(shortSide / PC_SHORT_SIDE_BASE, PC_SCALE_MIN, PC_SCALE_MAX)
end

-- 화면 비율로 크기를 잡은 큰 창(보관함·차고)은 너무 커지지 않게 배율 상한을 둡니다.
function HudLayout.GetScaleFor(guiObject)
    local scale = HudLayout.GetScale()
    if guiObject:IsA("GuiObject") and (guiObject.Size.X.Scale >= 0.6 or guiObject.Size.Y.Scale >= 0.5) then
        return math.min(scale, POPUP_SCALE_MAX)
    end
    return scale
end

-- 모바일 점프 버튼의 화면 위치(가운데·반지름). 아직 없으면 Roblox 기본 위치로 짐작합니다.
local function jumpButtonCircle(screenSize)
    local playerGui = player and player:FindFirstChild("PlayerGui")
    local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
    local frame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
    local jump = frame and frame:FindFirstChild("JumpButton")
    if jump and jump.AbsoluteSize.X > 0 then
        return jump.AbsolutePosition + jump.AbsoluteSize / 2, jump.AbsoluteSize.X / 2, true
    end
    local isSmall = math.min(screenSize.X, screenSize.Y) <= 500
    local radius = isSmall and 35 or 60
    local offset = isSmall and Vector2.new(95, 90) or Vector2.new(170, 210)
    return Vector2.new(screenSize.X - offset.X + radius, screenSize.Y - offset.Y + radius), radius, false
end

local slotCenterButton
-- 등록된 자리이름 → GuiObject (왼쪽 패널 줄에서 위 패널을 찾을 때 씀)
local function findPlaced(slotName)
    for guiObject, name in placed do
        if name == slotName and guiObject.Parent then
            return guiObject
        end
    end
    return nil
end

-- 자리이름 → (기준 좌표 px, AnchorPoint). screenGui 기준 좌표로 돌려줍니다.
local function slotCenter(slotName, screenGui)
    local isTouch = HudLayout.IsTouch()
    if slotName == "LeftWorld" then
        return Vector2.new(SCREEN_MARGIN * 0.6, isTouch and LEFT_TOP_TOUCH or LEFT_TOP_PC), Vector2.new(0, 0)
    elseif slotName == "LeftResources" then
        -- 월드 패널 바로 아래(겹치지 않게 실제 크기 기준)
        local above = findPlaced("LeftWorld")
        local top = isTouch and LEFT_TOP_TOUCH or LEFT_TOP_PC
        if above and above.Visible then
            top = above.AbsolutePosition.Y + above.AbsoluteSize.Y - screenGui.AbsolutePosition.Y + LEFT_GAP * HudLayout.GetScale()
        end
        return Vector2.new(SCREEN_MARGIN * 0.6, top), Vector2.new(0, 0)
    end
    return slotCenterButton(slotName, screenGui, isTouch), Vector2.new(0.5, 0.5)
end

function slotCenterButton(slotName, screenGui, isTouch)
    local scale = HudLayout.GetScale()
    local guiSize = screenGui.AbsoluteSize
    local sizes = HudLayout.ButtonSize
    local focusSize = sizes.Focus * scale
    local pistolSize = sizes.PistolEquip * scale
    local gap = BUTTON_GAP * scale

    if slotName == "MenuInventory" or slotName == "MenuVehicle" then
        local index = slotName == "MenuInventory" and 0 or 1
        local menuSize = sizes.MenuIcon * scale
        local step = menuSize + (MENU_CAPTION_SPACE + BUTTON_GAP) * scale
        local menuTop = isTouch and MENU_TOP_TOUCH or MENU_TOP_PC
        return Vector2.new(guiSize.X - SCREEN_MARGIN - menuSize / 2, menuTop + menuSize / 2 + index * step)
    end

    if isTouch then
        -- 점프 버튼 왼쪽(집중 발사), 위(권총 장착), 왼쪽 위 대각선(권총 발사)
        local center, radius = jumpButtonCircle(guiSize + screenGui.AbsolutePosition)
        center -= screenGui.AbsolutePosition
        if slotName == "Focus" then
            return center + Vector2.new(-(radius + gap + focusSize / 2), 0)
        elseif slotName == "PistolEquip" then
            return center + Vector2.new(0, -(radius + gap + pistolSize / 2))
        elseif slotName == "PistolFire" then
            local distance = (radius + gap + focusSize / 2) * 1.3
            return center + Vector2.new(-distance, -distance) * 0.7071
        end
    else
        -- 왼쪽 아래에 가로 한 줄: 집중 발사 · 권총 장착 · 권총 발사
        local bottom = guiSize.Y - SCREEN_MARGIN - FOCUS_GAUGE_SPACE * scale
        local focusX = SCREEN_MARGIN + focusSize / 2
        if slotName == "Focus" then
            return Vector2.new(focusX, bottom - focusSize / 2)
        end
        local equipX = focusX + focusSize / 2 + gap + pistolSize / 2
        if slotName == "PistolEquip" then
            return Vector2.new(equipX, bottom - pistolSize / 2)
        elseif slotName == "PistolFire" then
            return Vector2.new(equipX + pistolSize + gap, bottom - pistolSize / 2)
        end
    end
    return guiSize / 2
end

local function applyPlacement(guiObject, slotName)
    local screenGui = guiObject:FindFirstAncestorWhichIsA("ScreenGui")
    if not screenGui then
        return
    end
    local point, anchor = slotCenter(slotName, screenGui)
    guiObject.AnchorPoint = anchor
    guiObject.Position = UDim2.fromOffset(math.floor(point.X + 0.5), math.floor(point.Y + 0.5))
end

-- 위에 놓일 것부터(왼쪽 월드 패널 → 코인 패널) 순서대로 놓습니다.
local SLOT_ORDER = { LeftWorld = 1, LeftResources = 2 }
function HudLayout.Refresh(quiet)
    local list = {}
    for guiObject, slotName in placed do
        if guiObject.Parent then
            table.insert(list, guiObject)
        else
            placed[guiObject] = nil
        end
    end
    table.sort(list, function(first, second)
        return (SLOT_ORDER[placed[first]] or 9) < (SLOT_ORDER[placed[second]] or 9)
    end)
    for _, guiObject in list do
        applyPlacement(guiObject, placed[guiObject])
    end
    if not quiet then
        changedEvent:Fire()
    end
end

-- 버튼을 자리에 등록합니다. 화면 크기·기기·점프 버튼 위치가 바뀌면 다시 놓습니다.
function HudLayout.Place(guiObject, slotName)
    placed[guiObject] = slotName
    applyPlacement(guiObject, slotName)
end

-- 화면 변화 감시: 크기는 바로, 점프 버튼 등장·이동은 0.5초마다 확인합니다.
local lastSignature = ""
local elapsed = 0
local function signature()
    local size = viewportSize()
    local playerGui = player and player:FindFirstChild("PlayerGui")
    local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
    local jump = touchGui and touchGui:FindFirstChild("JumpButton", true)
    local jumpText = jump and tostring(jump.AbsolutePosition) .. tostring(jump.AbsoluteSize) or "none"
    return string.format("%d,%d,%s,%s", size.X, size.Y, tostring(HudLayout.IsTouch()), jumpText)
end
if RunService:IsClient() then
    RunService.Heartbeat:Connect(function(deltaTime)
        elapsed += deltaTime
        if elapsed < 0.5 then
            return
        end
        elapsed = 0
        local current = signature()
        if current ~= lastSignature then
            lastSignature = current
            HudLayout.Refresh()
        else
            -- 패널 크기(글 줄 수 등)가 바뀌어도 겹치지 않게 자리만 조용히 다시 놓습니다.
            HudLayout.Refresh(true)
        end
    end)
end

return HudLayout
