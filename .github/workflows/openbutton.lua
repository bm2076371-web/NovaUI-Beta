--[[
    NovaUI - OpenButton (estilo RedzLib)
    Bolinha flutuante arrastável para abrir/fechar a janela
]]

local OpenButton = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Icons = require(script.Parent.Parent.core.icons)

local function MakeDraggable(frame, callback)
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if callback then
                        callback(false)
                    end
                end
            end)

            if callback then
                callback(true)
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function OpenButton.New(config)
    config = config or {}

    local Size = config.Size or 45
    local Icon = Icons.Get(config.Icon or "home")
    local BackgroundColor = config.BackgroundColor or Color3.fromRGB(30, 30, 35)
    local IconColor = config.IconColor or Color3.fromRGB(255, 255, 255)
    local Position = config.Position or UDim2.new(0, 20, 0.5, 0)
    local Parent = config.Parent
    local OnClick = config.OnClick
    local StrokeColor = config.StrokeColor or Color3.fromRGB(80, 80, 90)
    local StrokeThickness = config.StrokeThickness or 1.5

    local Button = Instance.new("ImageButton")
    Button.Name = "NovaUI_OpenButton"
    Button.Size = UDim2.fromOffset(Size, Size)
    Button.Position = Position
    Button.AnchorPoint = Vector2.new(0.5, 0.5)
    Button.BackgroundColor3 = BackgroundColor
    Button.AutoButtonColor = false
    Button.Image = ""
    Button.Parent = Parent
    Button.ZIndex = 100
    Button.Visible = config.Visible ~= false

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0) -- total round
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = StrokeColor
    Stroke.Thickness = StrokeThickness
    Stroke.Transparency = 0.3
    Stroke.Parent = Button

    local IconLabel = Instance.new("ImageLabel")
    IconLabel.Name = "Icon"
    IconLabel.Size = UDim2.fromScale(0.55, 0.55)
    IconLabel.Position = UDim2.fromScale(0.5, 0.5)
    IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Image = Icon
    IconLabel.ImageColor3 = IconColor
    IconLabel.Parent = Button

    -- Shadow sutil
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.fromScale(0.5, 0.5)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ZIndex = Button.ZIndex - 1
    Shadow.Parent = Button

    -- Hover animation
    local originalSize = Button.Size
    local hoverSize = UDim2.fromOffset(Size + 6, Size + 6)

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Size = hoverSize
        }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {
            Transparency = 0
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
            Size = originalSize
        }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.2), {
            Transparency = 0.3
        }):Play()
    end)

    -- Click scale
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            Size = UDim2.fromOffset(Size - 4, Size - 4)
        }):Play()
    end)

    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
            Size = hoverSize
        }):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        if OnClick then
            task.spawn(OnClick)
        end
    end)

    -- Drag
    local isDragging = false
    MakeDraggable(Button, function(dragging)
        isDragging = dragging
    end)

    local API = {}

    function API:SetVisible(visible)
        Button.Visible = visible
    end

    function API:SetIcon(newIcon)
        IconLabel.Image = Icons.Get(newIcon)
    end

    function API:SetColor(bg, icon)
        if bg then Button.BackgroundColor3 = bg end
        if icon then IconLabel.ImageColor3 = icon end
    end

    function API:SetPosition(pos)
        Button.Position = pos
    end

    function API:GetButton()
        return Button
    end

    function API:Destroy()
        Button:Destroy()
    end

    return API
end

return OpenButton
