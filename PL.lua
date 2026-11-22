if not _G.ZuniHub or not _G.ZuniHub.Ready then return end
local Z = _G.ZuniHub
if Z.PrisonLifeLoaded then return end
Z.PrisonLifeLoaded = true
Z.ModuleName = "Prison Life"
local C, S, UI = Z.Colors, Z.SavedStates, Z.UI
local Player = game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")

-- ============================================================
-- CONFIGURAÇÕES PADRÃO (Prison Life)
-- ============================================================
if S.pl_esp_enabled == nil then S.pl_esp_enabled = false end
if S.pl_esp_name == nil then S.pl_esp_name = true end
if S.pl_esp_health == nil then S.pl_esp_health = true end
if S.pl_esp_distance == nil then S.pl_esp_distance = false end
if S.pl_esp_tracer == nil then S.pl_esp_tracer = true end
if S.pl_esp_max_dist == nil then S.pl_esp_max_dist = 500 end

if S.pl_aimbot_enabled == nil then S.pl_aimbot_enabled = false end
if S.pl_aimbot_fov == nil then S.pl_aimbot_fov = 120 end
if S.pl_aimbot_smooth == nil then S.pl_aimbot_smooth = 0.25 end
if S.pl_aimbot_key == nil then S.pl_aimbot_key = "RMB" end

if S.pl_walkspeed_enabled == nil then S.pl_walkspeed_enabled = false end
if S.pl_walkspeed_val == nil then S.pl_walkspeed_val = 16 end
if S.pl_jumppower_enabled == nil then S.pl_jumppower_enabled = false end
if S.pl_jumppower_val == nil then S.pl_jumppower_val = 50 end
if S.pl_infjump == nil then S.pl_infjump = false end

