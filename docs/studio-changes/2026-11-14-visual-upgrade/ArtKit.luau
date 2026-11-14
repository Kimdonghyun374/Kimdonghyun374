-- Toy City v04: 승인된 v03 레퍼런스의 흰 외벽·파란 프레임·원색 포인트.
-- 장식은 판정에 참여하지 않습니다. 게임 루트/속성/상호작용 위치는 보존합니다.
local Kit = {}

Kit.Colors = {
    White = Color3.fromRGB(240, 245, 251),
    Concrete = Color3.fromRGB(198, 212, 229),
    Pale = Color3.fromRGB(221, 231, 243),
    Blue = Color3.fromRGB(48, 112, 224),
    DeepBlue = Color3.fromRGB(30, 65, 123),
    Glass = Color3.fromRGB(108, 177, 232),
    Yellow = Color3.fromRGB(255, 195, 48),
    Red = Color3.fromRGB(239, 82, 86),
    Green = Color3.fromRGB(104, 181, 72),
    Dark = Color3.fromRGB(62, 80, 108),
    Road = Color3.fromRGB(98, 117, 145),
}
local C = Kit.Colors

function Kit.Part(parent, name, size, frame, color, shape)
    local piece = Instance.new("Part")
    piece.Name = name
    piece.Size = size
    piece.CFrame = frame
    piece.Color = color
    piece.Material = Enum.Material.SmoothPlastic
    piece.Anchored = true
    piece.CanCollide = false
    piece.CanQuery = false
    piece.CanTouch = false
    piece.CastShadow = size.Y > 0.25
    piece.TopSurface = Enum.SurfaceType.Smooth
    piece.BottomSurface = Enum.SurfaceType.Smooth
    if shape then
        piece.Shape = shape
    end
    piece:SetAttribute("ToyCityArt", true)
    piece.Parent = parent
    return piece
end

function Kit.Folder(parent, name)
    local old = parent:FindFirstChild(name)
    if old then
        old:Destroy()
    end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
end

function Kit.Cylinder(parent, name, radius, height, frame, color)
    return Kit.Part(parent, name, Vector3.new(height, radius * 2, radius * 2),
        frame * CFrame.Angles(0, 0, math.pi / 2), color, Enum.PartType.Cylinder)
end

function Kit.Ring(parent, name, radius, width, height, center, color, segments)
    segments = segments or 48
    for index = 1, segments do
        local angle = index * math.pi * 2 / segments
        local frame = center * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -radius)
        Kit.Part(parent, name, Vector3.new(2 * radius * math.tan(math.pi / segments) + 0.04,
            height, width), frame, color)
    end
end

function Kit.Tree(parent, frame, scale)
    scale = scale or 1
    Kit.Part(parent, "Planter", Vector3.new(4, 0.8, 4) * scale, frame * CFrame.new(0, 0.4 * scale, 0), C.Concrete)
    Kit.Part(parent, "Soil", Vector3.new(3.3, 0.2, 3.3) * scale, frame * CFrame.new(0, 0.85 * scale, 0), C.Green)
    Kit.Part(parent, "Trunk", Vector3.new(0.75, 5, 0.75) * scale, frame * CFrame.new(0, 3 * scale, 0), Color3.fromRGB(153, 117, 79))
    for index, offset in {Vector3.new(-0.9, 6.5, 0), Vector3.new(0.9, 6.8, 0), Vector3.new(0, 8, 0)} do
        local green = index == 3 and Color3.fromRGB(131, 202, 76) or C.Green
        Kit.Part(parent, "Canopy", Vector3.new(4.4, 4.4, 4.2) * scale, frame * CFrame.new(offset * scale), green, Enum.PartType.Ball)
    end
end

function Kit.Lamp(parent, frame, actualLight)
    Kit.Cylinder(parent, "LampFoot", 0.65, 0.4, frame * CFrame.new(0, 0.2, 0), C.Dark)
    Kit.Cylinder(parent, "LampPost", 0.2, 7, frame * CFrame.new(0, 3.7, 0), C.Dark)
    local bulb = Kit.Part(parent, "LampGlass", Vector3.new(0.9, 1.1, 0.9), frame * CFrame.new(0, 7.5, 0), Color3.fromRGB(255, 232, 159))
    bulb.Material = Enum.Material.Neon
    Kit.Part(parent, "LampCap", Vector3.new(1.4, 0.35, 1.4), frame * CFrame.new(0, 8.2, 0), C.DeepBlue)
    if actualLight then
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 220, 156)
        light.Brightness = 0.65
        light.Range = 18
        light.Shadows = false
        light.Parent = bulb
    end
