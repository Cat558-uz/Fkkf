local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Config = {
	Enabled = true,
	TextColor = Color3.fromRGB(255, 55, 55),
	StrokeColor = Color3.fromRGB(255, 150, 150),
	StrokeEnabled = true,
	StrokeTransparency = 0.2,
	TextSize = 24,
	Font = Enum.Font.GothamBold,
	Delay = 0.5,
	Duration = 0.8,
	RiseHeight = 2.5,
	RandomOffset = 1.2,
	MaxDistance = 250
}

local Connections = {}
local Tracked = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DamageIndicator"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ConfigButton = Instance.new("TextButton")
ConfigButton.Name = "ConfigButton"
ConfigButton.Size = UDim2.fromOffset(42, 42)
ConfigButton.Position = UDim2.new(0, 15, 0.5, -21)
ConfigButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ConfigButton.Text = "⚙"
ConfigButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigButton.TextSize = 20
ConfigButton.Font = Enum.Font.GothamBold
ConfigButton.Parent = ScreenGui

local ConfigCorner = Instance.new("UICorner")
ConfigCorner.CornerRadius = UDim.new(0, 10)
ConfigCorner.Parent = ConfigButton

local ConfigStroke = Instance.new("UIStroke")
ConfigStroke.Color = Color3.fromRGB(70, 70, 80)
ConfigStroke.Thickness = 1
ConfigStroke.Parent = ConfigButton

local Window = Instance.new("Frame")
Window.Name = "ConfigWindow"
Window.Size = UDim2.fromOffset(300, 365)
Window.Position = UDim2.new(0.5, -150, 0.5, -182)
Window.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Window.Visible = false
Window.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 14)
WindowCorner.Parent = Window

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Color = Color3.fromRGB(55, 55, 65)
WindowStroke.Thickness = 1
WindowStroke.Parent = Window

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 45)
Title.Position = UDim2.fromOffset(15, 5)
Title.BackgroundTransparency = 1
Title.Text = "Damage Indicator"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Window

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -42, 0, 10)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220, 220, 220)
Close.TextSize = 25
Close.Font = Enum.Font.GothamBold
Close.Parent = Window

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.fromOffset(10, 55)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new()
Content.Parent = Window

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Content

local function UpdateCanvas()
	Content.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 10)
end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

local function CreateButton(text, callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -5, 0, 38)
	Button.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(235, 235, 235)
	Button.TextSize = 14
	Button.Font = Enum.Font.GothamMedium
	Button.AutoButtonColor = true
	Button.Parent = Content

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	Button.Activated:Connect(callback)

	return Button
end

local function CreateLabel(text)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -5, 0, 27)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(180, 180, 190)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamMedium
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Content
	return Label
end

CreateButton("Sistema: ATIVADO", function(Button)
	Config.Enabled = not Config.Enabled
	Button.Text = "Sistema: " .. (Config.Enabled and "ATIVADO" or "DESATIVADO")
end)

CreateButton("Borda: ATIVADA", function(Button)
	Config.StrokeEnabled = not Config.StrokeEnabled
	Button.Text = "Borda: " .. (Config.StrokeEnabled and "ATIVADA" or "DESATIVADA")
end)

CreateLabel("Tamanho do texto")

CreateButton("Tamanho: 24", function(Button)
	Config.TextSize += 2
	if Config.TextSize > 40 then
		Config.TextSize = 14
	end
	Button.Text = "Tamanho: " .. Config.TextSize
end)

CreateLabel("Fonte")

CreateButton("Fonte: GothamBold", function(Button)
	local Fonts = {
		Enum.Font.GothamBold,
		Enum.Font.GothamBlack,
		Enum.Font.SourceSansBold,
		Enum.Font.Arcade,
		Enum.Font.FredokaOne,
		Enum.Font.Code,
		Enum.Font.Highway
	}

	local Current = 1

	for Index, Font in ipairs(Fonts) do
		if Font == Config.Font then
			Current = Index
			break
		end
	end

	Current += 1

	if Current > #Fonts then
		Current = 1
	end

	Config.Font = Fonts[Current]
	Button.Text = "Fonte: " .. tostring(Config.Font):gsub("Enum.Font.", "")
end)

CreateLabel("Cor do texto")

CreateButton("Vermelho", function(Button)
	local Colors = {
		{"Vermelho", Color3.fromRGB(255, 55, 55)},
		{"Laranja", Color3.fromRGB(255, 125, 45)},
		{"Amarelo", Color3.fromRGB(255, 220, 55)},
		{"Branco", Color3.fromRGB(255, 255, 255)},
		{"Rosa", Color3.fromRGB(255, 80, 170)},
		{"Roxo", Color3.fromRGB(175, 80, 255)},
		{"Azul", Color3.fromRGB(70, 150, 255)}
	}

	local Current = 1

	for Index, Data in ipairs(Colors) do
		if Config.TextColor == Data[2] then
			Current = Index
			break
		end
	end

	Current += 1

	if Current > #Colors then
		Current = 1
	end

	Config.TextColor = Colors[Current][2]
	Button.Text = "Cor: " .. Colors[Current][1]
end)

CreateLabel("Cor da borda")

CreateButton("Borda: vermelho claro", function(Button)
	local Colors = {
		{"Vermelho claro", Color3.fromRGB(255, 150, 150)},
		{"Branco", Color3.fromRGB(255, 255, 255)},
		{"Amarelo", Color3.fromRGB(255, 230, 100)},
		{"Rosa", Color3.fromRGB(255, 130, 200)},
		{"Roxo", Color3.fromRGB(200, 120, 255)},
		{"Azul", Color3.fromRGB(120, 190, 255)}
	}

	local Current = 1

	for Index, Data in ipairs(Colors) do
		if Config.StrokeColor == Data[2] then
			Current = Index
			break
		end
	end

	Current += 1

	if Current > #Colors then
		Current = 1
	end

	Config.StrokeColor = Colors[Current][2]
	Button.Text = "Borda: " .. Colors[Current][1]
end)

