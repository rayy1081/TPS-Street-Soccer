-- TPS Street Soccer | Delta Executor
local _G0 = game:GetService("Players")
local _G1 = game:GetService("RunService")
local _G2 = game:GetService("UserInputService")
local _G3 = game:GetService("TweenService")
local _G4 = game:GetService("Lighting")
local _G5 = game:GetService("StarterGui")

local LP = _G0.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- Execute log (Discord webhook)
task.spawn(function()
    pcall(function()
        local HS = game:GetService("HttpService")
        local age = LP.AccountAge
        local createdYear  = os.date("*t", os.time() - age * 86400)
        local createdStr   = string.format("%02d/%02d/%04d", createdYear.day, createdYear.month, createdYear.year)
        local memberTypes  = w{[0]="None",[1]="BuildersClub",[2]="TurboBuildersClub",[3]="OutrageousBuildersClub",[4]="Premium"}
        local memberStr    = memberTypes[LP.MembershipType.Value] or tostring(LP.MembershipType)
        local thumbUrl     = "https://www.roblox.com/headshot-thumbnail/image?userId="..LP.UserId.."&width=150&height=150&format=png"

        local payload = HS:JSONEncode({
            embeds = {{
                title   = "🟢 Script Executed",
                color   = 3066993,
                thumbnail = {url = thumbUrl},
                fields  = {
                    {name="👤 Username",      value=LP.Name,              inline=true},
                    {name="🏷️ Display Name",  value=LP.DisplayName,       inline=true},
                    {name="🆔 User ID",        value=tostring(LP.UserId),  inline=true},
                    {name="📅 Account Created",value=createdStr,           inline=true},
                    {name="⏳ Account Age",    value=tostring(age).." days",inline=true},
                    {name="💎 Membership",     value=memberStr,            inline=true},
                },
                footer  = {text="OREO MENU | TPS Street Soccer"},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })

        local fn = (typeof(request)=="function" and request)
                or (typeof(http_request)=="function" and http_request)
                or (syn and syn.request)
                or nil
        if fn then
            fn({
                Url     = "https://discord.com/api/webhooks/1515676907138453625/mIYSL2056ZTeJRzyruCdDbDS6AIFSEUE3ZfcA59j45adYxneBaD5XaIyl8fUx9BEZNM3",
                Method  = "POST",
                Headers = {["Content-Type"]="application/json"},
                Body    = payload,
            })
        end
    end)
end)

-- Bypass: indirect firetouchinterest reference
local _fti = pcall(function() return firetouchinterest end) and firetouchinterest or nil
local function _touch(a, b)
    if not _fti then return end
    pcall(_fti, a, b, 0)
    task.wait(0.01 + math.random() * 0.005)
    pcall(_fti, a, b, 1)
end

-- Bypass: random GUI name (different each execute)
math.randomseed(tick())
local _gname = "UI_" .. tostring(math.random(10000, 99999))

-- Character
local Char, HRP, Hum
local function RefChar()
    Char = LP.Character
    if not Char then return end
    HRP = Char:FindFirstChild("HumanoidRootPart")
    Hum = Char:FindFirstChildOfClass("Humanoid")
end
RefChar()
LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    Char = c
    HRP  = c:WaitForChild("HumanoidRootPart")
    Hum  = c:WaitForChild("Humanoid")
    _lastLeg = 0 _lastMoss = 0 _lastR15 = 0 _lastBall = 0
end)

-- Settings
local S = {
    LegOn=false,  LX=5, LY=5, LZ=5,  LHB=false,
    MossOn=false, MX=5, MY=5, MZ=5,  MHB=false,
    BallOn=false, BX=5, BY=5, BZ=5,  BHB=false,
    R15On=false,  RX=5, RY=5, RZ=5,
    React="",
    FPS=false, Bright=false, Fog=false, IJ=false,
    BallTp=false,
}

-- Find Ball
local function GetBall()
    local sys = workspace:FindFirstChild("TPSSystem")
    if sys then
        local t = sys:FindFirstChild("TPS")
        if t then return t end
    end
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n=="tps" or n:find("ball") or n:find("soccer") then return v end
        end
    end
end

-- Preferred foot
local function GetLeg(char, hum)
    if not char or not hum then return end
    local lit  = _G4:FindFirstChild(LP.Name)
    local pref = lit and lit:FindFirstChild("PreferredFoot")
    local R    = pref and (pref.Value == 1)
    if hum.RigType == Enum.HumanoidRigType.R6 then
        return R and char:FindFirstChild("Right Leg") or char:FindFirstChild("Left Leg")
    else
        return R and char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("LeftLowerLeg")
    end
end

-- Cooldown: based on ball speed + small jitter (bypass)
local function KickCD(ball)
    local ok, spd = pcall(function() return ball.AssemblyLinearVelocity.Magnitude end)
    if not ok then spd = 0 end
    local base = spd < 6 and 0.035 or (spd > 16 and 0.07 or 0.05)
    return base + math.random() * 0.012
end

_lastLeg = 0 _lastMoss = 0 _lastR15 = 0 _lastBall = 0

-- ── Hitbox Parts (semi-transparent, Delta compatible) ───────
local _hbFolder = Instance.new("Folder")
_hbFolder.Name = "OREO_Hitboxes"
_hbFolder.Parent = workspace

local function MkHitbox(col)
    local p
    pcall(function()
        p = Instance.new("Part")
        p.Shape        = Enum.PartType.Ball
        p.Color        = col
        p.Transparency = 0.78
        p.CanCollide   = false
        p.Anchored     = true
        p.Name         = "HB"
        pcall(function() p.Material = Enum.Material.Neon end)
        pcall(function() p.CastShadow = false end)
        pcall(function() p.CanQuery  = false end)
    end)
    return p
end

local legHB  = MkHitbox(Color3.fromRGB(90, 150, 255))   -- blue
local mossHB = MkHitbox(Color3.fromRGB(80, 220, 110))   -- green
local ballHB = MkHitbox(Color3.fromRGB(255, 200, 50))   -- yellow

local function SetHB(part, show, size, pos)
    if not part then return end
    pcall(function()
        if show then
            part.Size   = Vector3.new(size, size, size)
            part.CFrame = CFrame.new(pos)
            part.Parent = _hbFolder
        else
            part.Parent = nil
        end
    end)
end

local function UpdateHitboxes()
    if not Char or not HRP then
        SetHB(legHB,  false) SetHB(mossHB, false) SetHB(ballHB, false) return
    end
    -- Leg Hitbox
    do
        local r = 2 + S.LX * 0.8 + S.LZ * 0.5
        local leg = GetLeg(Char, Hum)
        local pos = (leg and leg.Position) or HRP.Position
        SetHB(legHB, S.LHB and S.LegOn, r * 2, pos)
    end
    -- Moss (Head) Hitbox
    do
        local r = 2 + S.MX * 0.8 + S.MZ * 0.5
        local head = Char:FindFirstChild("Head")
        local pos = (head and head.Position) or HRP.Position
        SetHB(mossHB, S.MHB and S.MossOn, r * 2, pos)
    end
    -- Ball Reach Hitbox
    do
        local r = 2 + S.BX * 0.8 + S.BZ * 0.5
        SetHB(ballHB, S.BHB and S.BallOn, r * 2, HRP.Position)
    end
end

-- ── Main Reach Loop ────────────────────────────────────────
_G1.RenderStepped:Connect(function()
    if not Char or not HRP or not Hum then return end
    local ball = GetBall() if not ball then return end
    local now  = tick()

    if S.LegOn then
        local d = (HRP.Position - ball.Position).Magnitude
        local r = 2 + S.LX * 0.8 + S.LZ * 0.5
        if d <= r and (now - _lastLeg) >= KickCD(ball) then
            local leg = GetLeg(Char, Hum)
            if leg then _touch(leg, ball) end
            _lastLeg = now
        end
    end

    if S.MossOn then
        local head = Char:FindFirstChild("Head")
        if head then
            local d = (head.Position - ball.Position).Magnitude
            local r = 2 + S.MX * 0.8 + S.MZ * 0.5
            if d <= r and (now - _lastMoss) >= KickCD(ball) then
                _touch(head, ball)
                _lastMoss = now
            end
        end
    end

    if S.BallOn then
        local d = (HRP.Position - ball.Position).Magnitude
        local r = 2 + S.BX * 0.8 + S.BZ * 0.5
        if d <= r and (now - _lastBall) >= KickCD(ball) then
            _touch(HRP, ball)
            _lastBall = now
        end
    end

    if S.R15On then
        local d = (HRP.Position - ball.Position).Magnitude
        local r = 2 + S.RX * 0.8 + S.RZ * 0.5
        if d <= r and (now - _lastR15) >= KickCD(ball) then
            local leg = GetLeg(Char, Hum)
            if leg then _touch(leg, ball) end
            _lastR15 = now
        end
    end

end)

-- Hitbox güncelleme: top varlığından bağımsız, her frame
_G1.RenderStepped:Connect(function()
    UpdateHitboxes()
end)

-- ── React: firetouchinterest based (like reference script) ──
local RD = {
    Rayy    = {range=2.0},
    Jinx    = {range=1.8},
    Azrael  = {range=2.5},
    Tunaz   = {range=3.0},
    Abzzy   = {range=1.5},
    ["4v0"] = {range=2.2},
    Apz     = {range=2.8},
    Alonezz = {range=1.6},
    Alzzy   = {range=3.2},
    Foxtede = {range=2.4},
}
local _rLast = 0
_G1.RenderStepped:Connect(function()
    if S.React == "" or not Char or not HRP or not Hum then return end
    local def = RD[S.React] if not def then return end
    local ball = GetBall() if not ball then return end
    local now  = tick()
    local dist = (HRP.Position - ball.Position).Magnitude
    if dist <= def.range and (now - _rLast) >= KickCD(ball) then
        local leg = GetLeg(Char, Hum)
        if leg then _touch(leg, ball) end
        _rLast = now
    end
end)

-- Infinite jump
local _ijC
local function ApplyIJ(v)
    if _ijC then _ijC:Disconnect() end
    if v then _ijC = _G2.JumpRequest:Connect(function()
        if Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end) end
end

-- ═══════════════════════════════════════════════
--              K E Y   S Y S T E M
-- ═══════════════════════════════════════════════

local _keyValid    = false
local _cacheFile   = "oreo_key.txt"
local _linkvertise = "YOUR_LINKVERTISE_LINK_HERE"   -- buraya kendi Linkvertise linkini yaz
local _keyUrl      = "https://oreohub--swcaptan.replit.app/key"
local _genv        = getgenv and getgenv() or _G
local _fetchedKey  = ""   -- URL'den çekilen güncel key

-- URL'den güncel keyi çek
local function FetchKey()
    local ok, res = pcall(function()
        local fn = (type(request)=="function" and request)
                or (type(http_request)=="function" and http_request)
                or nil
        if not fn then return "" end
        local r = fn({Url=_keyUrl, Method="GET"})
        return r and r.Body and r.Body:gsub("%s","") or ""
    end)
    return ok and res or ""
end

-- Cache oku: dosya formatı = "KEY;TIMESTAMP"
local function ReadCache()
    local paths = {_cacheFile, "workspace/" .. _cacheFile}
    for _, p in ipairs(paths) do
        local ok, data = pcall(function() return readfile(p) end)
        if ok and data and data ~= "" then
            local k, t = data:match("^(.+);(%d+)$")
            if k and t then return k, tonumber(t) end
        end
    end
    return nil, 0
end

local function SaveCache(key)
    _genv["__oreo_key"]    = key
    _genv["__oreo_key_ts"] = os.time()
    local content = key .. ";" .. tostring(os.time())
    local paths = {_cacheFile, "workspace/" .. _cacheFile}
    for _, p in ipairs(paths) do
        pcall(function() writefile(p, content) end)
    end
end

local function CheckCache(validKey)
    -- 1) getgenv: aynı oturumda, 24 saat dolmamışsa
    if _genv["__oreo_key"] == validKey
    and _genv["__oreo_key_ts"]
    and (os.time() - _genv["__oreo_key_ts"]) < 86400 then
        return true
    end
    -- 2) Dosya cache: 24 saat dolmamışsa
    local k, t = ReadCache()
    if k == validKey and (os.time() - t) < 86400 then
        _genv["__oreo_key"]    = k
        _genv["__oreo_key_ts"] = t
        return true
    end
    return false
