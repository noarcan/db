local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 240)
frame.Position = UDim2.new(0.4, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Gems GUI"
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(1, -20, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
minimizeButton.Text = "-"
minimizeButton.Parent = frame

local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -20)
content.Position = UDim2.new(0, 0, 0, 20)
content.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
content.Parent = frame

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    content.Visible = not isMinimized
    frame.Size = isMinimized and UDim2.new(0, 200, 0, 20) or UDim2.new(0, 200, 0, 240)
end)

-- Funcionalidad de drag (arrastrar)
local dragging, dragInput, dragStart, startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Definir toggles y sus estados
local toggles = {
    {name = "Auto Move", flag = "AutoMove"},
    {name = "Auto Click", flag = "AutoClick"},
    {name = "Anti AFK", flag = "AntiAfk"},
    {name = "Auto Ability", flag = "AutoAbility"},
    {name = "Fruit Shop", flag = "FruitShop"}
}

local toggleStates = {}
local toggleConnections = {}

for i, toggleInfo in ipairs(toggles) do
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, -10, 0, 25)
    toggleButton.Position = UDim2.new(0, 5, 0, (i - 1) * 30)
    toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    toggleButton.Text = toggleInfo.name .. " [OFF]"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Parent = content

    toggleStates[toggleInfo.flag] = false

    toggleButton.MouseButton1Click:Connect(function()
        toggleStates[toggleInfo.flag] = not toggleStates[toggleInfo.flag]
        toggleButton.Text = toggleInfo.name .. (toggleStates[toggleInfo.flag] and " [ON]" or " [OFF]")

        -- Lógica de cada toggle:
        if toggleInfo.flag == "AutoMove" then
            if toggleStates[toggleInfo.flag] then
                -- Configuración de posiciones y velocidad
                local deathPos = Vector3.new(16.41, 55.55, -160.83)
                local startPos = Vector3.new(13.74, 53.19, -115.41)
                local moveSpeed = 64  -- Cambia este valor para modificar la velocidad
                local thresholdDeath = 1
                local thresholdY = 0.2  -- Umbral para considerar que el personaje está a la altura del spawn

                toggleConnections[toggleInfo.flag] = RunService.RenderStepped:Connect(function(dt)
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local hrp = character.HumanoidRootPart
                        local pos = hrp.Position
                        -- Si el jugador está en la posición de "muerte", se le teletransporta al spawn.
                        if (pos - deathPos).Magnitude < thresholdDeath then
                            hrp.CFrame = CFrame.new(startPos)
                        -- Si el jugador está a la altura del spawn, se asume que la partida aún no inició y se detiene el movimiento.
                        elseif math.abs(pos.Y - startPos.Y) < thresholdY then
                            -- Aquí no se mueve; se podría agregar lógica extra si se requiere.
                        else
                            -- La partida inició: se mueve en línea recta usando el delta time real.
                            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -moveSpeed * dt)
                        end
                    end
                end)
            else
                if toggleConnections[toggleInfo.flag] then
                    toggleConnections[toggleInfo.flag]:Disconnect()
                    toggleConnections[toggleInfo.flag] = nil
                end
            end

        elseif toggleInfo.flag == "AutoClick" then
            if toggleStates[toggleInfo.flag] then
                toggleConnections[toggleInfo.flag] = task.spawn(function()
                    while toggleStates[toggleInfo.flag] do
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        task.wait()
                    end
                end)
            else
                if toggleConnections[toggleInfo.flag] then
                    task.cancel(toggleConnections[toggleInfo.flag])
                    toggleConnections[toggleInfo.flag] = nil
                end
            end

        elseif toggleInfo.flag == "AntiAfk" then
            if toggleStates[toggleInfo.flag] then
                toggleConnections[toggleInfo.flag] = player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            else
                if toggleConnections[toggleInfo.flag] then
                    toggleConnections[toggleInfo.flag]:Disconnect()
                    toggleConnections[toggleInfo.flag] = nil
                end
            end

        elseif toggleInfo.flag == "AutoAbility" then
            if toggleStates[toggleInfo.flag] then
                toggleConnections[toggleInfo.flag] = task.spawn(function()
                    while toggleStates[toggleInfo.flag] do
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                        task.wait(5.5)
                    end
                end)
            else
                if toggleConnections[toggleInfo.flag] then
                    task.cancel(toggleConnections[toggleInfo.flag])
                    toggleConnections[toggleInfo.flag] = nil
                end
            end

        elseif toggleInfo.flag == "FruitShop" then
            local uiObj = playerGui:FindFirstChild("UI")
            if uiObj then
                local framesObj = uiObj:FindFirstChild("Frames")
                if framesObj then
                    local fruitsUI = framesObj:FindFirstChild("FruitsUI")
                    if fruitsUI then
                        fruitsUI.Visible = toggleStates[toggleInfo.flag]
                    else
                        warn("No se encontró FruitsUI")
                    end
                else
                    warn("No se encontró Frames dentro de UI")
                end
            else
                warn("No se encontró UI en PlayerGui")
            end
        end
    end)
end

-- Botón adicional para eliminar la alerta "TeleportToMainLobbyUI"
local destroyAlertButton = Instance.new("TextButton")
destroyAlertButton.Size = UDim2.new(1, -10, 0, 25)
-- Se posiciona justo debajo del último toggle (5 toggles: posición Y = 5*30 = 150)
destroyAlertButton.Position = UDim2.new(0, 5, 0, 150)
destroyAlertButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
destroyAlertButton.Text = "Eliminar Alerta"
destroyAlertButton.TextColor3 = Color3.new(1, 1, 1)
destroyAlertButton.Parent = content

destroyAlertButton.MouseButton1Click:Connect(function()
    local uiMain = player.PlayerGui:FindFirstChild("UI")
    if uiMain then
        local framesObj = uiMain:FindFirstChild("Frames")
        if framesObj then
            local frameAlert = framesObj:FindFirstChild("TeleportToMainLobbyUI")
            if frameAlert then
                frameAlert:Destroy()
                print("UI eliminada")
            else
                print("No se encontró la UI a eliminar")
            end
        else
            print("No se encontró Frames dentro de UI")
        end
    else
        print("No se encontró el UI principal")
    end
end)
