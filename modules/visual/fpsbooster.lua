-- =============================================================================
-- COMMAND: FPS BOOSTER - Otimiza o desempenho reduzindo qualidade grafica
-- =============================================================================
return function(GH)
	local Lighting = game:GetService("Lighting")

	local function Cheats_ToggleFPSBooster(state, btn)
		if state then
			-- Inicializa cache se necessario
			GH.Cache = GH.Cache or {}

			-- Salva configuracoes originais para restaurar depois
			local ok, quality = pcall(function()
				return UserSettings().GameSettings.SavedQualityLevel
			end)
			GH.Cache.OrigQualityLevel = ok and quality or nil
			GH.Cache.OrigGlobalShadows = Lighting.GlobalShadows
			GH.Cache.OrigTechnology = Lighting.Technology
			GH.Cache.OrigFogEnd = Lighting.FogEnd

			-- Forca qualidade grafica minima (com pcall para seguranca)
			pcall(function()
				UserSettings().GameSettings.SavedQualityLevel = Enum.QualityLevel.Level01
			end)

			-- Desativa sombras globais
			Lighting.GlobalShadows = false

			-- Forca tecnologia Voxel (menos custosa)
			Lighting.Technology = Enum.Technology.Voxel

			-- Reduz nevoa/bruma
			Lighting.FogEnd = 1e5

			-- Remove efeitos pos-processamento
			GH.Cache.FPSB_Effects = {}
			for _, child in ipairs(Lighting:GetChildren()) do
				if child:IsA("BloomEffect") or child:IsA("SunRaysEffect")
					or child:IsA("ColorCorrectionEffect") or child:IsA("BlurEffect")
					or child:IsA("DepthOfFieldEffect") then
					child.Enabled = false
					table.insert(GH.Cache.FPSB_Effects, child)
				end
			end

			-- Desabilita particulas e efeitos visuais em todo workspace
			GH.Cache.FPSB_Particles = {}
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Fire")
					or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Trail") then
					if v.Enabled then
						v.Enabled = false
						table.insert(GH.Cache.FPSB_Particles, v)
					end
				end
			end

			-- CastShadow = false em todas as partes
			GH.Cache.FPSB_CastShadow = {}
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("BasePart") and v.CastShadow then
					v.CastShadow = false
					table.insert(GH.Cache.FPSB_CastShadow, v)
				end
			end

			GH.ShowToast(GH.T("toast_fpsbooster_on"), Color3.fromRGB(80, 200, 120), 2.5)
		else
			-- Restaura qualidade grafica
			if GH.Cache.OrigQualityLevel then
				pcall(function()
					UserSettings().GameSettings.SavedQualityLevel = GH.Cache.OrigQualityLevel
				end)
			end

			-- Restaura configs de iluminacao
			if GH.Cache.OrigGlobalShadows ~= nil then
				Lighting.GlobalShadows = GH.Cache.OrigGlobalShadows
			end
			if GH.Cache.OrigTechnology ~= nil then
				Lighting.Technology = GH.Cache.OrigTechnology
			end
			Lighting.FogEnd = GH.Cache.OrigFogEnd or 1e5

			-- Restaura efeitos pos-processamento
			if GH.Cache.FPSB_Effects then
				for _, effect in ipairs(GH.Cache.FPSB_Effects) do
					if effect and effect.Parent then
						effect.Enabled = true
					end
				end
			end

			-- Restaura particulas
			if GH.Cache.FPSB_Particles then
				for _, v in ipairs(GH.Cache.FPSB_Particles) do
					if v and v.Parent then
						v.Enabled = true
					end
				end
			end

			-- Restaura CastShadow
			if GH.Cache.FPSB_CastShadow then
				for _, v in ipairs(GH.Cache.FPSB_CastShadow) do
					if v and v.Parent then
						v.CastShadow = true
					end
				end
			end

			-- Limpa cache
			GH.Cache.OrigQualityLevel = nil
			GH.Cache.OrigGlobalShadows = nil
			GH.Cache.OrigTechnology = nil
			GH.Cache.OrigFogEnd = nil
			GH.Cache.FPSB_Effects = nil
			GH.Cache.FPSB_Particles = nil
			GH.Cache.FPSB_CastShadow = nil

			GH.ShowToast(GH.T("toast_fpsbooster_off"), GH.Theme.Accent, 2)
		end
	end

	GH.RegisterToggleButton("FPSBooster", "toggle_fpsbooster", Cheats_ToggleFPSBooster, "Visual", "desc_fpsbooster")
end
