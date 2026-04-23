local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer

-- Buscar la interfaz principal creada por el Hub para inyectar los tags ahí
local targetParent = pcall(function() return game:GetService("CoreGui").Name end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
local ScreenGui = targetParent:WaitForChild("BloxyHub_UI", 10)

local friendsCache = {}
local function isFriend(player)
    if player == LocalPlayer then return false end
    if friendsCache[player.UserId] ~= nil then return friendsCache[player.UserId] end
    local success, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
    if success then friendsCache[player.UserId] = result return result end
    return false
end

local tagConnections = {}

_G.cleanTags = function(animated)
    for _, conn in pairs(tagConnections) do conn:Disconnect() end
    tagConnections = {}
    if not ScreenGui then return end
    for _, child in ipairs(ScreenGui:GetChildren()) do
        if child.Name == "BloxyTag_Dynamic" then 
            if child.Adornee and child.Adornee.Parent then
                local hum = child.Adornee.Parent:FindFirstChild("Humanoid")
                if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
            end
            if animated then
                local btn = child:FindFirstChildOfClass("TextButton")
                if btn then
                    TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
                end
                task.delay(0.35, function() child:Destroy() end)
            else
                child:Destroy()
            end
        end
    end
end

local function PlayTeleportSound()
    pcall(function()
        if not ScreenGui then return end
        local sound = Instance.new("Sound", ScreenGui)
        sound.SoundId = "rbxassetid://7322277676" 
        sound.Volume = 3
        sound:Play()
        Debris:AddItem(sound, 3) 
    end)
end

_G.applyTagToPlayer = function(player)
    if not _G.TagsEnabled then return end
    if player == LocalPlayer then return end 

    task.spawn(function()
        local isF = isFriend(player)
        if not isF then return end 
        
        local function apply(character)
            if not _G.TagsEnabled then return end
            local head = character:WaitForChild("Head", 5)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if not head then return end
            
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
            
            if not ScreenGui then return end
            for _, child in ipairs(ScreenGui:GetChildren()) do
                if child.Name == "BloxyTag_Dynamic" and child.Adornee == head then child:Destroy() end
            end

            local Billboard = Instance.new("BillboardGui", ScreenGui)
            Billboard.Name = "BloxyTag_Dynamic"
            Billboard.Adornee = head
            Billboard.Size = UDim2.new(0, 300, 0, 40)
            Billboard.StudsOffset = Vector3.new(0, 1.5, 0)
            Billboard.AlwaysOnTop = true
            Billboard.MaxDistance = math.huge 
            Billboard.Active = true
            
            local TagButton = Instance.new("TextButton", Billboard)
            TagButton.Text = ""
            TagButton.AnchorPoint = Vector2.new(0.5, 0.5)
            TagButton.Position = UDim2.new(0.5, 0, 0.5, 0)
            TagButton.Size = UDim2.new(0, 40, 0, 40) 
            TagButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
            TagButton.BackgroundTransparency = 0.65 
            TagButton.BorderSizePixel = 0
            TagButton.ClipsDescendants = true 
            TagButton.Active = true
            TagButton.AutoButtonColor = false

            Instance.new("UICorner", TagButton).CornerRadius = UDim.new(0, 10)

            local InnerGradient = Instance.new("UIGradient", TagButton)
            InnerGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
            })
            InnerGradient.Rotation = 45 

            local strokeCol = Color3.fromRGB(255, 255, 255) 
            local logoBgCol = Color3.fromRGB(15, 15, 15) 
            local logoBorderCol = Color3.fromRGB(0, 0, 0) 
            local thickness = 1.2 

            local TagStroke = Instance.new("UIStroke", TagButton)
            TagStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
            TagStroke.Thickness = thickness
            TagStroke.Color = strokeCol 
            TagStroke.Transparency = 0.5 

            local OrbContainer = Instance.new("Frame", TagButton)
            OrbContainer.Size = UDim2.new(1, 0, 1, 0)
            OrbContainer.BackgroundTransparency = 1
            OrbContainer.ZIndex = 1

            local LogoContainer = Instance.new("Frame", TagButton)
            LogoContainer.Name = "CodeLogo"
            LogoContainer.Size = UDim2.new(1, 0, 1, 0) 
            LogoContainer.Position = UDim2.new(0, 0, 0, 0)
            LogoContainer.BackgroundColor3 = logoBgCol
            LogoContainer.BackgroundTransparency = 0.15 
            LogoContainer.ZIndex = 3
            
            local LogoCorner = Instance.new("UICorner", LogoContainer)
            LogoCorner.CornerRadius = UDim.new(0.25, 0)
            
            local LogoStroke = Instance.new("UIStroke", LogoContainer)
            LogoStroke.Color = logoBorderCol
            LogoStroke.Thickness = thickness
            LogoStroke.Transparency = 1 
    
            local FriendIcon = Instance.new("ImageLabel", LogoContainer)
            FriendIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
            FriendIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            FriendIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            FriendIcon.BackgroundTransparency = 1
            FriendIcon.Image = "rbxthumb://type=Asset&id=76848695027869&w=150&h=150"
            FriendIcon.ZIndex = 4

            local ContentContainer = Instance.new("Frame", TagButton)
            ContentContainer.Name = "Content"
            ContentContainer.Size = UDim2.new(1, -40, 1, 0)
            ContentContainer.Position = UDim2.new(0, 42, 0, 0)
            ContentContainer.BackgroundTransparency = 1
            ContentContainer.ZIndex = 2

            local ContentLayout = Instance.new("UIListLayout", ContentContainer)
            ContentLayout.FillDirection = Enum.FillDirection.Horizontal
            ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left 
            ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder 
            ContentLayout.Padding = UDim.new(0, 6) 

            local AliasLabel = Instance.new("TextLabel", ContentContainer)
            AliasLabel.BackgroundTransparency = 1
            AliasLabel.Size = UDim2.new(0, 0, 1, 0)
            AliasLabel.Text = ""
            AliasLabel.TextColor3 = Color3.fromRGB(15, 15, 15) 
            AliasLabel.Font = Enum.Font.GothamBlack
            AliasLabel.TextSize = 14 
            AliasLabel.TextXAlignment = Enum.TextXAlignment.Left
            AliasLabel.LayoutOrder = 2 
            AliasLabel.ZIndex = 3

            TagButton.MouseButton1Click:Connect(function()
                if player == LocalPlayer then return end
                pcall(function()
                    local lpChar = LocalPlayer.Character
                    local targetChar = player.Character
                    if lpChar and lpChar:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        PlayTeleportSound() 
                        local targetHRP = targetChar.HumanoidRootPart
                        local newCFrame = targetHRP.CFrame * CFrame.new(4, 0, 0) 
                        lpChar.HumanoidRootPart.CFrame = newCFrame
                    end
                end)
            end)

            local isExpanded = false
            local orbTimer = 0
            local displayAliasText = player.DisplayName
            
            local conn = RunService.RenderStepped:Connect(function(dt)
                if not Billboard or not Billboard.Parent then return end

                orbTimer = orbTimer + dt
                if orbTimer >= 0.15 then
                    orbTimer = 0
                    pcall(function()
                        local orb = Instance.new("Frame")
                        local size = math.random(2, 5)
                        orb.Size = UDim2.new(0, size, 0, size)
                        orb.Position = UDim2.new(math.random(10, 90)/100, 0, 1.2, 0)
                        orb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        orb.BackgroundTransparency = 0.4
                        orb.BorderSizePixel = 0
                        orb.ZIndex = 1
                        Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
                        orb.Parent = OrbContainer

                        local tween = TweenService:Create(orb, TweenInfo.new(math.random(15, 30)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                            Position = UDim2.new(orb.Position.X.Scale, 0, -0.2, 0),
                            BackgroundTransparency = 1
                        })
                        tween:Play()
                        tween.Completed:Connect(function() orb:Destroy() end)
                    end)
                end

                local distance = 9999
                local lpChar = LocalPlayer.Character
                if lpChar and lpChar:FindFirstChild("Head") then
                    distance = (head.Position - lpChar.Head.Position).Magnitude
                end
                
                if distance < 55 then
                    if not isExpanded then
                        isExpanded = true
                        AliasLabel.Text = displayAliasText .. "|"
                        local textWidth = AliasLabel.TextBounds.X
                        AliasLabel.Text = "" 
                        AliasLabel.Size = UDim2.new(0, textWidth + 4, 1, 0)
                        local totalFitWidth = 8 + 26 + 8 + textWidth + 12
                        TweenService:Create(TagButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, totalFitWidth, 0, 40)}):Play()
                        TweenService:Create(LogoContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 7, 0, 7)}):Play()
                        TweenService:Create(LogoCorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(1, 0)}):Play()
                    end
                else
                    if isExpanded then
                        isExpanded = false
                        TweenService:Create(TagButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 40, 0, 40)}):Play()
                        TweenService:Create(LogoContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
                        TweenService:Create(LogoCorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(0.25, 0)}):Play()
                        AliasLabel.Text = ""
                    end
                end
            end)
            table.insert(tagConnections, conn)

            task.spawn(function()
                while Billboard and Billboard.Parent do
                    if not _G.TagsEnabled then break end
                    if isExpanded then
                        for i = 1, #displayAliasText do
                            if not Billboard or not Billboard.Parent or not isExpanded then break end
                            AliasLabel.Text = string.sub(displayAliasText, 1, i) .. "|"
                            task.wait(0.04)
                        end
                        for b = 1, 5 do
                            if not Billboard or not Billboard.Parent or not isExpanded then break end
                            AliasLabel.Text = displayAliasText .. "|"
                            task.wait(0.4)
                            if not isExpanded then break end
                            AliasLabel.Text = displayAliasText
                            task.wait(0.4)
                        end
                        for i = #displayAliasText, 0, -1 do
                            if not Billboard or not Billboard.Parent or not isExpanded then break end
                            AliasLabel.Text = string.sub(displayAliasText, 1, i) .. "|"
                            task.wait(0.06) 
                        end
                        if isExpanded then AliasLabel.Text = "|" end
                        task.wait(0.5)
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end

        if player.Character then apply(player.Character) end
        player.CharacterAdded:Connect(apply)
    end)
