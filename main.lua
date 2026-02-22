local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Camera = Workspace.CurrentCamera

local Player = Players.LocalPlayer

local autofarm = false
local currentTarget = nil
local stabAttemptsOnCurrent = 0
local GemGoal = 0
local LevelGoal = 0
local SkipPlayersList = {}
local ActivateSkip = false

local LockNearest = false
local AutoShoot = false

local YourTeam = "None"
local LockOpposite = false
local ESP_Red = false
local ESP_Blue = false

local ESP_Murderer = false
local ESP_Sheriff = false
local ESP_All = false

task.spawn(function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DiscordPrompt"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.Parent = game.CoreGui
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,300,0,140)
    frame.Position = UDim2.new(0.5,-150,0,40)
    frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(200,200,200)
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,40)
    title.BackgroundTransparency = 1
    title.Text = "Join Discord for Key"
    title.TextColor3 = Color3.new(0,0,0)
    title.Font = Enum.Font.Cartoon
    title.TextScaled = true
    local copy = Instance.new("TextButton", frame)
    copy.Size = UDim2.new(0.8,0,0,40)
    copy.Position = UDim2.new(0.1,0,0.45,0)
    copy.BackgroundColor3 = Color3.fromRGB(240,240,240)
    copy.Text = "Copy Invite"
    copy.TextColor3 = Color3.new(0,0,0)
    copy.Font = Enum.Font.Cartoon
    copy.TextScaled = true
    copy.MouseButton1Click:Connect(function() setclipboard("discord.gg/9uRWRnmNyF") end)
    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0.5,0,0,28)
    close.Position = UDim2.new(0.25,0,0.8,0)
    close.BackgroundColor3 = Color3.fromRGB(230,230,230)
    close.Text = "Close"
    close.TextColor3 = Color3.new(0,0,0)
    close.Font = Enum.Font.Cartoon
    close.TextScaled = true
    close.MouseButton1Click:Connect(function() gui:Destroy() end)
end)

local Window = Rayfield:CreateWindow({
   Name = "KattHub | Knife Ability Test",
   LoadingTitle = "KattHub",
   LoadingSubtitle = "Welcome",
   Theme = "Default",
   ToggleUIKeybind = "K",
   ConfigurationSaving = { Enabled = true, FileName = "KattHubKnife" },
   Discord = { Enabled = true, Invite = "9uRWRnmNyF", RememberJoins = true },
   KeySystem = true,
   KeySettings = {
      Title = "KattHub Key System",
      Subtitle = "Key in Discord",
      Note = "Join Discord Server for Key",
      FileName = "KatthubSystem",
      SaveKey = false,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/AkahKMG9"}
   }
})

local MainTab = Window:CreateTab("FFA Mode", 4483362458)
MainTab:CreateSection("Farm")

local function GetStat(statName)
    local ls = Player:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild(statName) then return tonumber(ls[statName].Value) or 0 end
    local data = Player:FindFirstChild("Data")
    if data and data:FindFirstChild(statName) then return tonumber(data[statName].Value) or 0 end
    return 0
end

