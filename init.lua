local COE = {}

-- Renk paleti
COE.Colors = {
    Background = Color3.fromRGB(30, 30, 30),
    Secondary = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(178, 75, 182)
}

-- Temel pencere oluşturma fonksiyonu
function COE:CreateWindow(name, size, position)
    local Window = {}
    
    -- Ana GUI elementlerini oluştur
    Window.ScreenGui = Instance.new("ScreenGui")
    Window.Frame = Instance.new("Frame")
    Window.Title = Instance.new("TextLabel")
    
    -- Özellikleri ayarla
    Window.ScreenGui.Name = name
    Window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Window.Frame.Name = "MainFrame"
    Window.Frame.BackgroundColor3 = COE.Colors.Background
    Window.Frame.BorderSizePixel = 0
    Window.Frame.Size = size or UDim2.new(0, 535, 0, 333)
    Window.Frame.Position = position or UDim2.new(0.338, 0, 0.295, 0)
    Window.Frame.Parent = Window.ScreenGui
    
    Window.Title.Name = "TitleLabel"
    Window.Title.Text = name or "COE - Create Your Own Executor"
    Window.Title.TextColor3 = COE.Colors.Accent
    Window.Title.BackgroundTransparency = 1
    Window.Title.Size = UDim2.new(1, 0, 0, 28)
    Window.Title.Font = Enum.Font.SourceSans
    Window.Title.TextSize = 14
    Window.Title.Parent = Window.Frame
    
    -- Pencereyi görünür yap
    Window.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Metotlar
    function Window:AddTextBox(name, position, size)
        local TextBox = Instance.new("TextBox")
        TextBox.Name = name or "CodeBox"
        TextBox.BackgroundColor3 = COE.Colors.Secondary
        TextBox.BorderSizePixel = 0
        TextBox.Position = position or UDim2.new(0.013, 0, 0.084, 0)
        TextBox.Size = size or UDim2.new(0, 522, 0, 249)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.TextColor3 = COE.Colors.Text
        TextBox.TextSize = 14
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.TextYAlignment = Enum.TextYAlignment.Top
        TextBox.TextWrapped = true
        TextBox.Parent = self.Frame
        
        -- Syntax highlighting ekle
        local script = Instance.new('LocalScript', TextBox)
        local MainModule = require(script.Parent:WaitForChild("MainModule"))
        MainModule(TextBox, {
            Highlight = true,
            Colors = {
                Globals = Color3.fromRGB(97, 175, 239),
                Numbers = Color3.fromRGB(255, 158, 100),
                Tokens = Color3.fromRGB(86, 214, 214),
                Comments = Color3.fromRGB(120, 120, 150),
                Keywords = Color3.fromRGB(220, 120, 220),
                Strings = Color3.fromRGB(150, 220, 150)
            }
        })
        
        return TextBox
    end
    
    function Window:AddButton(name, position, size, callback)
        local Button = Instance.new("TextButton")
        Button.Name = name or "Button"
        Button.BackgroundColor3 = COE.Colors.Secondary
        Button.BorderSizePixel = 0
        Button.Position = position or UDim2.new(0.032, 0, 0.88, 0)
        Button.Size = size or UDim2.new(0, 109, 0, 30)
        Button.Font = Enum.Font.SourceSans
        Button.Text = name or "Button"
        Button.TextColor3 = COE.Colors.Text
        Button.TextSize = 14
        Button.Parent = self.Frame
        
        if callback then
            Button.MouseButton1Click:Connect(callback)
        end
        
        return Button
    end
    
    function Window:Destroy()
        self.ScreenGui:Destroy()
    end
    
    return Window
end

-- Örnek kullanım fonksiyonu
function COE:Example()
    local Window = self:CreateWindow("COE Executor")
    
    local CodeBox = Window:AddTextBox("CodeBox")
    
    Window:AddButton("Execute", nil, nil, function()
        local success, err = pcall(function()
            loadstring(CodeBox.Text)()
        end)
        
        if not success then
            warn("Execution error:", err)
        end
    end)
    
    Window:AddButton("Clear", UDim2.new(0.254, 0, 0.88, 0), nil, function()
        CodeBox.Text = ""
    end)
end

return COE
