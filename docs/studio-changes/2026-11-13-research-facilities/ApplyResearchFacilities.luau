-- 연구시설 외형 분리. Edit에서 한 번 실행하는 배치 스크립트입니다.
local bases = workspace.ProjectMS_Bases
for id = 1, 6 do
    assert(not bases["Base_" .. id].Layout:FindFirstChild("TechLab"), "이미 반영된 기지입니다. 중복 실행하지 마세요.")
end
local backup = Instance.new("Folder")
backup.Name = "BeforeResearchFacilitiesSplit_" .. os.time()
backup.Parent = game.ServerStorage.ProjectMSBackups
for id = 1, 6 do
    local base = bases["Base_" .. id]
    local snapshot = Instance.new("Folder")
    snapshot.Name = base.Name
    snapshot.Parent = backup
    base.Layout.AFKLab:Clone().Parent = snapshot
    base.Storage:Clone().Parent = snapshot
    base.Layout.Label_Storage:Clone().Parent = snapshot
end

local purple = Color3.fromRGB(154, 111, 221)
local cyan = Color3.fromRGB(60, 190, 211)
local dark = Color3.fromRGB(39, 53, 77)
local white = Color3.fromRGB(226, 237, 245)

local function part(parent, name, size, frame, color, solid)
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.CFrame = frame
    item.Color = color
    item.Material = Enum.Material.SmoothPlastic
    item.Anchored = true
    item.CanCollide = solid == true
    item.CanTouch = false
    item.TopSurface = Enum.SurfaceType.Smooth
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.Parent = parent
    return item
end

local function sign(anchor, title, subtitle, accent)
    local gui = Instance.new("BillboardGui")
    gui.Name = "FacilitySign"
    gui.Size = UDim2.fromOffset(240, 64)
    gui.MaxDistance = 85
    gui.AlwaysOnTop = false
    gui.Parent = anchor
    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = dark
    label.BackgroundTransparency = 0.08
    label.TextColor3 = white
    label.Font = Enum.Font.GothamBold
    label.TextSize = 17
    label.Text = title .. "\n" .. subtitle
    label.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    local border = Instance.new("UIStroke")
    border.Color = accent
    border.Thickness = 2
    border.Parent = label
end