end

function Kit.WaterTank(parent, frame, scale)
    scale = scale or 1
    for _, x in {-1, 1} do
        for _, z in {-1, 1} do
            Kit.Part(parent, "TankLeg", Vector3.new(0.28, 2.2, 0.28) * scale,
                frame * CFrame.new(x * 1.1 * scale, 1.1 * scale, z * 1.1 * scale), C.Dark)
        end
    end
    Kit.Cylinder(parent, "WaterTank", 1.65 * scale, 2.6 * scale, frame * CFrame.new(0, 3.25 * scale, 0), C.Yellow)
    Kit.Cylinder(parent, "TankBlueCap", 1.8 * scale, 0.4 * scale, frame * CFrame.new(0, 4.75 * scale, 0), C.Blue)
    Kit.Cylinder(parent, "TankBand", 1.67 * scale, 0.14 * scale, frame * CFrame.new(0, 3.4 * scale, 0), C.White)
end

function Kit.City(model)
    local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    if not root then
        return
    end
    local details = Kit.Folder(model, "ArtDetails")
    local size = root.Size
    local width, height, depth = size.X, size.Y, size.Z
    local faceRoad = root.Position.X < 0 and -math.pi / 2 or math.pi / 2
    local base = root.CFrame * CFrame.new(0, -height / 2, 0) * CFrame.Angles(0, faceRoad, 0)
    local zone = model:GetAttribute("ZoneId") or 1
    local accent = zone == 2 and C.Red or C.Blue
    if model.Name:find("B", 1, true) then
        accent = C.Green
    end
    root.Color = C.White
    root.Material = Enum.Material.SmoothPlastic
    for _, item in model:GetChildren() do
        if item:IsA("BasePart") then
            if item.Name == "Window" then
                item.Color = C.Glass
                item.Material = Enum.Material.SmoothPlastic
                -- 기존 창문은 손상 시스템이 이름으로 찾으므로 이름/위치를 보존합니다.
                local sill = item.CFrame * CFrame.new(0, -item.Size.Y / 2 - 0.12, 0)
                Kit.Part(details, "WindowSill", Vector3.new(item.Size.X + 0.55, 0.24, 0.45), sill, C.Blue)
            elseif item.Name == "Roof" then
                item.Color = accent
                item.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    local function block(name, blockSize, position, color)
        return Kit.Part(details, name, blockSize, base * CFrame.new(position), color)
    end
    block("FoundationTrim", Vector3.new(width + 0.45, 0.65, depth + 0.45), Vector3.new(0, 0.4, 0), C.Concrete)
    block("RoofCornice", Vector3.new(width + 1, 0.6, depth + 1), Vector3.new(0, height - 0.2, 0), C.Pale)
    -- 길을 향한 면에도 창과 출입구가 보여야 공략 방향에서 건물로 읽힙니다.
    for level = 7, height - 2, 7 do
        for _, side in {-1, 1} do
            local position = Vector3.new(side * width * 0.27, level, -depth / 2 - 0.16)
            block("WindowFrame", Vector3.new(2.6, 3.1, 0.32), position, C.Blue)
            block("Window", Vector3.new(2.05, 2.55, 0.15), position + Vector3.new(0, 0, -0.22), C.Glass)
        end
    end
    for _, x in {-1, 1} do
        block("FacadePillar", Vector3.new(0.55, height - 1, 0.4), Vector3.new(x * (width / 2 - 0.4), height / 2, -depth / 2 - 0.12), C.Pale)
    end
    for level = 1, math.floor(height / 9) do
        block("FloorBelt", Vector3.new(width + 0.2, 0.22, depth + 0.2), Vector3.new(0, level * 9 - 1, 0), C.Pale)
    end
    block("DoorFrame", Vector3.new(3.6, 4.4, 0.35), Vector3.new(0, 2.3, -depth / 2 - 0.25), C.DeepBlue)
    block("DoorGlass", Vector3.new(2.7, 3.7, 0.15), Vector3.new(0, 2.3, -depth / 2 - 0.48), C.Glass)
    block("DoorDivider", Vector3.new(0.15, 3.8, 0.16), Vector3.new(0, 2.3, -depth / 2 - 0.58), C.Blue)
    local awning = block("RedAwning", Vector3.new(math.min(width - 1, 7), 0.45, 2), Vector3.new(0, 5, -depth / 2 - 0.7), C.Red)
    awning.CFrame *= CFrame.Angles(math.rad(-10), 0, 0)
    block("AwningValance", Vector3.new(math.min(width - 1, 7), 0.7, 0.2), Vector3.new(0, 4.65, -depth / 2 - 1.6), C.Red)
    for _, x in {-1, 1} do
        block("FlowerBox", Vector3.new(2.8, 0.8, 1.2), Vector3.new(x * (width / 2 - 1.9), 0.7, -depth / 2 - 0.5), C.Concrete)
        block("Hedge", Vector3.new(2.4, 1.2, 0.95), Vector3.new(x * (width / 2 - 1.9), 1.4, -depth / 2 - 0.5), C.Green)
    end
    if height >= 30 then
        Kit.WaterTank(details, base * CFrame.new(width * 0.22, height + 0.8, depth * 0.12), 0.8)
        block("RoofVent", Vector3.new(2.8, 1.4, 2.4), Vector3.new(-width * 0.23, height + 1.4, 0), C.Concrete)
    else
        block("RoofVent", Vector3.new(2.2, 1.2, 2), Vector3.new(width * 0.2, height + 1.2, 0), C.Yellow)
    end
    if zone == 3 then
        -- 계단 모양의 푸른 관측실로 연구 구역 실루엣을 차별화합니다.
        block("ResearchRoof", Vector3.new(width * 0.48, 3.6, depth * 0.46), Vector3.new(0, height + 2.5, 0), C.Pale)
        block("ResearchRoofCap", Vector3.new(width * 0.54, 0.45, depth * 0.52), Vector3.new(0, height + 4.5, 0), C.Blue)
        block("ResearchWindow", Vector3.new(width * 0.35, 1.7, 0.15), Vector3.new(0, height + 2.5, -depth * 0.235), C.Glass)
        Kit.Cylinder(details, "Antenna", 0.16, 4, base * CFrame.new(0, height + 6.5, 0), C.Yellow)
    end
    model:SetAttribute("VisualStyle", "ToyCity_v04")
