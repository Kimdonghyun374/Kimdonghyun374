-- 자산 Place 전용 비행/폭발 미리보기. 게임 Place에서는 실행하지 않습니다.
if game.PlaceId ~= 85812975859267 then
    return
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VFX = require(game.ReplicatedStorage:WaitForChild("MissileVFX"))
local gui = script.Parent
gui.Enabled = true
local panel = gui.Panel
local models = {}
for _, model in ipairs(workspace:GetChildren()) do
    if model:IsA("Model") and model:GetAttribute("VFXEditPreview") then
        table.insert(models, model)
        for _, effect in ipairs(model:GetDescendants()) do
            if effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Light") then
                effect.Enabled = false
            end
        end
    end
end
table.sort(models, function(a, b)
    return a.Name < b.Name
end)
local folder = Instance.new("Folder")
folder.Name = "MissileVFXPreviewRuntime"
folder.Parent = workspace
VFX.Container = folder
local index = #models
local token = 0
local missile
local autoplay = true
local busy = false
local camera = workspace.CurrentCamera
local function setCamera()
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = CFrame.lookAt(Vector3.new(30, 22, 34), Vector3.new(0, 7, -6))
end
local function show()
    token += 1
    busy = false
    if missile then
        missile:Destroy()
    end
    missile = models[index]:Clone()
    missile.Name = "PreviewMissile"
    for _, part in ipairs(missile:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
        end
    end
    missile.Parent = folder
    missile:PivotTo(CFrame.new(0, 7, 12))
    VFX.attach(missile)
    panel.Current.Text = index .. "/" .. #models .. "  " .. models[index].Name
        .. "\n" .. models[index]:GetAttribute("Rarity")
    gui:SetAttribute("SelectedIndex", index)
end
local function explode(position)
    VFX.explode(position, models[index]:GetAttribute("Rarity"), models[index]:GetAttribute("Scale"))
    gui:SetAttribute("ExplosionsPlayed", (gui:GetAttribute("ExplosionsPlayed") or 0) + 1)
end
local function fly()
    if busy then
        return
    end
    show()
    busy = true
    local currentToken = token
    gui:SetAttribute("FlightsStarted", (gui:GetAttribute("FlightsStarted") or 0) + 1)
    local began = os.clock()
    while token == currentToken and os.clock() - began < 1.5 do
        local alpha = math.clamp((os.clock() - began) / 1.5, 0, 1)
        missile:PivotTo(CFrame.new(0, 7 + math.sin(alpha * math.pi) * 3, 12 - alpha * 40))
        RunService.RenderStepped:Wait()
    end
    if token ~= currentToken then
        return
    end
    explode(Vector3.new(0, 7, -28))
    missile:Destroy()
    missile = nil
    task.wait(2.1)
    if token == currentToken then
        show()
    end
end
panel.Previous.Activated:Connect(function()
    index = (index - 2) % #models + 1
    show()
end)
panel.Next.Activated:Connect(function()
    index = index % #models + 1
    show()
end)
panel.Fly.Activated:Connect(function()
    task.spawn(fly)
end)
panel.Explosion.Activated:Connect(function()
    explode(Vector3.new(0, 7, -8))
end)
panel.Auto.Activated:Connect(function()
    autoplay = not autoplay
    panel.Auto.Text = autoplay and "자동 재생: 켜짐" or "자동 재생: 꺼짐"
end)
panel.View.Activated:Connect(setCamera)
setCamera()
show()
task.spawn(function()
    while gui.Parent do
        if autoplay and not busy then
            fly()
        end
        task.wait(1)
    end
end)
