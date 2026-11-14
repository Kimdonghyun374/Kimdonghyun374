-- Edit 전용. 백업을 만든 뒤 ArtKit으로 기존 맵에 그래픽을 입힙니다.
local Kit = require(game.ReplicatedStorage.PetMissiles.ArtKit)
local C = Kit.Colors
local bases = workspace.ProjectMS_Bases
local lanes = workspace.ProjectMS_Lanes

local function surface(parent, name, size, frame, color)
    return Kit.Part(parent, name, size, frame, color)
end

-- 공용 광장: 전투 원은 낮은 채도의 푸른 바닥, 둘레 보행 공간은 밝은 타일.
local plaza = Kit.Folder(lanes, "ToyCityPlaza")
lanes.PlazaFloor.Color = C.Pale
lanes.PlazaFloor.Material = Enum.Material.SmoothPlastic
lanes.RaidArena.RaidFloor.Color = Color3.fromRGB(179, 200, 226)
lanes.RaidArena.RaidFloor.Material = Enum.Material.SmoothPlastic
local center = CFrame.new(0, 0.29, 0)
Kit.Ring(plaza, "ArenaBoundary", 119, 1, 0.1, center, C.Blue, 72)
Kit.Ring(plaza, "ArenaSafetyLine", 123, 0.35, 0.1, center, C.White, 72)
Kit.Ring(plaza, "PlazaOuterCurb", 167, 1.3, 0.3, center, C.White, 72)
Kit.Ring(plaza, "CenterTarget", 20, 0.5, 0.1, center, C.White, 24)
Kit.Ring(plaza, "CenterTargetInner", 8, 0.4, 0.1, center, C.Blue, 20)
for index = 1, 6 do
    local angle = math.rad((index - 1) * 60)
    local direction = CFrame.Angles(0, angle, 0)
    for step = 0, 4 do
        surface(plaza, "BaseApproachStripe", Vector3.new(11, 0.08, 2),
            center * direction * CFrame.new(0, 0.06, -136 - step * 6), C.White)
    end
    local garden = direction * CFrame.Angles(0, math.rad(30), 0) * CFrame.new(0, 0.35, -150)
    Kit.Tree(plaza, garden * CFrame.new(-5, 0, 0), 1.4)
    Kit.Tree(plaza, garden * CFrame.new(5, 0, 0), 1.1)
    Kit.Lamp(plaza, garden * CFrame.new(-12, 0, -1), true)
    Kit.Lamp(plaza, garden * CFrame.new(12, 0, -1), true)
    surface(plaza, "BenchSeat", Vector3.new(7, 0.5, 2), garden * CFrame.new(0, 1.5, 3), C.Yellow)
    surface(plaza, "BenchBack", Vector3.new(7, 2, 0.4), garden * CFrame.new(0, 2.4, 3.9), C.Blue)
    for _, x in {-2.7, 2.7} do
        surface(plaza, "BenchLeg", Vector3.new(0.5, 1.4, 1.5), garden * CFrame.new(x, 0.7, 3), C.Dark)
    end
end
workspace.SpawnLocation.Color = C.Blue
workspace.SpawnLocation.Material = Enum.Material.SmoothPlastic
workspace.SpawnLocation.Transparency = 0.1
local spawnArt = Kit.Folder(workspace.SpawnLocation, "ArtDetails")
Kit.Ring(spawnArt, "ArrivalCircle", 8, 0.5, 0.1,
    CFrame.new(workspace.SpawnLocation.Position.X, 1.03, workspace.SpawnLocation.Position.Z), C.Yellow, 20)