end

function Kit.Station(anchor)
    local details = Kit.Folder(anchor, "ArtDetails")
    local origin = anchor.CFrame
    local function block(name, size, position, color)
        return Kit.Part(details, name, size, origin * CFrame.new(position), color)
    end
    anchor.Color = C.Blue
    anchor.Material = Enum.Material.SmoothPlastic
    block("MachinePlinth", Vector3.new(6.3, 0.4, 5.3), Vector3.new(0, -1.25, 0), C.Pale)
    block("MachineTop", Vector3.new(5.6, 0.3, 4.4), Vector3.new(0, 1.5, 0), C.White)
    block("BlueConsole", Vector3.new(2, 1.2, 0.35), Vector3.new(0.8, 0.25, -2.55), C.DeepBlue)
    block("ConsoleDisplay", Vector3.new(1.5, 0.65, 0.1), Vector3.new(0.8, 0.35, -2.78), C.Glass)
    block("StartButton", Vector3.new(0.5, 0.5, 0.2), Vector3.new(-1.3, 0.3, -2.65), C.Yellow)
    Kit.Cylinder(details, "ArmTurntable", 0.7, 0.4, origin * CFrame.new(-1.9, 1.9, 0.5), C.Blue)
    block("RobotArm", Vector3.new(0.5, 1.8, 0.5), Vector3.new(-1.9, 2.8, 0.5), C.Yellow)
    block("RobotForearm", Vector3.new(1.8, 0.45, 0.45), Vector3.new(-1.2, 3.6, 0.5), C.Yellow)
    block("RobotGripper", Vector3.new(0.45, 0.8, 0.7), Vector3.new(-0.4, 3.3, 0.5), C.Dark)
    Kit.Part(details, "DisplayRocket", Vector3.new(2.8, 0.65, 0.65), origin * CFrame.new(0.9, 2.2, 0.2) * CFrame.Angles(0, math.pi / 2, 0), C.White, Enum.PartType.Cylinder)
    Kit.Part(details, "RocketNose", Vector3.new(0.7, 0.7, 0.7), origin * CFrame.new(0.9, 2.2, -1.3), C.Blue, Enum.PartType.Ball)
    block("RocketFin", Vector3.new(1.5, 0.15, 0.7), Vector3.new(0.9, 2.2, 1.25), C.Yellow)
end

