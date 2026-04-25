local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local guiName = "BloxyHub_UI"
local blurName = "BloxyHub_Blur"
local toggleGuiName = "BloxyHub_Toggle"
local configFileName = "BloxyHub_Keybind.json"

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local currentKeybind = Enum.KeyCode.LeftAlt
local is24HourFormat = false 
local currentTab = "Home"

local function loadConfig()
    if isfile and readfile and isfile(configFileName) then
        pcall(function()
            local result = HttpService:JSONDecode(readfile(configFileName))
            if result.Keybind and Enum.KeyCode[result.Keybind] then
                currentKeybind = Enum.KeyCode[result.Keybind]
            end
            if result.Format24H ~= nil then is24HourFormat = result.Format24H end
        end)
    end
end

local function saveConfig()
    if writefile then
        pcall(function()
            local data = { Keybind = currentKeybind.Name, Format24H = is24HourFormat }
            writefile(configFileName, HttpService:JSONEncode(data))
        end)
    end
end

loadConfig()

local targetParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui", 5)
if targetParent and targetParent:FindFirstChild(guiName) then targetParent[guiName]:Destroy() end
if targetParent and targetParent:FindFirstChild(toggleGuiName) then targetParent[toggleGuiName]:Destroy() end
if Lighting:FindFirstChild(blurName) then Lighting[blurName]:Destroy() end

_G.BloxyHubClosed = false 
_G.TagsEnabled = false 
local scriptsExecuted = false 
local isUiVisible = true

local function ApplyFPSBoost()
    task.spawn(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.ShadowSoftness = 0
        if sethiddenproperty then pcall(function() sethiddenproperty(Lighting, "Technology", 2) end) end
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
    end)
end

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
FloatingToggleBtn.BackgroundTransparency = 0.1
FloatingToggleBtn.Text = "</>"
FloatingToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingToggleBtn.Font = Enum.Font.GothamBold
FloatingToggleBtn.TextSize = 16
FloatingToggleBtn.Visible = isMobile 
Instance.new("UICorner", FloatingToggleBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatingToggleBtn)
FloatStroke.Color = Color3.fromRGB(80, 80, 80)
FloatStroke.Thickness = 1.5

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = targetParent
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local DarkOverlay = Instance.new("Frame", ScreenGui)
DarkOverlay.Size = UDim2.new(1, 0, 1, 0)
DarkOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DarkOverlay.BackgroundTransparency = 1
DarkOverlay.ZIndex = 1

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) 
MainFrame.Size = isMobile and UDim2.new(0, 450, 0, 250) or UDim2.new(0, 520, 0, 310)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BackgroundTransparency = 1 
MainFrame.ZIndex = 2
MainFrame.ClipsDescendants = true
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
Title.Position = UDim2.new(0, 30, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BLOXY HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.ZIndex = 3

local SettingsBtn = Instance.new("ImageButton", MainFrame)
SettingsBtn.Size = UDim2.new(0, 24, 0, 24)
SettingsBtn.Position = UDim2.new(1, -65, 0, 8) 
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Image = "rbxassetid://6031280882" 
SettingsBtn.ImageTransparency = 1
SettingsBtn.ZIndex = 3

local DiscordBtn = Instance.new("ImageButton", MainFrame)
DiscordBtn.Size = UDim2.new(0, 28, 0, 28)
DiscordBtn.Position = UDim2.new(1, -100, 0, 6) 
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
DiscordBtn.Image = "rbxthumb://type=Asset&id=117462413260019&w=420&h=420" 
DiscordBtn.ImageTransparency = 1
DiscordBtn.BackgroundTransparency = 1
DiscordBtn.ZIndex = 3
Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 6)

local TopSeparator = Instance.new("Frame", MainFrame)
TopSeparator.Size = UDim2.new(1, 0, 0, 1)
TopSeparator.Position = UDim2.new(0, 0, 0, 40) 
TopSeparator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopSeparator.BackgroundTransparency = 1
TopSeparator.ZIndex = 3