-- 기지의 바닥/고정 경계와 구매에 따라 켜지는 시설 장식을 서로 다른 부모에 둡니다.
for index = 1, 6 do
    local base = bases["Base_" .. index]
    local origin = base:GetPivot()
    local layout = base.Layout
    base.Floor.Color = C.Pale
    base.Floor.Material = Enum.Material.SmoothPlastic
    base.ClaimPad.Color = C.Green
    base.ClaimPad.Material = Enum.Material.SmoothPlastic
    local foundation = Kit.Folder(base.Floor, "ArtDetails")
    for _, x in {-1, 1} do
        surface(foundation, "PlotEdge", Vector3.new(0.7, 0.35, 119), origin * CFrame.new(x * 47.5, 0.35, 0), C.Blue)
    end
    for _, z in {-1, 1} do
        for _, x in {-1, 1} do
            surface(foundation, "PlotFrontCurb", Vector3.new(39, 0.35, 0.7), origin * CFrame.new(x * 28, 0.35, z * 59.5), C.White)
        end
    end
    for _, x in {-28, -14, 14, 28} do
        surface(foundation, "FloorJoint", Vector3.new(0.08, 0.02, 116), origin * CFrame.new(x, 0.265, 0), C.Concrete)
    end
    for z = -48, 48, 16 do
        surface(foundation, "FloorJoint", Vector3.new(94, 0.02, 0.08), origin * CFrame.new(0, 0.265, z), C.Concrete)
    end
    for _, part in base.VisitGate:GetDescendants() do
        if part:IsA("BasePart") and part.Name == "Perimeter" then
            part.Color = C.Concrete
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    local street = Kit.Folder(layout, "ToyCityArchitecture")
    for _, x in {-30, 30} do
        Kit.Tree(street, origin * CFrame.new(x, 0.3, -48), 0.8)
        Kit.Lamp(street, origin * CFrame.new(x * 0.8, 0.3, -48), false)
    end
    local stationNames = {"Generator", "GeneratorSlot_4", "GeneratorSlot_2", "GeneratorSlot_5", "GeneratorSlot_1", "GeneratorSlot_6"}
    for _, name in stationNames do
        local anchor = name == "Generator" and base.Generator or layout.Production[name]
        Kit.Station(anchor)
    end
    for _, item in layout.Production:GetChildren() do
        if item:IsA("BasePart") and item.Name:match("^Chimney") then
            item.Color = C.White
            item.Material = Enum.Material.SmoothPlastic
        elseif item:IsA("BasePart") and item.Name:match("^Light") then
            item.Color = C.Yellow
        end
    end
    Kit.Facility(layout.TechLab, origin * CFrame.new(-15, 0.25, 24), 16, 14, false)
    Kit.Facility(layout.AFKLab, origin * CFrame.new(15, 0.25, 24), 16, 16, true)
    local garage = Kit.Folder(layout.Garage, "ArtDetails")
    for _, part in layout.Garage:GetChildren() do
        if part:IsA("BasePart") and not part.Name:match("Label") then
            part.Color = part.Name:find("Beam") and C.Blue or C.White
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    layout.VehiclePad.Color = C.Concrete
    layout.VehiclePad.Material = Enum.Material.SmoothPlastic
    surface(garage, "GarageBackPanel", Vector3.new(20, 3, 0.5), origin * CFrame.new(-15, 1.9, -2), C.Pale)
    surface(garage, "GarageAwning", Vector3.new(22, 0.5, 4), origin * CFrame.new(-15, 9.2, -17.5), C.Blue)
    for _, x in {-1, 1} do
        surface(garage, "BayMark", Vector3.new(0.3, 0.1, 12), origin * CFrame.new(-15 + x * 6, 0.63, -10), C.White)
    end
    local upgradeArt = Kit.Folder(layout.ProductionUpgrade, "ArtDetails")
    surface(upgradeArt, "ConsoleBack", Vector3.new(4.5, 5, 0.5), origin * CFrame.new(32, 2.9, -12.9), C.White)
    surface(upgradeArt, "ConsoleCap", Vector3.new(5, 0.4, 2.8), origin * CFrame.new(32, 5.5, -13.7), C.Blue)
    for _, part in layout.Gallery:GetChildren() do
        if part:IsA("BasePart") then
            if part.Name:find("Floor") or part.Name:find("Ramp") then
                part.Color = C.White
            elseif part.Name:find("Railing") then
                part.Color = C.Yellow
            elseif part.Name:find("Pillar") then
                part.Color = C.Blue
            elseif part.Name:find("Pedestal") then
                part.Color = part.Name:find("Rim") and C.Blue or C.Concrete
            end
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    base.Display.Color = C.Concrete
    base.Display.Material = Enum.Material.SmoothPlastic
    for _, piece in layout.MainRoute:GetChildren() do
        if piece:IsA("BasePart") then
            piece.Color = piece.Name:find("Chevron") and C.Yellow or C.Blue
            piece.Material = Enum.Material.SmoothPlastic
        end
    end
    base:SetAttribute("VisualStyle", "ToyCity_v04")
    task.wait()
end

