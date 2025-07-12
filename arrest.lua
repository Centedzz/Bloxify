local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local escapeeTarget = nil
local followConnection = nil
local targetTeamName = "Escapee"

local knownStaffIds = {
    1078803652, 103415684, 88554863, 2596431645, 6209871807, 2586607449,
    1639935407, 5755033491, 2666293035, 4150224481, 4521477021, 516340376,
    1019416391, 1568722355, 1419883261, 677893384, 1610467201, 76622615,
    3160916527, 5834670421, 304218468, 516954569, 3821639731, 243329354,
    3236777516, 640073286, 97940975, 756353889, 474657539, 713313171,
    316958565, 145788919, 320456898, 2521325511, 1230976883, 3100284074,
    120034822, 50730165, 100409924
}

local baseCFrame = CFrame.new(
    136.623703, 19.5980606, -168.573776,
    -1, 0, 0,
    0, 1, 0,
    0, 0, -1
)

local function simulateDetain()
    task.wait(3)
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local cuffUI = gui:FindFirstChild("CuffUI")
    if not cuffUI then return end
    local leftFrame = cuffUI:FindFirstChild("LeftFrame")
    if not leftFrame then return end
    local detainButton = leftFrame:FindFirstChild("Detain")
    if detainButton and detainButton:IsA("TextButton") and detainButton.Visible and detainButton.Active then
        detainButton:Activate()
    end
end

local function followTarget(player)
    if followConnection then 
        followConnection:Disconnect() 
        followConnection = nil
    end
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local timeInvalid = 0
    local maxWait = 10

    followConnection = RunService.RenderStepped:Connect(function(dt)
        if not player or not player.Parent then
            if followConnection then 
                followConnection:Disconnect() 
                followConnection = nil
            end
            return
        end
        
        local targetTeam = player.Team and player.Team.Name
        local targetChar = player.Character
        local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if targetTeam == targetTeamName and targetHRP and hrp then
            timeInvalid = 0
            hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 2, 0)
        else
            timeInvalid += dt
            if timeInvalid >= maxWait then
                if followConnection then 
                    followConnection:Disconnect() 
                    followConnection = nil
                end
                escapeeTarget = nil

                local found = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Team and p.Team.Name == targetTeamName then
                        escapeeTarget = p
                        followTarget(p)
                        simulateDetain()
                        found = true
                        break
                    end
                end

                if not found and hrp then
                    hrp.CFrame = baseCFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.3)
        if escapeeTarget then 
            followTarget(escapeeTarget) 
        end
    end)
end

local function runDetainSequence()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team and player.Team.Name == targetTeamName then
            escapeeTarget = player
            followTarget(player)
            simulateDetain()
            return
        end
    end

    local character = LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = baseCFrame + Vector3.new(0, 3, 0)
        end
    end
end

local function monitorHandcuffs()
    local function check(container)
        local cuffs = container:FindFirstChild("Handcuffs")
        if cuffs and cuffs:IsA("Tool") then
            runDetainSequence()
        end
    end

    local backpack = LocalPlayer:WaitForChild("Backpack")
    local serverVars = LocalPlayer:FindFirstChild("ServerVariables")

    if backpack then check(backpack) end
    if serverVars then check(serverVars) end

    backpack.ChildAdded:Connect(function(c)
        if c.Name == "Handcuffs" then 
            check(backpack) 
        end
    end)

    if serverVars then
        serverVars.ChildAdded:Connect(function(c)
            if c.Name == "Handcuffs" then 
                check(serverVars) 
            end
        end)
    end
end

local function disableGuardBarriers()
    local folder = workspace:FindFirstChild("Map")
        and workspace.Map.Functional
        and workspace.Map.Functional.Invisible
        and workspace.Map.Functional.Invisible:FindFirstChild("GuardBarriers")

    if folder then
        for _, part in ipairs(folder:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanTouch = false
                part.CanCollide = false
                part.Transparency = 1
            end
        end
    end
end

local function neutralizeSpawnkillBarriers()
    local teamColor = LocalPlayer.Team and LocalPlayer.Team.TeamColor
    local folder = workspace:FindFirstChild("Map")
        and workspace.Map.Functional
        and workspace.Map.Functional.Invisible
        and workspace.Map.Functional.Invisible:FindFirstChild("SpawnkillBarriers")

    if folder and teamColor then
        for _, barrierFolder in ipairs(folder:GetChildren()) do
            for _, part in ipairs(barrierFolder:GetChildren()) do
                if part:IsA("BasePart") and part:FindFirstChild("TeamID") then
                    local tid = part.TeamID
                    if tid and tid:IsA("BrickColorValue") and tid.Value == teamColor then
                        tid.Value = BrickColor.new("Really black")
                        part.Position = Vector3.new(9999, 9999, 9999)
                        part.CanTouch = false
                        part.CanCollide = false
                        part.Transparency = 1
                    end
                end
            end
        end
    end
end

local function nudgeCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 2 + Vector3.new(0, 2, 0)
    end
end

local function createStaffAlert(name)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StaffAlert"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local alertFrame = Instance.new("Frame")
    alertFrame.Size = UDim2.new(0, 320, 0, 60)
    alertFrame.Position = UDim2.new(0.5, -160, 0.05, 0)
    alertFrame.AnchorPoint = Vector2.new(0.5, 0)
    alertFrame.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    alertFrame.BorderSizePixel = 0
    alertFrame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 22
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Text = "🚨 STAFF DETECTED: " .. name
    textLabel.Parent = alertFrame

    task.delay(5, function()
        screenGui:Destroy()
    end)
end

local function checkStaff(player)
    if table.find(knownStaffIds, player.UserId) then
        createStaffAlert(player.Name)
    end
end

local function initialize()
    disableGuardBarriers()
    neutralizeSpawnkillBarriers()
    monitorHandcuffs()
    nudgeCharacter()

    for _, player in ipairs(Players:GetPlayers()) do
        checkStaff(player)
    end

    Players.PlayerAdded:Connect(checkStaff)
end

local success, err = pcall(initialize)
if not success then
    warn(err)
end

return nil