local BottomSeparator = Instance.new("Frame", MainFrame)
BottomSeparator.Size = UDim2.new(1, 0, 0, 1)
BottomSeparator.Position = UDim2.new(0, 0, 1, -40) 
BottomSeparator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BottomSeparator.BackgroundTransparency = 1
BottomSeparator.ZIndex = 3

local ProfilePic = Instance.new("ImageLabel", MainFrame)
ProfilePic.Size = UDim2.new(0, 26, 0, 26)
ProfilePic.Position = UDim2.new(0, 30, 1, -33)
ProfilePic.BackgroundTransparency = 1
ProfilePic.ImageTransparency = 1
ProfilePic.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
ProfilePic.ZIndex = 3
Instance.new("UICorner", ProfilePic).CornerRadius = UDim.new(1, 0)

local UsernameLabel = Instance.new("TextLabel", MainFrame)
UsernameLabel.Size = UDim2.new(0.3, 0, 0, 40) 
UsernameLabel.Position = UDim2.new(0, 65, 1, -40)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = LocalPlayer.DisplayName
UsernameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
UsernameLabel.TextTransparency = 1
UsernameLabel.Font = Enum.Font.GothamSemibold
UsernameLabel.TextSize = 13
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.ZIndex = 3

local StatsLabel = Instance.new("TextLabel", MainFrame)
StatsLabel.Size = UDim2.new(0.4, 0, 0, 40) 
StatsLabel.Position = UDim2.new(0.3, 0, 1, -40)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180) 
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.TextSize = 12
StatsLabel.ZIndex = 3

local TimeLabel = Instance.new("TextLabel", MainFrame)
TimeLabel.Size = UDim2.new(0.3, -15, 0, 40)
TimeLabel.Position = UDim2.new(0.7, 0, 1, -40)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
TimeLabel.TextTransparency = 1
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 13
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
TimeLabel.ZIndex = 3

local function updateTimeDisplay()
    local formatStr = is24HourFormat and "%H:%M" or "%I:%M %p"
    if TimeLabel then TimeLabel.Text = os.date(formatStr) end
end
task.spawn(function() while task.wait(1) do updateTimeDisplay() end end)

local lastTime = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTime >= 0.5 then 
        local fps = math.floor(frameCount / (currentTime - lastTime))
        frameCount = 0 
        lastTime = currentTime
        local ping = 0
        pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
        if StatsLabel then StatsLabel.Text = string.format("%d FPS | %d ms", fps, ping) end
    end
end)

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
    local Btn2 = btn2Text and createDialogBtn(btn2Text, UDim2.new(1, -150, 1, -45), Color3.fromRGB(220, 80, 80))

    TweenService:Create(DialogBox, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -20, 1, -20)}):Play()

    local function closeDialog(result)
        TweenService:Create(DialogBox, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 350, 1, -20)}):Play()
        task.wait(0.4)
        DialogBox:Destroy()
        if callback then callback(result) end
    end

    Btn1.MouseButton1Click:Connect(function() closeDialog(true) end)
    if Btn2 then Btn2.MouseButton1Click:Connect(function() closeDialog(false) end) end
end

DiscordBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard("https://discord.gg/fQF8BX7rbz")
    elseif toclipboard then toclipboard("https://discord.gg/fQF8BX7rbz") end
    ShowToastNotification("¡Link Copiado!", "El link del Discord ha sido copiado a tu portapapeles. ¡Pégalo en tu navegador!", "Ok")
end)

-------------------------------------------------------------------------
-- SISTEMA DE TAGS NATIVO E INTEGRADO (CERO LAG TOTAL)
-------------------------------------------------------------------------
local espConnections = {}
local espScreenGui = nil
local friendsCache = {}