local function getNearestPlayer()
    local closest = nil
    local shortest = math.huge
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local shouldSkip = false
            if ActivateSkip and #SkipPlayersList > 0 then
                for _, name in ipairs(SkipPlayersList) do
                    if p.Name:lower() == name:lower() then shouldSkip = true break end
                end
            end
            if not shouldSkip then
                local dist = (Player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortest and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    shortest = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

MainTab:CreateInput({
   Name = "Gem Goal",
   PlaceholderText = "0",
   Callback = function(Text) GemGoal = tonumber(Text) or 0 end,
})

MainTab:CreateInput({
   Name = "Level Goal",
   PlaceholderText = "0",
   Callback = function(Text) LevelGoal = tonumber(Text) or 0 end,
})

local AutofarmToggle = MainTab:CreateToggle({
    Name = "Autofarm (Press L to turn off)",
    CurrentValue = false,
    Callback = function(v)
        autofarm = v
        if not v then
            currentTarget = nil
            if Player.Character then Camera.CameraSubject = Player.Character.Humanoid end
        end
    end
})

MainTab:CreateInput({
   Name = "Skip Players",
   PlaceholderText = "Name1, Name2",
   Callback = function(Text)
      if Text == "0" or Text == "" then SkipPlayersList = {} else SkipPlayersList = string.split(Text:gsub("%s+", ""), ",") end
   end,
})

MainTab:CreateToggle({
    Name = "Activate Skip",
    CurrentValue = false,
    Callback = function(v) ActivateSkip = v end
})

MainTab:CreateSection("Aim")

local AimToggle = MainTab:CreateToggle({
    Name = "Lock Onto Nearest (Press P to turn off)",
    CurrentValue = false,
    Callback = function(v) 
        LockNearest = v 
        if v then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        else UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
    end
})

local AutoShootToggle = MainTab:CreateToggle({
    Name = "Auto-Shoot (Gun) (Press V to turn off)",
    CurrentValue = false,
    Callback = function(v) AutoShoot = v end
})

local MurderTab = Window:CreateTab("Murder Mode", 4483362458)
MurderTab:CreateSection("Visuals")

MurderTab:CreateToggle({ Name = "ESP Murderer", CurrentValue = false, Callback = function(v) ESP_Murderer = v end })
MurderTab:CreateToggle({ Name = "ESP Sheriff", CurrentValue = false, Callback = function(v) ESP_Sheriff = v end })

MurderTab:CreateSection("Sheriff")
MurderTab:CreateButton({
    Name = "Auto Win (Kill Murderer)",
    Callback = function()
        local murderer = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local tools = p.Backpack:GetChildren()
                if p.Character:FindFirstChildOfClass("Tool") then table.insert(tools, p.Character:FindFirstChildOfClass("Tool")) end
                for _, t in ipairs(tools) do
                    if t.Name:lower():find("knife") or t.Name:lower():find("blade") then
                        murderer = p
                        break
                    end
                end
            end
            if murderer then break end
        end

        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            local mHRP = murderer.Character.HumanoidRootPart
            local mHum = murderer.Character.Humanoid
            Player.Character.HumanoidRootPart.CFrame = mHRP.CFrame * CFrame.new(0, 0, 8)
            task.spawn(function()
                while murderer and murderer.Character and mHum.Health > 0 do
                    RunService.RenderStepped:Wait()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, mHRP.Position)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
                Rayfield:Notify({Title = "Murderer Eliminated", Content = "Auto Win completed.", Duration = 3})
            end)
        else
            Rayfield:Notify({Title = "Error", Content = "No Murderer found.", Duration = 3})
        end
    end
})

MurderTab:CreateSection("Murderer")
MurderTab:CreateButton({
    Name = "Auto Win (Kill All)",
    Callback = function()
        local playersToKill = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                table.insert(playersToKill, p)
            end
        end

        task.spawn(function()
            for _, target in ipairs(playersToKill) do
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local tHRP = target.Character.HumanoidRootPart
                    local tHum = target.Character.Humanoid
                    local stabCount = 0
                    
                    while target and target.Character and tHum.Health > 0 and stabCount < 5 do
                        RunService.Heartbeat:Wait()
                        local knife = Player.Character:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
                        if knife and knife.Parent ~= Player.Character then Player.Character.Humanoid:EquipTool(knife) end
                        
                        Player.Character.HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1)
                        Camera.CameraSubject = tHum
                        
                        if knife then
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
                            task.wait(0.05)
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
                            stabCount = stabCount + 1
                        end
                        
                        if target.Character:FindFirstChildOfClass("ForceField") then break end
                        task.wait(0.1)
                    end
                end
            end
            Camera.CameraSubject = Player.Character.Humanoid
            Rayfield:Notify({Title = "Success", Content = "Finished Kill All attempts.", Duration = 3})
        end)
    end
})

