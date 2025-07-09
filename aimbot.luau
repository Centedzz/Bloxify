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
    LoadingSubtitle = "by Anonymous",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Aimbot Tab
local AimbotTab = Window:CreateTab("⚏ Aimbot", 4483362458)
AimbotTab:CreateToggle({Name = "Enabled", CurrentValue = Environment.Settings.Enabled, Callback = function(val) Environment.Settings.Enabled = val end})
AimbotTab:CreateToggle({Name = "Team Check", CurrentValue = Environment.Settings.TeamCheck, Callback = function(val) Environment.Settings.TeamCheck = val end})
AimbotTab:CreateToggle({Name = "Alive Check", CurrentValue = Environment.Settings.AliveCheck, Callback = function(val) Environment.Settings.AliveCheck = val end})
AimbotTab:CreateToggle({Name = "Wall Check", CurrentValue = Environment.Settings.WallCheck, Callback = function(val) Environment.Settings.WallCheck = val end})
AimbotTab:CreateDropdown({Name = "Lock Part", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, CurrentOption = Environment.Settings.LockPart, Callback = function(opt) Environment.Settings.LockPart = opt end})
AimbotTab:CreateKeybind({Name = "Aimbot Key", CurrentKeybind = Enum.UserInputType[Environment.Settings.TriggerKey] or Enum.KeyCode.MouseButton2, HoldToInteract = not Environment.Settings.Toggle, Callback = function(Key) Environment.Settings.TriggerKey = Key.Name end})

-- FOV Tab
local FOVTab = Window:CreateTab("🔵 FOV", 4483362458)
FOVTab:CreateToggle({Name = "Enable FOV Circle", CurrentValue = Environment.FOVSettings.Enabled, Callback = function(val) Environment.FOVSettings.Enabled = val end})
FOVTab:CreateSlider({Name = "FOV Radius", Range = {20, 500}, Increment = 1, CurrentValue = Environment.FOVSettings.Amount, Callback = function(val) Environment.FOVSettings.Amount = val end})
FOVTab:CreateColorPicker({Name = "FOV Color", Color = GetColor(Environment.FOVSettings.Color), Callback = function(color) local r, g, b = color.R * 255, color.G * 255, color.B * 255 Environment.FOVSettings.Color = string.format("%d, %d, %d", r, g, b) end})

-- Prediction Tab
local PredictionTab = Window:CreateTab("⚡ Prediction", 4483362458)
PredictionTab:CreateDropdown({Name = "Prediction Mode", Options = {"Default", "Ping", "Custom"}, CurrentOption = Environment.PredictionSettings.PredictionMode, Callback = function(opt) Environment.PredictionSettings.PredictionMode = opt end})
PredictionTab:CreateSlider({Name = "Custom Prediction Value", Range = {0.01, 1}, Increment = 0.01, CurrentValue = Environment.PredictionSettings.CustomPrediction, Callback = function(val) Environment.PredictionSettings.CustomPrediction = val end})

-- TriggerBot Tab
local TriggerTab = Window:CreateTab("🎯 TriggerBot", 4483362458)
TriggerTab:CreateToggle({Name = "Enable TriggerBot", CurrentValue = Environment.TriggerBot.Enabled, Callback = function(val) Environment.TriggerBot.Enabled = val end})

-- Utility Tab
local UtilTab = Window:CreateTab("🛠 Utilities", 4483362458)
UtilTab:CreateButton({Name = "Reset All Settings", Callback = function() if Environment.Functions then Environment.Functions:ResetSettings() Rayfield:Notify({Title = "Reset", Content = "Settings have been reset.", Duration = 5}) end end})
UtilTab:CreateButton({Name = "Unload Aimbot", Callback = function() if Environment.Functions then Environment.Functions:Exit() end end})

-- Optimized prediction calculation
local function GetPredictionValue()
    if not Environment.PredictionSettings.Enabled then
        return 0
    end

    local prediction = 0

    if Environment.PredictionSettings.PredictionMode == "Default" then
        prediction = Environment.PredictionSettings.DefaultPrediction
    elseif Environment.PredictionSettings.PredictionMode == "Ping" then
        if tick() - Environment.LastPing > 0.5 then
            Environment.LastPing = tick()
            local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
            prediction = ping * Environment.PredictionSettings.PingBasedMultiplier
            Environment.LastPrediction = prediction
        else
            prediction = Environment.LastPrediction
        end
    elseif Environment.PredictionSettings.PredictionMode == "Custom" then
        prediction = Environment.PredictionSettings.CustomPrediction
    end

    return prediction
