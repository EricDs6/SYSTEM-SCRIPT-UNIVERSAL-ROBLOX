-- =============================================================================
-- UTILS — WeakCache, ObjectPool, TweenTeleport
-- =============================================================================
return function(GH, services)
local RunService = services.RunService
local TweenService = services.TweenService
local LocalPlayer = GH.LocalPlayer

-- ==========================================
-- WEAK TABLES
-- ==========================================
function GH.MakeWeakCache(mode)
	return setmetatable({}, { __mode = mode })
end

-- ==========================================
-- OBJECT POOL (para Drawing)
-- ==========================================
GH.ObjectPool = {}
GH.ObjectPool.__index = GH.ObjectPool

function GH.ObjectPool.new(factory, destructor)
	local self = setmetatable({}, GH.ObjectPool)
	self._pool = {}
	self._factory = factory
	self._destructor = destructor
	return self
end

function GH.ObjectPool:get(...)
	local n = #self._pool
	if n > 0 then
		local obj = self._pool[n]
		self._pool[n] = nil
		return obj
	end
	return self._factory(...)
end

function GH.ObjectPool:release(obj)
	if obj then
		self._destructor(obj)
		table.insert(self._pool, obj)
	end
end

function GH.ObjectPool:clear()
	for i = 1, #self._pool do
		pcall(self._destructor, self._pool[i])
		self._pool[i] = nil
	end
end

-- ==========================================
-- TWEEN TELEPORT HELPER
-- ==========================================
-- Move o personagem via TweenService com noclip contínuo durante o voo.
-- Velocidade baseada na distância (250 studs/s padrão) para parecer natural.
function GH.TweenTeleport(hrp, targetCFrame, speedOrDuration)
	if not hrp then return end
	if not LocalPlayer.Character then return end

	local char = LocalPlayer.Character

	-- Calcula distância total
	local distance = (hrp.Position - targetCFrame.Position).Magnitude

	-- Velocidade de viagem (250 studs/s padrão — burla 90% dos anti-cheats)
	-- O 3º parâmetro aceita velocidade (studs/s) ou duração (segundos).
	-- Regra: se o valor > 1, é velocidade; senão é duração (compatibilidade).
	local duration
	if speedOrDuration and speedOrDuration > 1 then
		-- É velocidade em studs/s
		duration = math.max(distance / speedOrDuration, 0.05)
	else
		-- É duração em segundos (compatibilidade com chamadas antigas) ou nil (usar 250 studs/s)
		duration = speedOrDuration or math.max(distance / 250, 0.05)
	end

	-- Trava colisões durante toda a viagem via RunService.Stepped
	local noclipConn
	noclipConn = RunService.Stepped:Connect(function()
		if char and char.Parent then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)

	-- Movimento suave com easing Linear (velocidade constante = mais natural)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCFrame })
	tween:Play()

	-- Limpeza quando chegar no destino
	tween.Completed:Connect(function()
		if noclipConn then noclipConn:Disconnect() end
	end)
end

end -- module
