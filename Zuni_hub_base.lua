-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  ZUNI HUB - BASE v7.0                                              ║
-- ║  Temas (Eclipse/Cherry/Pudding) • Fontes • Escala • Popups         ║
-- ║  Ícones desenhados (sem assets) • Player (fly/noclip/tpwalk)       ║
-- ║  Aba Misc. (ESP) • Aba Settings                                    ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local Players            = game:GetService("Players")
local UIS                = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local TeleportService    = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService        = game:GetService("TextService")
local HttpService        = game:GetService("HttpService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local C3 = Color3.fromRGB

-- ═══════════════════════════════════════════════════════════════════════
-- PRESETS DE COR
-- ═══════════════════════════════════════════════════════════════════════
local THEMES = {
    Eclipse = {
        Light = false,
        Bg = C3(10, 11, 19), Sidebar = C3(16, 17, 29), Card = C3(24, 26, 41), CardHover = C3(37, 40, 63), CardSoft = C3(30, 32, 51),
        Accent = C3(108, 140, 255), AccentLight = C3(172, 196, 255), AccentDark = C3(58, 80, 190), Purple = C3(178, 124, 255),
        Success = C3(70, 214, 130), Warning = C3(255, 196, 72), Danger = C3(242, 78, 96),
        Text = C3(246, 247, 255), TextDim = C3(182, 186, 210), TextMuted = C3(122, 127, 154),
        Border = C3(66, 70, 102), BorderSoft = C3(46, 49, 74), Divider = C3(44, 47, 70),
        Shade = C3(196, 200, 224), OnAccent = WHITE,
    },
    Cherry = {
        Light = false,
        Bg = C3(20, 9, 14), Sidebar = C3(31, 13, 20), Card = C3(45, 19, 29), CardHover = C3(72, 30, 46), CardSoft = C3(56, 24, 36),
        Accent = C3(242, 72, 104), AccentLight = C3(255, 152, 174), AccentDark = C3(168, 34, 66), Purple = C3(255, 122, 168),
        Success = C3(86, 216, 138), Warning = C3(255, 190, 84), Danger = C3(255, 92, 92),
        Text = C3(255, 242, 245), TextDim = C3(226, 184, 194), TextMuted = C3(164, 118, 130),
        Border = C3(120, 54, 74), BorderSoft = C3(80, 36, 50), Divider = C3(70, 32, 44),
        Shade = C3(214, 190, 200), OnAccent = WHITE,
    },
    Pudding = {
        Light = true,
        Bg = C3(253, 243, 214), Sidebar = C3(246, 226, 176), Card = C3(255, 250, 232), CardHover = C3(255, 236, 186), CardSoft = C3(249, 234, 194),
        Accent = C3(222, 142, 44), AccentLight = C3(168, 98, 22), AccentDark = C3(196, 116, 28), Purple = C3(236, 120, 96),
        Success = C3(52, 168, 98), Warning = C3(220, 146, 20), Danger = C3(214, 62, 72),
        Text = C3(80, 50, 24), TextDim = C3(128, 90, 52), TextMuted = C3(170, 136, 96),
        Border = C3(214, 176, 112), BorderSoft = C3(232, 206, 152), Divider = C3(236, 214, 166),
        Shade = C3(236, 222, 186), OnAccent = WHITE,
    },
}
local THEME_ORDER = { "Eclipse", "Cherry", "Pudding" }

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIG PERSISTENTE (arquivo próprio da Base)
-- ═══════════════════════════════════════════════════════════════════════
local CFG_FILE = "ZuniHub_Base.json"

local function DefaultESP()
    return {
        enabled = false, teamCheck = false, useTeamColor = false,
        names = true, nameMode = "Display", health = true, healthText = true, distance = true,
        highlight = true, box = false, tracers = false, tracerOrigin = "Baixo",
        mainColor = "Tema", fillColor = "Vermelho", outlineColor = "Branco",
        fillAlpha = 40, maxDist = 1500, textSize = 13,
    }
end

local Cfg = { theme = "Eclipse", font = "Gotham", scale = 1, customOn = false, cr = 108, cg = 140, cb = 255, esp = DefaultESP() }

local function Merge(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then Merge(dst[k], v) else dst[k] = v end
    end
end

local function LoadCfg()
    local okF, exists = pcall(function() return isfile and isfile(CFG_FILE) end)
    if not (okF and exists) then return end
    local ok, content = pcall(readfile, CFG_FILE)
    if not ok or type(content) ~= "string" or content == "" then return end
    local ok2, data = pcall(function() return HttpService:JSONDecode(content) end)
    if ok2 and type(data) == "table" then Merge(Cfg, data) end
end
LoadCfg()
if not THEMES[Cfg.theme] then Cfg.theme = "Eclipse" end
Cfg.scale = math.clamp(tonumber(Cfg.scale) or 1, 0.6, 1.4)
for _, k in ipairs({ "cr", "cg", "cb" }) do Cfg[k] = math.clamp(tonumber(Cfg[k]) or 128, 0, 255) end

local saveToken = 0
local function SaveCfg()
    if not writefile then return end
    saveToken += 1
    local my = saveToken
    task.delay(0.6, function()
        if my ~= saveToken then return end
        pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(Cfg)) end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- CORES + FONTES (mutáveis: o Rebuild relê tudo)
-- ═══════════════════════════════════════════════════════════════════════
local Colors = {}
local function ApplyPalette()
    local p = THEMES[Cfg.theme] or THEMES.Eclipse
    for k, v in pairs(p) do Colors[k] = v end
    if Cfg.customOn then
        local base = C3(Cfg.cr, Cfg.cg, Cfg.cb)
        local h, s, v = base:ToHSV()
        Colors.Accent = base
        Colors.AccentLight = p.Light and base:Lerp(BLACK, 0.3) or base:Lerp(WHITE, 0.45)
        Colors.AccentDark = p.Light and base:Lerp(BLACK, 0.12) or base:Lerp(BLACK, 0.4)
        Colors.Purple = Color3.fromHSV((h + 0.1) % 1, math.clamp(s * 0.85, 0, 1), math.max(v, 0.85))
    end
end
ApplyPalette()

-- { nome, regular, médio, bold, black, escala do tamanho do texto }
local FONTSETS = {
    { "Gotham",      "Gotham",     "GothamMedium",       "GothamBold",     "GothamBlack",   1.00 },
    { "Source Sans", "SourceSans", "SourceSansSemibold", "SourceSansBold", "SourceSansBold", 1.12 },
    { "Roboto",      "Roboto",     "Roboto",             "Roboto",         "Roboto",        1.04 },
    { "Nunito",      "Nunito",     "Nunito",             "Nunito",         "Nunito",        1.05 },
    { "Ubuntu",      "Ubuntu",     "Ubuntu",             "Ubuntu",         "Ubuntu",        1.02 },
    { "Fredoka",     "FredokaOne", "FredokaOne",         "FredokaOne",     "FredokaOne",    1.00 },
    { "Jura",        "Jura",       "Jura",               "Jura",           "Jura",          1.06 },
    { "Codigo",      "Code",       "Code",               "Code",           "Code",          0.95 },
    { "Arial",       "Arial",      "Arial",              "ArialBold",      "ArialBold",     1.02 },
}
local FONT_NAMES = {}
for _, f in ipairs(FONTSETS) do table.insert(FONT_NAMES, f[1]) end

local F_REG, F_MED, F_BOLD, F_BLACK, FS = Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold, Enum.Font.GothamBlack, 1
local function ResolveFont(n)
    local ok, f = pcall(function() return Enum.Font[n] end)
    return (ok and f) or Enum.Font.Gotham
end
local function SetFont(name)
    local set = FONTSETS[1]
    for _, f in ipairs(FONTSETS) do if f[1] == name then set = f break end end
    F_REG, F_MED, F_BOLD, F_BLACK = ResolveFont(set[2]), ResolveFont(set[3]), ResolveFont(set[4]), ResolveFont(set[5])
    FS = set[6]
end
SetFont(Cfg.font)
local function TS(n) return math.max(8, math.floor(n * FS + 0.5)) end

local MOUSE_ICON = "rbxassetid://11202664265"

-- ═══════════════════════════════════════════════════════════════════════
-- LIMPEZA + ONDE CRIAR A GUI
-- ═══════════════════════════════════════════════════════════════════════
local function SafeParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and typeof(h) == "Instance" then return h end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then
        local t = Instance.new("Folder")
        local ok3 = pcall(function() t.Parent = cg end)
        pcall(function() t:Destroy() end)
        if ok3 then return cg end
    end
    return PlayerGui
end
local GuiParent = SafeParent()

do
    if _G.ZuniHub then
        pcall(function()
            if _G.ZuniHub.Destroy then _G.ZuniHub.Destroy() else _G.ZuniHub.Alive = false end
        end)
        _G.ZuniHub = nil
    end
    local roots = { PlayerGui, GuiParent }
    pcall(function() table.insert(roots, game:GetService("CoreGui")) end)
    for _, root in ipairs(roots) do
        pcall(function()
            for _, n in ipairs({ "ZuniHub", "ZuniNotify", "ZuniESP" }) do
                local g = root:FindFirstChild(n)
                if g then g:Destroy() end
            end
        end)
    end
end

local Z = {
    Version = "7.0", Alive = true, Ready = false,
    Colors = Colors, SavedStates = {}, UI = {}, Connections = {}, Cleanups = {},
    Tabs = {}, TabOrder = {}, CurrentTab = nil,
    ModuleName = "Nenhum", PageGen = 0, IsVisible = false,
    FPS = 60, StartTime = tick(), Cfg = Cfg, SaveCfg = SaveCfg,
}
_G.ZuniHub = Z
local S = Z.SavedStates

function Z.Track(conn)
    if conn then table.insert(Z.Connections, conn) end
    return conn
end
function Z.DisconnectAll()
    for _, c in ipairs(Z.Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Z.Connections)
end
function Z.OnDestroy(fn) table.insert(Z.Cleanups, fn) end

-- ═══════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════
local function New(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function Corner(o, r) return New("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function Stroke(o, color, thick, transp)
    return New("UIStroke", {
        Color = color, Thickness = thick or 1, Transparency = transp or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end
local function Tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end
local function Label(parent, text, size, color, font, pos, sz, align)
    return New("TextLabel", {
        BackgroundTransparency = 1, Text = text, TextSize = TS(size), TextColor3 = color,
        Font = font or F_REG, Position = pos or UDim2.new(), Size = sz or UDim2.fromScale(1, 1),
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end
local function Gradient(o, c0, c1, rot, transparency)
    return New("UIGradient", {
        Color = ColorSequence.new(c0, c1), Rotation = rot or 90,
        Transparency = transparency or NumberSequence.new(0),
    }, o)
end
local function Safe(cb, ...)
    if not cb then return end
    local ok, err = pcall(cb, ...)
    if not ok then warn("[ZuniHub] " .. tostring(err)) end
end
local function IsPointer(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function Viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

-- Remove emojis de qualquer texto vindo dos módulos (a UI não usa emojis)
local function NoEmoji(s)
    s = tostring(s == nil and "" or s)
    local ok, out = pcall(function()
        local t = {}
        for _, cp in utf8.codes(s) do
            local bad = (cp >= 0x1F000 and cp <= 0x1FAFF)
                or (cp >= 0x2600 and cp <= 0x27BF)
                or (cp >= 0x2B00 and cp <= 0x2BFF)
                or (cp >= 0x2300 and cp <= 0x23FF)
                or (cp >= 0x25A0 and cp <= 0x25FF)
                or cp == 0x2139
                or cp == 0xFE0F or cp == 0x200D or cp == 0x20E3
            if not bad then t[#t + 1] = utf8.char(cp) end
        end
        return table.concat(t)
    end)
    if not ok then return s end
    return (out:gsub("^%s+", ""))
end

-- ═══════════════════════════════════════════════════════════════════════
-- ÍCONES DESENHADOS (Frames) — não dependem de asset nenhum, então nunca
-- aparece "X". Também aceita rbxassetid/número se o módulo quiser imagem.
-- Primitivas (grade 24x24):
--   {"l",x1,y1,x2,y2}  linha   {"r",x,y,w,h,raio,preenchido}  retângulo
--   {"c",cx,cy,r,preenchido}  círculo   {"t",cx,cy,w,h,rot}  retângulo girado
-- ═══════════════════════════════════════════════════════════════════════
local ICONS = {
    house    = { { "l", 3, 12, 12, 4 }, { "l", 12, 4, 21, 12 }, { "r", 6, 11, 12, 9, 1.5, false }, { "r", 10.5, 15, 3, 5, 0.6, true } },
    person   = { { "c", 12, 8, 4, false }, { "r", 5, 14.5, 14, 7, 3.5, false } },
    gamepad  = { { "r", 2.5, 7, 19, 11, 5.5, false }, { "l", 7.5, 10, 7.5, 15 }, { "l", 5, 12.5, 10, 12.5 }, { "c", 15.5, 11, 1.2, true }, { "c", 18, 13.8, 1.2, true } },
    hand     = { { "r", 6.5, 10.5, 11, 9.5, 3, false }, { "r", 6.5, 5, 2.2, 7, 1.1, true }, { "r", 9.6, 3, 2.2, 9, 1.1, true }, { "r", 12.7, 3.8, 2.2, 8.2, 1.1, true }, { "r", 15.8, 6, 2.2, 6.5, 1.1, true } },
    coin     = { { "c", 12, 12, 9, false }, { "c", 12, 12, 4, false } },
    walk     = { { "l", 4, 12, 20, 12 }, { "l", 14, 6, 20, 12 }, { "l", 14, 18, 20, 12 } },
    gift     = { { "r", 4, 11, 16, 9.5, 1.5, false }, { "r", 3, 7.5, 18, 3.5, 1, false }, { "l", 12, 7.5, 12, 20.5 }, { "c", 9.2, 5.2, 2.2, false }, { "c", 14.8, 5.2, 2.2, false } },
    pin      = { { "c", 12, 10, 6, false }, { "c", 12, 10, 2, true }, { "l", 8.5, 15, 12, 21.5 }, { "l", 15.5, 15, 12, 21.5 } },
    lock     = { { "r", 8, 3, 8, 11, 4, false }, { "r", 5, 11, 14, 10, 2.5, true } },
    upgrade  = { { "c", 12, 12, 9, false }, { "l", 12, 17, 12, 8 }, { "l", 8, 11.5, 12, 7.5 }, { "l", 16, 11.5, 12, 7.5 } },
    swap     = { { "l", 4, 8, 20, 8 }, { "l", 16, 4, 20, 8 }, { "l", 16, 12, 20, 8 }, { "l", 20, 16, 4, 16 }, { "l", 8, 12, 4, 16 }, { "l", 8, 20, 4, 16 } },
    eye      = { { "r", 2, 6.5, 20, 11, 5.5, false }, { "c", 12, 12, 3, true } },
    box      = { { "r", 4, 6, 16, 13, 2, false }, { "l", 4, 10.5, 20, 10.5 } },
    chevron  = { { "l", 6, 9, 12, 15 }, { "l", 18, 9, 12, 15 } },
    check    = { { "l", 5, 12.5, 10, 17.5 }, { "l", 10, 17.5, 19, 7 } },
    cross    = { { "l", 6, 6, 18, 18 }, { "l", 18, 6, 6, 18 } },
    alert    = { { "c", 12, 12, 9, false }, { "l", 12, 7, 12, 13 }, { "c", 12, 16.5, 1.3, true } },
    info     = { { "c", 12, 12, 9, false }, { "l", 12, 11, 12, 17 }, { "c", 12, 7.5, 1.3, true } },
}
do
    local gear = { { "c", 12, 12, 7.4, false }, { "c", 12, 12, 2.2, true } }
    for i = 0, 7 do
        local a = math.rad(i * 45)
        table.insert(gear, { "t", 12 + math.cos(a) * 9.4, 12 + math.sin(a) * 9.4, 3.2, 3.2, i * 45 })
    end
    ICONS.gear = gear
end

local EMOJI_ICONS = {
    { "🏠", "house" }, { "👤", "person" }, { "🧍", "person" }, { "🎮", "gamepad" }, { "🌾", "hand" }, { "🎒", "hand" },
    { "🍽", "coin" }, { "💰", "coin" }, { "🚶", "walk" }, { "🎁", "gift" }, { "🗺", "pin" }, { "🍃", "pin" },
    { "📏", "lock" }, { "⚡", "upgrade" }, { "🔁", "swap" }, { "👁", "eye" }, { "⚙", "gear" }, { "🔧", "gear" }, { "📦", "box" },
}
local NAME_ICONS = {
    { "home", "house" }, { "main", "gamepad" }, { "inicio", "house" }, { "player", "person" }, { "jogador", "person" },
    { "grab", "hand" }, { "eat", "coin" }, { "sell", "coin" }, { "walk", "walk" }, { "reward", "gift" },
    { "map", "pin" }, { "chunk", "pin" }, { "unstuck", "lock" }, { "upgrade", "upgrade" }, { "teleport", "swap" },
    { "misc", "eye" }, { "esp", "eye" }, { "setting", "gear" }, { "config", "gear" },
}
local function ResolveIconName(icon, tabName)
    icon = tostring(icon or "")
    if ICONS[icon:lower()] then return icon:lower() end
    for _, pair in ipairs(EMOJI_ICONS) do
        if icon:find(pair[1], 1, true) then return pair[2] end
    end
    local lname = string.lower(tostring(tabName or ""))
    for _, pair in ipairs(NAME_ICONS) do
        if lname:find(pair[1], 1, true) then return pair[2] end
    end
    return "box"
end

local function DrawIcon(parent, name, size, color, pos)
    local def = ICONS[name] or ICONS.box
    local root = New("Frame", {
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromOffset(size, size), Position = pos or UDim2.new(),
    }, parent)
    local k = size / 24
    local th = math.max(1.4, 1.9 * k)
    local parts = {}
    local function add(inst, prop) parts[#parts + 1] = { inst, prop } end

    for _, p in ipairs(def) do
        local t = p[1]
        if t == "l" then
            local x1, y1, x2, y2 = p[2] * k, p[3] * k, p[4] * k, p[5] * k
            local len = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
            local f = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2),
                Size = UDim2.fromOffset(len + th * 0.5, th), Rotation = math.deg(math.atan2(y2 - y1, x2 - x1)),
                BackgroundColor3 = color, BorderSizePixel = 0,
            }, root)
            Corner(f, th / 2)
            add(f, "BackgroundColor3")
        elseif t == "t" then
            local f = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(p[2] * k, p[3] * k),
                Size = UDim2.fromOffset(p[4] * k, p[5] * k), Rotation = p[6],
                BackgroundColor3 = color, BorderSizePixel = 0,
            }, root)
            Corner(f, math.max(0.5, 0.5 * k))
            add(f, "BackgroundColor3")
        else
            local x, y, w, h, rad, fill
            if t == "c" then
                x, y, w, h, rad, fill = p[2] - p[4], p[3] - p[4], p[4] * 2, p[4] * 2, p[4], p[5]
            else
                x, y, w, h, rad, fill = p[2], p[3], p[4], p[5], p[6], p[7]
            end
            local px, py, pw, ph = x * k, y * k, w * k, h * k
            if not fill then px, py, pw, ph = px + th / 2, py + th / 2, pw - th, ph - th end
            local f = New("Frame", {
                Position = UDim2.fromOffset(px, py), Size = UDim2.fromOffset(math.max(1, pw), math.max(1, ph)),
                BackgroundColor3 = color, BackgroundTransparency = fill and 0 or 1, BorderSizePixel = 0,
            }, root)
            Corner(f, math.max(0, rad * k))
            if fill then
                add(f, "BackgroundColor3")
            else
                add(New("UIStroke", { Color = color, Thickness = th, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f), "Color")
            end
        end
    end

    return {
        Root = root,
        SetColor = function(c, t)
            for _, pr in ipairs(parts) do
                if not pr[1].Parent then return end
                if t and t > 0 then Tween(pr[1], t, { [pr[2]] = c }) else pr[1][pr[2]] = c end
            end
        end,
    }
end

-- spec pode ser: nome ("gear"), emoji (mapeado), "rbxassetid://..." ou número (imagem)
local function MakeIcon(parent, spec, size, color, pos, tabName)
    if type(spec) == "number" or (type(spec) == "string" and spec:find("^rbxasset")) then
        local img = New("ImageLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size), Position = pos or UDim2.new(),
            Image = type(spec) == "number" and ("rbxassetid://" .. spec) or spec,
            ImageColor3 = color, ScaleType = Enum.ScaleType.Fit,
        }, parent)
        return { Root = img, SetColor = function(c, t)
            if not img.Parent then return end
            if t and t > 0 then Tween(img, t, { ImageColor3 = c }) else img.ImageColor3 = c end
        end }
    end
    return DrawIcon(parent, ResolveIconName(spec, tabName), size, color, pos)
end

local function Shade(a) return Colors.Shade:Lerp(WHITE, a or 0) end

Z.DrawIcon, Z.MakeIcon = DrawIcon, MakeIcon
Z.Util = { New = New, Corner = Corner, Stroke = Stroke, Tween = Tween, Label = Label, Gradient = Gradient, NoEmoji = NoEmoji, DrawIcon = DrawIcon }

-- ═══════════════════════════════════════════════════════════════════════
-- SCREEN GUIS
-- ═══════════════════════════════════════════════════════════════════════
local Hub = New("ScreenGui", {
    Name = "ZuniHub", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
}, GuiParent)
local ESPGui = New("ScreenGui", {
    Name = "ZuniESP", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 998,
}, GuiParent)
local NotifyGui = New("ScreenGui", {
    Name = "ZuniNotify", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000,
}, GuiParent)

-- ═══════════════════════════════════════════════════════════════════════
-- POPUPS: NOTIFICAÇÕES (toasts)  — vivem na Base, usam o tema atual
-- ═══════════════════════════════════════════════════════════════════════
local NotifyHolder = New("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(0, 340, 1, -24), Position = UDim2.new(1, -356, 0, 18),
}, NotifyGui)
New("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, NotifyHolder)
local notifyN = 0
local liveToasts = {}

local function ToastKind(color)
    if color == Colors.Success then return "check" end
    if color == Colors.Warning then return "alert" end
    if color == Colors.Danger then return "cross" end
    return "info"
end

function Z.Notify(title, text, color, duration)
    if not Z.Alive or not NotifyHolder.Parent then return end
    color, duration = color or Colors.Accent, duration or 4
    notifyN += 1
    title, text = NoEmoji(title), NoEmoji(text or "")

    local textH = 0
    if text ~= "" then
        local ok, sz = pcall(function()
            return TextService:GetTextSize(text, TS(12), F_REG, Vector2.new(266, 1000))
        end)
        textH = ok and sz.Y or 16
    end
    local H = math.max(60, 48 + textH)

    local slot = New("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = notifyN }, NotifyHolder)
    local mover = New("Frame", { Size = UDim2.new(1, 0, 0, H), Position = UDim2.fromOffset(70, 0), BackgroundTransparency = 1 }, slot)

    local glow = New("Frame", {
        Size = UDim2.new(1, 6, 1, 6), Position = UDim2.fromOffset(-3, -3), BackgroundTransparency = 1, BorderSizePixel = 0,
    }, mover)
    Corner(glow, 17)
    local glowStroke = Stroke(glow, color, 3, 1)

    local toast = New("CanvasGroup", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.02,
        BorderSizePixel = 0, GroupTransparency = 1,
    }, mover)
    Corner(toast, 14)
    Gradient(toast, Colors.Card:Lerp(color, 0.14), Colors.Bg, 0)

    local outline = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5 }, mover)
    Corner(outline, 14)
    local st = Stroke(outline, color, 1, 1)

    local strip = New("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, toast)
    Gradient(strip, color:Lerp(WHITE, 0.3), color, 90)

    local badge = New("Frame", {
        Size = UDim2.fromOffset(30, 30), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, -2),
        BackgroundColor3 = color, BackgroundTransparency = 0.8, BorderSizePixel = 0,
    }, toast)
    Corner(badge, 15)
    Stroke(badge, color, 1, 0.55)
    DrawIcon(badge, ToastKind(color), 16, color, UDim2.fromOffset(7, 7))

    Label(toast, title, 13, Colors.Text, F_BOLD, UDim2.fromOffset(56, 9), UDim2.new(1, -70, 0, 20))
    if text ~= "" then
        New("TextLabel", {
            BackgroundTransparency = 1, Text = text, Font = F_REG, TextSize = TS(12), TextColor3 = Colors.TextDim,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromOffset(56, 30), Size = UDim2.new(1, -70, 0, textH),
        }, toast)
    end

    New("Frame", {
        Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = WHITE, BackgroundTransparency = 0.9, BorderSizePixel = 0,
    }, toast)
    local bar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, toast)
    Gradient(bar, color, color:Lerp(WHITE, 0.45), 0)

    local hit = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 6 }, mover)

    local ease = Enum.EasingStyle.Quad
    local closed = false
    local function close()
        if closed then return end
        closed = true
        for i, f in ipairs(liveToasts) do if f == close then table.remove(liveToasts, i) break end end
        if not slot.Parent then return end
        Tween(mover, 0.25, { Position = UDim2.fromOffset(70, 0) }, ease, Enum.EasingDirection.In)
        Tween(toast, 0.25, { GroupTransparency = 1 }, ease, Enum.EasingDirection.In)
        Tween(st, 0.25, { Transparency = 1 }, ease, Enum.EasingDirection.In)
        Tween(glowStroke, 0.25, { Transparency = 1 }, ease, Enum.EasingDirection.In)
        task.delay(0.22, function()
            if not slot.Parent then return end
            local tw = Tween(slot, 0.2, { Size = UDim2.new(1, 0, 0, 0) }, ease)
            tw.Completed:Connect(function() pcall(function() slot:Destroy() end) end)
        end)
    end
    table.insert(liveToasts, close)
    if #liveToasts > 5 then task.defer(liveToasts[1]) end
    hit.MouseButton1Click:Connect(close)

    Tween(slot, 0.25, { Size = UDim2.new(1, 0, 0, H) }, ease)
    Tween(mover, 0.4, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
    Tween(toast, 0.3, { GroupTransparency = 0 }, ease)
    Tween(st, 0.3, { Transparency = 0.5 }, ease)
    Tween(glowStroke, 0.3, { Transparency = 0.86 }, ease)
    Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
    task.delay(duration, close)
end

-- ═══════════════════════════════════════════════════════════════════════
-- POPUPS: CONFIRMAÇÃO (modal)
-- ═══════════════════════════════════════════════════════════════════════
function Z.Confirm(title, text, onYes, yesText, noText)
    if not Z.Alive then return end
    title, text = NoEmoji(title), NoEmoji(text or "")
    local W = 372
    local ok, sz = pcall(function() return TextService:GetTextSize(text, TS(13), F_REG, Vector2.new(W - 52, 1000)) end)
    local textH = ok and sz.Y or 34
    local H = 26 + 24 + 10 + textH + 24 + 40 + 22
    local bw = (W - 52 - 10) / 2

    local overlay = New("TextButton", {
        Name = "ZuniModal", Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK, BackgroundTransparency = 1,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 100,
    }, NotifyGui)
    local box = New("Frame", {
        Size = UDim2.fromOffset(W, H), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 101,
    }, overlay)
    Corner(box, 18)
    Gradient(box, Colors.Card, Colors.Bg, 90)
    Stroke(box, Colors.Accent, 1.2, 0.45)
    local topBar = New("Frame", {
        Size = UDim2.new(1, -36, 0, 3), Position = UDim2.fromOffset(18, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, box)
    Corner(topBar, 2)
    Gradient(topBar, Colors.Accent, Colors.Purple, 0)

    local target = math.min(1, (Viewport().X - 24) / W)
    local sc = New("UIScale", { Scale = target * 0.9 }, box)

    Label(box, title, 17, Colors.Text, F_BLACK, UDim2.fromOffset(26, 24), UDim2.new(1, -52, 0, 24))
    New("TextLabel", {
        BackgroundTransparency = 1, Text = text, Font = F_REG, TextSize = TS(13), TextColor3 = Colors.TextDim,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(26, 58), Size = UDim2.new(1, -52, 0, textH),
    }, box)

    local closing = false
    local function close()
        if closing then return end
        closing = true
        Tween(overlay, 0.15, { BackgroundTransparency = 1 })
        Tween(sc, 0.15, { Scale = target * 0.92 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.17, function() pcall(function() overlay:Destroy() end) end)
    end

    local function MBtn(label, x, primary, cb)
        local b = New("TextButton", {
            Size = UDim2.fromOffset(bw, 40), Position = UDim2.fromOffset(x, H - 22 - 40),
            BackgroundColor3 = primary and WHITE or Colors.CardSoft, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
        }, box)
        Corner(b, 12)
        if primary then Gradient(b, Colors.Accent, Colors.Purple, 0) else Stroke(b, Colors.Border, 1, 0.4) end
        Label(b, label, 14, primary and Colors.OnAccent or Colors.Text, F_BOLD, UDim2.new(), UDim2.fromScale(1, 1), Enum.TextXAlignment.Center)
        b.MouseEnter:Connect(function() Tween(b, 0.12, { BackgroundTransparency = 0.15 }) end)
        b.MouseLeave:Connect(function() Tween(b, 0.12, { BackgroundTransparency = 0 }) end)
        b.MouseButton1Click:Connect(cb)
    end
    MBtn(noText or "Cancelar", 26, false, close)
    MBtn(yesText or "Confirmar", 26 + bw + 10, true, function()
        close()
        Safe(onYes)
    end)

    Tween(overlay, 0.2, { BackgroundTransparency = 0.5 })
    Tween(sc, 0.25, { Scale = target }, Enum.EasingStyle.Back)
end

-- ═══════════════════════════════════════════════════════════════════════
-- JANELA (reconstruída em Z.Rebuild quando tema/fonte mudam)
-- ═══════════════════════════════════════════════════════════════════════
local WIN_W, WIN_H = 760, 540
local Main, WinScale, Sidebar, TabsScroll, Content, Header, TabTitle, TitleIconHolder, TitleIcon, Scroll, Popup, Bubble
local WinConns = {}
local function WinTrack(c) table.insert(WinConns, c) return c end

local PageConns = {}
local order = 0
local function NextOrder() order += 1 return order end

local function TargetScale()
    local vp = Viewport()
    local fit = math.min((vp.X - 24) / WIN_W, (vp.Y - 24) / WIN_H)
    return math.clamp(math.min(Cfg.scale, fit), 0.4, 1.5)
end

Z.GUI = {}
function Z.GUI.Clear()
    Z.PageGen += 1
    for _, c in ipairs(PageConns) do pcall(function() c:Disconnect() end) end
    table.clear(PageConns)
    for k in pairs(Z.UI) do Z.UI[k] = nil end
    for _, v in ipairs(Scroll:GetChildren()) do
        if not (v:IsA("UIListLayout") or v:IsA("UIPadding")) then v:Destroy() end
    end
    Scroll.CanvasPosition = Vector2.zero
    Scroll.ScrollingEnabled = true
    order = 0
end
function Z.PageTrack(conn) table.insert(PageConns, conn) return conn end
function Z.PageLoop(interval, fn)
    local gen = Z.PageGen
    task.spawn(function()
        while Z.Alive and Z.PageGen == gen do
            local ok, err = pcall(fn)
            if not ok then warn("[Zuni] PageLoop: " .. tostring(err)) end
            task.wait(interval)
        end
    end)
end

local function MakeDraggable(handle, target, onClick, clampFn)
    local dragging, moved, origin, startPos = false, false, nil, nil
    handle.InputBegan:Connect(function(i)
        if IsPointer(i) then
            dragging, moved = true, false
            origin, startPos = i.Position, target.Position
        end
    end)
    WinTrack(UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - origin
            if not moved and d.Magnitude > 6 then moved = true end
            if moved then
                local x, y = startPos.X.Offset + d.X, startPos.Y.Offset + d.Y
                if clampFn then x, y = clampFn(x, y) end
                target.Position = UDim2.new(startPos.X.Scale, x, startPos.Y.Scale, y)
            end
        end
    end))
    WinTrack(UIS.InputEnded:Connect(function(i)
        if dragging and IsPointer(i) then
            dragging = false
            if not moved and onClick then Safe(onClick) end
        end
    end))
end

local function ClampMain(x, y)
    local vp = Viewport()
    local mx, my = vp.X / 2 - 80, vp.Y / 2 - 40
    return math.clamp(x, -mx, mx), math.clamp(y, -my, my)
end

-- ── Abas ───────────────────────────────────────────────────────────────
local function StyleTab(tab, active)
    if not tab or not tab.Button or not tab.Button.Parent then return end
    Tween(tab.Button, 0.2, { BackgroundTransparency = active and 0.1 or 1, BackgroundColor3 = active and Colors.AccentDark or Colors.Card })
    Tween(tab.Stroke, 0.2, { Transparency = active and 0.15 or 1 })
    Tween(tab.Bar, 0.2, { BackgroundTransparency = active and 0 or 1 })
    tab.IconObj.SetColor(active and Colors.OnAccent or Colors.TextDim, 0.2)
    Tween(tab.Label, 0.2, { TextColor3 = active and Colors.OnAccent or Colors.TextDim })
end

local function BuildTabButton(tab)
    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Colors.Card, BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "", LayoutOrder = tab.Order,
    }, TabsScroll)
    Corner(btn, 12)
    Gradient(btn, WHITE, Shade(0.15), 0)
    local tabStroke = Stroke(btn, Colors.AccentLight, 1.2, 1)
    local bar = New("Frame", {
        Size = UDim2.fromOffset(4, 22), Position = UDim2.new(0, 0, 0.5, -11), BackgroundColor3 = WHITE,
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, btn)
    Corner(bar, 2)
    Gradient(bar, Colors.AccentLight, Colors.Purple, 90)
    local ic = MakeIcon(btn, tab.IconSpec, 20, Colors.TextDim, UDim2.fromOffset(16, 12), tab.Name)
    local nm = Label(btn, tab.DisplayName, 14, Colors.TextDim, F_BOLD, UDim2.fromOffset(48, 0), UDim2.new(1, -54, 1, 0))

    tab.Button, tab.Stroke, tab.Bar, tab.IconObj, tab.Label = btn, tabStroke, bar, ic, nm

    btn.MouseEnter:Connect(function()
        if Z.CurrentTab ~= tab.Name then
            Tween(btn, 0.15, { BackgroundTransparency = 0.55 })
            Tween(tabStroke, 0.15, { Transparency = 0.75 })
        end
    end)
    btn.MouseLeave:Connect(function()
        if Z.CurrentTab ~= tab.Name then
            Tween(btn, 0.15, { BackgroundTransparency = 1 })
            Tween(tabStroke, 0.15, { Transparency = 1 })
        end
    end)
    btn.MouseButton1Click:Connect(function() Z.SelectTab(tab.Name) end)
    if Z.CurrentTab == tab.Name then StyleTab(tab, true) end
end

local function HeaderBtn(text, xOff, cb)
    local b = New("TextButton", {
        Size = UDim2.fromOffset(34, 34), Position = UDim2.new(1, xOff, 0, 15), BackgroundColor3 = Colors.Card, Text = text,
        Font = F_BOLD, TextSize = TS(18), TextColor3 = Colors.Text, AutoButtonColor = false, BorderSizePixel = 0,
    }, Header)
    Corner(b, 10)
    Gradient(b, WHITE, Colors.Shade, 90)
    local st = Stroke(b, Colors.Border, 1, 0.5)
    b.MouseEnter:Connect(function()
        Tween(b, 0.15, { BackgroundColor3 = Colors.CardHover })
        Tween(st, 0.15, { Color = Colors.Accent, Transparency = 0.2 })
    end)
    b.MouseLeave:Connect(function()
        Tween(b, 0.15, { BackgroundColor3 = Colors.Card })
        Tween(st, 0.15, { Color = Colors.Border, Transparency = 0.5 })
    end)
    b.MouseButton1Click:Connect(function() Safe(cb) end)
    return b
end

local function BuildWindow(savedPos, savedBubblePos)
    for _, c in ipairs(WinConns) do pcall(function() c:Disconnect() end) end
    table.clear(WinConns)
    Hub:ClearAllChildren()
    TitleIcon = nil

    Main = New("Frame", {
        Name = "Main", Size = UDim2.fromOffset(WIN_W, WIN_H), Position = savedPos or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BackgroundTransparency = 0.15,
        BorderSizePixel = 0, Visible = false, Active = true,
    }, Hub)
    Corner(Main, 18)
    Stroke(Main, Colors.Border, 1, 0.4)
    Gradient(Main, Colors.Bg, Colors.Sidebar, 135)
    WinScale = New("UIScale", { Scale = 1 }, Main)

    -- Sidebar
    Sidebar = New("Frame", { Size = UDim2.new(0, 200, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true }, Main)
    local SideBg = New("Frame", {
        Size = UDim2.new(1, 30, 1, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 0.3, BorderSizePixel = 0,
    }, Sidebar)
    Corner(SideBg, 18)
    Gradient(SideBg, Colors.Sidebar, Colors.Bg, 90)
    New("Frame", {
        Size = UDim2.new(0, 1, 1, -36), Position = UDim2.new(1, -1, 0, 18),
        BackgroundColor3 = Colors.Border, BackgroundTransparency = 0.55, BorderSizePixel = 0,
    }, Sidebar)

    local LogoCard = New("Frame", {
        Size = UDim2.new(1, -28, 0, 62), Position = UDim2.fromOffset(14, 16),
        BackgroundColor3 = Colors.Card, BackgroundTransparency = 0.1, BorderSizePixel = 0, Active = true,
    }, Sidebar)
    Corner(LogoCard, 14)
    Gradient(LogoCard, WHITE, Colors.Shade, 90)
    Stroke(LogoCard, Colors.Accent, 1, 0.55)
    local logoTitle = Label(LogoCard, "ZUNI HUB", 24, WHITE, F_BLACK, UDim2.fromOffset(16, 7), UDim2.new(1, -24, 0, 30))
    Gradient(logoTitle, Colors.Text, Colors.AccentLight, 0)
    Label(LogoCard, "HUB  v" .. Z.Version, 10, Colors.AccentLight, F_MED, UDim2.fromOffset(17, 37), UDim2.new(1, -24, 0, 16))

    TabsScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -170), Position = UDim2.fromOffset(10, 94),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Accent, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Sidebar)
    New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, TabsScroll)
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3),
    }, TabsScroll)

    New("TextLabel", {
        BackgroundTransparency = 1, Text = "INSERT ou R-CTRL\nmostra / esconde o hub",
        Font = F_REG, TextSize = TS(10), TextColor3 = Colors.TextMuted, TextWrapped = true,
        Position = UDim2.new(0, 16, 1, -52), Size = UDim2.new(1, -28, 0, 38),
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    }, Sidebar)

    -- Conteúdo
    Content = New("Frame", { Size = UDim2.new(1, -200, 1, 0), Position = UDim2.fromOffset(200, 0), BackgroundTransparency = 1 }, Main)
    Header = New("Frame", { Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1, Active = true }, Content)
    TitleIconHolder = New("Frame", {
        Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(24, 18), BackgroundTransparency = 1,
    }, Header)
    TabTitle = Label(Header, "Home", 22, Colors.Text, F_BLACK, UDim2.fromOffset(64, 0), UDim2.new(1, -170, 1, 0))
    local hLine = New("Frame", {
        Size = UDim2.new(1, -40, 0, 2), Position = UDim2.fromOffset(20, 64), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, Content)
    Corner(hLine, 1)
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.Accent), ColorSequenceKeypoint.new(0.5, Colors.Purple), ColorSequenceKeypoint.new(1, Colors.Accent),
        }),
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0.95) }),
    }, hLine)

    Scroll = New("ScrollingFrame", {
        Size = UDim2.new(1, -40, 1, -92), Position = UDim2.fromOffset(20, 78),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, Content)
    New("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, Scroll)
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 14),
    }, Scroll)

    -- camada de popups (listas dos dropdowns): acima de tudo dentro do Main
    Popup = New("Frame", { Name = "Popup", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 50 }, Main)

    HeaderBtn("–", -90, function() Z.SetVisible(false) end)
    HeaderBtn("×", -50, function() Z.Destroy() end)

    MakeDraggable(Header, Main, nil, ClampMain)
    MakeDraggable(LogoCard, Main, nil, ClampMain)

    -- Bolha
    Bubble = New("TextButton", {
        Size = UDim2.fromOffset(58, 58), Position = savedBubblePos or UDim2.new(1, -94, 1, -136), Text = "",
        BackgroundTransparency = 1, AutoButtonColor = false, BorderSizePixel = 0, Visible = false, ZIndex = 50,
    }, Hub)
    local bubbleCircle = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, Bubble)
    Corner(bubbleCircle, 29)
    Gradient(bubbleCircle, Colors.Accent, Colors.Purple, 45)
    local bubbleStroke = Stroke(bubbleCircle, Colors.AccentLight, 2.5, 0.25)
    New("TextLabel", {
        Name = "Letter", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "Z",
        Font = F_BLACK, TextSize = TS(28), TextColor3 = Colors.OnAccent, ZIndex = 2,
    }, Bubble)
    Bubble.MouseEnter:Connect(function() Tween(bubbleStroke, 0.18, { Transparency = 0, Thickness = 4 }) end)
    Bubble.MouseLeave:Connect(function() Tween(bubbleStroke, 0.18, { Transparency = 0.25, Thickness = 2.5 }) end)
    MakeDraggable(Bubble, Bubble, function() Z.SetVisible(true) end)

    -- abas
    for _, name in ipairs(Z.TabOrder) do BuildTabButton(Z.Tabs[name]) end

    -- visibilidade
    if Z.IsVisible then
        Main.Visible = true
        WinScale.Scale = TargetScale()
        Bubble.Visible = false
    else
        Main.Visible = false
        Bubble.Visible = savedPos ~= nil
    end

    Z.GUI.Hub, Z.GUI.Main, Z.GUI.Sidebar, Z.GUI.Scroll, Z.GUI.Content, Z.GUI.TabTitle = Hub, Main, Sidebar, Scroll, Content, TabTitle
