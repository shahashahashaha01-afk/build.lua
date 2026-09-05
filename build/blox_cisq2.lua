-- ====================================================================
-- SCRIPT: @wed_vk (BLOXSTRIKE EDITION) — PC & MOBILE ANTI-CRASH
-- Оптимизировано под ПК (Solara, Celery, Wave) и Android (Delta, Codex)
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- НАСТРОЙКИ
local Settings = {
    Aimbot = false,
    AimbotFOV = 45,           -- Базовый FOV
    AimSmoothness = 0.20,     -- Плавность (0.05 - легит, 1.0 - снап)
    TeamCheck = true,
    WallCheck = true,
    ESP = false               -- 2D Box ESP
}

local ScreenBoxes = {}

-- Единый кэшированный RaycastParams (предотвращает переполнение памяти и краш)
local WallCheckParams = RaycastParams.new()
WallCheckParams.FilterType = Enum.RaycastFilterType.Blacklist
WallCheckParams.IgnoreWater = true

-- Проверка команд
local function isEnemy(player)
    if not Settings.TeamCheck then return true end
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    if LocalPlayer.TeamColor and player.TeamColor then
        return LocalPlayer.TeamColor ~= player.TeamColor
    end
    return true
end

-- Безопасная проверка препятствий
local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    if not targetPart or not targetPart.Parent then return false end

    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin

    WallCheckParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

    local hit = Workspace:Raycast(origin, dir, WallCheckParams)
    if hit and hit.Instance then
        return hit.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- --------------------------------------------------------------------
-- БЕЗОПАСНЫЙ ИНТЕРФЕЙС (СТРОГО В PLAYERGUI ВО ИЗБЕЖАНИЕ КРАША)
-- --------------------------------------------------------------------
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WedVk_Bloxstrike_Safe"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Ровная привязка боксов без сдвига
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if PlayerGui then
    ScreenGui.Parent = PlayerGui
else
    ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESPContainer"
ESPContainer.Parent = ScreenGui

-- ВОТЕРМАРК СНИЗУ ЭКРАНА
local Watermark = Instance.new("Frame")
Watermark.Name = "Watermark"
Watermark.AnchorPoint = Vector2.new(0.5, 1)
Watermark.Position = UDim2.new(0.5, 0, 1, -20)
Watermark.Size = UDim2.new(0, 140, 0, 26)
Watermark.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Watermark.BackgroundTransparency = 0.35
Watermark.Parent = ScreenGui

local WCorner = Instance.new("UICorner")
WCorner.CornerRadius = UDim.new(0, 6)
WCorner.Parent = Watermark

local WStroke = Instance.new("UIStroke")
WStroke.Color = Color3.fromRGB(220, 45, 45)
WStroke.Thickness = 1.2
WStroke.Parent = Watermark

local WLabel = Instance.new("TextLabel")
WLabel.Size = UDim2.new(1, 0, 1, 0)
WLabel.BackgroundTransparency = 1
WLabel.Text = "@wed_vk"
WLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WLabel.TextSize = 13
WLabel.Font = Enum.Font.GothamBold
WLabel.Parent = Watermark

-- КРУГ FOV
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Settings.AimbotFOV * 2, 0, Settings.AimbotFOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FRound = Instance.new("UICorner")
FRound.CornerRadius = UDim.new(1, 0)
FRound.Parent = FOVCircle

local FStroke = Instance.new("UIStroke")
FStroke.Color = Color3.fromRGB(255, 50, 50)
FStroke.Thickness = 1.4
FStroke.Parent = FOVCircle

