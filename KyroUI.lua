--[[
	WeroUI — Roblox UI Library
	Tema azul profesional.

	Repositorio: sube este archivo a GitHub (raw) y cárgalo con loadstring(game:HttpGet(...))()

	API rápida:
		local WeroUI = loadstring(game:HttpGet("RAW_URL_AQUI"))()

		local Window = WeroUI:CreateWindow({
			Name = "Wero UI",
			Subtitle = "by TuNombre",
			Icon = 0,                         -- rbxassetid numérico del logo (opcional)
			ToggleKeybind = Enum.KeyCode.LeftControl,
			Size = UDim2.fromOffset(560, 380),
		})

		local Tab = Window:CreateTab("Principal", 0)

		Tab:CreateButton({ Name = "Botón", Callback = function() end })
		Tab:CreateToggle({ Name = "Toggle", CurrentValue = false, Callback = function(v) end })
		Tab:CreateDropdown({ Name = "Dropdown", Options = {"A","B"}, CurrentOption = "A", Callback = function(v) end })
		Tab:CreateSlider({ Name = "Slider", Range = {0, 100}, Increment = 1, CurrentValue = 50, Callback = function(v) end })
		Tab:CreateInput({ Name = "Input", PlaceholderText = "Escribe algo...", Callback = function(v) end })
		Tab:CreateParagraph({ Title = "Título", Content = "Contenido del párrafo." })
		Tab:CreateKeybind({ Name = "Keybind", CurrentKeybind = "F", Callback = function(v) end })
		Tab:CreateColorPicker({ Name = "Color", Color = Color3.fromRGB(28,152,235), Callback = function(c) end })
		Tab:CreateDivider()
		Tab:CreateLabel("Texto simple")
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------
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
	Error           = Color3.fromRGB(255, 96, 96),
	Font            = Enum.Font.GothamMedium,
	FontBold        = Enum.Font.GothamBold,
	FontSemibold    = Enum.Font.GothamSemibold,
}

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------
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
	-- Accepts: number (assetid), "rbxassetid://...", or nil
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

local function makeDraggable(dragHandle, target, onStart)
	local dragging, dragInput, dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			if onStart then onStart() end
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--------------------------------------------------------------------
-- LIBRARY
--------------------------------------------------------------------
local WeroUI = {}
WeroUI.__index = WeroUI
WeroUI.Theme = Theme

function WeroUI:CreateWindow(config)
	config = config or {}
	local WindowName        = config.Name or "Wero UI"
	local Subtitle          = config.Subtitle or config.LoadingSubtitle or ""
	local WindowIcon        = resolveIcon(config.Icon)
	local ToggleKeybind     = config.ToggleKeybind or Enum.KeyCode.LeftControl
	local WindowSize        = config.Size or UDim2.fromOffset(560, 380)

	local Window = setmetatable({}, WeroUI)
	Window.Tabs = {}
	Window.ToggleKeybind = ToggleKeybind
	Window.Open = true
	Window._tabButtons = {}

	----------------------------------------------------------------
	-- ROOT
	----------------------------------------------------------------
	local ScreenGui = create("ScreenGui", {
		Name = "WeroUI_" .. WindowName:gsub("%s", ""),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
	})
	ScreenGui.Parent = getGuiParent()
	Window.ScreenGui = ScreenGui

	----------------------------------------------------------------
	-- DROPDOWN OVERLAY (keeps popouts on top of everything)
	----------------------------------------------------------------
	local DropdownOverlay = create("Frame", {
		Parent = ScreenGui,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 200,
	})

	local openDropdown = nil
	local function closeOpenDropdown()
		if openDropdown then
			openDropdown.list.Visible = false
			openDropdown.backdrop.Visible = false
			openDropdown = nil
		end
	end

	----------------------------------------------------------------
	-- FLOATING TOGGLE ICON (rounded square, top-center)
	----------------------------------------------------------------
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

	-- fallback "K" text if no icon supplied
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

	----------------------------------------------------------------
	-- MAIN WINDOW FRAME
	----------------------------------------------------------------
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
		corner(24),
		stroke(Theme.Stroke, 1),
	})

	create("UIStroke", {
		Parent = Main,
		Color = Theme.Accent,
		Thickness = 1,
		Transparency = 0.85,
	})

	----------------------------------------------------------------
	-- TOP BAR
	----------------------------------------------------------------
	local TopBar = create("Frame", {
		Name = "TopBar",
		Parent = Main,
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Theme.Elevated,
		ZIndex = 11,
	}, { corner(24) })

	local TopBarMask = create("Frame", { -- mask bottom corners of topbar square
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
		Text = "–",
		TextColor3 = Theme.SubText,
		Font = Theme.FontBold,
		TextSize = 18,
		AutoButtonColor = false,
		ZIndex = 12,
	}, { corner(8) })

	local CloseBtn = create("TextButton", {
		Parent = TopBar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.ElevatedLight,
		Text = "×",
		TextColor3 = Theme.SubText,
		Font = Theme.FontBold,
		TextSize = 18,
		AutoButtonColor = false,
		ZIndex = 12,
	}, { corner(8) })

	makeDraggable(TopBar, Main, closeOpenDropdown)

	----------------------------------------------------------------
	-- SIDEBAR (tabs)
	----------------------------------------------------------------
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
			BottomLeftRadius = UDim.new(0, 24),
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
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		ZIndex = 11,
	}, {
		pad(10, 10, 10, 10),
		listLayout(Enum.FillDirection.Vertical, 4),
	})

	----------------------------------------------------------------
	-- CONTENT AREA
	----------------------------------------------------------------
	local ContentArea = create("Frame", {
		Name = "ContentArea",
		Parent = Main,
		Position = UDim2.new(0, 140, 0, 52),
		Size = UDim2.new(1, -140, 1, -52),
		BackgroundTransparency = 1,
		ZIndex = 11,
	})

	----------------------------------------------------------------
	-- NOTIFICATIONS HOLDER
	----------------------------------------------------------------
	local NotifyHolder = create("Frame", {
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(300, 400),
		BackgroundTransparency = 1,
		ZIndex = 100,
	}, {
		listLayout(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Right),
	})
	local nl = NotifyHolder:FindFirstChildOfClass("UIListLayout")
	nl.VerticalAlignment = Enum.VerticalAlignment.Bottom

	function Window:Notify(opts)
		opts = opts or {}
		local title = opts.Title or "Notificación"
		local content = opts.Content or ""
		local duration = opts.Duration or 4

		local Card = create("Frame", {
			Parent = NotifyHolder,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Elevated,
			BackgroundTransparency = 0,
			ZIndex = 100,
		}, {
			corner(10),
			stroke(Theme.Stroke, 1),
			pad(10, 10, 12, 12),
			listLayout(Enum.FillDirection.Vertical, 2),
		})
		create("TextLabel", {
			Parent = Card, LayoutOrder = 1, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18), Text = title,
			Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.AccentLight,
			TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
		})
		create("TextLabel", {
			Parent = Card, LayoutOrder = 2, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Text = content, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 101,
		})

		Card.BackgroundTransparency = 1
		local slideX = math.max(NotifyHolder.AbsoluteSize.X, 8)
		Card.Position = UDim2.new(0, slideX + 8, 0, 0)
		task.spawn(function()
			tween(Card, {
				Position = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 0,
			}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

			task.wait(duration + 0.3)
			local out = tween(Card, {
				Position = UDim2.fromOffset(slideX + 8, 0),
				BackgroundTransparency = 1,
			}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			out.Completed:Wait()
			Card:Destroy()
		end)
	end

	----------------------------------------------------------------
	-- OPEN / CLOSE LOGIC
	----------------------------------------------------------------
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
		MinBtn.Text = state and "+" or "–"
		if state then
			Main.Size = WindowSize
			tween(Main, { Size = UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, MINIMIZED_HEIGHT) }, 0.2)
		else
			Main.Size = UDim2.new(WindowSize.X.Scale, WindowSize.X.Offset, 0, MINIMIZED_HEIGHT)
			tween(Main, { Size = WindowSize }, 0.2)
		end
	end

	function Window:Toggle()
		Window:SetOpen(not Window.Open)
	end

	CloseBtn.MouseButton1Click:Connect(function()
		Window:SetOpen(false)
	end)
	CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {BackgroundColor3 = Theme.Error}, 0.15) end)
	CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {BackgroundColor3 = Theme.ElevatedLight}, 0.15) end)

	MinBtn.MouseButton1Click:Connect(function()
		Window:SetMinimized(not Window.Minimized)
	end)
	MinBtn.MouseEnter:Connect(function() tween(MinBtn, { BackgroundColor3 = Theme.Accent }, 0.15) end)
	MinBtn.MouseLeave:Connect(function() tween(MinBtn, { BackgroundColor3 = Theme.ElevatedLight }, 0.15) end)

	FloatIcon.MouseButton1Click:Connect(function()
		Window:Toggle()
	end)
	FloatIcon.MouseEnter:Connect(function() tween(FloatIcon, {BackgroundColor3 = Theme.ElevatedLight}, 0.15) end)
	FloatIcon.MouseLeave:Connect(function() tween(FloatIcon, {BackgroundColor3 = Theme.Elevated}, 0.15) end)

	function Window:SetToggleKeybind(keycode)
		Window.ToggleKeybind = keycode
	end

	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Window.ToggleKeybind then
			Window:Toggle()
		end
	end)

	----------------------------------------------------------------
	-- TAB CREATION
	----------------------------------------------------------------
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

		----------------------------------------------------------
		-- ELEMENT FACTORY HELPERS (scoped to this tab's Page)
		----------------------------------------------------------
		local function baseCard(height)
			return create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, 0, 0, height or 40),
				AutomaticSize = height and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Elevated,
				ZIndex = 12,
			}, { corner(10), stroke(Theme.Stroke, 1), pad(10, 10, 12, 12) })
		end

		local function nameSub(parent, nameText, descText)
			local holder = create("Frame", {
				Parent = parent,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -50, 1, 0),
			})
			create("TextLabel", {
				Parent = holder, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, descText and 0.55 or 1, 0),
				Text = nameText, Font = Theme.FontSemibold, TextSize = 13,
				TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 13,
			})
			if descText and descText ~= "" then
				create("TextLabel", {
					Parent = holder, BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.55, 0),
					Size = UDim2.new(1, 0, 0.45, 0),
					Text = descText, Font = Theme.Font, TextSize = 11,
					TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 13,
				})
			end
			return holder
		end

		----------------------------------------------------------
		-- SECTION LABEL
		----------------------------------------------------------
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

		----------------------------------------------------------
		-- LABEL
		----------------------------------------------------------
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

		----------------------------------------------------------
		-- PARAGRAPH
		----------------------------------------------------------
		function Tab:CreateParagraph(opts)
			opts = opts or {}
			local card = create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Elevated,
				ZIndex = 12,
			}, { corner(10), stroke(Theme.Stroke, 1), pad(10, 10, 12, 12), listLayout(Enum.FillDirection.Vertical, 4) })

			create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18), Text = opts.Title or "",
				Font = Theme.FontBold, TextSize = 13, TextColor3 = Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
			})
			create("TextLabel", {
				Parent = card, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				Text = opts.Content or "", Font = Theme.Font, TextSize = 12,
				TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true, ZIndex = 13,
			})
			return card
		end

		----------------------------------------------------------
		-- DIVIDER
		----------------------------------------------------------
		function Tab:CreateDivider()
			create("Frame", {
				Parent = Page,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
				ZIndex = 12,
			})
		end

		----------------------------------------------------------
		-- BUTTON
		----------------------------------------------------------
		function Tab:CreateButton(opts)
			opts = opts or {}
			local card = baseCard(opts.Description and 50 or 40)
			nameSub(card, opts.Name or "Botón", opts.Description)

			local Btn = create("TextButton", {
				Parent = card,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(34, 26),
				BackgroundColor3 = Theme.Accent,
				Text = "▶",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Theme.FontBold,
				TextSize = 13,
				AutoButtonColor = false,
				ZIndex = 13,
			}, { corner(7) })

			Btn.MouseButton1Click:Connect(function()
				tween(Btn, { BackgroundColor3 = Theme.AccentDark }, 0.08)
				task.wait(0.08)
				tween(Btn, { BackgroundColor3 = Theme.Accent }, 0.15)
				local ok, err = pcall(opts.Callback or function() end)
				if not ok then warn("[WeroUI] Button callback error: " .. tostring(err)) end
			end)
			return { Instance = card }
		end

		----------------------------------------------------------
		-- TOGGLE
		----------------------------------------------------------
		function Tab:CreateToggle(opts)
			opts = opts or {}
			local state = opts.CurrentValue or false
			local card = baseCard(opts.Description and 50 or 40)
			nameSub(card, opts.Name or "Toggle", opts.Description)

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

			local api = {}
			function api:Set(value)
				state = value
				tween(Switch, { BackgroundColor3 = state and Theme.Accent or Theme.ElevatedLight }, 0.15)
				tween(Knob, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, 0.15)
				local ok, err = pcall(opts.Callback or function() end, state)
				if not ok then warn("[WeroUI] Toggle callback error: " .. tostring(err)) end
			end

			Click.MouseButton1Click:Connect(function() api:Set(not state) end)
			if opts.CurrentValue then
				task.defer(function() pcall(opts.Callback or function() end, state) end)
			end
			return api
		end

		----------------------------------------------------------
		-- SLIDER
		----------------------------------------------------------
		function Tab:CreateSlider(opts)
			opts = opts or {}
			local min = (opts.Range and opts.Range[1]) or 0
			local max = (opts.Range and opts.Range[2]) or 100
			local inc = opts.Increment or 1
			local value = opts.CurrentValue or min

			local card = baseCard(56)
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
				Text = tostring(value), Font = Theme.FontSemibold, TextSize = 13,
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
				ValueLabel.Text = tostring(raw)
				local ok, err = pcall(opts.Callback or function() end, raw)
				if not ok then warn("[WeroUI] Slider callback error: " .. tostring(err)) end
			end

			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					setFromAlpha((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					setFromAlpha((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X)
				end
			end)

			function api:Set(v) setFromAlpha((v - min) / math.max(max - min, 1e-6)) end
			return api
		end

		----------------------------------------------------------
		-- DROPDOWN
		----------------------------------------------------------
		function Tab:CreateDropdown(opts)
			opts = opts or {}
			local options = opts.Options or {}
			local multi = opts.MultipleOptions or false
			local selected = {}
			if multi then
				for _, v in ipairs(opts.CurrentOption or {}) do selected[v] = true end
			else
				selected[opts.CurrentOption or options[1]] = true
			end

			local card = baseCard(40)
			nameSub(card, opts.Name or "Dropdown", nil)

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

			local function currentText()
				local list = {}
				for k, v in pairs(selected) do if v then table.insert(list, k) end end
				if #list == 0 then return "Seleccionar..." end
				return table.concat(list, ", ")
			end

			local DisplayLabel = create("TextLabel", {
				Parent = DisplayBtn, BackgroundTransparency = 1,
				Size = UDim2.new(1, -24, 1, 0), Position = UDim2.fromOffset(8, 0),
				Text = currentText(), Font = Theme.Font, TextSize = 12,
				TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 14,
			})
			create("TextLabel", {
				Parent = DisplayBtn, BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(14, 14), Text = "▾", Font = Theme.FontBold,
				TextSize = 12, TextColor3 = Theme.SubText, ZIndex = 14,
			})

			local OPTION_H = 26
			local OPTION_GAP = 2
			local OPTION_PAD = 8
			local MAX_VISIBLE_OPTIONS = 5

			local function listHeight()
				local n = math.min(#options, MAX_VISIBLE_OPTIONS)
				return OPTION_PAD + n * OPTION_H + math.max(n - 1, 0) * OPTION_GAP
			end

			local ListFrame = create("ScrollingFrame", {
				Parent = DropdownOverlay,
				Size = UDim2.new(0, 150, 0, listHeight()),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Theme.Accent,
				BackgroundColor3 = Theme.ElevatedLight,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 300,
				ClipsDescendants = true,
			}, { corner(8), stroke(Theme.Stroke, 1), pad(4, 4, 4, 4), listLayout(Enum.FillDirection.Vertical, OPTION_GAP) })

			local Backdrop = create("TextButton", {
				Parent = DropdownOverlay,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				Visible = false,
				ZIndex = 299,
			})

			local function hideList()
				ListFrame.Visible = false
				Backdrop.Visible = false
				if openDropdown and openDropdown.list == ListFrame then openDropdown = nil end
			end
			Backdrop.MouseButton1Click:Connect(hideList)

			local function showList()
				closeOpenDropdown()
				openDropdown = { list = ListFrame, backdrop = Backdrop }

				local btnAbs = DisplayBtn.AbsolutePosition
				local overAbs = DropdownOverlay.AbsolutePosition
				local x = btnAbs.X - overAbs.X
				local y = btnAbs.Y + DisplayBtn.AbsoluteSize.Y + 6 - overAbs.Y
				local h = ListFrame.AbsoluteSize.Y
				if y + h > DropdownOverlay.AbsoluteSize.Y then
					y = btnAbs.Y - h - 6 - overAbs.Y
				end
				ListFrame.Position = UDim2.fromOffset(x, y)
				ListFrame.Visible = true
				Backdrop.Visible = true
			end

			local api = { Value = multi and selected or (opts.CurrentOption or options[1]) }

			local function refreshOptions()
				for _, c in ipairs(ListFrame:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				for _, optName in ipairs(options) do
					local isSelected = selected[optName] and true or false
					local OptBtn = create("TextButton", {
						Parent = ListFrame,
						Size = UDim2.new(1, 0, 0, 26),
						BackgroundColor3 = isSelected and Theme.Accent or Theme.Elevated,
						BackgroundTransparency = isSelected and 0.5 or 1,
						Text = optName,
						TextColor3 = Theme.Text,
						Font = Theme.Font,
						TextSize = 12,
						AutoButtonColor = false,
						ZIndex = 31,
					}, { corner(6) })
					OptBtn.MouseButton1Click:Connect(function()
						if multi then
							selected[optName] = not selected[optName]
							api.Value = selected
						else
							selected = { [optName] = true }
							api.Value = optName
							hideList()
						end
						DisplayLabel.Text = currentText()
						refreshOptions()
						local ok, err = pcall(opts.Callback or function() end, api.Value)
						if not ok then warn("[WeroUI] Dropdown callback error: " .. tostring(err)) end
					end)
				end
				ListFrame.Size = UDim2.new(0, 150, 0, listHeight())
				if ListFrame.Visible then showList() end
			end
			refreshOptions()

			DisplayBtn.MouseButton1Click:Connect(function()
				if ListFrame.Visible then
					hideList()
				else
					showList()
				end
			end)

			function api:Refresh(newOptions)
				options = newOptions
				refreshOptions()
			end

			return api
		end

		----------------------------------------------------------
		-- INPUT / TEXTBOX
		----------------------------------------------------------
		function Tab:CreateInput(opts)
			opts = opts or {}
			local card = baseCard(40)
			nameSub(card, opts.Name or "Input", nil)

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
			end)
			function api:Set(text) Box.Text = text; api.Value = text end
			return api
		end

		----------------------------------------------------------
		-- KEYBIND
		----------------------------------------------------------
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

			local api = { Value = currentKey }

			KeyBtn.MouseButton1Click:Connect(function()
				listening = true
				KeyBtn.Text = "..."
				tween(KeyBtn, { BackgroundColor3 = Theme.Accent }, 0.15)
			end)

			UserInputService.InputBegan:Connect(function(input, processed)
				if listening and input.UserInputType == Enum.UserInputType.Keyboard then
					currentKey = input.KeyCode
					api.Value = currentKey
					KeyBtn.Text = currentKey.Name
					listening = false
					tween(KeyBtn, { BackgroundColor3 = Theme.ElevatedLight }, 0.15)
					local ok, err = pcall(opts.Callback or function() end, currentKey)
					if not ok then warn("[WeroUI] Keybind callback error: " .. tostring(err)) end
				end
			end)

			function api:Set(keycode) currentKey = keycode; api.Value = keycode; KeyBtn.Text = keycode.Name end
			return api
		end

		----------------------------------------------------------
		-- COLOR PICKER (simplified: RGB sliders in a popout)
		----------------------------------------------------------
		function Tab:CreateColorPicker(opts)
			opts = opts or {}
			local color = opts.Color or Theme.Accent
			local card = baseCard(40)
			nameSub(card, opts.Name or "Color", nil)

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
				Size = UDim2.fromOffset(180, 130),
				BackgroundColor3 = Theme.ElevatedLight,
				Visible = false,
				ZIndex = 300,
			}, { corner(8), stroke(Theme.Stroke, 1), pad(10, 10, 10, 10), listLayout(Enum.FillDirection.Vertical, 6) })

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

			local function updateColor()
				local c = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
				api.Value = c
				Swatch.BackgroundColor3 = c
				local ok, err = pcall(opts.Callback or function() end, c)
				if not ok then warn("[WeroUI] ColorPicker callback error: " .. tostring(err)) end
			end

			for i, ch in ipairs(channels) do
				local row = create("Frame", { Parent = Popout, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 })
				create("TextLabel", {
					Parent = row, BackgroundTransparency = 1, Size = UDim2.fromOffset(14, 20),
					Text = ch, Font = Theme.FontBold, TextSize = 11, TextColor3 = Theme.SubText, ZIndex = 31,
				})
				local track = create("Frame", {
					Parent = row, Position = UDim2.fromOffset(20, 6), Size = UDim2.new(1, -24, 0, 8),
					BackgroundColor3 = Theme.Elevated, ZIndex = 31,
				}, { corner(4) })
				local fill = create("Frame", {
					Parent = track, Size = UDim2.new(rgb[i] / 255, 0, 1, 0),
					BackgroundColor3 = Theme.Accent, ZIndex = 32,
				}, { corner(4) })

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
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						setAlpha((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
					end
				end)
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
				updateColor()
			end

			return api
		end

		if isFirst then selectTab() end
		return Tab
	end

	function Window:Destroy()
		ScreenGui:Destroy()
	end

	return Window
end

return WeroUI
