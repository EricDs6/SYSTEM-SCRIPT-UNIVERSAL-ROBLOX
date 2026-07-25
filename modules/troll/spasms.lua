-- =============================================================================
-- COMMAND: SPASMS
-- =============================================================================
return function(GH)
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleSpasmos(state, btn)
		pcall(function()
			if GH.Cache.SpasmTrack then
				GH.Cache.SpasmTrack:Stop()
				GH.Cache.SpasmTrack:Destroy()
				GH.Cache.SpasmTrack = nil
			end
			if GH.Cache.SpasmAnim then
				GH.Cache.SpasmAnim:Destroy()
				GH.Cache.SpasmAnim = nil
			end
		end)

		if state then
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			local animator = hum:FindFirstChildOfClass("Animator")
			if animator then
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					track:Stop(0)
					track:Destroy()
				end
			else
				animator = Instance.new("Animator")
				animator.Parent = hum
			end

			GH.Cache.SpasmAnim = Instance.new("Animation")
			GH.Cache.SpasmAnim.AnimationId = "rbxassetid://33796059"
			GH.Cache.SpasmTrack = animator:LoadAnimation(GH.Cache.SpasmAnim)
			GH.Cache.SpasmTrack.Looped = true
			GH.Cache.SpasmTrack:Play()
			GH.Cache.SpasmTrack:AdjustSpeed(99)
		end
	end

	GH.RegisterToggleButton("Spasms", GH.T("toggle_spasms"), Cheats_ToggleSpasmos, "Troll", GH.T("desc_spasms"))
end