for id = 1, 6 do
    local base = bases["Base_" .. id]
    local origin = base.Floor.CFrame * CFrame.new(0, -0.25, 0)
    local layout = base.Layout
    local afk = layout.AFKLab
    afk:SetAttribute("FacilityType", "AFK")
    afk:SetAttribute("PrototypeOnly", true)
    afk:SetAttribute("Purpose", "머무르며 연구자료 획득 — 보상 기능 구현 예정")
    -- 기존 자리를 유지하며 막힌 유리 상자를 열린 대기실로 바꿉니다.
    local deck = afk.AFKLab
    deck.Size = Vector3.new(22, 0.4, 24)
    deck.CFrame = origin * CFrame.new(15, 0.7, 24)
    deck.Transparency = 0
    deck.Color = Color3.fromRGB(94, 72, 130)
    deck.CanCollide = false
    local oldLabel = afk.Label_AFKLab
    oldLabel:Destroy()
    part(afk, "Canopy", Vector3.new(22, 0.8, 16), origin * CFrame.new(15, 10.5, 28), purple, false)
    for _, x in ipairs({5, 25}) do
        part(afk, "CanopyPost", Vector3.new(0.7, 9.6, 0.7), origin * CFrame.new(x, 5.5, 34.5), dark, false)
    end
    for _, x in ipairs({10, 20}) do
        part(afk, "RestPodSeat", Vector3.new(5, 0.8, 5), origin * CFrame.new(x, 1.3, 24), white, false)
        part(afk, "RestPodBack", Vector3.new(5, 3, 0.7), origin * CFrame.new(x, 3, 26.2), purple, false)
        local glow = part(afk, "RestPodLight", Vector3.new(5, 0.12, 0.3), origin * CFrame.new(x, 1.75, 21.6), purple, false)
        glow.Material = Enum.Material.Neon
    end
    local zone = part(afk, "AFKStayArea", Vector3.new(15, 0.12, 6), origin * CFrame.new(15, 0.98, 16.5), purple, false)
    zone.Transparency = 0.3
    zone:SetAttribute("FutureAFKZone", true)
    part(afk, "ClockFace", Vector3.new(4, 4, 0.3), origin * CFrame.new(15, 7, 33), white, false)
    part(afk, "ClockMinuteHand", Vector3.new(0.18, 1.4, 0.15), origin * CFrame.new(15, 7.6, 32.76), dark, false)
    part(afk, "ClockHourHand", Vector3.new(1.1, 0.18, 0.15), origin * CFrame.new(15.45, 7, 32.76), dark, false)
    local afkAnchor = part(afk, "Label_AFK", Vector3.one, origin * CFrame.new(15, 17.5, 24), purple, false)
    afkAnchor.Transparency = 1
    sign(afkAnchor, "AFK 연구시설", "대기 · 연구자료 획득 예정", purple)

    local tech = Instance.new("Model")
    tech.Name = "TechLab"
    tech:SetAttribute("FacilityType", "Technology")
    tech:SetAttribute("PrototypeOnly", true)
    tech:SetAttribute("Purpose", "연구자료로 확정 강화 — 장착 수 등 기술 개발 예정")
    part(tech, "Foundation", Vector3.new(22, 0.4, 20), origin * CFrame.new(-15, 0.7, 24), Color3.fromRGB(55, 95, 118), false)
    part(tech, "BackWall", Vector3.new(22, 8, 0.6), origin * CFrame.new(-15, 4.9, 33.7), dark, true)
    part(tech, "Roof", Vector3.new(22, 0.7, 9), origin * CFrame.new(-15, 9.2, 30), cyan, false)
    for _, x in ipairs({-25.5, -4.5}) do
        part(tech, "Frame", Vector3.new(0.7, 8, 0.7), origin * CFrame.new(x, 4.9, 15), cyan, false)
    end
    part(tech, "Header", Vector3.new(22, 0.9, 0.7), origin * CFrame.new(-15, 9.1, 15), cyan, false)
    part(tech, "Workbench", Vector3.new(15, 2, 4), origin * CFrame.new(-15, 2, 28), white, false)
    local screen = part(tech, "BlueprintScreen", Vector3.new(13, 4.2, 0.3), origin * CFrame.new(-15, 5.5, 29.4), Color3.fromRGB(20, 75, 102), false)
    local trace = part(tech, "MissileBlueprintBody", Vector3.new(0.9, 2.3, 0.13), origin * CFrame.new(-15, 5.6, 29.16), cyan, false)
    trace.Material = Enum.Material.Neon
    part(tech, "MissileBlueprintFins", Vector3.new(2.2, 0.5, 0.13), origin * CFrame.new(-15, 4.7, 29.16), cyan, false)
    for _, x in ipairs({-19, -11}) do
        for _, y in ipairs({4.7, 5.6, 6.5}) do
            part(tech, "BlueprintData", Vector3.new(2.5, 0.16, 0.13), origin * CFrame.new(x, y, 29.16), cyan, false)
        end
    end
    local console = part(tech, "DevelopmentTerminal", Vector3.new(5, 3, 3), origin * CFrame.new(-15, 2.4, 18.5), dark, false)
    part(tech, "TerminalScreen", Vector3.new(4.4, 0.2, 2.4), origin * CFrame.new(-15, 4, 18.5), cyan, false).Material = Enum.Material.Neon
    local anchor = part(tech, "Label_Tech", Vector3.one, origin * CFrame.new(-15, 12, 24), cyan, false)
    anchor.Transparency = 1
    sign(anchor, "기술 개발실", "연구자료 사용 · 확정 강화 예정", cyan)
    -- 실제 메뉴가 연결되기 전에는 작동하지 않는 E 프롬프트를 만들지 않습니다.
    tech.Parent = layout
    -- 제거된 보관함 기능의 원본은 유지하되 겹치는 옛 표지만 Edit에서도 숨깁니다.
    base.Storage.Transparency = 1
    base.Storage.CanCollide = false
    for _, child in ipairs(base.Storage:GetDescendants()) do
        if child:IsA("LayerCollector") or child:IsA("ProximityPrompt") then
            child.Enabled = false
        end
    end
    for _, child in ipairs(layout.Label_Storage:GetDescendants()) do
        if child:IsA("LayerCollector") then
            child.Enabled = false
        end
    end
    task.wait()
end
return {backup = backup:GetFullName(), bases = 6, facilities = 12}