end

-- ═══════════════════════════════════════════════════════════════════════
-- WIDGETS
-- ═══════════════════════════════════════════════════════════════════════
local function CardHover(card, on)
    if not card.Parent then return end
    Tween(card, 0.18, { BackgroundColor3 = on and Colors.CardHover or Colors.Card })
end

local function Card(height)
    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Colors.Card, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, LayoutOrder = NextOrder(),
    }, Scroll)
    Corner(f, 14)
    Gradient(f, WHITE, Colors.Shade, 90)
    local st = Stroke(f, Colors.Border, 1, 0.5)
    f.MouseEnter:Connect(function() CardHover(f, true) end)
    f.MouseLeave:Connect(function() CardHover(f, false) end)
    return f, st
end
Z.Card = Card

function Z.Sep(text)
    local f = New("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = NextOrder() }, Scroll)
    local bar = New("Frame", {
        Size = UDim2.fromOffset(3, 16), Position = UDim2.fromOffset(4, 10), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, f)
    Corner(bar, 2)
    Gradient(bar, Colors.Accent, Colors.Purple, 90)
    Label(f, NoEmoji(text), 12, Colors.AccentLight, F_BOLD, UDim2.fromOffset(18, 6), UDim2.new(1, -18, 0, 24))
    local line = New("Frame", {
        Size = UDim2.new(1, -4, 0, 1), Position = UDim2.new(0, 2, 1, -4), BackgroundColor3 = Colors.Accent, BorderSizePixel = 0,
    }, f)
    New("UIGradient", {
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) }),
    }, line)
    return f
