assert(not game.StarterPack:FindFirstChild("장난 권총"), "이미 설치되었습니다")

local function write(parent, name, className, source)
    assert(not parent:FindFirstChild(name), name .. " 이미 존재")
    local object = Instance.new(className)
    object.Name = name
    object.Source = source
    object.Parent = parent
    return object
end
local shared = game.ReplicatedStorage.PetMissiles
local remotes = Instance.new("Folder")
remotes.Name = "SocialNetwork"
remotes.Parent = shared
for _, name in ipairs({"Shoot", "Trace", "Notice"}) do
    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = remotes
end
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
for id = 1, 6 do
    local base = workspace.ProjectMS_Bases["Base_" .. id]
    local origin = base.Floor.CFrame * CFrame.new(0, -0.25, 0)
    local gate = Instance.new("Model")
    gate.Name = "VisitGate"
    gate.Parent = base
    for _, x in ipairs({-47.5, 47.5}) do
        part(gate, "Perimeter", Vector3.new(0.5, 5, 120), origin * CFrame.new(x, 3, 0), Color3.fromRGB(83, 103, 125), true)
    end
    for _, z in ipairs({-59.5, 59.5}) do
        for _, x in ipairs({-28, 28}) do
            part(gate, "Perimeter", Vector3.new(40, 5, 0.5), origin * CFrame.new(x, 3, z), Color3.fromRGB(83, 103, 125), true)
        end
    end
    local barrier = part(gate, "Barrier", Vector3.new(16, 7, 0.5), origin * CFrame.new(0, 4, -59.5), Color3.fromRGB(245, 120, 60), false)
    barrier.Material = Enum.Material.ForceField
    barrier.Transparency = 1
    barrier.CanQuery = false
    local rear = part(gate, "LaneBarrier", Vector3.new(16, 7, 0.5), origin * CFrame.new(0, 4, 59.5), Color3.fromRGB(245, 120, 60), false)
    rear.Material = Enum.Material.ForceField
    rear.Transparency = 1
    rear.CanQuery = false
    local control = part(gate, "Control", Vector3.new(1.7, 3, 1.5), origin * CFrame.new(10, 2, -55), Color3.fromRGB(80, 210, 150), true)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ToggleVisitLock"
    prompt.ActionText = "방문 잠그기"
    prompt.ObjectText = "내 기지·진입로"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = 7
    prompt.RequiresLineOfSight = false
    prompt.Style = Enum.ProximityPromptStyle.Custom
    prompt.Parent = control
    local sign = Instance.new("BillboardGui")
    sign.Name = "VisitSign"
    sign.Size = UDim2.fromOffset(210, 40)
    sign.StudsOffset = Vector3.new(0, 3, 0)
    sign.MaxDistance = 65
    sign.Parent = control
    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(23, 44, 65)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.Text = "방문 허용"
    label.Parent = sign
    task.wait()
end
local tool = Instance.new("Tool")
tool.Name = "장난 권총"
tool.CanBeDropped = false
tool:SetAttribute("PrankPistol", true)
local handle = part(tool, "Handle", Vector3.new(0.32, 0.9, 0.45), CFrame.new(), Color3.fromRGB(45, 62, 88), false)
handle.Anchored = false
handle.Massless = true
local barrel = part(tool, "Barrel", Vector3.new(0.42, 0.38, 1.2), CFrame.new(0, 0.3, -0.45), Color3.fromRGB(245, 178, 40), false)
barrel.Anchored = false
barrel.Massless = true
local weld = Instance.new("WeldConstraint")
weld.Part0 = handle
weld.Part1 = barrel
weld.Parent = handle
local muzzle = Instance.new("Attachment")
muzzle.Name = "Muzzle"
muzzle.Position = Vector3.new(0, 0.3, -1.1)
muzzle.Parent = handle
tool.Parent = game.StarterPack
local gui = Instance.new("ScreenGui")
gui.Name = "PrankPistolHUD"
gui.ResetOnSpawn = false
gui.Enabled = false
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -18, 1, -90)
panel.Size = UDim2.new(0.42, 0, 0, 78)
panel.BackgroundColor3 = Color3.fromRGB(23, 44, 65)
panel.Parent = gui
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(320, 78)
limit.Parent = panel
Instance.new("UICorner", panel)
local equip = Instance.new("TextButton")
equip.Name = "Equip"
equip.Size = UDim2.new(1, -12, 0, 32)
equip.Position = UDim2.fromOffset(6, 6)
equip.BackgroundColor3 = Color3.fromRGB(235, 164, 35)
equip.Font = Enum.Font.GothamBold
equip.TextSize = 15
equip.TextColor3 = Color3.fromRGB(30, 35, 50)
equip.Text = "권총 해제 [G]"
equip.Parent = panel
Instance.new("UICorner", equip)
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Position = UDim2.fromOffset(6, 41)
status.Size = UDim2.new(1, -12, 0, 32)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.TextSize = 12
status.TextWrapped = true
status.Font = Enum.Font.Gotham
status.Text = "클릭/터치 발사 · 건물 선택 / 플레이어 장난"
status.Parent = panel
gui.Parent = game.StarterGui
local preview = gui:Clone()
preview.Name = "UIPreview_PrankPistolHUD"
preview.Enabled = true
preview:SetAttribute("EditPreviewOnly", true)
local remove = Instance.new("LocalScript")
remove.Name = "RemoveInPlay"
remove.Source = "script.Parent:Destroy()"
remove.Parent = preview
preview.Parent = game.StarterGui
return "방문잠금·기본권총·발광탄도·랙돌·건설힌트 설치"
