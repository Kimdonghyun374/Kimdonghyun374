local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local network = game.ReplicatedStorage:WaitForChild("PetMissiles")
local Config = require(network.SocialConfig)
local BaseService = require(script.Parent.BaseService)
local remotes = network.SocialNetwork
local Service = {}
local lastShot, lastOwner = {}, {}
local started = false

local function finiteVector(value)
    return typeof(value) == "Vector3" and value.X == value.X and value.Y == value.Y
        and value.Z == value.Z and value.Magnitude < 1000000
end

local function ownedBase(player)
    local id = BaseService.GetPlotId(player)
    return id ~= 0 and workspace.ProjectMS_Bases:FindFirstChild("Base_" .. id) or nil
end

local function inLockedArea(position, ignoredOwner)
    for _, base in ipairs(workspace.ProjectMS_Bases:GetChildren()) do
        local owner = base:GetAttribute("OwnerUserId")
        if owner and owner ~= 0 and owner ~= ignoredOwner and base:GetAttribute("VisitLocked") then
            local point = base.Floor.CFrame:PointToObjectSpace(position)
            local inBase = math.abs(point.X) < base.Floor.Size.X / 2
                and math.abs(point.Z) < base.Floor.Size.Z / 2
            local inLane = math.abs(point.X) < 65 and point.Z >= base.Floor.Size.Z / 2 and point.Z < 1120
            if inBase or inLane then
                return base
            end
        end
    end
    return nil
end
Service.InLockedArea = inLockedArea

function Service.SetLocked(player, base, locked)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if base ~= ownedBase(player) or not root then
        return false, "내 기지 입구에서만 바꿀 수 있습니다"
    end
    local control = base.VisitGate.Control
    if (root.Position - control.Position).Magnitude > 13 then
        return false, "출입 단말 가까이 이동하세요"
    end
    base:SetAttribute("VisitLocked", locked == true)
    return true
end

local function restoreRagdoll(character, record)
    if not character.Parent then
        return
    end
    for _, object in ipairs(record.created) do
        object:Destroy()
    end
    for motor, enabled in pairs(record.motors) do
        if motor.Parent then
            motor.Enabled = enabled
        end
    end
    for part, collide in pairs(record.collisions) do
        if part.Parent then
            part.CanCollide = collide
        end
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 then
        humanoid.RequiresNeck = record.requiresNeck
        humanoid.AutoRotate = record.autoRotate
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if root then
        root.AssemblyAngularVelocity = Vector3.zero
        local velocity = root.AssemblyLinearVelocity
        if velocity.Magnitude > 20 then
            root.AssemblyLinearVelocity = velocity.Unit * 20
        end
        pcall(function()
            root:SetNetworkOwnershipAuto()
        end)
    end
    character:SetAttribute("PrankRagdoll", false)
end

function Service.Ragdoll(character, direction)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    local now = workspace:GetServerTimeNow()
    if not humanoid or humanoid.Health <= 0 or not root or root.Anchored
        or character:GetAttribute("PrankRagdoll")
        or now < (character:GetAttribute("PrankProtectedUntil") or 0)
        or character:FindFirstChildOfClass("ForceField") then
        return false, "피격 보호 중"
    end
    local record = {
        created = {}, motors = {}, collisions = {},
        requiresNeck = humanoid.RequiresNeck, autoRotate = humanoid.AutoRotate,
    }
    character:SetAttribute("PrankRagdoll", true)
    character:SetAttribute("PrankProtectedUntil", now + Config.HitProtection)
    humanoid.RequiresNeck = false
    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("Motor6D") and object.Part0 and object.Part1
            and object.Part0 ~= root and object.Part1 ~= root and object.Enabled then
            local a = Instance.new("Attachment")
            a.CFrame = object.C0
            a.Parent = object.Part0
            local b = Instance.new("Attachment")
            b.CFrame = object.C1
            b.Parent = object.Part1
            local socket = Instance.new("BallSocketConstraint")
            socket.Attachment0 = a
            socket.Attachment1 = b
            socket.LimitsEnabled = true
            socket.UpperAngle = 45
            socket.TwistLimitsEnabled = true
            socket.TwistLowerAngle = -25
            socket.TwistUpperAngle = 25
            socket.Parent = object.Part0
            local noCollision = Instance.new("NoCollisionConstraint")
            noCollision.Part0 = object.Part0
            noCollision.Part1 = object.Part1
            noCollision.Parent = object.Part0
            table.insert(record.created, a)
            table.insert(record.created, b)
            table.insert(record.created, socket)
            table.insert(record.created, noCollision)
            record.motors[object] = object.Enabled
            object.Enabled = false
        elseif object:IsA("BasePart") then
            record.collisions[object] = object.CanCollide
            object.CanCollide = object ~= root and not object:FindFirstAncestorWhichIsA("Tool")
                and not object:FindFirstAncestorWhichIsA("Accessory")
        end
    end
    humanoid.Sit = false
    humanoid.AutoRotate = false
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    pcall(function()
        root:SetNetworkOwner(nil)
    end)
    local flat = Vector3.new(direction.X, 0, direction.Z)
    flat = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
    root.AssemblyLinearVelocity = flat * Config.PushSpeed + Vector3.yAxis * Config.LiftSpeed
    root.AssemblyAngularVelocity = Vector3.new(flat.Z, 0, -flat.X) * Config.RollSpeed
    task.delay(Config.RagdollDuration, function()
        restoreRagdoll(character, record)
    end)
    return true
end

