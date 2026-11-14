--[[
	MissileVFX (ModuleScript) — 미사일 비행/폭발 이펙트

	- 위치: ReplicatedStorage 등 클라이언트가 require할 수 있는 곳
	- 클라이언트(LocalScript)에서 호출 전제
	- 다른 스크립트 의존 없음. 텍스처는 Studio 기본(rbxasset://)이라 업로드 불필요

	- 사용법
	  local MissileVFX = require(ReplicatedStorage.MissileVFX)
	  local vfx = MissileVFX.attach(missileModel)    -- 발사할 때 붙임
	  vfx:SetEnabled(false)                          -- 장착 중엔 끄기 (발사 때 true)
	  MissileVFX.explode(hitPosition, rarity, scale) -- 착탄 지점 폭발, 2초 뒤 자동 정리
	  vfx:Destroy()                                  -- 미사일 회수/풀링 시
	  MissileVFX.Quality = 0.5                       -- 저사양에서 파티클 양 줄이기

	- 미사일 모델 조건
	  - Model 속성 Rarity(common~cosmic), Scale(크기 배율). Rarity가 없으면 attach의 두 번째 인자로 지정
	  - PrimaryPart(몸통) 안에 TrailAttachment(꼬리 끝)가 있으면 그 위치에 붙음
	  - 없으면 탄두가 -Z 방향이라고 보고 바운딩 박스 꼬리(+Z)에 자동 생성

	- 희귀도별 색·구성은 아래 Presets 표에서 수정
	  전 등급 추진 불빛+연기 / Rare부터 Trail / Epic부터 화염 / Legendary부터 PointLight / Mythic 불씨 / Cosmic 별가루
]]

local TweenService = game:GetService("TweenService")

local TEX = {
	smoke = "rbxasset://textures/particles/smoke_main.dds",
	fire = "rbxasset://textures/particles/fire_main.dds",
	sparkle = "rbxasset://textures/particles/sparkles_main.dds",
}

local MissileVFX = {}

-- 파티클 양 배율. 저사양 기기나 동시 발사가 많을 때 0.5 등으로 낮춤
MissileVFX.Quality = 1
-- 폭발용 임시 파트를 넣을 곳
MissileVFX.Container = workspace

-- core: 추진 불빛·화염 안쪽 색 / tip: 바깥쪽 색 / smoke: 연기 색 / boom: 폭발 반경(stud)
MissileVFX.Presets = {
	common = {
		scale = 1.0, core = "#FFB347", tip = "#FF6A1A", smoke = "#B8BEC4", smokeRate = 16, boom = 8,
		trail = false, fire = false, light = false, extra = nil,
	},
	uncommon = {
		scale = 1.15, core = "#D4FF7A", tip = "#4CAF50", smoke = "#C8D4C8", smokeRate = 18, boom = 9,
		trail = false, fire = false, light = false, extra = nil,
	},
	rare = {
		scale = 1.3, core = "#9FE0FF", tip = "#2F80ED", smoke = "#D6E6F5", smokeRate = 20, boom = 10.5,
		trail = true, fire = false, light = false, extra = nil,
	},
	epic = {
		scale = 1.5, core = "#E0B3FF", tip = "#7B3FE4", smoke = "#B9A6D6", smokeRate = 22, boom = 12,
		trail = true, fire = true, light = false, extra = nil,
	},
	legendary = {
		scale = 1.75, core = "#FFF3B0", tip = "#E5A400", smoke = "#E8DCC0", smokeRate = 24, boom = 14,
		trail = true, fire = true, light = true, extra = nil,
	},
	mythic = {
		scale = 2.0, core = "#FF4FD8", tip = "#E0245E", smoke = "#2A1A20", smokeRate = 26, boom = 16,
		trail = true, fire = true, light = true, extra = "embers",
	},
	cosmic = {
		scale = 2.4, core = "#7DF9FF", tip = "#FF4FD8", smoke = "#3B1F8F", smokeRate = 28, boom = 19,
		trail = true, fire = true, light = true, extra = "stars",
	},
}

local function hex(value: string): Color3
	return Color3.fromHex(value)
end

local function seq(a: string, b: string): ColorSequence
	return ColorSequence.new(hex(a), hex(b))
end

-- ns({0, 1}, {1, 0}) → NumberSequence
local function ns(...): NumberSequence
	local points = {}
	for _, p in { ... } do
		table.insert(points, NumberSequenceKeypoint.new(p[1], p[2]))
	end
	return NumberSequence.new(points)
end

local function make(className: string, props, parent: Instance?)
	local inst = Instance.new(className)
	for key, value in props do
		inst[key] = value
	end
	inst.Parent = parent
	return inst
end

local function rate(value: number): number
	return value * MissileVFX.Quality
end

local function presetFor(rarity: string?)
	return MissileVFX.Presets[rarity or "common"] or MissileVFX.Presets.common
end

---- 비행 이펙트 ----

local Handle = {}
Handle.__index = Handle

function Handle:SetEnabled(on: boolean)
	for _, holder in self._holders do
		for _, inst in holder:GetChildren() do
			if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Light") then
				inst.Enabled = on
			end
		end
	end
end

function Handle:Destroy()
	for _, holder in self._holders do
		holder:Destroy()
	end
	table.clear(self._holders)
end

local function findTail(model: Model, body: BasePart): Attachment
	local tail = body:FindFirstChild("TrailAttachment")
	if tail and tail:IsA("Attachment") then
		return tail
	end
	-- 조립 스크립트로 만든 모델이 아니면 바운딩 박스 꼬리(+Z, 탄두 반대쪽)에 만듦
	local cf, size = model:GetBoundingBox()
	tail = Instance.new("Attachment")
	tail.Name = "TrailAttachment"
	tail.CFrame = body.CFrame:ToObjectSpace(cf * CFrame.new(0, 0, size.Z / 2))
	tail.Parent = body
	return tail
end

function MissileVFX.attach(model: Model, rarity: string?)
	rarity = rarity or model:GetAttribute("Rarity") or "common"
	local p = presetFor(rarity)
	local s = model:GetAttribute("Scale") or p.scale
	local body = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	assert(body, `[MissileVFX] {model:GetFullName()}에 BasePart가 없습니다`)

	-- 다시 붙이면 이전 이펙트를 지움
	for _, old in body:GetChildren() do
		if old:GetAttribute("MissileVFX") then
			old:Destroy()
		end
	end

	local tail = findTail(model, body)
	local function holder(name: string, offset: Vector3): Attachment
		local at = make("Attachment", { Name = name, CFrame = tail.CFrame * CFrame.new(offset) }, body)
		at:SetAttribute("MissileVFX", true)
		return at
	end
	local vfx = holder("VFX_Tail", Vector3.zero)
	local holders = { vfx }

	-- 추진 불빛: 노즐에 붙어 있는 밝은 점 (전 등급)
	make("ParticleEmitter", {
		Name = "Core", Texture = TEX.sparkle, Color = seq(p.core, p.tip), LightEmission = 1,
		Size = ns({ 0, 1.1 * s }, { 1, 0.4 * s }), Transparency = ns({ 0, 0 }, { 1, 0.6 }),
		Lifetime = NumberRange.new(0.08, 0.12), Rate = rate(50), Speed = NumberRange.new(0),
		LockedToPart = true, ZOffset = 1,
	}, vfx)

	-- 연기 (전 등급). Mythic처럼 어두운 연기는 빛을 내지 않음
	make("ParticleEmitter", {
		Name = "Smoke", Texture = TEX.smoke, Color = seq(p.smoke, p.smoke), LightInfluence = 1,
		Size = ns({ 0, 0.4 * s }, { 1, 2.2 * s }), Transparency = ns({ 0, 0.35 }, { 1, 1 }),
		Lifetime = NumberRange.new(0.9, 1.4), Rate = rate(p.smokeRate), Speed = NumberRange.new(2, 4),
		SpreadAngle = Vector2.new(8, 8), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-40, 40),
		Acceleration = Vector3.new(0, 1.5, 0), Drag = 1, EmissionDirection = Enum.NormalId.Back,
	}, vfx)

	if p.fire then
		make("ParticleEmitter", {
			Name = "Flame", Texture = TEX.fire, Color = seq(p.core, p.tip), LightEmission = 1,
			Size = ns({ 0, 0.9 * s }, { 1, 0.15 * s }), Transparency = ns({ 0, 0.1 }, { 1, 1 }),
			Lifetime = NumberRange.new(0.18, 0.3), Rate = rate(45), Speed = NumberRange.new(6, 9),
			SpreadAngle = Vector2.new(6, 6), Rotation = NumberRange.new(0, 360),
			EmissionDirection = Enum.NormalId.Back, ZOffset = 0.5,
		}, vfx)
	end

	if p.extra == "embers" then
		make("ParticleEmitter", {
			Name = "Embers", Texture = TEX.sparkle, Color = seq(p.core, p.tip), LightEmission = 1,
			Size = ns({ 0, 0.3 * s }, { 1, 0 }), Lifetime = NumberRange.new(0.6, 1),
			Rate = rate(25), Speed = NumberRange.new(3, 6), SpreadAngle = Vector2.new(35, 35),
			Acceleration = Vector3.new(0, -4, 0), Drag = 2, EmissionDirection = Enum.NormalId.Back,
		}, vfx)
	elseif p.extra == "stars" then
		make("ParticleEmitter", {
			Name = "Stars", Texture = TEX.sparkle, LightEmission = 1,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, hex(p.core)),
				ColorSequenceKeypoint.new(0.5, hex(p.tip)),
				ColorSequenceKeypoint.new(1, hex(p.core)),
			}),
			Size = ns({ 0, 0 }, { 0.3, 0.5 * s }, { 1, 0 }), Lifetime = NumberRange.new(0.8, 1.4),
			Rate = rate(20), Speed = NumberRange.new(1, 2), SpreadAngle = Vector2.new(180, 180),
			Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-90, 90),
		}, vfx)
	end

	if p.trail then
		local a0 = holder("VFX_Trail0", Vector3.new(0, 0.35 * s, 0))
		local a1 = holder("VFX_Trail1", Vector3.new(0, -0.35 * s, 0))
		table.insert(holders, a0)
		table.insert(holders, a1)
		make("Trail", {
			Name = "Trail", Attachment0 = a0, Attachment1 = a1, Color = seq(p.core, p.tip),
			Transparency = ns({ 0, 0.15 }, { 1, 1 }), WidthScale = ns({ 0, 1 }, { 1, 0.2 }),
			Lifetime = 0.35 + 0.05 * s, MinLength = 0.05, FaceCamera = true, LightEmission = 1,
		}, a0)
	end

	if p.light then
		make("PointLight", { Name = "Glow", Color = hex(p.core), Brightness = 2.5, Range = 6 * s, Shadows = false }, vfx)
	end

	return setmetatable({ _holders = holders, Rarity = rarity }, Handle)
