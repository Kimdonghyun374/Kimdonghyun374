local RunService = game:GetService("RunService")
local network = game.ReplicatedStorage.PetMissiles
if not RunService:IsStudio() or not require(network.BaseConfig).StudioMockData then
    return
end
local Base = require(game.ServerScriptService.PetMissiles.BaseService)
local Combat = require(game.ServerScriptService.PetMissiles.Service)
local Progress = require(game.ServerScriptService.PetMissiles.ProgressionService)
local Raid = require(game.ServerScriptService.PetMissiles.RaidService)
local Vehicle = require(game.ServerScriptService.PetMissiles.VehicleService)
local Rules = require(game.ServerScriptService.PetMissiles.ProgressionRules)
local WorldConfig = require(network.WorldConfig)
local remote = Instance.new("RemoteFunction")
remote.Name = "CodexArtVerification"
remote.Parent = game.ReplicatedStorage

remote.OnServerInvoke = function(player, action)
    local began = os.clock()
    while not Base.GetData(player) and os.clock() - began < 20 do
        task.wait(0.1)
    end
    local data = assert(Base.GetData(player))
    local character = assert(player.Character)
    local base = workspace.ProjectMS_Bases.Base_1
    if action == "craft" then
        local cycle = Rules.Cycle(workspace:GetServerTimeNow(), WorldConfig)
        Progress.SetStudioTime(cycle.id * (WorldConfig.DayDuration + WorldConfig.NightDuration) + 10)
        character:PivotTo(base.ClaimPad.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)
        Base.Claim(player, 1)
        task.wait(0.8)
        assert(Base.GetPlotId(player) == 1)
        Base.GrantResources(player, 3000, 20)
        character:PivotTo(base.Generator.CFrame + Vector3.new(0, 3, -5))
        task.wait(0.2)
        Base.Roll(player, 1)
        task.wait(6)
        assert(#data.Inventory > 0, "제작 결과 없음")
        local shown = 0
        for _, part in base.Generator.ArtDetails:GetChildren() do
            if part:IsA("BasePart") and part.Transparency < 0.1 then
                shown += 1
            end
        end
        assert(shown > 0, "열린 제작대 장식이 보이지 않음")
        local locked = base.Layout.Production.GeneratorSlot_4
        for _, part in locked.ArtDetails:GetChildren() do
            if part:IsA("BasePart") then
                assert(part.Transparency >= 0.6, "잠긴 제작대 장식 불투명")
            end
        end
        return {crafted = #data.Inventory, openStationArtParts = shown, lockedStationGhost = true}
    elseif action == "city" then
        local city
        for _, candidate in workspace.ProjectMS_PersonalCities:GetChildren() do
            if candidate:GetAttribute("OwnerUserId") == player.UserId then
                city = candidate
            end
        end
        assert(city and #city:GetChildren() == 8)
        local target
        for _, model in city:GetChildren() do
            if model:GetAttribute("BuildingId") == "주택" then
                target = model
            end
        end
        assert(target and target.ArtDetails and target:GetAttribute("VisualStyle") == "ToyCity_v04")
        character:PivotTo(CFrame.new(target.PrimaryPart.Position + Vector3.new(0, 1, 55)))
        local before = Combat.GetDiagnostics(player).launched
        Combat.RequestFocus(player, {target = target})
        task.wait(4)
        assert(Combat.GetDiagnostics(player).launched > before)
        assert(target.Humanoid.Health <= 0, "실제 미사일 파괴 실패")
        return {buildings = 8, styled = true, actualMissileDestroyedHouse = true}
    elseif action == "vehicle" then
        character:PivotTo(base.Layout.VehiclePad.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.3)
        assert(Vehicle.Upgrade(player, 0))
        assert(Vehicle.Summon(player))
        task.wait(0.4)
        local mount = workspace:FindFirstChild("Mount_" .. player.UserId, true)
        assert(mount and mount.ArtDetails, "탈것 장식 누락")
        local count = 0
        for _, part in mount.ArtDetails:GetChildren() do
            if part:IsA("BasePart") then
                assert(not part.Anchored and part.Massless, "장식이 이동을 고정함")
                assert(part:FindFirstChildOfClass("WeldConstraint"))
                count += 1
            end
        end
        Vehicle.Exit(player)
        return {vehicleArtParts = count, welded = true, unanchored = true}
    elseif action == "raid" then
        character:PivotTo(CFrame.new(0, 4, 65))
        assert(Raid.StartWarningNow(1))
        task.wait(5)
        local snapshot = Raid.GetState()
        local boss = assert(snapshot.boss)
        assert(boss.ArtDetails and boss.Hull.Color == require(network.ArtKit).Colors.White)
        assert(workspace.ProjectMS_Lanes.RaidArena:FindFirstChild("RaidBossPreview") == nil)
        return {phase = snapshot.phase, bossDecorated = true, artPieces = #boss.ArtDetails:GetChildren(), health = snapshot.health}
    end
end