end

Players.PlayerAdded:Connect(function(player)
    if _G.TagsEnabled then _G.applyTagToPlayer(player) end
end)

task.spawn(function()
    while task.wait(2.5) do
        if _G.TagsEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end 
                
                local isF = false
                local wasFriend = friendsCache[player.UserId]
                local isNowFriend = false
                pcall(function() isNowFriend = LocalPlayer:IsFriendsWith(player.UserId) end)
                if isNowFriend and not wasFriend then
                    friendsCache[player.UserId] = true
                    isF = true
                    task.spawn(function()
                        task.wait(1)
                        _G.applyTagToPlayer(player)
                    end)
                else
                    friendsCache[player.UserId] = isNowFriend
                    isF = isNowFriend
                end
                
                if isF then 
                    if player.Character and player.Character:FindFirstChild("Head") then
                        local hasTag = false
                        if ScreenGui then
                            for _, child in ipairs(ScreenGui:GetChildren()) do
                                if child.Name == "BloxyTag_Dynamic" and child.Adornee == player.Character.Head then hasTag = true end
                            end
                        end
                        if not hasTag then _G.applyTagToPlayer(player) end
                    end
                else
                    if player.Character and player.Character:FindFirstChild("Head") then
                        if ScreenGui then
                            for _, child in ipairs(ScreenGui:GetChildren()) do
                                if child.Name == "BloxyTag_Dynamic" and child.Adornee == player.Character.Head then
                                    local hum = player.Character:FindFirstChild("Humanoid")
                                    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
                                    child:Destroy()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