end

-- URL'den güncel keyi çek, önce cache'i kontrol et
_fetchedKey = FetchKey()
if _fetchedKey ~= "" and CheckCache(_fetchedKey) then
    _keyValid = true
elseif _fetchedKey == "" then
    -- URL'ye ulaşılamadı: eski cache varsa geçerli say (offline tolerans)
    local k, t = ReadCache()
    if k and k ~= "" and (os.time() - t) < 172800 then -- 48 saat offline tolerans
        _fetchedKey = k
        _keyValid = true
    end
end

if not _keyValid then
    local KSG = Instance.new("ScreenGui")
    KSG.Name = "OREO_Key" KSG.ResetOnSpawn = false KSG.IgnoreGuiInset = true
    KSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling KSG.Parent = PG

    -- Dim overlay
    local dim = Instance.new("Frame")
    dim.Size = UDim2.new(1,0,1,0) dim.BackgroundColor3 = Color3.fromRGB(0,0,0)
    dim.BackgroundTransparency = 0.45 dim.BorderSizePixel = 0 dim.Parent = KSG

    -- Key card
    local KC = Instance.new("Frame")
    KC.Size = UDim2.new(0,360,0,210) KC.Position = UDim2.new(0.5,-180,0.5,-105)
    KC.BackgroundColor3 = Color3.fromRGB(20,20,20) KC.BorderSizePixel = 0 KC.Parent = KSG
    Instance.new("UICorner",KC).CornerRadius = UDim.new(0,12)

    -- Header
    local KH = Instance.new("Frame")
    KH.Size = UDim2.new(1,0,0,40) KH.BackgroundColor3 = Color3.fromRGB(14,14,14)
    KH.BorderSizePixel = 0 KH.Parent = KC
    Instance.new("UICorner",KH).CornerRadius = UDim.new(0,12)
    local KHCover = Instance.new("Frame")
    KHCover.Size = UDim2.new(1,0,0,14) KHCover.Position = UDim2.new(0,0,1,-14)
    KHCover.BackgroundColor3 = Color3.fromRGB(14,14,14) KHCover.BorderSizePixel=0 KHCover.Parent=KH
    local KHT = Instance.new("TextLabel")
    KHT.Text = "🔑  OREO MENU — Key System"
    KHT.Size = UDim2.new(1,0,1,0) KHT.BackgroundTransparency = 1 KHT.BorderSizePixel = 0
    KHT.TextColor3 = Color3.fromRGB(230,230,230) KHT.Font = Enum.Font.GothamBold
    KHT.TextSize = 13 KHT.Parent = KH

    -- Info
    local KI = Instance.new("TextLabel")
    KI.Text = "Get your key from Linkvertise below.\nKey is refreshed automatically. You only need to enter it once per day."
    KI.Size = UDim2.new(1,-20,0,38) KI.Position = UDim2.new(0,10,0,48)
    KI.BackgroundTransparency = 1 KI.BorderSizePixel = 0
    KI.TextColor3 = Color3.fromRGB(110,110,110) KI.Font = Enum.Font.Gotham
    KI.TextSize = 11 KI.TextWrapped = true KI.Parent = KC

    -- Linkvertise button (display only — Roblox can't open URLs)
    local KLB = Instance.new("TextButton")
    KLB.Text = "🔗  Get Key — Linkvertise"
    KLB.Size = UDim2.new(1,-20,0,28) KLB.Position = UDim2.new(0,10,0,92)
    KLB.BackgroundColor3 = Color3.fromRGB(88,101,242) KLB.BorderSizePixel = 0
    KLB.TextColor3 = Color3.fromRGB(255,255,255) KLB.Font = Enum.Font.GothamBold
    KLB.TextSize = 12 KLB.Parent = KC
    Instance.new("UICorner",KLB).CornerRadius = UDim.new(0,7)
    KLB.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(_linkvertise) end)
        KLB.Text = "✓  Link Kopyalandı!"
        task.delay(2, function() KLB.Text = "🔗  Get Key — Linkvertise" end)
    end)

    -- Input row
    local KTB = Instance.new("TextBox")
    KTB.Size = UDim2.new(1,-108,0,30) KTB.Position = UDim2.new(0,10,0,130)
    KTB.BackgroundColor3 = Color3.fromRGB(35,35,35) KTB.BorderSizePixel = 0
    KTB.Text = "" KTB.TextColor3 = Color3.fromRGB(230,230,230)
    KTB.Font = Enum.Font.Gotham KTB.TextSize = 12
    KTB.PlaceholderText = "Enter key from Linkvertise..." KTB.PlaceholderColor3 = Color3.fromRGB(70,70,70)
    KTB.ClearTextOnFocus = false KTB.Parent = KC
    Instance.new("UICorner",KTB).CornerRadius = UDim.new(0,6)

    local KOK = Instance.new("TextButton")
    KOK.Text = "Confirm" KOK.Size = UDim2.new(0,88,0,30) KOK.Position = UDim2.new(1,-98,0,130)
    KOK.BackgroundColor3 = Color3.fromRGB(90,150,255) KOK.BorderSizePixel = 0
    KOK.TextColor3 = Color3.fromRGB(255,255,255) KOK.Font = Enum.Font.GothamBold
    KOK.TextSize = 12 KOK.Parent = KC
    Instance.new("UICorner",KOK).CornerRadius = UDim.new(0,6)

    -- Status
    local KST = Instance.new("TextLabel")
    KST.Text = "" KST.Size = UDim2.new(1,-20,0,18) KST.Position = UDim2.new(0,10,0,168)
    KST.BackgroundTransparency = 1 KST.BorderSizePixel = 0
    KST.TextColor3 = Color3.fromRGB(200,60,60) KST.Font = Enum.Font.GothamBold
    KST.TextSize = 11 KST.TextXAlignment = Enum.TextXAlignment.Center KST.Parent = KC

    local function TryKey()
        local entered = KTB.Text:gsub("%s","")
        local valid   = _fetchedKey ~= "" and _fetchedKey or nil
        if not valid then
            KST.Text = "! Could not reach key server. Try again."
            task.delay(3, function() KST.Text = "" end)
            return
        end
        if entered == valid then
            SaveCache(valid)
            _keyValid = true
            KSG:Destroy()
        else
            KST.Text = "! Invalid key — get it from Linkvertise"
            KTB.Text = ""
            task.delay(3, function() KST.Text = "" end)
        end
    end

    KOK.MouseButton1Click:Connect(TryKey)
    KTB.FocusLost:Connect(function(enter) if enter then TryKey() end end)

    -- Block until valid
    repeat task.wait(0.1) until _keyValid