end

function Z.Info(text)
    local l = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Text = NoEmoji(text), Font = F_REG, TextSize = TS(12), TextColor3 = Colors.TextDim, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = NextOrder(),
        LineHeight = 1.3,
    }, Scroll)
    New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4) }, l)
    return l
end

function Z.Stat(name, value)
    local card = Card(46)
    Label(card, NoEmoji(name), 12, Colors.TextDim, F_MED, UDim2.fromOffset(18, 0), UDim2.new(0.5, -18, 1, 0))
    local v = Label(card, tostring(value), 14, Colors.Text, F_BOLD, UDim2.fromScale(0.5, 0), UDim2.new(0.5, -18, 1, 0), Enum.TextXAlignment.Right)
    return {
        Frame = card,
        Set = function(text, color)
            if not v.Parent then return end
            v.Text = tostring(text)
            if color then v.TextColor3 = color end
        end,
    }
end

function Z.Toggle(name, default, callback, desc)
    local card, st = Card(desc and 66 or 54)
    local state = not not default
    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, desc and 11 or 0), UDim2.new(1, -104, 0, desc and 20 or 54))
    if desc then Label(card, NoEmoji(desc), 11, Colors.TextDim, F_REG, UDim2.fromOffset(18, 35), UDim2.new(1, -104, 0, 20)) end

    local track = New("Frame", {
        Size = UDim2.fromOffset(48, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
        BackgroundColor3 = Colors.CardHover, BorderSizePixel = 0,
    }, card)
    Corner(track, 13)
    Gradient(track, WHITE, Shade(0), 90)
    local trackStroke = Stroke(track, Colors.Border, 1, 0.5)
    local knob = New("Frame", {
        Size = UDim2.fromOffset(20, 20), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, track)
    Corner(knob, 10)
    local knobStroke = Stroke(knob, Colors.Border, 1.5, 0.25)

    local function render(v, animate)
        if not card.Parent then return end
        local t = animate and 0.2 or 0
        Tween(track, t, { BackgroundColor3 = v and Colors.Accent or Colors.CardHover })
        Tween(trackStroke, t, { Color = v and Colors.AccentLight or Colors.Border, Transparency = v and 0.35 or 0.5 })
        Tween(knob, t, { Position = UDim2.new(0, v and 25 or 3, 0.5, 0) }, Enum.EasingStyle.Back)
        Tween(knobStroke, t, {
            Color = v and Colors.AccentLight or Colors.Border,
            Thickness = v and 2.5 or 1.5, Transparency = v and 0.05 or 0.25,
        })
        Tween(st, t, { Color = v and Colors.Accent or Colors.Border, Transparency = v and 0.3 or 0.5 })
    end
    render(state, false)

    local hit = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, card)
    hit.MouseEnter:Connect(function() CardHover(card, true) end)
    hit.MouseLeave:Connect(function() CardHover(card, false) end)
    hit.MouseButton1Click:Connect(function()
        state = not state
        render(state, true)
        Safe(callback, state)
    end)

    local obj = { Frame = card }
    function obj.Set(v, silent)
        v = not not v
        if v == state then return end
        state = v
        render(v, true)
        if not silent then Safe(callback, v) end
    end
    function obj.Get() return state end
    obj.SetState = obj.Set
    return obj
end

-- opts: step, suffix, onRelease(valor) — chamado quando o jogador solta o slider
function Z.Slider(name, min, max, default, callback, opts)
    opts = opts or {}
    local step, suffix = opts.step or 1, opts.suffix or ""
    local range = math.max(1e-6, max - min)
    local card = Card(74)

    local function snap(v)
        v = min + math.floor((v - min) / step + 0.5) * step
        return math.clamp(v, min, max)
    end
    local function fmt(v)
        if v == math.floor(v) then return tostring(v) end
        return string.format("%.2f", v)
    end
    local value = snap(default or min)

    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, 12), UDim2.new(1, -148, 0, 20))
    local valLbl = Label(card, "", 12, Colors.AccentLight, F_BLACK, UDim2.new(1, -18, 0, 11), UDim2.fromOffset(92, 22), Enum.TextXAlignment.Center)
    valLbl.AnchorPoint = Vector2.new(1, 0)
    valLbl.BackgroundTransparency = 0.2
    valLbl.BackgroundColor3 = Colors.CardSoft
    Corner(valLbl, 8)
    Stroke(valLbl, Colors.Accent, 1, 0.65)

    local track = New("Frame", {
        Size = UDim2.new(1, -36, 0, 8), Position = UDim2.fromOffset(18, 50), BackgroundColor3 = Colors.CardHover, BorderSizePixel = 0,
    }, card)
    Corner(track, 4)
    Stroke(track, Colors.BorderSoft, 1, 0.5)
    local fill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, track)
    Corner(fill, 4)
    Gradient(fill, Colors.AccentDark, Colors.Accent, 0)
    local knob = New("Frame", {
        Size = UDim2.fromOffset(18, 18), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 2,
    }, track)
    Corner(knob, 9)
    local knobStroke = Stroke(knob, Colors.Accent, 2, 0.1)

    local function render()
        local a = (value - min) / range
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, 0.5)
        valLbl.Text = fmt(value) .. suffix
    end
    render()

    local dragging = false
    local function fromX(x)
        local a = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
        local v = snap(min + range * a)
        if v ~= value then
            value = v
            render()
            Safe(callback, v)
        end
    end
    local hit = New("TextButton", {
        Size = UDim2.new(1, -20, 0, 34), Position = UDim2.fromOffset(10, 38),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
    }, card)
    hit.MouseEnter:Connect(function() CardHover(card, true) end)
    hit.MouseLeave:Connect(function() CardHover(card, false) end)
    hit.InputBegan:Connect(function(i)
        if IsPointer(i) then
            dragging = true
            Scroll.ScrollingEnabled = false
            Tween(knobStroke, 0.12, { Thickness = 3.5, Transparency = 0 })
            fromX(i.Position.X)
        end
    end)
    Z.PageTrack(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            fromX(i.Position.X)
        end
    end))
    Z.PageTrack(UIS.InputEnded:Connect(function(i)
        if dragging and IsPointer(i) then
            dragging = false
            Scroll.ScrollingEnabled = true
            Tween(knobStroke, 0.15, { Thickness = 2, Transparency = 0.1 })
            if opts.onRelease then Safe(opts.onRelease, value) end
        end
    end))

    local obj = { Frame = card }
    function obj.Set(v, silent)
        v = snap(v)
        if v == value then return end
        value = v
        render()
        if not silent then Safe(callback, v) end
    end
    function obj.Get() return value end
    return obj