local function cleanExternalTags()
    -- 1. Limpieza de conexiones (muy rápido, sin lag)
    for _, conn in ipairs(espConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    table.clear(espConnections)

    -- 2. Destruimos todo el GUI directamente (eliminando todos los tags sin tener que escanear personajes)
    if espScreenGui then
        pcall(function() espScreenGui:Destroy() end)
        espScreenGui = nil
    end

    -- 3. Limpieza de seguridad extra en CoreGui/PlayerGui (sólo por precaución y sin escaneo profundo)
    task.spawn(function()
        pcall(function()
            local target = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:FindFirstChild("PlayerGui")
            if target and target:FindFirstChild("BloxyTags_External_GUI") then
                target["BloxyTags_External_GUI"]:Destroy()
            end
        end)
    end)
end

local function ActivateTagsESP()
    if espScreenGui and espScreenGui.Parent then return end 
    
    local targetParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui", 5)
    
    espScreenGui = Instance.new("ScreenGui")
    espScreenGui.Name = "BloxyTags_External_GUI"
    espScreenGui.Parent = targetParent
    espScreenGui.ResetOnSpawn = false

    local function isFriend(player)
        if player == LocalPlayer then return false end
        if friendsCache[player.UserId] ~= nil then return friendsCache[player.UserId] end
        local success, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
        if success then friendsCache[player.UserId] = result return result end
        return false
    end

    local function PlayTeleportSound()
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://127439510287856" 
            sound.Volume = 2 
            sound.Parent = SoundService 
            sound:Play()
            Debris:AddItem(sound, 4) 
        end)
    end

    local function applyTagToPlayer(player)
        if player == LocalPlayer then return end 

        task.spawn(function()
            local isF = isFriend(player)
            if not isF then return end 
            
            local function apply(character)
                local head = character:WaitForChild("Head", 5)
                local humanoid = character:WaitForChild("Humanoid", 5)
                if not head or not _G.TagsEnabled then return end
                
                if humanoid then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end

                local Billboard = Instance.new("BillboardGui", espScreenGui)
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

                local TagStroke = Instance.new("UIStroke", TagButton)
                TagStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
                TagStroke.Thickness = 1.2
                TagStroke.Color = Color3.fromRGB(255, 255, 255) 
                TagStroke.Transparency = 0.5 

                local OrbContainer = Instance.new("Frame", TagButton)
                OrbContainer.Size = UDim2.new(1, 0, 1, 0)
                OrbContainer.BackgroundTransparency = 1
                OrbContainer.ZIndex = 1
                OrbContainer.Active = false 

                local LogoContainer = Instance.new("Frame", TagButton)
                LogoContainer.Name = "CodeLogo"
                LogoContainer.Size = UDim2.new(1, 0, 1, 0) 
                LogoContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
                LogoContainer.BackgroundTransparency = 0.15 
                LogoContainer.ZIndex = 3
                LogoContainer.Active = false 
                
                local LogoCorner = Instance.new("UICorner", LogoContainer)
                LogoCorner.CornerRadius = UDim.new(0.25, 0)
                
                local FriendIcon = Instance.new("ImageLabel", LogoContainer)
                FriendIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
                FriendIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                FriendIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
                FriendIcon.BackgroundTransparency = 1
                FriendIcon.Image = "rbxthumb://type=Asset&id=136701428260164&w=150&h=150"
                FriendIcon.ZIndex = 4

                local ContentContainer = Instance.new("Frame", TagButton)
                ContentContainer.Name = "Content"
                ContentContainer.Size = UDim2.new(1, -40, 1, 0)
                ContentContainer.Position = UDim2.new(0, 42, 0, 0)
                ContentContainer.BackgroundTransparency = 1
                ContentContainer.ZIndex = 2
                ContentContainer.Active = false

                local ContentLayout = Instance.new("UIListLayout", ContentContainer)
                ContentLayout.FillDirection = Enum.FillDirection.Horizontal
                ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                ContentLayout.Padding = UDim.new(0, 6) 

                local AliasLabel = Instance.new("TextLabel", ContentContainer)
                AliasLabel.BackgroundTransparency = 1
                AliasLabel.Size = UDim2.new(0, 0, 1, 0)
                AliasLabel.Text = ""
                AliasLabel.TextColor3 = Color3.fromRGB(15, 15, 15) 
                AliasLabel.Font = Enum.Font.GothamBlack
                AliasLabel.TextSize = 14 
                AliasLabel.ZIndex = 3

                table.insert(espConnections, TagButton.Activated:Connect(function()
                    if player == LocalPlayer or not _G.TagsEnabled then return end
                    pcall(function()
                        local lpChar = LocalPlayer.Character
                        local targetChar = player.Character
                        if lpChar and lpChar:FindFirstChild("HumanoidRootPart") and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            PlayTeleportSound() 
                            local targetHRP = targetChar.HumanoidRootPart
                            local newCFrame = targetHRP.CFrame * CFrame.new(4, 0, 2) 
                            lpChar:PivotTo(newCFrame)
                        end
                    end)
                end))

                local isExpanded = false
                local orbTimer = 0
                local displayAliasText = player.DisplayName
                
                local renderConn
                renderConn = RunService.RenderStepped:Connect(function(dt)
                    if not _G.TagsEnabled or not Billboard or not Billboard.Parent then 
                        if renderConn then renderConn:Disconnect() end
                        return 
                    end

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
                            orb.Active = false 
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
                table.insert(espConnections, renderConn)

                task.spawn(function()
                    while Billboard and Billboard.Parent and _G.TagsEnabled do
                        if isExpanded then
                            for i = 1, #displayAliasText do
                                if not Billboard or not Billboard.Parent or not isExpanded or not _G.TagsEnabled then break end
                                AliasLabel.Text = string.sub(displayAliasText, 1, i) .. "|"
                                task.wait(0.04)
                            end
                            for b = 1, 5 do
                                if not Billboard or not Billboard.Parent or not isExpanded or not _G.TagsEnabled then break end
                                AliasLabel.Text = displayAliasText .. "|"
                                task.wait(0.4)
                                if not isExpanded then break end
                                AliasLabel.Text = displayAliasText
                                task.wait(0.4)
                            end
                            for i = #displayAliasText, 0, -1 do
                                if not Billboard or not Billboard.Parent or not isExpanded or not _G.TagsEnabled then break end
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
            table.insert(espConnections, player.CharacterAdded:Connect(apply))
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        applyTagToPlayer(player)
    end

    table.insert(espConnections, Players.PlayerAdded:Connect(function(player)
        applyTagToPlayer(player)
    end))

    task.spawn(function()
        while task.wait(2.5) do
            if not _G.TagsEnabled or not espScreenGui or not espScreenGui.Parent then break end
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
                        applyTagToPlayer(player)
                    end)
                else
                    friendsCache[player.UserId] = isNowFriend
                    isF = isNowFriend
                end
                
                if isF then 
                    if player.Character and player.Character:FindFirstChild("Head") then
                        local hasTag = false
                        for _, child in ipairs(espScreenGui:GetChildren()) do
                            if child.Name == "BloxyTag_Dynamic" and child.Adornee == player.Character.Head then hasTag = true end
                        end
                        if not hasTag then applyTagToPlayer(player) end
                    end
                end
            end
        end
    end)
end

-------------------------------------------------------------------------
-- SISTEMA DE FRAMES (Home, Settings, Credits)
-------------------------------------------------------------------------
local HomeFrame = Instance.new("ScrollingFrame", MainFrame)
HomeFrame.Size = UDim2.new(1, -30, 1, -95) 
HomeFrame.Position = UDim2.new(0, 20, 0, 55) 
HomeFrame.BackgroundTransparency = 1
HomeFrame.ScrollBarThickness = isMobile and 0 or 4
HomeFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
HomeFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
HomeFrame.BorderSizePixel = 0
HomeFrame.ZIndex = 3

if isMobile then
    local HomeList = Instance.new("UIListLayout", HomeFrame)
    HomeList.Padding = UDim.new(0, 0)
    HomeList.SortOrder = Enum.SortOrder.LayoutOrder
end

local LeftCol = Instance.new("Frame", HomeFrame)
LeftCol.BackgroundTransparency = 1
LeftCol.LayoutOrder = 1
local LeftLayout = Instance.new("UIListLayout", LeftCol)
LeftLayout.Padding = UDim.new(0, 8)
LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local RightCol = Instance.new("Frame", HomeFrame)
RightCol.BackgroundTransparency = 1
RightCol.LayoutOrder = 2
local RightLayout = Instance.new("UIListLayout", RightCol)
RightLayout.Padding = UDim.new(0, 8)
RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

if isMobile then
    LeftCol.Size = UDim2.new(1, 0, 0, 0)
    LeftCol.AutomaticSize = Enum.AutomaticSize.Y
    RightCol.Size = UDim2.new(1, 0, 0, 0)
    RightCol.AutomaticSize = Enum.AutomaticSize.Y
else
    LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
    LeftCol.Position = UDim2.new(0, 0, 0, 0)
    RightCol.Size = UDim2.new(0.5, -5, 1, 0)
    RightCol.Position = UDim2.new(0.5, 5, 0, 0)
end

local function createScriptButton(text, parent, exactId, isInfinityYield)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
    btn.BackgroundTransparency = 0.85
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextTransparency = 1
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13 
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    if exactId then
        btn.TextXAlignment = Enum.TextXAlignment.Left
        local padding = Instance.new("UIPadding", btn)
        padding.PaddingLeft = UDim.new(0, 15) 
        
        local icon = Instance.new("ImageLabel", btn)
        icon.Name = "BtnIcon"
        icon.AnchorPoint = Vector2.new(1, 0.5)
        
        if isInfinityYield then
            icon.Size = UDim2.new(0, 65, 0, 32) 
            icon.Position = UDim2.new(1, 60, 0.5, 0) 
            icon.ScaleType = Enum.ScaleType.Stretch
            padding.PaddingRight = UDim.new(0, 85) 
        else
            icon.Size = UDim2.new(0, 65, 0, 37) 
            icon.Position = UDim2.new(1, 30, 0.5, 0) 
            icon.ScaleType = Enum.ScaleType.Fit
            padding.PaddingRight = UDim.new(0, 52) 
        end
        
        icon.BackgroundTransparency = 1
        icon.Image = "rbxthumb://type=Asset&id=" .. exactId .. "&w=420&h=420"
        icon.ImageTransparency = 1
        icon.ZIndex = 4
    else
        btn.TextXAlignment = Enum.TextXAlignment.Center
    end
    
    btn.MouseEnter:Connect(function() 
        if isUiVisible and btn.TextTransparency < 0.5 then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.65}):Play() end 
    end)
    btn.MouseLeave:Connect(function() 
        if isUiVisible and btn.TextTransparency < 0.5 then TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play() end 
    end)
    
    return btn
