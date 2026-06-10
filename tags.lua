local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

-- ==============================================================
-- 1. SISTEMA DE FIREBASE (Reemplaza al sistema de amigos)
-- ==============================================================
local firebaseUrl = "https://space-tagsp-default-rtdb.firebaseio.com/Activos.json"
local myIdStr = tostring(LocalPlayer.UserId)
local requestFunc = request or http_request or syn.request or fluxus.request

local firebaseCache = {} -- Guarda quién está en Firebase

-- Auto-Anotarme en la base de datos al ejecutar
pcall(function()
    if requestFunc then
        local datos = {}
        datos[myIdStr] = "Usuario" 
        requestFunc({
            Url = firebaseUrl,
            Method = "PATCH",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(datos)
        })
    end
end)

-- Auto-Borrarme al salir del juego
local function borrarDeFirebase()
    pcall(function()
        if requestFunc then
            requestFunc({Url = "https://space-tagsp-default-rtdb.firebaseio.com/Activos/" .. myIdStr .. ".json", Method = "DELETE"})
        end
    end)
end
game:BindToClose(borrarDeFirebase)
Players.PlayerRemoving:Connect(function(player) if player == LocalPlayer then borrarDeFirebase() end end)
-- ==============================================================


-- Crear el GUI contenedor de los Tags (TU CÓDIGO ORIGINAL)
local guiName = "BloxyTags_External_GUI"
local targetParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui", 5)

if targetParent:FindFirstChild(guiName) then
    targetParent[guiName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = targetParent
ScreenGui.ResetOnSpawn = false

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

-- Función creadora (TU CÓDIGO ORIGINAL)
local function applyTagToPlayer(player)
    -- Eliminé la línea que te bloqueaba a ti mismo para que tú también veas tu tag

    task.spawn(function()
        local function apply(character)
            -- Antes de poner el tag, revisamos si el jugador está en Firebase
            if not firebaseCache[tostring(player.UserId)] then return end
            
            local head = character:WaitForChild("Head", 5)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if not head then return end
            
            -- Evitar duplicados (Candado seguro)
            for _, gui in ipairs(ScreenGui:GetChildren()) do
                if gui.Name == "BloxyTag_Dynamic" and gui.Adornee == head then return end
            end

            if humanoid then
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
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
            LogoContainer.Position = UDim2.new(0, 0, 0, 0)
            LogoContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
            LogoContainer.BackgroundTransparency = 0.15 
            LogoContainer.ZIndex = 3
            LogoContainer.Active = false
            
            local LogoCorner = Instance.new("UICorner", LogoContainer)
            LogoCorner.CornerRadius = UDim.new(0.25, 0)
            
            local LogoStroke = Instance.new("UIStroke", LogoContainer)
            LogoStroke.Color = Color3.fromRGB(0, 0, 0) 
            LogoStroke.Thickness = 1.2 
            LogoStroke.Transparency = 1 
    
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

            -----------------------------------------------------
            -- SISTEMA DE TELETRANSPORTE AL HACER CLIC
            -----------------------------------------------------
            TagButton.Activated:Connect(function()
                -- EVITA HACER TP A TI MISMO
                if player == LocalPlayer then return end
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
            end)
            -----------------------------------------------------

            local isExpanded = false
            local orbTimer = 0
            -- SOLO EL NOMBRE (Sin la palabra Usuario)
            local displayAliasText = player.DisplayName
            
            RunService.RenderStepped:Connect(function(dt)
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

            task.spawn(function()
                while Billboard and Billboard.Parent do
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

-- Aplicar a jugadores actuales y nuevos
for _, player in ipairs(Players:GetPlayers()) do
    applyTagToPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
    applyTagToPlayer(player)
end)

-- Bucle de comprobación (Tu bucle original adaptado a Firebase)
task.spawn(function()
    while task.wait(2.5) do
        if not ScreenGui or not ScreenGui.Parent then break end
        
        -- Descargar datos reales de Firebase sin caché
        pcall(function()
            local res = game:HttpGet(firebaseUrl .. "?nocache=" .. tostring(math.random(100000, 999999)))
            if res and res ~= "null" then
                firebaseCache = HttpService:JSONDecode(res)
            else
                firebaseCache = {}
            end
        end)
        
        -- Revisar a los jugadores
        for _, player in ipairs(Players:GetPlayers()) do
            local idPlayer = tostring(player.UserId)
            local isFb = (firebaseCache[idPlayer] ~= nil)
            
            -- Si el jugador SÍ está en Firebase, asegurarnos de que tenga tag
            if isFb then 
                if player.Character and player.Character:FindFirstChild("Head") then
                    local hasTag = false
                    for _, child in ipairs(ScreenGui:GetChildren()) do
                        if child.Name == "BloxyTag_Dynamic" and child.Adornee == player.Character.Head then hasTag = true end
                    end
                    if not hasTag then applyTagToPlayer(player) end
                end
            else
                -- Si NO está en Firebase, le borramos el tag visual si lo tiene
                if player.Character and player.Character:FindFirstChild("Head") then
                    for _, child in ipairs(ScreenGui:GetChildren()) do
                        if child.Name == "BloxyTag_Dynamic" and child.Adornee == player.Character.Head then 
                            child:Destroy() 
                        end
                    end
                end
            end
        end
    end
end)