end

-- Todos os botões têm o MESMO visual (o parâmetro color existe só por compatibilidade)
function Z.Button(name, color, callback)
    local b = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Colors.Card, BackgroundTransparency = 0.05,
        Text = NoEmoji(name), Font = F_BOLD, TextSize = TS(14), TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left, RichText = true, TextTruncate = Enum.TextTruncate.AtEnd,
        BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = NextOrder(),
    }, Scroll)
    Corner(b, 14)
    Gradient(b, WHITE, Shade(0.1), 90)
    local st = Stroke(b, Colors.Border, 1, 0.5)
    local press = New("UIScale", { Scale = 1 }, b)
    New("UIPadding", { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 48) }, b)

    New("ImageLabel", {
        Name = "MouseIcon", Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(1, 13, 0.5, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = MOUSE_ICON, ImageColor3 = Colors.Light and Colors.TextDim or WHITE, ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Fit, ZIndex = 2,
    }, b)

    local hovering = false
    b.MouseEnter:Connect(function()
        hovering = true
        Tween(b, 0.18, { BackgroundColor3 = Colors.CardHover })
        Tween(st, 0.18, { Color = Colors.Accent, Transparency = 0.2, Thickness = 1.5 })
    end)
    b.MouseLeave:Connect(function()
        hovering = false
        Tween(b, 0.18, { BackgroundColor3 = Colors.Card })
        Tween(st, 0.18, { Color = Colors.Border, Transparency = 0.5, Thickness = 1 })
        Tween(press, 0.12, { Scale = 1 })
    end)
    b.MouseButton1Down:Connect(function()
        Tween(press, 0.08, { Scale = 0.97 })
        Tween(b, 0.08, { BackgroundColor3 = Colors.Card:Lerp(BLACK, 0.2) })
    end)
    b.MouseButton1Up:Connect(function()
        Tween(press, 0.14, { Scale = 1 }, Enum.EasingStyle.Back)
        Tween(b, 0.14, { BackgroundColor3 = hovering and Colors.CardHover or Colors.Card })
    end)
    b.MouseButton1Click:Connect(function() Safe(callback) end)
    return b
end

-- ── Dropdowns ──────────────────────────────────────────────────────────
local function MakeSelect(card, selY, text, hasValue)
    local btn = New("TextButton", {
        Size = UDim2.new(1, -36, 0, 34), Position = UDim2.fromOffset(18, selY),
        BackgroundColor3 = Colors.Bg, BackgroundTransparency = 0.25, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
    }, card)
    Corner(btn, 10)
    Gradient(btn, WHITE, Shade(0), 90)
    local st = Stroke(btn, Colors.Border, 1, 0.35)

    local dot = New("Frame", {
        Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 13, 0.5, 0),
        BackgroundColor3 = Colors.Accent, BorderSizePixel = 0,
    }, btn)
    Corner(dot, 3)
    local val = Label(btn, text, 13, hasValue and Colors.Text or Colors.TextMuted, F_MED, UDim2.fromOffset(28, 0), UDim2.new(1, -72, 1, 0))

    New("Frame", {
        Size = UDim2.new(0, 1, 1, -14), Position = UDim2.new(1, -38, 0, 7),
        BackgroundColor3 = Colors.Border, BackgroundTransparency = 0.5, BorderSizePixel = 0,
    }, btn)
    local arrow = New("Frame", { Size = UDim2.fromOffset(38, 34), Position = UDim2.new(1, -38, 0, 0), BackgroundTransparency = 1 }, btn)
    local arrowIcon = DrawIcon(arrow, "chevron", 16, Colors.TextDim, UDim2.fromOffset(11, 9))

    local open = false
    arrow:GetPropertyChangedSignal("Rotation"):Connect(function()
        local o = arrow.Rotation > 90
        if o ~= open then
            open = o
            Tween(st, 0.15, { Color = open and Colors.Accent or Colors.Border, Transparency = open and 0.1 or 0.35 })
            arrowIcon.SetColor(open and Colors.AccentLight or Colors.TextDim, 0.15)
        end
    end)
    btn.MouseEnter:Connect(function()
        if open then return end
        Tween(btn, 0.15, { BackgroundTransparency = 0.1 })
        Tween(st, 0.15, { Color = Colors.Accent, Transparency = 0.3 })
    end)
    btn.MouseLeave:Connect(function()
        if open then return end
        Tween(btn, 0.15, { BackgroundTransparency = 0.25 })
        Tween(st, 0.15, { Color = Colors.Border, Transparency = 0.35 })
    end)
    return btn, val, arrow
