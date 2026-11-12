local RunService = game:GetService("RunService")
if not RunService:IsStudio() or not require(game.ReplicatedStorage.PetMissiles.BaseConfig).StudioMockData then
    return
end
local Base = require(game.ServerScriptService.PetMissiles.BaseService)
local Progress = require(game.ServerScriptService.PetMissiles.ProgressionService)
local Social = require(game.ServerScriptService.PetMissiles.SocialService)
local Combat = require(game.ServerScriptService.PetMissiles.Service)
local Config = require(game.ReplicatedStorage.PetMissiles.WorldConfig)
local Rules = require(game.ServerScriptService.PetMissiles.ProgressionRules)
local remote = Instance.new("RemoteFunction")
remote.Name = "CodexSocialZoneTest"
remote.Parent = game.ReplicatedStorage
local function waitData(player)
    local began = os.clock()
    while not Base.GetData(player) and os.clock() - began < 20 do
        task.wait(0.1)
    end
    return assert(Base.GetData(player))
end
local function cityFor(player)
    for _, folder in ipairs(workspace.ProjectMS_PersonalCities:GetChildren()) do
        if folder:GetAttribute("OwnerUserId") == player.UserId then
            return folder
        end
    end
end
remote.OnServerInvoke = function(player, action)
    local data = waitData(player)
    local char = player.Character
    if action == "prepare" then
        local now = workspace:GetServerTimeNow()
        local cycle = Rules.Cycle(now, Config)
        Progress.SetStudioTime(cycle.id * (Config.DayDuration + Config.NightDuration) + 10)
        char:PivotTo(workspace.ProjectMS_Bases.Base_1.ClaimPad.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)
        Base.Claim(player, 1)
        task.wait(0.7)
        assert(Base.GetPlotId(player) == 1)
        Base.GrantResources(player, 5000, 0)
        local city = cityFor(player)
        assert(#city:GetChildren() == 8)
        return {spawned = #city:GetChildren(), base = Base.GetPlotId(player), research = data.ResearchData}
    elseif action == "zones" then
        local city = cityFor(player)
        local first
        for _, model in ipairs(city:GetChildren()) do
            if model:GetAttribute("BuildingId") == "주택" then
                first = model
            end
        end
        data.Inventory = {{id=1,key="asset_spark"},{id=2,key="asset_spark"},{id=3,key="asset_spark"}}
        data.Equipped = {1,2,3}
        data.NextId = 4
        local target = assert(first)
        local root = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart")
        char:PivotTo(CFrame.new(root.Position + Vector3.new(0, 0, 35)))
        task.wait(0.4)
        local launched = Combat.GetDiagnostics(player).launched
        Combat.RequestFocus(player, {target=target})
        task.wait(3)
        assert(target.Humanoid.Health <= 0, "실제 미사일 첫 표적 파괴 실패")
        assert(Combat.GetDiagnostics(player).launched > launched)
        for _, model in ipairs(city:GetChildren()) do
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid:TakeDamage(humanoid.Health)
            end
        end
        task.wait(0.5)
        assert(data.Progression.ZoneClears["1-1"] == 1)
        assert(data.ResearchData >= 4)
        assert(not Rules.CanUnlockZone(data.Progression,1,Config.Zones[2]))
        assert(Progress.UnlockZone(player,1,2))
        assert(#city:GetChildren() == 14)
        for _, model in ipairs(city:GetChildren()) do
            if model:GetAttribute("ZoneId") == 2 then
                model.Humanoid:TakeDamage(model.Humanoid.Health)
            end
        end
        task.wait(0.5)
        assert(data.Progression.ZoneClears["1-2"] == 1)
        assert(Progress.UnlockZone(player,1,3))
        assert(#city:GetChildren() == 22)
        for _, model in ipairs(city:GetChildren()) do
            if model:GetAttribute("ZoneId") == 3 then
                model.Humanoid:TakeDamage(model.Humanoid.Health)
            end
        end
        task.wait(0.5)
        assert(data.Progression.ZoneClears["1-3"] == 1)
        assert(data.Progression.FullWorldClears["1"] == 1)
        assert(data.ResearchData >= 20)
        return {zone1=8,zone2=6,zone3=8,research=data.ResearchData,completed=true,actualFirstTarget=true}
    elseif action == "lock" then
        local base = workspace.ProjectMS_Bases.Base_1
        char:PivotTo(base.VisitGate.Control.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.2)
        assert(Social.SetLocked(player, base, true))
        assert(Social.InLockedArea(base.Floor.Position, -999) == base)
        assert(not Social.InLockedArea(base.Floor.Position, player.UserId))
        assert(not Social.SetLocked(player, workspace.ProjectMS_Bases.Base_2, true))
        local other = workspace.ProjectMS_Bases.Base_2
        other:SetAttribute("OwnerUserId", -999)
        task.wait(0.2)
        other:SetAttribute("VisitLocked", true)
        char:PivotTo(other.Floor.CFrame + Vector3.new(0, 4, 0))
        task.wait(0.5)
        assert(math.abs(other.Floor.CFrame:PointToObjectSpace(char:GetPivot().Position).Z) > 60)
        other:SetAttribute("OwnerUserId", 0)
        other:SetAttribute("VisitLocked", false)
        char:PivotTo(base.VisitGate.Control.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.2)
        assert(Social.SetLocked(player, base, false))
        return {ownerPass=true,visitorEjected=true,otherOwnerRejected=true}
    elseif action == "prank" then
        char.Archivable = true
        local dummy = char:Clone()
        dummy.Name = "CodexPrankDummy"
        dummy:SetAttribute("PrankTestTarget", true)
        for _, object in ipairs(dummy:GetDescendants()) do
            if object:IsA("LuaSourceContainer") or object:IsA("ForceField") or object:IsA("Tool") then
                object:Destroy()
            end
        end
        dummy.Parent = workspace
        dummy:PivotTo(CFrame.new(0, 5, -88))
        char:PivotTo(CFrame.new(0, 5, -66))
        task.wait(0.7)
        local before = dummy.Humanoid.Health
        local target = dummy:FindFirstChild("UpperTorso") or dummy:FindFirstChild("Torso") or dummy.HumanoidRootPart
        local ok, message = Social.TryShoot(player, target.Position)
        assert(ok, message)
        assert(dummy:GetAttribute("PrankRagdoll"), "랙돌 미발동")
        assert(not Social.TryShoot(player, target.Position), "연사 제한 실패")
        assert(not Social.Ragdoll(dummy, Vector3.zAxis), "연속 피격 방지 실패")
        task.wait(1.7)
        assert(not dummy:GetAttribute("PrankRagdoll"))
        assert(dummy.Humanoid.Health == before and not dummy.Humanoid.PlatformStand)
        local sockets = 0
        for _, object in ipairs(dummy:GetDescendants()) do
            if object:IsA("BallSocketConstraint") then sockets += 1 end
        end
        assert(sockets == 0)
        dummy:Destroy()
        return {ragdoll=true,recovered=true,healthUnchanged=true,cooldown=true,immunity=true,temporaryJointsRemoved=true}
    end
end