-- ПЛАВАЮЩАЯ КНОПКА МЕНЮ
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
ToggleBtn.Position = UDim2.new(0.04, 0, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 20
ToggleBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
ToggleBtn.Parent = ScreenGui

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(1, 0)
TBCorner.Parent = ToggleBtn

local TBStroke = Instance.new("UIStroke")
TBStroke.Color = Color3.fromRGB(220, 45, 45)
TBStroke.Thickness = 1.8
TBStroke.Parent = ToggleBtn

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 310)
MainFrame.Position = UDim2.new(0.5, -115, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MFCorner = Instance.new("UICorner")
MFCorner.CornerRadius = UDim.new(0, 10)
MFCorner.Parent = MainFrame

local MFStroke = Instance.new("UIStroke")
MFStroke.Color = Color3.fromRGB(220, 45, 45)
MFStroke.Thickness = 1.5
MFStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundTransparency = 1
Title.Text = "@wed_vk [PC/Mobile]"
Title.TextColor3 = Color3.fromRGB(255, 65, 65)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -46)
Scroll.Position = UDim2.new(0, 8, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 0, 260)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Scroll

-- Перемещение меню
local function makeDraggable(gui)
    local dragging, dragStart, startPos
    gui.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = gui.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseMovement) and dragging and dragStart and startPos then
            local delta = inp.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(ToggleBtn)
makeDraggable(MainFrame)

-- Открытие/закрытие по клику мыши / тапу
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Горячая клавиша для ПК: Insert или RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

local function createToggle(name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(190, 35, 35) or Color3.fromRGB(28, 28, 34)
    btn.Text = name .. ": " .. (defaultState and "ВКЛ" or "ВЫКЛ")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(190, 35, 35) or Color3.fromRGB(28, 28, 34)
        btn.Text = name .. ": " .. (state and "ВКЛ" or "ВЫКЛ")
        callback(state)
    end)
end

local function createAdjuster(title, getValueText, onMinus, onPlus)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    frame.Parent = Scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 32, 1, -8)
    minusBtn.Position = UDim2.new(0, 4, 0, 4)
    minusBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.TextSize = 16
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.Parent = frame

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 4)
    mCorner.Parent = minusBtn

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 32, 1, -8)
    plusBtn.Position = UDim2.new(1, -36, 0, 4)
    plusBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.TextSize = 16
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.Parent = frame

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 4)
    pCorner.Parent = plusBtn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -76, 1, 0)
    label.Position = UDim2.new(0, 38, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. getValueText()
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.Parent = frame

    minusBtn.MouseButton1Click:Connect(function()
        onMinus()
        label.Text = title .. ": " .. getValueText()
    end)
    plusBtn.MouseButton1Click:Connect(function()
        onPlus()
        label.Text = title .. ": " .. getValueText()
    end)
end

-- --------------------------------------------------------------------
-- СОЗДАНИЕ И ОБНОВЛЕНИЕ 2D BOX ESP
-- --------------------------------------------------------------------
local function getOrCreateScreenBox(player)
    if ScreenBoxes[player] then return ScreenBoxes[player] end

    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "Box_" .. player.Name
    boxFrame.BackgroundTransparency = 1
    boxFrame.Visible = false
    boxFrame.Parent = ESPContainer

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 45, 45)
    stroke.Parent = boxFrame

    local tag = Instance.new("TextLabel")
    tag.Name = "Tag"
    tag.AnchorPoint = Vector2.new(0.5, 1)
    tag.Position = UDim2.new(0.5, 0, 0, -4)
    tag.Size = UDim2.new(0, 160, 0, 16)
    tag.BackgroundTransparency = 1
    tag.TextColor3 = Color3.fromRGB(255, 255, 255)
    tag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    tag.TextStrokeTransparency = 0.2
    tag.TextSize = 11
    tag.Font = Enum.Font.GothamBold
    tag.Text = player.DisplayName
    tag.Parent = boxFrame

    ScreenBoxes[player] = {
        Frame = boxFrame,
        Stroke = stroke,
        Tag = tag
    }
    return ScreenBoxes[player]
end

local function removeScreenBox(player)
    if ScreenBoxes[player] then
        pcall(function() ScreenBoxes[player].Frame:Destroy() end)
        ScreenBoxes[player] = nil
    end