end

local function MakeList(card)
    local catcher = New("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, Visible = false, ZIndex = 55,
    }, Popup)
    local holder = New("ScrollingFrame", {
        Size = UDim2.fromOffset(0, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Colors.Accent, ScrollBarImageTransparency = 0.35,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 60,
    }, Popup)
    Corner(holder, 14)
    Gradient(holder, Colors.Card, Colors.Bg, 90)
    local st = Stroke(holder, Colors.Accent, 1, 1)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, holder)
    New("UIPadding", {
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 8),
    }, holder)
    card.Destroying:Connect(function()
        pcall(function() holder:Destroy() end)
        pcall(function() catcher:Destroy() end)
    end)
    return holder, st, catcher
end

local function ShowList(holder, st, selectBtn, count)
    local want = math.min(220, count * 36 + 12)
    local sc = math.max(WinScale.Scale, 0.01)
    local bp = (selectBtn.AbsolutePosition - Main.AbsolutePosition) / sc
    local bs = selectBtn.AbsoluteSize / sc
    local w = math.min(WIN_W - 16, bs.X + 70)
    local x = math.clamp(bp.X - 35, 8, WIN_W - 8 - w)
    local spaceBelow = WIN_H - 8 - (bp.Y + bs.Y + 6)
    local spaceAbove = bp.Y - 6 - 8
    local up = want > spaceBelow and spaceAbove > spaceBelow
    local h = math.max(48, math.min(want, up and spaceAbove or spaceBelow))

    holder.AnchorPoint = Vector2.new(0, up and 1 or 0)
    holder.Position = UDim2.fromOffset(x, up and (bp.Y - 6) or (bp.Y + bs.Y + 6))
    holder.Size = UDim2.fromOffset(w, 0)
    holder.BackgroundTransparency = 1
    st.Transparency = 1
    holder.Visible = true
    Tween(holder, 0.24, { Size = UDim2.fromOffset(w, h), BackgroundTransparency = 0.02 }, Enum.EasingStyle.Quint)
    Tween(st, 0.24, { Transparency = 0.4 })
end

