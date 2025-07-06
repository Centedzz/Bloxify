local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Bloxify",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Bloxify",
    LoadingSubtitle = "by vxperity",
    ShowText = "Bloxify", -- for mobile users to unhide rayfield, change if you'd like
    Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },

   KeySystem = true,
   KeySettings = {
   Title = "Key",
   Subtitle = "Password",
   Note = "The key is valleyprison67",
   FileName = "Key", 
   SaveKey = false, 
   GrabKeyFromSite = false, 
   Key = {"valleyprison67"} 
}

 })

 local PlayerTab = Window:CreateTab("Player", 4483362458) -- Title, Image

local Slider = PlayerTab:CreateSlider({
    Name = "Walkspeed",
    Range = {0, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16, -- or the player's default speed
    Flag = "Slider1",
    Callback = function(Value)
        local Player = game.Players.LocalPlayer
        local DefaultWalkSpeedValue = Player:FindFirstChild("ServerVariables")
            and Player.ServerVariables:FindFirstChild("Sprint")
            and Player.ServerVariables.Sprint:FindFirstChild("DefaultWalkSpeed")

        if DefaultWalkSpeedValue then
            DefaultWalkSpeedValue.Value = Value
        else
            warn("DefaultWalkSpeed value not found!")
        end
    end,
})

local SprintWalkspeedSlider = PlayerTab:CreateSlider({
    Name = "Sprint Walkspeed",
    Range = {0, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 20, -- or whatever your sprint speed normally starts at
    Flag = "Slider2",
    Callback = function(Value)
        local Player = game.Players.LocalPlayer
        local SprintWalkSpeedValue = Player:FindFirstChild("ServerVariables")
            and Player.ServerVariables:FindFirstChild("Sprint")
            and Player.ServerVariables.Sprint:FindFirstChild("SprintWalkSpeed")

        if SprintWalkSpeedValue then
            SprintWalkSpeedValue.Value = Value
        else
            warn("SprintWalkSpeed value not found!")
        end
    end,
})

