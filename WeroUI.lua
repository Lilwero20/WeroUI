local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Global = (getgenv and getgenv()) or _G
Global.WeroUIInstances = Global.WeroUIInstances or {}

local Theme = {
	Background      = Color3.fromRGB(7, 11, 19),
	Elevated        = Color3.fromRGB(17, 27, 42),
	ElevatedLight   = Color3.fromRGB(31, 47, 70),
	Stroke          = Color3.fromRGB(56, 88, 128),
	Accent          = Color3.fromRGB(28, 152, 235),
	AccentLight     = Color3.fromRGB(132, 208, 252),
	AccentDark      = Color3.fromRGB(14, 96, 158),
	Text            = Color3.fromRGB(250, 252, 255),
	SubText         = Color3.fromRGB(176, 194, 212),
	Success         = Color3.fromRGB(97, 219, 138),
	Warning         = Color3.fromRGB(255, 196, 87),
	Error           = Color3.fromRGB(255, 96, 96),
	Info            = Color3.fromRGB(132, 208, 252),
	Font            = Enum.Font.GothamMedium,
	FontBold        = Enum.Font.GothamBold,
	FontSemibold    = Enum.Font.GothamSemibold,
	CornerRadius    = 24,
	CardRadius      = 10,
}

local ThemePresets = {
	Blue = {
		Background = Color3.fromRGB(7, 11, 19), Elevated = Color3.fromRGB(17, 27, 42),
		ElevatedLight = Color3.fromRGB(31, 47, 70), Stroke = Color3.fromRGB(56, 88, 128),
		Accent = Color3.fromRGB(28, 152, 235), AccentLight = Color3.fromRGB(132, 208, 252),
		AccentDark = Color3.fromRGB(14, 96, 158),
	},
	Purple = {
		Background = Color3.fromRGB(12, 9, 20), Elevated = Color3.fromRGB(24, 19, 38),
		ElevatedLight = Color3.fromRGB(41, 32, 63), Stroke = Color3.fromRGB(84, 68, 128),
		Accent = Color3.fromRGB(147, 97, 235), AccentLight = Color3.fromRGB(200, 172, 252),
		AccentDark = Color3.fromRGB(84, 55, 158),
	},
	Emerald = {
		Background = Color3.fromRGB(6, 16, 13), Elevated = Color3.fromRGB(14, 32, 26),
		ElevatedLight = Color3.fromRGB(24, 54, 44), Stroke = Color3.fromRGB(52, 110, 90),
		Accent = Color3.fromRGB(46, 204, 138), AccentLight = Color3.fromRGB(150, 240, 200),
		AccentDark = Color3.fromRGB(26, 122, 82),
	},
	Crimson = {
		Background = Color3.fromRGB(18, 8, 10), Elevated = Color3.fromRGB(36, 17, 20),
		ElevatedLight = Color3.fromRGB(58, 28, 33), Stroke = Color3.fromRGB(120, 55, 62),
		Accent = Color3.fromRGB(235, 64, 78), AccentLight = Color3.fromRGB(252, 150, 160),
		AccentDark = Color3.fromRGB(150, 35, 46),
	},
	Slate = {
		Background = Color3.fromRGB(10, 10, 12), Elevated = Color3.fromRGB(22, 22, 26),
		ElevatedLight = Color3.fromRGB(38, 38, 44), Stroke = Color3.fromRGB(80, 80, 90),
		Accent = Color3.fromRGB(200, 200, 210), AccentLight = Color3.fromRGB(240, 240, 245),
		AccentDark = Color3.fromRGB(130, 130, 140),
	},
}

local function tween(obj, props, time, style, dir)
	local t = TweenService:Create(
		obj,
		TweenInfo.new(time or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	return inst
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) })
end

local function stroke(color, thickness, transparency)
	return create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function gradient(colorSeq, rotation, transparency)
	return create("UIGradient", {
		Color = colorSeq,
		Rotation = rotation or 90,
		Transparency = transparency,
	})
end

local function pad(top, bottom, left, right)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or top or 0),
		PaddingLeft = UDim.new(0, left or top or 0),
		PaddingRight = UDim.new(0, right or left or top or 0),
	})
end

local function listLayout(direction, gap, alignment)
	return create("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, gap or 6),
		HorizontalAlignment = alignment or Enum.HorizontalAlignment.Left,
	})
end

local function resolveIcon(icon)
	if not icon or icon == 0 or icon == "" then return nil end
	if typeof(icon) == "number" then
		return "rbxassetid://" .. tostring(icon)
	end
	if typeof(icon) == "string" then
		if icon:match("^rbxassetid://") or icon:match("^http") then
			return icon
		end
		return "rbxassetid://" .. icon
	end
	return nil
end

local function getGuiParent()
	local ok, hui = pcall(function()
		return (gethui and gethui()) or nil
	end)
	if ok and hui then return hui end
	if syn and syn.protect_gui then
		return CoreGui
	end
	local ok2, playerGui = pcall(function()
		return LocalPlayer:WaitForChild("PlayerGui")
	end)
	if ok2 then return playerGui end
	return CoreGui
end

local ROTATIONS = { down = 0, up = 180, right = -90, left = 90 }

