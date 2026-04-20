-- ==========================================
-- BLOXY HUB - ESP PREMIUM (COMPATIBLE CON OFUSCADORES)
-- ==========================================

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local guiName = "BloxyHub_UI"
local blurName = "BloxyHub_Blur"
local toggleGuiName = "BloxyHub_Toggle"
local configFileName = "BloxyHub_Keybind.json"

-- ==========================================
-- DETECCIÓN DE DISPOSITIVO (PC vs MÓVIL)
-- ==========================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ==========================================
-- SISTEMA DE GUARDADO (CONFIG Y EMOJIS)
-- ==========================================
local currentKeybind = Enum.KeyCode.LeftAlt
local is24HourFormat = false 
local customVerifiedSymbol = "✅"
local customFriendSymbol = "🤝"

local function loadConfig()
    if isfile and readfile and isfile(configFileName) then
        pcall(function()
            local result = HttpService:JSONDecode(readfile(configFileName))
            if result.Keybind and Enum.KeyCode[result.Keybind] then
                currentKeybind = Enum.KeyCode[result.Keybind]
            end
            if result.Format24H ~= nil then is24HourFormat = result.Format24H end
            if result.VerifiedSymbol then customVerifiedSymbol = result.VerifiedSymbol end
            if result.FriendSymbol then customFriendSymbol = result.FriendSymbol end
        end)
    end
end

local function saveConfig()
    if writefile then
        pcall(function()
            local data = { 
                Keybind = currentKeybind.Name, 
                Format24H = is24HourFormat,
                VerifiedSymbol = customVerifiedSymbol,
                FriendSymbol = customFriendSymbol
            }
            writefile(configFileName, HttpService:JSONEncode(data))
        end)
    end
end

loadConfig()

-- ==========================================
-- UTILIDAD: LIMITAR CARACTERES UTF-8
-- ==========================================
local function truncateToChars(str, limit)
    local success, result = pcall(function()
        local res = ""
        local count = 0
        for _, c in utf8.codes(str) do
            count = count + 1
            if count > limit then break end
            res = res .. utf8.char(c)
        end
        return res
    end)
    if success then return result else return string.sub(str, 1, limit * 4) end
end

-- ==========================================
-- LIMPIEZA PREVIA ABSOLUTA
-- ==========================================
local targetParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui", 5)
if targetParent and targetParent:FindFirstChild(guiName) then targetParent[guiName]:Destroy() end
if targetParent and targetParent:FindFirstChild(toggleGuiName) then targetParent[toggleGuiName]:Destroy() end
if Lighting:FindFirstChild(blurName) then Lighting[blurName]:Destroy() end

_G.BloxyHubClosed = false 
_G.TagsEnabled = false 
local scriptsExecuted = false 
local isUiVisible = true
local inSettings = false

-- ==========================================
-- CACHÉ DE AMIGOS Y USUARIOS SCRIPT
-- ==========================================
local friendsCache = {}
local function isFriend(player)
    if player == LocalPlayer then return false end
    if friendsCache[player.UserId] ~= nil then return friendsCache[player.UserId] end
    local success, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
    if success then friendsCache[player.UserId] = result return result end
    return false
end

