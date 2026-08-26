--[[
    NovaUI - Exemplo de uso
]]

local NovaUI = loadstring(game:HttpGet("URL_DA_SUA_LIB_AQUI"))() 
-- ou local NovaUI = require(path.to.NovaUI.main)

local Window = NovaUI:CreateWindow({
    Title = "Meu Hub",
    Author = "by NovaUI",
    Folder = "MeuHub",
    Icon = "home", -- ou "rbxassetid://123" ou URL

    -- Bolinha estilo RedzLib
    OpenButton = {
        Size = 48,
        Icon = "home",                          -- rbxassetid / lucide / url
        BackgroundColor = Color3.fromRGB(25, 25, 30),
        IconColor = Color3.fromRGB(100, 180, 255),
        Position = UDim2.new(0, 30, 0.5, 0),
    },

    Theme = "Dark",
    Size = UDim2.fromOffset(580, 460),
    ToggleKey = Enum.KeyCode.RightShift,
})

-- Tabs (API 100% compatível com WindUI)
local Tab1 = Window:Tab({
    Title = "Principal",
    Icon = "home",
})

Tab1:Button({
    Title = "Testar Botão",
    Desc = "Clique para testar",
    Callback = function()
        NovaUI:Notify({
            Title = "NovaUI",
            Content = "Funcionando!",
            Duration = 3,
        })
    end
})

Tab1:Toggle({
    Title = "Ativar Feature",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end
})

local Tab2 = Window:Tab({
    Title = "Configurações",
    Icon = "settings",
})

Tab2:Paragraph({
    Title = "Sobre",
    Desc = "NovaUI v1.0 - Baseada no WindUI + bolinha estilo RedzLib",
})

-- Exemplos de ícones
-- Window:SetOpenButtonIcon("rbxassetid://71014873973869")
-- Window:SetOpenButtonIcon("https://i.imgur.com/xxx.png")
-- Window:SetOpenButtonColor(Color3.fromRGB(40, 20, 60), Color3.fromRGB(200, 100, 255))
