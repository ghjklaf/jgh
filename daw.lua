--[[
    fatalwtfuilibrary
    High performance, modular UI library replicating the fatal.wtf / VisualMenu aesthetic.
    Features:
      - Pixel-perfect reproduction of VisualMenu (diagonal canvas stripes, custom toggles, chevron dropdowns)
      - Dynamic Theme engine (Default, Ocean, Blood, Mint, Midnight, Sunset) with live reactivity
      - Tab switching, Search filtering, Keybind toggling, Smooth drag (PC & Touch)
      - Controls: Toggles (with nested Colorpickers & Keybinds), Sliders, Dropdowns, Colorpickers, Keybinds, TextBoxes, Buttons, Lists
      - Built-in Toast Notification system
--]]

local fatalwtfuilibrary = {}
fatalwtfuilibrary.__index = fatalwtfuilibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Themes
fatalwtfuilibrary.Themes = {
    Default = {
        Accent = Color3.fromRGB(235, 60, 140),
        Header1 = Color3.fromRGB(150, 25, 85),
        Header2 = Color3.fromRGB(30, 26, 28),
        Background = Color3.fromRGB(10, 10, 10),
        SectionBg = Color3.fromRGB(18, 18, 18),
        ElementBg = Color3.fromRGB(26, 26, 26),
        Stroke = Color3.fromRGB(38, 38, 38),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(130, 130, 130),
        StripeColor = Color3.fromRGB(170, 170, 170),
        SliderStripe = Color3.fromRGB(32, 32, 32),
    },
    Ocean = {
        Accent = Color3.fromRGB(0, 195, 255),
        Header1 = Color3.fromRGB(0, 100, 180),
        Header2 = Color3.fromRGB(15, 25, 45),
        Background = Color3.fromRGB(10, 12, 16),
        SectionBg = Color3.fromRGB(16, 20, 26),
        ElementBg = Color3.fromRGB(24, 30, 38),
        Stroke = Color3.fromRGB(35, 45, 58),
        Text = Color3.fromRGB(240, 245, 255),
        TextDim = Color3.fromRGB(120, 135, 155),
        StripeColor = Color3.fromRGB(140, 180, 220),
        SliderStripe = Color3.fromRGB(28, 36, 48),
    },
    Blood = {
        Accent = Color3.fromRGB(245, 45, 60),
        Header1 = Color3.fromRGB(160, 20, 30),
        Header2 = Color3.fromRGB(35, 12, 16),
        Background = Color3.fromRGB(12, 10, 10),
        SectionBg = Color3.fromRGB(20, 16, 16),
        ElementBg = Color3.fromRGB(28, 22, 22),
        Stroke = Color3.fromRGB(48, 32, 32),
        Text = Color3.fromRGB(245, 240, 240),
        TextDim = Color3.fromRGB(145, 120, 120),
        StripeColor = Color3.fromRGB(190, 140, 140),
        SliderStripe = Color3.fromRGB(36, 26, 26),
    },
    Mint = {
        Accent = Color3.fromRGB(45, 225, 145),
        Header1 = Color3.fromRGB(20, 135, 80),
        Header2 = Color3.fromRGB(14, 32, 24),
        Background = Color3.fromRGB(10, 12, 11),
        SectionBg = Color3.fromRGB(16, 20, 18),
        ElementBg = Color3.fromRGB(24, 30, 27),
        Stroke = Color3.fromRGB(32, 48, 38),
        Text = Color3.fromRGB(240, 250, 245),
        TextDim = Color3.fromRGB(125, 145, 135),
        StripeColor = Color3.fromRGB(150, 210, 180),
        SliderStripe = Color3.fromRGB(26, 38, 32),
    },
    Midnight = {
        Accent = Color3.fromRGB(165, 95, 255),
        Header1 = Color3.fromRGB(100, 40, 180),
        Header2 = Color3.fromRGB(28, 16, 46),
        Background = Color3.fromRGB(11, 10, 14),
        SectionBg = Color3.fromRGB(18, 16, 24),
        ElementBg = Color3.fromRGB(27, 24, 36),
        Stroke = Color3.fromRGB(45, 36, 58),
        Text = Color3.fromRGB(245, 240, 255),
        TextDim = Color3.fromRGB(135, 125, 155),
        StripeColor = Color3.fromRGB(180, 150, 225),
        SliderStripe = Color3.fromRGB(35, 30, 48),
    },
    Sunset = {
        Accent = Color3.fromRGB(255, 135, 45),
        Header1 = Color3.fromRGB(185, 55, 65),
        Header2 = Color3.fromRGB(42, 20, 26),
        Background = Color3.fromRGB(12, 10, 10),
        SectionBg = Color3.fromRGB(22, 18, 16),
        ElementBg = Color3.fromRGB(32, 25, 22),
        Stroke = Color3.fromRGB(50, 36, 30),
        Text = Color3.fromRGB(255, 245, 240),
        TextDim = Color3.fromRGB(150, 130, 120),
        StripeColor = Color3.fromRGB(215, 165, 140),
        SliderStripe = Color3.fromRGB(40, 30, 26),
    }
}

-- Icons Asset Registry
fatalwtfuilibrary.Icons = {
    Logo = "rbxassetid://123865964093715",
    Search = "rbxassetid://135740014908175",
    Aimbot = "rbxassetid://76535961115022",
    Visual = "rbxassetid://120042457174817",
    Misc = "rbxassetid://107381670745078",
    Players = "rbxassetid://133980729758572",
    Config = "rbxassetid://138852765629919",
    Globe = "rbxassetid://135874277454346",
    Info = "rbxassetid://99396201903267",
}

-- Helper functions
local function Create(className, properties, children)
    local inst = Instance.new(className)
    if properties then
        for prop, val in pairs(properties) do
            inst[prop] = val
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