end

local Script1Btn = createScriptButton("BLOXY - MM2™", LeftCol, "103857058597024")
local Script2Btn = createScriptButton("BLOXY - emote", LeftCol, "72723345121695") 
local Script3Btn = createScriptButton("BLOXY - RV", LeftCol, "124445109174902") 
local IYBtn = createScriptButton("Infinity Yield", RightCol, "108605555614873", true) 

local SettingsFrame = Instance.new("ScrollingFrame", MainFrame) 
SettingsFrame.Size = UDim2.new(1, -30, 1, -95)
SettingsFrame.Position = UDim2.new(0, 20, 0, 55)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Visible = false 
SettingsFrame.ScrollBarThickness = isMobile and 0 or 4
SettingsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ZIndex = 3

local SettingsLayout = Instance.new("UIListLayout", SettingsFrame)
SettingsLayout.Padding = UDim.new(0, 8)
SettingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 

local KeybindBtn = createScriptButton("Tecla Actual: " .. currentKeybind.Name, SettingsFrame)
if isMobile then KeybindBtn.Text = "Tecla Actual: Botón Flotante" end
local TimeFormatBtn = createScriptButton("Formato de Hora: " .. (is24HourFormat and "24H" or "12H"), SettingsFrame)
local ToggleTagsBtn = createScriptButton("Etiquetas ESP (Amigos): Desactivado", SettingsFrame)