local scriptUsersCache = {}
local function markAsScriptUser()
    local function addMarker(char)
        if not char then return end
        if char:FindFirstChild("BloxyHub_User") then return end
        local marker = Instance.new("StringValue")
        marker.Name = "BloxyHub_User"
        marker.Value = "true"
        marker.Parent = char
    end
    if LocalPlayer.Character then addMarker(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(addMarker)
end
markAsScriptUser()

local function isScriptUser(player)
    if player == LocalPlayer then return true end
    if scriptUsersCache[player.UserId] ~= nil then return scriptUsersCache[player.UserId] end
    local success, result = pcall(function()
        local char = player.Character
        if char then return char:FindFirstChild("BloxyHub_User") ~= nil end
        return false
    end)
    if success then scriptUsersCache[player.UserId] = result return result end
    return false
end

-- ==========================================
-- CREAR INTERFAZ BASE
-- ==========================================
local Blur = Instance.new("BlurEffect")
Blur.Name = blurName
Blur.Size = 0
Blur.Parent = Lighting

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = toggleGuiName
ToggleGui.Parent = targetParent
ToggleGui.ResetOnSpawn = false

local FloatingToggleBtn = Instance.new("TextButton", ToggleGui)
FloatingToggleBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingToggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
FloatingToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatingToggleBtn.BackgroundTransparency = 0.2
FloatingToggleBtn.Text = "B"
FloatingToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingToggleBtn.Font = Enum.Font.GothamBlack
FloatingToggleBtn.TextSize = 22
FloatingToggleBtn.Visible = isMobile 
FloatingToggleBtn.Active = true -- Activo para poder moverlo
Instance.new("UICorner", FloatingToggleBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingToggleBtn)
FloatStroke.Color = Color3.fromRGB(255, 255, 255)
FloatStroke.Thickness = 1.5

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = targetParent
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local DarkOverlay = Instance.new("Frame", ScreenGui)
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkOverlay.BackgroundTransparency = 1
DarkOverlay.ZIndex = 1

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Size = isMobile and UDim2.new(0, 380, 0, 280) or UDim2.new(0, 450, 0, 340)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BackgroundTransparency = 1 
MainFrame.ZIndex = 2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 1 

local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
})
UIGradient.Rotation = 45 

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -120, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0) 
Title.BackgroundTransparency = 1
Title.Text = "BLOXY HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

local SettingsBtn = Instance.new("ImageButton", MainFrame)
SettingsBtn.Size = UDim2.new(0, 24, 0, 24)
SettingsBtn.Position = UDim2.new(1, -65, 0, 8) 
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Image = "rbxassetid://6031280882" 
SettingsBtn.ImageTransparency = 1

local DiscordBtn = Instance.new("ImageButton", MainFrame)
DiscordBtn.Size = UDim2.new(0, 28, 0, 28)
DiscordBtn.Position = UDim2.new(1, -100, 0, 6) 
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.Image = "rbxassetid://13028574346" 
DiscordBtn.ImageTransparency = 1
DiscordBtn.BackgroundTransparency = 1
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 6)

local TopSeparator = Instance.new("Frame", MainFrame)
TopSeparator.Size = UDim2.new(1, 0, 0, 1)
TopSeparator.Position = UDim2.new(0, 0, 0, 40) 
TopSeparator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopSeparator.BackgroundTransparency = 1

local BottomSeparator = Instance.new("Frame", MainFrame)
BottomSeparator.Size = UDim2.new(1, 0, 0, 1)
BottomSeparator.Position = UDim2.new(0, 0, 1, -40) 
BottomSeparator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BottomSeparator.BackgroundTransparency = 1

local ProfilePic = Instance.new("ImageLabel", MainFrame)
ProfilePic.Size = UDim2.new(0, 26, 0, 26)
ProfilePic.Position = UDim2.new(0, 12, 1, -33)
ProfilePic.BackgroundTransparency = 1
ProfilePic.ImageTransparency = 1
ProfilePic.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", ProfilePic).CornerRadius = UDim.new(1, 0)

local UsernameLabel = Instance.new("TextLabel", MainFrame)
UsernameLabel.Size = UDim2.new(0.3, 0, 0, 40) 
UsernameLabel.Position = UDim2.new(0, 45, 1, -40)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.DisplayName
UsernameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
UsernameLabel.TextTransparency = 1
UsernameLabel.Font = Enum.Font.GothamSemibold
UsernameLabel.TextSize = 13
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel", MainFrame)
StatsLabel.Size = UDim2.new(0.4, 0, 0, 40) 
StatsLabel.Position = UDim2.new(0.3, 0, 1, -40)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180) 
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12

local TimeLabel = Instance.new("TextLabel", MainFrame)
TimeLabel.Size = UDim2.new(0.3, -15, 0, 40)
TimeLabel.Position = UDim2.new(0.7, 0, 1, -40)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
TimeLabel.TextTransparency = 1
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 13
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right

local function updateTimeDisplay()
    local formatStr = is24HourFormat and "%H:%M" or "%I:%M %p"
    if TimeLabel then TimeLabel.Text = os.date(formatStr) end
end
task.spawn(function() while task.wait(1) do updateTimeDisplay() end end)