CreateLabel("Transparência da borda")

CreateButton("Transparência: 0.2", function(Button)
	Config.StrokeTransparency += 0.1

	if Config.StrokeTransparency > 1 then
		Config.StrokeTransparency = 0
	end

	Button.Text = string.format("Transparência: %.1f", Config.StrokeTransparency)
end)

CreateLabel("Atraso antes de aparecer")

CreateButton("Atraso: 0.5s", function(Button)
	Config.Delay += 0.1

	if Config.Delay > 1 then
		Config.Delay = 0
	end

	Button.Text = string.format("Atraso: %.1fs", Config.Delay)
end)

CreateLabel("Altura da animação")

CreateButton("Subida: 2.5", function(Button)
	Config.RiseHeight += 0.5

	if Config.RiseHeight > 6 then
		Config.RiseHeight = 1
	end

	Button.Text = string.format("Subida: %.1f", Config.RiseHeight)
end)

CreateLabel("Aleatoriedade da posição")

CreateButton("Aleatório: 1.2", function(Button)
	Config.RandomOffset += 0.2

	if Config.RandomOffset > 3 then
		Config.RandomOffset = 0
	end

	Button.Text = string.format("Aleatório: %.1f", Config.RandomOffset)
end)

ConfigButton.Activated:Connect(function()
	Window.Visible = not Window.Visible
end)

Close.Activated:Connect(function()
	Window.Visible = false
end)

local function GetRoot(Character)
	return Character:FindFirstChild("HumanoidRootPart")
		or Character:FindFirstChild("UpperTorso")
		or Character:FindFirstChild("Torso")
end

local function CreateDamage(Character, Damage)
	if not Config.Enabled then
		return
	end

	if Damage <= 0 then
		return
	end

	local Root = GetRoot(Character)

	if not Root then
		return
	end

	local Distance = (Root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

	if Distance > Config.MaxDistance then
		return
	end

	task.delay(Config.Delay, function()
		if not Config.Enabled then
			return
		end

		if not Character.Parent or not Root.Parent then
			return
		end

		local Billboard = Instance.new("BillboardGui")
		Billboard.Name = "DamageNumber"
		Billboard.Adornee = Root
		Billboard.Size = UDim2.fromOffset(120, 45)
		Billboard.StudsOffset = Vector3.new(
			math.random(-100, 100) / 100 * Config.RandomOffset,
			2.5 + math.random(-100, 100) / 100 * Config.RandomOffset,
			math.random(-100, 100) / 100 * Config.RandomOffset
		)
		Billboard.AlwaysOnTop = true
		Billboard.LightInfluence = 0
		Billboard.MaxDistance = Config.MaxDistance
		Billboard.Parent = ScreenGui

		local Text = Instance.new("TextLabel")
		Text.BackgroundTransparency = 1
		Text.Size = UDim2.fromScale(1, 1)
		Text.Text = "-" .. tostring(math.floor(Damage))
		Text.TextColor3 = Config.TextColor
		Text.TextSize = Config.TextSize
		Text.Font = Config.Font
		Text.TextTransparency = 0
		Text.TextStrokeColor3 = Config.StrokeColor
		Text.TextStrokeTransparency = Config.StrokeEnabled and Config.StrokeTransparency or 1
		Text.Parent = Billboard

		local StartOffset = Billboard.StudsOffset

		local MoveTween = TweenService:Create(
			Billboard,
			TweenInfo.new(
				Config.Duration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				StudsOffset = StartOffset + Vector3.new(
					math.random(-20, 20) / 100,
					Config.RiseHeight,
					math.random(-20, 20) / 100
				)
			}
		)

		local FadeTween = TweenService:Create(
			Text,
			TweenInfo.new(
				Config.Duration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)

		MoveTween:Play()
		FadeTween:Play()

		FadeTween.Completed:Once(function()
			Billboard:Destroy()
		end)
	end)
end

local function TrackCharacter(Player, Character)
	if Player == LocalPlayer then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Humanoid then
		Humanoid = Character:WaitForChild("Humanoid", 5)
	end

	if not Humanoid then
		return
	end

	if Tracked[Character] then
		return
	end

	Tracked[Character] = true

	local LastHealth = Humanoid.Health

	local Connection = Humanoid.HealthChanged:Connect(function(NewHealth)
		if NewHealth < LastHealth then
			local Damage = LastHealth - NewHealth
			CreateDamage(Character, Damage)
		end

		LastHealth = NewHealth
	end)

	table.insert(Connections, Connection)

	Character.Destroying:Once(function()
		Tracked[Character] = nil

		if Connection then
			Connection:Disconnect()
		end
	end)
end

local function TrackPlayer(Player)
	if Player == LocalPlayer then
		return
	end

	if Player.Character then
		task.spawn(TrackCharacter, Player, Player.Character)
	end

	Player.CharacterAdded:Connect(function(Character)
		task.wait(0.2)
		TrackCharacter(Player, Character)
	end)
end

for _, Player in ipairs(Players:GetPlayers()) do
	TrackPlayer(Player)
end

Players.PlayerAdded:Connect(TrackPlayer)

Players.PlayerRemoving:Connect(function(Player)
	if Player.Character then
		Tracked[Player.Character] = nil
	end
end)

ScreenGui.Destroying:Connect(function()
	for _, Connection in ipairs(Connections) do
		if Connection then
			Connection:Disconnect()
		end
	end

	table.clear(Connections)
	table.clear(Tracked)
end)
