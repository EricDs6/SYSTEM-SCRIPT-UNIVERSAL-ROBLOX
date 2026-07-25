-- =============================================================================
-- COMMAND: NO FLING
-- =============================================================================
return function(GH)
	local Players = GH.Services.Players
	local RunService = GH.Services.RunService
	local LocalPlayer = GH.LocalPlayer

	function Cheats_ToggleNoFling(state, btn)
		GH.UnregisterMasterLoop("NoFling")

		if state then
			GH.RegisterMasterLoop("NoFling", "Heartbeat", function()
				if GH.isClosing or not GH.States.NoFling then
					GH.UnregisterMasterLoop("NoFling")
					return
				end
				local char = LocalPlayer.Character
				if not char then return end
				local root = char:FindFirstChild("HumanoidRootPart")
				if not root then return end

				for _, v in ipairs(root:GetChildren()) do
					if v:IsA("BodyAngularVelocity") or v:IsA("BodyAngularForce") then
						v:Destroy()
					end
				end

				for _, att in ipairs(root:GetDescendants()) do
					if att:IsA("Attachment") then
						for _, v in ipairs(att:GetChildren()) do
							if v:IsA("AngularVelocity") or v:IsA("VectorForce") then
								v:Destroy()
							end
						end
					end
				end

				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
					end
				end
			end)
		end
	end

	GH.RegisterToggleButton("NoFling", "toggle_nofling", Cheats_ToggleNoFling, "Combat", "desc_nofling")
end