local TeamTab = Window:CreateTab("Team Duels Mode", 4483362458)

TeamTab:CreateSection("Visuals")
TeamTab:CreateToggle({
    Name = "ESP Red Team",
    CurrentValue = false,
    Callback = function(v) ESP_Red = v end
})
TeamTab:CreateToggle({
    Name = "ESP Blue Team",
    CurrentValue = false,
    Callback = function(v) ESP_Blue = v end
})

TeamTab:CreateSection("Main")
TeamTab:CreateDropdown({
    Name = "Your Team",
    Options = {"Red", "Blue"},
    CurrentOption = {"Pick a Team"},
    MultipleOptions = false,
    Callback = function(Option) YourTeam = Option[1] end,
})

local TeamLockToggle = TeamTab:CreateToggle({
    Name = "Lock Onto Opposite (Press U to turn off)",
    CurrentValue = false,
    Callback = function(v) 
        LockOpposite = v 
        if v then UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        else UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
    end
})

local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateSection("Visuals")
MiscTab:CreateToggle({
    Name = "ESP All",
    CurrentValue = false,
    Callback = function(v) ESP_All = v end
})

MiscTab:CreateSection("Misc")
MiscTab:CreateButton({
    Name = "ServerHop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local function GetServer()
            local Servers = Http:JSONDecode(game:HttpGet(Api))
            for _, Server in pairs(Servers.data) do
                if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
                    return Server.id
                end
            end
            return nil
        end
        local NextServer = GetServer()
        if NextServer then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, NextServer, Player)
        else
            Rayfield:Notify({Title = "Error", Content = "Could not find a new server.", Duration = 3})
        end
    end
})

local function CreateNameTag(parent, text, color)
    local bg = parent:FindFirstChild("KattName")
    if not bg then
        bg = Instance.new("BillboardGui", parent)
        bg.Name = "KattName"
        bg.Adornee = parent:FindFirstChild("Head")
        bg.Size = UDim2.new(0, 150, 0, 50)
        bg.StudsOffset = Vector3.new(0, 3, 0)
        bg.AlwaysOnTop = true
        local tl = Instance.new("TextLabel", bg)
        tl.Name = "Label"
        tl.BackgroundTransparency = 1; tl.Size = UDim2.new(1, 0, 1, 0); tl.TextStrokeTransparency = 0; tl.Font = Enum.Font.Cartoon; tl.TextScaled = true
    end
    bg.Label.Text = text
    bg.Label.TextColor3 = color
end

