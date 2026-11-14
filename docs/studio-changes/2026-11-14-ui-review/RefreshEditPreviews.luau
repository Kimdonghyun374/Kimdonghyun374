local network = game.ReplicatedStorage.PetMissiles
local stale = network:FindFirstChild("CodexUIPreviewRefresh")
if stale then
    stale:Destroy()
end
local temporary = Instance.new("Folder")
temporary.Name = "CodexUIPreviewRefresh"
temporary.Parent = network
local layoutModule = network.HudLayout:Clone()
layoutModule.Name = "HudLayout"
layoutModule.Parent = temporary
local appearanceModule = network.UIAppearance:Clone()
appearanceModule.Source = appearanceModule.Source:gsub("require%(ReplicatedStorage.PetMissiles.HudLayout%)", "require(script.Parent.HudLayout)")
appearanceModule.Parent = temporary
local appearance = require(appearanceModule)
local layout = require(layoutModule)
local root = game.StarterGui
appearance.Apply(root)
local slots = { OpenInventory = "MenuInventory", SummonBuggy = "MenuVehicle", PistolEquip = "PistolEquip", PistolFire = "PistolFire" }
local checks = {}
for _, gui in root:GetChildren() do
    if gui:IsA("ScreenGui") and gui.Name:match("^UIPreview_") then
        gui:SetAttribute("EditPreviewOnly", true)
        for _, child in gui:GetChildren() do
            if child:IsA("GuiObject") then
                local scale = child:FindFirstChild("HudScale") or Instance.new("UIScale")
                scale.Name = "HudScale"
                scale.Scale = layout.GetScaleFor(child)
                scale.Parent = child
                local slot = slots[child.Name]
                if gui.Name == "UIPreview_PetMissileHUD" and child.Name == "Panel" then
                    slot = "Focus"
                end
                if slot then
                    layout.Place(child, slot)
                end
            end
        end
        table.insert(checks, { name = gui.Name, removeInPlay = gui:FindFirstChild("RemoveInPlay") ~= nil })
    end
end
local focusPanel = root.UIPreview_PetMissileHUD.Panel
focusPanel.Gauge.ZIndex = 2
local function gaugeSkin(parent, sprite, slice, depth)
    local skin = parent:FindFirstChild("Skin") or Instance.new("ImageLabel")
    skin.Name = "Skin"
    skin:SetAttribute("NoTheme", true)
    skin.BackgroundTransparency = 1
    skin.Size = UDim2.fromScale(1, 1)
    skin.ScaleType = Enum.ScaleType.Slice
    skin.SliceCenter = slice
    skin.SliceScale = 0.12
    skin.ZIndex = depth
    require(network.UIImages).Apply(skin, sprite)
    skin.Parent = parent
    parent.BackgroundTransparency = 1
end
gaugeSkin(focusPanel.Gauge, "gauge_track", Rect.new(40,25,195,58),2)
focusPanel.Gauge.Fill.ZIndex = 4
gaugeSkin(focusPanel.Gauge.Fill, "gauge_gold", Rect.new(32,20,191,44),4)
root.UIPreview_PrankPistolHUD.PistolFire.Visible = false
root.UIPreview_DayNightHUD.Phase.Text = "낮  2:34"
layout.Refresh()
local popup = root.UIPreview_Popup_FocusHint
local oldPanel = popup:FindFirstChild("Panel")
if oldPanel then
    oldPanel:Destroy()
end
local hintPanel = focusPanel:Clone()
hintPanel.AnchorPoint = Vector2.new(0.5, 1)
hintPanel.Position = UDim2.new(0.5, 0, 1, -24)
local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint:SetAttribute("NoTheme", true)
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 0, -8)
hint.Size = UDim2.fromOffset(260, 26)
hint.Text = "집중 게이지 충전 중"
hint.TextSize = 13
hint.Font = Enum.Font.GothamBold
hint.TextColor3 = Color3.fromRGB(16, 39, 94)
hint.BackgroundColor3 = Color3.fromRGB(250, 252, 255)
hint.Parent = hintPanel
hintPanel.Parent = popup
temporary:Destroy()
return game.HttpService:JSONEncode(checks)
