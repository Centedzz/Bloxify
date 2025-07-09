-- Preventing Multiple Processes
pcall(function()
    getgenv().Aimbot.Functions:Exit()
end)

-- Environment
getgenv().Aimbot = {}
local Environment = getgenv().Aimbot

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local Stats = game:GetService("Stats")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Title = "AimbotConfig"
local FileNames = {"Aimbot", "Configuration.json", "Drawing.json", "Prediction.json"}
local Typing, Running, Animation, RequiredDistance, ServiceConnections = false, false, nil, 2000, {}

-- Support Functions
local function Encode(Table)
	if Table and type(Table) == "table" then
		return HttpService:JSONEncode(Table)
	end
end

local function Decode(String)
	if String and type(String) == "string" then
		return HttpService:JSONDecode(String)
	end
end

local function GetColor(Color)
	local R = tonumber(string.match(Color, "([%d]+)[%s]*,[%s]*[%d]+[%s]*,[%s]*[%d]+"))
	local G = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*([%d]+)[%s]*,[%s]*[%d]+"))
	local B = tonumber(string.match(Color, "[%d]+[%s]*,[%s]*[%d]+[%s]*,[%s]*([%d]+)"))
	return Color3.fromRGB(R, G, B)
end

-- Settings (Default)
Environment.Settings = {
	SendNotifications = true,
	SaveSettings = true,
	ReloadOnTeleport = false,
	Enabled = false,
	TeamCheck = false,
	AliveCheck = true,
	WallCheck = false,
	Sensitivity = 0,
	ThirdPerson = false,
	ThirdPersonSensitivity = 3,
	TriggerKey = "MouseButton2",
	Toggle = false,
	LockPart = "Head",
	CopMode = false,
	PrisonerMode = false
}

Environment.FOVSettings = {
	Enabled = true,
	Visible = true,
	Amount = 90,
	Color = "255, 255, 255",
	LockedColor = "255, 70, 70",
	Transparency = 0.5,
	Sides = 60,
	Thickness = 1,
	Filled = false
}

Environment.PredictionSettings = {
	Enabled = true,
	PredictionMode = "Ping",
	DefaultPrediction = 0.165,
	PingBasedMultiplier = 0.00075,
	CustomPrediction = 0.2
}

Environment.TriggerBot = {
	Enabled = false,
	Debounce = false,
	Connection = nil
}

-- Drawing Circle for FOV
Environment.FOVCircle = Drawing.new("Circle")
Environment.Locked = nil
Environment.LastPing = 0
Environment.LastPrediction = 0

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Aimbot",
	LoadingTitle = "Aimbot V2",
	LoadingSubtitle = "Loading...",
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = false
})

-- Aimbot Tab
local AimbotTab = Window:CreateTab("\226\144\175 Aimbot", 4483362458)
AimbotTab:CreateToggle({Name = "Enabled", CurrentValue = Environment.Settings.Enabled, Callback = function(val) Environment.Settings.Enabled = val end})
AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = Environment.Settings.TeamCheck, Callback = function(val) Environment.Settings.TeamCheck = val end})
AimbotTab:CreateToggle({Name = "Alive Check", CurrentValue = Environment.Settings.AliveCheck, Callback = function(val) Environment.Settings.AliveCheck = val end})
AimbotTab:CreateToggle({Name = "Wall Check", CurrentValue = Environment.Settings.WallCheck, Callback = function(val) Environment.Settings.WallCheck = val end})
AimbotTab:CreateDropdown({Name = "Lock Part", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, CurrentOption = Environment.Settings.LockPart, Callback = function(opt) Environment.Settings.LockPart = opt end})
AimbotTab:CreateKeybind({Name = "Aimbot Key", CurrentKeybind = Enum.UserInputType[Environment.Settings.TriggerKey] or Enum.KeyCode.MouseButton2, HoldToInteract = not Environment.Settings.Toggle, Callback = function(Key) Environment.Settings.TriggerKey = Key.Name end})

-- FOV Tab
local FOVTab = Window:CreateTab("\240\159\149\143 FOV", 4483362458)
FOVTab:CreateToggle({Name = "Enable FOV Circle", CurrentValue = Environment.FOVSettings.Enabled, Callback = function(val) Environment.FOVSettings.Enabled = val end})
FOVTab:CreateSlider({Name = "FOV Radius", Range = {20, 500}, Increment = 1, CurrentValue = Environment.FOVSettings.Amount, Callback = function(val) Environment.FOVSettings.Amount = val end})
FOVTab:CreateColorPicker({Name = "FOV Color", Color = GetColor(Environment.FOVSettings.Color), Callback = function(color) local r, g, b = color.R * 255, color.G * 255, color.B * 255 Environment.FOVSettings.Color = string.format("%d, %d, %d", r, g, b) end})

-- Prediction Tab
local PredictionTab = Window:CreateTab("\240\159\147\161 Prediction", 4483362458)
PredictionTab:CreateDropdown({Name = "Prediction Mode", Options = {"Default", "Ping", "Custom"}, CurrentOption = Environment.PredictionSettings.PredictionMode, Callback = function(opt) Environment.PredictionSettings.PredictionMode = opt end})
PredictionTab:CreateSlider({Name = "Custom Prediction Value", Range = {0.01, 1}, Increment = 0.01, CurrentValue = Environment.PredictionSettings.CustomPrediction, Callback = function(val) Environment.PredictionSettings.CustomPrediction = val end})

-- TriggerBot Tab
local TriggerTab = Window:CreateTab("\240\159\148\165 TriggerBot", 4483362458)
TriggerTab:CreateToggle({Name = "Enable TriggerBot", CurrentValue = Environment.TriggerBot.Enabled, Callback = function(val) Environment.TriggerBot.Enabled = val end})

-- Utility Tab
local UtilTab = Window:CreateTab("\240\159\143\176 Utilities", 4483362458)
UtilTab:CreateButton({Name = "Reset All Settings", Callback = function() if Environment.Functions then Environment.Functions:ResetSettings() Rayfield:Notify({Title = "Reset", Content = "Settings have been reset.", Duration = 5}) end end})
UtilTab:CreateButton({Name = "Unload Aimbot", Callback = function() if Environment.Functions then Environment.Functions:Exit() end end})

-- Finish rest of aimbot logic loading and connections (not shown here)
-- You must insert the full aimbot logic from your provided code after this section.

-- Example: Load()
-- Load() -- Ensure this is called after settings are done

print("Aimbot with Rayfield UI Loaded")
