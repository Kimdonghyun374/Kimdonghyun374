-- ApplyWorld 이후 Edit에서 실행합니다. 판정/이름/위치는 유지합니다.
local Kit = require(game.ReplicatedStorage.PetMissiles.ArtKit)
for _, root in {workspace.ProjectMS_City, workspace.ProjectMS_Bases, workspace.ProjectMS_Lanes} do
    for _, item in root:GetDescendants() do
        if item:IsA("BillboardGui") then
            item.MaxDistance = 85
            local label = item:FindFirstChildWhichIsA("TextLabel", true)
            if label then
                label.BackgroundColor3 = Kit.Colors.White
                label.BackgroundTransparency = 0.12
                label.TextColor3 = Kit.Colors.DeepBlue
            end
        end
    end
end
local tool = game.StarterPack["장난 권총"]
tool.Handle.Color = Kit.Colors.DeepBlue
tool.Barrel.Color = Kit.Colors.White
local details = Kit.Folder(tool, "ArtDetails")
local accent = Kit.Part(details, "BlueSlide", Vector3.new(0.44, 0.12, 0.9),
    tool.Handle.CFrame * CFrame.new(0, 0.52, -0.45), Kit.Colors.Blue)
local muzzle = Kit.Part(details, "ToyMuzzleRing", Vector3.new(0.46, 0.4, 0.13),
    tool.Handle.CFrame * CFrame.new(0, 0.3, -1.07), Kit.Colors.Yellow)
for _, piece in {accent, muzzle} do
    piece.Anchored = false
    piece.Massless = true
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = tool.Handle
    weld.Part1 = piece
    weld.Parent = piece
end
for _, piece in workspace.ProjectMS_Garage:GetDescendants() do
    if piece:IsA("BasePart") then
        piece.Material = Enum.Material.SmoothPlastic
        if piece.Name:find("Wheel") then
            piece.Color = Kit.Colors.Dark
        elseif piece.Name:find("Rim") then
            piece.Color = Kit.Colors.Yellow
        elseif piece.Name == "Hood" or piece.Name == "Chassis" then
            piece.Color = Kit.Colors.Blue
        elseif piece.Name == "Pad" then
            piece.Color = Kit.Colors.Pale
        else
            piece.Color = Kit.Colors.White
        end
    end
end
local marker = workspace.ProjectMS_Lanes.RaidArena.RaidBossMarker
marker.Shape = Enum.PartType.Cylinder
marker.Size = Vector3.new(0.25, 16, 16)
marker.CFrame = CFrame.new(0, 0.4, 0) * CFrame.Angles(0, 0, math.pi / 2)
marker.Color = Kit.Colors.Blue