end

createToggle("Обычный ESP", Settings.ESP, function(v)
    Settings.ESP = v
    if not v then
        for _, data in pairs(ScreenBoxes) do
            data.Frame.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(removeScreenBox)

-- --------------------------------------------------------------------
-- ПЛАВНЫЙ АИМБОТ
-- --------------------------------------------------------------------
createToggle("Плавный Аимбот", Settings.Aimbot, function(v)
    Settings.Aimbot = v
    FOVCircle.Visible = v
end)

createAdjuster("FOV", function()
    return tostring(Settings.AimbotFOV)
end, function()
    Settings.AimbotFOV = math.max(15, Settings.AimbotFOV - 5)
    FOVCircle.Size = UDim2.new(0, Settings.AimbotFOV * 2, 0, Settings.AimbotFOV * 2)
end, function()
    Settings.AimbotFOV = math.min(180, Settings.AimbotFOV + 5)
    FOVCircle.Size = UDim2.new(0, Settings.AimbotFOV * 2, 0, Settings.AimbotFOV * 2)
end)

createAdjuster("Плавность", function()
    return string.format("%.2f", Settings.AimSmoothness)
end, function()
    Settings.AimSmoothness = math.clamp(Settings.AimSmoothness - 0.05, 0.05, 1.0)
end, function()
    Settings.AimSmoothness = math.clamp(Settings.AimSmoothness + 0.05, 0.05, 1.0)
end)

local function getBestTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestPart = nil
    local minDistance = Settings.AimbotFOV

    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if head and hum and hum.Health > 0 then
                local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist < minDistance then
                        if isVisible(head) then
                            minDistance = dist
                            bestPart = head
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

-- --------------------------------------------------------------------
-- ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ (БЕЗ УТЕЧЕК ПАМЯТИ)
-- --------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- 1. Аимбот
    if Settings.Aimbot then
        local target = getBestTarget()
        if target then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.AimSmoothness)
        end
    end

    -- 2. Box ESP
    if Settings.ESP then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local boxData = getOrCreateScreenBox(player)
                local char = player.Character

                if char and char:IsDescendantOf(Workspace) then
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    local hum = char:FindFirstChildOfClass("Humanoid")

                    if head and root and (not hum or hum.Health > 0) then
                        local topWorld = head.Position + Vector3.new(0, 0.7, 0)
                        local bottomWorld = root.Position - Vector3.new(0, 2.5, 0)

                        local topScreen, topVisible = Camera:WorldToViewportPoint(topWorld)
                        local bottomScreen, bottomVisible = Camera:WorldToViewportPoint(bottomWorld)

                        if topVisible and bottomVisible then
                            local height = math.abs(bottomScreen.Y - topScreen.Y)
                            local width = height * 0.55
                            local midX = (topScreen.X + bottomScreen.X) / 2
                            local topY = math.min(topScreen.Y, bottomScreen.Y)

                            boxData.Frame.Size = UDim2.new(0, width, 0, height)
                            boxData.Frame.Position = UDim2.new(0, midX - (width / 2), 0, topY)

                            local isHostile = isEnemy(player)
                            boxData.Stroke.Color = isHostile and Color3.fromRGB(255, 45, 45) or Color3.fromRGB(50, 160, 255)

                            local dist = myRoot and math.floor((root.Position - myRoot.Position).Magnitude) or 0
                            local hp = hum and math.floor(hum.Health) or 100
                            boxData.Tag.Text = string.format("%s [%dm] [%d HP]", player.DisplayName, dist, hp)

                            boxData.Frame.Visible = true
                        else
                            boxData.Frame.Visible = false
                        end
                    else
                        boxData.Frame.Visible = false
                    end
                else
                    boxData.Frame.Visible = false
                end
            end
        end
    end
end)

print("[@wed_vk] Bloxstrike (PC/Mobile Anti-Crash) готов к работе!")