function Service.TryShoot(player, aim)
    if not finiteVector(aim) then
        return false, "잘못된 조준 위치"
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local tool = character and character:FindFirstChild(Config.ToolName)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 or character:GetAttribute("PrankRagdoll")
        or not tool or not tool:IsA("Tool") or not tool:GetAttribute("PrankPistol") then
        return false, "권총을 장착하세요"
    end
    local now = os.clock()
    if now - (lastShot[player] or -math.huge) < Config.FireCooldown then
        return false, "재사용 대기 중"
    end
    local muzzle = tool.Handle:FindFirstChild("Muzzle")
    local origin = muzzle and muzzle.WorldPosition or root.Position + Vector3.new(0, 1, 0)
    if (origin - root.Position).Magnitude > 8 or (aim - origin).Magnitude < 0.1 then
        return false, "잘못된 총구 위치"
    end
    lastShot[player] = now
    local direction = (aim - origin).Unit
    local ignored = { character }
    local cities = workspace:FindFirstChild("ProjectMS_PersonalCities")
    for _, folder in ipairs(cities and cities:GetChildren() or {}) do
        if folder:GetAttribute("OwnerUserId") ~= player.UserId then
            table.insert(ignored, folder)
        end
    end
    for _, base in ipairs(workspace.ProjectMS_Bases:GetChildren()) do
        if not base:GetAttribute("VisitLocked") or base:GetAttribute("OwnerUserId") == player.UserId then
            table.insert(ignored, base.VisitGate.Barrier)
        end
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignored
    local hit = workspace:Raycast(origin, direction * Config.Range, params)
    local endpoint = hit and hit.Position or origin + direction * Config.Range
    remotes.Trace:FireAllClients(origin, endpoint)
    local target = hit and hit.Instance:FindFirstAncestorOfClass("Model")
    local victim = target and Players:GetPlayerFromCharacter(target)
    local testTarget = target and RunService:IsStudio() and target:GetAttribute("PrankTestTarget")
    if target and (victim or testTarget) then
        if inLockedArea(root.Position) or inLockedArea(target:GetPivot().Position) then
            return true, "잠긴 기지·진입로는 장난 사격 보호 구역입니다"
        end
        local ok, reason = Service.Ragdoll(target, direction)
        return true, ok and "적중! 잠시 뒤 자동으로 일어납니다" or reason
    end
    -- 건물 목표 선택은 기존 클릭/터치 클라이언트가 그대로 처리합니다. 권총 피해는 없습니다.
    return true, "발사"
end

local function equip(player, character)
    task.spawn(function()
        local backpack = player:WaitForChild("Backpack", 10)
        local humanoid = character:WaitForChild("Humanoid", 10)
        local tool = backpack and backpack:WaitForChild(Config.ToolName, 10)
        if humanoid and tool and character == player.Character then
            humanoid:EquipTool(tool)
        end
    end)
end

function Service.Start()
    if started then
        return
    end
    started = true
    BaseService.Start()
    for _, base in ipairs(workspace.ProjectMS_Bases:GetChildren()) do
        base:SetAttribute("VisitLocked", false)
        base.VisitGate.Control.ToggleVisitLock.Triggered:Connect(function(player)
            local ok, message = Service.SetLocked(player, base, not base:GetAttribute("VisitLocked"))
            remotes.Notice:FireClient(player, message or (ok and "기지 출입 설정을 바꿨습니다"))
        end)
    end
    local function add(player)
        player.CharacterAdded:Connect(function(character)
            equip(player, character)
        end)
        if player.Character then
            equip(player, player.Character)
        end
    end
    Players.PlayerAdded:Connect(add)
    for _, player in ipairs(Players:GetPlayers()) do
        add(player)
    end
    remotes.Shoot.OnServerEvent:Connect(function(player, aim)
        local ok, message = Service.TryShoot(player, aim)
        if ok or message ~= "재사용 대기 중" then
            remotes.Notice:FireClient(player, message)
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        lastShot[player] = nil
    end)
    local elapsed = 0
    RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < 0.15 then
            return
        end
        elapsed = 0
        for _, base in ipairs(workspace.ProjectMS_Bases:GetChildren()) do
            local owner = base:GetAttribute("OwnerUserId") or 0
            if lastOwner[base] ~= owner then
                base:SetAttribute("VisitLocked", false)
                lastOwner[base] = owner
            end
            local locked = owner ~= 0 and base:GetAttribute("VisitLocked")
            local gate = base.VisitGate
            gate.Barrier.Transparency = locked and 0.45 or 1
            gate.LaneBarrier.Transparency = locked and 0.45 or 1
            gate.Control.Color = locked and Color3.fromRGB(235, 110, 75) or Color3.fromRGB(80, 210, 150)
            gate.Control.VisitSign.Text.Text = locked and "방문 잠금 · 주인만 출입" or "방문 허용"
            gate.Control.ToggleVisitLock.Enabled = owner ~= 0
            gate.Control.ToggleVisitLock.ActionText = locked and "방문 허용으로 변경" or "방문 잠그기"
        end
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local base = root and inLockedArea(root.Position, player.UserId)
            if base then
                BaseService.PrepareTravel(player)
                character:PivotTo(base.Floor.CFrame * CFrame.new(0, 4, -base.Floor.Size.Z / 2 - 9))
                root.AssemblyLinearVelocity = Vector3.zero
                remotes.Notice:FireClient(player, "잠긴 기지·진입로에는 들어갈 수 없습니다")
            end
        end
    end)
end
return Service