-- CREDITS FRAME
local CreditsFrame = Instance.new("ScrollingFrame", MainFrame) 
CreditsFrame.Size = UDim2.new(1, -30, 1, -95)
CreditsFrame.Position = UDim2.new(0, 20, 0, 55)
CreditsFrame.BackgroundTransparency = 1
CreditsFrame.Visible = false 
CreditsFrame.ScrollBarThickness = isMobile and 0 or 4
CreditsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
CreditsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
CreditsFrame.BorderSizePixel = 0
CreditsFrame.ZIndex = 3

local CreditsLayout = Instance.new("UIListLayout", CreditsFrame)
CreditsLayout.Padding = UDim.new(0, 12)
CreditsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 

local function createCreditCard(title, name, exactId)
    local card = Instance.new("Frame", CreditsFrame)
    card.Size = UDim2.new(0.9, 0, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.85
    card.ZIndex = 3
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local icon = Instance.new("ImageLabel", card)
    icon.Name = "BtnIcon" 
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0.5, -20)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxthumb://type=Asset&id=" .. exactId .. "&w=420&h=420"
    icon.ImageTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = 4
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
    
    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.Size = UDim2.new(1, -70, 0, 20)
    titleLbl.Position = UDim2.new(0, 60, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    titleLbl.TextTransparency = 1
    titleLbl.Font = Enum.Font.Gotham
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 4
    
    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1, -70, 0, 20)
    nameLbl.Position = UDim2.new(0, 60, 0, 30)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.TextTransparency = 1
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 15
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 4
end