local function UpdateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local hasK, hasG = false, false
            local t = p.Backpack:GetChildren()
            if p.Character:FindFirstChildOfClass("Tool") then table.insert(t, p.Character:FindFirstChildOfClass("Tool")) end
            for _, v in ipairs(t) do
                local n = v.Name:lower()
                if n:find("knife") or n:find("blade") then hasK = true
                elseif n:find("gun") or n:find("revolver") then hasG = true end
            end
            
            local pTeam = "None"
            if p:FindFirstChild("Team") then pTeam = p.Team.Name
            elseif p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChildOfClass("SelectionBox") then
                local box = p.Character.Head:FindFirstChildOfClass("SelectionBox")
                if box.Color3 == Color3.fromRGB(255, 0, 0) then pTeam = "Red"
                elseif box.Color3 == Color3.fromRGB(0, 0, 255) then pTeam = "Blue" end
            end

            local shouldShow = false
            local espColor = Color3.new(1,1,1)
            local tagText = p.Name

            if ESP_All then
                shouldShow = true; espColor = Color3.fromRGB(0, 255, 0); tagText = p.Name
            elseif ESP_Red and pTeam == "Red" then
                shouldShow = true; espColor = Color3.fromRGB(255, 0, 0); tagText = p.Name .. " [RED]"
            elseif ESP_Blue and pTeam == "Blue" then
                shouldShow = true; espColor = Color3.fromRGB(0, 0, 255); tagText = p.Name .. " [BLUE]"
            elseif ESP_Sheriff and hasG then
                shouldShow = true; espColor = Color3.fromRGB(0, 120, 255); tagText = p.Name .. " [SHERIFF]"
            elseif ESP_Murderer and hasK then
                shouldShow = true; espColor = Color3.fromRGB(255, 0, 0); tagText = p.Name .. " [MURDERER]"
            end

            local h = p.Character:FindFirstChild("KattESP")
            if shouldShow then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "KattESP"
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                h.FillColor = espColor
                CreateNameTag(p.Character, tagText, espColor)
            else
                if h then h:Destroy() end
                if p.Character:FindFirstChild("KattName") then p.Character.KattName:Destroy() end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.L and autofarm then 
        autofarm = false
        AutofarmToggle:Set(false)
    elseif i.KeyCode == Enum.KeyCode.P and LockNearest then 
        LockNearest = false
        AimToggle:Set(false)
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    elseif i.KeyCode == Enum.KeyCode.V and AutoShoot then 
        AutoShoot = false
        AutoShootToggle:Set(false)
    elseif i.KeyCode == Enum.KeyCode.U and LockOpposite then 
        LockOpposite = false
        TeamLockToggle:Set(false)
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default 
    end
end)

task.spawn(function() while task.wait(0.5) do UpdateESP() end end)

RunService.RenderStepped:Connect(function()
    local target = nil
    
    if LockNearest or AutoShoot then
        target = getNearestPlayer()
    elseif LockOpposite and YourTeam ~= "Pick a Team" then
        local shortest = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pTeam = "None"
                if p.Character.Head:FindFirstChildOfClass("SelectionBox") then
                    local color = p.Character.Head:FindFirstChildOfClass("SelectionBox").Color3
                    if color == Color3.fromRGB(255, 0, 0) then pTeam = "Red"
                    elseif color == Color3.fromRGB(0, 0, 255) then pTeam = "Blue" end
                end
                
                if pTeam ~= YourTeam and pTeam ~= "None" then
                    local dist = (Player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < shortest and p.Character.Humanoid.Health > 0 then 
                        shortest = dist
                        target = p 
                    end
                end
            end
        end
    end

    if target and target.Character then
        local p = target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Torso")
        if p and (LockNearest or LockOpposite) then 
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, p.Position) 
        end
        if p and AutoShoot then 
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not autofarm then return end
    local curGems, curLevel = GetStat("Gems"), GetStat("Level")
    if (GemGoal > 0 and curGems >= GemGoal) or (LevelGoal > 0 and curLevel >= LevelGoal) then
        autofarm = false; AutofarmToggle:Set(false); Rayfield:Notify({Title = "Goal Reached", Content = "Stopped.", Duration = 5}); return
    end
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local tool = char:FindFirstChildOfClass("Tool") or Player.Backpack:FindFirstChildOfClass("Tool")
    if tool and tool.Parent ~= char then char.Humanoid:EquipTool(tool) end
    if not tool then return end
    if not currentTarget or not currentTarget.Character or currentTarget.Character.Humanoid.Health <= 0 or stabAttemptsOnCurrent >= 5 then
        currentTarget = getNearestPlayer(); stabAttemptsOnCurrent = 0
        if not currentTarget then return end
    end
    local tHRP = currentTarget.Character:FindFirstChild("HumanoidRootPart")
    if tHRP then
        char.HumanoidRootPart.CFrame = tHRP.CFrame * CFrame.new(0, -4, 0) * CFrame.Angles(0, math.rad(math.random(-180,180)), 0)
        if not LockNearest then Camera.CameraSubject = currentTarget.Character.Humanoid end
        tool:Activate()
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
        stabAttemptsOnCurrent = stabAttemptsOnCurrent + 1
    end
end)
