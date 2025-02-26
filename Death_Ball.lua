local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "DEATH BALL",
    Icon = 0,
    LoadingTitle = "DEATH BALL TUTORIAL",
    LoadingSubtitle = "by arcan",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "DEATH_BALL",
        FileName = "Death Ball"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

local Tab = Window:CreateTab("OPTIONS")
local Section = Tab:CreateSection("no")

local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart")

-- Toggle 1: Movimiento Automático
local movingForward = false
local moveConnection
local speed = 7

local function moveCharacter(deltaTime)
    if movingForward and rootPart then
        rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -speed * deltaTime)
    end
end

local ToggleMove = Tab:CreateToggle({
    Name = "Auto Move Forward",
    CurrentValue = false,
    Flag = "ToggleMove",
    Callback = function(Value)
        movingForward = Value
        if movingForward then
            moveConnection = RunService.RenderStepped:Connect(moveCharacter)
        else
            if moveConnection then
                moveConnection:Disconnect()
                moveConnection = nil
            end
        end
    end
})

-- Toggle 2: Auto Click
local clicking = false

local function autoClick()
    while clicking do
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.2)
    end
end

local ToggleClick = Tab:CreateToggle({
    Name = "Auto Click",
    CurrentValue = false,
    Flag = "ToggleClick",
    Callback = function(Value)
        clicking = Value
        if clicking then
            task.spawn(autoClick)
        end
    end
})

-- Toggle 3: Anti-AFK
local antiAfkEnabled = false
local afkConnection

local function toggleAntiAfk(state)
    if state then
        afkConnection = Players.LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if afkConnection then
            afkConnection:Disconnect()
            afkConnection = nil
        end
    end
end

local ToggleAfk = Tab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "ToggleAntiAFK",
    Callback = function(Value)
        antiAfkEnabled = Value
        toggleAntiAfk(antiAfkEnabled)
    end
})

-- Toggle 4: Auto Ability (Tecla "1" cada 5.5s)
local sendingKey = false

local function sendKey()
    while sendingKey do
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
        task.wait(5.5)
    end
end

local ToggleKey = Tab:CreateToggle({
    Name = "Auto Ability",
    CurrentValue = false,
    Flag = "ToggleKey1",
    Callback = function(Value)
        sendingKey = Value
        if sendingKey then
            task.spawn(sendKey)
        end
    end
})

-- Eliminar la UI de "TeleportToMainLobbyUI" automáticamente
local ButtonDestroyUI = Tab:CreateButton({
    Name = "Eliminar Teleport UI",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local gui = player:FindFirstChild("PlayerGui")
        if gui then
            local frame = gui:FindFirstChild("Frames") and gui.Frames:FindFirstChild("TeleportToMainLobbyUI")
            if frame then
                frame:Destroy()
            end
        end
    end
})


-- Toggle para mostrar u ocultar la tienda de frutas
local player = game:GetService("Players").LocalPlayer
local gui = player:WaitForChild("PlayerGui")

local ToggleFruitsUI = Tab:CreateToggle({
    Name = "Fruit Shop",
    CurrentValue = false,
    Flag = "ToggleFruitsShop",
    Callback = function(Value)
        local fruitsUI = gui:FindFirstChild("UI") and gui.UI:FindFirstChild("Frames") and gui.UI.Frames:FindFirstChild("FruitsUI")
        if fruitsUI then
            fruitsUI.Visible = Value
        end
    end
})
