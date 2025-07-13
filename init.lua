-- Roblox Code Editor UI Library
-- Version: 1.0
-- A modern, feature-rich code editor with syntax highlighting

local CodeEditorLib = {}

-- Default configuration
local DEFAULT_CONFIG = {
    -- Window settings
    WindowTitle = "Code Editor",
    WindowSize = UDim2.new(0, 600, 0, 400),
    WindowPosition = UDim2.new(0.5, -300, 0.5, -200),
    
    -- Theme settings
    Theme = {
        Background = Color3.fromRGB(30, 30, 30),
        TitleBar = Color3.fromRGB(40, 40, 40),
        TextBox = Color3.fromRGB(25, 25, 25),
        Button = Color3.fromRGB(45, 45, 45),
        ButtonHover = Color3.fromRGB(55, 55, 55),
        Text = Color3.fromRGB(255, 255, 255),
        TitleText = Color3.fromRGB(178, 75, 182),
        Border = Color3.fromRGB(60, 60, 60)
    },
    
    -- Editor settings
    Font = Enum.Font.Code,
    FontSize = 14,
    ShowLineNumbers = true,
    AutoIndent = true,
    TabSize = 4,
    
    -- Syntax highlighting
    EnableHighlighting = true,
    HighlightColors = {
        Keywords = Color3.fromRGB(220, 120, 220),
        Strings = Color3.fromRGB(150, 220, 150),
        Comments = Color3.fromRGB(120, 120, 150),
        Numbers = Color3.fromRGB(255, 158, 100),
        Operators = Color3.fromRGB(86, 214, 214),
        Functions = Color3.fromRGB(97, 175, 239),
        Variables = Color3.fromRGB(200, 200, 255),
        Booleans = Color3.fromRGB(255, 100, 100)
    }
}

-- Syntax highlighter module
local SyntaxHighlighter = {}

-- Keywords and patterns
local LUA_KEYWORDS = {
    "and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", 
    "while", "do", "for", "in", "end", "local", "return", "function", "export",
    "true", "false", "nil", "not"
}

local ROBLOX_GLOBALS = {
    "game", "workspace", "script", "math", "string", "table", "task", "wait",
    "select", "next", "Enum", "error", "warn", "tick", "assert", "shared",
    "loadstring", "tonumber", "tostring", "type", "typeof", "unpack", "print",
    "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2",
    "Ray", "BrickColor", "OverlapParams", "RaycastParams", "Axes", "Random",
    "Region3", "Rect", "TweenInfo", "collectgarbage", "utf8", "pcall", "xpcall",
    "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
}

local OPERATORS = {
    "#", "+", "-", "*", "%", "/", "^", "=", "~", "<", ">", ",", ".", "(", ")", 
    "{", "}", "[", "]", ";", ":", "==", "~=", "<=", ">="
}

-- Create keyword lookup tables
local function createKeywordSet(keywords)
    local set = {}
    for _, keyword in ipairs(keywords) do
        set[keyword] = true
    end
    return set
end

local luaKeywords = createKeywordSet(LUA_KEYWORDS)
local robloxGlobals = createKeywordSet(ROBLOX_GLOBALS)
local operators = createKeywordSet(OPERATORS)

-- Tokenizer
function SyntaxHighlighter.tokenize(source)
    local tokens = {}
    local currentToken = ""
    local inString = false
    local inComment = false
    local commentPersist = false
    local stringChar = nil
    
    for i = 1, #source do
        local char = source:sub(i, i)
        
        if inComment then
            if char == "\n" and not commentPersist then
                table.insert(tokens, {type = "comment", value = currentToken})
                table.insert(tokens, {type = "whitespace", value = char})
                currentToken = ""
                inComment = false
            elseif source:sub(i - 1, i) == "]]" and commentPersist then
                currentToken = currentToken .. "]"
                table.insert(tokens, {type = "comment", value = currentToken})
                currentToken = ""
                inComment = false
                commentPersist = false
            else
                currentToken = currentToken .. char
            end
        elseif inString then
            currentToken = currentToken .. char
            if char == stringChar and source:sub(i-1, i-1) ~= "\\" then
                table.insert(tokens, {type = "string", value = currentToken})
                currentToken = ""
                inString = false
                stringChar = nil
            end
        else
            if source:sub(i, i + 1) == "--" then
                if currentToken ~= "" then
                    table.insert(tokens, {type = "identifier", value = currentToken})
                    currentToken = ""
                end
                currentToken = "--"
                inComment = true
                commentPersist = source:sub(i + 2, i + 3) == "[["
            elseif char == "\"" or char == "\'" then
                if currentToken ~= "" then
                    table.insert(tokens, {type = "identifier", value = currentToken})
                    currentToken = ""
                end
                currentToken = char
                inString = true
                stringChar = char
            elseif operators[char] then
                if currentToken ~= "" then
                    table.insert(tokens, {type = "identifier", value = currentToken})
                    currentToken = ""
                end
                table.insert(tokens, {type = "operator", value = char})
            elseif char:match("[%w_]") then
                currentToken = currentToken .. char
            else
                if currentToken ~= "" then
                    table.insert(tokens, {type = "identifier", value = currentToken})
                    currentToken = ""
                end
                table.insert(tokens, {type = "whitespace", value = char})
            end
        end
    end
    
    if currentToken ~= "" then
        table.insert(tokens, {type = "identifier", value = currentToken})
    end
    
    return tokens
