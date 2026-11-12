assert(not workspace.ProjectMS_Bases.Base_1.Layout:FindFirstChild("MainRoute"), "부지 변경이 이미 반영되었습니다")
-- 부지와 시설 크기를 조정하고 도시 구역 1~3을 배치합니다.
local bases = workspace.ProjectMS_Bases
local function part(parent, name, size, frame, color, collide)
    local object = Instance.new("Part")
    object.Name = name
    object.Size = size
    object.CFrame = frame
    object.Color = color
    object.Anchored = true
    object.CanCollide = collide == true
    object.TopSurface = Enum.SurfaceType.Smooth
    object.BottomSurface = Enum.SurfaceType.Smooth
    object.Parent = parent
    return object
end
local function scaleFacility(root, origin, center, factors)
    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("BasePart") then
            local localFrame = origin:ToObjectSpace(object.CFrame)
            local offset = localFrame.Position - center
            local position = center + offset * factors
            object.CFrame = origin * CFrame.new(position) * localFrame.Rotation
            object.Size *= factors
        end
    end
end
for id = 1, 6 do
    local base = bases["Base_" .. id]
    local origin = base.Floor.CFrame * CFrame.new(0, -base.Floor.Position.Y, 0)
    base.Floor.Size = Vector3.new(96, 0.5, 120)
    base:SetAttribute("PlotWidth", 96)
    base:SetAttribute("PlotDepth", 120)
    for _, object in ipairs(base.Layout.Gallery:GetDescendants()) do
        if object:IsA("BasePart") then
            local position = origin:PointToObjectSpace(object.Position)
            object.CFrame += origin:VectorToWorldSpace(Vector3.new(position.X > 0 and 8 or -8, 0, 0))
        end
    end
    local displayPosition = origin:PointToObjectSpace(base.Display.Position)
    base.Display.CFrame += origin:VectorToWorldSpace(Vector3.new(displayPosition.X > 0 and 8 or -8, 0, 0))
    scaleFacility(base.Layout.TechLab, origin, Vector3.new(-15, 0.5, 24), Vector3.new(16 / 22, 0.85, 14 / 20))
    scaleFacility(base.Layout.AFKLab, origin, Vector3.new(15, 0.5, 24), Vector3.new(16 / 22, 0.85, 16 / 24))
    local upgrade = base.Layout.ProductionUpgrade
    for _, object in ipairs(upgrade:GetDescendants()) do
        if object:IsA("BasePart") then
            object.CFrame += origin:VectorToWorldSpace(Vector3.new(23, 0, 8))
        end
    end
    local path = Instance.new("Folder")
    path.Name = "MainRoute"
    path.Parent = base.Layout
    local color = Color3.fromRGB(65, 210, 215)
    for _, x in ipairs({-4, 4}) do
        local line = part(path, "RouteLine", Vector3.new(0.18, 0.08, 100), origin * CFrame.new(x, 0.56, 3), color, false)
        line.Material = Enum.Material.Neon
    end
    for _, z in ipairs({-8, 13, 38, 55}) do
        for _, side in ipairs({-1, 1}) do
            local arrow = part(path, "ForwardChevron", Vector3.new(0.2, 0.1, 3), origin * CFrame.new(side, 0.58, z) * CFrame.Angles(0, math.rad(side * 35), 0), color, false)
            arrow.Material = Enum.Material.Neon
        end
    end
    for _, x in ipairs({-6, 6}) do
        part(path, "ExitPost", Vector3.new(0.7, 7, 0.7), origin * CFrame.new(x, 4, 57), color, false)
    end
    part(path, "ExitHeader", Vector3.new(12.7, 0.8, 0.8), origin * CFrame.new(0, 7.7, 57), color, false)
    base.Layout.LaneExit.CFrame = origin * CFrame.new(0, 0.56, 57)
    base.Layout.Label_LaneExit.CFrame = origin * CFrame.new(0, 5.5, 57)
    task.wait()
end
local city = workspace.ProjectMS_City
local positions = {
    ["주택"] = Vector3.new(-24, 0, -280),
    ["주택B"] = Vector3.new(24, 0, -286),
    ["상가"] = Vector3.new(24, 0, -338),
    ["상가B"] = Vector3.new(-24, 0, -344),
    ["창고"] = Vector3.new(-24, 0, -375),
    ["사무실"] = Vector3.new(-24, 0, -425),
    ["사무실B"] = Vector3.new(24, 0, -432),
    ["연구동"] = Vector3.new(26, 0, -474),
}
for name, position in pairs(positions) do
    local model = city[name]
    local pivot = model:GetPivot()
    model:PivotTo(CFrame.new(position.X, pivot.Y, position.Z) * pivot.Rotation)
    model:SetAttribute("ZoneId", 1)
end
local groups = {
    { zone = 2, prefix = "상업가", entries = {
        {"상가", -26, 590, 160, 45}, {"상가B", 26, 596, 160, 45},
        {"사무실", -26, 656, 320, 80}, {"사무실B", 26, 662, 320, 80},
        {"연구동", -27, 730, 640, 140}, {"연구동", 27, 738, 640, 140},
    }},
    { zone = 3, prefix = "산업연구구역", entries = {
        {"창고", -27, 833, 320, 80}, {"창고", 27, 839, 320, 80},
        {"사무실", -27, 884, 640, 140}, {"사무실B", 27, 890, 640, 140},
        {"연구동", -28, 943, 960, 200}, {"연구동", 28, 949, 960, 200},
        {"연구동", -28, 1004, 1600, 300}, {"연구동", 28, 1012, 1600, 300},
    }},
}
for _, group in ipairs(groups) do
    for i, entry in ipairs(group.entries) do
        local model = city[entry[1]]:Clone()
        local scale = group.zone == 3 and (i >= 7 and 1.35 or 1.15) or 1.05
        model:ScaleTo(model:GetScale() * scale)
        model.Name = group.prefix .. "_" .. i
        model:SetAttribute("BuildingId", "Z" .. group.zone .. "_" .. i)
        model:SetAttribute("ZoneId", group.zone)
        model:SetAttribute("BuildingHealth", entry[4])
        model:SetAttribute("ScrapReward", entry[5])
        local pivot, size = model:GetBoundingBox()
        local current = model:GetPivot()
        model:PivotTo(CFrame.new(entry[2], current.Y + 0.5 - (pivot.Y - size.Y / 2), -entry[3]) * current.Rotation)
        model.Parent = city
    end
    task.wait()
end
return "기지96×120, 시설축소·동선·구역1 8채 + 구역2 6채 + 구역3 8채 배치"