local lastTime, frameCount = tick(), 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTime >= 0.1 then 
        local fps = math.floor(frameCount / (currentTime - lastTime))
        frameCount, lastTime = 0, currentTime
        local ping = 0
        pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
        if StatsLabel then StatsLabel.Text = string.format("%d FPS | %d ms", fps, ping) end
    end
end)

-- ==========================================
-- SISTEMA DE NOTIFICACIONES TOAST 
-- ==========================================
local function ShowToastNotification(titleText, descText, btn1Text, btn2Text, callback)
    local DialogBox = Instance.new("Frame", ScreenGui)
    DialogBox.Size = UDim2.new(0, 320, 0, 140)
    DialogBox.Position = UDim2.new(1, 350, 1, -20)
    DialogBox.AnchorPoint = Vector2.new(1, 1)
    DialogBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DialogBox.BackgroundTransparency = 0.75 
    DialogBox.ZIndex = 20
    Instance.new("UICorner", DialogBox).CornerRadius = UDim.new(0, 10)
    
    local dGradient = Instance.new("UIGradient", DialogBox)
    dGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
    })
    dGradient.Rotation = 45

    local dStroke = Instance.new("UIStroke", DialogBox)
    dStroke.Thickness = 1.2
    dStroke.Color = Color3.fromRGB(255, 255, 255)
    dStroke.Transparency = 0.4 

    local dTitle = Instance.new("TextLabel", DialogBox)
    dTitle.Size = UDim2.new(1, 0, 0, 30)
    dTitle.BackgroundTransparency = 1
    dTitle.Text = titleText
    dTitle.TextColor3 = Color3.fromRGB(30, 30, 30)
    dTitle.Font = Enum.Font.GothamBlack
    dTitle.TextSize = 16
    dTitle.ZIndex = 21

    local dDesc = Instance.new("TextLabel", DialogBox)
    dDesc.Size = UDim2.new(1, -40, 0, 50)
    dDesc.Position = UDim2.new(0, 20, 0, 35)
    dDesc.BackgroundTransparency = 1
    dDesc.Text = descText
    dDesc.TextColor3 = Color3.fromRGB(40, 40, 40)
    dDesc.TextWrapped = true
    dDesc.Font = Enum.Font.GothamSemibold
    dDesc.TextSize = 13
    dDesc.ZIndex = 21

    local function createDialogBtn(text, posX, bgCol)
        local btn = Instance.new("TextButton", DialogBox)
        btn.Size = UDim2.new(0, 120, 0, 30)
        btn.Position = posX
        btn.BackgroundColor3 = bgCol
        btn.BackgroundTransparency = 0.1
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.ZIndex = 21
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    local Btn1 = createDialogBtn(btn1Text, UDim2.new(0, 30, 1, -45), Color3.fromRGB(100, 120, 255)) 
    local Btn2 = createDialogBtn(btn2Text, UDim2.new(1, -150, 1, -45), Color3.fromRGB(220, 80, 80))

    TweenService:Create(DialogBox, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, -20)}):Play()

    local function closeDialog(result)
        TweenService:Create(DialogBox, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 350, 1, -20)}):Play()
        task.wait(0.4)
        DialogBox:Destroy()
        if callback then callback(result) end
    end

    Btn1.MouseButton1Click:Connect(function() closeDialog(true) end)
    Btn2.MouseButton1Click:Connect(function() closeDialog(false) end)
end

-- ==========================================
-- ETIQUETAS ESP (ORBES Y SÍMBOLOS)
-- ==========================================
local tagConnections = {}

function cleanTags(animated)
    for _, conn in pairs(tagConnections) do conn:Disconnect() end
    tagConnections = {}
    for _, child in ipairs(ScreenGui:GetChildren()) do
        if child.Name == "BloxyTag_Dynamic" then 
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
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local humanoid = p.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end
end

local function PlayTeleportSound()
    pcall(function()
        local sound = Instance.new("Sound", ScreenGui)
        sound.SoundId = "rbxassetid://7322277676" 
        sound.Volume = 3
        sound:Play()
        Debris:AddItem(sound, 3) 
    end)
end

