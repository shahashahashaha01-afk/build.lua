-- ====================================================================
-- BUILD A BOAT FOR TREASURE — ULTIMATE AUTO-FARM (MOBILE EDITION)
-- Оптимизировано для Delta, Codex, Arceus X, Hydrogen
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ
local Settings = {
    AutoFarm = false,
    Fly = false,
    FlySpeed = 50,
    Speed = false
}

local FarmingActive = false

-- --------------------------------------------------------------------
-- ИНТЕРФЕЙС (GUI ДЛЯ ANDROID)
-- --------------------------------------------------------------------
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BABFT_AutoFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if PlayerGui then
    ScreenGui.Parent = PlayerGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
end

-- Плавающая кнопка (Драг пальцем)
local MenuBtn = Instance.new("TextButton")
MenuBtn.Size = UDim2.new(0, 52, 0, 52)
MenuBtn.Position = UDim2.new(0.04, 0, 0.35, 0)
MenuBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MenuBtn.Text = "⛵"
MenuBtn.TextSize = 24
MenuBtn.Parent = ScreenGui

local MC = Instance.new("UICorner")
MC.CornerRadius = UDim.new(1, 0)
MC.Parent = MenuBtn

local MS = Instance.new("UIStroke")
MS.Color = Color3.fromRGB(240, 180, 40)
MS.Thickness = 2
MS.Parent = MenuBtn

-- Окно меню
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 290)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local FC = Instance.new("UICorner")
FC.CornerRadius = UDim.new(0, 12)
FC.Parent = MainFrame

local FS = Instance.new("UIStroke")
FS.Color = Color3.fromRGB(240, 180, 40)
FS.Thickness = 1.6
FS.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "BABFT: ЗОЛОТОЙ ФАРМ"
Title.TextColor3 = Color3.fromRGB(245, 190, 45)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -50)
Scroll.Position = UDim2.new(0, 8, 0, 44)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 2
Scroll.CanvasSize = UDim2.new(0, 0, 0, 240)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Scroll

-- Перетаскивание меню пальцем
local function makeTouchDraggable(gui)
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

makeTouchDraggable(MenuBtn)
makeTouchDraggable(MainFrame)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function createToggle(name, defaultState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(180, 130, 25) or Color3.fromRGB(28, 28, 34)
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
        btn.BackgroundColor3 = state and Color3.fromRGB(180, 130, 25) or Color3.fromRGB(28, 28, 34)
        btn.Text = name .. ": " .. (state and "ВКЛ" or "ВЫКЛ")
        callback(state)
    end)
end

local function createActionBtn(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Scroll

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

-- --------------------------------------------------------------------
-- NO-CLIP (ПРОХОД СКВОЗЬ ЛЮБЫЕ ПРЕПЯТСТВИЯ)
-- --------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if Settings.AutoFarm or Settings.Fly then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- --------------------------------------------------------------------
-- 1. ЦИКЛ АВТОФАРМА ЗОЛОТА (AUTO-FARM)
-- --------------------------------------------------------------------
local function startGoldFarm()
    task.spawn(function()
        while Settings.AutoFarm do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                -- Фиксируем скорость и поднимаем в безопасную зону
                hrp.AssemblyLinearVelocity = Vector3.zero

                local boatStages = Workspace:FindFirstChild("BoatStages")
                local normalStages = boatStages and boatStages:FindFirstChild("NormalStages")

                if normalStages then
                    -- Сортировка стадий 1..10
                    local stagesList = {}
                    for _, st in ipairs(normalStages:GetChildren()) do
                        if st.Name:find("CaveStage") then
                            local id = tonumber(st.Name:match("%d+")) or 0
                            table.insert(stagesList, {folder = st, id = id})
                        end
                    end
                    table.sort(stagesList, function(a, b) return a.id < b.id end)

                    -- Полет по стадиям (на высоте +55 над водой)
                    for _, stageData in ipairs(stagesList) do
                        if not Settings.AutoFarm or not LocalPlayer.Character then break end
                        local part = stageData.folder:FindFirstChildWhichIsA("BasePart") or stageData.folder:FindFirstChild("DarknessPart")
                        if part then
                            hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 55, 0))
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            task.wait(0.65) -- Небольшая пауза, чтобы сервер зарегистрировал чекпоинт
                        end
                    end

                    -- Финиш: золотой сундук
                    local theEnd = normalStages:FindFirstChild("TheEnd")
                    if theEnd and Settings.AutoFarm and LocalPlayer.Character then
                        local chest = theEnd:FindFirstChild("GoldenChest")
                        local trigger = chest and chest:FindFirstChild("Trigger")
                        if trigger then
                            hrp.CFrame = trigger.CFrame
                            task.wait(2.2) -- Ожидание зачисления золота
                        end
                    end
                end

                -- Респавн на базу для следующего круга
                if Settings.AutoFarm and LocalPlayer.Character then
                    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if h then h.Health = 0 end
                end
            end
            task.wait(2.5)
        end
    end)
end

createToggle("💰 Автофарм Золота (Цикл)", Settings.AutoFarm, function(v)
    Settings.AutoFarm = v
    if v then
        startGoldFarm()
    end
end)

-- Автоматический рестарт фарма при спавне
LocalPlayer.CharacterAdded:Connect(function()
    if Settings.AutoFarm then
        task.wait(1.5)
        startGoldFarm()
    end
end)

-- --------------------------------------------------------------------
-- 2. ТЕЛЕПОРТ К СУНДУКУ В ОДИН КЛИК
-- --------------------------------------------------------------------
createActionBtn("⚡ Телепорт к Сундуку (1 раз)", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local boatStages = Workspace:FindFirstChild("BoatStages")
        local theEnd = boatStages and boatStages:FindFirstChild("NormalStages") and boatStages.NormalStages:FindFirstChild("TheEnd")
        local trigger = theEnd and theEnd:FindFirstChild("GoldenChest") and theEnd.GoldenChest:FindFirstChild("Trigger")

        if trigger then
            hrp.CFrame = trigger.CFrame
        else
            -- Если сундук не подгрузился, летим по координатам финиша
            hrp.CFrame = CFrame.new(-55, -360, 9485)
        end
    end
end)

-- --------------------------------------------------------------------
-- 3. РУЧНОЙ ПОЛЕТ (FLY)
-- --------------------------------------------------------------------
local bodyGyro, bodyVel
createToggle("🕊️ Свободный Полет", Settings.Fly, function(v)
    Settings.Fly = v
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if v then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.cframe = hrp.CFrame
        bodyGyro.Parent = hrp

        bodyVel = Instance.new("BodyVelocity")
        bodyVel.velocity = Vector3.zero
        bodyVel.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.Parent = hrp

        task.spawn(function()
            while Settings.Fly and hrp.Parent do
                local cam = Workspace.CurrentCamera
                local moveDir = Vector3.zero
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.MoveDirection.Magnitude > 0 then
                    moveDir = cam.CFrame:VectorToWorldSpace(Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z))
                end
                bodyVel.velocity = moveDir * Settings.FlySpeed
                bodyGyro.cframe = cam.CFrame
                task.wait()
            end
        end)
    else
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVel then bodyVel:Destroy() end
    end
end)

-- --------------------------------------------------------------------
-- 4. СКОРОСТЬ БЕГА x2
-- --------------------------------------------------------------------
createToggle("⚡ Скорость Бега x2", Settings.Speed, function(v)
    Settings.Speed = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = v and 36 or 16
    end
end)

print("[BABFT Gold Farm] Скрипт готов! Нажмите ⛵ для меню.")
