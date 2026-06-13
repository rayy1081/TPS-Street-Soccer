-- TPS Street Soccer Rayy Hub
-- Güncellenmiş Sürüm (Kategoriler Ayrıldı)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local TabContainer = Instance.new("Frame")
local ContentContainer = Instance.new("Frame")
local UIListLayoutTabs = Instance.new("UIListLayout")

-- Delta / CoreGui Uyumluluğu
ScreenGui.Name = "TPSSoccerHub_CustomUI"
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = game:GetService("CoreGui")
end

-- Ana Panel
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.ClipsDescendants = true

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = MainFrame

-- Üst Bar
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
Title.Text = "TPS STREET SOCCER | PRIVATE HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Sol Sekme Paneli
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.Size = UDim2.new(0, 130, 1, -35)

UIListLayoutTabs.Parent = TabContainer
UIListLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutTabs.Padding = UDim.new(0, 4)

-- Sağ İçerik Paneli
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 140, 0, 45)
ContentContainer.Size = UDim2.new(1, -150, 1, -55)

-- Sürükleme Sistemi
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [[ SEKMELER VE ELEMENTLERİN OLUŞTURULMASI ]]
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
    TabButton.TextSize = 11
    
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
    if #tabs == 1 then
        Page.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    return Page
end

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

-- YENİ AYRILMIŞ SEKMELER
local ReachPage = CreateTab("Reach Options")
local ReactPage = CreateTab("React Presets")
local SkillsPage = CreateTab("Skill Helpers")
local MiscPage = CreateTab("Misc")

-- [[ 1. REACH KATEGORİSİ ]]
CreateToggle(ReachPage, "Reach Hack (Aktif/Pasif)", function(state)
    _G.ReachEnabled = state
    if state then print("Reach Sistemi Devrede") else print("Reach Sistemi Kapatildi") end
end)

-- [[ 2. REACT PRESETS KATEGORİSİ ]]
CreateToggle(ReactPage, "Alz React Mode", function(state)
    _G.AlzReact = state
end)

CreateToggle(ReactPage, "Abz React Mode", function(state)
    _G.AbzReact = state
end)

CreateToggle(ReactPage, "Tunaz React Mode", function(state)
    _G.TunazReact = state
end)

CreateToggle(ReactPage, "Azrael React Mode", function(state)
    _G.AzraelReact = state
end)

-- [[ 3. SKILL HELPERS KATEGORİSİ ]]
CreateToggle(SkillsPage, "Air Dribble Helper", function(state)
    _G.AirDribble = state
end)

CreateToggle(SkillsPage, "Inf Dribble Helper", function(state)
    _G.InfDribble = state
end)

-- [[ 4. MISC KATEGORİSİ ]]
CreateToggle(MiscPage, "FPS Booster", function(state)
    -- FPS yükseltme kodu buraya gelecek
end)
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

-- Sol Sekme Paneli (Tab Container)
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.Size = UDim2.new(0, 130, 1, -35)

UIListLayoutTabs.Parent = TabContainer
UIListLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayoutTabs.Padding = UDim.new(0, 4)

-- Sağ İçerik Paneli (Content Container)
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 140, 0, 45)
ContentContainer.Size = UDim2.new(1, -150, 1, -55)

-- Sürüklenebilirlik Özelliği (Mobil ve Delta İçin Optimize)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [[ SEKMELER VE ELEMENTLERİN OLUŞTURULMASI ]]

local tabs = {}
local activeTab = nil

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

