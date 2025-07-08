-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create UI window
local Window = Rayfield:CreateWindow({
   Name = "Bloxify",
   Icon = 0,
   LoadingTitle = "Bloxify",
   LoadingSubtitle = "by vxperity",
   ShowText = "Bloxify",
   Theme = "Default",
   ToggleUIKeybind = "X",

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "Password",
      Subtitle = "Script by vxperity",
      Note = "Code is autofarm67",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"autofarm67"}
   }
})

-- Create Autofarm tab
local Tab = Window:CreateTab("Autofarm", 4483362458)

-- Autofarm variables
local autofarmRunning = false
local player = game.Players.LocalPlayer
local tool = player.Backpack:FindFirstChild("steal food")

-- CFrame definitions
local stealFoodLocation = CFrame.new(
    73.0000229, 23.9500122, 292.496765,
   -1.2755394e-05, 0.819186091, -0.573527873,
   -1, -1.2755394e-05, 3.9935112e-06,
   -3.9935112e-06, 0.573527873, 0.819186032
)

local giveFoodLocation = CFrame.new(
    60.117775, 0.0100130001, -1293.98157,
   -3.23057175e-05, -0.707060337, -0.707153201,
   -1, 3.23057175e-05, 1.33812428e-05,
    1.33812428e-05, 0.707153201, -0.707060337
)

-- Utility functions
local function equipTool()
    tool = player.Backpack:FindFirstChild("steal food")
    if tool then
        player.Character.Humanoid:EquipTool(tool)
    end
end

local function moveTo(cframe)
    player.Character:SetPrimaryPartCFrame(cframe)
end

local function autoClickUntil(targetValue, comparisonType)
    while autofarmRunning and tool and tool:GetAttribute("CurrentFood") ~= nil do
        local currentFood = tool:GetAttribute("CurrentFood")

        if (comparisonType == "increase" and currentFood >= targetValue) or
           (comparisonType == "decrease" and currentFood <= targetValue) then
            break
        end

        tool:Activate()
        wait(0.1)
    end
end

-- Create toggle
Tab:CreateToggle({
    Name = "Start Autofarm",
    CurrentValue = false,
    Flag = "AutofarmToggle",
    Callback = function(Value)
        autofarmRunning = Value

        if autofarmRunning then
            equipTool()
            spawn(function()
                while autofarmRunning do
                    moveTo(stealFoodLocation)
                    autoClickUntil(100, "increase")

                    moveTo(giveFoodLocation)
                    autoClickUntil(0, "decrease")
                end
            end)
        end
    end
})