function applyTagToPlayer(player)
    if not _G.TagsEnabled then return end
    
    task.spawn(function()
        local isLocal = (player == LocalPlayer)
        local isF = false
        if not isLocal then isF = isFriend(player) end
        local isV = isScriptUser(player) or isLocal 
        
        if not (isF or isV or isLocal) then return end
        
        local function apply(character)
            if not _G.TagsEnabled then return end
            local head = character:WaitForChild("Head", 5)
            if not head then return end
            
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
            
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
            TagButton.Size = UDim2.new(0, 0, 0, 0) 
            TagButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TagButton.BackgroundTransparency = 0.5 
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
            
            local TagStroke = Instance.new("UIStroke", TagButton)
            TagStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
            TagStroke.Thickness = 1.2
            TagStroke.Color = Color3.fromRGB(255, 255, 255) 
            TagStroke.Transparency = 0.1 

            local OrbContainer = Instance.new("Frame", TagButton)
            OrbContainer.Size = UDim2.new(1, 0, 1, 0)
            OrbContainer.BackgroundTransparency = 1
            OrbContainer.ZIndex = 1

            local ContentContainer = Instance.new("Frame", TagButton)
            ContentContainer.Name = "Content"
            ContentContainer.Size = UDim2.new(1, 0, 1, 0)
            ContentContainer.BackgroundTransparency = 1
            ContentContainer.ZIndex = 2

            local ContentLayout = Instance.new("UIListLayout", ContentContainer)
            ContentLayout.FillDirection = Enum.FillDirection.Horizontal
            ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left 
            ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder 
            ContentLayout.Padding = UDim.new(0, 6) 
            
            local Padding = Instance.new("UIPadding", ContentContainer)
            Padding.PaddingLeft = UDim.new(0, 12)
            Padding.PaddingRight = UDim.new(0, 12)

            if isV then
                local VerifiedIcon = Instance.new("TextLabel", ContentContainer)
                VerifiedIcon.Name = "VerifiedIcon"
                VerifiedIcon.Size = UDim2.new(0, 22, 0, 22)
                VerifiedIcon.BackgroundTransparency = 1
                VerifiedIcon.Text = customVerifiedSymbol
                VerifiedIcon.Font = Enum.Font.GothamBold 
                VerifiedIcon.RichText = true 
                VerifiedIcon.TextSize = 15
                VerifiedIcon.LayoutOrder = 1 
                VerifiedIcon.ZIndex = 3
            end

            if isF then
                local FriendsIcon = Instance.new("TextLabel", ContentContainer)
                FriendsIcon.Name = "FriendsIcon"
                FriendsIcon.Size = UDim2.new(0, 22, 0, 22) 
                FriendsIcon.BackgroundTransparency = 1
                FriendsIcon.Text = customFriendSymbol
                FriendsIcon.Font = Enum.Font.GothamBold 
                FriendsIcon.RichText = true 
                FriendsIcon.TextSize = 15
                FriendsIcon.LayoutOrder = 2 
                FriendsIcon.ZIndex = 3
            end

            local AliasLabel = Instance.new("TextLabel", ContentContainer)
            AliasLabel.BackgroundTransparency = 1
            AliasLabel.Size = UDim2.new(0, 0, 1, 0)
            AliasLabel.Text = ""
            AliasLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
            AliasLabel.Font = Enum.Font.GothamBold
            AliasLabel.TextSize = 14 
            AliasLabel.TextXAlignment = Enum.TextXAlignment.Left
            AliasLabel.LayoutOrder = 3 
            AliasLabel.ZIndex = 3

            TweenService:Create(TagButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 40, 0, 40)}):Play()

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
            
            local conn = RunService.RenderStepped:Connect(function(dt)
                if not Billboard or not Billboard.Parent then return end

                orbTimer = orbTimer + dt
                if isExpanded and orbTimer >= 0.15 then
                    orbTimer = 0
                    pcall(function()
                        local orb = Instance.new("Frame")
                        local size = math.random(2, 5)
                        orb.Size = UDim2.new(0, size, 0, size)
                        orb.Position = UDim2.new(math.random(10, 90)/100, 0, 1.2, 0)
                        orb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        orb.BackgroundTransparency = 0.3
                        orb.BorderSizePixel = 0
                        orb.ZIndex = 1
                        Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)
                        orb.Parent = OrbContainer

                        local tweenInfo = TweenInfo.new(math.random(15, 30)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                        local tween = TweenService:Create(orb, tweenInfo, {
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
                        AliasLabel.Text = player.DisplayName .. "|"
                        local textWidth = AliasLabel.TextBounds.X
                        AliasLabel.Text = "" 
                        AliasLabel.Size = UDim2.new(0, textWidth + 4, 1, 0)
                        
                        local numIcons = 0
                        for _, child in ipairs(ContentContainer:GetChildren()) do
                            if child.Name == "VerifiedIcon" or child.Name == "FriendsIcon" then 
                                numIcons = numIcons + 1 
                            end
                        end
                        
                        local totalChildWidth = textWidth + (numIcons * 22)
                        local totalPadsWidth = numIcons * 6
                        local totalFitWidth = 12 + totalChildWidth + totalPadsWidth + 12
                        
                        TweenService:Create(TagButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, totalFitWidth, 0, 40)}):Play()
                    end
                else
                    if isExpanded then
                        isExpanded = false
                        TweenService:Create(TagButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 40, 0, 40)}):Play()
                        AliasLabel.Text = ""
                    end
                end
            end)
            table.insert(tagConnections, conn)

            task.spawn(function()
                local aliasText = player.DisplayName 
                while Billboard and Billboard.Parent do
                    if not _G.TagsEnabled then break end
                    if isExpanded then
                        for i = 1, #aliasText do
                            if not Billboard or not Billboard.Parent or not isExpanded then break end
                            AliasLabel.Text = string.sub(aliasText, 1, i) .. "|"
                            task.wait(0.04)
                        end
                        for b = 1, 5 do
                            if not Billboard or not Billboard.Parent or not isExpanded then break end
                            AliasLabel.Text = aliasText .. "|"
                            task.wait(0.4)
                            if not isExpanded then break end
                            AliasLabel.Text = aliasText
                            task.wait(0.4)
                        end
                        for i = #aliasText, 0, -1 do
                            if not Billboard or not Billboard.Parent or not isExpanded then break end
                            AliasLabel.Text = string.sub(aliasText, 1, i) .. "|"
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
    if _G.TagsEnabled then applyTagToPlayer(player) end
end)