-- ============================================================
-- ESTADO INTERNO
-- ============================================================
local espObjects = {}
local aimbotHolding = false

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getDistance(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    local myChar = Player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return 0 end
    return (myChar.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
end

local function worldToScreen(pos)
    local screen, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screen.X, screen.Y), onScreen
end

-- ============================================================
-- ESP (Visuals)
-- ============================================================
local function destroyESP(plr)
    if espObjects[plr] then
        for _, obj in pairs(espObjects[plr]) do
            if obj and obj.Remove then pcall(obj.Remove, obj) end
        end
        espObjects[plr] = nil
    end
end

local function createESP(plr)
    if not S.pl_esp_enabled then return end
    if not isAlive(plr) or plr == Player then return end
    if espObjects[plr] then return end

    local char = plr.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    local objs = {}

    -- Billboard (Nome / Vida / Distância)
    if S.pl_esp_name or S.pl_esp_health or S.pl_esp_distance then
        local bg = Instance.new("BillboardGui")
        bg.Name = "ZuniPL_ESP"
        bg.Size = UDim2.new(0, 200, 0, 50)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.MaxDistance = S.pl_esp_max_dist
        bg.Adornee = head
        bg.Parent = head
        
        local container = Instance.new("Frame", bg)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1

        if S.pl_esp_name then
            local name = Instance.new("TextLabel", container)
            name.Size = UDim2.new(1, 0, 0, 14)
            name.BackgroundTransparency = 1
            name.Text = plr.Name
            name.TextColor3 = C.Text
            name.TextStrokeTransparency = 0
            name.Font = Enum.Font.GothamBold
            name.TextSize = 12
            objs.nameLbl = name
        end
        
        if S.pl_esp_health then
            local hp = Instance.new("TextLabel", container)
            hp.Size = UDim2.new(1, 0, 0, 12)
            hp.Position = UDim2.new(0, 0, 0, 14)
            hp.BackgroundTransparency = 1
            hp.TextColor3 = C.Success
            hp.TextStrokeTransparency = 0
            hp.Font = Enum.Font.GothamMedium
            hp.TextSize = 10
            objs.hpLbl = hp
        end

        if S.pl_esp_distance then
            local dist = Instance.new("TextLabel", container)
            dist.Size = UDim2.new(1, 0, 0, 12)
            dist.Position = UDim2.new(0, 0, 0, 26)
            dist.BackgroundTransparency = 1
            dist.TextColor3 = C.TextDim
            dist.TextStrokeTransparency = 0
            dist.Font = Enum.Font.GothamMedium
            dist.TextSize = 10
            objs.distLbl = dist
        end
        objs.billboard = bg
    end

    -- Tracer (Linha)
    if S.pl_esp_tracer then
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Color = C.AccentLight
        tracer.Thickness = 1
        tracer.Transparency = 0.8
        objs.tracer = tracer
    end

    espObjects[plr] = objs
end

local function updateESP(plr)
    local objs = espObjects[plr]
    if not objs then return end
    
    if not isAlive(plr) or not S.pl_esp_enabled then
        destroyESP(plr)
        return
    end

    local char = plr.Character
    local head = char and char:FindFirstChild("Head")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not head or not hrp or not hum then
        destroyESP(plr)
        return
    end

    local dist = getDistance(plr)
    if dist > S.pl_esp_max_dist then
        if objs.billboard then objs.billboard.Enabled = false end
        if objs.tracer then objs.tracer.Visible = false end
        return
    end

    local headScreen, headOn = worldToScreen(head.Position)

    if objs.billboard then
        objs.billboard.Enabled = true
        if objs.nameLbl then objs.nameLbl.Text = plr.Name end
        if objs.hpLbl then
            objs.hpLbl.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
            local ratio = hum.Health / hum.MaxHealth
            objs.hpLbl.TextColor3 = ratio > 0.5 and C.Success or (ratio > 0.25 and C.Warning or C.Danger)
        end
        if objs.distLbl then objs.distLbl.Text = math.floor(dist) .. "m" end
    end

    if objs.tracer then
        if headOn then
            local vp = Camera.ViewportSize
            objs.tracer.From = Vector2.new(vp.X / 2, vp.Y)
            objs.tracer.To = headScreen
            objs.tracer.Visible = true
        else
            objs.tracer.Visible = false
        end
    end
end

-- ============================================================
-- AIMBOT (Combat)
-- ============================================================
local function getClosestTarget()
    local mouse = UIS:GetMouseLocation()
    local best, bestDist = nil, S.pl_aimbot_fov

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and isAlive(plr) then
            local head = plr.Character and plr.Character:FindFirstChild("Head")
            if head then
                local screen, onScreen = worldToScreen(head.Position)
                if onScreen then
                    local d = (mouse - screen).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = plr
                    end
                end
            end
        end
    end
    return best
end

local function doAimbot()
    if not S.pl_aimbot_enabled or not aimbotHolding then return end
    local target = getClosestTarget()
    if not target then return end
    
    local head = target.Character and target.Character:FindFirstChild("Head")
    if not head then return end

    local goal = CFrame.new(Camera.CFrame.Position, head.Position)
    Camera.CFrame = Camera.CFrame:Lerp(goal, S.pl_aimbot_smooth)
end

-- ============================================================
-- LOOPS (Movimento & Visuais)
-- ============================================================
-- Loop de ESP
Z.PageLoop(0.01, function()
    if not Z.Alive then return end
    for plr, _ in pairs(espObjects) do
        updateESP(plr)
    end
    if S.pl_esp_enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player and isAlive(plr) then
                createESP(plr)
            end
        end
    else
        for plr, _ in pairs(espObjects) do
            destroyESP(plr)
        end
    end
end)

-- Loop de Aimbot
Z.PageLoop(0.01, function()
    if not Z.Alive then return end
    doAimbot()
end)

-- Loop de Movimento (WalkSpeed / JumpPower)
Z.PageLoop(0.1, function()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if S.pl_walkspeed_enabled then
            hum.WalkSpeed = S.pl_walkspeed_val
        else
            if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
        end

        if S.pl_jumppower_enabled then
            if not hum.UseJumpPower then hum.UseJumpPower = true end
            hum.JumpPower = S.pl_jumppower_val
        else
            if hum.UseJumpPower and hum.JumpPower ~= 50 then hum.JumpPower = 50 end
        end
    end
end)

-- ============================================================
-- INPUTS (Teclas e Eventos)
-- ============================================================
local function isAimbotKey(input)
    if S.pl_aimbot_key == "RMB" then return input.UserInputType == Enum.UserInputType.MouseButton2 end
    if S.pl_aimbot_key == "LMB" then return input.UserInputType == Enum.UserInputType.MouseButton1 end
    if S.pl_aimbot_key == "E" then return input.KeyCode == Enum.KeyCode.E end
    if S.pl_aimbot_key == "Q" then return input.KeyCode == Enum.KeyCode.Q end
    return false
end

Z.Track(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if isAimbotKey(input) then aimbotHolding = true end
    -- Pulo Infinito
    if S.pl_infjump and input.KeyCode == Enum.KeyCode.Space then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

Z.Track(UIS.InputEnded:Connect(function(input, gpe)
    if isAimbotKey(input) then aimbotHolding = false end
end))

-- Anti-AFK (Prison Life pode kickar por inatividade)
Z.Track(Player.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end))

-- Limpeza ao sair
Z.Track(Players.PlayerRemoving:Connect(function(plr)
    destroyESP(plr)
end))

-- ============================================================
-- UI (Interface do Módulo)
-- ============================================================
local function LoadPrisonLife()
    -- Visuals
    Z.Sep("ESP / Visuals (Prison Life)")
    Z.Toggle("Ativar ESP", S.pl_esp_enabled, function(v)
        S.pl_esp_enabled = v
        if not v then
            for plr, _ in pairs(espObjects) do destroyESP(plr) end
        end
    end, "Mostra jogadores através das paredes")
    Z.Toggle("Nome", S.pl_esp_name, function(v) S.pl_esp_name = v end)
    Z.Toggle("Vida", S.pl_esp_health, function(v) S.pl_esp_health = v end)
    Z.Toggle("Distância", S.pl_esp_distance, function(v) S.pl_esp_distance = v end)
    Z.Toggle("Tracer (Linha)", S.pl_esp_tracer, function(v) S.pl_esp_tracer = v end)
    Z.Slider("Distância Máx ESP", 50, 2000, S.pl_esp_max_dist, function(v) S.pl_esp_max_dist = v end)

    -- Combat
    Z.Sep("Aimbot (Combat)")
    Z.Toggle("Ativar Aimbot", S.pl_aimbot_enabled, function(v)
        S.pl_aimbot_enabled = v
        if not v then aimbotHolding = false end
    end, "Segure a tecla para mirar na cabeça")
    Z.Slider("FOV", 10, 500, S.pl_aimbot_fov, function(v) S.pl_aimbot_fov = v end)
    Z.Slider("Suavidade", 0.05, 1, S.pl_aimbot_smooth, function(v) S.pl_aimbot_smooth = v end)
    Z.Dropdown("Tecla de Mira", {"RMB", "LMB", "E", "Q"}, S.pl_aimbot_key, function(v) S.pl_aimbot_key = v end)

    -- Movement
    Z.Sep("Movimento")
    Z.Toggle("Velocidade Custom", S.pl_walkspeed_enabled, function(v) S.pl_walkspeed_enabled = v end)
    Z.Slider("WalkSpeed", 16, 150, S.pl_walkspeed_val, function(v) S.pl_walkspeed_val = v end)
    
    Z.Toggle("Pulo Custom", S.pl_jumppower_enabled, function(v) S.pl_jumppower_enabled = v end)
    Z.Slider("JumpPower", 50, 200, S.pl_jumppower_val, function(v) S.pl_jumppower_val = v end)
    
    Z.Toggle("Pulo Infinito", S.pl_infjump, function(v) S.pl_infjump = v end, "Pule no ar quantas vezes quiser")

    -- Utilities
    Z.Sep("Utilidades")
    Z.Button("Rejoin (Trocar de Servidor)", C.Warning, function()
        Z.Notify("Prison Life", "Reconectando...", C.Warning, 3)
        pcall(function() TeleportService:Teleport(game.PlaceId, Player) end)
    end)
    Z.Info("Dica: Use o ESP para ver Guardas se aproximando e o Aimbot para dominar confrontos. O Rejoin ajuda se você morrer muito.")
end

Z.AddTab("Prison Life", "shield", LoadPrisonLife)
Z.SelectTab("Prison Life")
Z.Notify("Prison Life", "Módulo carregado! ESP, Aimbot e Movimento prontos.", C.Success, 4)
