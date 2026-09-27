local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- CONFIGURAÇÃO E VALIDAÇÃO DA KEY
-- ==========================================
local PANEL_URL = "https://pjhub-panel.onrender.com"
local userKey = _G.PJKey

if not userKey or userKey == "" or userKey == "SUA_KEY_AQUI" then
    LocalPlayer:Kick("\n[PJHub] Nenhuma key fornecida! Defina _G.PJKey antes de executar o script.")
    return
end

local function validateKey()
    local success, response = pcall(function()
        return request({
            Url = PANEL_URL .. "/api/validate?key=" .. userKey,
            Method = "GET",
            Headers = {["Content-Type"] = "application/json"}
        })
    end)

    if success and response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data.valid then
            return true, data.status
        else
            return false, data.message or "Key invalida ou expirada."
        end
    else
        return false, "Erro ao conectar com o servidor do PJHub."
    end
end

-- Validação Inicial
local isValid, statusMsg = validateKey()
if not isValid then
    LocalPlayer:Kick("\n[PJHub] " .. tostring(statusMsg))
    return
end

-- Loop de Checagem em Tempo Real (a cada 10s)
task.spawn(function()
    while task.wait(10) do
        local valid, msg = validateKey()
        if not valid then
            LocalPlayer:Kick("\n[PJHub] " .. tostring(msg))
            break
        end
    end
end)

-- ==========================================
-- INTERFACE GRÁFICA (UI NEON ROXA/PRETA)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PJHub_UI"
ScreenGui.ResetOnSpawn = false

pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)

-- Botão Flutuante Circular PJ
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Parent = ScreenGui
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0.05, 0, 0.2, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "PJ"
OpenButton.TextColor3 = Color3.fromRGB(180, 50, 255)
OpenButton.TextSize = 22
OpenButton.Font = Enum.Font.FredokaOne
OpenButton.Active = true
OpenButton.Draggable = true

local UICornerOpen = Instance.new("UICorner")
UICornerOpen.CornerRadius = UDim2.new(1, 0)
UICornerOpen.Parent = OpenButton

local UIStrokeOpen = Instance.new("UIStroke")
UIStrokeOpen.Color = Color3.fromRGB(180, 50, 255)
UIStrokeOpen.Thickness = 2.5
UIStrokeOpen.Parent = OpenButton

-- Painel Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 350)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim2.new(0, 12)
UICornerMain.Parent = MainFrame

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Color = Color3.fromRGB(180, 50, 255)
UIStrokeMain.Thickness = 2
UIStrokeMain.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "PJ HUB"
Title.TextColor3 = Color3.fromRGB(180, 50, 255)
Title.TextSize = 20
Title.Font = Enum.Font.FredokaOne

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Container dos Botões
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Parent = MainFrame
ButtonContainer.Size = UDim2.new(1, -20, 1, -50)
ButtonContainer.Position = UDim2.new(0, 10, 0, 45)
ButtonContainer.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ButtonContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- Função para Criar Toggles
local function createToggleButton(name, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = ButtonContainer
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    button.BorderSizePixel = 0
    button.Text = text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSansBold

    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim2.new(0, 8)
    UICornerBtn.Parent = button

    local UIStrokeBtn = Instance.new("UIStroke")
    UIStrokeBtn.Color = Color3.fromRGB(50, 50, 60)
    UIStrokeBtn.Thickness = 1.5
    UIStrokeBtn.Parent = button

    local enabled = false
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            button.Text = text .. ": ON"
            button.TextColor3 = Color3.fromRGB(180, 50, 255)
            UIStrokeBtn.Color = Color3.fromRGB(180, 50, 255)
        else
            button.Text = text .. ": OFF"
            button.TextColor3 = Color3.fromRGB(220, 220, 220)
            UIStrokeBtn.Color = Color3.fromRGB(50, 50, 60)
        end
        callback(enabled)
    end)
end

-- ==========================================
-- FUNÇÕES DO HUB
-- ==========================================

-- 1. Auto Go (Velocidade)
local autoGoConnection = nil
createToggleButton("AutoGoButton", "Auto Go", function(state)
    if state then
        autoGoConnection = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 32
            end
        end)
    else
        if autoGoConnection then
            autoGoConnection:Disconnect()
            autoGoConnection = nil
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- 2. Fast Jump (Pulo Rápido)
local fastJumpConnection = nil
createToggleButton("FastJumpButton", "Fast Jump", function(state)
    if state then
        fastJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if fastJumpConnection then
            fastJumpConnection:Disconnect()
            fastJumpConnection = nil
        end
    end
end)

-- 3. Auto Pegar Ovo (Instant Proximity Prompt)
local autoPickConnection = nil
createToggleButton("AutoPickButton", "Auto Pegar Ovo", function(state)
    if state then
        autoPickConnection = ProximityPromptService.PromptShown:Connect(function(prompt)
            prompt.HoldDuration = 0 -- Faz o tempo de segurar virar instantâneo
            fireproximityprompt(prompt) -- Interage automaticamente ao se aproximar
        end)
    else
        if autoPickConnection then
            autoPickConnection:Disconnect()
            autoPickConnection = nil
        end
    end
end)

-- 4. Anti-AFK
local antiAfkConnection = nil
createToggleButton("AntiAfkButton", "Anti AFK", function(state)
    if state then
        antiAfkConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end)