task.spawn(function()
    while task.wait(5) do
        if _G.TagsEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                local isLocal = (player == LocalPlayer)
                local isF = false
                if not isLocal then
                    local success, res = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
                    if success then isF = res end
                end
                local isV = isScriptUser(player) or isLocal 
                
                if (isF or isV or isLocal) then
                    friendsCache[player.UserId] = isF
                    if player.Character and player.Character:FindFirstChild("Head") then
                        local hasTag = false
                        for _, child in ipairs(ScreenGui:GetChildren()) do
                            if child.Name == "BloxyTag_Dynamic" and child.Adornee == player.Character.Head then hasTag = true end
                        end
                        if not hasTag then applyTagToPlayer(player) end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- BOTONES Y MENÚS PRINCIPALES
-- ==========================================
local HomeFrame = Instance.new("Frame", MainFrame)
HomeFrame.Size = UDim2.new(1, -20, 1, -95) 
HomeFrame.Position = UDim2.new(0, 10, 0, 55) 
HomeFrame.BackgroundTransparency = 1
local HomeLayout = Instance.new("UIListLayout", HomeFrame)
HomeLayout.Padding = UDim.new(0, 8)
HomeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createScriptButton(text, parent, iconId)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 35) 
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    btn.BackgroundTransparency = 0.85
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextTransparency = 1
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13 
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    if iconId then
        local icon = Instance.new("ImageLabel", btn)
        icon.Name = "BtnIcon"
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 15, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Image = iconId
        icon.ImageTransparency = 1
        local padding = Instance.new("UIPadding", btn)
        padding.PaddingLeft = UDim.new(0, 20)
    end
    
    btn.MouseEnter:Connect(function() 
        if isUiVisible and btn.TextTransparency < 0.5 then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.65}):Play() end 
    end)
    btn.MouseLeave:Connect(function() 
        if isUiVisible and btn.TextTransparency < 0.5 then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play() end 
    end)
    
    return btn
