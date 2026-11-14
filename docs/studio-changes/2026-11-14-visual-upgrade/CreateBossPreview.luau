-- Edit 전용 보스 외형 사본. 실제 레이드에서는 RaidService.Start가 제거합니다.
local network=game.ReplicatedStorage.PetMissiles
local RaidConfig=require(network.RaidConfig)
local function part(parent, name, shape, size, cframe, color, material, transparency)
    local piece = Instance.new("Part")
    piece.Name = name
    piece.Shape = shape or Enum.PartType.Block
    piece.Size = size
    piece.CFrame = cframe
    piece.Color = color
    piece.Material = material or Enum.Material.Metal
    piece.Transparency = transparency or 0
    piece.Anchored = true
    piece.CanCollide = false
    piece.CanTouch = false
    piece.CanQuery = true -- 미사일 충돌 판정용
    piece.CastShadow = false
    piece.Parent = parent
    return piece
end

local function buildBoss(center)
    local model = Instance.new("Model")
    model.Name = "RaidBoss"
    local origin = CFrame.new(center)
    local core = part(model, "Core", Enum.PartType.Ball, Vector3.one * 12, origin, Color3.fromRGB(235, 40, 50), Enum.Material.Neon)
    part(model, "Hull", Enum.PartType.Cylinder, Vector3.new(5, 34, 34), origin * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(55, 60, 72))
    part(model, "HullRim", Enum.PartType.Cylinder, Vector3.new(1.2, 36, 36), origin * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 120, 40), Enum.Material.Neon)
    part(model, "Dome", Enum.PartType.Ball, Vector3.new(18, 18, 18), origin * CFrame.new(0, 4, 0), Color3.fromRGB(80, 88, 104), Enum.Material.Metal, 0.35)
    -- 아래 미사일 포대 4개(주황 끝)
    for index = 1, 4 do
        local angle = math.rad(45 + index * 90)
        local offset = Vector3.new(math.cos(angle) * 9, -5, math.sin(angle) * 9)
        part(model, "Pod", Enum.PartType.Cylinder, Vector3.new(6, 2.4, 2.4), origin * CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(45, 48, 56))
        part(model, "PodTip", Enum.PartType.Ball, Vector3.one * 2.2, origin * CFrame.new(offset + Vector3.new(0, -3, 0)), Color3.fromRGB(255, 150, 40), Enum.Material.Neon)
    end
    -- 회전 장갑판(클라이언트가 돌림)
    local ring = Instance.new("Model")
    ring.Name = "ArmorRing"
    for index = 1, 6 do
        local angle = math.rad(index * 60)
        local offset = Vector3.new(math.cos(angle) * 20, 0, math.sin(angle) * 20)
        part(ring, "Plate", Enum.PartType.Block, Vector3.new(2, 8, 9), CFrame.lookAt(center + offset, center), Color3.fromRGB(150, 40, 45), Enum.Material.DiamondPlate)
    end
    ring.Parent = model
    model.PrimaryPart = core
    -- 체력(전투 시스템은 Humanoid 체력을 깎습니다)
    local humanoid = Instance.new("Humanoid")
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    humanoid.RequiresNeck = false
    humanoid.Parent = model
    -- 보조 이름표
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BossTag"
    billboard.Size = UDim2.fromOffset(260, 40)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 16, 0)
    billboard.MaxDistance = 400
    billboard.AlwaysOnTop = true
    billboard.Parent = core
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(40, 10, 14)
    label.BackgroundTransparency = 0.2
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 120, 110)
    label.Text = RaidConfig.BossName
    label.Parent = billboard
    model:SetAttribute("RaidBoss", true)
    require(network.ArtKit).Boss(model)
    return model, humanoid
end


local arena=workspace.ProjectMS_Lanes.RaidArena
local old=arena:FindFirstChild("RaidBossPreview")
if old then
    old:Destroy()
end
local model=buildBoss(Vector3.new(0,26.15,0))
model.Name="RaidBossPreview"
model:SetAttribute("EditPreviewOnly",true)
model.Parent=arena