function Kit.Facility(parent, origin, width, depth, isAFK)
    local details = Kit.Folder(parent, "ArtDetails")
    local accent = isAFK and C.Green or C.Blue
    for _, item in parent:GetDescendants() do
        if item:IsA("BasePart") and not item:GetAttribute("ToyCityArt") then
            if item.Name:find("Wall") or item.Name == "Workbench" then
                item.Color = C.White
            elseif item.Name:find("Frame") or item.Name:find("Canopy") or item.Name == "Header" or item.Name == "Roof" then
                item.Color = accent
            elseif item.Name == "Foundation" or item.Name == "AFKLab" or item.Name == "AFKStayArea" then
                item.Color = C.Concrete
            elseif item.Name:find("RestPodSeat") then
                item.Color = C.White
            end
            if item.Transparency < 1 and item.Material ~= Enum.Material.Neon then
                item.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    local function block(name, size, offset, color)
        return Kit.Part(details, name, size, origin * CFrame.new(offset), color)
    end
    block("RoofFascia", Vector3.new(width + 0.6, 0.65, depth * 0.46), Vector3.new(0, 8.15, depth * 0.27), accent)
    for _, x in {-1, 1} do
        block("SidePanel", Vector3.new(0.6, 6.2, depth * 0.55), Vector3.new(x * (width / 2 - 0.25), 3.7, depth * 0.18), C.White)
        block("SideWindow", Vector3.new(0.65, 2.6, depth * 0.3), Vector3.new(x * width / 2, 4.5, depth * 0.16), C.Glass)
        block("DoorPost", Vector3.new(0.8, 6.8, 0.9), Vector3.new(x * (width / 2 - 0.6), 3.8, -depth / 2 + 0.6), C.White)
    end
    if isAFK then
        block("SolarPanel", Vector3.new(7, 0.4, 3.5), Vector3.new(0, 8.65, 3), C.DeepBlue)
        for x = -2, 2 do
            block("SolarGrid", Vector3.new(0.08, 0.05, 3.3), Vector3.new(x * 1.2, 8.88, 3), C.Glass)
        end
        block("SleepCabinet", Vector3.new(2.2, 3, 2.2), Vector3.new(5.8, 2, 3), C.White)
        block("SleepStatus", Vector3.new(1.7, 0.25, 0.2), Vector3.new(5.8, 3.1, 1.85), C.Green)
    else
        Kit.Cylinder(details, "RadarPedestal", 0.7, 1.1, origin * CFrame.new(0, 8.8, 3), C.White)
        local dish = Kit.Part(details, "RadarDish", Vector3.new(0.5, 4, 4), origin * CFrame.new(0, 10, 3) * CFrame.Angles(0, 0, math.rad(50)), C.Blue, Enum.PartType.Cylinder)
        dish.Material = Enum.Material.SmoothPlastic
        block("LabLight", Vector3.new(6, 0.3, 0.4), Vector3.new(0, 6.9, -depth / 2 + 0.45), C.Yellow)
    end
end

function Kit.Boss(model)
    local core = model.PrimaryPart
    if not core then
        return
    end
    local details = Kit.Folder(model, "ArtDetails")
    for _, piece in model:GetDescendants() do
        if piece:IsA("BasePart") then
            if piece.Name == "Hull" or piece.Name == "Dome" then
                piece.Color = C.White
                piece.Material = Enum.Material.SmoothPlastic
            elseif piece.Name == "Plate" then
                piece.Color = C.Blue
                piece.Material = Enum.Material.SmoothPlastic
            end
        end
    end
    Kit.Ring(details, "BlueHullTrim", 16.5, 0.7, 1, core.CFrame * CFrame.new(0, -1.8, 0), C.Blue, 24)
    for index = 1, 6 do
        local frame = core.CFrame * CFrame.Angles(0, math.rad(index * 60), 0) * CFrame.new(0, -3.8, -12)
        Kit.Part(details, "Vent", Vector3.new(3.2, 1.8, 0.5), frame, C.DeepBlue)
        Kit.Part(details, "HazardLight", Vector3.new(2.3, 0.35, 0.55), frame * CFrame.new(0, 0.2, -0.1), C.Yellow)
    end
end

function Kit.Vehicle(model)
    local deck = model.PrimaryPart or model:FindFirstChild("Deck")
    if not deck then
        return
    end
    local details = Kit.Folder(model, "ArtDetails")
    for _, x in {-1, 1} do
        Kit.Cylinder(details, "HoverFan", 0.8, 0.22, deck.CFrame * CFrame.new(x * 0.85, 0.3, 1.3), C.Dark)
        Kit.Cylinder(details, "FanHub", 0.28, 0.26, deck.CFrame * CFrame.new(x * 0.85, 0.44, 1.3), C.Yellow)
    end
    Kit.Part(details, "NoseBumper", Vector3.new(2.6, 0.45, 0.5), deck.CFrame * CFrame.new(0, -0.1, -2.3), C.White)
    Kit.Part(details, "TailBumper", Vector3.new(2.6, 0.45, 0.5), deck.CFrame * CFrame.new(0, -0.1, 2.3), C.Yellow)
end

return Kit