end

-- Optimized wall check function
local function IsTargetVisible(target, targetPart)
    if not Environment.Settings.WallCheck then return true end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

    local targetPosition = targetPart.Position
    local cameraPosition = Camera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit

    local result = workspace:Raycast(cameraPosition, direction * 1000, rayParams)
    return result and result.Instance:IsDescendantOf(target.Character)
end

function IsPlayerInTeamCategory(player, category)
    if not player or not player.Team then return false end

    local teamName = player.Team.Name
    if category == "Prisoner" then
        local prisonerTeams = {
            "Booking",
            "Escapee",
            "Maximum Security",
            "Medium Security",
            "Minimum Security"
        }

        for _, team in ipairs(prisonerTeams) do
            if teamName == team then
                return true
            end
        end
    elseif category == "Cop" then
        local copTeams = {
            "Civilian",
            "Department of Corrections",
            "Sheriff's Office",
            "State Police",
            "VCSO-SWAT",
            "WeaponsTester"
        }

        for _, team in ipairs(copTeams) do
            if teamName == team then
                return true
            end
        end
    end

    return false
end

-- Optimized GetClosestPlayer function
local function GetClosestPlayer()
    if not Environment.Locked then
        if Environment.FOVSettings.Enabled then
            RequiredDistance = Environment.FOVSettings.Amount
        else
            RequiredDistance = 2000
        end

        local closestPlayer = nil
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in next, Players:GetPlayers() do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    local targetPart = character:FindFirstChild(Environment.Settings.LockPart)
                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    if targetPart and humanoid then
                        if Environment.Settings.CopMode and not IsPlayerInTeamCategory(player, "Prisoner") then
                            continue
                        end
                        if Environment.Settings.PrisonerMode and not IsPlayerInTeamCategory(player, "Cop") then
                            continue
                        end
                        if Environment.Settings.TeamCheck and player.Team == LocalPlayer.Team then
                            continue
                        end
                        if Environment.Settings.AliveCheck and humanoid.Health <= 0 then
                            continue
                        end

                        local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if not onScreen then continue end

                        local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(vector.X, vector.Y)).Magnitude

                        if distance < RequiredDistance then
                            if not Environment.Settings.WallCheck or IsTargetVisible(player, targetPart) then
                                RequiredDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end

        Environment.Locked = closestPlayer
    elseif Environment.Locked and Environment.Locked.Character then
        local targetPart = Environment.Locked.Character:FindFirstChild(Environment.Settings.LockPart)
        if not targetPart then
            Environment.Locked = nil
            if Animation then Animation:Cancel() end
            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
            return
        end

        local vector, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then
            Environment.Locked = nil
            if Animation then Animation:Cancel() end
            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
            return
        end

        local mousePos = UserInputService:GetMouseLocation()
        local distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(vector.X, vector.Y)).Magnitude

        if distance > RequiredDistance or (Environment.Settings.WallCheck and not IsTargetVisible(Environment.Locked, targetPart)) then
            Environment.Locked = nil
            if Animation then Animation:Cancel() end
            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
        end
    else
        Environment.Locked = nil
        if Animation then Animation:Cancel() end
        Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
    end
end

-- TriggerBot implementation
local function SetupTriggerBot()
    if Environment.TriggerBot.Connection then
        Environment.TriggerBot.Connection:Disconnect()
        Environment.TriggerBot.Connection = nil
    end

    Environment.TriggerBot.Connection = RunService.RenderStepped:Connect(function()
        if not Environment.TriggerBot.Enabled then return end
        if Environment.TriggerBot.Debounce then return end

        local Mouse = LocalPlayer:GetMouse()
        local Target = Mouse.Target

        if not Target or not Target.Parent then return end

        local Player = Players:GetPlayerFromCharacter(Target.Parent)
        if not Player then return end

        if Environment.Settings.TeamCheck and Player.Team == LocalPlayer.Team then return end
        if Environment.Settings.CopMode and not IsPlayerInTeamCategory(Player, "Prisoner") then
            return
        end
        if Environment.Settings.PrisonerMode and not IsPlayerInTeamCategory(Player, "Cop") then
            return
        end

        local Character = Player.Character
        if not Character then return end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Environment.Settings.AliveCheck and (not Humanoid or Humanoid.Health <= 0) then return end

        if Character:FindFirstChildOfClass("ForceField") then return end

        if Environment.Settings.WallCheck and not IsTargetVisible(Player, Target) then
            return
        end

        Environment.TriggerBot.Debounce = true

        task.spawn(function()
            mouse1press()

            repeat
                RunService.RenderStepped:Wait()
                local CurrentTarget = Mouse.Target
                local CurrentPlayer = CurrentTarget and CurrentTarget.Parent and Players:GetPlayerFromCharacter(CurrentTarget.Parent)

                if not CurrentTarget or not CurrentPlayer or CurrentPlayer ~= Player then
                    break
                end
            until not Environment.TriggerBot.Enabled

            mouse1release()
            Environment.TriggerBot.Debounce = false
        end)
    end)
