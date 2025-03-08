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
frame.Size = UDim2.new(0, 200, 0, 210)
frame.Position = UDim2.new(0.4, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Simple GUI"
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
    frame.Size = isMinimized and UDim2.new(0, 200, 0, 20) or UDim2.new(0, 200, 0, 210)
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
        -- Cambiar estado visual y lógico del toggle
        toggleStates[toggleInfo.flag] = not toggleStates[toggleInfo.flag]
        toggleButton.Text = toggleInfo.name .. (toggleStates[toggleInfo.flag] and " [ON]" or " [OFF]")

        -- Lógica de cada toggle:
        if toggleInfo.flag == "AutoMove" then
            -- Ahora, en lugar de mover en línea recta, se verifica la posición cada 1s
            if toggleStates[toggleInfo.flag] then
                toggleConnections[toggleInfo.flag] = task.spawn(function()
                    while toggleStates[toggleInfo.flag] do
                        local character = player.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local pos = character.HumanoidRootPart.Position
                            local deathPos = Vector3.new(16.41, 55.55, -160.83)
                            local targetPos = Vector3.new(13.74, 53.19, -115.41)
                            -- Si el personaje está en la posición de muerte/fin, se teleporta a la posición de inicio
                            if (pos - deathPos).Magnitude < 1 then
                                character:MoveTo(targetPos)
                            end
                        end
                        task.wait(5)
                    end
                end)
            else
                toggleStates[toggleInfo.flag] = false
                toggleConnections[toggleInfo.flag] = nil
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
                toggleStates[toggleInfo.flag] = false
                toggleConnections[toggleInfo.flag] = nil
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
                toggleStates[toggleInfo.flag] = false
                toggleConnections[toggleInfo.flag] = nil
            end

        elseif toggleInfo.flag == "FruitShop" then
            local fruitsUI = playerGui:FindFirstChild("UI") and playerGui.UI:FindFirstChild("Frames") and playerGui.UI.Frames:FindFirstChild("FruitsUI")
            if fruitsUI then
                fruitsUI.Visible = toggleStates[toggleInfo.flag]
            end
        end
    end)
end