end

local Script1Btn = createScriptButton(" BLOXY - MM2™", HomeFrame, "rbxassetid://7300465360")
local Script2Btn = createScriptButton(" BLOXY - emote", HomeFrame, "rbxassetid://4731371541") 
local Script3Btn = createScriptButton("BLOXY - RV", HomeFrame, "rbxassetid://8935402434") 

-- TAB DE CONFIGURACIÓN
local SettingsFrame = Instance.new("Frame", MainFrame) 
SettingsFrame.Size = UDim2.new(1, -20, 1, -95)
SettingsFrame.Position = UDim2.new(0, 10, 0, 55)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Visible = false 
local SettingsLayout = Instance.new("UIListLayout", SettingsFrame)
SettingsLayout.Padding = UDim.new(0, 8)
SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 

local KeybindBtn = createScriptButton("Tecla Actual: " .. currentKeybind.Name, SettingsFrame)
if isMobile then KeybindBtn.Text = "Tecla Actual: Botón Flotante" end
local TimeFormatBtn = createScriptButton("Formato de Hora: " .. (is24HourFormat and "24H" or "12H"), SettingsFrame)
local ToggleTagsBtn = createScriptButton("Etiquetas ESP (Amigos): Desactivado", SettingsFrame)

local function createTextBox(placeholder, parent, defaultText)
    local container = Instance.new("Frame", parent)
    container.Size = UDim2.new(0.9, 0, 0, 35)
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 0.85
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local box = Instance.new("TextBox", container)
    box.Size = UDim2.new(1, -20, 1, 0)
    box.Position = UDim2.new(0, 10, 0, 0)
    box.BackgroundTransparency = 1
    box.Text = defaultText
    box.PlaceholderText = placeholder
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 13
    box.TextXAlignment = Enum.TextXAlignment.Center
    box.ClearTextOnFocus = false
    
    return box
end

local VerifiedBox = createTextBox("Símbolo Verificado (Ej: ✅)", SettingsFrame, customVerifiedSymbol)
local FriendBox = createTextBox("Símbolo Amigo (Ej: 🤝)", SettingsFrame, customFriendSymbol)

local function refreshTagsIfEnabled()
    if _G.TagsEnabled then
        cleanTags(false)
        for _, p in ipairs(Players:GetPlayers()) do applyTagToPlayer(p) end
    end
end

VerifiedBox.FocusLost:Connect(function()
    local txt = VerifiedBox.Text
    if #txt > 0 then customVerifiedSymbol = truncateToChars(txt, 3) else customVerifiedSymbol = "✅" end
    VerifiedBox.Text = customVerifiedSymbol
    saveConfig()
    refreshTagsIfEnabled()
end)

FriendBox.FocusLost:Connect(function()
    local txt = FriendBox.Text
    if #txt > 0 then customFriendSymbol = truncateToChars(txt, 3) else customFriendSymbol = "🤝" end
    FriendBox.Text = customFriendSymbol
    saveConfig()
    refreshTagsIfEnabled()
end)

-- ==========================================
-- ANIMACIONES Y VISIBILIDAD
-- ==========================================
local fastFadeInfo = TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local fadeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function fadeTabContent(tab, show)
    for _, item in ipairs(tab:GetDescendants()) do
        if item:IsA("TextButton") or item:IsA("Frame") and item.Name ~= "MainFrame" and not item:IsA("UIListLayout") and not item:IsA("UICorner") and not item:IsA("UIPadding") then 
            if item.Parent == tab or item.Parent.Parent == tab then
                TweenService:Create(item, fastFadeInfo, {BackgroundTransparency = show and 0.85 or 1}):Play()
            end
        end
        if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then 
            TweenService:Create(item, fastFadeInfo, {TextTransparency = show and 0 or 1}):Play()
        elseif item:IsA("ImageLabel") and item.Name == "BtnIcon" then 
            TweenService:Create(item, fastFadeInfo, {ImageTransparency = show and 0 or 1}):Play() 
        end
    end
end