local function chevronIcon(parent, color, size, direction)
	size = size or 8
	local holder = create("Frame", {
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		Rotation = ROTATIONS[direction] or 0,
		ZIndex = 14,
	})
	create("Frame", {
		Parent = holder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(size * 0.62, 2),
		Position = UDim2.new(0.28, 0, 0.5, 0),
		Rotation = 45,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, { corner(1) })
	create("Frame", {
		Parent = holder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(size * 0.62, 2),
		Position = UDim2.new(0.72, 0, 0.5, 0),
		Rotation = -45,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, { corner(1) })
	return holder
end

local function xIcon(parent, color, size)
	size = size or 12
	local holder = create("Frame", {
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	create("Frame", {
		Parent = holder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 2),
		Rotation = 45,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, { corner(1) })
	create("Frame", {
		Parent = holder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 2),
		Rotation = -45,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, { corner(1) })
	return holder
end

local function minmaxIcon(parent, color, size, isPlus)
	size = size or 12
	local holder = create("Frame", {
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	create("Frame", {
		Parent = holder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, { corner(1) })
	if isPlus then
		create("Frame", {
			Parent = holder,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 2, 1, 0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
		}, { corner(1) })
	end
	return holder
end

local function checkIcon(parent, color, size)
	size = size or 10
	local holder = create("Frame", {
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		ZIndex = 14,
	})
	create("Frame", {
		Parent = holder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(size * 0.36, 1.6),
		Position = UDim2.new(0.26, 0, 0.6, 0),
		Rotation = 45,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, { corner(1) })
	create("Frame", {
		Parent = holder,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(size * 0.64, 1.6),
		Position = UDim2.new(0.62, 0, 0.36, 0),
		Rotation = -45,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, { corner(1) })
	return holder
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return GuiService:GetScreenResolution()
end

local function makeDraggable(dragHandle, target, onStart, onMoved, connBag, clampToScreen)
	local dragging, dragInput, dragStart, startPos, moved

	local function track(conn)
		if connBag then table.insert(connBag, conn) end
		return conn
	end

	track(dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = target.Position
			if onStart then onStart() end
			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if endConn then endConn:Disconnect() end
				end
			end)
		end
	end))

	track(dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	track(UserInputService.InputChanged:Connect(function(input)
		if input ~= dragInput or not dragging then return end
		local rawDelta = input.Position - dragStart
		local delta = typeof(rawDelta) == "Vector3" and Vector2.new(rawDelta.X, rawDelta.Y) or rawDelta
		if delta.Magnitude > 4 and not moved then
			moved = true
			if onMoved then onMoved() end
		end
		target.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
		if clampToScreen ~= false then
			local viewport = getViewportSize()
			local absPos = target.AbsolutePosition
			local absSize = target.AbsoluteSize
			local ax, ay = target.AnchorPoint.X, target.AnchorPoint.Y
			local minX, maxX = -ax * absSize.X, viewport.X - absSize.X * (1 - ax)
			local minY, maxY = -ay * absSize.Y, viewport.Y - absSize.Y * (1 - ay)
			local clampedX = math.clamp(absPos.X, minX, maxX)
			local clampedY = math.clamp(absPos.Y, minY, maxY)
			local correctionX = clampedX - absPos.X
			local correctionY = clampedY - absPos.Y
			if correctionX ~= 0 or correctionY ~= 0 then
				target.Position = UDim2.new(
					target.Position.X.Scale, target.Position.X.Offset + correctionX,
					target.Position.Y.Scale, target.Position.Y.Offset + correctionY
				)
			end
		end
	end))
end

local function makeResizable(grip, target, minSize, maxSize, onResized, connBag)
	local resizing, dragStart, startSize

	local function track(conn)
		if connBag then table.insert(connBag, conn) end
		return conn
	end

	track(grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			dragStart = input.Position
			startSize = target.Size
			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					if endConn then endConn:Disconnect() end
					if onResized then onResized(target.Size) end
				end
			end)
		end
	end))

	track(UserInputService.InputChanged:Connect(function(input)
		if not resizing then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local rawDelta = input.Position - dragStart
		local delta = typeof(rawDelta) == "Vector3" and Vector2.new(rawDelta.X, rawDelta.Y) or rawDelta
		local newW = math.clamp(startSize.X.Offset + delta.X, minSize.X, maxSize.X)
		local newH = math.clamp(startSize.Y.Offset + delta.Y, minSize.Y, maxSize.Y)
		target.Size = UDim2.new(startSize.X.Scale, newW, startSize.Y.Scale, newH)
	end))
end

local WeroUI = {}
WeroUI.__index = WeroUI
WeroUI.Theme = Theme

function WeroUI:UsePreset(name)
	local preset = ThemePresets[name]
	if not preset then
		warn("[WeroUI] Preset '" .. tostring(name) .. "' no existe. Disponibles: Blue, Purple, Emerald, Crimson, Slate")
		return false
	end
	self:SetTheme(preset)
	return true
end

function WeroUI:SetTheme(patch)
	for k, v in pairs(patch or {}) do
		Theme[k] = v
	end
end

function WeroUI:CreateWindow(config)
	config = config or {}
	for _, win in ipairs(table.clone(Global.WeroUIInstances)) do
		pcall(function() win:Destroy() end)
	end
	Global.WeroUIInstances = {}

	local WindowName        = config.Name or "Wero UI"
	local Subtitle          = config.Subtitle or config.LoadingSubtitle or ""
	local WindowIcon        = resolveIcon(config.Icon)
	local ToggleKeybind     = config.ToggleKeybind or Enum.KeyCode.LeftControl
	local WindowSize        = config.Size or UDim2.fromOffset(560, 380)
	local Resizable         = config.Resizable ~= false
	local MinSize           = config.MinSize or Vector2.new(420, 280)
	local MaxSize           = config.MaxSize or Vector2.new(900, 700)
	local ConfigSaving      = config.ConfigurationSaving or {}
	local ConfigFileName    = ConfigSaving.FileName or WindowName:gsub("%s", "_")
	local ConfigFolder      = ConfigSaving.Folder or "WeroUI"

	local Window = setmetatable({}, WeroUI)
	Window.Tabs = {}
	Window.ToggleKeybind = ToggleKeybind
	Window.Open = true
	Window._tabButtons = {}
	Window._connections = {}
	Window._flags = {}

	local ScreenGui = create("ScreenGui", {
		Name = "WeroUI_" .. WindowName:gsub("%s", ""),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
	})
	ScreenGui.Parent = getGuiParent()
	Window.ScreenGui = ScreenGui
	table.insert(Global.WeroUIInstances, Window)

	local DropdownOverlay = create("Frame", {
		Parent = ScreenGui,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 200,
	})

	local Tooltip = create("TextLabel", {
		Parent = ScreenGui,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Theme.Elevated,
		Text = "",
		TextColor3 = Theme.Text,
		Font = Theme.Font,
		TextSize = 12,
		Visible = false,
		ZIndex = 500,
	}, { corner(6), stroke(Theme.Stroke, 1), pad(6, 6, 8, 8) })

	local function attachTooltip(instance, text)
		if not text or text == "" then return end
		table.insert(Window._connections, instance.MouseEnter:Connect(function()
			Tooltip.Text = text
			Tooltip.Visible = true
		end))
		table.insert(Window._connections, instance.MouseLeave:Connect(function()
			Tooltip.Visible = false
		end))
		table.insert(Window._connections, instance.MouseMoved:Connect(function(x, y)
			Tooltip.Position = UDim2.fromOffset(x + 16, y + 16)
		end))
	end

	local openDropdown = nil
	local function closeOpenDropdown()
		if openDropdown then
			openDropdown.list.Visible = false
			openDropdown.backdrop.Visible = false
			openDropdown = nil
		end
	end

	local FloatIcon = create("ImageButton", {
		Name = "FloatIcon",
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(46, 46),
		BackgroundColor3 = Theme.Elevated,
		AutoButtonColor = false,
		Image = "",
		Visible = true,
		ZIndex = 50,
	}, {
		corner(14),
		stroke(Theme.Stroke, 1),
		create("ImageLabel", {
			Name = "Logo",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.62, 0.62),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = WindowIcon or "",
			ImageColor3 = Color3.new(1, 1, 1),
			ScaleType = Enum.ScaleType.Fit,
		}),
	})
	gradient(ColorSequence.new(Theme.ElevatedLight, Theme.Elevated), 90).Parent = FloatIcon
	if not WindowIcon then
		create("TextLabel", {
			Parent = FloatIcon,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "W",
			TextColor3 = Theme.AccentLight,
			Font = Theme.FontBold,
			TextSize = 20,
		})
	end

	local iconMoved = false
	makeDraggable(FloatIcon, FloatIcon,
		function() iconMoved = false end,
		function() iconMoved = true end,
		Window._connections
	)

	local Main = create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.5, -WindowSize.Y.Offset / 2),
		Size = WindowSize,
		BackgroundColor3 = Theme.Background,
		ClipsDescendants = true,
		ZIndex = 10,
	}, {
		corner(Theme.CornerRadius),
		stroke(Theme.Stroke, 1),
	})

	create("UIStroke", {
		Parent = Main,
		Color = Theme.Accent,
		Thickness = 1,
		Transparency = 0.85,
	})

	local TopBar = create("Frame", {
		Name = "TopBar",
		Parent = Main,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Theme.Elevated,
		ZIndex = 11,
	}, { corner(Theme.CornerRadius) })

	local TopBarMask = create("Frame", {
		Parent = TopBar,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 1, -24),
		BackgroundColor3 = Theme.Elevated,
		BorderSizePixel = 0,
		ZIndex = 11,
	})

	local TitleLogo = create("ImageLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(28, 28),
		Position = UDim2.fromOffset(16, 12),
		Image = WindowIcon or "",
		ImageColor3 = Color3.new(1, 1, 1),
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 12,
	})
	if not WindowIcon then
		TitleLogo.BackgroundColor3 = Theme.ElevatedLight
		TitleLogo.BackgroundTransparency = 0
		corner(8).Parent = TitleLogo
		create("TextLabel", {
			Parent = TitleLogo,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "W",
			TextColor3 = Theme.AccentLight,
			Font = Theme.FontBold,
			TextSize = 15,
			ZIndex = 13,
		})
	end

	create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(52, 8),
		Size = UDim2.new(1, -160, 0, 20),
		Text = WindowName,
		TextColor3 = Theme.Text,
		Font = Theme.FontBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12,
	})

	create("TextLabel", {
		Parent = TopBar,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(52, 27),
		Size = UDim2.new(1, -160, 0, 16),
		Text = Subtitle,
		TextColor3 = Theme.SubText,
		Font = Theme.Font,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12,
	})

	local MinBtn = create("TextButton", {
		Parent = TopBar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -48, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.ElevatedLight,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 12,
	}, { corner(8) })
	local MinBtnMinus = minmaxIcon(MinBtn, Theme.SubText, 12, false)
	local MinBtnPlus = minmaxIcon(MinBtn, Theme.SubText, 12, true)
	MinBtnPlus.Visible = false

	local CloseBtn = create("TextButton", {
		Parent = TopBar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.ElevatedLight,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 12,
	}, { corner(8) })
	xIcon(CloseBtn, Theme.SubText, 12)

	makeDraggable(TopBar, Main, closeOpenDropdown, nil, Window._connections)

	local Sidebar = create("Frame", {
		Name = "Sidebar",
		Parent = Main,
		Position = UDim2.new(0, 0, 0, 52),
		Size = UDim2.new(0, 140, 1, -52),
		BackgroundColor3 = Theme.Elevated,
		ZIndex = 11,
	}, {
		create("UICorner", {
			TopLeftRadius = UDim.new(0, 0),
			TopRightRadius = UDim.new(0, 0),
			BottomLeftRadius = UDim.new(0, Theme.CornerRadius),
			BottomRightRadius = UDim.new(0, 0),
		}),
	})

	create("Frame", {
		Parent = Sidebar,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		ZIndex = 11,
	})

	local TabList = create("ScrollingFrame", {
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 11,
	}, {
		pad(10, 10, 10, 10),
		listLayout(Enum.FillDirection.Vertical, 4),
	})

	local ContentArea = create("Frame", {
		Name = "ContentArea",
		Parent = Main,
		Position = UDim2.new(0, 140, 0, 52),
		Size = UDim2.new(1, -140, 1, -52),
		BackgroundTransparency = 1,
		ZIndex = 11,
	})

	local ResizeGrip = nil
	if Resizable then
		ResizeGrip = create("Frame", {
			Parent = Main,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -3, 1, -3),
			Size = UDim2.fromOffset(18, 18),
			BackgroundTransparency = 1,
			ZIndex = 30,
		})
		chevronIcon(ResizeGrip, Theme.Stroke, 10, "left")
		local GripBtn = create("TextButton", {
			Parent = ResizeGrip,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 31,
		})
		-- El grip queda pegado a la esquina de Main pase lo que pase, así
		-- que si la ventana está minimizada (Main achicado a 52px) seguía
		-- siendo arrastrable ahí mismo y forzaba a Main a un tamaño entre
		-- MinSize/MaxSize sin importar el estado minimizado, dejando todo
		-- desincronizado (ver Window:SetMinimized, que ahora lo oculta).
		makeResizable(GripBtn, Main, MinSize, MaxSize, function(newSize)
			WindowSize = UDim2.new(WindowSize.X.Scale, newSize.X.Offset, WindowSize.Y.Scale, newSize.Y.Offset)
		end, Window._connections)
	end

	-- El contenedor se ancla abajo-derecha y su alto se limita a un % de la
	-- pantalla (nunca fijo en 400px), así nunca puede taparlo todo aunque
	-- se acumulen varias notificaciones.
	local NotifyHolder = create("Frame", {
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 300, 0.85, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 100,
	}, {
		listLayout(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Right),
	})
	local nl = NotifyHolder:FindFirstChildOfClass("UIListLayout")
	nl.VerticalAlignment = Enum.VerticalAlignment.Bottom

	local NOTIFY_COLORS = {
		Success = Theme.Success,
		Error = Theme.Error,
		Warning = Theme.Warning,
		Info = Theme.Info,
	}

	local MAX_NOTIFICATIONS = 5
	local MAX_CONTENT_CHARS = 260
	local activeNotifications = {} -- cola FIFO de tarjetas activas

	local function removeNotification(entry, instant)
		if entry.removed then return end
		entry.removed = true
		for i, e in ipairs(activeNotifications) do
			if e == entry then table.remove(activeNotifications, i) break end
		end
		if entry.timerConn then entry.timerConn:Disconnect() end
		if instant then
			entry.card:Destroy()
			return
		end
		local out = tween(entry.slide, {
			Position = UDim2.fromOffset(entry.slide.AbsoluteSize.X + 24, 0),
			BackgroundTransparency = 1,
		}, 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.spawn(function()
			out.Completed:Wait()
			entry.card:Destroy()
		end)
	end

	-- opts.Title, opts.Content, opts.Type ("Success"|"Error"|"Warning"|"Info"),
	-- opts.Duration en segundos (0 o false = se queda hasta cerrarla con la X).
	function Window:Notify(opts)
		opts = opts or {}
		local title = tostring(opts.Title or "Notificación")
		local content = tostring(opts.Content or "")
		if #content > MAX_CONTENT_CHARS then
			content = content:sub(1, MAX_CONTENT_CHARS) .. "..."
		end
		local duration = opts.Duration
		if duration == nil then duration = 4 end
		local sticky = duration == false or duration <= 0
		local accentColor = NOTIFY_COLORS[opts.Type] or Theme.AccentLight

		-- Si ya hay demasiadas notificaciones abiertas, se cierra la más vieja
		-- de inmediato para dejar espacio (evita que se acumulen sin límite).
		while #activeNotifications >= MAX_NOTIFICATIONS do
			removeNotification(activeNotifications[1], true)
		end

		-- Card: elemento administrado por el UIListLayout de NotifyHolder.
		-- Nunca se le toca Position manualmente (eso es lo que rompía la
		-- animación antes); solo su Size, que UIListLayout no controla.
		local Card = create("Frame", {
			Parent = NotifyHolder,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ZIndex = 100,
		})

		-- Slide: el visual real. Está un nivel adentro de Card, así que
		-- animar su Position para el efecto de entrada/salida no compite
		-- con el layout del contenedor.
		local Slide = create("Frame", {
			Parent = Card,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Elevated,
			BackgroundTransparency = 1,
			ZIndex = 100,
			ClipsDescendants = true,
		}, { corner(10), stroke(Theme.Stroke, 1) })

		-- Bloque de texto: SOLO título+contenido viven dentro del
		-- UIListLayout interno. La barra de acento NO participa de ese
		-- layout (antes sí, y su Size Y en Scale (1,0) generaba una
		-- referencia circular con el AutomaticSize del padre, causando que
		-- la tarjeta creciera sin control hasta tapar la pantalla).
		local TextStack = create("Frame", {
			Parent = Slide,
			Position = UDim2.fromOffset(15, 0),
			Size = UDim2.new(1, -15, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ZIndex = 101,
		}, {
			pad(10, 10, 12, 16),
			listLayout(Enum.FillDirection.Vertical, 2),
		})

		local AccentStrip = create("Frame", {
			Parent = Slide,
			Size = UDim2.new(0, 3, 0, 0),
			BackgroundColor3 = accentColor,
			BorderSizePixel = 0,
			ZIndex = 101,
		})
		-- Alto de la barra en offset (px), sincronizado al tamaño real ya
		-- resuelto de Slide, para no depender de un Scale circular.
		local function syncStripHeight()
			AccentStrip.Size = UDim2.new(0, 3, 0, Slide.AbsoluteSize.Y)
		end
		table.insert(Window._connections, Slide:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncStripHeight))
		task.defer(syncStripHeight)

		create("TextLabel", {
			Parent = TextStack, LayoutOrder = 1, BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 0, 18), Text = title,
			Font = Theme.FontBold, TextSize = 13, TextColor3 = accentColor,
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 102,
		})
		create("TextLabel", {
			Parent = TextStack, LayoutOrder = 2, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Text = content, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 102,
		})

		local entry = { card = Card, slide = Slide, removed = false }

		local CloseBtn = create("TextButton", {
			Parent = Slide,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -6, 0, 6),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 103,
		})
		xIcon(CloseBtn, Theme.SubText, 9)
		CloseBtn.MouseButton1Click:Connect(function() removeNotification(entry, false) end)

		local ProgressBar
		if not sticky then
			local ProgressTrack = create("Frame", {
				Parent = Slide,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 15, 1, 0),
				Size = UDim2.new(1, -15, 0, 2),
				BackgroundColor3 = Theme.ElevatedLight,
				BorderSizePixel = 0,
				ZIndex = 102,
			})
			ProgressBar = create("Frame", {
				Parent = ProgressTrack,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = accentColor,
				BorderSizePixel = 0,
				ZIndex = 103,
			})
		end

		table.insert(activeNotifications, entry)

		local slideX = math.max(NotifyHolder.AbsoluteSize.X, 8) + 24
		Slide.Position = UDim2.fromOffset(slideX, 0)
		tween(Slide, {
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 0,
		}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		if not sticky then
			if ProgressBar then
				tween(ProgressBar, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)
			end
			task.spawn(function()
				task.wait(duration)
				removeNotification(entry, false)
			end)
		end
	end

	-- Cierra todas las notificaciones visibles al instante.
	function Window:ClearNotifications()
		for _, entry in ipairs(table.clone(activeNotifications)) do
			removeNotification(entry, true)
		end
	end

	Main.Visible = true
	Window.Minimized = false
	local MINIMIZED_HEIGHT = 52

	function Window:SetOpen(state)
		Window.Open = state
		if state then
			Main.Visible = true
			if Window.Minimized then
				Main.Size = UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, MINIMIZED_HEIGHT)
			else
				Main.Size = UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, 0)
				tween(Main, { Size = WindowSize }, 0.25)
			end
		else
			closeOpenDropdown()
			local closing = tween(Main, { Size = UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, 0) }, 0.2)
			closing.Completed:Connect(function()
				if not Window.Open then
					Main.Visible = false
				end
			end)
		end
	end

	function Window:SetMinimized(state)
		if not Window.Open then return end
		Window.Minimized = state
		closeOpenDropdown()
		TopBarMask.Visible = not state
		MinBtnMinus.Visible = not state
		MinBtnPlus.Visible = state
		-- No basta con encoger Main y confiar en ClipsDescendants: durante el
		-- tween, el recorte no siempre acompaña el cambio de tamaño a tiempo
		-- (sobre todo con el ScrollingFrame de tabs, que tiene
		-- AutomaticCanvasSize), y botones/íconos del contenido quedan
		-- "flotando" visibles fuera de la barra minimizada. Por eso además
		-- ocultamos Sidebar/ContentArea explícitamente.
		if state then
			Sidebar.Visible = false
			ContentArea.Visible = false
			Main.Size = WindowSize
			tween(Main, { Size = UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, MINIMIZED_HEIGHT) }, 0.2)
		else
			Main.Size = UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, MINIMIZED_HEIGHT)
			tween(Main, { Size = WindowSize }, 0.2)
			Sidebar.Visible = true
			ContentArea.Visible = true
		end
	end

	function Window:Toggle()
		Window:SetOpen(not Window.Open)
	end

	function Window:SetAccentColor(color)
		Theme.Accent = color
		Theme.AccentLight = Color3.new(
			math.min(color.R + 0.4, 1),
			math.min(color.G + 0.4, 1),
			math.min(color.B + 0.4, 1)
		)
		Theme.AccentDark = Color3.new(color.R * 0.55, color.G * 0.55, color.B * 0.55)
	end

	-- Diálogo modal de confirmación.
	-- opts = { Title, Content, ConfirmText, CancelText, ShowCancel }
	-- Devuelve un booleano vía opts.Callback(confirmed) y también acepta
	-- yield: `if Window:Prompt({...}) then ... end` (bloquea la coroutine
	-- actual hasta que el usuario responde).
	function Window:Prompt(opts)
		opts = opts or {}
		local co = coroutine.running()
		local resultGiven = false

		local Backdrop = create("TextButton", {
			Parent = DropdownOverlay, Text = "", AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.5, ZIndex = 400,
		})
		local Box = create("Frame", {
			Parent = DropdownOverlay,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Elevated,
			ZIndex = 401,
		}, { corner(12), stroke(Theme.Stroke, 1), pad(18, 18, 18, 18), listLayout(Enum.FillDirection.Vertical, 10) })
		create("TextLabel", {
			Parent = Box, LayoutOrder = 1, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20), Text = opts.Title or "¿Confirmar?",
			Font = Theme.FontBold, TextSize = 15, TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 402,
		})
		if opts.Content and opts.Content ~= "" then
			create("TextLabel", {
				Parent = Box, LayoutOrder = 2, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				Text = opts.Content, Font = Theme.Font, TextSize = 12.5, TextColor3 = Theme.SubText,
				TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 402,
			})
		end
		local BtnRow = create("Frame", {
			Parent = Box, LayoutOrder = 3, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32), ZIndex = 402,
		}, { listLayout(Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right) })

		local function finish(confirmed)
			if resultGiven then return end
			resultGiven = true
			Backdrop:Destroy()
			Box:Destroy()
			if opts.Callback then task.spawn(opts.Callback, confirmed) end
			if co then
				local ok = coroutine.resume(co, confirmed)
				if not ok then end
			end
		end
		Backdrop.MouseButton1Click:Connect(function() finish(false) end)

		if opts.ShowCancel ~= false then
			local CancelBtn = create("TextButton", {
				Parent = BtnRow, Size = UDim2.fromOffset(90, 32),
				BackgroundColor3 = Theme.ElevatedLight, AutoButtonColor = false,
				Text = opts.CancelText or "Cancelar", Font = Theme.FontSemibold,
				TextSize = 13, TextColor3 = Theme.SubText, ZIndex = 403,
			}, { corner(8) })
			CancelBtn.MouseButton1Click:Connect(function() finish(false) end)
		end
		local ConfirmBtn = create("TextButton", {
			Parent = BtnRow, Size = UDim2.fromOffset(90, 32),
			BackgroundColor3 = Theme.Accent, AutoButtonColor = false,
			Text = opts.ConfirmText or "Aceptar", Font = Theme.FontSemibold,
			TextSize = 13, TextColor3 = Theme.Text, ZIndex = 403,
		}, { corner(8) })
		ConfirmBtn.MouseButton1Click:Connect(function() finish(true) end)

		if co and coroutine.status(co) == "running" then
			return coroutine.yield()
		end
	end

	function Window:SaveConfig()
		if not (writefile and isfile) then return false end
		local ok = pcall(function()
			if makefolder and not (isfolder and isfolder(ConfigFolder)) then
				makefolder(ConfigFolder)
			end
		end)
		local data = {}
		for flag, api in pairs(Window._flags) do
			data[flag] = api.Value
		end
		local ok2, encoded = pcall(function() return HttpService:JSONEncode(data) end)
		if not ok2 then return false end
		local path = ConfigFolder .. "/" .. ConfigFileName .. ".json"
		local ok3 = pcall(writefile, path, encoded)
		return ok3
	end

	function Window:LoadConfig()
		if not (readfile and isfile) then return false end
		local path = ConfigFolder .. "/" .. ConfigFileName .. ".json"
		local ok, exists = pcall(isfile, path)
		if not ok or not exists then return false end
		local ok2, raw = pcall(readfile, path)
		if not ok2 then return false end
		local ok3, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok3 or typeof(data) ~= "table" then return false end
		for flag, value in pairs(data) do
			local api = Window._flags[flag]
			if api and api.Set then
				pcall(api.Set, api, value)
			end
		end
		return true
	end

	CloseBtn.MouseButton1Click:Connect(function()
		Window:SetOpen(false)
	end)
	CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, { BackgroundColor3 = Theme.Error }, 0.15) end)
	CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, { BackgroundColor3 = Theme.ElevatedLight }, 0.15) end)

	MinBtn.MouseButton1Click:Connect(function()
		Window:SetMinimized(not Window.Minimized)
	end)
	MinBtn.MouseEnter:Connect(function() tween(MinBtn, { BackgroundColor3 = Theme.Accent }, 0.15) end)
	MinBtn.MouseLeave:Connect(function() tween(MinBtn, { BackgroundColor3 = Theme.ElevatedLight }, 0.15) end)

	FloatIcon.MouseButton1Click:Connect(function()
		if iconMoved then return end
		Window:Toggle()
	end)
	FloatIcon.MouseEnter:Connect(function() tween(FloatIcon, { BackgroundColor3 = Theme.ElevatedLight }, 0.15) end)
	FloatIcon.MouseLeave:Connect(function() tween(FloatIcon, { BackgroundColor3 = Theme.Elevated }, 0.15) end)

	function Window:SetToggleKeybind(keycode)
		Window.ToggleKeybind = keycode
	end

	table.insert(Window._connections, UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Window.ToggleKeybind then
			Window:Toggle()
		end
	end))

	function Window:CreateTab(name, icon)
		icon = resolveIcon(icon)
		local isFirst = #Window.Tabs == 0

		local TabButton = create("TextButton", {
			Parent = TabList,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = isFirst and Theme.ElevatedLight or Theme.Elevated,
			BackgroundTransparency = isFirst and 0 or 1,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 12,
		}, { corner(8) })

		local IconLabel
		if icon then
			IconLabel = create("ImageLabel", {
				Parent = TabButton,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(10, 8),
				Size = UDim2.fromOffset(18, 18),
				Image = icon,
				ImageColor3 = isFirst and Theme.AccentLight or Theme.SubText,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 13,
			})
		end

		local TabLabel = create("TextLabel", {
			Parent = TabButton,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(icon and 34 or 12, 0),
			Size = UDim2.new(1, icon and -40 or -20, 1, 0),
			Text = name,
			Font = Theme.FontSemibold,
			TextSize = 13,
			TextColor3 = isFirst and Theme.Text or Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 13,
		})

		local Page = create("ScrollingFrame", {
			Parent = ContentArea,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Visible = isFirst,
			ZIndex = 11,
		}, {
			pad(14, 14, 14, 14),
			listLayout(Enum.FillDirection.Vertical, 8),
		})

		local Tab = { Button = TabButton, Page = Page }
		table.insert(Window.Tabs, Tab)

		local function selectTab()
			for _, t in ipairs(Window.Tabs) do
				t.Page.Visible = (t == Tab)
				tween(t.Button, {
					BackgroundTransparency = (t == Tab) and 0 or 1,
					BackgroundColor3 = Theme.ElevatedLight,
				}, 0.15)
				local lbl = t.Button:FindFirstChildOfClass("TextLabel")
				if lbl then lbl.TextColor3 = (t == Tab) and Theme.Text or Theme.SubText end
				local ic = t.Button:FindFirstChildOfClass("ImageLabel")
				if ic then ic.ImageColor3 = (t == Tab) and Theme.AccentLight or Theme.SubText end
			end
		end
		TabButton.MouseButton1Click:Connect(selectTab)

		-- autoGrow = true: la card crece en alto si su contenido (p. ej. una
		-- descripción larga en varias líneas) no entra en "height". Se usa
		-- en Botón/Toggle, que pueden tener Description opcional.
		local function baseCard(height, autoGrow)
			return create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, 0, 0, height or 40),
				AutomaticSize = autoGrow and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
				BackgroundColor3 = Theme.Elevated,
				ZIndex = 12,
			}, { corner(Theme.CardRadius), stroke(Theme.Stroke, 1), pad(10, 10, 12, 12) })
		end

		-- Bloque de nombre + descripción opcional. "holder" mide su alto
		-- según su propio contenido (AutomaticSize) y se centra verticalmente
		-- dentro de la card con AnchorPoint, así que si la card crece (ver
		-- baseCard autoGrow) el bloque de texto crece con ella en vez de
		-- quedar recortado a un % fijo de una altura fija.
		local function nameSub(parent, nameText, descText)
			local holder = create("Frame", {
				Parent = parent,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, -50, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				ZIndex = 13,
			}, { listLayout(Enum.FillDirection.Vertical, 2) })
			create("TextLabel", {
				Parent = holder, LayoutOrder = 1, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Text = nameText, Font = Theme.FontSemibold, TextSize = 13,
				TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 14,
			})
			if descText and descText ~= "" then
				create("TextLabel", {
					Parent = holder, LayoutOrder = 2, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
					Text = descText, Font = Theme.Font, TextSize = 11,
					TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, ZIndex = 14,
				})
			end
			return holder
		end

		local function registerFlag(opts, api)
			if opts.Flag then
				Window._flags[opts.Flag] = api
			end
		end

		local function autosave()
			if ConfigSaving.Enabled then
				task.defer(function() Window:SaveConfig() end)
			end
		end

		function Tab:CreateSection(text)
			create("TextLabel", {
				Parent = Page,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 22),
				Text = text:upper(),
				Font = Theme.FontBold,
				TextSize = 11,
				TextColor3 = Theme.AccentLight,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 12,
			})
		end

		function Tab:CreateLabel(text)
			local card = baseCard(36)
			create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Text = text, Font = Theme.Font, TextSize = 13,
				TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true, ZIndex = 13,
			})
			return card
		end

		function Tab:CreateParagraph(opts)
			opts = opts or {}
			local card = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Elevated,
				ZIndex = 12,
			}, { corner(Theme.CardRadius), stroke(Theme.Stroke, 1), pad(10, 10, 12, 12), listLayout(Enum.FillDirection.Vertical, 4) })

			create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18), Text = opts.Title or "",
				Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
			})
			local content = create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				Text = opts.Content or "", Font = Theme.Font, TextSize = 12,
				TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true, ZIndex = 13,
			})
			local api = {}
			function api:SetDescription(txt)
				content.Text = txt or ""
			end
			function api:Set(txt) api:SetDescription(txt) end
			return api
		end

		-- opts = { Image, Title, Height (default 160), ScaleType }
		function Tab:CreateImage(opts)
			opts = opts or {}
			local height = opts.Height or 160
			local card = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Elevated,
				ZIndex = 12,
			}, { corner(Theme.CardRadius), stroke(Theme.Stroke, 1), pad(10, 10, 10, 10), listLayout(Enum.FillDirection.Vertical, 6) })

			if opts.Title and opts.Title ~= "" then
				create("TextLabel", {
					Parent = card, LayoutOrder = 1, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18), Text = opts.Title,
					Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
				})
			end
			local ImageFrame = create("ImageLabel", {
				Parent = card, LayoutOrder = 2, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, height),
				Image = resolveIcon(opts.Image) or "",
				ScaleType = opts.ScaleType or Enum.ScaleType.Fit,
				ZIndex = 13,
			}, { corner(6) })

			local api = {}
			function api:SetImage(img) ImageFrame.Image = resolveIcon(img) or "" end
			return api
		end

		function Tab:CreateDivider()
			create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
				ZIndex = 12,
			})
		end

		function Tab:CreateButton(opts)
			opts = opts or {}
			local card = baseCard(opts.Description and 50 or 40, true)
			nameSub(card, opts.Name or "Botón", opts.Description)

			local Btn = create("TextButton", {
				Parent = card,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(34, 26),
				BackgroundColor3 = Theme.Accent,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 13,
			}, { corner(7) })
			chevronIcon(Btn, Color3.new(1, 1, 1), 10, "right")
			attachTooltip(Btn, opts.Tooltip)

			Btn.MouseButton1Click:Connect(function()
				tween(Btn, { BackgroundColor3 = Theme.AccentDark }, 0.08)
				task.wait(0.08)
				tween(Btn, { BackgroundColor3 = Theme.Accent }, 0.15)
				local ok, err = pcall(opts.Callback or function() end)
				if not ok then warn("[WeroUI] Button callback error: " .. tostring(err)) end
			end)
			return { Instance = card }
		end

		function Tab:CreateToggle(opts)
			opts = opts or {}
			local state = opts.CurrentValue or false
			local card = baseCard(opts.Description and 50 or 40, true)
			nameSub(card, opts.Name or "Toggle", opts.Description)
			attachTooltip(card, opts.Tooltip)

			local Switch = create("Frame", {
				Parent = card,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(40, 22),
				BackgroundColor3 = state and Theme.Accent or Theme.ElevatedLight,
				ZIndex = 13,
			}, { corner(11), stroke(Theme.Stroke, 1) })

			local Knob = create("Frame", {
				Parent = Switch,
				Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromOffset(16, 16),
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 14,
			}, { corner(8) })

			local Click = create("TextButton", {
				Parent = Switch, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 15,
			})

			local api = { Value = state }
			function api:Set(value)
				state = value
				api.Value = value
				tween(Switch, { BackgroundColor3 = state and Theme.Accent or Theme.ElevatedLight }, 0.15)
				tween(Knob, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, 0.15)
				local ok, err = pcall(opts.Callback or function() end, state)
				if not ok then warn("[WeroUI] Toggle callback error: " .. tostring(err)) end
				autosave()
			end

			Click.MouseButton1Click:Connect(function() api:Set(not state) end)
			registerFlag(opts, api)
			if opts.CurrentValue then
				task.defer(function() pcall(opts.Callback or function() end, state) end)
			end
			return api
		end

		function Tab:CreateSlider(opts)
			opts = opts or {}
			local min = (opts.Range and opts.Range[1]) or 0
			local max = (opts.Range and opts.Range[2]) or 100
			local inc = opts.Increment or 1
			local value = opts.CurrentValue or min

			local card = baseCard(56)
			attachTooltip(card, opts.Tooltip)
			create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				Size = UDim2.new(1, -50, 0, 18),
				Text = opts.Name or "Slider", Font = Theme.FontSemibold, TextSize = 13,
				TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
			})
			local ValueLabel = create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.fromOffset(50, 18),
				Text = tostring(value) .. (opts.Suffix or ""), Font = Theme.FontSemibold, TextSize = 13,
				TextColor3 = Theme.AccentLight, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
			})

			local Track = create("Frame", {
				Parent = card,
				Position = UDim2.new(0, 0, 0, 30),
				Size = UDim2.new(1, 0, 0, 8),
				BackgroundColor3 = Theme.ElevatedLight,
				ZIndex = 13,
			}, { corner(4) })

			local pct = (value - min) / math.max(max - min, 1e-6)
			local Fill = create("Frame", {
				Parent = Track,
				Size = UDim2.new(pct, 0, 1, 0),
				BackgroundColor3 = Theme.Accent,
				ZIndex = 14,
			}, { corner(4) })
			gradient(ColorSequence.new(Theme.AccentLight, Theme.Accent), 0).Parent = Fill

			local Grabber = create("Frame", {
				Parent = Track,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(pct, 0, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 15,
			}, { corner(7) })

			local api = { Value = value }
			local dragging = false

			local function setFromAlpha(alpha)
				alpha = math.clamp(alpha, 0, 1)
				local raw = min + (max - min) * alpha
				raw = math.floor(raw / inc + 0.5) * inc
				raw = math.clamp(raw, min, max)
				api.Value = raw
				local a = (raw - min) / math.max(max - min, 1e-6)
				Fill.Size = UDim2.new(a, 0, 1, 0)
				Grabber.Position = UDim2.new(a, 0, 0.5, 0)
				ValueLabel.Text = tostring(raw) .. (opts.Suffix or "")
				local ok, err = pcall(opts.Callback or function() end, raw)
				if not ok then warn("[WeroUI] Slider callback error: " .. tostring(err)) end
				autosave()
			end

			table.insert(Window._connections, Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					setFromAlpha((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X)
				end
			end))
			table.insert(Window._connections, UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end))
			table.insert(Window._connections, UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					setFromAlpha((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X)
				end
			end))

			function api:Set(v) setFromAlpha((v - min) / math.max(max - min, 1e-6)) end
			registerFlag(opts, api)
			return api
		end

		function Tab:CreateProgressBar(opts)
			opts = opts or {}
			local min = (opts.Range and opts.Range[1]) or 0
			local max = (opts.Range and opts.Range[2]) or 100
			local value = math.clamp(opts.CurrentValue or min, min, max)

			local card = baseCard(48)
			create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				Size = UDim2.new(1, -50, 0, 18),
				Text = opts.Name or "Progreso", Font = Theme.FontSemibold, TextSize = 13,
				TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
			})
			local ValueLabel = create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.fromOffset(50, 18),
				Text = "", Font = Theme.FontSemibold, TextSize = 12,
				TextColor3 = Theme.AccentLight, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 13,
			})
			local Track = create("Frame", {
				Parent = card,
				Position = UDim2.new(0, 0, 0, 26),
				Size = UDim2.new(1, 0, 0, 8),
				BackgroundColor3 = Theme.ElevatedLight,
				ZIndex = 13,
			}, { corner(4) })
			local Fill = create("Frame", {
				Parent = Track,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Theme.Accent,
				ZIndex = 14,
			}, { corner(4) })
			gradient(ColorSequence.new(Theme.AccentLight, Theme.Accent), 0).Parent = Fill

			local api = { Value = value }
			function api:Set(v)
				v = math.clamp(v, min, max)
				api.Value = v
				local a = (v - min) / math.max(max - min, 1e-6)
				tween(Fill, { Size = UDim2.new(a, 0, 1, 0) }, 0.2)
				ValueLabel.Text = math.floor((v - min) / math.max(max - min, 1e-6) * 100) .. "%"
			end
			api:Set(value)
			return api
		end

		function Tab:CreateDropdown(opts)
			opts = opts or {}
			local options = opts.Options or {}
			local multi = opts.MultipleOptions or false
			local searchable = opts.Searchable or false
			-- Por defecto: los de selección simple se cierran al elegir, los
			-- multi-selección se quedan abiertos (como antes). Se puede forzar
			-- con opts.CloseOnSelect = true/false en cualquiera de los dos casos.
			local closeOnSelect = opts.CloseOnSelect
			if closeOnSelect == nil then closeOnSelect = not multi end
			local selected = {}
			if multi then
				for _, v in ipairs(opts.CurrentOption or {}) do selected[v] = true end
			else
				selected[opts.CurrentOption or options[1] or ""] = true
			end

			local card = baseCard(40)
			nameSub(card, opts.Name or "Dropdown", nil)
			attachTooltip(card, opts.Tooltip)

			local DisplayBtn = create("TextButton", {
				Parent = card,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(150, 28),
				BackgroundColor3 = Theme.ElevatedLight,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 13,
			}, { corner(7), stroke(Theme.Stroke, 1) })

			DisplayBtn.MouseEnter:Connect(function()
				tween(DisplayBtn, { BackgroundColor3 = Theme.Stroke }, 0.12)
			end)
			DisplayBtn.MouseLeave:Connect(function()
				tween(DisplayBtn, { BackgroundColor3 = Theme.ElevatedLight }, 0.12)
			end)

			-- Recorremos "options" (no "selected") para que el orden mostrado sea
			-- estable y para que las selecciones que ya no existen (tras un Refresh)
			-- no se queden "fantasma" en el texto.
			local function currentText()
				local list = {}
				for _, optName in ipairs(options) do
					if selected[optName] then table.insert(list, optName) end
				end
				if #list == 0 then return "Seleccionar..." end
				return table.concat(list, ", ")
			end

			local DisplayLabel = create("TextLabel", {
				Parent = DisplayBtn, BackgroundTransparency = 1,
				Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(8, 0),
				Text = currentText(), Font = Theme.Font, TextSize = 12,
				TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14,
			})
			local ArrowHolder = create("Frame", {
				Parent = DisplayBtn,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundTransparency = 1,
				ZIndex = 14,
			})
			local Arrow = chevronIcon(ArrowHolder, Theme.SubText, 9, "down")

			local OPTION_H = 27
			local OPTION_GAP = 4
			local OPTION_PAD = 8
			-- Cuántas opciones se ven sin necesidad de hacer scroll. Con más
			-- opciones que esto, la lista se vuelve scrolleable automáticamente.
			local MAX_VISIBLE_OPTIONS = opts.MaxVisibleOptions or 5
			local SEARCH_H = searchable and 34 or 0
			local EMPTY_H = 26

			local ListFrame = create("Frame", {
				Parent = DropdownOverlay,
				Size = UDim2.new(0, 150, 0, SEARCH_H + OPTION_PAD),
				BackgroundColor3 = Theme.ElevatedLight,
				BorderSizePixel = 0,
				Visible = false,
				ClipsDescendants = true,
				ZIndex = 300,
			}, { corner(8), stroke(Theme.Stroke, 1) })

			local SearchBox
			if searchable then
				SearchBox = create("TextBox", {
					Parent = ListFrame,
					Position = UDim2.fromOffset(4, 4),
					Size = UDim2.new(1, -8, 0, 26),
					BackgroundColor3 = Theme.Elevated,
					PlaceholderText = "Buscar...",
					PlaceholderColor3 = Theme.SubText,
					Text = "",
					TextColor3 = Theme.Text,
					Font = Theme.Font,
					TextSize = 12,
					ClearTextOnFocus = false,
					ZIndex = 302,
				}, { corner(6), pad(0, 0, 8, 8) })
			end

			-- IMPORTANTE: este ScrollingFrame es el que permite hacer scroll
			-- cuando hay más opciones de las que caben. AutomaticCanvasSize ya
			-- calcula bien el área scrolleable en base al contenido real; el bug
			-- original era que el ListFrame (el contenedor visible de afuera)
			-- tenía una altura FIJA calculada una sola vez al crear el dropdown,
			-- así que si luego cambiaban las opciones (Refresh) o se filtraba con
			-- la búsqueda, el área visible se quedaba con el tamaño viejo (a
			-- veces minúsculo) aunque por dentro sí hubiera más opciones para
			-- scrollear. Ahora resizeList() recalcula y anima esa altura cada
			-- vez que cambia la cantidad de opciones visibles.
			local OptionsScroll = create("ScrollingFrame", {
				Parent = ListFrame,
				Position = UDim2.fromOffset(0, SEARCH_H),
				Size = UDim2.new(1, 0, 1, -SEARCH_H),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.Accent,
				ScrollBarImageTransparency = 0.2,
				ElasticBehavior = Enum.ElasticBehavior.Never,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 301,
			}, { pad(4, 4, 4, 4), listLayout(Enum.FillDirection.Vertical, OPTION_GAP) })

			local EmptyLabel = create("TextLabel", {
				Parent = OptionsScroll,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, EMPTY_H),
				Text = "Sin opciones",
				Font = Theme.Font,
				TextSize = 12,
				TextColor3 = Theme.SubText,
				Visible = false,
				ZIndex = 302,
			})

			local Backdrop = create("TextButton", {
				Parent = DropdownOverlay,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				Visible = false,
				ZIndex = 299,
			})

			local function resizeList(shownCount, animate)
				local height
				if shownCount <= 0 then
					height = SEARCH_H + OPTION_PAD + EMPTY_H
				else
					local visible = math.min(shownCount, MAX_VISIBLE_OPTIONS)
					height = SEARCH_H + OPTION_PAD + visible * OPTION_H + math.max(visible - 1, 0) * OPTION_GAP
				end
				local target = UDim2.new(0, 150, 0, height)
				if animate and ListFrame.Visible then
					tween(ListFrame, { Size = target }, 0.16, Enum.EasingStyle.Quart)
				else
					ListFrame.Size = target
				end
			end

			local function hideList()
				ListFrame.Visible = false
				Backdrop.Visible = false
				tween(Arrow, { Rotation = 0 }, 0.16)
				if openDropdown and openDropdown.list == ListFrame then openDropdown = nil end
			end
			Backdrop.MouseButton1Click:Connect(hideList)

			local function showList()
				closeOpenDropdown()
				openDropdown = { list = ListFrame, backdrop = Backdrop }

				local targetSize = ListFrame.Size
				local h = targetSize.Y.Offset

				local btnAbs = DisplayBtn.AbsolutePosition
				local overAbs = DropdownOverlay.AbsolutePosition
				local x = btnAbs.X - overAbs.X
				local y = btnAbs.Y + DisplayBtn.AbsoluteSize.Y + 6 - overAbs.Y
				local opensUp = false
				if y + h > DropdownOverlay.AbsoluteSize.Y then
					y = btnAbs.Y - h - 6 - overAbs.Y
					opensUp = true
				end

				ListFrame.Position = UDim2.fromOffset(x, opensUp and (y + h) or y)
				ListFrame.Size = UDim2.new(targetSize.X.Scale, targetSize.X.Offset, 0, 0)
				ListFrame.Visible = true
				Backdrop.Visible = true
				tween(Arrow, { Rotation = 180 }, 0.16)
				tween(ListFrame, { Size = targetSize }, 0.18, Enum.EasingStyle.Quart)
				if opensUp then
					tween(ListFrame, { Position = UDim2.fromOffset(x, y) }, 0.18, Enum.EasingStyle.Quart)
				end
				if SearchBox then
					SearchBox.Text = ""
					task.defer(function() SearchBox:CaptureFocus() end)
				end
			end

			local api = { Value = multi and selected or (opts.CurrentOption or options[1] or "") }

			local function refreshOptions(filter)
				for _, c in ipairs(OptionsScroll:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				local shown = 0
				for _, optName in ipairs(options) do
					if not filter or filter == "" or optName:lower():find(filter:lower(), 1, true) then
						shown += 1
						local isSelected = selected[optName] and true or false
						local OptBtn = create("TextButton", {
							Parent = OptionsScroll,
							Size = UDim2.new(1, 0, 0, OPTION_H),
							BackgroundColor3 = isSelected and Theme.Accent or Theme.Elevated,
							BackgroundTransparency = isSelected and 0.55 or 1,
							Text = "",
							AutoButtonColor = false,
							ZIndex = 302,
						}, { corner(6) })

						create("TextLabel", {
							Parent = OptBtn,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, isSelected and -26 or -12, 1, 0),
							Position = UDim2.fromOffset(8, 0),
							Text = optName,
							Font = Theme.Font,
							TextSize = 12,
							TextColor3 = isSelected and Theme.AccentLight or Theme.Text,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextTruncate = Enum.TextTruncate.AtEnd,
							ZIndex = 303,
						})

						if isSelected then
							local CheckHolder = create("Frame", {
								Parent = OptBtn,
								AnchorPoint = Vector2.new(1, 0.5),
								Position = UDim2.new(1, -8, 0.5, 0),
								Size = UDim2.fromOffset(10, 10),
								BackgroundTransparency = 1,
								ZIndex = 303,
							})
							checkIcon(CheckHolder, Theme.AccentLight, 10)
						end

						OptBtn.MouseEnter:Connect(function()
							if not isSelected then
								tween(OptBtn, { BackgroundTransparency = 0.75 }, 0.12)
							end
						end)
						OptBtn.MouseLeave:Connect(function()
							if not isSelected then
								tween(OptBtn, { BackgroundTransparency = 1 }, 0.12)
							end
						end)

						OptBtn.MouseButton1Click:Connect(function()
							if multi then
								selected[optName] = not selected[optName]
								api.Value = selected
							else
								selected = { [optName] = true }
								api.Value = optName
							end
							if closeOnSelect then hideList() end
							DisplayLabel.Text = currentText()
							refreshOptions(SearchBox and SearchBox.Text or nil)
							local ok, err = pcall(opts.Callback or function() end, api.Value)
							if not ok then warn("[WeroUI] Dropdown callback error: " .. tostring(err)) end
							autosave()
						end)
					end
				end
				EmptyLabel.Text = (#options == 0) and "Sin opciones" or "Sin resultados"
				EmptyLabel.Visible = (shown == 0)
				resizeList(shown, true)
				return shown
			end
			refreshOptions() -- ya deja ListFrame con el tamaño correcto (sin animar, porque aún no es visible)

			if SearchBox then
				SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
					refreshOptions(SearchBox.Text)
				end)
			end

			DisplayBtn.MouseButton1Click:Connect(function()
				if ListFrame.Visible then
					hideList()
				else
					showList()
				end
			end)

			function api:Refresh(newOptions)
				options = newOptions or {}
				-- Limpiamos selecciones que ya no existen en la nueva lista para
				-- que no queden seleccionadas "a ciegas" opciones eliminadas.
				if multi then
					for k in pairs(selected) do
						if not table.find(options, k) then selected[k] = nil end
					end
				else
					local current = next(selected)
					if current and not table.find(options, current) then
						selected = {}
					end
				end
				DisplayLabel.Text = currentText()
				refreshOptions(SearchBox and SearchBox.Text or nil)
			end
			api.Reload = api.Refresh

			function api:Set(optName)
				if multi then
					for k in pairs(selected) do selected[k] = nil end
					selected[optName] = true
				else
					selected = { [optName] = true }
				end
				api.Value = multi and selected or optName
				DisplayLabel.Text = currentText()
				refreshOptions(SearchBox and SearchBox.Text or nil)
				local ok, err = pcall(opts.Callback or function() end, api.Value)
				if not ok then warn("[WeroUI] Dropdown Set callback error: " .. tostring(err)) end
			end

			registerFlag(opts, api)
			return api
		end

		function Tab:CreateInput(opts)
			opts = opts or {}
			local card = baseCard(40)
			nameSub(card, opts.Name or "Input", nil)
			attachTooltip(card, opts.Tooltip)

			local Box = create("TextBox", {
				Parent = card,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(150, 28),
				BackgroundColor3 = Theme.ElevatedLight,
				PlaceholderText = opts.PlaceholderText or "Escribe...",
				PlaceholderColor3 = Theme.SubText,
				Text = opts.CurrentValue or "",
				TextColor3 = Theme.Text,
				Font = Theme.Font,
				TextSize = 12,
				ClearTextOnFocus = false,
				ZIndex = 13,
			}, { corner(7), stroke(Theme.Stroke, 1), pad(0, 0, 8, 8) })

			local api = { Value = opts.CurrentValue or "" }
			Box.FocusLost:Connect(function(enterPressed)
				api.Value = Box.Text
				local ok, err = pcall(opts.Callback or function() end, Box.Text, enterPressed)
				if not ok then warn("[WeroUI] Input callback error: " .. tostring(err)) end
				autosave()
			end)
			function api:Set(text) Box.Text = text; api.Value = text end
			registerFlag(opts, api)
			return api
		end

		function Tab:CreateKeybind(opts)
			opts = opts or {}
			local currentKey = opts.CurrentKeybind
			if typeof(currentKey) == "string" then
				currentKey = Enum.KeyCode[currentKey] or Enum.KeyCode.F
			end
			currentKey = currentKey or Enum.KeyCode.F
			local listening = false

			local card = baseCard(40)
			nameSub(card, opts.Name or "Keybind", nil)
			attachTooltip(card, opts.Tooltip)

			local KeyBtn = create("TextButton", {
				Parent = card,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(90, 28),
				BackgroundColor3 = Theme.ElevatedLight,
				Text = currentKey.Name,
				TextColor3 = Theme.Text,
				Font = Theme.FontSemibold,
				TextSize = 12,
				AutoButtonColor = false,
				ZIndex = 13,
			}, { corner(7), stroke(Theme.Stroke, 1) })

			local api = { Value = currentKey.Name }

			KeyBtn.MouseButton1Click:Connect(function()
				listening = true
				KeyBtn.Text = "..."
				tween(KeyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
			end)

			table.insert(Window._connections, UserInputService.InputBegan:Connect(function(input, processed)
				if processed then return end
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				if listening then
					currentKey = input.KeyCode
					api.Value = currentKey.Name
					KeyBtn.Text = currentKey.Name
					listening = false
					tween(KeyBtn, { BackgroundColor3 = Theme.ElevatedLight }, 0.15)
					local ok, err = pcall(opts.Callback or function() end, currentKey)
					if not ok then warn("[WeroUI] Keybind callback error: " .. tostring(err)) end
					autosave()
				elseif input.KeyCode == currentKey then
					local ok, err = pcall(opts.Callback or function() end, currentKey)
					if not ok then warn("[WeroUI] Keybind press callback error: " .. tostring(err)) end
				end
			end))

			function api:Set(keycode)
				if typeof(keycode) == "string" then
					keycode = Enum.KeyCode[keycode] or currentKey
				end
				currentKey = keycode
				api.Value = keycode.Name
				KeyBtn.Text = keycode.Name
			end
			registerFlag(opts, api)
			return api
		end

		function Tab:CreateColorPicker(opts)
			opts = opts or {}
			local color = opts.Color or Theme.Accent
			local card = baseCard(40)
			nameSub(card, opts.Name or "Color", nil)
			attachTooltip(card, opts.Tooltip)

			local Swatch = create("TextButton", {
				Parent = card,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(28, 28),
				BackgroundColor3 = color,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 13,
			}, { corner(7), stroke(Theme.Stroke, 1) })

			local Popout = create("Frame", {
				Parent = DropdownOverlay,
				Size = UDim2.fromOffset(180, 150),
				BackgroundColor3 = Theme.ElevatedLight,
				Visible = false,
				ZIndex = 300,
			}, { corner(8), stroke(Theme.Stroke, 1), pad(10, 10, 10, 10), listLayout(Enum.FillDirection.Vertical, 6) })

			local HexBox = create("TextBox", {
				Parent = Popout,
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = Theme.Elevated,
				Text = string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255),
				TextColor3 = Theme.Text,
				Font = Theme.FontSemibold,
				TextSize = 12,
				ClearTextOnFocus = false,
				ZIndex = 301,
			}, { corner(6), pad(0, 0, 8, 8) })

			local PBackdrop = create("TextButton", {
				Parent = DropdownOverlay,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				Visible = false,
				ZIndex = 299,
			})

			local function hidePopout()
				Popout.Visible = false
				PBackdrop.Visible = false
				if openDropdown and openDropdown.list == Popout then openDropdown = nil end
			end

			local function showPopout()
				closeOpenDropdown()
				openDropdown = { list = Popout, backdrop = PBackdrop }

				local swAbs = Swatch.AbsolutePosition
				local overAbs = DropdownOverlay.AbsolutePosition
				local x = swAbs.X - overAbs.X
				local y = swAbs.Y + Swatch.AbsoluteSize.Y + 6 - overAbs.Y
				if y + Popout.AbsoluteSize.Y > DropdownOverlay.AbsoluteSize.Y then
					y = swAbs.Y - Popout.AbsoluteSize.Y - 6 - overAbs.Y
				end
				Popout.Position = UDim2.fromOffset(x, y)
				Popout.Visible = true
				PBackdrop.Visible = true
			end
			PBackdrop.MouseButton1Click:Connect(hidePopout)

			local api = { Value = color }
			local channels = { "R", "G", "B" }
			local rgb = { color.R * 255, color.G * 255, color.B * 255 }
			local fills = {}

			local function updateColor(skipHex)
				local c = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
				api.Value = c
				Swatch.BackgroundColor3 = c
				if not skipHex then
					HexBox.Text = string.format("#%02X%02X%02X", rgb[1], rgb[2], rgb[3])
				end
				local ok, err = pcall(opts.Callback or function() end, c)
				if not ok then warn("[WeroUI] ColorPicker callback error: " .. tostring(err)) end
				autosave()
			end

			HexBox.FocusLost:Connect(function()
				local hex = HexBox.Text:gsub("#", "")
				if #hex == 6 and hex:match("^%x+$") then
					local r = tonumber(hex:sub(1, 2), 16)
					local g = tonumber(hex:sub(3, 4), 16)
					local b = tonumber(hex:sub(5, 6), 16)
					rgb = { r, g, b }
					for i, fill in ipairs(fills) do
						fill.Size = UDim2.new(rgb[i] / 255, 0, 1, 0)
					end
					updateColor(true)
				else
					HexBox.Text = string.format("#%02X%02X%02X", rgb[1], rgb[2], rgb[3])
				end
			end)

			for i, ch in ipairs(channels) do
				local row = create("Frame", { Parent = Popout, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 })
				create("TextLabel", {
					Parent = row, BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 20),
					Text = ch, Font = Theme.FontBold, TextSize = 11, TextColor3 = Theme.SubText, ZIndex = 301,
				})
				local track = create("Frame", {
					Parent = row, Position = UDim2.fromOffset(20, 6), Size = UDim2.new(1, -24, 0, 8),
					BackgroundColor3 = Theme.Elevated, ZIndex = 301,
				}, { corner(4) })
				local fill = create("Frame", {
					Parent = track, Size = UDim2.new(rgb[i] / 255, 0, 1, 0),
					BackgroundColor3 = Theme.Accent, ZIndex = 302,
				}, { corner(4) })
				fills[i] = fill

				local dragging = false
				local function setAlpha(a)
					a = math.clamp(a, 0, 1)
					rgb[i] = a * 255
					fill.Size = UDim2.new(a, 0, 1, 0)
					updateColor()
				end
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						setAlpha((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
					end
				end)
				table.insert(Window._connections, UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end))
				table.insert(Window._connections, UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						setAlpha((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
					end
				end))
			end

			Swatch.MouseButton1Click:Connect(function()
				if Popout.Visible then
					hidePopout()
				else
					showPopout()
				end
			end)

			function api:Set(c)
				rgb = { c.R * 255, c.G * 255, c.B * 255 }
				for i, fill in ipairs(fills) do
					fill.Size = UDim2.new(rgb[i] / 255, 0, 1, 0)
				end
				updateColor()
			end

			registerFlag(opts, api)
			return api
		end

		if isFirst then selectTab() end
		return Tab
	end

	function Window:Destroy()
		for _, conn in ipairs(Window._connections) do
			pcall(function() conn:Disconnect() end)
		end
		ScreenGui:Destroy()
		for i, win in ipairs(Global.WeroUIInstances) do
			if win == Window then
				table.remove(Global.WeroUIInstances, i)
				break
			end
		end
	end

	task.defer(function()
		local abs = ScreenGui.AbsoluteSize
		if abs.X > 0 and abs.Y > 0 then
			local w = WindowSize.X
			local h = WindowSize.Y
			if w.Offset > abs.X then w = UDim.new(w.Scale, abs.X) end
			if h.Offset > abs.Y then h = UDim.new(h.Scale, abs.Y) end
			WindowSize = UDim2.new(w.Scale, w.Offset, h.Scale, h.Offset)
			Main.Size = WindowSize
			Main.Position = UDim2.new(0.5, 0, 0.5, -WindowSize.Y.Offset / 2)
		end
	end)

	if ConfigSaving.Enabled then
		task.defer(function() Window:LoadConfig() end)
	end

	return Window
end

return WeroUI