-- 대로: 중앙 22stud 판정 폭과 해금 벽은 유지하고 노면·가로수·조명만 입힙니다.
local laneOne = lanes.Lane_1
local laneOneEntry = laneOne.Entry.CFrame
for index = 1, 6 do
    local lane = lanes["Lane_" .. index]
    local transform = lane.Entry.CFrame * laneOneEntry:Inverse()
    local details = Kit.Folder(lane, "ArtDetails")
    lane.Road.Color = C.Road
    lane.Road.Material = Enum.Material.SmoothPlastic
    lane.Entry.Color = C.Blue
    for zone = 1, 4 do
        local ground = lane["Zone" .. zone .. "_Ground"]
        ground.Color = zone == 3 and Color3.fromRGB(209, 224, 235) or C.Pale
        ground.Material = Enum.Material.SmoothPlastic
    end
    for _, side in {-1, 1} do
        surface(details, "RoadCurb", Vector3.new(1, 0.3, 915), transform * CFrame.new(side * 12, 0.3, -742.5), C.White)
        surface(details, "RoadEdge", Vector3.new(0.25, 0.07, 915), transform * CFrame.new(side * 9.5, 0.3, -742.5), C.White)
    end
    for distance = 305, 1190, 24 do
        surface(details, "CenterDash", Vector3.new(0.4, 0.08, 8), transform * CFrame.new(0, 0.3, -distance), C.Yellow)
    end
    for _, distance in {322, 625, 865} do
        for stripe = -3, 3 do
            surface(details, "Crosswalk", Vector3.new(1.6, 0.08, 6), transform * CFrame.new(stripe * 2.6, 0.31, -distance), C.White)
        end
    end
    for _, distance in {360, 470, 680, 780, 940, 1085} do
        local side = distance % 20 == 0 and 1 or -1
        Kit.Lamp(details, transform * CFrame.new(side * 14, 0.3, -distance), false)
        Kit.Tree(details, transform * CFrame.new(-side * 39, 0.3, -distance - 6), 0.9)
    end
    for _, name in {"Gate_Zone2", "Gate_Zone3"} do
        local gate = lane[name]
        gate.Color = C.Glass
        gate.Material = Enum.Material.ForceField
        local frame = gate.CFrame
        for _, side in {-1, 1} do
            surface(details, "ZoneGatePost", Vector3.new(1.8, 10, 2), frame * CFrame.new(side * 13, -8, 0), C.White)
            surface(details, "ZoneGateBand", Vector3.new(1.9, 1.5, 2.1), frame * CFrame.new(side * 13, -5, 0), C.Blue)
        end
        surface(details, "ZoneGateHeader", Vector3.new(28, 1.3, 2), frame * CFrame.new(0, -2.3, 0), C.Blue)
    end
    task.wait()
end

for _, container in {workspace.ProjectMS_City, workspace.ProjectMS_Worlds.World_2.Buildings} do
    for _, model in container:GetChildren() do
        if model:IsA("Model") then
            Kit.City(model)
        end
        task.wait()
    end
end

workspace.Baseplate.Color = Color3.fromRGB(166, 197, 170)
workspace.Baseplate.Material = Enum.Material.SmoothPlastic
for _, texture in workspace.Baseplate:GetChildren() do
    if texture:IsA("Texture") or texture:IsA("Decal") then
        texture.Transparency = 1
    end
end
for _, piece in lanes:GetChildren() do
    if piece:IsA("BasePart") and piece.Name:match("BaseplateExtension") then
        piece.Color = workspace.Baseplate.Color
        piece.Material = Enum.Material.SmoothPlastic
    end
end

-- 푸른 낮빛과 약한 후처리. 낮/밤 ClockTime 전환 코드는 그대로 동작합니다.
local lighting = game:GetService("Lighting")
lighting.Brightness = 2.5
lighting.Ambient = Color3.fromRGB(105, 122, 153)
lighting.OutdoorAmbient = Color3.fromRGB(144, 158, 184)
lighting.ExposureCompensation = 0.05
lighting.EnvironmentDiffuseScale = 0.7
lighting.EnvironmentSpecularScale = 0.35
lighting.ShadowSoftness = 0.35
local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
if atmosphere then
    atmosphere.Density = 0.18
    atmosphere.Offset = 0.1
    atmosphere.Color = Color3.fromRGB(192, 216, 250)
    atmosphere.Decay = Color3.fromRGB(151, 181, 222)
    atmosphere.Glare = 0.05
    atmosphere.Haze = 0.6
end
local bloom = lighting:FindFirstChildOfClass("BloomEffect")
if bloom then
    bloom.Intensity = 0.08
    bloom.Size = 16
    bloom.Threshold = 1.5
end
local depth = lighting:FindFirstChildOfClass("DepthOfFieldEffect")
if depth then
    depth.Enabled = false
end
workspace:SetAttribute("VisualStyle", "ToyCity_v04")
return "Toy City v04 map visuals applied"
