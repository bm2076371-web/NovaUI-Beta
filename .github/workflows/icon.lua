--[[
    NovaUI - Icons System
    Suporte a:
    - rbxassetid://
    - Lucide icons
    - URLs (Google, Imgur, etc.)
]]

local Icons = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Cache de ícones baixados
local IconCache = {}

-- Packs de ícones embutidos (Lucide básico)
local BuiltIn = {
    home = "rbxassetid://10734950309",
    settings = "rbxassetid://10734950309",
    user = "rbxassetid://10734951538",
    search = "rbxassetid://10734943674",
    close = "rbxassetid://10747384394",
    minimize = "rbxassetid://10734896206",
    maximize = "rbxassetid://10734924532",
    chevron_down = "rbxassetid://10709781958",
    chevron_up = "rbxassetid://10709781517",
    check = "rbxassetid://10709790644",
    x = "rbxassetid://10747384394",
    star = "rbxassetid://10734966248",
    heart = "rbxassetid://10734932373",
    info = "rbxassetid://10723415903",
    warning = "rbxassetid://10723407389",
    error = "rbxassetid://10747384394",
    success = "rbxassetid://10709790644",
}

function Icons.Get(icon)
    if not icon or icon == "" then
        return nil
    end

    -- Já é rbxassetid
    if type(icon) == "string" and string.find(icon, "rbxassetid://") then
        return icon
    end

    -- Número puro
    if type(icon) == "number" then
        return "rbxassetid://" .. tostring(icon)
    end

    -- Lucide style: "lucide:home" ou só "home"
    local clean = tostring(icon):lower():gsub("lucide:", ""):gsub(" ", "_")
    if BuiltIn[clean] then
        return BuiltIn[clean]
    end

    -- URL (http/https)
    if type(icon) == "string" and (string.find(icon, "http://") or string.find(icon, "https://")) then
        return Icons.LoadFromURL(icon)
    end

    -- Fallback
    return BuiltIn.home
end

function Icons.LoadFromURL(url)
    if IconCache[url] then
        return IconCache[url]
    end

    -- Em Studio ou sem writefile, retorna placeholder
    if RunService:IsStudio() or not writefile or not getcustomasset then
        return "rbxassetid://10734950309" -- placeholder
    end

    local success, result = pcall(function()
        local filename = "NovaUI/icons/" .. HttpService:GenerateGUID(false) .. ".png"
        
        if not isfolder("NovaUI") then
            makefolder("NovaUI")
        end
        if not isfolder("NovaUI/icons") then
            makefolder("NovaUI/icons")
        end

        local body
        if game.HttpGet then
            body = game:HttpGet(url)
        elseif request or http_request or syn and syn.request then
            local req = request or http_request or syn.request
            body = req({Url = url, Method = "GET"}).Body
        end

        if body then
            writefile(filename, body)
            local asset = getcustomasset(filename)
            IconCache[url] = asset
            return asset
        end
    end)

    if success and result then
        return result
    end

    return "rbxassetid://10734950309"
end

function Icons.Add(name, assetId)
    BuiltIn[tostring(name):lower()] = type(assetId) == "number" and ("rbxassetid://" .. assetId) or assetId
end

return Icons
