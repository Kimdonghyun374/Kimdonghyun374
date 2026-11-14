-- 2026-11-14: 공동 레이드 반경 확장. 한 번만 적용하는 Edit 전용 작업.
local lanes = workspace.ProjectMS_Lanes
local bases = workspace.ProjectMS_Bases
local arena = lanes.RaidArena
local floor = arena.RaidFloor
assert(math.abs(floor.Size.Y - 120) < 0.01, "기존 반경60 배치에서만 실행하세요.")
local editor = game:GetService("ScriptEditorService")
local network = game.ReplicatedStorage.PetMissiles
local progression = game.ServerScriptService.PetMissiles.ProgressionService
local backupRoot = game.ServerStorage:FindFirstChild("ProjectMSBackups")
if not backupRoot then
    backupRoot = Instance.new("Folder")
    backupRoot.Name = "ProjectMSBackups"
    backupRoot.Parent = game.ServerStorage
end
local backup = Instance.new("Folder")
backup.Name = "BeforeRaidArenaExpansion_" .. os.time()
backup.Parent = backupRoot
for _, original in {bases, lanes, workspace.ProjectMS_City, workspace.ProjectMS_Garage, workspace.ProjectMS_Worlds.World_1.Entry, workspace.SpawnLocation, network.RaidConfig, progression} do
    original:Clone().Parent = backup
end

local outwardDistance = 60
local function translateParts(container, offset)
    for _, item in container:GetDescendants() do
        if item:IsA("BasePart") then
            item.CFrame += offset
        end
    end
end

-- 각 기지 내부 간격과 회전은 그대로 두고 방사 방향으로 평행 이동합니다.
for index = 1, 6 do
    local base = bases["Base_" .. index]
    local pivot = base:GetPivot()
    local flat = Vector3.new(pivot.X, 0, pivot.Z)
    local offset = flat.Unit * outwardDistance
    base:PivotTo(pivot + offset)
    translateParts(lanes["Lane_" .. index], offset)
end
translateParts(workspace.ProjectMS_City, Vector3.new(0, 0, -outwardDistance))
translateParts(workspace.ProjectMS_Garage, Vector3.new(-outwardDistance, 0, 0))
workspace.ProjectMS_Worlds.World_1.Entry.CFrame += Vector3.new(outwardDistance, 0, 0)
workspace.SpawnLocation.CFrame += Vector3.new(0, 0, -outwardDistance)

floor.Size = Vector3.new(floor.Size.X, 240, 240)
local plaza = lanes.PlazaFloor
plaza.Size = Vector3.new(plaza.Size.X, 336, 336)
arena.RaidBossMarker.LayoutSign.Text.Text = "공동 보스 레이드 구역"
lanes:SetAttribute("RaidArenaRadius", 120)
lanes:SetAttribute("BaseCenterRadius", 230)

local function updateScript(scriptInstance, oldText, newText)
    local source = scriptInstance.Source
    assert(source:find(oldText, 1, true), scriptInstance.Name .. ": 기존 설정 없음")
    local startIndex, endIndex = source:find(oldText, 1, true)
    source = source:sub(1, startIndex - 1) .. newText .. source:sub(endIndex + 1)
    editor:UpdateSourceAsync(scriptInstance, function()
        return source
    end)
    scriptInstance.Source = source
    assert(editor:GetEditorSource(scriptInstance) == scriptInstance.Source)
end
updateScript(network.RaidConfig, "ArenaRadius = 60,", "ArenaRadius = 120,")
updateScript(network.RaidConfig, "AttackPlayerRange = 75,", "AttackPlayerRange = 135,")
updateScript(progression, "local NIGHT_SAFE_RADIUS = 246", "local NIGHT_SAFE_RADIUS = 306")
workspace.CurrentCamera.CFrame = CFrame.lookAt(Vector3.new(440, 520, 440), Vector3.new(0, 0, 0))
game:GetService("Selection"):Set({arena.RaidFloor})
return {backup = backup:GetFullName(), arenaRadius = 120, plazaRadius = 168, baseRadius = 230, outwardDistance = outwardDistance}