end

-- ═══════════════════════════════════════════════
--                  G U I
-- ═══════════════════════════════════════════════

-- Clear old GUIs
for _,g in pairs(PG:GetChildren()) do
    if g:IsA("ScreenGui") and g.Name:sub(1,3)=="UI_" then g:Destroy() end
end

local SG = Instance.new("ScreenGui")
SG.Name = _gname
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = PG

-- Colors
local BG   = Color3.fromRGB(20,20,20)
local SBC  = Color3.fromRGB(14,14,14)
local CONT = Color3.fromRGB(26,26,26)
local ACC  = Color3.fromRGB(90,150,255)
local TXT  = Color3.fromRGB(230,230,230)
local DIM  = Color3.fromRGB(120,120,120)
local TON  = Color3.fromRGB(60,195,90)
local TOFF = Color3.fromRGB(50,50,50)
local WH   = Color3.fromRGB(255,255,255)
local BOX  = Color3.fromRGB(35,35,35)
local SLB  = Color3.fromRGB(45,45,45)
local RED  = Color3.fromRGB(200,50,50)
local DISC = Color3.fromRGB(88,101,242)
local YTBC = Color3.fromRGB(220,40,40)
local YELL = Color3.fromRGB(255,200,50)

local function MkF(p,a)
    local f=Instance.new("Frame") f.BorderSizePixel=0
    for k,v in pairs(a or {}) do pcall(function()f[k]=v end) end
    f.Parent=p return f
end
local function MkL(p,a)
    local l=Instance.new("TextLabel") l.BorderSizePixel=0 l.BackgroundTransparency=1
    for k,v in pairs(a or {}) do pcall(function()l[k]=v end) end
    l.Parent=p return l
end
local function MkB(p,a)
    local b=Instance.new("TextButton") b.BorderSizePixel=0
    for k,v in pairs(a or {}) do pcall(function()b[k]=v end) end
    b.Parent=p return b