createCreditCard("Creador", "Cooper_593", "129384361181023")
createCreditCard("Co - Owner", "abrahahamCuenta2", "78644946858214")

-------------------------------------------------------------------------
-- BARRA LATERAL (LÍNEA EXTRAFINA Y SEPARADA)
-------------------------------------------------------------------------
local isSidebarOpen = false

local SidebarLineBtn = Instance.new("Frame", MainFrame)
SidebarLineBtn.Size = UDim2.new(0, 4, 1, -100) 
SidebarLineBtn.Position = UDim2.new(0, 10, 0, 50) 
SidebarLineBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SidebarLineBtn.BackgroundTransparency = 0.8
SidebarLineBtn.ZIndex = 11
Instance.new("UICorner", SidebarLineBtn).CornerRadius = UDim.new(0, 5)

-- Panel Oscuro de la barra
local SidebarPanel = Instance.new("Frame", MainFrame)
SidebarPanel.Size = UDim2.new(0, 0, 1, -100) 
SidebarPanel.Position = UDim2.new(0, 22, 0, 50) 
SidebarPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SidebarPanel.BackgroundTransparency = 0.15
SidebarPanel.ClipsDescendants = true
SidebarPanel.ZIndex = 10 
Instance.new("UICorner", SidebarPanel).CornerRadius = UDim.new(0, 8)

local SidebarLayout = Instance.new("UIListLayout", SidebarPanel)
SidebarLayout.Padding = UDim.new(0, 10)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SidebarPadding = Instance.new("UIPadding", SidebarPanel)
SidebarPadding.PaddingTop = UDim.new(0, 15)

local function createSidebarBtnItem(text, exactId, order)
    local btn = Instance.new("TextButton", SidebarPanel)
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.Text = "" 
    btn.LayoutOrder = order
    btn.AutoButtonColor = false
    btn.ZIndex = 12 
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 26, 0, 26) 
    icon.Position = UDim2.new(0.5, -13, 0.5, -13) 
    icon.BackgroundTransparency = 1
    icon.Image = "rbxthumb://type=Asset&id=" .. exactId .. "&w=420&h=420"
    icon.ScaleType = Enum.ScaleType.Fit
    icon.ZIndex = 13

    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play() end)
    
    return btn