local function Tween(instance, duration, properties, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(guiObject, handle)
    handle = handle or guiObject
    local dragging = false
    local dragStart = nil
    local startPos = nil

    local function HookInput(target)
        target.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = guiObject.Position
            end
        end)
    end

    HookInput(handle)
    for _, child in ipairs(handle:GetDescendants()) do
        if child:IsA("GuiObject") and not child:IsA("TextBox") and not child:IsA("TextButton") then
            HookInput(child)
        end
    end
    handle.DescendantAdded:Connect(function(child)
        if child:IsA("GuiObject") and not child:IsA("TextBox") and not child:IsA("TextButton") then
            HookInput(child)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function FormatKey(keyCode)
    if not keyCode then return "None" end
    local str = tostring(keyCode.Name)
    str = str:gsub("Keypad", "Num ")
    str = str:gsub("Right", "R")
    str = str:gsub("Left", "L")
    return str
end

-- Mouse buttons get short names in keybind boxes
local function FormatBind(key)
    if key == nil then return "None" end
    if key == Enum.UserInputType.MouseButton1 then return "MB1" end
    if key == Enum.UserInputType.MouseButton2 then return "MB2" end
    if key == Enum.UserInputType.MouseButton3 then return "MB3" end
    return FormatKey(key)
end

-- File storage (uses writefile/readfile when available, otherwise keeps files in memory)
local HasFileSystem = typeof(writefile) == "function" and typeof(readfile) == "function"
    and typeof(isfile) == "function" and typeof(isfolder) == "function"
    and typeof(makefolder) == "function" and typeof(listfiles) == "function"

local MemoryFiles = {}
local Storage = {}

function Storage.EnsureFolder(path)
    if HasFileSystem and not isfolder(path) then
        makefolder(path)
    end
end

function Storage.Write(path, data)
    if HasFileSystem then
        writefile(path, data)
    else
        MemoryFiles[path] = data
    end
end

function Storage.Read(path)
    if HasFileSystem then
        if isfile(path) then
            return readfile(path)
        end
        return nil
    end
    return MemoryFiles[path]
end

function Storage.Delete(path)
    if HasFileSystem then
        if isfile(path) and typeof(delfile) == "function" then
            delfile(path)
        end
    else
        MemoryFiles[path] = nil
    end
end

function Storage.List(folder, ext)
    local names = {}
    local paths = {}
    if HasFileSystem then
        if isfolder(folder) then
            paths = listfiles(folder)
        end
    else
        for p in pairs(MemoryFiles) do
            table.insert(paths, p)
        end
    end
    local prefix = folder .. "/"
    for _, p in ipairs(paths) do
        p = p:gsub("\\", "/")
        local idx = p:find(prefix, 1, true)
        if idx and p:sub(-#ext) == ext then
            local name = p:sub(idx + #prefix, -#ext - 1)
            if name ~= "" and not name:find("/", 1, true) then
                table.insert(names, name)
            end
        end
    end
    table.sort(names)
    return names
end

-- Window creation
function fatalwtfuilibrary:CreateWindow(opts)
    opts = opts or {}
    local Title = opts.Title or "Fatal.wtf"
    local MenuKey = opts.MenuKey or Enum.KeyCode.RightShift
    local Language = opts.Language or "English"
    local DefaultTheme = opts.Theme or "Default"
    local ScaleVal = opts.Scale or 0.7
    local LogoAsset = opts.Logo or fatalwtfuilibrary.Icons.Logo

    local ActiveTheme = table.clone(fatalwtfuilibrary.Themes[DefaultTheme] or fatalwtfuilibrary.Themes.Default)

    -- ScreenGui Parent target
    local TargetParent = opts.Parent
    if not TargetParent then
        local success, coreGui = pcall(function() return CoreGui end)
        if success and coreGui then
            local successParent, _ = pcall(function()
                local test = Instance.new("Folder", coreGui)
                test:Destroy()
            end)
            if successParent then
                TargetParent = coreGui
            end
        end
    end
    if not TargetParent then
        if LocalPlayer then
            TargetParent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 2)
        end
        if not TargetParent then
            TargetParent = game:GetService("StarterGui")
        end
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "fatalwtfuilibrary_" .. Title:gsub("%s+", "_"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        Parent = TargetParent
    })

    local UIScale = Create("UIScale", {
        Scale = ScaleVal,
        Parent = nil
    })

    local InitialVisible = opts.Visible ~= false
    local Window = Create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 853, 0, 994),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Visible = InitialVisible,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", {
            Name = "WindowStroke",
            Thickness = 1,
            Color = ActiveTheme.Stroke,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
        UIScale
    })


    -- TopBar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(0, 853, 0, 88),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Window
    })

    MakeDraggable(Window, TopBar)

    -- Logo
    local LogoFrame = Create("Frame", {
        Name = "Logo",
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0, 22, 0, 20),
        BackgroundTransparency = 1,
        Parent = TopBar
    }, {
        Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = LogoAsset
        })
    })

    -- Divider
    local Divider = Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(0, 2, 0, 68),
        Position = UDim2.new(0, 96, 0, 12),
        BackgroundColor3 = ActiveTheme.Stroke,
        BorderSizePixel = 0,
        Parent = TopBar
    })

    -- Search Bar Container
    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(0, 150, 0, 26),
        Position = UDim2.new(0, 110, 0, 36),
        BackgroundTransparency = 1,
        Parent = TopBar
    })

    local SearchIcon = Create("ImageLabel", {
        Name = "SearchIcon",
        Size = UDim2.new(0, 21, 0, 21),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1,
        Image = fatalwtfuilibrary.Icons.Search,
        ImageColor3 = ActiveTheme.TextDim,
        Parent = SearchContainer
    })

    local SearchBox = Create("TextBox", {
            TextStrokeTransparency = 1,
        Name = "SearchBox",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = ActiveTheme.Text,
        PlaceholderText = "Search...",
        PlaceholderColor3 = ActiveTheme.TextDim,
        Text = "",
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchContainer
    })

    -- Tabs Container (Matches Studio layout: starts at X=269, Left-aligned with 26px padding)
    local TabsContainer = Create("Frame", {
        Name = "Tabs",
        Size = UDim2.new(0, 584, 0, 88),
        Position = UDim2.new(0, 269, 0, 0),
        BackgroundTransparency = 1,
        Parent = TopBar
    })

    local TabsListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 26),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabsContainer
    })

    -- Header Line under TopBar
    local HeaderLine = Create("Frame", {
        Name = "HeaderLine",
        Size = UDim2.new(0, 837, 0, 2),
        Position = UDim2.new(0, 8, 0, 88),
        BackgroundColor3 = ActiveTheme.Stroke,
        BorderSizePixel = 0,
        Parent = Window
    })

    -- Bottom Bar: Globe, Language, MenuKey
    local GlobeIcon = Create("Frame", {
        Name = "GlobeIcon",
        Size = UDim2.new(0, 21, 0, 21),
        Position = UDim2.new(0, 12, 0, 965),
        BackgroundTransparency = 1,
        Parent = Window
    }, {
        Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = fatalwtfuilibrary.Icons.Globe,
            ImageColor3 = ActiveTheme.TextDim
        })
    })

    local LanguageLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
        Name = "Language",
        Size = UDim2.new(0, 150, 0, 20),
        Position = UDim2.new(0, 40, 0, 965),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = ActiveTheme.Text,
        Text = Language,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Window
    })

    local MenuKeyLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
        Name = "MenuKey",
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 636, 0, 965),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = ActiveTheme.TextDim,
        Text = "Menu: " .. FormatKey(MenuKey),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Window
    })

    -- Pages Container
    local PagesContainer = Create("Frame", {
        Name = "PagesContainer",
        Size = UDim2.new(0, 853, 0, 860),
        Position = UDim2.new(0, 0, 0, 96),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = Window
    })

    -- Floating Overlay Container for popups (Dropdowns, Colorpickers)
    local OverlayContainer = Create("Frame", {
        Name = "OverlayContainer",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 50,
        Parent = Window
    })

    -- Notification container (bottom right)
    local NotificationContainer = Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 320, 0, 600),
        Position = UDim2.new(1, -14, 1, -14),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = ScreenGui
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        }),
        Create("UIScale", { Name = "Scale", Scale = ScaleVal })
    })

    -- Window Object
    local WindowObj = {
        ScreenGui = ScreenGui,
        Window = Window,
        UIScale = UIScale,
        TopBar = TopBar,
        TabsContainer = TabsContainer,
        PagesContainer = PagesContainer,
        OverlayContainer = OverlayContainer,
        NotificationContainer = NotificationContainer,
        ActiveTheme = ActiveTheme,
        Tabs = {},
        CurrentTab = nil,
        MenuKey = MenuKey,
        Visible = InitialVisible,
        ThemeObjects = {},
        ActiveToggles = {}
    }

    -- Register Theme elements
    local function RegisterTheme(instance, prop, themeKey)
        table.insert(WindowObj.ThemeObjects, {
            Instance = instance,
            Property = prop,
            Key = themeKey
        })
    end

    RegisterTheme(Window, "BackgroundColor3", "Background")
    RegisterTheme(Window.WindowStroke, "Color", "Stroke")
    RegisterTheme(Divider, "BackgroundColor3", "Stroke")
    RegisterTheme(HeaderLine, "BackgroundColor3", "Stroke")
    RegisterTheme(LanguageLabel, "TextColor3", "Text")
    RegisterTheme(MenuKeyLabel, "TextColor3", "TextDim")
    RegisterTheme(GlobeIcon.Icon, "ImageColor3", "TextDim")
    RegisterTheme(SearchIcon, "ImageColor3", "TextDim")
    RegisterTheme(SearchBox, "TextColor3", "Text")
    RegisterTheme(SearchBox, "PlaceholderColor3", "TextDim")

    -- Extra window state
    WindowObj.Flags = {}
    WindowObj.Keybinds = {}
    WindowObj.Headers = {}
    WindowObj.ScaleObjects = { UIScale, NotificationContainer.Scale }
    WindowObj.NotificationsEnabled = true
    WindowObj.StrokesEnabled = true
    WindowObj.StripesEnabled = true
    WindowObj.Folder = opts.Folder or "Fatal.wtf"

    local function RegisterFlag(flag, obj)
        if flag then
            obj.Flag = flag
            WindowObj.Flags[flag] = obj
        end
    end

    -- Converts a screen position into the window's unscaled coordinates
    local function ToWindowSpace(absPos)
        local scale = UIScale.Scale
        if scale <= 0 then scale = 1 end
        return (absPos - Window.AbsolutePosition) / scale
    end

    -- Popups (dropdowns, colorpicker, keybind menu): only one open, closes on outside click
    local ActivePopup = nil
    local LastClosedOwner, LastClosedAt = nil, 0

    local function ClosePopup()
        if ActivePopup then
            local popup = ActivePopup
            ActivePopup = nil
            LastClosedOwner, LastClosedAt = popup.Owner, os.clock()
            if popup.OnClose then
                popup.OnClose()
            end
        end
    end

    local function JustClosed(owner)
        return owner ~= nil and owner == LastClosedOwner and (os.clock() - LastClosedAt) < 0.25
    end

    local function OpenPopup(frame, onClose, owner)
        ClosePopup()
        ActivePopup = { Frame = frame, OnClose = onClose, Owner = owner }
    end

    WindowObj.ClosePopup = ClosePopup

    UserInputService.InputBegan:Connect(function(input)
        if not ActivePopup then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.MouseButton2 and t ~= Enum.UserInputType.Touch then
            return
        end
        local f = ActivePopup.Frame
        local p, s = f.AbsolutePosition, f.AbsoluteSize
        local x, y = input.Position.X, input.Position.Y
        if x < p.X or x > p.X + s.X or y < p.Y or y > p.Y + s.Y then
            ClosePopup()
        end
    end)

    -- Striped gradient header (sections, keybind list)
    local function BuildStripedHeader(parent, height)
        local canvas = Create("CanvasGroup", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, height),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = parent
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) })
        })
        local stripes = Create("Folder", { Name = "Stripes", Parent = canvas })
        for i = 1, 56 do
            Create("Frame", {
                Name = "Stripe",
                Size = UDim2.new(0, 3, 0, height * 3),
                Position = UDim2.new(0, -height + (i - 1) * 8, 0, -height),
                Rotation = 45,
                BackgroundColor3 = WindowObj.ActiveTheme.StripeColor,
                BorderSizePixel = 0,
                Visible = WindowObj.StripesEnabled,
                Parent = stripes
            })
        end
        local grad = Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, WindowObj.ActiveTheme.Header1),
                ColorSequenceKeypoint.new(0.45, WindowObj.ActiveTheme.Header1),
                ColorSequenceKeypoint.new(1, WindowObj.ActiveTheme.Header2)
            }),
            Parent = canvas
        })
        table.insert(WindowObj.Headers, { Gradient = grad, Stripes = stripes })
        return canvas, grad, stripes
    end

    -- Swaps every themed color in the gui from the old theme to the new one.
    -- Instances with attribute ThemeIgnore = true are skipped, "Text"/"Background" skips just that property.
    local function RemapColors(oldTheme, newTheme)
        local reverse = {}
        for key, col in pairs(oldTheme) do
            if typeof(col) == "Color3" then
                local hex = col:ToHex()
                reverse[hex] = reverse[hex] or {}
                table.insert(reverse[hex], key)
            end
        end

        local function apply(inst, prop)
            local keys = reverse[inst[prop]:ToHex()]
            if not keys then return end
            local attr = "ThemeKey_" .. prop
            local key = keys[1]
            if #keys > 1 then
                local cached = inst:GetAttribute(attr)
                if cached and table.find(keys, cached) then
                    key = cached
                end
            end
            if inst:GetAttribute(attr) ~= key then
                inst:SetAttribute(attr, key)
            end
            local new = newTheme[key]
            if new then
                inst[prop] = new
            end
        end

        for _, inst in ipairs(ScreenGui:GetDescendants()) do
            local ignore = inst:GetAttribute("ThemeIgnore")
            if ignore ~= true then
                if inst:IsA("GuiObject") then
                    if ignore ~= "Background" then
                        apply(inst, "BackgroundColor3")
                    end
                    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                        if ignore ~= "Text" then
                            apply(inst, "TextColor3")
                        end
                        if inst:IsA("TextBox") then
                            apply(inst, "PlaceholderColor3")
                        end
                    elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                        apply(inst, "ImageColor3")
                    end
                    if inst:IsA("ScrollingFrame") then
                        apply(inst, "ScrollBarImageColor3")
                    end
                elseif inst:IsA("UIStroke") then
                    apply(inst, "Color")
                end
            end
        end
    end

    -- Button styling: no stroke unless mouse is over
    local function SetupButton(Btn, bOpts)
        bOpts = bOpts or {}
        Create("UICorner", { CornerRadius = UDim.new(0, 3), Parent = Btn })
        local stroke = Create("UIStroke", {
            Color = WindowObj.ActiveTheme.Accent,
            Thickness = 1,
            Transparency = 1,
            Enabled = false,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = Btn
        })

        local isHovered = false
        local obj = { Instance = Btn, Highlighted = bOpts.Accent == true, Stroke = stroke }

        Btn.MouseEnter:Connect(function()
            isHovered = true
            if WindowObj.StrokesEnabled ~= false then
                stroke.Enabled = true
                stroke.Color = WindowObj.ActiveTheme.Accent
                Tween(stroke, 0.15, { Transparency = 0 })
            end
        end)
        Btn.MouseLeave:Connect(function()
            isHovered = false
            local tw = Tween(stroke, 0.15, { Transparency = 1 })
            tw.Completed:Connect(function()
                if not isHovered then
                    stroke.Enabled = false
                end
            end)
        end)
        Btn.MouseButton1Click:Connect(function()
            Tween(Btn, 0.08, { BackgroundColor3 = WindowObj.ActiveTheme.Stroke }).Completed:Connect(function()
                Tween(Btn, 0.15, { BackgroundColor3 = WindowObj.ActiveTheme.ElementBg })
            end)
            if bOpts.Callback then
                task.spawn(bOpts.Callback)
            end
        end)

        function obj:SetHighlighted(state)
            obj.Highlighted = state == true
        end

        function obj:SetText(text)
            Btn.Text = text
        end

        return obj
    end

    -- Keybind mode menu (right click a keybind): Toggle / Hold / Always
    function WindowObj:OpenKeybindMenu(anchor, currentMode, onSelect)
        local theme = WindowObj.ActiveTheme
        local scale = math.max(UIScale.Scale, 0.01)
        local rel = ToWindowSpace(anchor.AbsolutePosition)
        local anchorW = anchor.AbsoluteSize.X / scale
        local anchorH = anchor.AbsoluteSize.Y / scale
        local menuW = math.max(anchorW, 110)

        local Menu = Create("Frame", {
            Name = "KeybindModeMenu",
            Size = UDim2.new(0, menuW, 0, 104),
            Position = UDim2.new(0, rel.X + anchorW - menuW, 0, rel.Y + anchorH + 4),
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            ZIndex = 90,
            Parent = OverlayContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
            Create("Frame", {
                Name = "AccentLine",
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 2
            }, {
                Create("UIGradient", { Transparency = NumberSequence.new(0, 0.6) })
            })
        })

        for i, mode in ipairs({ "Toggle", "Hold", "Always" }) do
            local selected = mode == currentMode
            local Opt = Create("TextButton", {
            TextStrokeTransparency = 1,
                Name = mode,
                Size = UDim2.new(1, -8, 0, 30),
                Position = UDim2.new(0, 4, 0, 6 + (i - 1) * 32),
                BackgroundColor3 = selected and theme.ElementBg or theme.Background,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Text = "",
                Parent = Menu
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })

            if selected then
                Create("Frame", {
                    Name = "SelectBar",
                    Size = UDim2.new(0, 3, 0, 16),
                    Position = UDim2.new(0, 0, 0.5, -8),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0,
                    Parent = Opt
                })
            end

            local OptText = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Text",
                Size = UDim2.new(1, -14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = selected and theme.Text or theme.TextDim,
                Text = mode,
                Parent = Opt
            })

            Opt.MouseEnter:Connect(function()
                if not selected then OptText.TextColor3 = WindowObj.ActiveTheme.Text end
            end)
            Opt.MouseLeave:Connect(function()
                if not selected then OptText.TextColor3 = WindowObj.ActiveTheme.TextDim end
            end)
            Opt.MouseButton1Click:Connect(function()
                ClosePopup()
                onSelect(mode)
            end)
        end

        OpenPopup(Menu, function()
            Menu:Destroy()
        end, anchor)
    end

    -- Keybind list (shows every bound key, active ones highlighted)
    local KeybindList = Create("Frame", {
        Name = "KeybindList",
        Size = UDim2.new(0, 240, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = ActiveTheme.SectionBg,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
        Create("UIStroke", { Color = ActiveTheme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })
    local KeybindListScale = Create("UIScale", { Scale = ScaleVal, Parent = KeybindList })
    table.insert(WindowObj.ScaleObjects, KeybindListScale)
    MakeDraggable(KeybindList)

    local KeybindListHeader = BuildStripedHeader(KeybindList, 34)
    Create("Frame", {
        Name = "HeaderLine",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 33),
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        Parent = KeybindList
    })
    Create("TextLabel", {
            TextStrokeTransparency = 1,
        Name = "Title",
        Size = UDim2.new(1, -40, 0, 34),
        Position = UDim2.new(0, 11, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = ActiveTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Keybinds",
        Parent = KeybindList
    })
    Create("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -28, 0, 8),
        BackgroundTransparency = 1,
        Image = fatalwtfuilibrary.Icons.Aimbot,
        ImageColor3 = ActiveTheme.Text,
        Parent = KeybindList
    })
    local KeybindRows = Create("Frame", {
        Name = "List",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 35),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = KeybindList
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8) })
    })
    MakeDraggable(KeybindList, KeybindListHeader)

    function WindowObj:RefreshKeybindList()
        for _, child in ipairs(KeybindRows:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local theme = WindowObj.ActiveTheme
        for i, bind in ipairs(WindowObj.Keybinds) do
            if bind.ShowInList and bind.Key then
                local on = bind.Active
                local Row = Create("Frame", {
                    Name = bind.Name,
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    LayoutOrder = i,
                    Parent = KeybindRows
                })
                Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Name",
                    Size = UDim2.new(1, -150, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextColor3 = on and theme.Text or theme.TextDim,
                    Text = bind.Name,
                    Parent = Row
                })
                Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Mode",
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(1, -134, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextColor3 = on and theme.Accent or theme.TextDim,
                    Text = bind.Mode,
                    Parent = Row
                })
                Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Key",
                    Size = UDim2.new(0, 54, 0, 22),
                    Position = UDim2.new(1, -64, 0, 3),
                    BackgroundColor3 = theme.ElementBg,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = on and theme.Text or theme.TextDim,
                    Text = FormatBind(bind.Key),
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) })
                })
            end
        end
    end

    function WindowObj:SetKeybindListVisible(state)
        KeybindList.Visible = state == true
        WindowObj:RefreshKeybindList()
    end

    -- Keybind engine (Toggle / Hold / Always)
    local function SetBindActive(bind, state)
        if bind.Active == state then return end
        bind.Active = state
        if bind.OnState then
            task.spawn(bind.OnState, state)
        end
        WindowObj:RefreshKeybindList()
    end

    local function MatchesBind(bind, input)
        local key = bind.Key
        if key == nil then return false end
        if key.EnumType == Enum.UserInputType then
            return input.UserInputType == key
        end
        return input.KeyCode == key
    end

    local function CreateBind(parent, props, bOpts)
        local bind = {
            Type = "Keybind",
            Name = bOpts.Name or "Keybind",
            Key = bOpts.Default,
            Value = bOpts.Default,
            Mode = bOpts.Mode or "Toggle",
            Active = false,
            Listening = false,
            ShowInList = bOpts.ShowInList ~= false,
            OnState = bOpts.OnState,
            OnKeyChanged = bOpts.Callback,
            OnModeChanged = bOpts.ModeCallback
        }

        local KeyBtn = Create("TextButton", {
            TextStrokeTransparency = 1,
            Name = "KeybindBtn",
            Size = props.Size,
            Position = props.Position or UDim2.new(),
            BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
            Text = FormatBind(bind.Key),
            Font = Enum.Font.GothamBold,
            TextSize = props.TextSize or 13,
            TextColor3 = WindowObj.ActiveTheme.Text,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Parent = parent
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = WindowObj.ActiveTheme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })
        bind.Button = KeyBtn

        function bind:SetKey(key, silent)
            bind.Key = key
            bind.Value = key
            KeyBtn.Text = FormatBind(key)
            if not silent and bind.OnKeyChanged then
                task.spawn(bind.OnKeyChanged, key)
            end
            WindowObj:RefreshKeybindList()
        end

        function bind:SetMode(mode)
            bind.Mode = mode
            if mode == "Always" then
                SetBindActive(bind, true)
            elseif mode == "Hold" then
                SetBindActive(bind, false)
            end
            if bind.OnModeChanged then
                task.spawn(bind.OnModeChanged, mode)
            end
            WindowObj:RefreshKeybindList()
        end

        function bind:GetState()
            return bind.Active
        end

        KeyBtn.MouseButton1Click:Connect(function()
            bind.Listening = true
            KeyBtn.Text = "..."
            KeyBtn.TextColor3 = WindowObj.ActiveTheme.Accent
        end)

        KeyBtn.MouseButton2Click:Connect(function()
            if bind.Listening or JustClosed(KeyBtn) then return end
            WindowObj:OpenKeybindMenu(KeyBtn, bind.Mode, function(mode)
                bind:SetMode(mode)
            end)
        end)

        table.insert(WindowObj.Keybinds, bind)
        if bind.Mode == "Always" then
            task.defer(SetBindActive, bind, true)
        end
        return bind
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        for _, bind in ipairs(WindowObj.Keybinds) do
            if bind.Listening then
                local t = input.UserInputType
                if t == Enum.UserInputType.Keyboard then
                    bind.Listening = false
                    bind.Button.TextColor3 = WindowObj.ActiveTheme.Text
                    if input.KeyCode == Enum.KeyCode.Escape then
                        bind.Button.Text = FormatBind(bind.Key)
                    elseif input.KeyCode == Enum.KeyCode.Backspace then
                        bind:SetKey(nil)
                    else
                        bind:SetKey(input.KeyCode)
                    end
                elseif t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then
                    bind.Listening = false
                    bind.Button.TextColor3 = WindowObj.ActiveTheme.Text
                    bind:SetKey(t)
                end
            elseif not gpe and bind.Mode ~= "Always" and MatchesBind(bind, input) then
                if bind.Mode == "Toggle" then
                    SetBindActive(bind, not bind.Active)
                else
                    SetBindActive(bind, true)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        for _, bind in ipairs(WindowObj.Keybinds) do
            if bind.Mode == "Hold" and bind.Active and MatchesBind(bind, input) then
                SetBindActive(bind, false)
            end
        end
    end)

    -- Watermark (logo | title | user | fps | ping | time)
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = ActiveTheme.Background,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Create("UIStroke", { Color = ActiveTheme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
    })
    local WatermarkScale = Create("UIScale", { Scale = ScaleVal, Parent = Watermark })
    table.insert(WindowObj.ScaleObjects, WatermarkScale)
    MakeDraggable(Watermark)

    Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = ActiveTheme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Watermark
    }, {
        Create("UIGradient", { Transparency = NumberSequence.new(0, 0.6) })
    })

    local WatermarkContent = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = Watermark
    }, {
        Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 2)
        })
    })

    Create("ImageLabel", {
        Name = "Logo",
        LayoutOrder = 1,
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundTransparency = 1,
        Image = LogoAsset,
        Parent = WatermarkContent
    })

    local WatermarkParts = {}
    local watermarkOrder = 1
    local function WatermarkText(name, text, color)
        watermarkOrder = watermarkOrder + 1
        local label = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = name,
            LayoutOrder = watermarkOrder,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = color,
            Text = text,
            Parent = WatermarkContent
        })
        WatermarkParts[name] = label
        return label
    end

    WatermarkText("Title", Title, ActiveTheme.Accent)
    WatermarkText("Sep1", "|", ActiveTheme.TextDim)
    WatermarkText("User", LocalPlayer and LocalPlayer.Name or "Player", ActiveTheme.Text)
    WatermarkText("Sep2", "|", ActiveTheme.TextDim)
    WatermarkText("FPS", "0 fps", ActiveTheme.Text)
    WatermarkText("Sep3", "|", ActiveTheme.TextDim)
    WatermarkText("Ping", "0 ms", ActiveTheme.Text)
    WatermarkText("Sep4", "|", ActiveTheme.TextDim)
    WatermarkText("Time", os.date("%H:%M"), ActiveTheme.Text)

    local frameCount, lastStatUpdate = 0, os.clock()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        if now - lastStatUpdate >= 0.5 then
            if Watermark.Visible then
                WatermarkParts.FPS.Text = math.floor(frameCount / (now - lastStatUpdate) + 0.5) .. " fps"
                local ok, ping = pcall(function()
                    return LocalPlayer:GetNetworkPing() * 1000
                end)
                WatermarkParts.Ping.Text = (ok and math.floor(ping) or 0) .. " ms"
                WatermarkParts.Time.Text = os.date("%H:%M")
            end
            frameCount, lastStatUpdate = 0, now
        end
    end)

    local WatermarkPositions = {
        ["Top Left"] = { UDim2.new(0, 14, 0, 14), Vector2.new(0, 0) },
        ["Top Right"] = { UDim2.new(1, -14, 0, 14), Vector2.new(1, 0) },
        ["Bottom Left"] = { UDim2.new(0, 14, 1, -14), Vector2.new(0, 1) },
        ["Bottom Right"] = { UDim2.new(1, -14, 1, -14), Vector2.new(1, 1) }
    }

    function WindowObj:SetWatermarkVisible(state)
        Watermark.Visible = state == true
    end

    function WindowObj:SetWatermarkPosition(position)
        local data = WatermarkPositions[position]
        if data then
            Watermark.Position = data[1]
            Watermark.AnchorPoint = data[2]
        end
    end

    function WindowObj:SetWatermarkText(text)
        WatermarkParts.Title.Text = text
    end

    function WindowObj:SetWatermarkColor(color)
        WatermarkParts.Title.TextColor3 = color
        WatermarkParts.Title:SetAttribute("ThemeIgnore", true)
    end

    local NotificationPositions = {
        ["Top Left"] = { UDim2.new(0, 14, 0, 14), Vector2.new(0, 0), Enum.VerticalAlignment.Top, Enum.HorizontalAlignment.Left },
        ["Top Right"] = { UDim2.new(1, -14, 0, 14), Vector2.new(1, 0), Enum.VerticalAlignment.Top, Enum.HorizontalAlignment.Right },
        ["Bottom Left"] = { UDim2.new(0, 14, 1, -14), Vector2.new(0, 1), Enum.VerticalAlignment.Bottom, Enum.HorizontalAlignment.Left },
        ["Bottom Right"] = { UDim2.new(1, -14, 1, -14), Vector2.new(1, 1), Enum.VerticalAlignment.Bottom, Enum.HorizontalAlignment.Right },
    }

    function WindowObj:SetNotificationPosition(position)
        local data = NotificationPositions[position] or NotificationPositions["Bottom Right"]
        NotificationContainer.Position = data[1]
        NotificationContainer.AnchorPoint = data[2]
        local listLayout = NotificationContainer:FindFirstChildOfClass("UIListLayout")
        if listLayout then
            listLayout.VerticalAlignment = data[3]
            listLayout.HorizontalAlignment = data[4]
        end
    end

    -- Visual settings
    function WindowObj:SetStrokesEnabled(state)
        WindowObj.StrokesEnabled = state == true
        for _, d in ipairs(ScreenGui:GetDescendants()) do
            if d:IsA("UIStroke") then
                d.Enabled = WindowObj.StrokesEnabled
            end
        end
    end

    function WindowObj:SetStripesEnabled(state)
        WindowObj.StripesEnabled = state == true
        for _, header in ipairs(WindowObj.Headers) do
            for _, stripe in ipairs(header.Stripes:GetChildren()) do
                stripe.Visible = WindowObj.StripesEnabled
            end
        end
    end

    local FontOptions = {
        ["Gotham"] = Enum.Font.GothamBold,
        ["Arial"] = Enum.Font.ArialBold,
        ["Source Sans"] = Enum.Font.SourceSansBold,
        ["Ubuntu"] = Enum.Font.Ubuntu,
        ["Roboto Mono"] = Enum.Font.RobotoMono
    }

    function WindowObj:SetFont(name)
        local font = FontOptions[name]
        if not font then return end
        for _, d in ipairs(ScreenGui:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                d.Font = font
            end
        end
    end

    -- Theme
    function WindowObj:SetTheme(themeNameOrTable)
        local theme = type(themeNameOrTable) == "table" and themeNameOrTable or fatalwtfuilibrary.Themes[themeNameOrTable]
        if not theme then return end
        local newTheme = table.clone(theme)
        local oldTheme = table.clone(WindowObj.ActiveTheme)

        -- Update WindowObj.ActiveTheme in-place so all closures see new colors
        for k, v in pairs(newTheme) do
            WindowObj.ActiveTheme[k] = v
        end

        RemapColors(oldTheme, newTheme)

        -- Refresh all active toggles with the new Accent/ElementBg colors
        for _, t in ipairs(WindowObj.ActiveToggles or {}) do
            if t.Button and t.Button.Parent then
                if t.GetState() then
                    Tween(t.Button, 0.15, { BackgroundColor3 = newTheme.Accent })
                else
                    local offCol = t.OffColor or newTheme.ElementBg
                    Tween(t.Button, 0.15, { BackgroundColor3 = offCol })
                end
            end
        end

        for _, item in ipairs(WindowObj.ThemeObjects) do
            if item.Instance and item.Instance.Parent then
                local col = newTheme[item.Key]
                if col then
                    item.Instance[item.Property] = col
                end
            end
        end

        for _, header in ipairs(WindowObj.Headers) do
            header.Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, newTheme.Header1),
                ColorSequenceKeypoint.new(0.45, newTheme.Header1),
                ColorSequenceKeypoint.new(1, newTheme.Header2)
            })
            for _, stripe in ipairs(header.Stripes:GetChildren()) do
                stripe.BackgroundColor3 = newTheme.StripeColor
            end
        end

        for _, tab in ipairs(WindowObj.Tabs) do
            if tab == WindowObj.CurrentTab then
                tab.Label.TextColor3 = newTheme.Text
                tab.Icon.ImageColor3 = newTheme.Accent
            else
                tab.Label.TextColor3 = newTheme.TextDim
                tab.Icon.ImageColor3 = newTheme.TextDim
            end
            if tab.MiniTabs and tab.MiniTabs.Buttons then
                for tName, data in pairs(tab.MiniTabs.Buttons) do
                    if tName == tab.MiniTabs.Current and data.Icon then
                        data.Icon.ImageColor3 = newTheme.Accent
                    end
                end
            end
        end
    end

    -- Change a single theme color (used by the theme colorpickers)
    function WindowObj:SetThemeColor(key, color)
        local theme = table.clone(WindowObj.ActiveTheme)
        theme[key] = color
        WindowObj:SetTheme(theme)
    end

    -- Toggle Window Visibility
    function WindowObj:Toggle(state)
        if state == nil then
            WindowObj.Visible = not WindowObj.Visible
        else
            WindowObj.Visible = state
        end

        if WindowObj.Visible then
            Window.Visible = true
            Tween(Window, 0.25, {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 0
            })
            Tween(UIScale, 0.25, { Scale = ScaleVal })
        else
            ClosePopup()
            local tw = Tween(UIScale, 0.2, { Scale = ScaleVal * 0.95 })
            Tween(Window, 0.2, {
                BackgroundTransparency = 1
            })
            tw.Completed:Connect(function()
                if not WindowObj.Visible then
                    Window.Visible = false
                end
            end)
        end
    end

    function WindowObj:SetVisible(state)
        return WindowObj:Toggle(state)
    end

    -- Keybind listener to open/close menu
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == WindowObj.MenuKey then
            WindowObj:Toggle()
        end
    end)

    function WindowObj:SetMenuKey(newKey)
        WindowObj.MenuKey = newKey
        MenuKeyLabel.Text = "Menu: " .. FormatKey(newKey)
    end

    function WindowObj:SetScale(newScale)
        ScaleVal = newScale
        for _, scaleObj in ipairs(WindowObj.ScaleObjects) do
            scaleObj.Scale = newScale
        end
    end

    -- Search filtering
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower():gsub("%s+", "")
        for _, tab in ipairs(WindowObj.Tabs) do
            for _, section in ipairs(tab.Sections) do
                for _, element in ipairs(section.Elements) do
                    if element.SearchableText and element.RowFrame then
                        if query == "" or element.SearchableText:lower():find(query, 1, true) then
                            element.RowFrame.Visible = true
                        else
                            element.RowFrame.Visible = false
                        end
                    end
                end
            end
        end
    end)

    -- Notifications
    local NotifyOrder = 0
    function WindowObj:Notify(nOpts)
        nOpts = nOpts or {}
        if not WindowObj.NotificationsEnabled then return end
        local nTitle = nOpts.Title or "Notice"
        local nContent = nOpts.Content or ""
        local nDuration = nOpts.Duration or 4
        local theme = WindowObj.ActiveTheme
        NotifyOrder = NotifyOrder + 1

        -- Interactive Notification with Buttons (e.g. Staff Notification)
        if nOpts.Buttons or nOpts.Type == "Staff" then
            local buttons = nOpts.Buttons or {
                {
                    Text = "Disable All",
                    Primary = true,
                    Callback = function()
                        WindowObj:Notify({ Title = "Protection", Content = "Disabled all active features.", Duration = 2.5 })
                    end
                },
                {
                    Text = "Keep Enabled",
                    Primary = false,
                    Callback = function()
                        WindowObj:Notify({ Title = "Protection", Content = "Maintained current settings.", Duration = 2.5 })
                    end
                }
            }

            local Holder = Create("Frame", {
                Name = "StaffNotification",
                Size = UDim2.new(0, 320, 0, 118),
                BackgroundTransparency = 1,
                LayoutOrder = NotifyOrder,
                Parent = NotificationContainer
            })

            local Toast = Create("Frame", {
                Name = "Toast",
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 340, 0, 0),
                BackgroundColor3 = Color3.fromRGB(14, 14, 14),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = Holder
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", {
                    Color = Color3.fromRGB(38, 38, 38),
                    Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
                Create("Frame", {
                    Name = "AccentBar",
                    Size = UDim2.new(0, 3, 0, 118),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = theme.Accent,
                    BorderSizePixel = 0
                }),
                Create("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 16, 0, 14),
                    BackgroundTransparency = 1,
                    Image = nOpts.Icon or fatalwtfuilibrary.Icons.Info,
                    ImageColor3 = theme.Accent
                }),
                Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Title",
                    Size = UDim2.new(0, 260, 0, 22),
                    Position = UDim2.new(0, 46, 0, 12),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 16,
                    TextColor3 = Color3.fromRGB(240, 240, 240),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Text = nTitle
                }),
                Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Message",
                    Size = UDim2.new(0, 260, 0, 34),
                    Position = UDim2.new(0, 46, 0, 34),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Text = nContent
                })
            })

            local Track = Create("Frame", {
                Name = "Progress",
                Size = UDim2.new(0, 320, 0, 3),
                Position = UDim2.new(0, 0, 0, 115),
                BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                BorderSizePixel = 0,
                Parent = Toast
            })
            local Fill = Create("Frame", {
                Name = "Fill",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0,
                Parent = Track
            })

            local isClosed = false
            local function dismiss()
                if isClosed then return end
                isClosed = true
                local tw = Tween(Toast, 0.25, { Position = UDim2.new(0, 340, 0, 0) })
                tw.Completed:Connect(function()
                    Holder:Destroy()
                end)
            end

            for idx, btnData in ipairs(buttons) do
                local isPrimary = (btnData.Primary == true) or (idx == 1 and btnData.Primary ~= false)
                local btnPos = (idx == 1) and UDim2.new(0, 16, 0, 78) or UDim2.new(0, 164, 0, 78)
                local btnSize = (#buttons == 1) and UDim2.new(0, 288, 0, 30) or UDim2.new(0, 140, 0, 30)

                local Btn = Create("TextButton", {
            TextStrokeTransparency = 1,
                    Name = isPrimary and "DisableAllButton" or "KeepEnabledButton",
                    Size = btnSize,
                    Position = btnPos,
                    BackgroundColor3 = isPrimary and theme.Accent or Color3.fromRGB(26, 26, 26),
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = Toast
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", {
                        Color = Color3.fromRGB(41, 41, 41),
                        Thickness = 1,
                        Transparency = isPrimary and 1 or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
                    Create("TextLabel", {
            TextStrokeTransparency = 1,
                        Name = "Text",
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = isPrimary and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200),
                        Text = btnData.Text or (isPrimary and "Disable All" or "Keep Enabled")
                    })
                })

                local btnStroke = Btn:FindFirstChildOfClass("UIStroke")
                Btn.MouseEnter:Connect(function()
                    if btnStroke then
                        Tween(btnStroke, 0.15, { Transparency = 0 })
                    end
                end)
                Btn.MouseLeave:Connect(function()
                    if btnStroke and isPrimary then
                        Tween(btnStroke, 0.15, { Transparency = 1 })
                    end
                end)

                Btn.MouseButton1Click:Connect(function()
                    if btnData.Callback then
                        task.spawn(btnData.Callback, dismiss)
                    end
                    dismiss()
                end)
            end

            Tween(Toast, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
            Tween(Fill, nDuration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)

            task.delay(nDuration, function()
                dismiss()
            end)

            return {
                Holder = Holder,
                Close = dismiss
            }
        end

        local textSize = TextService:GetTextSize(nContent, 14, Enum.Font.GothamBold, Vector2.new(254, 1000))
        local height = math.max(70, 44 + textSize.Y + 14)

        local Holder = Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(0, 320, 0, height),
            BackgroundTransparency = 1,
            LayoutOrder = NotifyOrder,
            Parent = NotificationContainer
        })

        local Toast = Create("Frame", {
            Name = "Toast",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 340, 0, 0),
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = Holder
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
            Create("Frame", {
                Name = "AccentBar",
                Size = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0
            }),
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 16, 0, 14),
                BackgroundTransparency = 1,
                Image = nOpts.Icon or fatalwtfuilibrary.Icons.Info,
                ImageColor3 = theme.Accent
            }),
            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Title",
                Size = UDim2.new(1, -60, 0, 22),
                Position = UDim2.new(0, 46, 0, 12),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = nTitle
            }),
            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Content",
                Size = UDim2.new(1, -60, 0, textSize.Y),
                Position = UDim2.new(0, 46, 0, 36),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = theme.TextDim,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Text = nContent
            })
        })

        local Track = Create("Frame", {
            Name = "Progress",
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 1, -3),
            BackgroundColor3 = theme.ElementBg,
            BorderSizePixel = 0,
            Parent = Toast
        })
        local Fill = Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Parent = Track
        })

        Tween(Toast, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
        Tween(Fill, nDuration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)

        task.delay(nDuration, function()
            local tw = Tween(Toast, 0.25, { Position = UDim2.new(0, 340, 0, 0) })
            tw.Completed:Connect(function()
                Holder:Destroy()
            end)
        end)
    end

    -- Tab creation
    function WindowObj:CreateTab(tabOpts)
        tabOpts = tabOpts or {}
        local TabName = tabOpts.Name or "Tab"
        local TabIcon = tabOpts.Icon or fatalwtfuilibrary.Icons[TabName] or fatalwtfuilibrary.Icons.Visual

        local tabIndex = #WindowObj.Tabs + 1
        local TabBtn = Create("TextButton", {
            TextStrokeTransparency = 1,
            Name = TabName .. "Tab",
            Size = UDim2.new(0, 0, 0, 36),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = "",
            LayoutOrder = tabOpts.LayoutOrder or (TabName:lower() == "config" and 999 or tabIndex),
            Parent = TabsContainer
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 10)
            })
        })

        local TabIconImg = Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 23, 0, 23),
            BackgroundTransparency = 1,
            Image = TabIcon,
            ImageColor3 = WindowObj.ActiveTheme.TextDim,
            Parent = TabBtn
        })

        local TabText = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Text",
            Size = UDim2.new(0, 0, 0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBlack,
            TextSize = 16,
            TextColor3 = WindowObj.ActiveTheme.TextDim,
            Text = TabName,
            Parent = TabBtn
        })

        -- Page Frame (2 Columns: Left & Right, matching 408x406 cards or dynamic height)
        local PageFrame = Create("Frame", {
            Name = TabName .. "Page",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = PagesContainer
        })

        local LeftColumn = Create("ScrollingFrame", {
            Name = "LeftColumn",
            Size = UDim2.new(0, 412, 1, -10),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = PageFrame
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 14),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })

        local RightColumn = Create("ScrollingFrame", {
            Name = "RightColumn",
            Size = UDim2.new(0, 412, 1, -10),
            Position = UDim2.new(0, 431, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = PageFrame
        }, {
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 14),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })

        local TabObj = {
            Name = TabName,
            Button = TabBtn,
            Icon = TabIconImg,
            Label = TabText,
            Page = PageFrame,
            LeftCol = LeftColumn,
            RightCol = RightColumn,
            Sections = {},
            Window = WindowObj
        }

        function TabObj:Select()
            for _, t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                Tween(t.Label, 0.15, { TextColor3 = WindowObj.ActiveTheme.TextDim })
                Tween(t.Icon, 0.15, { ImageColor3 = WindowObj.ActiveTheme.TextDim })
            end
            WindowObj.CurrentTab = TabObj
            TabObj.Page.Visible = true
            Tween(TabObj.Label, 0.15, { TextColor3 = WindowObj.ActiveTheme.Text })
            Tween(TabObj.Icon, 0.15, { ImageColor3 = WindowObj.ActiveTheme.Accent })
        end

        TabBtn.MouseButton1Click:Connect(function()
            TabObj:Select()
        end)

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 then
            TabObj:Select()
        end

        -- Mini Tabs / Subtabs switcher (Works on ANY tab/page)
        function TabObj:CreateMiniTabs(mOpts)
            mOpts = mOpts or {}
            local rawTabs = mOpts.Tabs or { "Subtab 1", "Subtab 2" }
            local tabsOrder = {}
            local tabsData = {}

            -- Adjust columns downward to accommodate MiniTabs bar (Y = 48, matching Studio offset)
            LeftColumn.Position = UDim2.new(0, 10, 0, 48)
            LeftColumn.Size = UDim2.new(0, 412, 1, -54)
            RightColumn.Position = UDim2.new(0, 431, 0, 48)
            RightColumn.Size = UDim2.new(0, 412, 1, -54)

            local MiniTabsBar = Create("Frame", {
                Name = "MiniTabs",
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 8),
                BackgroundTransparency = 1,
                Parent = PageFrame
            })

            local MiniTabButtons = {}
            local defaultTab = mOpts.Default or (type(rawTabs[1]) == "table" and rawTabs[1].Name or rawTabs[1])

            local MiniTabObj = {
                Bar = MiniTabsBar,
                Current = defaultTab,
                Buttons = MiniTabButtons,
                SubTabs = {},
                TabsOrder = tabsOrder
            }

            local function realignTabs()
                local count = #tabsOrder
                if count == 0 then return end
                for idx, tName in ipairs(tabsOrder) do
                    local btnData = MiniTabButtons[tName]
                    if btnData and btnData.Button then
                        btnData.Button.Size = UDim2.new(1 / count, 0, 1, 0)
                        btnData.Button.Position = UDim2.new((idx - 1) / count, 0, 0, 0)
                    end
                end
            end

            function MiniTabObj:GetTab(name)
                if MiniTabObj.SubTabs[name] then return MiniTabObj.SubTabs[name] end
                local sub = {
                    Name = name,
                    CreateSection = function(_, secOpts)
                        secOpts = secOpts or {}
                        secOpts.MiniTab = name
                        secOpts.SubTab = name
                        return TabObj:CreateSection(secOpts)
                    end,
                    AddSection = function(_, secOpts)
                        secOpts = secOpts or {}
                        secOpts.MiniTab = name
                        secOpts.SubTab = name
                        return TabObj:CreateSection(secOpts)
                    end
                }
                MiniTabObj.SubTabs[name] = sub
                return sub
            end

            function MiniTabObj:Select(name)
                MiniTabObj.Current = name
                for tName, data in pairs(MiniTabButtons) do
                    local isSel = (tName == name)
                    Tween(data.Icon, 0.15, { ImageColor3 = isSel and WindowObj.ActiveTheme.Accent or Color3.fromRGB(130, 130, 130) })
                    Tween(data.Label, 0.15, { TextColor3 = isSel and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(130, 130, 130) })
                end

                for _, sec in ipairs(TabObj.Sections) do
                    local secTarget = sec.MiniTab or sec.SubTab
                    if secTarget and secTarget ~= "All" then
                        sec.Card.Visible = (secTarget == name)
                    end
                end

                if mOpts.OnChange then
                    task.spawn(mOpts.OnChange, name)
                end
            end

            function MiniTabObj:AddTab(tabItem)
                local tName = (type(tabItem) == "table" and tabItem.Name) or tabItem
                if MiniTabButtons[tName] then return MiniTabObj:GetTab(tName) end

                local tIcon = (type(tabItem) == "table" and tabItem.Icon)
                    or mOpts.Icon
                    or fatalwtfuilibrary.Icons[tName]
                    or TabObj.Icon.Image
                    or "rbxassetid://76535961115022"

                table.insert(tabsOrder, tName)

                local Btn = Create("TextButton", {
            TextStrokeTransparency = 1,
                    Name = tName:gsub("%s+", "") .. "Mini",
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = MiniTabsBar
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 10)
                    })
                })

                local IconContainer = Create("Frame", {
                    Name = "Icon",
                    Size = UDim2.new(0, 23, 0, 23),
                    BackgroundTransparency = 1,
                    Parent = Btn
                })

                local IconImg = Create("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = tIcon,
                    ImageColor3 = (tName == MiniTabObj.Current) and WindowObj.ActiveTheme.Accent or Color3.fromRGB(130, 130, 130),
                    Parent = IconContainer
                })

                local Label = Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Text",
                    Size = UDim2.new(0, 0, 0, 20),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBlack,
                    TextSize = 16,
                    TextColor3 = (tName == MiniTabObj.Current) and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(130, 130, 130),
                    Text = tName,
                    Parent = Btn
                })

                MiniTabButtons[tName] = {
                    Button = Btn,
                    Icon = IconImg,
                    Label = Label
                }

                Btn.MouseButton1Click:Connect(function()
                    MiniTabObj:Select(tName)
                end)

                realignTabs()
                return MiniTabObj:GetTab(tName)
            end

            for _, tabItem in ipairs(rawTabs) do
                MiniTabObj:AddTab(tabItem)
            end

            -- Initialize active state and visibility
            MiniTabObj:Select(defaultTab)

            TabObj.MiniTabs = MiniTabObj
            TabObj.SubTabs = MiniTabObj
            return MiniTabObj
        end
        TabObj.CreateSubTabs = TabObj.CreateMiniTabs

        -- Section creation
        function TabObj:CreateSection(secOpts)
            secOpts = secOpts or {}
            local SecName = secOpts.Name or "Section"
            local Side = secOpts.Side or (#TabObj.Sections % 2 == 0 and "Left" or "Right")
            local TargetCol = (Side:lower() == "right") and RightColumn or LeftColumn

            -- Section Card Frame
            local Card = Create("Frame", {
                Name = SecName,
                Size = UDim2.new(1, -6, 0, secOpts.Height or 410),
                AutomaticSize = Enum.AutomaticSize.None,
                BackgroundColor3 = WindowObj.ActiveTheme.SectionBg,
                BorderSizePixel = 0,
                Parent = TargetCol
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", {
                    Color = WindowObj.ActiveTheme.Stroke,
                    Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
            })

            RegisterTheme(Card, "BackgroundColor3", "SectionBg")

            -- Section header: diagonal stripes & gradient
            local HeaderCanvas, HeaderGrad, StripesFolder = BuildStripedHeader(Card, 38)

            local HeaderLineSec = Create("Frame", {
                Name = "HeaderLine",
                Size = UDim2.new(1, 0, 0, 2),
                Position = UDim2.new(0, 0, 0, 37),
                BackgroundColor3 = WindowObj.ActiveTheme.Accent,
                BorderSizePixel = 0,
                Parent = Card
            })

            local SecTitle = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Title",
                Size = UDim2.new(1, -40, 0, 38),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = WindowObj.ActiveTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = SecName,
                Parent = Card
            })

            local InfoIcon = Create("ImageLabel", {
                Name = "InfoIcon",
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -34, 0, 7),
                BackgroundTransparency = 1,
                Image = fatalwtfuilibrary.Icons.Info,
                ImageColor3 = WindowObj.ActiveTheme.TextDim,
                Parent = Card
            })

            -- Content Scrolling Container for Section Elements
            local ContentArea = Create("ScrollingFrame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 1, -42),
                Position = UDim2.new(0, 0, 0, 42),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = Card
            }, {
                Create("UIPadding", {
                    PaddingTop = UDim.new(0, 6),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                }),
                Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Vertical,
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            })

            local SecObj = {
                Name = SecName,
                Card = Card,
                ContentArea = ContentArea,
                HeaderGradient = HeaderGrad,
                StripesFolder = StripesFolder,
                Elements = {},
                Tab = TabObj,
                Window = WindowObj,
                MiniTab = secOpts.MiniTab
            }

            local subTabTarget = secOpts.MiniTab or secOpts.SubTab
            if subTabTarget and subTabTarget ~= "All" and TabObj.MiniTabs then
                Card.Visible = (TabObj.MiniTabs.Current == subTabTarget)
            end

            table.insert(TabObj.Sections, SecObj)

            -- Dual Toggle (Two toggles side by side in one row)
            function SecObj:CreateDualToggle(dOpts)
                dOpts = dOpts or {}
                local leftOpts = dOpts.Left or {}
                local rightOpts = dOpts.Right or {}

                local Row = Create("Frame", {
                    Name = (leftOpts.Name or "Dual") .. "Row",
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local function makeToggleHalf(opts, posX, sizeX)
                    local tName = opts.Name or "Toggle"
                    local state = opts.Default == true
                    local callback = opts.Callback or function() end

                    local HalfContainer = Create("Frame", {
                        Name = tName .. "Half",
                        Size = sizeX,
                        Position = posX,
                        BackgroundTransparency = 1,
                        Parent = Row
                    })

                    local Label = Create("TextLabel", {
            TextStrokeTransparency = 1,
                        Name = "Label",
                        Size = UDim2.new(1, -34, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = WindowObj.ActiveTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Text = tName,
                        Parent = HalfContainer
                    })

                    local ToggleBtn = Create("TextButton", {
            TextStrokeTransparency = 1,
                        Name = "Toggle",
                        Size = UDim2.new(0, 26, 0, 26),
                        Position = UDim2.new(1, -26, 0.5, -13),
                        BackgroundColor3 = state and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.ElementBg,
                        BorderSizePixel = 0,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = HalfContainer
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", {
                            Color = WindowObj.ActiveTheme.Stroke,
                            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
                    })

                    local CheckShort = Create("Frame", {
                        Name = "CheckShort",
                        Size = UDim2.new(0, 3, 0, 8),
                        Position = UDim2.new(0, 7, 0, 11),
                        Rotation = -45,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Visible = state,
                        Parent = ToggleBtn
                    })

                    local CheckLong = Create("Frame", {
                        Name = "CheckLong",
                        Size = UDim2.new(0, 3, 0, 13),
                        Position = UDim2.new(0, 13, 0, 6),
                        Rotation = 40,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Visible = state,
                        Parent = ToggleBtn
                    })

                    local itemObj = {
                        Type = "Toggle",
                        Name = tName,
                        Value = state,
                        Button = ToggleBtn
                    }

                    function itemObj:Set(val)
                        itemObj.Value = val
                        CheckShort.Visible = val
                        CheckLong.Visible = val
                        Tween(ToggleBtn, 0.15, {
                            BackgroundColor3 = val and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.ElementBg
                        })
                        pcall(callback, val)
                    end

                    ToggleBtn.MouseButton1Click:Connect(function()
                        itemObj:Set(not itemObj.Value)
                    end)

                    local btnStroke = ToggleBtn:FindFirstChildOfClass("UIStroke")
                    ToggleBtn.MouseEnter:Connect(function()
                        if btnStroke then Tween(btnStroke, 0.15, { Transparency = 0 }) end
                    end)
                    ToggleBtn.MouseLeave:Connect(function()
                        if btnStroke then Tween(btnStroke, 0.15, { Transparency = 0.5 }) end
                    end)

                    if opts.Flag then
                        WindowObj.Flags[opts.Flag] = itemObj
                    end

                    return itemObj
                end

                local LeftObj = makeToggleHalf(leftOpts, UDim2.new(0, 2, 0, 0), UDim2.new(0.5, -8, 1, 0))
                local RightObj = makeToggleHalf(rightOpts, UDim2.new(0.5, 6, 0, 0), UDim2.new(0.5, -8, 1, 0))

                local dualObj = {
                    Type = "DualToggle",
                    Left = LeftObj,
                    Right = RightObj,
                    RowFrame = Row
                }
                table.insert(SecObj.Elements, dualObj)
                table.insert(WindowObj.ActiveToggles, {
                    Button = LeftObj.Button,
                    GetState = function() return LeftObj.Value end
                })
                table.insert(WindowObj.ActiveToggles, {
                    Button = RightObj.Button,
                    GetState = function() return RightObj.Value end
                })
                return dualObj
            end

            -- Toggle
            function SecObj:CreateToggle(tOpts)
                tOpts = tOpts or {}
                local TName = tOpts.Name or "Toggle"
                local State = tOpts.Default == true
                local Callback = tOpts.Callback or function() end

                local Row = Create("Frame", {
                    Name = TName .. "Row",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Label",
                    Size = UDim2.new(1, -120, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = TName,
                    Parent = Row
                })

                local ToggleBtn = Create("TextButton", {
            TextStrokeTransparency = 1,
                    Name = "Toggle",
                    Size = UDim2.new(0, 26, 0, 26),
                    Position = UDim2.new(1, -28, 0, 2),
                    BackgroundColor3 = State and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    Text = "",
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    })
                })

                -- Checkmark lines
                local CheckShort = Create("Frame", {
                    Name = "CheckShort",
                    Size = UDim2.new(0, 3, 0, 8),
                    Position = UDim2.new(0, 7, 0, 11),
                    Rotation = -45,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Visible = State,
                    Parent = ToggleBtn
                })

                local CheckLong = Create("Frame", {
                    Name = "CheckLong",
                    Size = UDim2.new(0, 3, 0, 13),
                    Position = UDim2.new(0, 13, 0, 6),
                    Rotation = 40,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Visible = State,
                    Parent = ToggleBtn
                })

                local ExtraControls = Create("Frame", {
                    Name = "Extras",
                    Size = UDim2.new(0, 200, 1, 0),
                    Position = UDim2.new(1, -234, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = Row
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 8)
                    })
                })

                local ToggleObj = {
                    Type = "Toggle",
                    Name = TName,
                    Value = State,
                    RowFrame = Row,
                    SearchableText = TName,
                    ExtrasContainer = ExtraControls
                }

                function ToggleObj:SetValue(val)
                    State = val == true
                    ToggleObj.Value = State
                    CheckShort.Visible = State
                    CheckLong.Visible = State
                    Tween(ToggleBtn, 0.15, {
                        BackgroundColor3 = State and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.ElementBg
                    })
                    if ToggleObj.Bind and ToggleObj.Bind.Active ~= State then
                        ToggleObj.Bind.Active = State
                        WindowObj:RefreshKeybindList()
                    end
                    task.spawn(Callback, State)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    ToggleObj:SetValue(not State)
                end)

                -- Colorbox next to the toggle (click to open the colorpicker)
                local colorCount = 0
                function ToggleObj:AddColorpicker(cpOpts)
                    cpOpts = cpOpts or {}
                    colorCount = colorCount + 1
                    local index = colorCount
                    local ColorVal = cpOpts.Default or Color3.fromRGB(255, 255, 255)
                    local Transp = cpOpts.Transparency or 0
                    local cpCallback = cpOpts.Callback or function() end
                    local cpName = cpOpts.Name or (TName .. " Color")

                    local ColorBox = Create("TextButton", {
            TextStrokeTransparency = 1,
                        Name = "ColorBox" .. index,
                        Size = UDim2.new(0, 33, 0, 26),
                        BackgroundColor3 = ColorVal,
                        AutoButtonColor = false,
                        Text = "",
                        BorderSizePixel = 0,
                        LayoutOrder = index,
                        Parent = ExtraControls
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", {
                            Color = WindowObj.ActiveTheme.Stroke,
                            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
                    })
                    ColorBox:SetAttribute("ThemeIgnore", true)

                    local CPObj = {
                        Type = "Colorpicker",
                        Name = cpName,
                        Value = ColorVal,
                        Transparency = Transp
                    }

                    function CPObj:SetValue(newCol, newTransp, silent)
                        ColorVal = newCol
                        Transp = newTransp or Transp
                        CPObj.Value = newCol
                        CPObj.Transparency = Transp
                        ColorBox.BackgroundColor3 = newCol
                        if not silent then
                            task.spawn(cpCallback, newCol, Transp)
                        end
                    end

                    ColorBox.MouseButton1Click:Connect(function()
                        if JustClosed(ColorBox) then return end
                        WindowObj:OpenColorpickerPopup(ColorVal, function(c, t)
                            CPObj:SetValue(c, t)
                        end, {
                            Title = cpName,
                            Anchor = ColorBox,
                            Transparency = Transp
                        })
                    end)

                    RegisterFlag(cpOpts.Flag or (ToggleObj.Flag .. ".Color" .. index), CPObj)
                    return CPObj
                end

                -- Keybind next to the toggle (right click for Toggle / Hold / Always)
                function ToggleObj:AddKeybind(kbOpts)
                    kbOpts = kbOpts or {}
                    local bind = CreateBind(ExtraControls, { Size = UDim2.new(0, 54, 0, 24) }, {
                        Name = kbOpts.Name or TName,
                        Default = kbOpts.Default,
                        Mode = kbOpts.Mode or "Toggle",
                        Callback = kbOpts.Callback,
                        ModeCallback = kbOpts.ModeCallback,
                        ShowInList = kbOpts.ShowInList,
                        OnState = function(active)
                            if ToggleObj.Value ~= active then
                                ToggleObj:SetValue(active)
                            end
                            if kbOpts.OnState then
                                pcall(kbOpts.OnState, active)
                            end
                        end
                    })
                    bind.Button.LayoutOrder = 100
                    bind.Active = ToggleObj.Value
                    ToggleObj.Bind = bind
                    RegisterFlag(kbOpts.Flag or (ToggleObj.Flag .. ".Key"), bind)
                    WindowObj:RefreshKeybindList()
                    return bind
                end

                RegisterFlag(tOpts.Flag or (TabName .. "." .. SecName .. "." .. TName), ToggleObj)
                table.insert(SecObj.Elements, ToggleObj)
                table.insert(WindowObj.ActiveToggles, {
                    Button = ToggleBtn,
                    GetState = function() return ToggleObj.Value end
                })
                return ToggleObj
            end

            -- Slider
            function SecObj:CreateSlider(sOpts)
                sOpts = sOpts or {}
                local SName = sOpts.Name or "Slider"
                local Min = sOpts.Min or 0
                local Max = sOpts.Max or 100
                local Def = math.clamp(sOpts.Default or Min, Min, Max)
                local Decimals = sOpts.Decimals or 0
                local Unit = sOpts.Unit or ""
                local Callback = sOpts.Callback or function() end

                local CurrentVal = Def

                local Row = Create("Frame", {
                    Name = SName .. "SliderRow",
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Label",
                    Size = UDim2.new(1, -70, 0, 20),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = SName,
                    Parent = Row
                })

                local ValueLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Value",
                    Size = UDim2.new(0, 65, 0, 20),
                    Position = UDim2.new(1, -67, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = WindowObj.ActiveTheme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Text = string.format("%." .. Decimals .. "f", CurrentVal) .. Unit,
                    Parent = Row
                })

                -- Slider Track (CanvasGroup with diagonal stripes)
                local Track = Create("CanvasGroup", {
                    Name = "SliderTrack",
                    Size = UDim2.new(1, -4, 0, 14),
                    Position = UDim2.new(0, 2, 0, 24),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) })
                })

                -- Diagonal stripes in slider track
                for i = 1, 75 do
                    Create("Frame", {
                        Name = "Stripe",
                        Size = UDim2.new(0, 2, 0, 42),
                        Position = UDim2.new(0, -14 + (i - 1) * 5, 0, -14),
                        Rotation = 45,
                        BackgroundColor3 = WindowObj.ActiveTheme.SliderStripe,
                        BorderSizePixel = 0,
                        Parent = Track
                    })
                end

                local initAlpha = (CurrentVal - Min) / (Max - Min)
                local Fill = Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new(initAlpha, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = WindowObj.ActiveTheme.Accent,
                    BorderSizePixel = 0,
                    Parent = Track
                })

                local SliderObj = {
                    Type = "Slider",
                    Name = SName,
                    Value = CurrentVal,
                    RowFrame = Row,
                    SearchableText = SName
                }

                local function UpdateFromInput(input)
                    local trackAbs = Track.AbsolutePosition
                    local trackSize = Track.AbsoluteSize
                    local x = math.clamp(input.Position.X - trackAbs.X, 0, trackSize.X)
                    local alpha = x / trackSize.X
                    local rawVal = Min + (Max - Min) * alpha
                    local mult = 10 ^ Decimals
                    local stepped = math.round(rawVal * mult) / mult

                    CurrentVal = stepped
                    SliderObj.Value = CurrentVal
                    Fill.Size = UDim2.new(alpha, 0, 1, 0)
                    ValueLabel.Text = string.format("%." .. Decimals .. "f", CurrentVal) .. Unit
                    task.spawn(Callback, CurrentVal)
                end

                local dragging = false
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateFromInput(input)
                    end
                end)

                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateFromInput(input)
                    end
                end)

                function SliderObj:SetValue(val)
                    CurrentVal = math.clamp(val, Min, Max)
                    SliderObj.Value = CurrentVal
                    local alpha = (CurrentVal - Min) / (Max - Min)
                    Fill.Size = UDim2.new(alpha, 0, 1, 0)
                    ValueLabel.Text = string.format("%." .. Decimals .. "f", CurrentVal) .. Unit
                    task.spawn(Callback, CurrentVal)
                end

                RegisterFlag(sOpts.Flag or (TabName .. "." .. SecName .. "." .. SName), SliderObj)
                table.insert(SecObj.Elements, SliderObj)
                return SliderObj
            end

            -- Dropdown
            function SecObj:CreateDropdown(dOpts)
                dOpts = dOpts or {}
                local DName = dOpts.Name or "Dropdown"
                local Options = dOpts.Options or {}
                local isMulti = dOpts.Multi == true
                local Callback = dOpts.Callback or function() end

                local Selected = nil

                local function FormatDisplay(val)
                    if type(val) == "table" then
                        local chosen = {}
                        if #val > 0 then
                            for _, v in ipairs(val) do table.insert(chosen, tostring(v)) end
                        else
                            for k, v in pairs(val) do
                                if v == true then table.insert(chosen, tostring(k)) end
                            end
                        end
                        if #chosen == 0 then return "None" end
                        if #Options > 0 and #chosen == #Options then return "All" end
                        return table.concat(chosen, ", ")
                    end
                    return tostring(val or "")
                end

                if isMulti then
                    local map = {}
                    if type(dOpts.Default) == "table" then
                        if #dOpts.Default > 0 then
                            for _, v in ipairs(dOpts.Default) do map[v] = true end
                        else
                            for k, v in pairs(dOpts.Default) do if v == true then map[k] = true end end
                        end
                    elseif dOpts.Default ~= nil then
                        map[tostring(dOpts.Default)] = true
                    end
                    Selected = map
                else
                    local Def = dOpts.Default or (Options[1] or "")
                    if type(Def) == "number" and Options[Def] then
                        Def = Options[Def]
                    end
                    Selected = Def
                end

                local isOpen = false
                local DropObj

                local Row = Create("Frame", {
                    Name = DName .. "DropdownRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local Label = Create("TextLabel", {
                    TextStrokeTransparency = 1,
                    Name = "Label",
                    Size = UDim2.new(1, -140, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = DName,
                    Parent = Row
                })

                -- Dropdown Box
                local DropBox = Create("TextButton", {
                    TextStrokeTransparency = 1,
                    Name = "Box",
                    Size = UDim2.new(0, 92, 0, 32),
                    Position = UDim2.new(1, -132, 0, 2),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    Text = "",
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    }),
                    Create("TextLabel", {
                        TextStrokeTransparency = 1,
                        Name = "Value",
                        Size = UDim2.new(1, -10, 1, 0),
                        Position = UDim2.new(0, 5, 0, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = WindowObj.ActiveTheme.Text,
                        Text = FormatDisplay(Selected),
                        TextTruncate = Enum.TextTruncate.AtEnd
                    })
                })

                -- Dropdown Arrow with procedural chevrons
                local ArrowBtn = Create("TextButton", {
                    TextStrokeTransparency = 1,
                    Name = "Arrow",
                    Size = UDim2.new(0, 34, 0, 32),
                    Position = UDim2.new(1, -36, 0, 2),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    Text = "",
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    })
                })

                local ChevL = Create("Frame", {
                    Name = "ChevL",
                    Size = UDim2.new(0, 2, 0, 8),
                    Position = UDim2.new(0, 13, 0, 13),
                    Rotation = -45,
                    BackgroundColor3 = WindowObj.ActiveTheme.TextDim,
                    BorderSizePixel = 0,
                    Parent = ArrowBtn
                })

                local ChevR = Create("Frame", {
                    Name = "ChevR",
                    Size = UDim2.new(0, 2, 0, 8),
                    Position = UDim2.new(0, 18, 0, 13),
                    Rotation = 45,
                    BackgroundColor3 = WindowObj.ActiveTheme.TextDim,
                    BorderSizePixel = 0,
                    Parent = ArrowBtn
                })

                -- Floating popup menu
                local DropList = Create("ScrollingFrame", {
                    Name = "FloatingOptions",
                    Size = UDim2.new(0, 128, 0, 0),
                    BackgroundColor3 = WindowObj.ActiveTheme.SectionBg,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Visible = false,
                    ZIndex = 60,
                    Parent = OverlayContainer
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    }),
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 2)
                    })
                })

                local function PopulateOptions()
                    for _, ch in ipairs(DropList:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _, opt in ipairs(Options) do
                        local isOptSelected = false
                        if isMulti then
                            isOptSelected = (Selected[opt] == true)
                        else
                            isOptSelected = (opt == Selected)
                        end

                        local OptBtn = Create("TextButton", {
                            TextStrokeTransparency = 1,
                            Name = "Opt_" .. tostring(opt),
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = isOptSelected and WindowObj.ActiveTheme.ElementBg or Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = isOptSelected and 0 or 1,
                            BorderSizePixel = 0,
                            Font = Enum.Font.GothamBold,
                            TextSize = 13,
                            TextColor3 = isOptSelected and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.Text,
                            Text = (isMulti and (isOptSelected and "✓ " or "  ") or "") .. tostring(opt),
                            ZIndex = 61,
                            Parent = DropList
                        })

                        OptBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                Selected[opt] = not Selected[opt]
                                if DropObj then DropObj.Value = Selected end
                                DropBox.Value.Text = FormatDisplay(Selected)
                                PopulateOptions()
                                task.spawn(Callback, Selected)
                            else
                                Selected = opt
                                if DropObj then DropObj.Value = opt end
                                DropBox.Value.Text = FormatDisplay(Selected)
                                ClosePopup()
                                task.spawn(Callback, Selected)
                            end
                        end)
                    end
                end

                local function CloseList()
                    isOpen = false
                    DropList.Visible = false
                    ChevL.Rotation = -45
                    ChevR.Rotation = 45
                end

                local function ToggleOpen()
                    if isOpen then
                        ClosePopup()
                        return
                    end
                    if JustClosed(Row) then return end
                    isOpen = true
                    PopulateOptions()
                    local rel = ToWindowSpace(DropBox.AbsolutePosition)
                    local maxH = math.min(#Options * 30 + 4, 150)
                    DropList.Position = UDim2.new(0, rel.X, 0, rel.Y + 36)
                    DropList.Size = UDim2.new(0, 128, 0, maxH)
                    DropList.Visible = true
                    ChevL.Rotation = 45
                    ChevR.Rotation = -45
                    OpenPopup(DropList, CloseList, Row)
                end

                DropBox.MouseButton1Click:Connect(ToggleOpen)
                ArrowBtn.MouseButton1Click:Connect(ToggleOpen)

                DropObj = {
                    Type = "Dropdown",
                    Name = DName,
                    Value = Selected,
                    RowFrame = Row,
                    SearchableText = DName
                }

                function DropObj:Set(val)
                    if isMulti then
                        if type(val) == "table" then
                            local map = {}
                            if #val > 0 then
                                for _, v in ipairs(val) do map[v] = true end
                            else
                                for k, v in pairs(val) do if v == true then map[k] = true end end
                            end
                            Selected = map
                        else
                            Selected = { [tostring(val)] = true }
                        end
                    else
                        Selected = val
                    end
                    DropObj.Value = Selected
                    DropBox.Value.Text = FormatDisplay(Selected)
                    task.spawn(Callback, Selected)
                end

                DropObj.SetValue = DropObj.Set

                function DropObj:SetOptions(newOpts)
                    Options = newOpts or {}
                    if not isMulti then
                        if not table.find(Options, Selected) then
                            Selected = Options[1] or ""
                            DropObj.Value = Selected
                            DropBox.Value.Text = FormatDisplay(Selected)
                        end
                    end
                    PopulateOptions()
                end

                DropObj.Refresh = DropObj.SetOptions

                RegisterFlag(dOpts.Flag or (TabName .. "." .. SecName .. "." .. DName), DropObj)
                table.insert(SecObj.Elements, DropObj)
                return DropObj
            end

            -- Button
            local function NewButton(parent, bOpts, size, position)
                local Btn = Create("TextButton", {
            TextStrokeTransparency = 1,
                    Name = "Button",
                    Size = size,
                    Position = position or UDim2.new(),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    Text = bOpts.Name or "Button",
                    Parent = parent
                })
                return SetupButton(Btn, bOpts)
            end

            function SecObj:CreateButton(bOpts)
                bOpts = bOpts or {}
                local BName = bOpts.Name or "Button"

                local Row = Create("Frame", {
                    Name = BName .. "ButtonRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local BtnObj = NewButton(Row, bOpts, UDim2.new(1, -4, 0, 32), UDim2.new(0, 2, 0, 2))
                BtnObj.Type = "Button"
                BtnObj.Name = BName
                BtnObj.RowFrame = Row
                BtnObj.SearchableText = BName

                table.insert(SecObj.Elements, BtnObj)
                return BtnObj
            end

            -- Button row (buttons side by side, e.g. Load / Create / Delete)
            function SecObj:CreateButtonRow(buttons)
                buttons = buttons or {}

                local Row = Create("Frame", {
                    Name = "ButtonRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                }, {
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 2),
                        PaddingRight = UDim.new(0, 2)
                    }),
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 6)
                    })
                })

                local count = math.max(#buttons, 1)
                local gap = math.ceil(6 * (count - 1) / count)
                local objs = {}
                local names = {}
                for i, b in ipairs(buttons) do
                    local obj = NewButton(Row, b, UDim2.new(1 / count, -gap, 0, 32))
                    obj.Instance.Name = (b.Name or "Button") .. "Button"
                    obj.Instance.LayoutOrder = i
                    objs[i] = obj
                    table.insert(names, b.Name or "")
                end

                table.insert(SecObj.Elements, {
                    Type = "ButtonRow",
                    RowFrame = Row,
                    SearchableText = table.concat(names, "")
                })
                return objs
            end

            -- TextBox
            function SecObj:CreateTextBox(tbOpts)
                tbOpts = tbOpts or {}
                local TBName = tbOpts.Name or "TextBox"
                local Placeholder = tbOpts.Placeholder or "Enter text..."
                local Def = tbOpts.Default or ""
                local ClearOnFocus = tbOpts.ClearTextOnFocus == true
                local Callback = tbOpts.Callback or function() end

                local Row = Create("Frame", {
                    Name = TBName .. "TextBoxRow",
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local InputBox = Create("TextBox", {
            TextStrokeTransparency = 1,
                    Name = "Input",
                    Size = UDim2.new(1, -4, 0, 32),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = WindowObj.ActiveTheme.ElementBg,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    PlaceholderColor3 = WindowObj.ActiveTheme.TextDim,
                    PlaceholderText = Placeholder,
                    Text = Def,
                    ClearTextOnFocus = ClearOnFocus,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    }),
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10)
                    })
                })

                InputBox.FocusLost:Connect(function(enterPressed)
                    task.spawn(Callback, InputBox.Text, enterPressed)
                end)

                local TBObj = {
                    Type = "TextBox",
                    Name = TBName,
                    RowFrame = Row,
                    SearchableText = TBName
                }

                function TBObj:SetText(t)
                    InputBox.Text = t
                    task.spawn(Callback, t, false)
                end

                function TBObj:GetText()
                    return InputBox.Text
                end

                table.insert(SecObj.Elements, TBObj)
                return TBObj
            end

            -- Colorpicker (row with one or more colorboxes)
            function SecObj:CreateColorpicker(cOpts)
                cOpts = cOpts or {}
                local CName = cOpts.Name or "Colorpicker"

                local Row = Create("Frame", {
                    Name = CName .. "ColorRow",
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Label",
                    Size = UDim2.new(1, -120, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = CName,
                    Parent = Row
                })

                local Swatches = Create("Frame", {
                    Name = "Swatches",
                    Size = UDim2.new(0, 200, 1, 0),
                    Position = UDim2.new(1, -234, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = Row
                }, {
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 8)
                    })
                })

                local count = 0
                local function AddSwatch(o)
                    count = count + 1
                    local index = count
                    local Col = o.Default or Color3.fromRGB(255, 255, 255)
                    local Transp = o.Transparency or 0
                    local cb = o.Callback or function() end
                    local swatchName = o.Name or CName

                    local Box = Create("TextButton", {
            TextStrokeTransparency = 1,
                        Name = "ColorBox" .. index,
                        Size = UDim2.new(0, 33, 0, 26),
                        BackgroundColor3 = Col,
                        AutoButtonColor = false,
                        Text = "",
                        BorderSizePixel = 0,
                        LayoutOrder = index,
                        Parent = Swatches
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        Create("UIStroke", {
                            Color = WindowObj.ActiveTheme.Stroke,
                            Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
                    })
                    Box:SetAttribute("ThemeIgnore", true)

                    local obj = {
                        Type = "Colorpicker",
                        Name = swatchName,
                        Value = Col,
                        Transparency = Transp,
                        RowFrame = Row,
                        SearchableText = CName
                    }

                    function obj:SetValue(c, t, silent)
                        Col = c
                        Transp = t or Transp
                        obj.Value = c
                        obj.Transparency = Transp
                        Box.BackgroundColor3 = c
                        if not silent then
                            task.spawn(cb, c, Transp)
                        end
                    end

                    Box.MouseButton1Click:Connect(function()
                        if JustClosed(Box) then return end
                        WindowObj:OpenColorpickerPopup(Col, function(c, t)
                            obj:SetValue(c, t)
                        end, {
                            Title = swatchName,
                            Anchor = Box,
                            Transparency = Transp
                        })
                    end)

                    local defaultFlag = TabName .. "." .. SecName .. "." .. CName
                    if index > 1 then
                        defaultFlag = defaultFlag .. ".Color" .. index
                    end
                    RegisterFlag(o.Flag or defaultFlag, obj)
                    return obj
                end

                local Primary = AddSwatch(cOpts)

                -- Adds another colorbox to the same row
                function Primary:AddColorpicker(o)
                    return AddSwatch(o or {})
                end

                table.insert(SecObj.Elements, Primary)
                return Primary
            end

            -- Keybind (right click for Toggle / Hold / Always)
            function SecObj:CreateKeybind(kOpts)
                kOpts = kOpts or {}
                local KName = kOpts.Name or "Keybind"

                local Row = Create("Frame", {
                    Name = KName .. "KeybindRow",
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Label",
                    Size = UDim2.new(1, -130, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 15,
                    TextColor3 = WindowObj.ActiveTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = KName,
                    Parent = Row
                })

                local bind = CreateBind(Row, {
                    Size = UDim2.new(0, 123, 0, 30),
                    Position = UDim2.new(1, -125, 0, 2),
                    TextSize = 14
                }, {
                    Name = KName,
                    Default = kOpts.Default,
                    Mode = kOpts.Mode,
                    Callback = kOpts.Callback,
                    ModeCallback = kOpts.ModeCallback,
                    OnState = kOpts.OnState,
                    ShowInList = kOpts.ShowInList
                })
                bind.RowFrame = Row
                bind.SearchableText = KName

                RegisterFlag(kOpts.Flag or (TabName .. "." .. SecName .. "." .. KName), bind)
                table.insert(SecObj.Elements, bind)
                WindowObj:RefreshKeybindList()
                return bind
            end

            -- List (configs / items)
            function SecObj:CreateList(lOpts)
                lOpts = lOpts or {}
                local LName = lOpts.Name or "List"
                local ListHeight = lOpts.Height or 160
                local Callback = lOpts.Callback or function() end

                local Row = Create("Frame", {
                    Name = LName .. "ListRow",
                    Size = UDim2.new(1, 0, 0, ListHeight + 8),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })

                local ListFrame = Create("ScrollingFrame", {
                    Name = "ListFrame",
                    Size = UDim2.new(1, -4, 0, ListHeight),
                    Position = UDim2.new(0, 2, 0, 4),
                    BackgroundColor3 = WindowObj.ActiveTheme.Background,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = WindowObj.ActiveTheme.Stroke,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = Row
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                    Create("UIStroke", {
                        Color = WindowObj.ActiveTheme.Stroke,
                        Thickness = 1,
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    }),
                    Create("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 3)
                    })
                })

                local Items = {}
                local SelectedId = nil

                local ListObj = {
                    Type = "List",
                    Name = LName,
                    RowFrame = Row,
                    SearchableText = LName
                }

                function ListObj:AddItem(itemData)
                    local id = itemData.Id or itemData.Name
                    local name = itemData.Name or "item"
                    local info = itemData.Info or ""
                    local iconAsset = itemData.Icon or fatalwtfuilibrary.Icons.Config

                    local ItemFrame = Create("Frame", {
                        Name = "Item_" .. id,
                        Size = UDim2.new(1, -6, 0, 30),
                        BackgroundColor3 = (SelectedId == id) and WindowObj.ActiveTheme.ElementBg or WindowObj.ActiveTheme.Background,
                        BorderSizePixel = 0,
                        Parent = ListFrame
                    }, {
                        Create("UICorner", { CornerRadius = UDim.new(0, 3) })
                    })

                    local SelectBar = Create("Frame", {
                        Name = "SelectBar",
                        Size = UDim2.new(0, 3, 0, 20),
                        Position = UDim2.new(0, 0, 0, 5),
                        BackgroundColor3 = WindowObj.ActiveTheme.Accent,
                        BorderSizePixel = 0,
                        Visible = (SelectedId == id),
                        Parent = ItemFrame
                    })

                    local IconImg = Create("ImageLabel", {
                        Name = "Icon",
                        Size = UDim2.new(0, 15, 0, 15),
                        Position = UDim2.new(0, 10, 0, 7),
                        BackgroundTransparency = 1,
                        Image = iconAsset,
                        ImageColor3 = (SelectedId == id) and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.TextDim,
                        Parent = ItemFrame
                    })

                    local NameLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
                        Name = "Name",
                        Size = UDim2.new(1, -140, 0, 20),
                        Position = UDim2.new(0, 32, 0, 5),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = (SelectedId == id) and WindowObj.ActiveTheme.Text or WindowObj.ActiveTheme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = name,
                        Parent = ItemFrame
                    })

                    local InfoLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
                        Name = "Info",
                        Size = UDim2.new(0, 100, 0, 20),
                        Position = UDim2.new(1, -106, 0, 5),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        TextSize = 12,
                        TextColor3 = WindowObj.ActiveTheme.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = info,
                        Parent = ItemFrame
                    })

                    local ClickBtn = Create("TextButton", {
            TextStrokeTransparency = 1,
                        Name = "ClickHitbox",
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = ItemFrame
                    })

                    ClickBtn.MouseButton1Click:Connect(function()
                        ListObj:Select(id)
                    end)

                    Items[id] = {
                        Frame = ItemFrame,
                        SelectBar = SelectBar,
                        Icon = IconImg,
                        NameLabel = NameLabel,
                        Data = itemData
                    }
                end

                function ListObj:Select(id)
                    SelectedId = id
                    for itId, it in pairs(Items) do
                        local isSel = (itId == id)
                        it.Frame.BackgroundColor3 = isSel and WindowObj.ActiveTheme.ElementBg or WindowObj.ActiveTheme.Background
                        it.SelectBar.Visible = isSel
                        it.Icon.ImageColor3 = isSel and WindowObj.ActiveTheme.Accent or WindowObj.ActiveTheme.TextDim
                        it.NameLabel.TextColor3 = isSel and WindowObj.ActiveTheme.Text or WindowObj.ActiveTheme.TextDim
                    end
                    if Items[id] then
                        task.spawn(Callback, Items[id].Data)
                    end
                end

                function ListObj:RemoveItem(id)
                    if Items[id] then
                        Items[id].Frame:Destroy()
                        Items[id] = nil
                        if SelectedId == id then SelectedId = nil end
                    end
                end

                function ListObj:Clear()
                    for _, it in pairs(Items) do
                        it.Frame:Destroy()
                    end
                    Items = {}
                    SelectedId = nil
                end

                function ListObj:GetSelected()
                    return SelectedId and Items[SelectedId] and Items[SelectedId].Data or nil
                end

                table.insert(SecObj.Elements, ListObj)
                return ListObj
            end

            -- Label & divider
            function SecObj:CreateLabel(txt)
                local Row = Create("Frame", {
                    Name = "LabelRow",
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })
                local L = Create("TextLabel", {
            TextStrokeTransparency = 1,
                    Name = "Text",
                    Size = UDim2.new(1, -4, 1, 0),
                    Position = UDim2.new(0, 2, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 14,
                    TextColor3 = WindowObj.ActiveTheme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = tostring(txt),
                    Parent = Row
                })
                return {
                    SetText = function(_, t) L.Text = tostring(t) end
                }
            end

            function SecObj:CreateDivider()
                local Row = Create("Frame", {
                    Name = "DividerRow",
                    Size = UDim2.new(1, 0, 0, 8),
                    BackgroundTransparency = 1,
                    Parent = ContentArea
                })
                Create("Frame", {
                    Name = "Line",
                    Size = UDim2.new(1, -4, 0, 1),
                    Position = UDim2.new(0, 2, 0, 4),
                    BackgroundColor3 = WindowObj.ActiveTheme.Stroke,
                    BorderSizePixel = 0,
                    Parent = Row
                }, {
                    Create("UIGradient", {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.8),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(1, 0.8)
                        })
                    })
                })
            end

            -- Model Preview / ESP Preview (3D ViewportFrame with character mannequin or custom ModelId)
            function SecObj:CreateModelPreview(pOpts)
                pOpts = pOpts or {}
                local PName = pOpts.Name or "PreviewContainer"
                local Height = pOpts.Height
                local ModelId = pOpts.ModelId or pOpts.UserId
                local BodyColor = pOpts.BodyColor or Color3.fromRGB(215, 218, 226)
                local fillMode = pOpts.Fill or (Height == nil)

                local Row = Create("Frame", {
                    Name = PName,
                    Size = fillMode and UDim2.new(1, -16, 1, -8) or UDim2.new(1, -16, 0, Height),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundColor3 = WindowObj.ActiveTheme.SectionBg,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = ContentArea
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Create("UIStroke", { Color = Color3.fromRGB(38, 38, 38), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
                })
                RegisterTheme(Row, "BackgroundColor3", "SectionBg")

                local VPF = Create("ViewportFrame", {
                    Name = "CharacterViewport",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Ambient = Color3.fromRGB(160, 160, 175),
                    LightColor = Color3.fromRGB(255, 255, 255),
                    LightDirection = Vector3.new(-1, -1.5, -1),
                    Parent = Row
                })

                local Cam = Instance.new("Camera")
                Cam.FieldOfView = pOpts.FieldOfView or 44
                Cam.CFrame = CFrame.new(0, -0.6, -9.8) * CFrame.Angles(0, math.rad(180), 0)
                Cam.Parent = VPF
                VPF.CurrentCamera = Cam

                local CurrentModel = nil

                local function ClearModel()
                    if CurrentModel then
                        CurrentModel:Destroy()
                        CurrentModel = nil
                    end
                end

                local function BuildDefaultDummy(bColor)
                    ClearModel()
                    local Dummy = Instance.new("Model")
                    Dummy.Name = "Dummy"
                    bColor = bColor or BodyColor

                    local function MakePart(partName, size, cf, isHead)
                        local p = Instance.new("Part")
                        p.Name = partName
                        p.Size = size
                        p.CFrame = cf
                        p.Color = bColor
                        p.Material = Enum.Material.SmoothPlastic
                        p.Anchored = true
                        p.CanCollide = false
                        if isHead then
                            local mesh = Instance.new("SpecialMesh")
                            mesh.MeshType = Enum.MeshType.Head
                            mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
                            mesh.Parent = p
                        end
                        p.Parent = Dummy
                        return p
                    end

                    MakePart("Torso", Vector3.new(2, 2, 1), CFrame.new(0, 0, 0))
                    MakePart("Head", Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 1.6, 0), true)
                    MakePart("LeftArm", Vector3.new(1, 2, 1), CFrame.new(-1.55, 0, 0))
                    MakePart("RightArm", Vector3.new(1, 2, 1), CFrame.new(1.55, 0, 0))
                    MakePart("LeftLeg", Vector3.new(1, 2, 1), CFrame.new(-0.52, -2.05, 0))
                    MakePart("RightLeg", Vector3.new(1, 2, 1), CFrame.new(0.52, -2.05, 0))

                    local Disc = MakePart("PedestalDisc", Vector3.new(3.6, 0.1, 3.6), CFrame.new(0, -3.1, 0))
                    Disc.Color = Color3.fromRGB(30, 32, 40)
                    local discMesh = Instance.new("CylinderMesh")
                    discMesh.Parent = Disc

                    Dummy.Parent = VPF
                    CurrentModel = Dummy
                    Cam.CFrame = CFrame.new(0, -0.6, -9.8) * CFrame.Angles(0, math.rad(180), 0)
                    return Dummy
                end

                local PreviewObj = {
                    Type = "ModelPreview",
                    RowFrame = Row,
                    Viewport = VPF,
                    Camera = Cam
                }

                function PreviewObj:SetModel(model)
                    ClearModel()
                    if model then
                        local clone = model:Clone()
                        for _, p in ipairs(clone:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.Anchored = true
                                p.CanCollide = false
                            end
                        end
                        clone.Parent = VPF
                        CurrentModel = clone

                        local cf, size
                        if clone:IsA("Model") then
                            cf, size = clone:GetBoundingBox()
                        elseif clone:IsA("BasePart") then
                            cf, size = clone.CFrame, clone.Size
                        else
                            cf, size = CFrame.new(0, 0, 0), Vector3.new(4, 5, 2)
                        end
                        local maxDim = math.max(size.X, size.Y, size.Z)
                        local fov = Cam.FieldOfView or 44
                        local dist = (maxDim / 2) / math.tan(math.rad(fov / 2)) + 1.8
                        Cam.CFrame = CFrame.new(cf.Position + Vector3.new(0, 0, -dist), cf.Position)
                    else
                        BuildDefaultDummy()
                    end
                end

                function PreviewObj:Reset()
                    BuildDefaultDummy()
                end

                function PreviewObj:GetModel()
                    return CurrentModel
                end

                function PreviewObj:SetModelId(id)
                    local rawStr = tostring(id or "")
                    local numId = tonumber(rawStr:match("%d+"))
                    if not numId and (id == nil or id == "" or id == 0 or rawStr == "default") then
                        BuildDefaultDummy()
                        return
                    end
                    task.spawn(function()
                        local ok, model
                        if numId then
                            ok, model = pcall(function()
                                return Players:CreateHumanoidModelFromUserId(numId)
                            end)
                            if (not ok or not model) and game:GetService("InsertService") then
                                ok, model = pcall(function()
                                    return game:GetService("InsertService"):LoadAsset(numId)
                                end)
                            end
                            if not ok or not model then
                                ok, model = pcall(function()
                                    local objs = game:GetObjects("rbxassetid://" .. numId)
                                    return objs and objs[1]
                                end)
                            end
                        elseif typeof(id) == "string" and id:find("rbxassetid://") then
                            ok, model = pcall(function()
                                local objs = game:GetObjects(id)
                                return objs and objs[1]
                            end)
                        end
                        if ok and model and (model:IsA("Model") or model:IsA("Folder") or model:IsA("BasePart")) then
                            PreviewObj:SetModel(model)
                        end
                    end)
                end

                function PreviewObj:SetUserId(userId)
                    PreviewObj:SetModelId(userId)
                end

                function PreviewObj:SetBodyColor(color)
                    BodyColor = color
                    if CurrentModel and CurrentModel.Name == "Dummy" then
                        for _, p in ipairs(CurrentModel:GetChildren()) do
                            if p:IsA("BasePart") and p.Name ~= "PedestalDisc" then
                                p.Color = color
                            end
                        end
                    end
                end

                if ModelId then
                    PreviewObj:SetModelId(ModelId)
                else
                    BuildDefaultDummy()
                end

                table.insert(SecObj.Elements, PreviewObj)
                return PreviewObj
            end

            SecObj.CreateESPPreview = SecObj.CreateModelPreview

            return SecObj
        end

        function TabObj:CreateESPPreview(pOpts)
            pOpts = pOpts or {}
            local Sec = TabObj:CreateSection({
                Name = pOpts.Name or "ESP Preview",
                Side = pOpts.Side or "Right",
                Height = pOpts.Height or 407
            })
            local Preview = Sec:CreateModelPreview({
                Name = "PreviewContainer",
                Fill = true,
                ModelId = pOpts.ModelId,
                UserId = pOpts.UserId,
                BodyColor = pOpts.BodyColor
            })
            return Preview, Sec
        end

        return TabObj
    end

    -- Colorpicker popup (opens next to the colorbox, closes on outside click)
    function WindowObj:OpenColorpickerPopup(initialColor, onColorChanged, cpOpts)
        cpOpts = cpOpts or {}
        local theme = WindowObj.ActiveTheme
        local curH, curS, curV = initialColor:ToHSV()
        local curA = cpOpts.Transparency or 0
        local conns = {}
        local winW, winH = Window.Size.X.Offset, Window.Size.Y.Offset

        local Modal = Create("Frame", {
            Name = "ColorpickerModal",
            Size = UDim2.new(0, 232, 0, 284),
            BackgroundColor3 = theme.Background,
            BorderSizePixel = 0,
            ZIndex = 80,
            Parent = OverlayContainer
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local x, y = winW / 2 - 116, winH / 2 - 142
        if cpOpts.Anchor then
            local scale = math.max(UIScale.Scale, 0.01)
            local rel = ToWindowSpace(cpOpts.Anchor.AbsolutePosition)
            local size = cpOpts.Anchor.AbsoluteSize / scale
            x = rel.X + size.X - 232
            y = rel.Y + size.Y + 6
            if y + 284 > winH - 8 then
                y = rel.Y - 290
            end
        end
        Modal.Position = UDim2.new(0, math.clamp(x, 8, winW - 240), 0, math.clamp(y, 8, winH - 292))

        Create("Frame", {
            Name = "AccentLine",
            Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = Modal
        }, {
            Create("UIGradient", { Transparency = NumberSequence.new(0, 0.6) })
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Title",
            Size = UDim2.new(1, -60, 0, 20),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = cpOpts.Title or "Color",
            Parent = Modal
        })

        local Preview = Create("Frame", {
            Name = "Preview",
            Size = UDim2.new(0, 32, 0, 18),
            Position = UDim2.new(1, -42, 0, 9),
            BackgroundColor3 = initialColor,
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = theme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })
        Preview:SetAttribute("ThemeIgnore", true)

        -- Saturation / value square
        local SV = Create("Frame", {
            Name = "SVSquare",
            Size = UDim2.new(0, 180, 0, 180),
            Position = UDim2.new(0, 10, 0, 36),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        SV:SetAttribute("ThemeIgnore", true)

        local SVGradient = Create("UIGradient", {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(curH, 1, 1)),
            Parent = SV
        })

        local Darkness = Create("Frame", {
            Name = "Darkness",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SV
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) })
        })
        Darkness:SetAttribute("ThemeIgnore", true)

        local SVCursor = Create("Frame", {
            Name = "Cursor",
            Size = UDim2.new(0, 12, 0, 12),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            ZIndex = 3,
            Parent = SV
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        -- Hue bar
        local hueKeys = {}
        for i = 0, 6 do
            table.insert(hueKeys, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i / 6) % 1, 1, 1)))
        end

        local HueBar = Create("Frame", {
            Name = "HueBar",
            Size = UDim2.new(0, 24, 0, 180),
            Position = UDim2.new(0, 198, 0, 36),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIGradient", { Rotation = 90, Color = ColorSequence.new(hueKeys) })
        })
        HueBar:SetAttribute("ThemeIgnore", true)

        local HueMarker = Create("Frame", {
            Name = "Marker",
            Size = UDim2.new(1, 6, 0, 4),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = HueBar
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
            Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        -- Transparency bar
        local AlphaBar = Create("Frame", {
            Name = "AlphaBar",
            Size = UDim2.new(0, 212, 0, 12),
            Position = UDim2.new(0, 10, 0, 226),
            BackgroundColor3 = theme.ElementBg,
            BorderSizePixel = 0,
            Parent = Modal
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })

        local AlphaFill = Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = initialColor,
            BorderSizePixel = 0,
            Parent = AlphaBar
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIGradient", { Transparency = NumberSequence.new(1, 0) })
        })
        AlphaFill:SetAttribute("ThemeIgnore", true)

        local AlphaMarker = Create("Frame", {
            Name = "Marker",
            Size = UDim2.new(0, 4, 1, 6),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = AlphaBar
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
            Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        -- Hex + RGB inputs
        local function InputBox(name, posX, width)
            return Create("TextBox", {
            TextStrokeTransparency = 1,
                Name = name,
                Size = UDim2.new(0, width, 0, 26),
                Position = UDim2.new(0, posX, 0, 248),
                BackgroundColor3 = theme.ElementBg,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = theme.Text,
                ClearTextOnFocus = false,
                Text = "",
                Parent = Modal
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = theme.Stroke, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
            })
        end

        local HexBox = InputBox("Hex", 10, 82)
        local RGBBox = InputBox("RGB", 98, 124)

        local function Refresh(fire)
            local c = Color3.fromHSV(curH, curS, curV)
            SVGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(curH, 1, 1))
            SVCursor.Position = UDim2.new(curS, 0, 1 - curV, 0)
            HueMarker.Position = UDim2.new(0.5, 0, curH, 0)
            AlphaFill.BackgroundColor3 = c
            AlphaMarker.Position = UDim2.new(1 - curA, 0, 0.5, 0)
            Preview.BackgroundColor3 = c
            Preview.BackgroundTransparency = curA
            if not HexBox:IsFocused() then
                HexBox.Text = "#" .. c:ToHex():upper()
            end
            if not RGBBox:IsFocused() then
                RGBBox.Text = string.format("%d, %d, %d",
                    math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
            end
            if fire and onColorChanged then
                onColorChanged(c, curA)
            end
        end

        local dragging = nil
        local function UpdateDrag(pos)
            if dragging == "SV" then
                local p, s = SV.AbsolutePosition, SV.AbsoluteSize
                curS = math.clamp((pos.X - p.X) / s.X, 0, 1)
                curV = 1 - math.clamp((pos.Y - p.Y) / s.Y, 0, 1)
            elseif dragging == "Hue" then
                local p, s = HueBar.AbsolutePosition, HueBar.AbsoluteSize
                curH = math.clamp((pos.Y - p.Y) / s.Y, 0, 0.999)
            elseif dragging == "Alpha" then
                local p, s = AlphaBar.AbsolutePosition, AlphaBar.AbsoluteSize
                curA = 1 - math.clamp((pos.X - p.X) / s.X, 0, 1)
            end
            Refresh(true)
        end

        local function BeginDrag(target, mode)
            target.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = mode
                    UpdateDrag(input.Position)
                end
            end)
        end

        BeginDrag(SV, "SV")
        BeginDrag(HueBar, "Hue")
        BeginDrag(AlphaBar, "Alpha")

        table.insert(conns, UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateDrag(input.Position)
            end
        end))

        table.insert(conns, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = nil
            end
        end))

        HexBox.FocusLost:Connect(function()
            local ok, col = pcall(Color3.fromHex, (HexBox.Text:gsub("#", "")))
            if ok and col then
                curH, curS, curV = col:ToHSV()
                Refresh(true)
            else
                Refresh(false)
            end
        end)

        RGBBox.FocusLost:Connect(function()
            local nums = {}
            for n in RGBBox.Text:gmatch("%d+") do
                table.insert(nums, math.clamp(tonumber(n), 0, 255))
            end
            if #nums >= 3 then
                curH, curS, curV = Color3.fromRGB(nums[1], nums[2], nums[3]):ToHSV()
                Refresh(true)
            else
                Refresh(false)
            end
        end)

        OpenPopup(Modal, function()
            for _, c in ipairs(conns) do
                c:Disconnect()
            end
            Modal:Destroy()
        end, cpOpts.Anchor)

        Refresh(false)
    end

    -- Config system (saves every element with a flag)
    local function SerializeFlag(obj)
        if obj.Type == "Toggle" or obj.Type == "Slider" or obj.Type == "Dropdown" then
            return obj.Value
        elseif obj.Type == "Colorpicker" then
            return { Color = obj.Value:ToHex(), Transparency = obj.Transparency or 0 }
        elseif obj.Type == "Keybind" then
            local key = obj.Key
            return {
                Key = key and key.Name or "None",
                Mouse = key ~= nil and key.EnumType == Enum.UserInputType,
                Mode = obj.Mode
            }
        end
        return nil
    end

    local function ApplyFlag(obj, value)
        if obj.Type == "Toggle" then
            obj:SetValue(value == true)
        elseif obj.Type == "Slider" then
            if type(value) == "number" then obj:SetValue(value) end
        elseif obj.Type == "Dropdown" then
            obj:Set(value)
        elseif obj.Type == "Colorpicker" and type(value) == "table" then
            obj:SetValue(Color3.fromHex(value.Color), value.Transparency)
        elseif obj.Type == "Keybind" and type(value) == "table" then
            local key = nil
            if value.Key and value.Key ~= "None" then
                key = value.Mouse and Enum.UserInputType[value.Key] or Enum.KeyCode[value.Key]
            end
            obj:SetKey(key)
            if value.Mode then obj:SetMode(value.Mode) end
        end
    end

    local function ConfigFolder()
        return WindowObj.Folder .. "/configs"
    end

    local function ThemeFolder()
        return WindowObj.Folder .. "/themes"
    end

    local function EnsureFolders()
        Storage.EnsureFolder(WindowObj.Folder)
        Storage.EnsureFolder(ConfigFolder())
        Storage.EnsureFolder(ThemeFolder())
    end

    local function CleanName(name)
        name = tostring(name or "")
        name = name:gsub('[\\/:%*%?"<>|]', "")
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        return name
    end

    function WindowObj:SaveConfig(name)
        name = CleanName(name)
        if name == "" then return false end
        local data = {}
        for flag, obj in pairs(WindowObj.Flags) do
            if flag:sub(1, 2) ~= "__" then
                local value = SerializeFlag(obj)
                if value ~= nil then
                    data[flag] = value
                end
            end
        end
        EnsureFolders()
        Storage.Write(ConfigFolder() .. "/" .. name .. ".json", HttpService:JSONEncode({
            Saved = os.date("%d/%m/%Y"),
            Flags = data
        }))
        return true
    end

    function WindowObj:LoadConfig(name)
        local raw = Storage.Read(ConfigFolder() .. "/" .. CleanName(name) .. ".json")
        if not raw then return false end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or type(data) ~= "table" or type(data.Flags) ~= "table" then return false end
        for flag, value in pairs(data.Flags) do
            local obj = WindowObj.Flags[flag]
            if obj then
                pcall(ApplyFlag, obj, value)
            end
        end
        return true
    end

    function WindowObj:DeleteConfig(name)
        Storage.Delete(ConfigFolder() .. "/" .. CleanName(name) .. ".json")
    end

    function WindowObj:ListConfigs()
        return Storage.List(ConfigFolder(), ".json")
    end

    function WindowObj:GetConfigDate(name)
        local raw = Storage.Read(ConfigFolder() .. "/" .. CleanName(name) .. ".json")
        if not raw then return "" end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        return (ok and type(data) == "table" and data.Saved) or ""
    end

    local function EncodeTheme(theme)
        local out = {}
        for key, value in pairs(theme) do
            if typeof(value) == "Color3" then
                out[key] = value:ToHex()
            end
        end
        return HttpService:JSONEncode(out)
    end

    local function DecodeTheme(raw)
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or type(data) ~= "table" then return nil end
        local theme = table.clone(fatalwtfuilibrary.Themes.Default)
        for key, value in pairs(data) do
            local okColor, col = pcall(Color3.fromHex, value)
            if okColor then
                theme[key] = col
            end
        end
        return theme
    end

    -- Default settings tab: Menu, Configs, Theme, Theme Config
    function WindowObj:CreateSettingsTab(sOpts)
        sOpts = sOpts or {}
        EnsureFolders()

        local function Notify(title, content)
            WindowObj:Notify({ Title = title, Content = content, Duration = 3 })
        end

        local Tab = WindowObj:CreateTab({
            Name = sOpts.Name or "Config",
            Icon = sOpts.Icon or fatalwtfuilibrary.Icons.Config
        })

        -- Menu
        local MenuSec = Tab:CreateSection({ Name = "Menu", Side = "Left" })

        MenuSec:CreateKeybind({
            Name = "Menu Keybind",
            Default = WindowObj.MenuKey,
            ShowInList = false,
            Flag = "__MenuKey",
            Callback = function(key)
                if key then WindowObj:SetMenuKey(key) end
            end
        })

        local WatermarkToggle = MenuSec:CreateToggle({
            Name = "Watermark",
            Default = sOpts.Watermark ~= false,
            Flag = "__Watermark",
            Callback = function(v) WindowObj:SetWatermarkVisible(v) end
        })
        WatermarkToggle:AddColorpicker({
            Name = "Watermark Color",
            Default = WindowObj.ActiveTheme.Accent,
            Flag = "__WatermarkColor",
            Callback = function(c) WindowObj:SetWatermarkColor(c) end
        })

        MenuSec:CreateDropdown({
            Name = "Watermark Position",
            Options = { "Top Left", "Top Right", "Bottom Left", "Bottom Right" },
            Default = "Top Left",
            Flag = "__WatermarkPosition",
            Callback = function(v) WindowObj:SetWatermarkPosition(v) end
        })

        local KeybindListToggle = MenuSec:CreateToggle({
            Name = "Keybind List",
            Default = sOpts.KeybindList == true,
            Flag = "__KeybindList",
            Callback = function(v) WindowObj:SetKeybindListVisible(v) end
        })

        MenuSec:CreateToggle({
            Name = "Notifications",
            Default = true,
            Flag = "__Notifications",
            Callback = function(v) WindowObj.NotificationsEnabled = v end
        })

        MenuSec:CreateDropdown({
            Name = "Notification Position",
            Options = { "Bottom Right", "Bottom Left", "Top Right", "Top Left" },
            Default = "Bottom Right",
            Flag = "__NotificationPosition",
            Callback = function(v) WindowObj:SetNotificationPosition(v) end
        })

        MenuSec:CreateSlider({
            Name = "Menu Scale",
            Min = 0.5,
            Max = 1.5,
            Default = ScaleVal,
            Decimals = 2,
            Flag = "__Scale",
            Callback = function(v) WindowObj:SetScale(v) end
        })

        MenuSec:CreateDivider()

        MenuSec:CreateButton({
            Name = "Rejoin Server",
            Callback = function()
                local ts = game:GetService("TeleportService")
                ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, game:GetService("Players").LocalPlayer)
            end
        })

        MenuSec:CreateButton({
            Name = "Server Hop",
            Callback = function()
                local ts = game:GetService("TeleportService")
                local hs = game:GetService("HttpService")
                local p = game:GetService("Players").LocalPlayer
                local success, servers = pcall(function()
                    local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc" .. string.char(38) .. "limit=100"
                    return hs:JSONDecode(game:HttpGet(url))
                end)
                if success and servers and servers.data then
                    for _, server in ipairs(servers.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            ts:TeleportToPlaceInstance(game.PlaceId, server.id, p)
                            return
                        end
                    end
                end
            end
        })

        MenuSec:CreateButton({
            Name = "Copy Server Link",
            Callback = function()
                local link = string.format("https://www.roblox.com/games/%s?privateServerLinkCode=" .. string.char(38) .. "gameInstanceId=%s", tostring(game.PlaceId), tostring(game.JobId))
                if setclipboard then
                    setclipboard(link)
                end
                WindowObj:Notify({ Title = "Server", Content = "Copied server link to clipboard", Duration = 2 })
            end
        })

        WindowObj:SetWatermarkVisible(WatermarkToggle.Value)
        WindowObj:SetKeybindListVisible(KeybindListToggle.Value)

        -- Configs
        local ConfigSec = Tab:CreateSection({ Name = "Configs", Side = "Right" })
        local ConfigList = ConfigSec:CreateList({ Name = "Configs", Height = 150 })
        local ConfigName = ConfigSec:CreateTextBox({ Name = "Config Name", Placeholder = "Type config name..." })
        local AutoLoadDropdown

        local function RefreshConfigs()
            ConfigList:Clear()
            local names = WindowObj:ListConfigs()
            for _, n in ipairs(names) do
                ConfigList:AddItem({ Id = n, Name = n, Info = WindowObj:GetConfigDate(n) })
            end
            if AutoLoadDropdown then
                AutoLoadDropdown:Refresh(#names > 0 and names or { "None" })
            end
            return names
        end

        ConfigSec:CreateButtonRow({
            {
                Name = "Load",
                Accent = true,
                Callback = function()
                    local sel = ConfigList:GetSelected()
                    if not sel then return Notify("Config", "Select a config first") end
                    if WindowObj:LoadConfig(sel.Name) then
                        Notify("Config Loaded", "Successfully loaded '" .. sel.Name .. "'")
                    else
                        Notify("Config Error", "Could not load '" .. sel.Name .. "'")
                    end
                end
            },
            {
                Name = "Create",
                Callback = function()
                    local name = CleanName(ConfigName:GetText())
                    if name == "" then return Notify("Config", "Type a config name first") end
                    WindowObj:SaveConfig(name)
                    RefreshConfigs()
                    ConfigList:Select(name)
                    Notify("Config Created", "Saved '" .. name .. "'")
                end
            },
            {
                Name = "Delete",
                Callback = function()
                    local sel = ConfigList:GetSelected()
                    if not sel then return Notify("Config", "Select a config first") end
                    WindowObj:DeleteConfig(sel.Name)
                    RefreshConfigs()
                    Notify("Config Deleted", "Deleted '" .. sel.Name .. "'")
                end
            }
        })

        local AutoLoadPath = WindowObj.Folder .. "/autoload.txt"
        local AutoName = Storage.Read(AutoLoadPath)

        local AutoLoadToggle = ConfigSec:CreateToggle({
            Name = "Auto Load",
            Default = AutoName ~= nil and AutoName ~= "",
            Flag = "__AutoLoad",
            Callback = function(v)
                if v then
                    local n = AutoLoadDropdown and AutoLoadDropdown.Value
                    if n and n ~= "None" and n ~= "" then
                        Storage.Write(AutoLoadPath, n)
                    end
                else
                    Storage.Delete(AutoLoadPath)
                end
            end
        })

        AutoLoadDropdown = ConfigSec:CreateDropdown({
            Name = "Auto Load Config",
            Options = { "None" },
            Default = AutoName or "None",
            Flag = "__AutoLoadConfig",
            Callback = function(n)
                if AutoLoadToggle.Value and n ~= "None" then
                    Storage.Write(AutoLoadPath, n)
                end
            end
        })

        RefreshConfigs()

        -- Theme
        local ThemeSec = Tab:CreateSection({ Name = "Theme", Side = "Left" })
        local ThemePickers = {}

        local function ThemePicker(label, key, second)
            local picker = ThemeSec:CreateColorpicker({
                Name = label,
                Default = WindowObj.ActiveTheme[key],
                Flag = "__Theme." .. key,
                Callback = function(c) WindowObj:SetThemeColor(key, c) end
            })
            ThemePickers[key] = picker
            if second then
                ThemePickers[second.Key] = picker:AddColorpicker({
                    Name = second.Name,
                    Default = WindowObj.ActiveTheme[second.Key],
                    Flag = "__Theme." .. second.Key,
                    Callback = function(c) WindowObj:SetThemeColor(second.Key, c) end
                })
            end
        end

        ThemePicker("Accent", "Accent")
        ThemePicker("Background", "Background")
        ThemePicker("Section", "SectionBg")
        ThemePicker("Element", "ElementBg")
        ThemePicker("Header Gradient", "Header1", { Name = "Header Gradient 2", Key = "Header2" })
        ThemePicker("Text", "Text", { Name = "Dim Text", Key = "TextDim" })

        local StrokeToggle = ThemeSec:CreateToggle({
            Name = "UI Stroke",
            Default = true,
            Flag = "__Strokes",
            Callback = function(v) WindowObj:SetStrokesEnabled(v) end
        })
        ThemePickers.Stroke = StrokeToggle:AddColorpicker({
            Name = "UI Stroke",
            Default = WindowObj.ActiveTheme.Stroke,
            Flag = "__Theme.Stroke",
            Callback = function(c) WindowObj:SetThemeColor("Stroke", c) end
        })

        ThemeSec:CreateToggle({
            Name = "Header Stripes",
            Default = true,
            Flag = "__Stripes",
            Callback = function(v) WindowObj:SetStripesEnabled(v) end
        })

        ThemeSec:CreateDropdown({
            Name = "Font",
            Options = { "Gotham", "Arial", "Source Sans", "Ubuntu", "Roboto Mono" },
            Default = "Gotham",
            Flag = "__Font",
            Callback = function(v) WindowObj:SetFont(v) end
        })

        local function SyncThemePickers()
            for key, picker in pairs(ThemePickers) do
                local col = WindowObj.ActiveTheme[key]
                if col then
                    picker:SetValue(col, nil, true)
                end
            end
        end

        -- Theme Config
        local ThemeConfigSec = Tab:CreateSection({ Name = "Theme Config", Side = "Right" })
        local ThemeList = ThemeConfigSec:CreateList({ Name = "Themes", Height = 150 })
        local ThemeName = ThemeConfigSec:CreateTextBox({ Name = "Theme Name", Placeholder = "Type theme name..." })
        local PresetOrder = { "Default", "Ocean", "Blood", "Mint", "Midnight", "Sunset" }

        local function RefreshThemes()
            ThemeList:Clear()
            for _, n in ipairs(PresetOrder) do
                if fatalwtfuilibrary.Themes[n] then
                    ThemeList:AddItem({ Id = n, Name = n, Info = "Preset", Icon = fatalwtfuilibrary.Icons.Visual })
                end
            end
            for _, n in ipairs(Storage.List(ThemeFolder(), ".json")) do
                if not fatalwtfuilibrary.Themes[n] then
                    ThemeList:AddItem({ Id = n, Name = n, Info = "Custom", Icon = fatalwtfuilibrary.Icons.Visual })
                end
            end
        end

        local function ApplyTheme(name)
            local theme = fatalwtfuilibrary.Themes[name]
            if not theme then
                local raw = Storage.Read(ThemeFolder() .. "/" .. name .. ".json")
                if raw then theme = DecodeTheme(raw) end
            end
            if not theme then return false end
            WindowObj:SetTheme(theme)
            SyncThemePickers()
            return true
        end

        ThemeConfigSec:CreateButtonRow({
            {
                Name = "Load",
                Accent = true,
                Callback = function()
                    local sel = ThemeList:GetSelected()
                    if not sel then return Notify("Theme", "Select a theme first") end
                    if ApplyTheme(sel.Name) then
                        Notify("Theme Loaded", "Applied '" .. sel.Name .. "'")
                    end
                end
            },
            {
                Name = "Save",
                Callback = function()
                    local name = CleanName(ThemeName:GetText())
                    if name == "" then return Notify("Theme", "Type a theme name first") end
                    if fatalwtfuilibrary.Themes[name] then return Notify("Theme", "Can't overwrite a preset") end
                    EnsureFolders()
                    Storage.Write(ThemeFolder() .. "/" .. name .. ".json", EncodeTheme(WindowObj.ActiveTheme))
                    RefreshThemes()
                    ThemeList:Select(name)
                    Notify("Theme Saved", "Saved '" .. name .. "'")
                end
            },
            {
                Name = "Delete",
                Callback = function()
                    local sel = ThemeList:GetSelected()
                    if not sel then return Notify("Theme", "Select a theme first") end
                    if fatalwtfuilibrary.Themes[sel.Name] then return Notify("Theme", "Presets can't be deleted") end
                    Storage.Delete(ThemeFolder() .. "/" .. sel.Name .. ".json")
                    RefreshThemes()
                    Notify("Theme Deleted", "Deleted '" .. sel.Name .. "'")
                end
            }
        })

        ThemeConfigSec:CreateButton({
            Name = "Reset To Default",
            Callback = function()
                ApplyTheme("Default")
                ThemeList:Select("Default")
            end
        })

        RefreshThemes()
        ThemeList:Select(fatalwtfuilibrary.Themes[DefaultTheme] and DefaultTheme or "Default")

        -- Auto load the saved config once everything exists
        if AutoLoadToggle.Value and AutoName and AutoName ~= "" then
            task.defer(function()
                if WindowObj:LoadConfig(AutoName) then
                    Notify("Config Loaded", "Auto loaded '" .. AutoName .. "'")
                end
            end)
        end

        return Tab
    end

    -- Players tab (Reworked 3-Card Layout matching Roblox Studio 1:1)
    function WindowObj:CreatePlayersTab(pOpts)
        pOpts = pOpts or {}

        local function Notify(title, content)
            WindowObj:Notify({ Title = title, Content = content, Duration = 2.5 })
        end

        local PriorityColors = {
            Friend = Color3.fromRGB(70, 210, 120),
            Neutral = Color3.fromRGB(150, 150, 150),
            Enemy = Color3.fromRGB(235, 65, 75)
        }
        WindowObj.PriorityColors = PriorityColors
        WindowObj.Priorities = WindowObj.Priorities or {}
        WindowObj.IgnoreFriends = true
        WindowObj.AutoAddFriends = false

        local Tab = WindowObj:CreateTab({
            Name = pOpts.Name or "Players",
            Icon = pOpts.Icon or fatalwtfuilibrary.Icons.Players
        })

        -- Remove default dual-column layout so we can mount the 3 dedicated cards directly
        if Tab.LeftCol then Tab.LeftCol:Destroy() end
        if Tab.RightCol then Tab.RightCol:Destroy() end
        Tab.Page.Parent = WindowObj.Window
        Tab.Page.Position = UDim2.new(0, 0, 0, 0)
        Tab.Page.Size = UDim2.new(1, 0, 1, 0)
        Tab.Page.BackgroundTransparency = 1

        local theme = WindowObj.ActiveTheme
        local Rows = {}
        local Selected = nil
        local Spectating = nil
        local AutoFriends = false
        local IgnoreFriends = true
        local SelectPlayer

        local function Headshot(userId)
            return "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
        end

        local function GetPriority(plr)
            if typeof(plr) == "table" and plr.Priority then
                return WindowObj.Priorities[plr.UserId] or plr.Priority
            end
            return WindowObj.Priorities[plr.UserId] or "Neutral"
        end

        function WindowObj:GetPriority(plr)
            return GetPriority(plr)
        end

        -- ====================================================================
        -- CARD 1: PLAYER LIST (Left)
        -- Pos: {0, 10}, {0, 108}, Size: {0, 409}, {0, 832}
        -- ====================================================================
        local PlayerList = Create("Frame", {
            Name = "PlayerList",
            Size = UDim2.new(0, 409, 0, 832),
            Position = UDim2.new(0, 10, 0, 108),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            Parent = Tab.Page
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })

        local ListHeader = BuildStripedHeader(PlayerList, 38)
        local ListHeaderLine = Create("Frame", {
            Name = "HeaderLine",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 37),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Parent = PlayerList
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Title",
            Size = UDim2.new(0, 300, 0, 20),
            Position = UDim2.new(0, 11, 0, 9),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Player List",
            Parent = PlayerList
        })

        Create("Frame", {
            Name = "InfoIcon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 378, 0, 9),
            BackgroundTransparency = 1,
            Parent = PlayerList
        }, {
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://99396201903267",
                ImageColor3 = Color3.fromRGB(245, 245, 245)
            })
        })

        local CountLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Count",
            Size = UDim2.new(0, 150, 0, 20),
            Position = UDim2.new(0, 220, 0, 9),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = "0 Players",
            Parent = PlayerList
        })

        local SearchBox = Create("TextBox", {
            TextStrokeTransparency = 1,
            Name = "SearchBox",
            Size = UDim2.new(0, 385, 0, 32),
            Position = UDim2.new(0, 12, 0, 50),
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            PlaceholderText = "Search players...",
            PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
            Text = "",
            ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = PlayerList
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
            Create("UIPadding", { PaddingLeft = UDim.new(0, 34) }),
            Create("ImageLabel", {
                Name = "SearchIcon",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, -24, 0, 8),
                BackgroundTransparency = 1,
                Image = "rbxassetid://135740014908175",
                ImageColor3 = Color3.fromRGB(120, 120, 120)
            })
        })

        local ListScroll = Create("ScrollingFrame", {
            Name = "List",
            Size = UDim2.new(0, 385, 0, 728),
            Position = UDim2.new(0, 12, 0, 92),
            BackgroundColor3 = Color3.fromRGB(22, 22, 22),
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = PlayerList
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Create("UIStroke", { Color = Color3.fromRGB(36, 36, 36), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            }),
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 3),
                PaddingBottom = UDim.new(0, 3),
                PaddingLeft = UDim.new(0, 3),
                PaddingRight = UDim.new(0, 3)
            })
        })

        local function UpdateCount()
            local n = 0
            for _ in pairs(Rows) do n = n + 1 end
            CountLabel.Text = n .. (n == 1 and " Player" or " Players")
        end

        local function UpdateRowStyle(plr)
            local row = Rows[plr]
            if not row then return end
            local t = WindowObj.ActiveTheme
            local selected = plr == Selected
            local prio = GetPriority(plr)
            local prioCol = PriorityColors[prio] or PriorityColors.Neutral

            row.Frame.BackgroundColor3 = selected and Color3.fromRGB(32, 32, 32) or Color3.fromRGB(22, 22, 22)
            row.Bar.Visible = selected
            row.AvatarStroke.Color = selected and t.Accent or Color3.fromRGB(45, 45, 45)
            row.DisplayName.TextColor3 = selected and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(210, 210, 210)
            row.TagText.Text = prio
            row.TagText.TextColor3 = prioCol
        end

        local function ApplySearch()
            local query = SearchBox.Text:lower()
            for plr, row in pairs(Rows) do
                local dName = (plr.DisplayName or ""):lower()
                local uName = (plr.Name or ""):lower()
                row.Frame.Visible = query == ""
                    or dName:find(query, 1, true) ~= nil
                    or uName:find(query, 1, true) ~= nil
            end
        end
        SearchBox:GetPropertyChangedSignal("Text"):Connect(ApplySearch)

        -- ====================================================================
        -- CARD 2: PLAYER INFO (Right Top)
        -- Pos: {0, 435}, {0, 108}, Size: {0, 408}, {0, 406}
        -- ====================================================================
        local PlayerInfo = Create("Frame", {
            Name = "PlayerInfo",
            Size = UDim2.new(0, 408, 0, 406),
            Position = UDim2.new(0, 435, 0, 108),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            Parent = Tab.Page
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })

        local InfoHeader = BuildStripedHeader(PlayerInfo, 38)
        local InfoHeaderLine = Create("Frame", {
            Name = "HeaderLine",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 37),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Parent = PlayerInfo
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Title",
            Size = UDim2.new(0, 300, 0, 20),
            Position = UDim2.new(0, 11, 0, 9),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Player Info",
            Parent = PlayerInfo
        })

        Create("Frame", {
            Name = "InfoIcon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 377, 0, 9),
            BackgroundTransparency = 1,
            Parent = PlayerInfo
        }, {
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://99396201903267",
                ImageColor3 = Color3.fromRGB(245, 245, 245)
            })
        })

        -- Identity Card: Avatar, DisplayName, Username, Priority Tag
        local Card_Identity = Create("Frame", {
            Name = "Card_Identity",
            Size = UDim2.new(0, 384, 0, 92),
            Position = UDim2.new(0, 12, 0, 50),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            BorderSizePixel = 0,
            Parent = PlayerInfo
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local InfoAvatar = Create("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 72, 0, 72),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
            BorderSizePixel = 0,
            Image = "",
            Parent = Card_Identity
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Accent, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local InfoDisplayName = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "DisplayName",
            Size = UDim2.new(0, 280, 0, 26),
            Position = UDim2.new(0, 96, 0, 10),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = "No player selected",
            Parent = Card_Identity
        })

        local InfoUsername = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Username",
            Size = UDim2.new(0, 280, 0, 18),
            Position = UDim2.new(0, 96, 0, 38),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(125, 125, 125),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = "",
            Parent = Card_Identity
        })

        local InfoPriorityBadge = Create("Frame", {
            Name = "Priority",
            Size = UDim2.new(0, 84, 0, 26),
            Position = UDim2.new(0, 96, 0, 58),
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
            BorderSizePixel = 0,
            Visible = false,
            Parent = Card_Identity
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        local InfoPriorityText = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Text",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = PriorityColors.Neutral,
            TextXAlignment = Enum.TextXAlignment.Center,
            Text = "Neutral",
            Parent = InfoPriorityBadge
        })

        -- Health Card
        local Card_Health = Create("Frame", {
            Name = "Card_Health",
            Size = UDim2.new(0, 384, 0, 52),
            Position = UDim2.new(0, 12, 0, 152),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            BorderSizePixel = 0,
            Parent = PlayerInfo
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "HealthLabel",
            Size = UDim2.new(0, 150, 0, 18),
            Position = UDim2.new(0, 12, 0, 7),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(125, 125, 125),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Health",
            Parent = Card_Health
        })

        local HealthValueLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "HealthValue",
            Size = UDim2.new(0, 360, 0, 18),
            Position = UDim2.new(0, 12, 0, 7),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = "- / -",
            Parent = Card_Health
        })

        local HealthBarTrack = Create("Frame", {
            Name = "HealthBar",
            Size = UDim2.new(0, 360, 0, 8),
            Position = UDim2.new(0, 12, 0, 31),
            BackgroundColor3 = Color3.fromRGB(30, 30, 32),
            BorderSizePixel = 0,
            Parent = Card_Health
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })

        local HealthFill = Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(70, 210, 120),
            BorderSizePixel = 0,
            Parent = HealthBarTrack
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(70, 210, 120), Color3.fromRGB(50, 185, 100))
            })
        })

        -- Tile: User ID
        local Tile_UserID = Create("Frame", {
            Name = "Tile_UserID",
            Size = UDim2.new(0, 186, 0, 48),
            Position = UDim2.new(0, 12, 0, 214),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            BorderSizePixel = 0,
            Parent = PlayerInfo
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "UserIDLabel",
                Size = UDim2.new(0, 162, 0, 14),
                Position = UDim2.new(0, 12, 0, 7),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(125, 125, 125),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "User ID"
            })
        })
        local UserIDValue = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "UserIDValue",
            Size = UDim2.new(0, 162, 0, 20),
            Position = UDim2.new(0, 12, 0, 23),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "-",
            Parent = Tile_UserID
        })

        -- Tile: Distance
        local Tile_Distance = Create("Frame", {
            Name = "Tile_Distance",
            Size = UDim2.new(0, 186, 0, 48),
            Position = UDim2.new(0, 210, 0, 214),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            BorderSizePixel = 0,
            Parent = PlayerInfo
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "DistanceLabel",
                Size = UDim2.new(0, 162, 0, 14),
                Position = UDim2.new(0, 12, 0, 7),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(125, 125, 125),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Distance"
            })
        })
        local DistanceValue = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "DistanceValue",
            Size = UDim2.new(0, 162, 0, 20),
            Position = UDim2.new(0, 12, 0, 23),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "-",
            Parent = Tile_Distance
        })

        -- Tile: Account Age
        local Tile_AccountAge = Create("Frame", {
            Name = "Tile_AccountAge",
            Size = UDim2.new(0, 384, 0, 48),
            Position = UDim2.new(0, 12, 0, 270),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            BorderSizePixel = 0,
            Parent = PlayerInfo
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        }),
            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "AccountAgeLabel",
                Size = UDim2.new(0, 360, 0, 14),
                Position = UDim2.new(0, 12, 0, 7),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(125, 125, 125),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Account Age"
            })
        })
        local AccountAgeValue = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "AccountAgeValue",
            Size = UDim2.new(0, 360, 0, 20),
            Position = UDim2.new(0, 12, 0, 23),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "-",
            Parent = Tile_AccountAge
        })

        local function FormatNumber(num)
            local formatted = tostring(math.floor(num or 0))
            while true do
                local k
                formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
                if k == 0 then break end
            end
            return formatted
        end

        local function RefreshStats()
            local plr = Selected
            if not plr then
                UserIDValue.Text = "-"
                DistanceValue.Text = "-"
                AccountAgeValue.Text = "-"
                HealthValueLabel.Text = "- / -"
                HealthFill.Size = UDim2.new(0, 0, 1, 0)
                return
            end

            -- Dummy player support or real player
            if typeof(plr) == "table" and plr.Dummy then
                UserIDValue.Text = tostring(plr.UserId)
                DistanceValue.Text = string.format("%.0f studs", plr.Distance or 100)
                AccountAgeValue.Text = FormatNumber(plr.AccountAge or 0) .. " days"
                HealthValueLabel.Text = (plr.Health or 100) .. " / " .. (plr.MaxHealth or 100)
                HealthFill.Size = UDim2.new(math.clamp((plr.Health or 100) / (plr.MaxHealth or 100), 0, 1), 0, 1, 0)
                return
            end

            if not plr.Parent then return end
            UserIDValue.Text = tostring(plr.UserId)
            AccountAgeValue.Text = FormatNumber(plr.AccountAge or 0) .. " days"

            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                HealthValueLabel.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
                HealthFill.Size = UDim2.new(math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1), 0, 1, 0)
            else
                HealthValueLabel.Text = "- / -"
                HealthFill.Size = UDim2.new(0, 0, 1, 0)
            end

            local myChar = LocalPlayer and LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if root and myRoot then
                DistanceValue.Text = string.format("%.0f studs", (root.Position - myRoot.Position).Magnitude)
            else
                DistanceValue.Text = "-"
            end
        end

        local function RefreshInfo()
            local plr = Selected
            if not plr then
                InfoAvatar.Image = ""
                InfoDisplayName.Text = "No player selected"
                InfoUsername.Text = ""
                InfoPriorityBadge.Visible = false
            else
                InfoAvatar.Image = Headshot(plr.UserId)
                InfoDisplayName.Text = plr.DisplayName or plr.Name
                InfoUsername.Text = "@" .. (plr.Name or "")
                InfoPriorityBadge.Visible = true
                local prio = GetPriority(plr)
                InfoPriorityText.Text = prio
                InfoPriorityText.TextColor3 = PriorityColors[prio] or PriorityColors.Neutral
            end
            RefreshStats()
        end

        -- ====================================================================
        -- CARD 3: ACTIONS (Right Bottom)
        -- Pos: {0, 435}, {0, 533}, Size: {0, 408}, {0, 407}
        -- ====================================================================
        local ActionsCard = Create("Frame", {
            Name = "Actions",
            Size = UDim2.new(0, 408, 0, 407),
            Position = UDim2.new(0, 435, 0, 533),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            Parent = Tab.Page
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })

        local ActionsHeader = BuildStripedHeader(ActionsCard, 38)
        local ActionsHeaderLine = Create("Frame", {
            Name = "HeaderLine",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 37),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Parent = ActionsCard
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Title",
            Size = UDim2.new(0, 300, 0, 20),
            Position = UDim2.new(0, 11, 0, 9),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Actions",
            Parent = ActionsCard
        })

        Create("Frame", {
            Name = "InfoIcon",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 377, 0, 9),
            BackgroundTransparency = 1,
            Parent = ActionsCard
        }, {
            Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://99396201903267",
                ImageColor3 = Color3.fromRGB(245, 245, 245)
            })
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "PriorityLabel",
            Size = UDim2.new(0, 200, 0, 16),
            Position = UDim2.new(0, 12, 0, 48),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(125, 125, 125),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Priority",
            Parent = ActionsCard
        })

        -- Segmented Priority Container (Friend / Neutral / Enemy)
        local Seg_Container = Create("Frame", {
            Name = "Seg_Container",
            Size = UDim2.new(0, 384, 0, 40),
            Position = UDim2.new(0, 12, 0, 68),
            BackgroundColor3 = Color3.fromRGB(14, 14, 14),
            BorderSizePixel = 0,
            Parent = ActionsCard
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local SegButtons = {}
        local SegDefs = {
            { Name = "Friend", PosX = 3 },
            { Name = "Neutral", PosX = 129 },
            { Name = "Enemy", PosX = 255 }
        }

        local function RefreshPrioritySegment()
            local curPrio = Selected and GetPriority(Selected) or nil
            local t = WindowObj.ActiveTheme
            for _, def in ipairs(SegDefs) do
                local btn = SegButtons[def.Name]
                if btn then
                    local isActive = (curPrio == def.Name)
                    btn.Button.BackgroundColor3 = isActive and t.Accent or Color3.fromRGB(14, 14, 14)
                    btn.Button.BackgroundTransparency = isActive and 0 or 1
                    btn.Stroke.Enabled = isActive
                    btn.Stroke.Color = t.Accent
                    btn.Button.TextColor3 = isActive and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
                end
            end
        end

        local function SetPriority(plr, prio)
            if not plr then return end
            WindowObj.Priorities[plr.UserId] = (prio ~= "Neutral") and prio or nil
            if typeof(plr) == "table" then
                plr.Priority = prio
            end
            UpdateRowStyle(plr)
            if plr == Selected then
                RefreshInfo()
                RefreshPrioritySegment()
            end
            if pOpts.OnPriorityChanged then
                task.spawn(pOpts.OnPriorityChanged, plr, prio)
            end
        end

        function WindowObj:SetPriority(plr, prio)
            SetPriority(plr, prio)
        end

        for _, def in ipairs(SegDefs) do
            local Btn = Create("TextButton", {
            TextStrokeTransparency = 1,
                Name = def.Name .. "Button",
                Size = UDim2.new(0, 126, 0, 34),
                Position = UDim2.new(0, def.PosX, 0, 3),
                BackgroundColor3 = Color3.fromRGB(14, 14, 14),
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Text = def.Name,
                Parent = Seg_Container
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })
            local Stroke = Create("UIStroke", {
                Color = WindowObj.ActiveTheme.Accent,
                Thickness = 1,
                Enabled = false,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Parent = Btn
            })
            Btn.MouseButton1Click:Connect(function()
                if not Selected then
                    return Notify("Players", "Select a player first")
                end
                SetPriority(Selected, def.Name)
            end)
            SegButtons[def.Name] = { Button = Btn, Stroke = Stroke, Def = def }
        end

        -- Spectate Button (No text stroke, reacts to active theme)
        local SpectateButton = Create("TextButton", {
            TextStrokeTransparency = 1,
            Name = "SpectateButton",
            Size = UDim2.new(0, 186, 0, 40),
            Position = UDim2.new(0, 12, 0, 122),
            BackgroundColor3 = WindowObj.ActiveTheme.Accent,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = Color3.new(1, 1, 1),
            TextStrokeTransparency = 1,
            Text = "Spectate",
            Parent = ActionsCard
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        RegisterTheme(SpectateButton, "BackgroundColor3", "Accent")

        local function StopSpectate()
            if not Spectating then return end
            Spectating = nil
            SpectateButton.Text = "Spectate"
            if pOpts.OnSpectate then
                task.spawn(pOpts.OnSpectate, nil)
            else
                local cam = workspace.CurrentCamera
                local hum = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if cam and hum then cam.CameraSubject = hum end
            end
        end

        local function StartSpectate(plr)
            if typeof(plr) == "table" and plr.Dummy then
                return Notify("Spectate", "Cannot spectate dummy player")
            end
            Spectating = plr
            SpectateButton.Text = "Stop Spectating"
            if pOpts.OnSpectate then
                task.spawn(pOpts.OnSpectate, plr)
            else
                local cam = workspace.CurrentCamera
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if cam and hum then cam.CameraSubject = hum end
            end
        end

        SpectateButton.MouseButton1Click:Connect(function()
            if Spectating then
                StopSpectate()
            elseif Selected then
                StartSpectate(Selected)
            else
                Notify("Players", "Select a player first")
            end
        end)

        -- Teleport Button
        local TeleportButton = Create("TextButton", {
            TextStrokeTransparency = 1,
            Name = "TeleportButton",
            Size = UDim2.new(0, 186, 0, 40),
            Position = UDim2.new(0, 210, 0, 122),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            Text = "Teleport",
            Parent = ActionsCard
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 3) })
        })
        local TeleportStroke = Create("UIStroke", {
            Color = Color3.fromRGB(60, 60, 60),
            Thickness = 1,
            Enabled = false,
            Parent = TeleportButton,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        TeleportButton.MouseEnter:Connect(function() TeleportStroke.Enabled = true end)
        TeleportButton.MouseLeave:Connect(function() TeleportStroke.Enabled = false end)

        TeleportButton.MouseButton1Click:Connect(function()
            if not Selected then
                return Notify("Players", "Select a player first")
            end
            if typeof(Selected) == "table" and Selected.Dummy then
                return Notify("Teleport", "Cannot teleport to dummy player")
            end
            if pOpts.OnTeleport then
                task.spawn(pOpts.OnTeleport, Selected)
            else
                Notify("Teleport", "No OnTeleport handler was given")
            end
        end)

        -- Options Section Header
        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Sec_Options",
            Size = UDim2.new(0, 200, 0, 16),
            Position = UDim2.new(0, 12, 0, 178),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(125, 125, 125),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Options",
            Parent = ActionsCard
        })

        -- Helper to build styled Toggle Card
        local function BuildToggleCard(name, labelText, defaultVal, posY, onChanged)
            local Card = Create("TextButton", {
            TextStrokeTransparency = 1,
                Name = "Card_" .. name,
                Size = UDim2.new(0, 384, 0, 40),
                Position = UDim2.new(0, 12, 0, posY),
                BackgroundColor3 = Color3.fromRGB(24, 24, 24),
                BorderSizePixel = 0,
                AutoButtonColor = false,
                Text = "",
                Parent = ActionsCard
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Color3.fromRGB(40, 40, 40), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
            })

            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Label",
                Size = UDim2.new(0, 300, 0, 20),
                Position = UDim2.new(0, 12, 0, 10),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Color3.fromRGB(215, 215, 215),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = labelText,
                Parent = Card
            })

            local Box = Create("Frame", {
                Name = "Toggle",
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(0, 344, 0, 6),
                BackgroundColor3 = defaultVal and WindowObj.ActiveTheme.Accent or Color3.fromRGB(24, 24, 24),
                BorderSizePixel = 0,
                Parent = Card
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) })
            })
            local BoxStroke = Create("UIStroke", {
                Color = Color3.fromRGB(55, 55, 55),
                Thickness = 1,
                Enabled = not defaultVal,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Parent = Box
            })

            local CheckShort = Create("Frame", {
                Name = "CheckShort",
                Size = UDim2.new(0, 3, 0, 8),
                Position = UDim2.new(0, 8, 0, 12),
                Rotation = -45,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Visible = defaultVal,
                Parent = Box
            })
            local CheckLong = Create("Frame", {
                Name = "CheckLong",
                Size = UDim2.new(0, 3, 0, 14),
                Position = UDim2.new(0, 14, 0, 7),
                Rotation = 40,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Visible = defaultVal,
                Parent = Box
            })

            local currentVal = defaultVal
            local function SetState(val)
                currentVal = val == true
                Box.BackgroundColor3 = currentVal and WindowObj.ActiveTheme.Accent or Color3.fromRGB(24, 24, 24)
                BoxStroke.Enabled = not currentVal
                CheckShort.Visible = currentVal
                CheckLong.Visible = currentVal
                if onChanged then onChanged(currentVal) end
            end

            table.insert(WindowObj.ActiveToggles, {
                Button = Box,
                GetState = function() return currentVal end,
                OffColor = Color3.fromRGB(24, 24, 24)
            })

            Card.MouseButton1Click:Connect(function()
                SetState(not currentVal)
            end)

            return { Card = Card, SetState = SetState, GetState = function() return currentVal end }
        end

        local CheckFriend
        local IgnoreFriendsToggleCard = BuildToggleCard("IgnoreFriendsToggle", "Ignore Friends", true, 198, function(val)
            IgnoreFriends = val
            WindowObj.IgnoreFriends = val
            if pOpts.OnIgnoreFriendsChanged then
                task.spawn(pOpts.OnIgnoreFriendsChanged, val)
            end
        end)

        local AutoFriendsToggleCard = BuildToggleCard("AutoAddFriendsToggle", "Auto Add Roblox Friends", false, 246, function(val)
            AutoFriends = val
            WindowObj.AutoAddFriends = val
            if pOpts.OnAutoAddFriendsChanged then
                task.spawn(pOpts.OnAutoAddFriendsChanged, val)
            end
            if val then
                for plr in pairs(Rows) do CheckFriend(plr) end
            end
        end)

        function CheckFriend(plr)
            if typeof(plr) == "table" and plr.Dummy then return end
            task.spawn(function()
                local ok, isFriend = pcall(function()
                    return LocalPlayer:IsFriendsWith(plr.UserId)
                end)
                if ok and isFriend and GetPriority(plr) == "Neutral" then
                    SetPriority(plr, "Friend")
                end
            end)
        end

        -- ====================================================================
        -- ROW MANAGEMENT
        -- ====================================================================
        function SelectPlayer(plr)
            local previous = Selected
            Selected = plr
            if previous then UpdateRowStyle(previous) end
            if plr then UpdateRowStyle(plr) end
            RefreshInfo()
            RefreshPrioritySegment()
        end

        local rowIndex = 0
        local function AddRow(plr)
            if Rows[plr] then return end
            if plr == LocalPlayer and pOpts.IncludeLocalPlayer ~= true then return end
            rowIndex = rowIndex + 1

            local t = WindowObj.ActiveTheme
            local prio = GetPriority(plr)
            local prioCol = PriorityColors[prio] or PriorityColors.Neutral

            local Frame = Create("TextButton", {
            TextStrokeTransparency = 1,
                Name = (plr.DisplayName or plr.Name):lower() .. "Row",
                Size = UDim2.new(0, 376, 0, 52),
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                AutoButtonColor = false,
                BorderSizePixel = 0,
                Text = "",
                LayoutOrder = rowIndex,
                Parent = ListScroll
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })

            local SelectBar = Create("Frame", {
                Name = "SelectBar",
                Size = UDim2.new(0, 3, 0, 32),
                Position = UDim2.new(0, 0, 0, 10),
                BackgroundColor3 = t.Accent,
                BorderSizePixel = 0,
                Visible = false,
                Parent = Frame
            })

            local Avatar = Create("ImageLabel", {
                Name = "Avatar",
                Size = UDim2.new(0, 36, 0, 36),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderSizePixel = 0,
                Image = Headshot(plr.UserId),
                Parent = Frame
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 99) })
            })
            local AvatarStroke = Create("UIStroke", {
                Color = Color3.fromRGB(45, 45, 45),
                Thickness = 1,
                Parent = Avatar,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })

            local NameLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "DisplayName",
                Size = UDim2.new(0, 220, 0, 20),
                Position = UDim2.new(0, 58, 0, 8),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = Color3.fromRGB(210, 210, 210),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = plr.DisplayName or plr.Name,
                Parent = Frame
            })

            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Username",
                Size = UDim2.new(0, 220, 0, 18),
                Position = UDim2.new(0, 58, 0, 27),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(115, 115, 115),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = "@" .. (plr.Name or ""),
                Parent = Frame
            })

            local TagFrame = Create("Frame", {
                Name = "Priority",
                Size = UDim2.new(0, 84, 0, 30),
                Position = UDim2.new(0, 280, 0, 11),
                BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                BorderSizePixel = 0,
                Parent = Frame
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })
            local TagText = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Text",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = prioCol,
                TextXAlignment = Enum.TextXAlignment.Center,
                Text = prio,
                Parent = TagFrame
            })

            Rows[plr] = {
                Frame = Frame,
                Bar = SelectBar,
                AvatarStroke = AvatarStroke,
                DisplayName = NameLabel,
                TagFrame = TagFrame,
                TagText = TagText
            }

            Frame.MouseButton1Click:Connect(function()
                SelectPlayer(plr)
            end)

            UpdateRowStyle(plr)
            UpdateCount()
            ApplySearch()
            if AutoFriends then CheckFriend(plr) end
        end

        local function RemoveRow(plr)
            local row = Rows[plr]
            if not row then return end
            row.Frame:Destroy()
            Rows[plr] = nil
            if Spectating == plr then StopSpectate() end
            if Selected == plr then SelectPlayer(nil) end
            UpdateCount()
        end

        -- Populate Real Players
        for _, plr in ipairs(Players:GetPlayers()) do
            AddRow(plr)
        end
        Players.PlayerAdded:Connect(AddRow)
        Players.PlayerRemoving:Connect(RemoveRow)

        local firstPlr = next(Rows)
        if firstPlr then SelectPlayer(firstPlr) end

        local elapsed = 0
        RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            if elapsed < 0.25 then return end
            elapsed = 0
            if Tab.Page.Visible and Selected then
                RefreshStats()
            end
        end)

        RefreshInfo()
        RefreshPrioritySegment()
        UpdateCount()

        return Tab
    end

    -- ========================================================================
    -- TARGET HUD (Rebuilt to match Studio 1:1)
    -- ========================================================================
    function WindowObj:CreateTargetHUD(tOpts)
        tOpts = tOpts or {}
        local theme = WindowObj.ActiveTheme
        local curHp = tOpts.Health or 85
        local maxHp = tOpts.MaxHealth or 100
        local curArmor = tOpts.Armor or 0
        local maxArmor = tOpts.MaxArmor or 200
        local curAmmo = tOpts.Ammo or 6
        local maxAmmo = tOpts.MaxAmmo or 6
        local curDist = tOpts.Distance or "34.5 studs"

        local HUD = Create("Frame", {
            Name = "TargetHUD",
            Size = UDim2.new(0, 340, 0, 150),
            Position = tOpts.Position or UDim2.new(1, -350, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            Visible = tOpts.Visible ~= false,
            Parent = ScreenGui
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(38, 38, 38), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local HUDScale = Create("UIScale", { Scale = ScaleVal, Parent = HUD })
        table.insert(WindowObj.ScaleObjects, HUDScale)

        local Header = BuildStripedHeader(HUD, 28)
        MakeDraggable(HUD, Header)

        Create("Frame", {
            Name = "HeaderLine",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 27),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = HUD
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 28),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = tOpts.Title or "Target",
            Parent = HUD
        })

        Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(1, -24, 0, 6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://76535961115022",
            ImageColor3 = Color3.fromRGB(240, 240, 240),
            Parent = HUD
        })

        -- Avatar 98x98
        local AvatarImg = Create("ImageLabel", {
            Name = "Avatar",
            Size = UDim2.new(0, 98, 0, 98),
            Position = UDim2.new(0, 12, 0, 40),
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
            BorderSizePixel = 0,
            Image = tOpts.Avatar or "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150",
            Parent = HUD
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 0.35,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local DisplayNameLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "DisplayName",
            Size = UDim2.new(1, -134, 0, 18),
            Position = UDim2.new(0, 122, 0, 38),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = tOpts.DisplayName or "Target Player",
            Parent = HUD
        })

        local UsernameLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Username",
            Size = UDim2.new(0, 110, 0, 14),
            Position = UDim2.new(0, 122, 0, 57),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = Color3.fromRGB(130, 130, 130),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = tOpts.Username or "@target_user",
            Parent = HUD
        })

        local DistanceLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Distance",
            Size = UDim2.new(0, 90, 0, 14),
            Position = UDim2.new(1, -12, 0, 57),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = tostring(curDist),
            Parent = HUD
        })

        local function CreateStatBar(name, labelText, barColor, posY)
            local Row = Create("Frame", {
                Name = name .. "Row",
                Size = UDim2.new(1, -134, 0, 17),
                Position = UDim2.new(0, 122, 0, posY),
                BackgroundTransparency = 1,
                Parent = HUD
            })

            local Track = Create("CanvasGroup", {
                Name = "Track",
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Color3.fromRGB(22, 22, 24),
                BorderSizePixel = 0,
                Parent = Row
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIStroke", { Color = Color3.fromRGB(38, 38, 38), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
            })

            local Fill = Create("Frame", {
                Name = "Fill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = barColor,
                BorderSizePixel = 0,
                Parent = Track
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) }),
                Create("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 200, 200))
                })
            })

            local Lbl = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Label",
                Size = UDim2.new(0.5, -6, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = labelText,
                ZIndex = 20,
                Parent = Row
            })

            local Val = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Value",
                Size = UDim2.new(0.5, -6, 1, 0),
                Position = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = "",
                ZIndex = 20,
                Parent = Row
            })

            return {
                Row = Row,
                Track = Track,
                Fill = Fill,
                Label = Lbl,
                Value = Val
            }
        end

        local HealthBar = CreateStatBar("Health", "Health", theme.Accent, 80)
        local ArmorBar = CreateStatBar("Armor", "Armor", Color3.fromRGB(60, 205, 255), 101)
        local AmmoBar = CreateStatBar("Ammo", "Ammo", Color3.fromRGB(255, 175, 45), 122)

        local HUDObj = {
            Instance = HUD
        }

        function HUDObj:SetVisible(state)
            HUD.Visible = state == true
        end

        function HUDObj:SetHealth(hp, max)
            curHp = hp or curHp
            maxHp = max or maxHp
            local pct = math.clamp(curHp / math.max(maxHp, 1), 0, 1)
            HealthBar.Value.Text = math.floor(curHp + 0.5) .. " / " .. math.floor(maxHp + 0.5)
            HealthBar.Fill.Size = UDim2.new(pct, 0, 1, 0)
        end

        function HUDObj:SetArmor(armor, max)
            curArmor = armor or curArmor
            maxArmor = max or maxArmor
            local pct = math.clamp(curArmor / math.max(maxArmor, 1), 0, 1)
            ArmorBar.Value.Text = math.floor(curArmor + 0.5) .. " / " .. math.floor(maxArmor + 0.5)
            ArmorBar.Fill.Size = UDim2.new(pct, 0, 1, 0)
        end

        function HUDObj:SetAmmo(ammo, max)
            curAmmo = ammo or curAmmo
            maxAmmo = max or maxAmmo
            local pct = math.clamp(curAmmo / math.max(maxAmmo, 1), 0, 1)
            AmmoBar.Value.Text = tostring(curAmmo) .. " / " .. tostring(maxAmmo)
            AmmoBar.Fill.Size = UDim2.new(pct, 0, 1, 0)
        end

        function HUDObj:SetDistance(dist)
            if type(dist) == "number" then
                DistanceLabel.Text = string.format("%.1f studs", dist)
            else
                DistanceLabel.Text = tostring(dist)
            end
        end

        function HUDObj:SetAvatar(assetOrUserId)
            if type(assetOrUserId) == "number" then
                AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. assetOrUserId .. "&w=150&h=150"
            else
                AvatarImg.Image = tostring(assetOrUserId)
            end
        end

        function HUDObj:SetName(displayName, username)
            if displayName then DisplayNameLabel.Text = tostring(displayName) end
            if username then
                UsernameLabel.Text = username:sub(1, 1) == "@" and username or ("@" .. username)
            end
        end

        function HUDObj:SetPlayer(plr)
            if not plr then return end
            HUDObj:SetAvatar(plr.UserId)
            HUDObj:SetName(plr.DisplayName, plr.Name)

            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                HUDObj:SetHealth(hum.Health, hum.MaxHealth)
            end

            local myChar = LocalPlayer and LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if root and myRoot then
                HUDObj:SetDistance((root.Position - myRoot.Position).Magnitude)
            end
        end

        HUDObj:SetHealth(curHp, maxHp)
        HUDObj:SetArmor(curArmor, maxArmor)
        HUDObj:SetAmmo(curAmmo, maxAmmo)

        WindowObj.TargetHUD = HUDObj
        return HUDObj
    end

    -- ========================================================================
    -- AUTO KILL LOGS (Rebuilt to match Studio 1:1)
    -- ========================================================================
    function WindowObj:CreateAutoKillLogs(kOpts)
        kOpts = kOpts or {}
        local theme = WindowObj.ActiveTheme

        local KillLogs = Create("Frame", {
            Name = "AutoKillLogs",
            Size = UDim2.new(0, 340, 0, 272),
            Position = kOpts.Position or UDim2.new(1, -350, 0.5, 66),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BorderSizePixel = 0,
            Visible = kOpts.Visible ~= false,
            Parent = ScreenGui
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(38, 38, 38), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local Scale = Create("UIScale", { Scale = ScaleVal, Parent = KillLogs })
        table.insert(WindowObj.ScaleObjects, Scale)

        local Header = BuildStripedHeader(KillLogs, 28)
        MakeDraggable(KillLogs, Header)

        Create("Frame", {
            Name = "HeaderLine",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 0, 27),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = KillLogs
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "Title",
            Size = UDim2.new(1, -40, 0, 28),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = kOpts.Title or "Auto Kill Logs",
            Parent = KillLogs
        })

        local TargetCountLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "TargetCount",
            Size = UDim2.new(0, 60, 0, 28),
            Position = UDim2.new(1, -12, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = kOpts.Count or "10 / 10",
            Parent = KillLogs
        })

        -- Summary Frame (54px)
        local Summary = Create("Frame", {
            Name = "Summary",
            Size = UDim2.new(1, -24, 0, 54),
            Position = UDim2.new(0, 12, 0, 38),
            BackgroundColor3 = Color3.fromRGB(21, 21, 21),
            BorderSizePixel = 0,
            Parent = KillLogs
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = Color3.fromRGB(38, 38, 38), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local myUserId = kOpts.MyUserId or (LocalPlayer and LocalPlayer.UserId or 1)
        local MyAvatar = Create("ImageLabel", {
            Name = "MyAvatar",
            Size = UDim2.new(0, 38, 0, 38),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
            BorderSizePixel = 0,
            Image = kOpts.MyAvatar or ("rbxthumb://type=AvatarHeadShot&id=" .. myUserId .. "&w=150&h=150"),
            Parent = Summary
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Create("UIStroke", { Color = theme.Accent, Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
        })

        local MyNameLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "MyName",
            Size = UDim2.new(0.55, -54, 0, 18),
            Position = UDim2.new(0, 54, 0, 10),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = kOpts.MyName or (LocalPlayer and LocalPlayer.DisplayName or "OzuTradeSphereX"),
            Parent = Summary
        })

        Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "ScoreCaption",
            Size = UDim2.new(0.55, -54, 0, 14),
            Position = UDim2.new(0, 54, 0, 29),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Color3.fromRGB(130, 130, 130),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Total score vs targets",
            Parent = Summary
        })

        local TotalScoreLabel = Create("TextLabel", {
            TextStrokeTransparency = 1,
            Name = "TotalScore",
            Size = UDim2.new(0, 100, 0, 26),
            Position = UDim2.new(1, -10, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextColor3 = theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = kOpts.TotalScore or "25 - 11",
            Parent = Summary
        })

        -- TargetList (160px)
        local TargetList = Create("ScrollingFrame", {
            Name = "TargetList",
            Size = UDim2.new(1, -24, 0, 160),
            Position = UDim2.new(0, 12, 0, 100),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(38, 38, 38),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = KillLogs
        }, {
            Create("UIPadding", {
                PaddingRight = UDim.new(0, 4)
            }),
            Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })

        local targetEntries = {}

        local function ClearTargets()
            for _, inst in ipairs(TargetList:GetChildren()) do
                if inst:IsA("Frame") then
                    inst:Destroy()
                end
            end
            table.clear(targetEntries)
        end

        local function AddTargetRow(idx, targetData)
            local nameStr = targetData.name or targetData.Name or ("Target Player " .. idx)
            local scoreStr = targetData.score or targetData.Score or (tostring(targetData.kills or 0) .. " - " .. tostring(targetData.deaths or 0))
            local userId = targetData.userId or targetData.UserId or 1
            local isPositive = targetData.isPositive
            if isPositive == nil then
                local k, d = scoreStr:match("(%d+)%s*-%s*(%d+)")
                if k and d then
                    isPositive = tonumber(k) >= tonumber(d) and tonumber(k) > 0
                else
                    isPositive = true
                end
            end

            local row = Create("Frame", {
                Name = "Target_" .. idx,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Color3.fromRGB(21, 21, 21),
                BorderSizePixel = 0,
                LayoutOrder = idx,
                Parent = TargetList
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Color3.fromRGB(38, 38, 38), Thickness = 1,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        })
            })

            local barColor = isPositive and theme.Accent or Color3.fromRGB(70, 70, 70)
            Create("Frame", {
                Name = "Bar",
                Size = UDim2.new(0, 2, 1, -10),
                Position = UDim2.new(0, 4, 0, 5),
                BackgroundColor3 = barColor,
                BorderSizePixel = 0,
                Parent = row
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 1) })
            })

            Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Index",
                Size = UDim2.new(0, 14, 0, 28),
                Position = UDim2.new(0, 11, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Color3.fromRGB(130, 130, 130),
                Text = tostring(idx),
                Parent = row
            })

            local avatarUrl = targetData.avatar or ("rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150")
            Create("ImageLabel", {
                Name = "Avatar",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 30, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(26, 26, 26),
                BorderSizePixel = 0,
                Image = avatarUrl,
                Parent = row
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })

            local NameLbl = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Name",
                Size = UDim2.new(1, -130, 1, 0),
                Position = UDim2.new(0, 58, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(225, 225, 225),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = nameStr,
                Parent = row
            })

            local ScoreLbl = Create("TextLabel", {
            TextStrokeTransparency = 1,
                Name = "Score",
                Size = UDim2.new(0, 60, 0, 28),
                Position = UDim2.new(1, -8, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = isPositive and theme.Accent or Color3.fromRGB(130, 130, 130),
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = scoreStr,
                Parent = row
            })

            local entry = {
                Row = row,
                NameLabel = NameLbl,
                ScoreLabel = ScoreLbl,
                Update = function(self, newScore, positive)
                    ScoreLbl.Text = tostring(newScore)
                    if positive ~= nil then
                        ScoreLbl.TextColor3 = positive and theme.Accent or Color3.fromRGB(130, 130, 130)
                    end
                end
            }
            table.insert(targetEntries, entry)
            return entry
        end

        local defaultTargets = kOpts.Targets or {}

        for i, t in ipairs(defaultTargets) do
            AddTargetRow(i, t)
        end

        local KillLogsObj = {
            Instance = KillLogs
        }

        function KillLogsObj:SetVisible(state)
            KillLogs.Visible = state == true
        end

        function KillLogsObj:SetCount(countStr)
            TargetCountLabel.Text = tostring(countStr)
        end

        function KillLogsObj:SetTotalScore(scoreStr)
            TotalScoreLabel.Text = tostring(scoreStr)
        end

        function KillLogsObj:SetSummary(opts)
            opts = opts or {}
            if opts.MyName then MyNameLabel.Text = opts.MyName end
            if opts.TotalScore then TotalScoreLabel.Text = opts.TotalScore end
            if opts.Count then TargetCountLabel.Text = opts.Count end
            if opts.MyAvatar then MyAvatar.Image = opts.MyAvatar end
            if opts.MyUserId then
                MyAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. opts.MyUserId .. "&w=150&h=150"
            end
        end

        function KillLogsObj:SetTargets(list)
            ClearTargets()
            for i, t in ipairs(list) do
                AddTargetRow(i, t)
            end
            TargetCountLabel.Text = #list .. " / " .. #list
        end

        function KillLogsObj:AddTarget(targetData)
            local idx = #targetEntries + 1
            AddTargetRow(idx, targetData)
            TargetCountLabel.Text = idx .. " / " .. idx
        end

        WindowObj.AutoKillLogs = KillLogsObj
        return KillLogsObj
    end

    function WindowObj:SetTargetHUDVisible(state)
        if WindowObj.TargetHUD then
            WindowObj.TargetHUD:SetVisible(state)
        end
    end

    function WindowObj:SetAutoKillLogsVisible(state)
        if WindowObj.AutoKillLogs then
            WindowObj.AutoKillLogs:SetVisible(state)
        end
    end

    return WindowObj
end

function fatalwtfuilibrary.CreateLoader(firstArg, secondArg)
    local opts = (type(firstArg) == "table" and firstArg ~= fatalwtfuilibrary) and firstArg or (secondArg or {})
    if opts.OnLoaded then
        task.spawn(opts.OnLoaded)
    end
    return {
        Destroy = function() end,
        Load = function() if opts.OnLoaded then task.spawn(opts.OnLoaded) end end,
        AddLog = function() end,
        AddStat = function() end
    }
end

return fatalwtfuilibrary