end
local function Rnd(o,r) local u=Instance.new("UICorner") u.CornerRadius=UDim.new(0,r) u.Parent=o end
local function Tw(o,pr,t) _G3:Create(o,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad),pr):Play() end

-- ── Main Window ───────────────────────────────
local Win = MkF(SG, {
    Size     = UDim2.new(0, 500, 0, 310),
    Position = UDim2.new(0.5, -250, 0.5, -155),
    BackgroundColor3 = BG,
    Active   = true,
})
Rnd(Win, 10)

-- ── Title Bar ────────────────────────────────
local TitleBar = MkF(Win, {
    Size             = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = SBC,
})
Rnd(TitleBar, 10)
MkF(TitleBar, {
    Size             = UDim2.new(1, 0, 0, 12),
    Position         = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = SBC,
})

local TitleLbl = MkL(TitleBar, {
    Text      = "OREO MENU - Home",
    Size      = UDim2.new(1, -70, 1, 0),
    Position  = UDim2.new(0, 35, 0, 0),
    TextColor3 = TXT,
    Font      = Enum.Font.GothamBold,
    TextSize  = 14,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex    = 2,
})

-- Close button
local CB = MkB(TitleBar, {
    Size             = UDim2.new(0, 26, 0, 26),
    Position         = UDim2.new(1, -32, 0.5, -13),
    BackgroundColor3 = RED,
    Text             = "✕",
    TextColor3       = WH,
    Font             = Enum.Font.GothamBold,
    TextSize         = 12,
    ZIndex           = 3,
})
Rnd(CB, 6)
local shown = true
CB.MouseButton1Click:Connect(function()
    shown = not shown Win.Visible = shown
end)

-- Drag (title bar)
do
    local drag, ds, sp = false
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true ds=i.Position sp=Win.Position
        end
    end)
    _G2.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds Win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    _G2.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- ── Sidebar ───────────────────────────────────
local SBar = MkF(Win, {
    Size             = UDim2.new(0, 110, 1, -34),
    Position         = UDim2.new(0, 0, 0, 34),
    BackgroundColor3 = SBC,
})
MkF(SBar, {Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=Color3.fromRGB(40,40,40)})

-- ── Content Panel ─────────────────────────────
local CPan = MkF(Win, {
    Size             = UDim2.new(1, -110, 1, -34),
    Position         = UDim2.new(0, 110, 0, 34),
    BackgroundColor3 = CONT,
})
local Scr = Instance.new("ScrollingFrame")
Scr.Size                = UDim2.new(1,0,1,0)
Scr.BackgroundTransparency = 1
Scr.BorderSizePixel     = 0
Scr.ScrollBarThickness  = 3
Scr.ScrollBarImageColor3 = ACC
Scr.CanvasSize          = UDim2.new(0,0,0,1600)
Scr.ScrollingDirection  = Enum.ScrollingDirection.Y
Scr.Parent              = CPan
local Con = MkF(Scr, {Size=UDim2.new(1,-6,0,1600),BackgroundTransparency=1})

-- Y position tracker
local cY = 14
local function NY(h, g) local y=cY cY=cY+h+(g or 8) return y end

-- UI Components
local function MkSec(txt)
    local y = NY(22, 6)
    local f = MkF(Con, {Size=UDim2.new(1,-24,0,22),Position=UDim2.new(0,12,0,y),BackgroundTransparency=1})
    MkL(f, {Text=txt:upper(),Size=UDim2.new(1,0,1,0),TextColor3=ACC,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left})
    MkF(f, {Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=ACC,BackgroundTransparency=0.6})
end