end

local NavLibraryBtn = createSidebarBtnItem("Librería", "105345141924524", 1)
local NavCreditsBtn = createSidebarBtnItem("Créditos", "100758079373329", 2)

-------------------------------------------------------------------------
-- LÓGICA DE RATÓN GLOBAL
-------------------------------------------------------------------------
local sidebarCheckConnection

local function isMouseInSidebar()
    local mousePos = UserInputService:GetMouseLocation()
    local framePos = MainFrame.AbsolutePosition
    local frameSize = MainFrame.AbsoluteSize
    local inSidebarRegion = (mousePos.X >= framePos.X) and (mousePos.X <= framePos.X + 95) and
                            (mousePos.Y >= framePos.Y) and (mousePos.Y <= framePos.Y + frameSize.Y)
    return inSidebarRegion
end

local function closeSidebar()
    if not isSidebarOpen then return end
    isSidebarOpen = false
    
    TweenService:Create(SidebarPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, -100)}):Play()

    local normalPos = UDim2.new(0, 20, 0, 55)
    local normalSize = UDim2.new(1, -30, 1, -95)
    TweenService:Create(HomeFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = normalPos, Size = normalSize}):Play()
    TweenService:Create(SettingsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = normalPos, Size = normalSize}):Play()
    TweenService:Create(CreditsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = normalPos, Size = normalSize}):Play()

    if sidebarCheckConnection then
        sidebarCheckConnection:Disconnect()
        sidebarCheckConnection = nil
    end
end

local function openSidebar()
    if isSidebarOpen then return end
    isSidebarOpen = true
    
    TweenService:Create(SidebarPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 60, 1, -100)}):Play()

    local shrinkPos = UDim2.new(0, 95, 0, 55)
    local shrinkSize = UDim2.new(1, -105, 1, -95)
    TweenService:Create(HomeFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = shrinkPos, Size = shrinkSize}):Play()
    TweenService:Create(SettingsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = shrinkPos, Size = shrinkSize}):Play()
    TweenService:Create(CreditsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = shrinkPos, Size = shrinkSize}):Play()

    if sidebarCheckConnection then return end
    sidebarCheckConnection = RunService.RenderStepped:Connect(function()
        if isUiVisible and isSidebarOpen and not isMouseInSidebar() then
            closeSidebar()
        end
    end)
end

SidebarLineBtn.MouseEnter:Connect(function() openSidebar() end)
SidebarPanel.MouseEnter:Connect(function() openSidebar() end)

-------------------------------------------------------------------------
-- TRANSICIONES DE TABS
-------------------------------------------------------------------------
local fastFadeInfo = TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local fadeTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function fadeTabContent(tab, show)
    for _, item in ipairs(tab:GetDescendants()) do
        if item:IsA("TextButton") or (item:IsA("Frame") and item.Name ~= "Frame") then 
            TweenService:Create(item, fastFadeInfo, {BackgroundTransparency = show and 0.85 or 1}):Play()
        end
        if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then 
            if item.Text ~= "" then
                TweenService:Create(item, fastFadeInfo, {TextTransparency = show and 0 or 1}):Play()
            end
        elseif item:IsA("ImageLabel") and item.Name == "BtnIcon" then 
            TweenService:Create(item, fastFadeInfo, {ImageTransparency = show and 0 or 1}):Play() 
        end
    end
end

local function switchTab(newTabName)
    if currentTab == newTabName then return end
    local oldFrame = currentTab == "Home" and HomeFrame or (currentTab == "Settings" and SettingsFrame or CreditsFrame)
    local newFrame = newTabName == "Home" and HomeFrame or (newTabName == "Settings" and SettingsFrame or CreditsFrame)
    
    currentTab = newTabName
    fadeTabContent(oldFrame, false)
    task.delay(0.20, function() 
        if not isUiVisible then return end 
        oldFrame.Visible = false
        newFrame.Visible = true
        fadeTabContent(newFrame, true) 
    end)
