-- TPS Street Soccer Rayy Hub | FULL & FINAL VERSION
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TabContainer = Instance.new("Frame")
local ContentContainer = Instance.new("Frame")
local UIListLayoutTabs = Instance.new("UIListLayout")

-- [[ OYUN İÇİ DEĞİŞKENLER VE AYARLAR ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Global Ayarlar
_G.ReachEnabled = false
_G.ReachSize = 5 
_G.CurrentReact = "None"
_G.AirDribble = false
_G.InfDribble = false

local AirVelocity = nil

-- Topu Algılama Fonksiyonu
local function GetBall()
    return Workspace:FindFirstChild("Football") or Workspace:FindFirstChild("Ball")
end

-- [[ REACTION PRESET ALTYAPISI ]]
local function ApplyReactPreset(presetName)
    _G.CurrentReact = presetName
    if presetName == "None" then
        settings().Network.IncomingReplicationLag = 0
    elseif presetName == "Alz" then
        settings().Network.IncomingReplicationLag = -0.01 
        _G.ReachSize = 6.5
    elseif presetName == "Abz" then
        settings().Network.IncomingReplicationLag = 0
        _G.ReachSize = 5.8
    elseif presetName == "Tunaz" then
        settings().Network.IncomingReplicationLag = -0.005
        _G.ReachSize = 6.2
    elseif presetName == "Azrael" then
        settings().Network.IncomingReplicationLag = -0.015
        _G.ReachSize = 7.0
    end
end

-- [[ ANA DÖNGÜ (REACH & SKILL HELPERS) ]]
RunService.Heartbeat:Connect(function()
    local ball = GetBall()
    if not ball or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local distance = (hrp.Position - ball.Position).Magnitude

    -- 1. Reach Mekaniği
    if _G.ReachEnabled then
        if distance <= (_G.ReachSize + 10) then
            ball.Size = Vector3.new(_G.ReachSize, _G.ReachSize, _G.ReachSize)
            ball.CanCollide = true 
        end
    else
        if ball.Size.X ~= 3 then
            ball.Size = Vector3.new(3, 3, 3)
        end
    end

    -- 2. Air Dribble Helper Mekaniği
    if _G.AirDribble then
        if distance <= 12 then
            if not ball:FindFirstChild("AirVelocity") then
                AirVelocity = Instance.new("BodyVelocity")
                AirVelocity.Name = "AirVelocity"
                AirVelocity.MaxForce = Vector3.new(450000, 450000, 450000)
                AirVelocity.Parent = ball
            end
            ball.AirVelocity.Velocity = hrp.Velocity + Vector3.new(0, 5, 0)
        end
    else
        if ball:FindFirstChild("AirVelocity") then
            ball.AirVelocity:Destroy()
        end
    end

    -- 3. Infinite Dribble Helper Mekaniği
    if _G.InfDribble then
        if distance <= 8 then
            local targetPos = hrp.Position + (hrp.CFrame.LookVector * 3.5)
            ball.Velocity = hrp.Velocity
            ball.CFrame = CFrame.new(Vector3.new(targetPos.X, ball.Position.Y, targetPos.Z), ball.Position)
        end
    end
end)

-- [[ MISC FONKSİYONLARI ]]
local function DynamicFPSBooster()
    -- Gölgeleri kapatır ve ışıklandırmayı optimize eder
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    -- Haritadaki materyalleri düz renge çevirir (FPS'i uçurur)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

local function StealAvatar(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if targetPlayer and targetPlayer.Character and LocalPlayer.Character then
        -- Mevcut aksesuarları temizle
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
                v:Destroy()
            end
        end
        -- Hedef oyuncunun kıyafetlerini ve aksesuarlarını kopyala
        for _, v in pairs(targetPlayer.Character:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
                local clone = v:Clone()
                clone.Parent = LocalPlayer.Character
            end
        end
        print("Avatar basariyla calindi: " .. targetName)
    else
        print("Oyuncu bulunamadi!")
    end
end

-- [[ UI INITIALIZATION ]]
ScreenGui.Name = "TPSSoccerHub_CustomUI"
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then ScreenGui.Parent = gethui()
else ScreenGui.Parent = game:GetService("CoreGui") end

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.ClipsDescendants = true

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = MainFrame

TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TopBar.Size = UDim2.new(1, 0, 0, 35)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -12, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "TPS STREET SOCCER | GITHUB PRIVATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.Size = UDim2.new(0, 130, 1, -35)

UIListLayoutTabs.Parent = TabContainer
UIListLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutTabs.Padding = UDim.new(0, 4)

ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 140, 0, 45)
ContentContainer.Size = UDim2.new(1, -150, 1, -55)

-- Sürüklenebilir UI
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- UI Sayfa Oluşturucu
local tabs = {}
local function CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    local TabUICorner = Instance.new("UICorner")
    local Page = Instance.new("ScrollingFrame")
    local PageListLayout = Instance.new("UIListLayout")
    
    TabButton.Name = tabName .. "Tab"
    TabButton.Parent = TabContainer
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButton.Size = UDim2.new(1, -10, 0, 32)
    TabButton.Font = Enum.Font.Gotham
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextSize = 12
    
    TabUICorner.CornerRadius = UDim.new(0, 6)
    TabUICorner.Parent = TabButton
    
    Page.Name = tabName .. "Page"
    Page.Parent = ContentContainer
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    PageListLayout.Parent = Page
    PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageListLayout.Padding = UDim.new(0, 6)
    
    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(tabs, {Button = TabButton, Page = Page})
    if #tabs == 1 then Page.Visible = true TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40) TabButton.TextColor3 = Color3.fromRGB(255, 255, 255) end
    return Page
end

-- UI Buton Oluşturucu
local function CreateToggle(page, text, callback)
    local ToggleButton = Instance.new("TextButton")
    local ToggleCorner = Instance.new("UICorner")
    local StatusFrame = Instance.new("Frame")
    local StatusCorner = Instance.new("UICorner")
    local enabled = false
    
    ToggleButton.Parent = page
    ToggleButton.Size = UDim2.new(1, -10, 0, 35)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = "  " .. text
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 12
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleButton
    
    StatusFrame.Parent = ToggleButton
    StatusFrame.Position = UDim2.new(1, -30, 0, 10)
    StatusFrame.Size = UDim2.new(0, 15, 0, 15)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    
    StatusCorner.CornerRadius = UDim.new(0, 4)
    StatusCorner.Parent = StatusFrame
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        StatusFrame.BackgroundColor3 = enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
        callback(enabled)
    end)
end

-- UI TextBox (Yazı Kutusu) Oluşturucu [Avatar Çalma İçin]
local function CreateTextBox(page, placeholder, callback)
    local BoxFrame = Instance.new("Frame")
    local BoxCorner = Instance.new("UICorner")
    local TextBox = Instance.new("TextBox")
    
    BoxFrame.Parent = page
    BoxFrame.Size = UDim2.new(1, -10, 0, 35)
    BoxFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    
    BoxCorner.CornerRadius = UDim.new(0, 5)
    BoxCorner.Parent = BoxFrame
    
    TextBox.Parent = BoxFrame
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Font = Enum.Font.Gotham
    TextBox.PlaceholderText = placeholder
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    TextBox.TextSize = 12
    
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and TextBox.Text ~= "" then
            callback(TextBox.Text)
        end
    end)
end

-- SEKMELERİN TANIMLANMASI
local CombatPage = CreateTab("Combat / React")
local SkillsPage = CreateTab("Skill Helpers")
local MiscPage = CreateTab("Misc")

-- [[ SEKMELERE ÖZELLİKLERİN BAĞLANMASI ]]

-- Combat / React Sayfası
CreateToggle(CombatPage, "Reach Arttirma", function(state)
    _G.ReachEnabled = state
end)

CreateToggle(CombatPage, "Alz React Mode", function(state)
    ApplyReactPreset(state and "Alz" or "None")
end)

CreateToggle(CombatPage, "Abz React Mode", function(state)
    ApplyReactPreset(state and "Abz" or "None")
end)

CreateToggle(CombatPage, "Tunaz React Mode", function(state)
    ApplyReactPreset(state and "Tunaz" or "None")
end)

CreateToggle(CombatPage, "Azrael React Mode", function(state)
    ApplyReactPreset(state and "Azrael" or "None")
end)

-- Skill Helpers Sayfası
CreateToggle(SkillsPage, "Air Dribble Helper", function(state)
    _G.AirDribble = state
end)

CreateToggle(SkillsPage, "Inf Dribble Helper", function(state)
    _G.InfDribble = state
end)

-- Misc Sayfası
CreateTextBox(MiscPage, "Target Username (Press Enter)", function(text)
    StealAvatar(text)
end)

CreateToggle(MiscPage, "FPS Booster", function(state)
    if state then
        DynamicFPSBooster()
    end
end)
veTab = nil

local function CreateTab(tabName)
    local TabButton = Instance.new("TextButton")
    local TabUICorner = Instance.new("UICorner")
    local Page = Instance.new("ScrollingFrame")
    local PageListLayout = Instance.new("UIListLayout")
    
    -- Sekme Butonu
    TabButton.Name = tabName .. "Tab"
    TabButton.Parent = TabContainer
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButton.Size = UDim2.new(1, -10, 0, 32)
    TabButton.Font = Enum.Font.Gotham
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextSize = 12
    
    TabUICorner.CornerRadius = UDim.new(0, 6)
    TabUICorner.Parent = TabButton
    
    -- Sekme İçerik Sayfası
    Page.Name = tabName .. "Page"
    Page.Parent = ContentContainer
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    PageListLayout.Parent = Page
    PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageListLayout.Padding = UDim.new(0, 6)
    
    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(tabs, {Button = TabButton, Page = Page})
    if #tabs == 1 then
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    return Page
end

-- Element Yardımcı Fonksiyonu (Toggle Oluşturucu)
local function CreateToggle(page, text, callback)
    local ToggleButton = Instance.new("TextButton")
    local ToggleCorner = Instance.new("UICorner")
    local StatusFrame = Instance.new("Frame")
    local StatusCorner = Instance.new("UICorner")
    local enabled = false
    
    ToggleButton.Parent = page
    ToggleButton.Size = UDim2.new(1, -10, 0, 35)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    ToggleButton.Font = Enum.Font.Gotham
    ToggleButton.Text = "  " .. text
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 12
    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
    
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleButton
    
    StatusFrame.Parent = ToggleButton
    StatusFrame.Position = UDim2.new(1, -30, 0, 10)
    StatusFrame.Size = UDim2.new(0, 15, 0, 15)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    
    StatusCorner.CornerRadius = UDim.new(0, 4)
    StatusCorner.Parent = StatusFrame
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            StatusFrame.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        else
            StatusFrame.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
        callback(enabled)
    end)
end

-- SEKMELERİ OLUŞTURMA
local CombatPage = CreateTab("Combat / React")
local SkillsPage = CreateTab("Skill Helpers")
local MiscPage = CreateTab("Misc")

-- [[ ÖZELLİKLER VE AYARLAR ]]

-- 1. Reach Ayarı Altyapısı
CreateToggle(CombatPage, "Reach Arttirma", function(state)
    _G.ReachEnabled = state
    if state then
        print("Reach Aktif")
        -- Top algılama ve hitbox genişletme kodları buraya gelecek
    else
        print("Reach Kapatildi")
    end
end)

-- 2. Oyuncu Presetleri (Alz, Abz, Tunaz, Azrael)
-- Sırayla tetiklenebilmesi için basit tıklama butonları ekledik
CreateToggle(CombatPage, "Alz React Mode", function(state)
    if state then print("Alz React Preseti Aktif") end
end)

CreateToggle(CombatPage, "Abz React Mode", function(state)
    if state then print("Abz React Preseti Aktif") end
end)

CreateToggle(CombatPage, "Tunaz React Mode", function(state)
    if state then print("Tunaz React Preseti Aktif") end
end)

CreateToggle(CombatPage, "Azrael React Mode", function(state)
    if state then print("Azrael React Preseti Aktif") end
end)

-- 3. Skill Helpers
CreateToggle(SkillsPage, "Air Dribble Helper", function(state)
    _G.AirDribble = state
    if state then print("Air Dribble Helper Acildi") end
end)

CreateToggle(SkillsPage, "Inf Dribble Helper", function(state)
    _G.InfDribble = state
    if state then print("Inf Dribble Helper Acildi") end
end)

-- 4. Misc Kategorisi
CreateToggle(MiscPage, "FPS Booster", function(state)
    if state then
        print("FPS Booster Calistirildi")
        -- Gereksiz efektleri ve gölgeleri silme döngüsü buraya entegre edilecek
    end
end)

