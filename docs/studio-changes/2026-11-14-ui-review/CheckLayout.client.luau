local g=game.Players.LocalPlayer.PlayerGui
local layout=require(game.ReplicatedStorage.PetMissiles.HudLayout)
local controls={g.SalvageHUD.Resources,g.DayNightHUD.Phase,g.RaidHUD.RaidPanel,g.MissileBaseHUD.OpenInventory,g.ScoutBuggyHUD.SummonBuggy,g.PetMissileHUD.Panel,g.PrankPistolHUD.PistolEquip,g.PrankPistolHUD.PistolFire}
local jump=g:FindFirstChild("TouchGui") and g.TouchGui:FindFirstChild("JumpButton",true)
if jump then table.insert(controls,jump) end
local issues={}
local rects={}
for i,a in controls do
 local screen=a:FindFirstAncestorWhichIsA("ScreenGui")
 local point=a.AbsolutePosition-screen.AbsolutePosition
 if a.Visible then
 table.insert(rects,{name=a.Name,x=point.X,y=point.Y,w=a.AbsoluteSize.X,h=a.AbsoluteSize.Y})
 if point.X<0 or point.Y<0 or point.X+a.AbsoluteSize.X>screen.AbsoluteSize.X+1 or point.Y+a.AbsoluteSize.Y>screen.AbsoluteSize.Y+1 then table.insert(issues,a.Name.." outside safe GUI") end
 for j=i+1,#controls do
 local b=controls[j]
 local ap,as=a.AbsolutePosition,a.AbsoluteSize
 local bp,bs=b.AbsolutePosition,b.AbsoluteSize
 if b.Visible and ap.X<bp.X+bs.X and ap.X+as.X>bp.X and ap.Y<bp.Y+bs.Y and ap.Y+as.Y>bp.Y then table.insert(issues,a.Name.." overlaps "..b.Name) end
 end end
end
return game.HttpService:JSONEncode({viewport=tostring(workspace.CurrentCamera.ViewportSize),touch=layout.IsTouch(),scale=layout.GetScale(),issues=issues,rects=rects,inventoryListHeight=g.MissileBaseHUD.Inventory.Items.AbsoluteSize.Y,playerGuiChildren=#g:GetChildren()})