local function HideList(holder, st)
    Tween(holder, 0.16, { Size = UDim2.fromOffset(holder.Size.X.Offset, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    Tween(st, 0.16, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

local function MakeItem(parent, text, ord, selected, onClick)
    local restT = selected and 0.8 or 1
    local item = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = WHITE, BackgroundTransparency = restT,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = ord,
    }, parent)
    Corner(item, 9)
    Gradient(item, Colors.Accent, Colors.Purple, 0)
    local lbl = Label(item, tostring(text), 13, selected and Colors.AccentLight or Colors.TextDim,
        selected and F_BOLD or F_MED, UDim2.fromOffset(14, 0), UDim2.new(1, -38, 1, 0))
    if selected then
        local dot = New("Frame", {
            Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
            BackgroundColor3 = Colors.AccentLight, BorderSizePixel = 0,
        }, item)
        Corner(dot, 3)
    end
    item.MouseEnter:Connect(function()
        Tween(item, 0.12, { BackgroundTransparency = selected and 0.65 or 0.82 })
        Tween(lbl, 0.12, { TextColor3 = Colors.Text })
    end)
    item.MouseLeave:Connect(function()
        Tween(item, 0.12, { BackgroundTransparency = restT })
        Tween(lbl, 0.12, { TextColor3 = selected and Colors.AccentLight or Colors.TextDim })
    end)
    item.MouseButton1Click:Connect(onClick)
    return item
end

function Z.Dropdown(name, options, default, callback, desc)
    options = options or {}
    local selY = desc and 58 or 36
    local card = Card(selY + 34 + 12)

    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, 10), UDim2.new(1, -36, 0, 20))
    if desc then Label(card, NoEmoji(desc), 11, Colors.TextDim, F_REG, UDim2.fromOffset(18, 32), UDim2.new(1, -36, 0, 18)) end

    local selectBtn, valLbl, arrow = MakeSelect(card, selY, default and tostring(default) or "Selecionar...", default ~= nil)
    local listHolder, listStroke, catcher = MakeList(card)

    local selected, isOpen, itemButtons = default, false, {}

    local function CloseList()
        if not isOpen then return end
        isOpen = false
        catcher.Visible = false
        Tween(arrow, 0.2, { Rotation = 0 })
        HideList(listHolder, listStroke)
        task.delay(0.18, function() if not isOpen and listHolder.Parent then listHolder.Visible = false end end)
    end

    local function RenderItems()
        for _, b in ipairs(itemButtons) do b:Destroy() end
        table.clear(itemButtons)
        for i, opt in ipairs(options) do
            local item = MakeItem(listHolder, opt, i, opt == selected, function()
                selected = opt
                valLbl.Text, valLbl.TextColor3 = tostring(opt), Colors.Text
                CloseList()
                Safe(callback, opt)
            end)
            table.insert(itemButtons, item)
        end
    end
    RenderItems()

    local function OpenList()
        if isOpen or #options == 0 then return end
        RenderItems()
        isOpen = true
        catcher.Visible = true
        ShowList(listHolder, listStroke, selectBtn, #options)
        Tween(arrow, 0.2, { Rotation = 180 })
    end

    catcher.MouseButton1Click:Connect(CloseList)
    selectBtn.MouseButton1Click:Connect(function() if isOpen then CloseList() else OpenList() end end)

    local obj = { Frame = card }
    function obj.SetOptions(newOptions)
        local wasOpen = isOpen
        options = newOptions or {}
        RenderItems()
        if selected ~= nil and not table.find(options, selected) then
            selected = nil
            valLbl.Text, valLbl.TextColor3 = "Selecionar...", Colors.TextMuted
        end
        if wasOpen then isOpen = false; OpenList() end
    end
    function obj.Get() return selected end
    function obj.Set(v, silent)
        selected = v
        valLbl.Text = v and tostring(v) or "Selecionar..."
        valLbl.TextColor3 = v and Colors.Text or Colors.TextMuted
        if not silent then Safe(callback, v) end
    end
    return obj
end

function Z.PlayerDropdown(name, callback, desc)
    local selY = desc and 58 or 36
    local card = Card(selY + 34 + 12)

    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, 10), UDim2.new(1, -36, 0, 20))
    if desc then Label(card, NoEmoji(desc), 11, Colors.TextDim, F_REG, UDim2.fromOffset(18, 32), UDim2.new(1, -36, 0, 18)) end

    local selectBtn, valLbl, arrow = MakeSelect(card, selY, "Selecionar jogador...", false)
    local listHolder, listStroke, catcher = MakeList(card)

    local selected, isOpen, itemButtons = nil, false, {}

    local function CloseList()
        if not isOpen then return end
        isOpen = false
        catcher.Visible = false
        Tween(arrow, 0.2, { Rotation = 0 })
        HideList(listHolder, listStroke)
        task.delay(0.18, function() if not isOpen and listHolder.Parent then listHolder.Visible = false end end)
    end

    local function RenderItems()
        for _, b in ipairs(itemButtons) do b:Destroy() end
        table.clear(itemButtons)
        for i, p in ipairs(Players:GetPlayers()) do
            if p ~= Player then
                local item = MakeItem(listHolder, p.Name, i, p == selected, function()
                    selected = p
                    valLbl.Text, valLbl.TextColor3 = p.Name, Colors.Text
                    CloseList()
                    Safe(callback, p)
                end)
                table.insert(itemButtons, item)
            end
        end
    end

    local function OpenList()
        if isOpen then return end
        RenderItems()
        if #itemButtons == 0 then
            Z.Notify("Players", "Nenhum outro jogador no servidor.", Colors.Warning, 2)
            return
        end
        isOpen = true
        catcher.Visible = true
        ShowList(listHolder, listStroke, selectBtn, #itemButtons)
        Tween(arrow, 0.2, { Rotation = 180 })
    end

    catcher.MouseButton1Click:Connect(CloseList)
    selectBtn.MouseButton1Click:Connect(function() if isOpen then CloseList() else OpenList() end end)

    Z.PageTrack(Players.PlayerAdded:Connect(function() if isOpen then RenderItems() end end))
    Z.PageTrack(Players.PlayerRemoving:Connect(function(p)
        if selected == p then
            selected = nil
            valLbl.Text, valLbl.TextColor3 = "Selecionar jogador...", Colors.TextMuted
        end
        if isOpen then RenderItems() end
    end))

    local obj = { Frame = card }
    function obj.Get() return selected end
    function obj.Set(p, silent)
        selected = p
        valLbl.Text = p and p.Name or "Selecionar jogador..."
        valLbl.TextColor3 = p and Colors.Text or Colors.TextMuted
        if not silent then Safe(callback, p) end
    end
    return obj
end

-- ═══════════════════════════════════════════════════════════════════════
-- MOSTRAR / ESCONDER, ABAS, REBUILD
-- ═══════════════════════════════════════════════════════════════════════
local animToken = 0
function Z.SetVisible(v)
    if not Z.Alive then return end
    v = not not v
    if v == Z.IsVisible then return end
    Z.IsVisible = v
    animToken += 1
    local my = animToken
    if v then
        Bubble.Visible = false
        WinScale.Scale = 0.6
        Main.Visible = true
        Tween(WinScale, 0.32, { Scale = TargetScale() }, Enum.EasingStyle.Quint)
    else
        Tween(WinScale, 0.22, { Scale = 0.01 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.23, function()
            if animToken == my and Z.Alive then
                Main.Visible = false
                Bubble.Visible = true
            end
        end)
    end
end
function Z.ToggleVisible() Z.SetVisible(not Z.IsVisible) end

function Z.ApplyScale()
    if Z.Alive and Z.IsVisible and WinScale and WinScale.Parent then
        Tween(WinScale, 0.25, { Scale = TargetScale() }, Enum.EasingStyle.Quint)
    end
end

function Z.AddTab(name, icon, callback)
    local existing = Z.Tabs[name]
    if existing then existing.Callback = callback return existing end
    local tab = {
        Name = name, IconSpec = icon, Callback = callback, DisplayName = NoEmoji(name),
        Order = (name == "Settings") and 100000 or (#Z.TabOrder + 1),   -- Settings sempre por último
    }
    Z.Tabs[name] = tab
    table.insert(Z.TabOrder, name)
    if TabsScroll and TabsScroll.Parent then BuildTabButton(tab) end
    return tab
end

function Z.SelectTab(name)
    local tab = Z.Tabs[name]
    if not tab then return end
    local old = Z.Tabs[Z.CurrentTab]
    if old and old ~= tab then StyleTab(old, false) end
    Z.CurrentTab = name
    StyleTab(tab, true)
    TabTitle.Text = tab.DisplayName
    if TitleIcon then pcall(function() TitleIcon.Root:Destroy() end) end
    TitleIcon = MakeIcon(TitleIconHolder, tab.IconSpec, 26, Colors.AccentLight, UDim2.fromOffset(1, 1), tab.Name)

    Z.GUI.Clear()
    if tab.Callback then
        local ok, err = xpcall(tab.Callback, function(e)
            warn("[Zuni] Erro na aba '" .. name .. "': " .. tostring(e) .. "\n" .. debug.traceback())
            return tostring(e)
        end)
        if not ok then
            Z.Info("Erro ao carregar esta aba:")
            Z.Info(tostring(err))
        end
    end
end

-- Recria a janela inteira (usado quando tema/fonte mudam) e reabre a aba atual
function Z.Rebuild()
    if not Z.Alive then return end
    local pos = Main and Main.Position
    local bpos = Bubble and Bubble.Position
    local keepScroll = Scroll and Scroll.CanvasPosition or Vector2.zero
    BuildWindow(pos, bpos)
    if Z.CurrentTab and Z.Tabs[Z.CurrentTab] then
        Z.SelectTab(Z.CurrentTab)
        task.delay(0.05, function()
            if Z.Alive and Scroll and Scroll.Parent then Scroll.CanvasPosition = keepScroll end
        end)
    end
end

function Z.ApplyTheme()
    ApplyPalette()
    Z.Rebuild()
end
function Z.ApplyFont()
    SetFont(Cfg.font)
    Z.Rebuild()
end
function Z.ApplyAll()
    ApplyPalette()
    SetFont(Cfg.font)
    Z.Rebuild()
    Z.ApplyScale()
end

-- ═══════════════════════════════════════════════════════════════════════
-- ENCERRAR
-- ═══════════════════════════════════════════════════════════════════════
function Z.Destroy()
    if not Z.Alive then return end
    Z.Alive = false
    for _, fn in ipairs(Z.Cleanups) do pcall(fn) end
    Z.DisconnectAll()
    for _, c in ipairs(PageConns) do pcall(function() c:Disconnect() end) end
    for _, c in ipairs(WinConns) do pcall(function() c:Disconnect() end) end
    pcall(function() Hub:Destroy() end)
    pcall(function() ESPGui:Destroy() end)
    pcall(function() NotifyGui:Destroy() end)
    if _G.ZuniHub == Z then _G.ZuniHub = nil end
end

-- Atalhos de teclado + FPS
Z.Track(UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not Z.Alive then return end
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl then
        Z.ToggleVisible()
    end
end))
Z.Track(RunService.Heartbeat:Connect(function(dt)
    if dt > 0 then Z.FPS = Z.FPS * 0.92 + (1 / dt) * 0.08 end
end))
do
    local cam = workspace.CurrentCamera
    if cam then Z.Track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() Z.ApplyScale() end)) end
end

BuildWindow(nil, nil)

-- ═══════════════════════════════════════════════════════════════════════
-- MOVIMENTO (WalkSpeed/JumpPower em loop, Fly, Noclip, TPWalk, Inf Jump)
-- Estado fora do SavedStates de propósito: o ETW salva o S inteiro em JSON e
-- não queremos fly/noclip voltando ligados sozinhos ao reexecutar.
-- ═══════════════════════════════════════════════════════════════════════
local M = {
    speedOn = false, spd = 16, jumpOn = false, jmp = 50, infJump = false, antiAfk = true,
    fly = false, flySpeed = 60, noclip = false, tpwalk = false, tpSpeed = 60,
}
Z.Move = M

local function GetHum() local c = Player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function GetHRP() local c = Player.Character return c and c:FindFirstChild("HumanoidRootPart") end