function toggleUI(show)
    if show then MainFrame.Visible = true end
    isUiVisible = show
    TweenService:Create(Blur, fadeTweenInfo, {Size = show and 25 or 0}):Play()
    TweenService:Create(DarkOverlay, fadeTweenInfo, {BackgroundTransparency = show and 0.4 or 1}):Play()
    TweenService:Create(MainFrame, fadeTweenInfo, {BackgroundTransparency = show and 0.75 or 1}):Play()

    local t1 = show and 0 or 1 
    TweenService:Create(UIStroke, fadeTweenInfo, {Transparency = show and 0.5 or 1}):Play()
    TweenService:Create(Title, fadeTweenInfo, {TextTransparency = t1}):Play()
    TweenService:Create(CloseBtn, fadeTweenInfo, {TextTransparency = t1}):Play()
    TweenService:Create(SettingsBtn, fadeTweenInfo, {ImageTransparency = t1}):Play()
    TweenService:Create(TopSeparator, fadeTweenInfo, {BackgroundTransparency = show and 0.8 or 1}):Play()
    TweenService:Create(DiscordBtn, fadeTweenInfo, {ImageTransparency = t1, BackgroundTransparency = t1}):Play()
    TweenService:Create(BottomSeparator, fadeTweenInfo, {BackgroundTransparency = show and 0.8 or 1}):Play()
    TweenService:Create(ProfilePic, fadeTweenInfo, {ImageTransparency = t1}):Play()
    TweenService:Create(UsernameLabel, fadeTweenInfo, {TextTransparency = t1}):Play()
    TweenService:Create(StatsLabel, fadeTweenInfo, {TextTransparency = t1}):Play()
    TweenService:Create(TimeLabel, fadeTweenInfo, {TextTransparency = t1}):Play()

    fadeTabContent(inSettings and SettingsFrame or HomeFrame, show)
    if not show then task.delay(0.35, function() if not isUiVisible then MainFrame.Visible = false end end) end
end

-- ==========================================
-- LÓGICA DE BOTONES Y SISTEMAS
-- ==========================================
-- Para evitar que se oculte la interfaz si el usuario solo quería mover el botón flotante
local clickTick = tick()
FloatingToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        clickTick = tick()
    end
end)
FloatingToggleBtn.MouseButton1Click:Connect(function() 
    -- Si el clic fue rápido (menos de 0.2 segundos), lo cuenta como clic y no como arrastre
    if tick() - clickTick < 0.25 then
        toggleUI(not isUiVisible) 
    end
end)

ToggleTagsBtn.MouseButton1Click:Connect(function()
    _G.TagsEnabled = not _G.TagsEnabled
    ToggleTagsBtn.Text = "Etiquetas ESP (Amigos): " .. (_G.TagsEnabled and "Activado" or "Desactivado")
    if _G.TagsEnabled then
        for _, p in ipairs(Players:GetPlayers()) do applyTagToPlayer(p) end
    else
        cleanTags(true) 
    end
end)

TimeFormatBtn.MouseButton1Click:Connect(function()
    is24HourFormat = not is24HourFormat
    TimeFormatBtn.Text = "Formato de Hora: " .. (is24HourFormat and "24H" or "12H")
    updateTimeDisplay()
    saveConfig()
end)

local isBinding = false
KeybindBtn.MouseButton1Click:Connect(function()
    if isMobile then return end
    isBinding = true
    KeybindBtn.Text = "Presiona una tecla..."
    TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(88, 101, 242)}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        currentKeybind = input.KeyCode
        isBinding = false
        KeybindBtn.Text = "Tecla Actual: " .. currentKeybind.Name
        TweenService:Create(KeybindBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        saveConfig()
        return
    end
    if input.KeyCode == currentKeybind and not isBinding and not gameProcessed then
        toggleUI(not isUiVisible)
    end
end)

local function executeScript(url)
    scriptsExecuted = true 
    toggleUI(false)
    pcall(function() loadstring(game:HttpGet(url))() end)
end

Script1Btn.MouseButton1Click:Connect(function() executeScript("https://raw.githubusercontent.com/Cooprince593/Script-hub/refs/heads/main/Bloxy-MM2.lua") end)
Script2Btn.MouseButton1Click:Connect(function() executeScript("https://raw.githubusercontent.com/Cooprince593/Script-hub/refs/heads/main/Bloxy%20-%20emote.lua") end)
Script3Btn.MouseButton1Click:Connect(function() executeScript("https://raw.githubusercontent.com/Cooprince593/Script-hub/refs/heads/main/BLOXY-RV.lua") end)

