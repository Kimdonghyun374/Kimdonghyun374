-- 자산 미사일 모델(ReplicatedStorage.MissileAssets) 복제 도우미. 2026-11-13.
-- 모델은 탄두가 -Z(앞)를 향합니다. 길이(Z)를 원하는 크기로 맞추고, 충돌·조회·접촉을 끈 고정 모델을 돌려줍니다.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MissileModels = {}

local function assetFolder()
    return ReplicatedStorage:FindFirstChild("MissileAssets")
end

-- modelName: 카탈로그 definition.model, length: 원하는 전체 길이(stud). 없으면 nil.
function MissileModels.Build(modelName, length)
    local folder = assetFolder()
    local source = modelName and folder and folder:FindFirstChild(modelName)
    if not source or not source:IsA("Model") then
        return nil
    end
    local model = source:Clone()
    -- 원본 자산은 보존하고 게임에 표시할 복제본만 Toy City 팔레트로 마감합니다.
    local accents = {
        common = Color3.fromRGB(48, 112, 224),
        uncommon = Color3.fromRGB(104, 181, 72),
        rare = Color3.fromRGB(48, 140, 224),
        epic = Color3.fromRGB(143, 105, 211),
        legendary = Color3.fromRGB(255, 195, 48),
        mythic = Color3.fromRGB(239, 82, 86),
        cosmic = Color3.fromRGB(84, 108, 201),
    }
    local accent = accents[model:GetAttribute("Rarity")] or accents.common
    for _, part in model:GetDescendants() do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.CanQuery = false
            part.CanTouch = false
            part.CastShadow = false
            part.Material = Enum.Material.SmoothPlastic
            if part.Name:find("body", 1, true) then
                part.Color = Color3.fromRGB(240, 245, 251)
            elseif part.Name:find("warhead", 1, true) or part.Name:find("nose", 1, true) then
                part.Color = accent
            elseif part.Name:find("fin", 1, true) then
                part.Color = Color3.fromRGB(255, 195, 48)
            elseif part.Name:find("nozzle", 1, true) then
                part.Color = Color3.fromRGB(62, 80, 108)
            end
        end
    end
    -- 중심을 기준점으로 두고 길이를 맞춥니다.
    local boxFrame, boxSize = model:GetBoundingBox()
    model.WorldPivot = CFrame.new(boxFrame.Position) * (model:GetPivot() - model:GetPivot().Position)
    local longest = math.max(boxSize.Z, 0.01)
    model:ScaleTo(model:GetScale() * (length / longest))
    return model
end

return MissileModels