local function MkTog(txt, init, cb)
    local y = NY(42, 6)
    local bx = MkF(Con, {Size=UDim2.new(1,-24,0,42),Position=UDim2.new(0,12,0,y),BackgroundColor3=BOX})
    Rnd(bx, 10)
    MkF(bx, {Size=UDim2.new(0,3,0.5,0),Position=UDim2.new(0,0,0.25,0),BackgroundColor3=ACC,BackgroundTransparency=0.3})
    MkL(bx, {Text=txt,Size=UDim2.new(1,-64,1,0),Position=UDim2.new(0,14,0,0),TextColor3=TXT,Font=Enum.Font.GothamSemibold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
    local TW,TH = 46,26
    local trk = MkF(bx, {Size=UDim2.new(0,TW,0,TH),Position=UDim2.new(1,-(TW+10),0.5,-TH/2),BackgroundColor3=init and TON or TOFF})
    Rnd(trk, 13)
    local KS = 20
    local knob = MkF(trk, {Size=UDim2.new(0,KS,0,KS),Position=init and UDim2.new(0,TW-KS-3,0.5,-KS/2) or UDim2.new(0,3,0.5,-KS/2),BackgroundColor3=WH})
    Rnd(knob, 10)
    local st = init
    MkB(bx, {Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""}).MouseButton1Click:Connect(function()
        st = not st
        Tw(trk,  {BackgroundColor3=st and TON or TOFF})
        Tw(knob, {Position=st and UDim2.new(0,TW-KS-3,0.5,-KS/2) or UDim2.new(0,3,0.5,-KS/2)})
        cb(st)
    end)
end

local function MkSld(txt, mn, mx, ini, cb)
    local y = NY(64, 6)
    local bx = MkF(Con, {Size=UDim2.new(1,-24,0,64),Position=UDim2.new(0,12,0,y),BackgroundColor3=BOX})
    Rnd(bx, 10)
    MkF(bx, {Size=UDim2.new(0,3,0.5,0),Position=UDim2.new(0,0,0.25,0),BackgroundColor3=ACC,BackgroundTransparency=0.3})
    MkL(bx, {Text=txt,Size=UDim2.new(0.65,0,0,22),Position=UDim2.new(0,14,0,9),TextColor3=TXT,Font=Enum.Font.GothamSemibold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
    local vl = MkL(bx, {Text=tostring(ini),Size=UDim2.new(0.3,-4,0,22),Position=UDim2.new(0.7,0,0,9),TextColor3=ACC,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Right})
    local sbg = MkF(bx, {Size=UDim2.new(1,-28,0,6),Position=UDim2.new(0,14,0,44),BackgroundColor3=SLB})
    Rnd(sbg, 3)
    local p0 = (ini-mn)/(mx-mn)
    local fill = MkF(sbg, {Size=UDim2.new(p0,0,1,0),BackgroundColor3=ACC}) Rnd(fill,3)
    local kn   = MkF(sbg, {Size=UDim2.new(0,16,0,16),Position=UDim2.new(p0,-8,0.5,-8),BackgroundColor3=WH}) Rnd(kn,8)
    local drag = false
    local function upd(x)
        local p = math.clamp((x-sbg.AbsolutePosition.X)/sbg.AbsoluteSize.X,0,1)
        local v = math.floor((mn+(mx-mn)*p)*2+0.5)/2
        local ps = (v-mn)/(mx-mn)
        fill.Size=UDim2.new(ps,0,1,0) kn.Position=UDim2.new(ps,-8,0.5,-8)
        vl.Text = (v == math.floor(v)) and tostring(math.floor(v)) or tostring(v)
        cb(v)
    end
    sbg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true upd(i.Position.X) end
    end)
    _G2.InputChanged:Connect(function(i)
        if drag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end
    end)
    _G2.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

-- ── Tab System ────────────────────────────────
local Tabs   = {}
local CurTab = nil
local sbY    = 6

local function RegTab(name, bld)
    local btn = MkB(SBar, {
        Size             = UDim2.new(1, 0, 0, 34),
        Position         = UDim2.new(0, 0, 0, sbY),
        BackgroundColor3 = SBC,
        Text             = name,
        TextColor3       = DIM,
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
    })
    sbY = sbY + 35
    Tabs[name] = {btn=btn, bld=bld}

    btn.MouseButton1Click:Connect(function()
        if CurTab == name then return end
        if CurTab and Tabs[CurTab] then
            Tw(Tabs[CurTab].btn, {BackgroundColor3=SBC, TextColor3=DIM})
        end
        CurTab = name
        TitleLbl.Text = "OREO MENU - " .. name
        Tw(btn, {BackgroundColor3=Color3.fromRGB(30,30,30), TextColor3=TXT})
        for _,ch in pairs(Con:GetChildren()) do
            if not ch:IsA("UIPadding") then ch:Destroy() end
        end
        cY = 12
        Scr.CanvasPosition = Vector2.new(0,0)
        bld()
    end)
    btn.MouseEnter:Connect(function() if CurTab~=name then Tw(btn,{BackgroundColor3=Color3.fromRGB(22,22,22)}) end end)
    btn.MouseLeave:Connect(function() if CurTab~=name then Tw(btn,{BackgroundColor3=SBC}) end end)
end

-- ═══ TAB CONTENTS ═══════════════════════════════

-- HOME
local function BldHome()
    local ay = NY(80, 6)
    local av = Instance.new("ImageLabel")
    av.Size             = UDim2.new(0,72,0,72)
    av.Position         = UDim2.new(0.5,-36,0,ay)
    av.BackgroundColor3 = Color3.fromRGB(80,80,80)
    av.BorderSizePixel  = 0
    av.Image            = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"
    av.Parent           = Con
    Rnd(av, 36)

    local oy = NY(22, 8)
    MkL(Con, {
        Text      = "Owner: Rayy",
        Size      = UDim2.new(1,-20,0,22),
        Position  = UDim2.new(0,10,0,oy),
        TextColor3 = TXT,
        Font      = Enum.Font.GothamBold,
        TextSize  = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local socs = {
        {"D", "Discord Server",  DISC},
        {"Y", "Youtube Channel", YTBC},
    }
    for _, s in ipairs(socs) do
        local sy = NY(46, 6)
        local bx = MkB(Con, {
            Size             = UDim2.new(1,-20,0,46),
            Position         = UDim2.new(0,10,0,sy),
            BackgroundColor3 = BOX,
            Text             = "",
        })
        Rnd(bx, 8)
        local lbox = MkF(bx, {
            Size             = UDim2.new(0,46,1,0),
            BackgroundColor3 = Color3.fromRGB(28,28,28),
        })
        Rnd(lbox, 8)
        MkF(lbox, {Size=UDim2.new(0,6,1,0),Position=UDim2.new(1,-6,0,0),BackgroundColor3=Color3.fromRGB(28,28,28)})
        MkL(lbox, {
            Text      = s[1],
            Size      = UDim2.new(1,0,1,0),
            TextColor3 = s[3],
            Font      = Enum.Font.GothamBold,
            TextSize  = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
        })
        MkL(bx, {
            Text      = s[2],
            Size      = UDim2.new(1,-60,1,0),
            Position  = UDim2.new(0,54,0,0),
            TextColor3 = TXT,
            Font      = Enum.Font.GothamSemibold,
            TextSize  = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        bx.MouseEnter:Connect(function() Tw(bx,{BackgroundColor3=Color3.fromRGB(42,42,42)}) end)
        bx.MouseLeave:Connect(function() Tw(bx,{BackgroundColor3=BOX}) end)
    end
end

-- LEG REACH
local function BldLeg()
    MkSec("Leg Reach")
    MkTog("Leg Reach", S.LegOn, function(v) S.LegOn=v _lastLeg=0 end)
    MkSec("Hitbox")
    MkTog("Show Hitbox  (Blue)", S.LHB, function(v) S.LHB=v end)
    MkSec("Distance (1-10)")
    MkSld("X - Horizontal", 0,10,S.LX, function(v) S.LX=v end)
    MkSld("Y - Vertical",   0,10,S.LY, function(v) S.LY=v end)
    MkSld("Z - Depth",      0,10,S.LZ, function(v) S.LZ=v end)
end

-- MOSS REACH
local function BldMoss()
    MkSec("Moss Reach - Head")
    MkTog("Moss Reach", S.MossOn, function(v) S.MossOn=v _lastMoss=0 end)
    MkSec("Hitbox")
    MkTog("Show Hitbox  (Green)", S.MHB, function(v) S.MHB=v end)
    MkSec("Distance (1-10)")
    MkSld("X - Horizontal", 0,10,S.MX, function(v) S.MX=v end)
    MkSld("Y - Vertical",   0,10,S.MY, function(v) S.MY=v end)
    MkSld("Z - Depth",      0,10,S.MZ, function(v) S.MZ=v end)
end

-- BALL REACH
local function BldBall()
    MkSec("Ball Reach")
    MkTog("Ball Reach", S.BallOn, function(v) S.BallOn=v _lastBall=0 end)
    MkSec("Hitbox")
    MkTog("Show Hitbox  (Yellow)", S.BHB, function(v) S.BHB=v end)
    MkSec("Distance (1-10)")
    MkSld("X - Horizontal", 0,10,S.BX, function(v) S.BX=v end)
    MkSld("Y - Vertical",   0,10,S.BY, function(v) S.BY=v end)
    MkSld("Z - Depth",      0,10,S.BZ, function(v) S.BZ=v end)
end

-- PLAYERS REACT
local function BldReact()
    MkSec("Ball Hit Reacts")
    local infoY = NY(20, 4)

    local rlist = {"Rayy","Jinx","Azrael","Tunaz","Abzzy","4v0","Apz","Alonezz","Alzzy","Foxtede"}
    local TW, TH, KS = 44, 24, 18
    local tRefs = {}

    for _, rn in ipairs(rlist) do
        local isOn = (S.React == rn)
        local ry = NY(36, 5)
        local bx = MkF(Con, {Size=UDim2.new(1,-20,0,36),Position=UDim2.new(0,10,0,ry),
            BackgroundColor3= isOn and Color3.fromRGB(28,36,28) or BOX})
        Rnd(bx, 8)
        local rangeTxt = tostring(RD[rn] and RD[rn].range or "?").." st"
        MkL(bx, {Text=rn,Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,12,0,0),
            TextColor3=TXT,Font=Enum.Font.GothamSemibold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
        MkL(bx, {Text=rangeTxt,Size=UDim2.new(0,38,1,0),Position=UDim2.new(1,-(TW+8+42),0,0),
            TextColor3=DIM,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right})
        local trk = MkF(bx, {Size=UDim2.new(0,TW,0,TH),Position=UDim2.new(1,-(TW+8),0.5,-TH/2),
            BackgroundColor3= isOn and TON or TOFF})
        Rnd(trk, 12)
        local knob = MkF(trk, {Size=UDim2.new(0,KS,0,KS),
            Position= isOn and UDim2.new(0,TW-KS-3,0.5,-KS/2) or UDim2.new(0,3,0.5,-KS/2),
            BackgroundColor3=WH})
        Rnd(knob, 9)
        tRefs[rn] = {trk=trk, knob=knob, bx=bx}

        MkB(bx, {Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""}).MouseButton1Click:Connect(function()
            local was = (S.React == rn)
            S.React = ""
            for _, ref in pairs(tRefs) do
                Tw(ref.trk,  {BackgroundColor3=TOFF})
                Tw(ref.knob, {Position=UDim2.new(0,3,0.5,-KS/2)})
                Tw(ref.bx,   {BackgroundColor3=BOX})
            end
            if not was then
                S.React = rn
                Tw(trk,  {BackgroundColor3=TON})
                Tw(knob, {Position=UDim2.new(0,TW-KS-3,0.5,-KS/2)})
                Tw(bx,   {BackgroundColor3=Color3.fromRGB(28,36,28)})
            end
        end)
    end
end

-- PLAYER SETTINGS
local function BldSettings()
    MkSec("Performance")
    MkTog("FPS Boost", S.FPS, function(v)
        S.FPS = v
        pcall(function()
            settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
            _G4.GlobalShadows = not v
        end)
        if v then for _,o in pairs(workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Smoke") then
                pcall(function() o.Enabled=false end) end end end
    end)
    MkTog("FullBright", S.Bright, function(v)
        S.Bright = v
        pcall(function()
            if v then _G4.Brightness=10 _G4.GlobalShadows=false _G4.Ambient=Color3.new(1,1,1) _G4.OutdoorAmbient=Color3.new(1,1,1)
            else _G4.Brightness=1 _G4.GlobalShadows=true _G4.Ambient=Color3.fromRGB(70,70,70) _G4.OutdoorAmbient=Color3.fromRGB(140,140,140) end
        end)
    end)
    MkTog("No Fog", S.Fog, function(v)
        S.Fog = v
        pcall(function() _G4.FogEnd = v and 9e8 or 1000 _G4.FogStart = v and 9e8 or 0 end)
    end)
    MkSec("Movement")
    MkTog("Infinite Jump", S.IJ, function(v) S.IJ=v ApplyIJ(v) end)
    -- Ball Teleport button (instant, also H key)
    local bty = NY(42, 6)
    local btbx = MkF(Con, {Size=UDim2.new(1,-24,0,42),Position=UDim2.new(0,12,0,bty),BackgroundColor3=BOX})
    Rnd(btbx, 10)
    MkF(btbx, {Size=UDim2.new(0,3,0.5,0),Position=UDim2.new(0,0,0.25,0),BackgroundColor3=ACC,BackgroundTransparency=0.3})
    MkL(btbx, {Text="Ball Teleport  [H]",Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,14,0,0),TextColor3=TXT,Font=Enum.Font.GothamSemibold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
    local btBtn = MkB(btbx, {
        Size=UDim2.new(0,70,0,26),Position=UDim2.new(1,-(70+10),0.5,-13),
        BackgroundColor3=ACC,Text="Teleport",TextColor3=WH,Font=Enum.Font.GothamBold,TextSize=11
    })
    Rnd(btBtn, 7)
    local btSt = MkL(btbx, {Text="",Size=UDim2.new(0,20,0,26),Position=UDim2.new(1,-88,0.5,-13),TextColor3=TON,Font=Enum.Font.GothamBold,TextSize=13})
    local function DoBallTp()
        pcall(function()
            if not HRP then return end
            local ball = GetBall()
            if not ball then btSt.Text="?" btSt.TextColor3=RED task.delay(1,function()btSt.Text=""end) return end
            local dir = HRP.Position - ball.Position
            local mag = dir.Magnitude
            local offset = mag < 0.1 and Vector3.new(0,0,3) or (dir/mag)*3
            HRP.CFrame = CFrame.new(ball.Position + offset + Vector3.new(0,1,0))
            btSt.Text="✓" btSt.TextColor3=TON task.delay(0.6,function()btSt.Text=""end)
        end)
    end
    btBtn.MouseButton1Click:Connect(DoBallTp)
    btBtn.MouseEnter:Connect(function() Tw(btBtn,{BackgroundColor3=Color3.fromRGB(110,165,255)}) end)
    btBtn.MouseLeave:Connect(function() Tw(btBtn,{BackgroundColor3=ACC}) end)
    -- expose for H key
    _BallTpFn = DoBallTp

    MkSec("Ping Spoofer")
    local psy = NY(42, 6)
    local pbx = MkF(Con,{Size=UDim2.new(1,-24,0,42),Position=UDim2.new(0,12,0,psy),BackgroundColor3=BOX})
    Rnd(pbx,10)
    MkF(pbx,{Size=UDim2.new(0,3,0.5,0),Position=UDim2.new(0,0,0.25,0),BackgroundColor3=ACC,BackgroundTransparency=0.3})
    MkL(pbx,{Text="Ping Spoofer",Size=UDim2.new(0.55,0,1,0),Position=UDim2.new(0,14,0,0),TextColor3=TXT,Font=Enum.Font.GothamSemibold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
    local pingSt = MkL(pbx,{Text="OFF",Size=UDim2.new(0,60,1,0),Position=UDim2.new(0.55,0,0,0),TextColor3=DIM,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left})
    local PTW,PTH=46,26 local PKS=20
    local ptrk=MkF(pbx,{Size=UDim2.new(0,PTW,0,PTH),Position=UDim2.new(1,-(PTW+10),0.5,-PTH/2),BackgroundColor3=TOFF})
    Rnd(ptrk,13)
    local pknob=MkF(ptrk,{Size=UDim2.new(0,PKS,0,PKS),Position=UDim2.new(0,3,0.5,-PKS/2),BackgroundColor3=WH})
    Rnd(pknob,10)
    local pingOn=false
    local pingFlags={
        {"FIntActivatedCountTimerMSMouse",    "0"},
        {"FIntActivatedCountTimerMSTouch",    "0"},
        {"FIntActivatedCountTimerMSKeyboard", "0"},
        {"FIntInterpolationMaxDelayMSec",     "1"},
        {"DFIntTargetTimeDelayFacctorTenths", "7"},
        {"FIntCLI20390_2",                    "0"},
    }
    local pingOrig={}
    MkB(pbx,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""}).MouseButton1Click:Connect(function()
        pingOn=not pingOn
        Tw(ptrk, {BackgroundColor3=pingOn and TON or TOFF})
        Tw(pknob,{Position=pingOn and UDim2.new(0,PTW-PKS-3,0.5,-PKS/2) or UDim2.new(0,3,0.5,-PKS/2)})
        if pingOn then
            pingSt.Text="ON" pingSt.TextColor3=TON
            for _,f in ipairs(pingFlags) do
                pingOrig[f[1]]=getfflag and pcall(function() pingOrig[f[1]]=getfflag(f[1]) end)
                pcall(function() setfflag(f[1],f[2]) end)
            end
        else
            pingSt.Text="OFF" pingSt.TextColor3=DIM
            for _,f in ipairs(pingFlags) do
                pcall(function() setfflag(f[1], pingOrig[f[1]] or f[2]) end)
            end
        end
    end)

    -- ── Avatar Stealer V1 ─────────────────────────────────
    MkSec("Avatar Stealer  V1")
    local ky = NY(60, 4)
    local kavt = MkF(Con, {Size=UDim2.new(1,-20,0,60),Position=UDim2.new(0,10,0,ky),BackgroundColor3=BOX})
    Rnd(kavt, 8)
    MkL(kavt, {
        Text="Enter player name to copy avatar:",
        Size=UDim2.new(1,-14,0,16),Position=UDim2.new(0,8,0,4),
        TextColor3=DIM,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left
    })
    -- Name input box
    local nTB = Instance.new("TextBox")
    nTB.Size=UDim2.new(0,200,0,24) nTB.Position=UDim2.new(0,8,0,28)
    nTB.BackgroundColor3=Color3.fromRGB(22,22,22) nTB.BorderSizePixel=0
    nTB.Text="" nTB.TextColor3=WH nTB.Font=Enum.Font.Gotham nTB.TextSize=12
    nTB.PlaceholderText="Player name..." nTB.PlaceholderColor3=DIM nTB.ClearTextOnFocus=false
    nTB.Parent=kavt Rnd(nTB,5)
    -- Copy button
    local kbtn = MkB(kavt,{
        Size=UDim2.new(0,110,0,24),Position=UDim2.new(0,214,0,28),
        BackgroundColor3=ACC,Text="Copy Avatar",TextColor3=WH,Font=Enum.Font.GothamBold,TextSize=11
    })
    Rnd(kbtn,5)
    local kSt = MkL(kavt,{
        Text="",Size=UDim2.new(0,46,0,24),Position=UDim2.new(1,-50,0,28),
        TextColor3=TON,Font=Enum.Font.GothamBold,TextSize=12
    })
    kbtn.MouseButton1Click:Connect(function()
        local nm = nTB.Text:gsub("%s","")
        if nm == "" then return end
        kSt.Text="..." kSt.TextColor3=DIM

        local target = _G0:FindFirstChild(nm)
        if not target then
            kSt.Text="Not Found" kSt.TextColor3=RED
            task.delay(2, function() kSt.Text="" end) return
        end

        local mc  = LP.Character
        local hum = mc and mc:FindFirstChildOfClass("Humanoid")
        if not mc or not hum then
            kSt.Text="Error" kSt.TextColor3=RED
            task.delay(2, function() kSt.Text="" end) return
        end

        -- Try full HumanoidDescription copy (local-only visual)
        local ok, desc = pcall(function()
            return _G0:GetHumanoidDescriptionFromUserId(target.UserId)
        end)

        if ok and desc then
            local applyOk = pcall(function() hum:ApplyDescription(desc) end)
            if applyOk then
                kSt.Text="✓" kSt.TextColor3=TON
                pcall(function()
                    _G5:SetCore("SendNotification",{
                        Title="RAYY",
                        Text=nm.."'s avatar copied! (only you see this)",
                    Duration=4
                    })
                end)
                task.delay(2, function() kSt.Text="" end)
                return
            end
        end

        -- Fallback: clone accessories only
        local tc = target.Character
        if tc then
            for _,a in pairs(mc:GetChildren()) do
                if a:IsA("Accessory") then pcall(function() a:Destroy() end) end
            end
            for _,a in pairs(tc:GetChildren()) do
                if a:IsA("Accessory") then
                    pcall(function()
                        local cl = a:Clone()
                        cl.Parent = mc
                    end)
                end
            end
            kSt.Text="✓" kSt.TextColor3=TON
            pcall(function()
                _G5:SetCore("SendNotification",{
                    Title="RAYY",
                    Text=nm.."'s accessories copied!",
                    Duration=3
                })
            end)
        else
            kSt.Text="Error" kSt.TextColor3=RED
        end
        task.delay(2, function() kSt.Text="" end)
    end)
    kbtn.MouseEnter:Connect(function() Tw(kbtn,{BackgroundColor3=Color3.fromRGB(110,165,255)}) end)
    kbtn.MouseLeave:Connect(function() Tw(kbtn,{BackgroundColor3=ACC}) end)
end

-- R15 REACH
local function BldR15()
    MkSec("R15 Reach")
    MkTog("R15 Reach", S.R15On, function(v) S.R15On=v _lastR15=0 end)
    MkSec("Distance (1-10)")
    MkSld("X - Horizontal", 0,10,S.RX, function(v) S.RX=v end)
    MkSld("Y - Vertical",   0,10,S.RY, function(v) S.RY=v end)
    MkSld("Z - Depth",      0,10,S.RZ, function(v) S.RZ=v end)
end

-- FFLAG SETTING
local SF = {
    ["FIntActivatedCountTimerMSMouse"]    = "0",
    ["FIntCLI20390_2"]                    = "0",
    ["FIntActivatedCountTimerMSTouch"]    = "0",
    ["DFIntTargetTimeDelayFacctorTenths"] = "7",
    ["FIntActivatedCountTimerMSKeyboard"] = "0",
    ["FIntInterpolationMaxDelayMSec"]     = "1",
}

local function ApplyFlag(name, val)
    pcall(function() setfflag(name, val) end)
end

for k,v in pairs(SF) do ApplyFlag(k,v) end

local function BldFFlag()
    local iy0 = NY(22, 3)
    local inf0 = MkF(Con,{Size=UDim2.new(1,-20,0,22),Position=UDim2.new(0,10,0,iy0),BackgroundColor3=Color3.fromRGB(18,22,40)})
    Rnd(inf0,6)

    MkSec("FFlag Settings")

    local flagList = {
        "FIntActivatedCountTimerMSMouse",
        "FIntCLI20390_2",
        "FIntActivatedCountTimerMSTouch",
        "DFIntTargetTimeDelayFacctorTenths",
        "FIntActivatedCountTimerMSKeyboard",
        "FIntInterpolationMaxDelayMSec",
    }

    for _, fname in ipairs(flagList) do
        local fy = NY(44, 3)
        local bx = MkF(Con, {Size=UDim2.new(1,-20,0,44),Position=UDim2.new(0,10,0,fy),BackgroundColor3=BOX})
        Rnd(bx, 7)

        MkL(bx, {Text=fname,
            Size=UDim2.new(1,-14,0,16),Position=UDim2.new(0,8,0,3),
            TextColor3=TXT,Font=Enum.Font.GothamBold,TextSize=9,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd})

        local tbx = Instance.new("TextBox")
        tbx.Size=UDim2.new(0,100,0,20) tbx.Position=UDim2.new(0,8,0,21)
        tbx.BackgroundColor3=Color3.fromRGB(22,22,22) tbx.BorderSizePixel=0
        tbx.Text=SF[fname] or "0" tbx.TextColor3=WH tbx.Font=Enum.Font.Gotham tbx.TextSize=12
        tbx.PlaceholderText="value" tbx.PlaceholderColor3=DIM tbx.ClearTextOnFocus=false
        tbx.Parent=bx Rnd(tbx,4)

        local ab = MkB(bx,{Size=UDim2.new(0,62,0,20),Position=UDim2.new(0,114,0,21),
            BackgroundColor3=ACC,Text="Apply",TextColor3=WH,Font=Enum.Font.GothamBold,TextSize=10})
        Rnd(ab,4)

        local st = MkL(bx,{Text="",Size=UDim2.new(0,80,0,20),Position=UDim2.new(0,182,0,21),
            TextColor3=TON,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left})

        ab.MouseButton1Click:Connect(function()
            local v = tbx.Text if v=="" then return end
            SF[fname] = v
            local ok = pcall(function() setfflag(fname, v) end)
            st.Text = ok and "✓ OK" or "✓ Trying"
            st.TextColor3 = ok and TON or DIM
            task.delay(2, function() st.Text="" end)
        end)
        ab.MouseEnter:Connect(function() Tw(ab,{BackgroundColor3=Color3.fromRGB(110,165,255)}) end)
        ab.MouseLeave:Connect(function() Tw(ab,{BackgroundColor3=ACC}) end)
    end

    MkSec("Custom FFlag")
    local cy2 = NY(48, 3)
    local cx = MkF(Con,{Size=UDim2.new(1,-20,0,48),Position=UDim2.new(0,10,0,cy2),BackgroundColor3=BOX})
    Rnd(cx,7)
    MkL(cx,{Text="Flag:",Size=UDim2.new(0,36,0,14),Position=UDim2.new(0,8,0,4),TextColor3=DIM,Font=Enum.Font.Gotham,TextSize=9})
    MkL(cx,{Text="Value:",Size=UDim2.new(0,40,0,14),Position=UDim2.new(0,198,0,4),TextColor3=DIM,Font=Enum.Font.Gotham,TextSize=9})
    local cN=Instance.new("TextBox")
    cN.Size=UDim2.new(0,178,0,20) cN.Position=UDim2.new(0,8,0,22)
    cN.BackgroundColor3=Color3.fromRGB(22,22,22) cN.BorderSizePixel=0
    cN.Text="" cN.TextColor3=WH cN.Font=Enum.Font.Gotham cN.TextSize=10
    cN.PlaceholderText="FIntXxx..." cN.PlaceholderColor3=DIM cN.ClearTextOnFocus=false
    cN.Parent=cx Rnd(cN,4)
    local cV=Instance.new("TextBox")
    cV.Size=UDim2.new(0,60,0,20) cV.Position=UDim2.new(0,192,0,22)
    cV.BackgroundColor3=Color3.fromRGB(22,22,22) cV.BorderSizePixel=0
    cV.Text="" cV.TextColor3=WH cV.Font=Enum.Font.Gotham cV.TextSize=10
    cV.PlaceholderText="0" cV.PlaceholderColor3=DIM cV.ClearTextOnFocus=false
    cV.Parent=cx Rnd(cV,4)
    local cSt=MkL(cx,{Text="",Size=UDim2.new(0,30,0,20),Position=UDim2.new(0,320,0,22),TextColor3=TON,Font=Enum.Font.GothamBold,TextSize=11})
    local cA=MkB(cx,{Size=UDim2.new(0,52,0,20),Position=UDim2.new(0,258,0,22),BackgroundColor3=ACC,Text="Enter",TextColor3=WH,Font=Enum.Font.GothamBold,TextSize=10})
    Rnd(cA,4)
    cA.MouseButton1Click:Connect(function()
        if cN.Text=="" or cV.Text=="" then return end
        local ok=pcall(function() setfflag(cN.Text,cV.Text) end)
        cSt.Text=ok and "✓" or "✗"
        cSt.TextColor3=ok and TON or Color3.fromRGB(200,80,80)
        task.delay(2,function() cSt.Text="" end)
    end)
end

-- Tab registration
RegTab("Home",            BldHome)
RegTab("Leg Reach",       BldLeg)
RegTab("Moss Reach",      BldMoss)
RegTab("Ball Reach",      BldBall)
RegTab("Players React",   BldReact)
RegTab("Player Settings", BldSettings)
RegTab("R15 Reach",       BldR15)
RegTab("FFlag Setting",   BldFFlag)

-- Open Home by default
CurTab = "Home"
Tw(Tabs["Home"].btn, {BackgroundColor3=Color3.fromRGB(30,30,30), TextColor3=TXT})
cY = 12
BldHome()

-- ── Toggle Button (mobile draggable) ──────────
local TB = MkB(SG, {
    Size             = UDim2.new(0,90,0,52),
    Position         = UDim2.new(0,10,0,48),
    BackgroundColor3 = Color3.fromRGB(20,20,20),
    Text             = "MENU",
    TextColor3       = TXT,
    Font             = Enum.Font.GothamBold,
    TextSize         = 13,
    ZIndex           = 20,
    Active           = true,
})
Rnd(TB, 6)
MkF(TB, {Size=UDim2.new(0,2,0.6,0),Position=UDim2.new(0,0,0.2,0),BackgroundColor3=ACC,ZIndex=21})

local tbDrag, tbDS, tbSP, tbT = false
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        tbDrag=true tbDS=i.Position tbSP=TB.Position tbT=tick()
    end
end)
_G2.InputChanged:Connect(function(i)
    if tbDrag and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-tbDS
        TB.Position=UDim2.new(tbSP.X.Scale,tbSP.X.Offset+d.X,tbSP.Y.Scale,tbSP.Y.Offset+d.Y)
    end
end)
_G2.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        if tbDrag then
            local d=i.Position-tbDS
            if d.Magnitude < 8 and (tick()-tbT) < 0.3 then
                shown=not shown Win.Visible=shown
            end
        end
        tbDrag=false
    end
end)

-- Right Shift (PC) + Ball Teleport [E]
_G2.InputBegan:Connect(function(i,p)
    if p then return end
    if i.KeyCode==Enum.KeyCode.RightShift then
        shown=not shown Win.Visible=shown
    end
    if i.KeyCode==Enum.KeyCode.H then
        if _BallTpFn then _BallTpFn() end
    end
end)

pcall(function()
    _RAYY = true
end)