end

-- Typing Check
ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
    Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
    Typing = false
end)

-- Save Settings
local function SaveSettings()
    if Environment.Settings.SaveSettings then
        if isfolder(Title) then
            if not isfolder(Title.."/"..FileNames[1]) then
                makefolder(Title.."/"..FileNames[1])
            end
            writefile(Title.."/"..FileNames[1].."/"..FileNames[2], Encode(Environment.Settings))
            writefile(Title.."/"..FileNames[1].."/"..FileNames[3], Encode(Environment.FOVSettings))
            writefile(Title.."/"..FileNames[1].."/"..FileNames[4], Encode(Environment.PredictionSettings))
        end
    end
end

-- Main Load function
local function Load()
    -- RenderStepped connection
    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
            Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
            Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
            Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
            Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
            Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
            Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
            Environment.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Running and Environment.Settings.Enabled then
            GetClosestPlayer()
            if Environment.Locked and Environment.Locked.Character and Environment.Locked.Character:FindFirstChild(Environment.Settings.LockPart) then
                local targetPart = Environment.Locked.Character[Environment.Settings.LockPart]
                local predictionValue = GetPredictionValue()
                local predictedPosition = targetPart.Position + (targetPart.Velocity * predictionValue)

                if Environment.Settings.ThirdPerson then
                    Environment.Settings.ThirdPersonSensitivity = math.clamp(Environment.Settings.ThirdPersonSensitivity, 0.1, 5)
                    local Vector = Camera:WorldToViewportPoint(predictedPosition)
                    mousemoverel(
                        (Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity,
                        (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity
                    )
                else
                    if Environment.Settings.Sensitivity > 0 then
                        if Animation then
                            Animation:Cancel()
                        end
                        Animation = TweenService:Create(Camera, TweenInfo.new(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)})
                        Animation:Play()
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
                    end
                end

                Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.LockedColor)
            else
                Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
            end
        else
            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
        end
    end)

    -- Input handling
    ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
        if not Typing then
            pcall(function()
                if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                    if Environment.Settings.Toggle then
                        Running = not Running
                        if not Running then
                            Environment.Locked = nil
                            if Animation then
                                Animation:Cancel()
                            end
                            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                        end
                    else
                        Running = true
                    end
                end
            end)
            pcall(function()
                if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                    if Environment.Settings.Toggle then
                        Running = not Running
                        if not Running then
                            Environment.Locked = nil
                            if Animation then
                                Animation:Cancel()
                            end
                            Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                        end
                    else
                        Running = true
                    end
                end
            end)
        end
    end)

    ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
        if not Typing then
            if Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerKey] then
                if not Environment.Settings.Toggle then
                    Running = false
                    Environment.Locked = nil
                    if Animation then
                        Animation:Cancel()
                    end
                    Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                end
            end
            if Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                if not Environment.Settings.Toggle then
                    Running = false
                    Environment.Locked = nil
                    if Animation then
                        Animation:Cancel()
                    end
                    Environment.FOVCircle.Color = GetColor(Environment.FOVSettings.Color)
                end
            end
        end
    end)

    -- Setup TriggerBot
    SetupTriggerBot()
end

-- Functions for resetting settings and exiting
Environment.Functions = {}

function Environment.Functions:ResetSettings()
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
    Environment.TriggerBot.Enabled = false
    Environment.Locked = nil
    Running = false
end

function Environment.Functions:Exit()
    for _, conn in pairs(ServiceConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    Environment.FOVCircle:Remove()
    Environment.Locked = nil
    Running = false
    Typing = false
    Environment = nil
    getgenv().Aimbot = nil
end

-- Run Load to start the aimbot logic!
Load()

print("Aimbot with Rayfield UI and full logic loaded.")