end

---- 폭발 ----

local function shockwave(position: Vector3, color: string, size: number, duration: number, delay: number)
	local ring = make("Part", {
		Name = "Shockwave", Shape = Enum.PartType.Ball, Material = Enum.Material.Neon, Color = hex(color),
		Size = Vector3.one, CFrame = CFrame.new(position), Transparency = 0.3, Anchored = true,
		CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false,
	}, MissileVFX.Container)
	TweenService:Create(
		ring,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, delay),
		{ Size = Vector3.one * size, Transparency = 1 }
	):Play()
	task.delay(duration + delay + 0.1, ring.Destroy, ring)
end

function MissileVFX.explode(position: Vector3, rarity: string?, scale: number?)
	local p = presetFor(rarity)
	local b = p.boom * ((scale or p.scale) / p.scale)

	local holder = make("Part", {
		Name = "MissileExplosion", Size = Vector3.one, CFrame = CFrame.new(position), Transparency = 1,
		Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false,
	}, MissileVFX.Container)
	local at = make("Attachment", {}, holder)

	local function burst(count: number, props)
		props.Enabled = false
		props.Rotation = props.Rotation or NumberRange.new(0, 360)
		props.SpreadAngle = props.SpreadAngle or Vector2.new(180, 180)
		make("ParticleEmitter", props, at):Emit(math.max(1, math.round(rate(count))))
	end

	burst(2, {
		Name = "Flash", Texture = TEX.sparkle, Color = seq(p.core, p.core), LightEmission = 1,
		Size = ns({ 0, b * 0.3 }, { 1, b * 0.9 }), Transparency = ns({ 0, 0 }, { 1, 1 }),
		Lifetime = NumberRange.new(0.15), Speed = NumberRange.new(0),
	})
	burst(25, {
		Name = "Fireball", Texture = TEX.fire, Color = seq(p.core, p.tip), LightEmission = 1,
		Size = ns({ 0, b * 0.25 }, { 1, b * 0.05 }), Transparency = ns({ 0, 0 }, { 1, 1 }),
		Lifetime = NumberRange.new(0.3, 0.5), Speed = NumberRange.new(b * 1.2, b * 2), Drag = 4,
	})
	burst(14, {
		Name = "Smoke", Texture = TEX.smoke, Color = seq(p.smoke, p.smoke), LightInfluence = 1,
		Size = ns({ 0, b * 0.2 }, { 1, b * 0.45 }), Transparency = ns({ 0, 0.3 }, { 1, 1 }),
		Lifetime = NumberRange.new(1, 1.6), Speed = NumberRange.new(b * 0.4, b * 0.8), Drag = 2,
		Acceleration = Vector3.new(0, 2, 0), RotSpeed = NumberRange.new(-30, 30),
	})
	burst(20, {
		Name = "Sparks", Texture = TEX.sparkle, Color = seq(p.core, p.tip), LightEmission = 1,
		Size = ns({ 0, 0.3 + b * 0.02 }, { 1, 0 }), Lifetime = NumberRange.new(0.4, 0.7),
		Speed = NumberRange.new(b * 2.5, b * 4), Drag = 3, Acceleration = Vector3.new(0, -20, 0),
	})

	shockwave(position, p.core, b, 0.35, 0)
	if p.fire then
		-- Epic부터 바깥 색 링을 한 겹 더
		shockwave(position, p.tip, b * 1.3, 0.45, 0.05)
	end

	if p.light then
		local light = make("PointLight", { Color = hex(p.core), Brightness = 4, Range = b * 2, Shadows = false }, at)
		TweenService:Create(light, TweenInfo.new(0.4), { Brightness = 0 }):Play()
	end

	task.delay(2, holder.Destroy, holder)
end

return MissileVFX