SettingsBtn.MouseButton1Click:Connect(function()
    if not isUiVisible then return end
    inSettings = not inSettings
    TweenService:Create(SettingsBtn, fastFadeInfo, {Rotation = inSettings and 90 or 0}):Play()
    local activeTab, inactiveTab = inSettings and SettingsFrame or HomeFrame, inSettings and HomeFrame or SettingsFrame
    fadeTabContent(inactiveTab, false)
    task.delay(0.20, function() 
        if not isUiVisible then return end 
        inactiveTab.Visible = false; activeTab.Visible = true; fadeTabContent(activeTab, true) 
    end)
end)

local function destroyHubCompletely()
    toggleUI(false)
    _G.BloxyHubClosed = true
    cleanTags(true)
    task.wait(0.4)
    if ScreenGui then ScreenGui:Destroy() end
    if ToggleGui then ToggleGui:Destroy() end
    if Blur then Blur:Destroy() end
end

CloseBtn.MouseButton1Click:Connect(function() 
    if scriptsExecuted then
        ShowToastNotification("¡ADVERTENCIA!", "Al cerrar el hub se destruirá su interfaz. Nota: Los scripts se mantendrán activos.", "Cerrar Hub", "Cancelar", function(result)
            if result then destroyHubCompletely() end
        end)
    else
        destroyHubCompletely()
    end
end)

-- ==========================================
-- DRAG SYSTEM 
-- ==========================================
local dragging = false
local dragStart, startPos, lastMousePos
local velocity = Vector2.new(0, 0)

local function clampPosition(pos)
    local screenSize = ScreenGui.AbsoluteSize
    local frameSize = MainFrame.AbsoluteSize
    local minX = frameSize.X / 2
    local maxX = screenSize.X - (frameSize.X / 2)
    local minY = frameSize.Y / 2
    local maxY = screenSize.Y - (frameSize.Y / 2)
    
    local absX = (pos.X.Scale * screenSize.X) + pos.X.Offset
    local absY = (pos.Y.Scale * screenSize.Y) + pos.Y.Offset
    
    absX = math.clamp(absX, minX, maxX)
    absY = math.clamp(absY, minY, maxY)
    
    return UDim2.new(0.5, absX - (screenSize.X * 0.5), 0.5, absY - (screenSize.Y * 0.5))
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position 
        lastMousePos = input.Position
        velocity = Vector2.new(0, 0)
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        local targetPos = clampPosition(UDim2.new(
            startPos.X.Scale, MainFrame.Position.X.Offset + (velocity.X * 10),
            startPos.Y.Scale, MainFrame.Position.Y.Offset + (velocity.Y * 10)
        ))
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local targetPos = clampPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
        TweenService:Create(MainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        velocity = input.Position - lastMousePos
        lastMousePos = input.Position
    end
end)

-- ==========================================
-- DRAG SYSTEM PARA EL BOTÓN FLOTANTE (MÓVIL)
-- ==========================================
local tDragging = false
local tDragStart, tStartPos

FloatingToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = true
        tDragStart = input.Position
        tStartPos = FloatingToggleBtn.Position
    end
end)

FloatingToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tDragStart
        -- Movimiento libre sin restricciones matemáticas para que lo puedas poner donde quieras
        FloatingToggleBtn.Position = UDim2.new(
            tStartPos.X.Scale, tStartPos.X.Offset + delta.X,
            tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ==========================================
-- INICIO
-- ==========================================
MainFrame.Visible = false
task.wait(0.1) 
toggleUI(true)

task.spawn(function()
    task.wait(0.5)
    ShowToastNotification("BLOXY HUB - ESP", "¿Deseas activar las etiquetas visuales para identificar a tus amigos en la partida?", "Activar ESP", "No, gracias", function(result)
        if result then
            _G.TagsEnabled = true
            ToggleTagsBtn.Text = "Etiquetas ESP (Amigos): Activado"
            for _, p in ipairs(Players:GetPlayers()) do applyTagToPlayer(p) end
        end
    end)
end)