do
    local origWS, origJP = 16, 50
    local humConns = {}
    local fly = { bv = nil, bg = nil }
    local controlsObj = nil

    -- Aplica o valor do slider sempre que o jogo (ou outro script) mudar
    local function Enforce()
        local hum = GetHum()
        if not hum then return end
        if M.speedOn and hum.WalkSpeed ~= M.spd then hum.WalkSpeed = M.spd end
        if M.jumpOn then
            if not hum.UseJumpPower then hum.UseJumpPower = true end
            if hum.JumpPower ~= M.jmp then hum.JumpPower = M.jmp end
        end
    end

    local function HookHum(hum)
        for _, c in ipairs(humConns) do pcall(function() c:Disconnect() end) end
        table.clear(humConns)
        if not hum then return end
        table.insert(humConns, hum:GetPropertyChangedSignal("WalkSpeed"):Connect(Enforce))
        table.insert(humConns, hum:GetPropertyChangedSignal("JumpPower"):Connect(Enforce))
        table.insert(humConns, hum:GetPropertyChangedSignal("UseJumpPower"):Connect(Enforce))
        Enforce()
    end
    local function OnChar(char)
        task.spawn(function()
            local hum = char:WaitForChild("Humanoid", 10)
            if hum and Z.Alive then HookHum(hum) end
        end)
    end
    if Player.Character then OnChar(Player.Character) end
    Z.Track(Player.CharacterAdded:Connect(OnChar))

    function Z.SetSpeedLoop(v)
        local hum = GetHum()
        if v and not M.speedOn and hum then origWS = hum.WalkSpeed end
        M.speedOn = v
        if v then Enforce() elseif hum then hum.WalkSpeed = origWS end
    end
    function Z.SetJumpLoop(v)
        local hum = GetHum()
        if v and not M.jumpOn and hum then origJP = hum.JumpPower end
        M.jumpOn = v
        if v then Enforce() elseif hum then hum.JumpPower = origJP end
    end
    function Z.EnforceMovement() Enforce() end

    -- Fly ------------------------------------------------------------------
    local function FlyParts()
        if fly.bv then pcall(function() fly.bv:Destroy() end) fly.bv = nil end
        if fly.bg then pcall(function() fly.bg:Destroy() end) fly.bg = nil end
    end
    function Z.FlyCleanup()
        FlyParts()
        local hum = GetHum()
        if hum then pcall(function() hum.PlatformStand = false end) end
    end

    local function MoveVector()
        if controlsObj == nil then
            local ok, c = pcall(function()
                return require(Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 2)):GetControls()
            end)
            controlsObj = ok and c or false
        end
        if controlsObj then
            local ok, v = pcall(function() return controlsObj:GetMoveVector() end)
            if ok and typeof(v) == "Vector3" then return v end
        end
        local x = (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
        local z = (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
        return Vector3.new(x, 0, z)
    end

    local function FlyStep()
        local hrp, hum, cam = GetHRP(), GetHum(), workspace.CurrentCamera
        if not (hrp and hum and cam) or hum.Health <= 0 then return end
        if not fly.bv or fly.bv.Parent ~= hrp then
            FlyParts()
            fly.bv = New("BodyVelocity", { MaxForce = Vector3.new(9e9, 9e9, 9e9), Velocity = Vector3.zero, P = 1e4 }, hrp)
            fly.bg = New("BodyGyro", { MaxTorque = Vector3.new(9e9, 9e9, 9e9), P = 9e4, D = 1e3, CFrame = cam.CFrame }, hrp)
        end
        hum.PlatformStand = true
        local mv = MoveVector()
        local dir = cam.CFrame:VectorToWorldSpace(Vector3.new(mv.X, 0, mv.Z))
        local up = (UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E)) and 1 or 0
        local down = (UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl)) and 1 or 0
        fly.bv.Velocity = dir * M.flySpeed + Vector3.new(0, (up - down) * M.flySpeed, 0)
        fly.bg.CFrame = cam.CFrame
    end

    Z.Track(RunService.Heartbeat:Connect(function(dt)
        pcall(Enforce)
        if M.fly then pcall(FlyStep) end
        if M.tpwalk then
            local hum, hrp = GetHum(), GetHRP()
            if hum and hrp and hum.Health > 0 and not hrp.Anchored then
                local md = hum.MoveDirection
                if md.Magnitude > 0 then hrp.CFrame = hrp.CFrame + md * M.tpSpeed * dt end
            end
        end
    end))
    Z.Track(RunService.Stepped:Connect(function()
        pcall(Enforce)
        if M.noclip then
            local c = Player.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end
    end))
    Z.Track(UIS.JumpRequest:Connect(function()
        if not M.infJump then return end
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end))
    Z.Track(Player.Idled:Connect(function()
        if not M.antiAfk then return end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end))

    Z.OnDestroy(function()
        for _, c in ipairs(humConns) do pcall(function() c:Disconnect() end) end
        M.fly, M.noclip, M.tpwalk = false, false, false
        Z.FlyCleanup()
        local hum = GetHum()
        if hum then
            if M.speedOn then hum.WalkSpeed = origWS end
            if M.jumpOn then hum.JumpPower = origJP end
        end
        M.speedOn, M.jumpOn = false, false
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════════════════════════════════
local ESP_COLOR_ORDER = { "Tema", "Vermelho", "Verde", "Azul", "Amarelo", "Branco", "Ciano", "Rosa", "Roxo", "Laranja" }
local ESP_RGB = {
    Vermelho = C3(255, 70, 70), Verde = C3(70, 255, 120), Azul = C3(80, 150, 255), Amarelo = C3(255, 220, 70),
    Branco = C3(255, 255, 255), Ciano = C3(70, 235, 235), Rosa = C3(255, 110, 200), Roxo = C3(170, 110, 255), Laranja = C3(255, 150, 60),
}
local TRACER_ORIGINS = { "Baixo", "Centro", "Topo", "Mouse" }
local NAME_MODES = { "Display", "Usuario" }
local function EspColor(name)
    if name == "Tema" then return Colors.Accent end
    return ESP_RGB[name] or WHITE
end

do
    local ESPObjs = {}

    local function ESPHide(o)
        o.hl.Enabled = false
        o.box.Enabled = false
        o.info.Enabled = false
        o.line.Visible = false
    end

    local function ESPDestroy(plr)
        local o = ESPObjs[plr]
        if not o then return end
        for _, k in ipairs({ "hl", "box", "info", "line" }) do
            if o[k] then pcall(function() o[k]:Destroy() end) end
        end
        ESPObjs[plr] = nil
    end

    local function ESPCreate(plr)
        if plr == Player or ESPObjs[plr] then return end
        local o = {}
        o.hl = New("Highlight", {
            Name = "ZuniHL", Enabled = false, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            FillTransparency = 0.6, OutlineTransparency = 0, FillColor = WHITE, OutlineColor = WHITE,
        }, ESPGui)

        o.box = New("BillboardGui", {
            Name = "ZuniBox", AlwaysOnTop = true, Size = UDim2.new(4, 0, 6, 0), LightInfluence = 0, Enabled = false,
        }, ESPGui)
        local boxFrame = New("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, o.box)
        o.boxStroke = Stroke(boxFrame, WHITE, 1.5, 0)

        o.info = New("BillboardGui", {
            Name = "ZuniInfo", AlwaysOnTop = true, Size = UDim2.new(0, 200, 0, 60), StudsOffset = Vector3.new(0, 1.9, 0),
            LightInfluence = 0, Enabled = false,
        }, ESPGui)
        local holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, o.info)
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 1),
        }, holder)
        local function Txt(ord)
            return New("TextLabel", {
                BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Font = F_BOLD, TextSize = 13, TextColor3 = WHITE,
                TextStrokeTransparency = 0.35, TextStrokeColor3 = BLACK, LayoutOrder = ord, Text = "",
            }, holder)
        end
        o.name = Txt(1)
        o.hpBack = New("Frame", {
            Size = UDim2.fromOffset(84, 6), BackgroundColor3 = BLACK, BackgroundTransparency = 0.35, BorderSizePixel = 0, LayoutOrder = 2,
        }, holder)
        Corner(o.hpBack, 3)
        o.hpFill = New("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Colors.Success, BorderSizePixel = 0 }, o.hpBack)
        Corner(o.hpFill, 3)
        o.hpText = Txt(3)
        o.dist = Txt(4)

        o.line = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0, Visible = false,
            Size = UDim2.fromOffset(0, 1.5),
        }, ESPGui)
        ESPObjs[plr] = o
    end

    local warned = false
    local function ESPStep()
        local E = Cfg.esp
        local cam = workspace.CurrentCamera
        if not E.enabled or not cam then
            for _, o in pairs(ESPObjs) do ESPHide(o) end
            return
        end
        local myChar = Player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local origin = myHrp and myHrp.Position or cam.CFrame.Position
        local vp = cam.ViewportSize
        local tracerFrom
        if E.tracerOrigin == "Centro" then tracerFrom = vp / 2
        elseif E.tracerOrigin == "Topo" then tracerFrom = Vector2.new(vp.X / 2, 0)
        elseif E.tracerOrigin == "Mouse" then tracerFrom = UIS:GetMouseLocation()
        else tracerFrom = Vector2.new(vp.X / 2, vp.Y) end

        for plr, o in pairs(ESPObjs) do
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local show = hrp ~= nil and hum ~= nil and hum.Health > 0
            if show and E.teamCheck and Player.Team ~= nil and plr.Team == Player.Team then show = false end
            local dist = show and (hrp.Position - origin).Magnitude or 0
            if show and dist > E.maxDist then show = false end

            if not show then
                ESPHide(o)
            else
                local main = (E.useTeamColor and plr.Team) and plr.TeamColor.Color or EspColor(E.mainColor)

                -- highlight
                if o.hl.Adornee ~= char then o.hl.Adornee = char end
                o.hl.Enabled = E.highlight
                if E.highlight then
                    o.hl.FillColor = (E.useTeamColor and plr.Team) and main or EspColor(E.fillColor)
                    o.hl.OutlineColor = (E.useTeamColor and plr.Team) and main or EspColor(E.outlineColor)
                    o.hl.FillTransparency = 1 - math.clamp(E.fillAlpha, 0, 100) / 100
                end

                -- caixa
                o.box.Enabled = E.box
                if E.box then
                    if o.box.Adornee ~= hrp then o.box.Adornee = hrp end
                    o.boxStroke.Color = main
                end

                -- informações
                local infoOn = E.names or E.health or E.healthText or E.distance
                o.info.Enabled = infoOn
                if infoOn then
                    local ad = char:FindFirstChild("Head") or hrp
                    if o.info.Adornee ~= ad then o.info.Adornee = ad end
                    local ts = math.clamp(E.textSize, 9, 24)
                    o.name.Visible = E.names
                    if E.names then
                        o.name.Text = (E.nameMode == "Usuario") and plr.Name or plr.DisplayName
                        o.name.TextColor3 = main
                        o.name.Font = F_BOLD
                        o.name.TextSize = ts
                    end
                    local pct = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
                    o.hpBack.Visible = E.health
                    if E.health then
                        o.hpFill.Size = UDim2.fromScale(pct, 1)
                        o.hpFill.BackgroundColor3 = Color3.fromHSV(0.33 * pct, 0.85, 1)
                    end
                    o.hpText.Visible = E.healthText
                    if E.healthText then
                        o.hpText.Text = string.format("%d/%d HP", math.floor(hum.Health + 0.5), math.floor(hum.MaxHealth + 0.5))
                        o.hpText.TextColor3 = Color3.fromHSV(0.33 * pct, 0.6, 1)
                        o.hpText.Font = F_MED
                        o.hpText.TextSize = ts - 1
                    end
                    o.dist.Visible = E.distance
                    if E.distance then
                        o.dist.Text = string.format("%d studs", math.floor(dist + 0.5))
                        o.dist.TextColor3 = WHITE
                        o.dist.Font = F_MED
                        o.dist.TextSize = ts - 1
                    end
                end

                -- tracer
                if E.tracers then
                    local v = cam:WorldToViewportPoint(hrp.Position)
                    if v.Z > 0 then
                        local b = Vector2.new(v.X, v.Y)
                        local d = b - tracerFrom
                        o.line.Visible = true
                        o.line.Position = UDim2.fromOffset((tracerFrom.X + b.X) / 2, (tracerFrom.Y + b.Y) / 2)
                        o.line.Size = UDim2.fromOffset(d.Magnitude, 1.5)
                        o.line.Rotation = math.deg(math.atan2(d.Y, d.X))
                        o.line.BackgroundColor3 = main
                    else
                        o.line.Visible = false
                    end
                else
                    o.line.Visible = false
                end
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do ESPCreate(p) end
    Z.Track(Players.PlayerAdded:Connect(ESPCreate))
    Z.Track(Players.PlayerRemoving:Connect(ESPDestroy))
    Z.Track(RunService.RenderStepped:Connect(function()
        local ok, err = pcall(ESPStep)
        if not ok and not warned then
            warned = true
            warn("[ZuniHub] ESP: " .. tostring(err))
        end
    end))
    Z.OnDestroy(function()
        for plr in pairs(ESPObjs) do ESPDestroy(plr) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ABA HOME
-- ═══════════════════════════════════════════════════════════════════════
local function FmtTime(sec)
    sec = math.floor(sec)
    return string.format("%02d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
end

local function LoadHome()
    local hero = Card(102)
    local stripe = New("Frame", {
        Size = UDim2.new(0, 4, 1, -28), Position = UDim2.fromOffset(12, 14), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, hero)
    Corner(stripe, 2)
    Gradient(stripe, Colors.Accent, Colors.Purple, 90)
    Label(hero, "Bem-vindo, " .. Player.DisplayName, 20, Colors.Text, F_BLACK, UDim2.fromOffset(28, 14), UDim2.new(1, -44, 0, 28))
    New("TextLabel", {
        BackgroundTransparency = 1, Font = F_REG, TextSize = TS(12), TextColor3 = Colors.TextDim, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LineHeight = 1.3,
        Text = "Escolha uma aba ao lado para começar. Minimize com – para virar uma bolha arrastável. Cores, fonte e tamanho ficam em Settings.",
        Position = UDim2.fromOffset(28, 46), Size = UDim2.new(1, -44, 0, 48),
    }, hero)

    Z.Sep("INFORMAÇÕES")
    Z.Stat("Jogador", Player.Name)
    local stGame = Z.Stat("Jogo", tostring(game.PlaceId))
    Z.Stat("Módulo carregado", Z.ModuleName)
    Z.Stat("Preset de cores", Cfg.theme)
    local stFps  = Z.Stat("FPS", "—")
    local stPing = Z.Stat("Ping", "—")
    local stTime = Z.Stat("Tempo de uso", "00:00:00")

    task.spawn(function()
        local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
        if ok and info and info.Name then stGame.Set(info.Name) end
    end)
    Z.PageLoop(0.5, function()
        local fps = math.floor(Z.FPS + 0.5)
        stFps.Set(fps, fps >= 50 and Colors.Success or (fps >= 30 and Colors.Warning or Colors.Danger))
        local okp, ping = pcall(function() return Player:GetNetworkPing() * 1000 end)
        if okp then
            ping = math.floor(ping)
            stPing.Set(ping .. " ms", ping <= 100 and Colors.Success or (ping <= 200 and Colors.Warning or Colors.Danger))
        end
        stTime.Set(FmtTime(tick() - Z.StartTime))
    end)

    Z.Sep("ATALHOS")
    Z.Info("INSERT ou RIGHT CTRL: mostrar / esconder o hub.\nArraste o topo da janela para mover. Use – para minimizar.")
end

-- ═══════════════════════════════════════════════════════════════════════
-- ABA PLAYER
-- ═══════════════════════════════════════════════════════════════════════
local function LoadPlayer()
    Z.Sep("MOVIMENTO (LOOP)")
    Z.Toggle("WalkSpeed em loop", M.speedOn, function(v) Z.SetSpeedLoop(v) end,
        "Reaplica o valor do slider sempre que o jogo mudar")
    Z.Slider("Velocidade (WalkSpeed)", 16, 500, M.spd, function(v) M.spd = v; Z.EnforceMovement() end)
    Z.Toggle("JumpPower em loop", M.jumpOn, function(v) Z.SetJumpLoop(v) end,
        "Reaplica o valor do slider sempre que o jogo mudar")
    Z.Slider("Força do pulo (JumpPower)", 50, 500, M.jmp, function(v) M.jmp = v; Z.EnforceMovement() end)
    Z.Toggle("Pulo infinito", M.infJump, function(v) M.infJump = v end, "Pule no ar quantas vezes quiser")

    Z.Sep("VOO / ATRAVESSAR")
    Z.Toggle("Fly", M.fly, function(v)
        M.fly = v
        if not v then Z.FlyCleanup() end
    end, "WASD move pela câmera • Espaço/E sobe • Q/Ctrl desce")
    Z.Slider("Velocidade do Fly", 10, 300, M.flySpeed, function(v) M.flySpeed = v end, { step = 5, suffix = " studs/s" })
    Z.Toggle("Noclip", M.noclip, function(v) M.noclip = v end, "Atravessa paredes e objetos")

    Z.Sep("TPWALK")
    Z.Toggle("TPWalk", M.tpwalk, function(v) M.tpwalk = v end, "Anda teleportando um pouco a cada frame na direção do movimento")
    Z.Slider("Velocidade do TPWalk", 10, 300, M.tpSpeed, function(v) M.tpSpeed = v end, { step = 5, suffix = " studs/s" })

    Z.Sep("UTILIDADES")
    Z.Toggle("Anti-AFK", M.antiAfk, function(v) M.antiAfk = v end, "Evita ser kickado por ficar parado")

    Z.Sep("AÇÕES")
    Z.Button("Resetar valores de movimento", Colors.AccentDark, function()
        Z.SetSpeedLoop(false)
        Z.SetJumpLoop(false)
        M.infJump, M.fly, M.noclip, M.tpwalk = false, false, false, false
        M.spd, M.jmp, M.flySpeed, M.tpSpeed = 16, 50, 60, 60
        Z.FlyCleanup()
        Z.Notify("Player", "Valores resetados.", Colors.Success, 2)
        Z.SelectTab("Player")
    end)
    Z.Button("Resetar personagem", Colors.Warning, function()
        local h = GetHum()
        if h then h.Health = 0 end
    end)
    Z.Button("Rejoin (reentrar no servidor)", Colors.Danger, function()
        Z.Confirm("Reentrar no servidor?", "Você vai ser teleportado para uma nova instância deste jogo.", function()
            Z.Notify("Rejoin", "Reconectando...", Colors.Warning, 3)
            pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
        end, "Reentrar", "Cancelar")
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ABA MISC. (ESP)
-- ═══════════════════════════════════════════════════════════════════════
local function LoadMisc()
    local E = Cfg.esp
    local function Flag(key) return function(v) E[key] = v; SaveCfg() end end

    Z.Sep("ESP")
    Z.Toggle("Ativar ESP", E.enabled, Flag("enabled"), "Liga/desliga tudo abaixo")
    Z.Toggle("Ignorar meu time", E.teamCheck, Flag("teamCheck"), "Não mostra jogadores do mesmo time")

    Z.Sep("INFORMAÇÕES")
    Z.Toggle("Nome", E.names, Flag("names"), "Nome acima da cabeça")
    Z.Dropdown("Tipo de nome", NAME_MODES, E.nameMode, function(v) E.nameMode = v; SaveCfg() end, "Display = nome de exibição • Usuario = @username")
    Z.Toggle("Barra de vida", E.health, Flag("health"), "Barra colorida conforme a vida")
    Z.Toggle("Vida em número", E.healthText, Flag("healthText"), "Mostra vida/máx (HP)")
    Z.Toggle("Distância", E.distance, Flag("distance"), "Distância em studs até você")

    Z.Sep("VISUAL")
    Z.Toggle("Highlight", E.highlight, Flag("highlight"), "Contorno e preenchimento no corpo (visível pelas paredes)")
    Z.Toggle("Caixa (Box)", E.box, Flag("box"), "Caixa 2D ao redor do jogador")
    Z.Toggle("Tracers", E.tracers, Flag("tracers"), "Linha da tela até o jogador")
    Z.Dropdown("Origem do tracer", TRACER_ORIGINS, E.tracerOrigin, function(v) E.tracerOrigin = v; SaveCfg() end)

    Z.Sep("CORES")
    Z.Toggle("Usar cor do time", E.useTeamColor, Flag("useTeamColor"), "Se o jogador tiver time, usa a cor dele em tudo")
    Z.Dropdown("Cor principal", ESP_COLOR_ORDER, E.mainColor, function(v) E.mainColor = v; SaveCfg() end, "Nome, caixa e tracer (Tema = cor de destaque da UI)")
    Z.Dropdown("Cor do preenchimento", ESP_COLOR_ORDER, E.fillColor, function(v) E.fillColor = v; SaveCfg() end, "Preenchimento do highlight")
    Z.Dropdown("Cor do contorno", ESP_COLOR_ORDER, E.outlineColor, function(v) E.outlineColor = v; SaveCfg() end, "Contorno do highlight")
    Z.Slider("Opacidade do preenchimento", 0, 100, E.fillAlpha, function(v) E.fillAlpha = v end,
        { step = 5, suffix = " %", onRelease = function() SaveCfg() end })

    Z.Sep("AJUSTES")
    Z.Slider("Distância máxima", 100, 5000, E.maxDist, function(v) E.maxDist = v end,
        { step = 50, suffix = " studs", onRelease = function() SaveCfg() end })
    Z.Slider("Tamanho do texto", 10, 22, E.textSize, function(v) E.textSize = v end,
        { suffix = " px", onRelease = function() SaveCfg() end })
    Z.Button("Restaurar padrões do ESP", Colors.AccentDark, function()
        Cfg.esp = DefaultESP()
        SaveCfg()
        Z.Notify("ESP", "Configurações restauradas.", Colors.Success, 2)
        Z.SelectTab("Misc.")
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ABA SETTINGS (sempre a última)
-- ═══════════════════════════════════════════════════════════════════════
local function LoadSettings()
    local function Later(fn) task.defer(function() Safe(fn) end) end

    Z.Sep("TEMA")
    Z.Dropdown("Preset de cores", THEME_ORDER, Cfg.theme, function(v)
        if v == Cfg.theme then return end
        Cfg.theme = v
        SaveCfg()
        Later(Z.ApplyTheme)
    end, "Eclipse • Cherry • Pudding")

    local pal = Card(46)
    Label(pal, "Paleta atual", 12, Colors.TextDim, F_MED, UDim2.fromOffset(18, 0), UDim2.new(0.4, -18, 1, 0))
    local dots = { Colors.Accent, Colors.Purple, Colors.Success, Colors.Warning, Colors.Danger }
    for i, c in ipairs(dots) do
        local d = New("Frame", {
            Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -18 - (#dots - i) * 30, 0.5, 0), BackgroundColor3 = c, BorderSizePixel = 0,
        }, pal)
        Corner(d, 11)
        Stroke(d, Colors.Border, 1, 0.4)
    end

    Z.Sep("COR DE DESTAQUE PERSONALIZADA")
    Z.Info("Substitui a cor de destaque (botões ativos, sliders, popups) por uma cor sua. As outras cores seguem o preset. Aplica ao soltar o slider.")
    Z.Toggle("Usar cor personalizada", Cfg.customOn, function(v)
        Cfg.customOn = v
        SaveCfg()
        Later(Z.ApplyTheme)
    end)

    local swatchCard = Card(46)
    Label(swatchCard, "Prévia da cor", 12, Colors.TextDim, F_MED, UDim2.fromOffset(18, 0), UDim2.new(0.4, -18, 1, 0))
    local swatch = New("Frame", {
        Size = UDim2.fromOffset(120, 24), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
        BackgroundColor3 = C3(Cfg.cr, Cfg.cg, Cfg.cb), BorderSizePixel = 0,
    }, swatchCard)
    Corner(swatch, 8)
    Stroke(swatch, Colors.Border, 1, 0.4)
    local function Preview() swatch.BackgroundColor3 = C3(Cfg.cr, Cfg.cg, Cfg.cb) end
    local function Commit()
        Cfg.customOn = true
        SaveCfg()
        Later(Z.ApplyTheme)
    end
    Z.Slider("Vermelho (R)", 0, 255, Cfg.cr, function(v) Cfg.cr = v; Preview() end, { onRelease = Commit })
    Z.Slider("Verde (G)", 0, 255, Cfg.cg, function(v) Cfg.cg = v; Preview() end, { onRelease = Commit })
    Z.Slider("Azul (B)", 0, 255, Cfg.cb, function(v) Cfg.cb = v; Preview() end, { onRelease = Commit })
    Z.Button("Voltar para a cor do preset", Colors.AccentDark, function()
        Cfg.customOn = false
        SaveCfg()
        Later(Z.ApplyTheme)
    end)

    Z.Sep("FONTE")
    Z.Dropdown("Fonte da interface", FONT_NAMES, Cfg.font, function(v)
        if v == Cfg.font then return end
        Cfg.font = v
        SaveCfg()
        Later(Z.ApplyFont)
    end, "Gotham, Source Sans, Roboto, Nunito, Ubuntu, Fredoka, Jura, Codigo, Arial")
    Z.Info("Algumas fontes têm só um peso, então negrito e normal ficam parecidos.")

    Z.Sep("TAMANHO DA UI")
    Z.Slider("Escala da janela", 60, 140, math.floor(Cfg.scale * 100 + 0.5), function(v) end, {
        step = 5, suffix = " %",
        onRelease = function(v)
            Cfg.scale = v / 100
            SaveCfg()
            Z.ApplyScale()
        end,
    })
    Z.Info("O tamanho é aplicado quando você solta o slider. A janela nunca passa do tamanho da tela.")

    Z.Sep("GERAL")
    Z.Button("Restaurar aparência padrão", Colors.AccentDark, function()
        Z.Confirm("Restaurar aparência?", "Preset, cor personalizada, fonte e tamanho voltam ao padrão (Eclipse, Gotham, 100%).", function()
            Cfg.theme, Cfg.font, Cfg.scale, Cfg.customOn = "Eclipse", "Gotham", 1, false
            Cfg.cr, Cfg.cg, Cfg.cb = 108, 140, 255
            SaveCfg()
            Later(Z.ApplyAll)
        end, "Restaurar", "Cancelar")
    end)
    Z.Info(writefile and "As configurações ficam salvas em ZuniHub_Base.json." or "Seu executor não suporta writefile: as configurações não serão salvas.")
end

-- ═══════════════════════════════════════════════════════════════════════
-- INICIAR
-- ═══════════════════════════════════════════════════════════════════════
Z.AddTab("Home", "house", LoadHome)
Z.AddTab("Player", "person", LoadPlayer)
Z.AddTab("Misc.", "eye", LoadMisc)
Z.AddTab("Settings", "gear", LoadSettings)   -- Order 100000: fica sempre no fim, mesmo com módulos depois
Z.SelectTab("Home")
Z.SetVisible(true)
Z.Ready = true
print("Zuni Hub Base v" .. Z.Version .. " carregada.")
