-- =============================================================================
-- TOAST — Sistema de notificacoes customizado Win11
-- =============================================================================
return function(GH, services)
local TweenService = services.TweenService

function GH.ShowToast(message, color, duration, persistent)
	if GH.SilentRestore then return end
	if not GH.ScreenGui or not GH.ScreenGui.Parent then return end

	pcall(function()
		if not GH.ToastContainer then
			GH.ToastContainer = Instance.new("Frame")
			GH.ToastContainer.Name = "GH_ToastContainer"
			GH.ToastContainer.Size = UDim2.new(0, 320, 1, 0)
			GH.ToastContainer.Position = UDim2.new(1, -330, 0, 40)
			GH.ToastContainer.BackgroundTransparency = 1
			GH.ToastContainer.ZIndex = 9999
			GH.ToastContainer.Parent = GH.ScreenGui
			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 6)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.VerticalAlignment = Enum.VerticalAlignment.Top
			layout.Parent = GH.ToastContainer
		end

		GH._toastIndex = (GH._toastIndex or 0) + 1
		local toast = Instance.new("Frame")
		toast.Size = UDim2.new(1, 0, 0, 0)
		toast.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		toast.BackgroundTransparency = 0.05
		toast.BorderSizePixel = 0
		toast.LayoutOrder = GH._toastIndex
		toast.ZIndex = 10000
		toast.ClipsDescendants = true
		toast.Parent = GH.ToastContainer
		Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

		local stroke = Instance.new("UIStroke")
		stroke.Color = color or GH.Theme.Accent
		stroke.Thickness = 1
		stroke.Transparency = 0.5
		stroke.Parent = toast

		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(0, 3, 1, 0)
		accent.BackgroundColor3 = color or GH.Theme.Accent
		accent.BorderSizePixel = 0
		accent.Parent = toast

		-- Botao X para fechar (apenas em toasts persistentes)
		local closeBtn = nil
		if persistent then
			closeBtn = Instance.new("TextButton")
			closeBtn.Size = UDim2.new(0, 22, 0, 22)
			closeBtn.Position = UDim2.new(1, -26, 0.5, -11)
			closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
			closeBtn.Text = ""
			closeBtn.AutoButtonColor = false
			closeBtn.ZIndex = 10003
			closeBtn.Parent = toast
			Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

			local closeX = Instance.new("TextLabel")
			closeX.Size = UDim2.new(1, 0, 1, 0)
			closeX.BackgroundTransparency = 1
			closeX.Text = "X"
			closeX.TextColor3 = Color3.fromRGB(180, 180, 190)
			closeX.Font = Enum.Font.SourceSans
			closeX.TextSize = 12
			closeX.ZIndex = 10004
			closeX.Parent = closeBtn

			closeBtn.MouseEnter:Connect(function()
				TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
			end)
			closeBtn.MouseLeave:Connect(function()
				TweenService:Create(closeBtn, GH.TI, { BackgroundColor3 = Color3.fromRGB(50, 50, 58) }):Play()
			end)
		end

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, persistent and -40 or -14, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = message
		label.TextColor3 = GH.Theme.Text
		label.Font = Enum.Font.GothamMedium
		label.TextSize = 11
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextWrapped = true
		label.ZIndex = 10001
		label.Parent = toast

		TweenService:Create(toast, GH.TI_Slow, {
			Size = UDim2.new(1, 0, 0, 32),
		}):Play()

		local function closeToast()
			if toast and toast.Parent then
				TweenService:Create(toast, GH.TI_Slow, {
					Size = UDim2.new(1, 0, 0, 0),
				}):Play()
				task.delay(0.35, function()
					if toast and toast.Parent then toast:Destroy() end
				end)
			end
		end

		if closeBtn then
			closeBtn.MouseButton1Click:Connect(closeToast)
		end

		if not persistent then
			task.delay(duration or 3, closeToast)
		end
	end)
end

end -- module