end

NavLibraryBtn.MouseButton1Click:Connect(function() switchTab("Home") end)
NavCreditsBtn.MouseButton1Click:Connect(function() switchTab("Credits") end)

SettingsBtn.MouseButton1Click:Connect(function()
    if not isUiVisible then return end
    TweenService:Create(SettingsBtn, fastFadeInfo, {Rotation = currentTab == "Settings" and 0 or 90}):Play()
    switchTab(currentTab == "Settings" and "Home" or "Settings")
end)

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
    TweenService:Create(SidebarLineBtn, fadeTweenInfo, {BackgroundTransparency = show and 0.8 or 1}):Play()

    if not show and isSidebarOpen then
        closeSidebar()
    end

    local activeFrame = currentTab == "Home" and HomeFrame or (currentTab == "Settings" and SettingsFrame or CreditsFrame)
    fadeTabContent(activeFrame, show)
    if not show then task.delay(0.35, function() if not isUiVisible then MainFrame.Visible = false end end) end
end

local clickTick = tick()
FloatingToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        clickTick = tick()
    end
end)
FloatingToggleBtn.MouseButton1Click:Connect(function() 
    if tick() - clickTick < 0.25 then toggleUI(not isUiVisible) end
end)

ToggleTagsBtn.MouseButton1Click:Connect(function()
    _G.TagsEnabled = not _G.TagsEnabled
    
    if _G.TagsEnabled then
        ToggleTagsBtn.Text = "Etiquetas ESP (Amigos): Activado"
        task.spawn(ActivateTagsESP)
    else
        ToggleTagsBtn.Text = "Etiquetas ESP (Amigos): Desactivado"
        cleanExternalTags()
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
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet(url))() end)
    end)
end

Script1Btn.MouseButton1Click:Connect(function() executeScript("https://raw.githubusercontent.com/Cooprince593/Script-hub/refs/heads/main/Bloxy-MM2.lua") end)
Script2Btn.MouseButton1Click:Connect(function() executeScript("https://raw.githubusercontent.com/Cooprince593/Script-hub/refs/heads/main/Bloxy%20-%20emote.lua") end)
Script3Btn.MouseButton1Click:Connect(function() executeScript("https://raw.githubusercontent.com/Cooprince593/Script-hub/refs/heads/main/BLOXY-RV.lua") end)
IYBtn.MouseButton1Click:Connect(function() executeScript("https://rawscripts.net/raw/Universal-Script-IY-InfiniteYield-137097") end)

local function destroyHubCompletely()
    toggleUI(false)
    _G.BloxyHubClosed = true
    _G.TagsEnabled = false
    cleanExternalTags()
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
        FloatingToggleBtn.Position = UDim2.new(
            tStartPos.X.Scale, tStartPos.X.Offset + delta.X,
            tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y
        )
    end
end)

MainFrame.Visible = false
task.wait(0.1) 
toggleUI(true)

task.spawn(function()
    task.wait(0.5)
    ShowToastNotification("BLOXY HUB - ESP", "¿Deseas activar las etiquetas visuales para identificar a tus amigos en la partida?", "Activar ESP", "No, gracias", function(result)
        if result then
            _G.TagsEnabled = true
            if ToggleTagsBtn then ToggleTagsBtn.Text = "Etiquetas ESP (Amigos): Activado" end
            task.spawn(ActivateTagsESP)
        else
            _G.TagsEnabled = false
            if ToggleTagsBtn then ToggleTagsBtn.Text = "Etiquetas ESP (Amigos): Desactivado" end
            cleanExternalTags()
        end
        
        task.wait(0.5)
        ShowToastNotification("OPTIMIZACIÓN", "¿Deseas activar el FPS Boost para reducir el lag y mejorar el rendimiento?", "Activar", "Omitir", function(fpsResult)
            if fpsResult then ApplyFPSBoost() end
        end)
    end)
end)