end

-- Highlight tokens
function SyntaxHighlighter.highlight(tokens, colors)
    local highlighted = {}
    
    for i, token in ipairs(tokens) do
        local color = nil
        local value = token.value
        
        if token.type == "comment" then
            color = colors.Comments
        elseif token.type == "string" then
            color = colors.Strings
        elseif token.type == "operator" then
            color = colors.Operators
        elseif token.type == "identifier" then
            if luaKeywords[value] then
                color = colors.Keywords
            elseif robloxGlobals[value] then
                color = colors.Functions
            elseif tonumber(value) then
                color = colors.Numbers
            elseif value == "true" or value == "false" then
                color = colors.Booleans
            else
                color = colors.Variables
            end
        end
        
        if color then
            local colorHex = string.format("#%02x%02x%02x", 
                math.floor(color.R * 255), 
                math.floor(color.G * 255), 
                math.floor(color.B * 255))
            local highlighted_text = string.format('<font color="%s">%s</font>', 
                colorHex, value:gsub("<", "&lt;"):gsub(">", "&gt;"))
            table.insert(highlighted, highlighted_text)
        else
            table.insert(highlighted, value)
        end
    end
    
    return table.concat(highlighted)
end

-- Main library functions
function CodeEditorLib.new(config)
    local self = {}
    
    -- Merge config with defaults
    config = config or {}
    for key, value in pairs(DEFAULT_CONFIG) do
        if config[key] == nil then
            config[key] = value
        elseif type(value) == "table" then
            config[key] = config[key] or {}
            for subkey, subvalue in pairs(value) do
                if config[key][subkey] == nil then
                    config[key][subkey] = subvalue
                end
            end
        end
    end
    
    self.config = config
    self.callbacks = {}
    
    -- Create GUI elements
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "CodeEditor"
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main frame
    self.frame = Instance.new("Frame")
    self.frame.Parent = self.screenGui
    self.frame.BackgroundColor3 = config.Theme.Background
    self.frame.BorderSizePixel = 1
    self.frame.BorderColor3 = config.Theme.Border
    self.frame.Size = config.WindowSize
    self.frame.Position = config.WindowPosition
    
    -- Title bar
    self.titleBar = Instance.new("Frame")
    self.titleBar.Parent = self.frame
    self.titleBar.BackgroundColor3 = config.Theme.TitleBar
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Size = UDim2.new(1, 0, 0, 30)
    self.titleBar.Position = UDim2.new(0, 0, 0, 0)
    
    -- Title label
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Parent = self.titleBar
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Size = UDim2.new(1, -60, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.titleLabel.Font = config.Font
    self.titleLabel.Text = config.WindowTitle
    self.titleLabel.TextColor3 = config.Theme.TitleText
    self.titleLabel.TextSize = config.FontSize
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close button
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Parent = self.titleBar
    self.closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Size = UDim2.new(0, 20, 0, 20)
    self.closeButton.Position = UDim2.new(1, -25, 0, 5)
    self.closeButton.Font = config.Font
    self.closeButton.Text = "×"
    self.closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.closeButton.TextSize = 14
    
    -- Text editor
    self.textBox = Instance.new("TextBox")
    self.textBox.Parent = self.frame
    self.textBox.BackgroundColor3 = config.Theme.TextBox
    self.textBox.BorderSizePixel = 1
    self.textBox.BorderColor3 = config.Theme.Border
    self.textBox.Size = UDim2.new(1, -20, 1, -80)
    self.textBox.Position = UDim2.new(0, 10, 0, 40)
    self.textBox.Font = config.Font
    self.textBox.Text = ""
    self.textBox.TextColor3 = config.Theme.Text
    self.textBox.TextSize = config.FontSize
    self.textBox.TextXAlignment = Enum.TextXAlignment.Left
    self.textBox.TextYAlignment = Enum.TextYAlignment.Top
    self.textBox.MultiLine = true
    self.textBox.ClearTextOnFocus = false
    self.textBox.PlaceholderText = "-- Enter your code here..."
    
    -- Buttons container
    self.buttonsFrame = Instance.new("Frame")
    self.buttonsFrame.Parent = self.frame
    self.buttonsFrame.BackgroundTransparency = 1
    self.buttonsFrame.Size = UDim2.new(1, -20, 0, 30)
    self.buttonsFrame.Position = UDim2.new(0, 10, 1, -40)
    
    -- Execute button
    self.executeButton = Instance.new("TextButton")
    self.executeButton.Parent = self.buttonsFrame
    self.executeButton.BackgroundColor3 = config.Theme.Button
    self.executeButton.BorderSizePixel = 0
    self.executeButton.Size = UDim2.new(0, 100, 1, 0)
    self.executeButton.Position = UDim2.new(0, 0, 0, 0)
    self.executeButton.Font = config.Font
    self.executeButton.Text = "Execute"
    self.executeButton.TextColor3 = config.Theme.Text
    self.executeButton.TextSize = config.FontSize
    
    -- Clear button
    self.clearButton = Instance.new("TextButton")
    self.clearButton.Parent = self.buttonsFrame
    self.clearButton.BackgroundColor3 = config.Theme.Button
    self.clearButton.BorderSizePixel = 0
    self.clearButton.Size = UDim2.new(0, 100, 1, 0)
    self.clearButton.Position = UDim2.new(0, 110, 0, 0)
    self.clearButton.Font = config.Font
    self.clearButton.Text = "Clear"
    self.clearButton.TextColor3 = config.Theme.Text
    self.clearButton.TextSize = config.FontSize
    
    -- Event handlers
    self.closeButton.MouseButton1Click:Connect(function()
        self:destroy()
    end)
    
    self.executeButton.MouseButton1Click:Connect(function()
        if self.callbacks.onExecute then
            self.callbacks.onExecute(self.textBox.Text)
        end
    end)
    
    self.clearButton.MouseButton1Click:Connect(function()
        self.textBox.Text = ""
        if self.callbacks.onClear then
            self.callbacks.onClear()
        end
    end)
    
    -- Syntax highlighting
    if config.EnableHighlighting then
        self.textBox:GetPropertyChangedSignal("Text"):Connect(function()
            self:updateHighlighting()
        end)
    end
    
    -- Add hover effects
    self:addHoverEffect(self.executeButton)
    self:addHoverEffect(self.clearButton)
    self:addHoverEffect(self.closeButton)
    
    return self
end

-- Methods
function CodeEditorLib:addHoverEffect(button)
    local originalColor = button.BackgroundColor3
    local hoverColor = self.config.Theme.ButtonHover
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

function CodeEditorLib:updateHighlighting()
    if not self.config.EnableHighlighting then return end
    
    local tokens = SyntaxHighlighter.tokenize(self.textBox.Text)
    local highlighted = SyntaxHighlighter.highlight(tokens, self.config.HighlightColors)
    
    -- Note: Rich text highlighting would need a TextLabel overlay
    -- For now, we'll keep the basic text in the TextBox
end

function CodeEditorLib:show()
    self.screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.frame.Visible = true
end

function CodeEditorLib:hide()
    self.frame.Visible = false
end

function CodeEditorLib:destroy()
    if self.screenGui then
        self.screenGui:Destroy()
    end
end

function CodeEditorLib:setText(text)
    self.textBox.Text = text
end

function CodeEditorLib:getText()
    return self.textBox.Text
end

function CodeEditorLib:setCallback(event, callback)
    self.callbacks[event] = callback
end

function CodeEditorLib:setTheme(theme)
    for key, value in pairs(theme) do
        self.config.Theme[key] = value
    end
    self:updateTheme()
end

function CodeEditorLib:updateTheme()
    self.frame.BackgroundColor3 = self.config.Theme.Background
    self.titleBar.BackgroundColor3 = self.config.Theme.TitleBar
    self.titleLabel.TextColor3 = self.config.Theme.TitleText
    self.textBox.BackgroundColor3 = self.config.Theme.TextBox
    self.textBox.TextColor3 = self.config.Theme.Text
    self.executeButton.BackgroundColor3 = self.config.Theme.Button
    self.clearButton.BackgroundColor3 = self.config.Theme.Button
end

-- Usage example
function CodeEditorLib.example()
    local editor = CodeEditorLib.new({
        WindowTitle = "My Code Editor",
        WindowSize = UDim2.new(0, 700, 0, 500)
    })
    
    editor:setCallback("onExecute", function(code)
        print("Executing code:", code)
        -- Add your code execution logic here
    end)
    
    editor:setCallback("onClear", function()
        print("Editor cleared")
    end)
    
    editor:show()
    
    return editor
end

return CodeEditorLib
