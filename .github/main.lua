--[[
     _   _                  _   _ ___
    | \ | | _____   ____ _ | | | |_ _|
    |  \| |/ _ \ \ / / _` || | | || |
    | |\  | (_) \ V / (_| || |_| || |
    |_| \_|\___/ \_/ \__,_| \___/|___|
    
    NovaUI v1.0.0
    Base: WindUI + OpenButton estilo RedzLib
    
    Author: Você + Grok
    Compatível com API original do WindUI
]]

local NovaUI = {
    Version = "1.0.0",
    Name = "NovaUI",
    Window = nil,
    OpenButton = nil,
    WindUI = nil, -- referência à lib original
}

-- =====================================================
-- Carrega o WindUI (você pode trocar pela URL ou local)
-- =====================================================
local function LoadWindUI()
    -- Opção 1: usar o arquivo local que você enviou
    -- Opção 2: loadstring da URL oficial do WindUI
    
    local success, result = pcall(function()
        -- Tenta carregar do GitHub oficial do WindUI
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)

    if success and result then
        return result
    end

    -- Fallback: se você tiver o arquivo local
    warn("[NovaUI] Não foi possível carregar WindUI remoto. Use o arquivo local.")
    return nil
end

-- =====================================================
-- Módulos internos
-- =====================================================
local Icons = nil
local OpenButtonModule = nil

-- Como estamos em um ambiente de arquivos, vamos simular o require
-- No uso real, você coloca os arquivos juntos ou usa loadstring

local function GetIcons()
    -- Inline do sistema de ícones para facilitar
    local IconsModule = {}
    local BuiltIn = {
        home = "rbxassetid://10734950309",
        settings = "rbxassetid://10734950309",
        user = "rbxassetid://10734951538",
        search = "rbxassetid://10734943674",
        close = "rbxassetid://10747384394",
        minimize = "rbxassetid://10734896206",
        star = "rbxassetid://10734966248",
        heart = "rbxassetid://10734932373",
        info = "rbxassetid://10723415903",
    }

    function IconsModule.Get(icon)
        if not icon or icon == "" then return BuiltIn.home end
        if type(icon) == "string" and string.find(icon, "rbxassetid://") then return icon end
        if type(icon) == "number" then return "rbxassetid://" .. tostring(icon) end
        if type(icon) == "string" and (string.find(icon, "http://") or string.find(icon, "https://")) then
            -- URL support (simplificado)
            return icon -- WindUI já tem suporte parcial a URL
        end
        local clean = tostring(icon):lower():gsub("lucide:", ""):gsub(" ", "_")
        return BuiltIn[clean] or BuiltIn.home
    end

    function IconsModule.Add(name, id)
        BuiltIn[tostring(name):lower()] = type(id) == "number" and ("rbxassetid://" .. id) or id
    end

    return IconsModule
end

Icons = GetIcons()

-- =====================================================
-- OpenButton estilo RedzLib (inline para facilitar)
-- =====================================================
local function CreateOpenButton(config)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    config = config or {}
    local Size = config.Size or 48
    local Icon = Icons.Get(config.Icon or "home")
    local BackgroundColor = config.BackgroundColor or Color3.fromRGB(25, 25, 30)
    local IconColor = config.IconColor or Color3.fromRGB(255, 255, 255)
    local Position = config.Position or UDim2.new(0, 30, 0.5, 0)
    local Parent = config.Parent
    local OnClick = config.OnClick
    local StrokeColor = config.StrokeColor or Color3.fromRGB(70, 70, 80)

    local Button = Instance.new("ImageButton")
    Button.Name = "NovaUI_OpenButton"
    Button.Size = UDim2.fromOffset(Size, Size)
    Button.Position = Position
    Button.AnchorPoint = Vector2.new(0.5, 0.5)
    Button.BackgroundColor3 = BackgroundColor
    Button.AutoButtonColor = false
    Button.Image = ""
    Button.Parent = Parent
    Button.ZIndex = 999
    Button.Visible = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = StrokeColor
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.4
    Stroke.Parent = Button

    local IconLabel = Instance.new("ImageLabel")
    IconLabel.Name = "Icon"
    IconLabel.Size = UDim2.fromScale(0.5, 0.5)
    IconLabel.Position = UDim2.fromScale(0.5, 0.5)
    IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Image = Icon
    IconLabel.ImageColor3 = IconColor
    IconLabel.Parent = Button

    -- Drag
    local dragging, dragStart, startPos
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Button.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Hover
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(Size + 6, Size + 6)
        }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), { Transparency = 0 }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(Size, Size)
        }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), { Transparency = 0.4 }):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        if OnClick then
            task.spawn(OnClick)
        end
    end)

    local API = {}
    function API:SetVisible(v) Button.Visible = v end
    function API:SetIcon(i) IconLabel.Image = Icons.Get(i) end
    function API:SetColor(bg, icon)
        if bg then Button.BackgroundColor3 = bg end
        if icon then IconLabel.ImageColor3 = icon end
    end
    function API:GetButton() return Button end
    function API:Destroy() Button:Destroy() end

    return API
end

-- =====================================================
-- API Principal da NovaUI
-- =====================================================

function NovaUI:CreateWindow(config)
    config = config or {}

    -- Carrega WindUI
    local WindUI = LoadWindUI()
    if not WindUI then
        error("[NovaUI] WindUI não encontrado. Verifique a conexão ou use o arquivo local.")
    end

    self.WindUI = WindUI

    -- Configurações padrão da NovaUI
    config.Title = config.Title or "NovaUI"
    config.Author = config.Author or "NovaUI"
    config.Folder = config.Folder or "NovaUI"
    config.Theme = config.Theme or "Dark"

    -- Cria a janela usando WindUI (compatibilidade total)
    local Window = WindUI:CreateWindow(config)
    self.Window = Window

    -- Cria a bolinha estilo RedzLib
    local openBtnConfig = config.OpenButton or {}
    self.OpenButton = CreateOpenButton({
        Size = openBtnConfig.Size or 48,
        Icon = openBtnConfig.Icon or config.Icon or "home",
        BackgroundColor = openBtnConfig.BackgroundColor or Color3.fromRGB(25, 25, 30),
        IconColor = openBtnConfig.IconColor or Color3.fromRGB(255, 255, 255),
        Position = openBtnConfig.Position or UDim2.new(0, 30, 0.5, 0),
        Parent = WindUI.ScreenGui or game:GetService("CoreGui"),
        OnClick = function()
            if Window.Closed then
                Window:Open()
                self.OpenButton:SetVisible(false)
            else
                Window:Close()
                self.OpenButton:SetVisible(true)
            end
        end
    })

    -- Quando a janela fecha, mostra a bolinha
    if Window.OnClose then
        Window:OnClose(function()
            self.OpenButton:SetVisible(true)
        end)
    end

    -- Quando a janela abre, esconde a bolinha
    if Window.OnOpen then
        Window:OnOpen(function()
            self.OpenButton:SetVisible(false)
        end)
    end

    -- Inicialmente esconde a bolinha (janela começa aberta)
    self.OpenButton:SetVisible(false)

    -- Expõe métodos extras
    function Window:ToggleOpenButton(visible)
        if self.OpenButton then
            self.OpenButton:SetVisible(visible)
        end
    end

    function Window:SetOpenButtonIcon(icon)
        if NovaUI.OpenButton then
            NovaUI.OpenButton:SetIcon(icon)
        end
    end

    function Window:SetOpenButtonColor(bg, icon)
        if NovaUI.OpenButton then
            NovaUI.OpenButton:SetColor(bg, icon)
        end
    end

    -- Compatibilidade: retorna a Window do WindUI + extras
    return Window
end

-- Atalhos de compatibilidade com WindUI
function NovaUI:Notify(config)
    if self.WindUI then
        return self.WindUI:Notify(config)
    end
end

function NovaUI:SetTheme(theme)
    if self.WindUI then
        return self.WindUI:SetTheme(theme)
    end
end

function NovaUI:GetThemes()
    if self.WindUI then
        return self.WindUI:GetThemes()
    end
end

-- Sistema de ícones exposto
NovaUI.Icons = Icons

return NovaUI
