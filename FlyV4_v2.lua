local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextBox")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")
local config = Instance.new("TextButton")
local fpsLabel = Instance.new("TextLabel")
local deviceLabel = Instance.new("TextLabel")

local ConfigFrame
local ConfigScale

local backgroundTransparency = 0.12
local mainButtonsTransparency = 0.05
local otherButtonsTransparency = 0.05
local configTransparency = 0.12

local interfaceScale = 1
local configScaleValue = 0.85

local language = "PT"
local flySpeed = 1
local minimized = false
local closing = false
local saveSpeed = true
local showFPS = false
local showMS = false
local showDevice = false
local metricsTransparency = 0.05
local metricsScaleValue = 1
local pcFly = false
local buttonSizeScale = 1
local cornerRadius = 7
local flyAnimation = true
local selectedFont = "GothamBold"

local activationKey = Enum.KeyCode.F
local waitingForKey = false
local activationKeyConnection
local activationActionName = "FlyV4Activation"
local flyRenderConnection
local flyBodyVelocity
local flyBodyGyro
local flyInputBeganConnection
local flyInputEndedConnection
local flyUpInput = 0
local flyDownInput = 0
local flyKeys = {W=false,S=false,A=false,D=false,Space=false,LeftControl=false}

local speedFile = "FlyV4_Config.json"

local fonts = {
	"Legacy",
	"Arial",
	"ArialBold",
	"SourceSans",
	"SourceSansBold",
	"SourceSansSemibold",
	"SourceSansLight",
	"SourceSansItalic",
	"Bodoni",
	"Garamond",
	"Cartoon",
	"Code",
	"Highway",
	"SciFi",
	"Arcade",
	"Fantasy",
	"Antique",
	"Gotham",
	"GothamMedium",
	"GothamBold",
	"GothamBlack",
	"GothamSemibold",
	"Roboto",
	"RobotoMono",
	"Ubuntu"
}

local fontMap = {}

for _, fontName in ipairs(fonts) do
	local success, value = pcall(function()
		return Enum.Font[fontName]
	end)

	if success and value then
		fontMap[fontName] = value
	end
end

local function fileExists(path)
	return type(isfile) == "function" and isfile(path)
end

local function saveConfig()
	if type(writefile) ~= "function" then
		return
	end

	local data = {
		Speed = flySpeed,
		SaveSpeed = saveSpeed,
		BackgroundTransparency = backgroundTransparency,
		MainButtonsTransparency = mainButtonsTransparency,
		OtherButtonsTransparency = otherButtonsTransparency,
		ConfigTransparency = configTransparency,
		Scale = interfaceScale,
		ConfigScale = configScaleValue,
		Language = language,
		Font = selectedFont,
		ShowFPS = showFPS,
		ShowMS = showMS,
		ShowDevice = showDevice,
		MetricsTransparency = metricsTransparency,
		MetricsScale = metricsScaleValue,
		PCFly = pcFly,
		ActivationKey = activationKey.Name,
		ButtonSize = buttonSizeScale,
		CornerRadius = cornerRadius,
		FlyAnimation = flyAnimation
	}

	local success, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if success then
		pcall(function()
			writefile(speedFile, encoded)
		end)
	end
end

local function loadConfig()
	if type(readfile) ~= "function" or not fileExists(speedFile) then
		return
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(speedFile))
	end)

	if not success or type(data) ~= "table" then
		return
	end

	if type(data.Speed) == "number" then
		flySpeed = math.clamp(
			math.round(data.Speed * 10) / 10,
			0.1,
			150
		)
	end

	if type(data.SaveSpeed) == "boolean" then
		saveSpeed = data.SaveSpeed
	end

	if type(data.BackgroundTransparency) == "number" then
		backgroundTransparency = math.clamp(
			data.BackgroundTransparency,
			0,
			0.8
		)
	end

	if type(data.MainButtonsTransparency) == "number" then
		mainButtonsTransparency = math.clamp(
			data.MainButtonsTransparency,
			0,
			0.8
		)
	end

	if type(data.OtherButtonsTransparency) == "number" then
		otherButtonsTransparency = math.clamp(
			data.OtherButtonsTransparency,
			0,
			0.8
		)
	end

	if type(data.ConfigTransparency) == "number" then
		configTransparency = math.clamp(
			data.ConfigTransparency,
			0,
			0.8
		)
	end

	if type(data.Scale) == "number" then
		interfaceScale = math.clamp(
			data.Scale,
			0.4,
			2.9
		)
	end

	if type(data.ConfigScale) == "number" then
		configScaleValue = math.clamp(
			data.ConfigScale,
			0.65,
			1.1
		)
	end

	if data.Language == "PT"
		or data.Language == "EN"
		or data.Language == "ES" then
		language = data.Language
	end

	if type(data.Font) == "string"
		and fontMap[data.Font] then
		selectedFont = data.Font
	end

	if type(data.ShowFPS) == "boolean" then
		showFPS = data.ShowFPS
	end

	if type(data.PCFly) == "boolean" then
		pcFly = data.PCFly
	end

	if type(data.ActivationKey) == "string" then
		local keySuccess, keyCode = pcall(function()
			return Enum.KeyCode[data.ActivationKey]
		end)

		if keySuccess and keyCode then
			activationKey = keyCode
		end
	end
	if type(data.ShowMS) == "boolean" then showMS = data.ShowMS end
	if type(data.ShowDevice) == "boolean" then showDevice = data.ShowDevice end
	if type(data.MetricsTransparency) == "number" then metricsTransparency = math.clamp(data.MetricsTransparency, 0, 0.8) end
	if type(data.MetricsScale) == "number" then metricsScaleValue = math.clamp(data.MetricsScale, 0.6, 1.8) end
	if type(data.ButtonSize) == "number" then buttonSizeScale = math.clamp(data.ButtonSize, 0.6, 2) end
	if type(data.CornerRadius) == "number" then cornerRadius = math.clamp(math.round(data.CornerRadius), 0, 25) end
	if type(data.FlyAnimation) == "boolean" then flyAnimation = data.FlyAnimation end
end

loadConfig()

local translations = {
	PT = {
		title = "CONFIGURAÇÕES",
		languagePT = "Idioma: Português",
		languageEN = "Idioma: Inglês",
		languageES = "Idioma: Espanhol",
		background = "Transparência do Fundo",
		mainButtons = "Transparência dos Botões",
		otherButtons = "Transparência dos Outros Botões",
		configTransparency = "Transparência da Config",
		size = "Tamanho da Fly",
		configSize = "Tamanho da Config",
		saveSpeed = "Salvar Velocidade",
		showFPS = "FPS no Fly GUI",
		pcFly = "Fly no PC",
		activationKey = "Tecla para Ativar/Desativar",
		pressKey = "PRESSIONE UMA TECLA",
		font = "Fonte",
		previous = "Anterior",
		next = "Próxima",
		closeQuestion = "Fechar Fly v4?",
		yes = "SIM",
		no = "NÃO",
		fly = "VOAR"
	},

	EN = {
		title = "SETTINGS",
		languagePT = "Language: Portuguese",
		languageEN = "Language: English",
		languageES = "Language: Spanish",
		background = "Background Transparency",
		mainButtons = "Main Buttons Transparency",
		otherButtons = "Other Buttons Transparency",
		configTransparency = "Config Transparency",
		size = "Fly Size",
		configSize = "Config Size",
		saveSpeed = "Save Speed",
		showFPS = "FPS in Fly GUI",
		pcFly = "Fly on PC",
		activationKey = "Activation/Toggle Key",
		pressKey = "PRESS A KEY",
		font = "Font",
		previous = "Previous",
		next = "Next",
		closeQuestion = "Close Fly v4?",
		yes = "YES",
		no = "NO",
		fly = "FLY"
	},

	ES = {
		title = "CONFIGURACIÓN",
		languagePT = "Idioma: Portugués",
		languageEN = "Idioma: Inglés",
		languageES = "Idioma: Español",
		background = "Transparencia del Fondo",
		mainButtons = "Transparencia de los Botones",
		otherButtons = "Transparencia de Otros Botones",
		configTransparency = "Transparencia de Config",
		size = "Tamaño del Fly",
		configSize = "Tamaño de Config",
		saveSpeed = "Guardar Velocidad",
		showFPS = "FPS en el Fly GUI",
		pcFly = "Fly en PC",
		activationKey = "Tecla para Activar/Desactivar",
		pressKey = "PRESIONE UNA TECLA",
		font = "Fuente",
		previous = "Anterior",
		next = "Siguiente",
		closeQuestion = "¿Cerrar Fly v4?",
		yes = "SÍ",
		no = "NO",
		fly = "VOLAR"
	}
}

local function getLanguage()
	return translations[language] or translations.PT
end

local function corner(object, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = object
end

local function applyCornerRadius()
	for _, object in ipairs(main:GetDescendants()) do
		local c = object:FindFirstChildOfClass("UICorner")
		if c then c.CornerRadius = UDim.new(0, cornerRadius) end
	end
end

main.Name = "FlyV4"
main.Parent = player:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
Frame.BackgroundTransparency = backgroundTransparency
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)
Frame.Active = true
Frame.Draggable = true

corner(Frame, 10)

local scale = Instance.new("UIScale")
scale.Scale = interfaceScale
scale.Parent = Frame

up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(76, 150, 255)
up.BackgroundTransparency = mainButtonsTransparency
up.BorderSizePixel = 0
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.GothamBold
up.Text = "↑"
up.TextColor3 = Color3.fromRGB(255, 255, 255)
up.TextSize = 19
up.TextStrokeTransparency = 1
up.AutoButtonColor = false

down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(76, 150, 255)
down.BackgroundTransparency = mainButtonsTransparency
down.BorderSizePixel = 0
down.Position = UDim2.new(0, 0, 0.491, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.GothamBold
down.Text = "↓"
down.TextColor3 = Color3.fromRGB(255, 255, 255)
down.TextSize = 19
down.TextStrokeTransparency = 1
down.AutoButtonColor = false

onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(70, 185, 110)
onof.BackgroundTransparency = mainButtonsTransparency
onof.BorderSizePixel = 0
onof.Position = UDim2.new(0.703, 0, 0.491, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.GothamBold
onof.Text = "VOAR"
onof.TextColor3 = Color3.fromRGB(255, 255, 255)
onof.TextSize = 12
onof.TextStrokeTransparency = 1
onof.AutoButtonColor = false

TextLabel.Name = "Title"
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
TextLabel.BackgroundTransparency = mainButtonsTransparency
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.469, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "Fly v4"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14
TextLabel.TextStrokeTransparency = 1

plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(80, 165, 245)
plus.BackgroundTransparency = mainButtonsTransparency
plus.BorderSizePixel = 0
plus.Position = UDim2.new(0.232, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.GothamBold
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.TextSize = 20
plus.TextStrokeTransparency = 1
plus.AutoButtonColor = false

speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
speed.BackgroundTransparency = mainButtonsTransparency
speed.BorderSizePixel = 0
speed.Position = UDim2.new(0.468, 0, 0.491, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = Enum.Font.GothamBold
speed.Text = string.format("%.1f", flySpeed)
speed.TextColor3 = Color3.fromRGB(255, 255, 255)
speed.TextScaled = true
speed.TextSize = 14
speed.TextStrokeTransparency = 1
speed.ClearTextOnFocus = false
speed.MultiLine = false
speed.TextEditable = true
speed.PlaceholderText = "0.1 - 150"

mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(80, 165, 245)
mine.BackgroundTransparency = mainButtonsTransparency
mine.BorderSizePixel = 0
mine.Position = UDim2.new(0.232, 0, 0.491, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.GothamBold
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(255, 255, 255)
mine.TextSize = 20
mine.TextStrokeTransparency = 1
mine.AutoButtonColor = false

closebutton.Name = "Close"
closebutton.Parent = main
closebutton.BackgroundColor3 = Color3.fromRGB(205, 65, 65)
closebutton.BackgroundTransparency = otherButtonsTransparency
closebutton.BorderSizePixel = 0
closebutton.Font = Enum.Font.GothamBold
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "×"
closebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
closebutton.TextSize = 23
closebutton.TextStrokeTransparency = 1
closebutton.AutoButtonColor = false
closebutton.ZIndex = 10

mini.Name = "minimize"
mini.Parent = main
mini.BackgroundColor3 = Color3.fromRGB(75, 75, 80)
mini.BackgroundTransparency = otherButtonsTransparency
mini.BorderSizePixel = 0
mini.Font = Enum.Font.GothamBold
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "−"
mini.TextColor3 = Color3.fromRGB(255, 255, 255)
mini.TextSize = 22
mini.TextStrokeTransparency = 1
mini.AutoButtonColor = false
mini.ZIndex = 10

mini2.Name = "minimize2"
mini2.Parent = main
mini2.BackgroundColor3 = Color3.fromRGB(75, 75, 80)
mini2.BackgroundTransparency = otherButtonsTransparency
mini2.BorderSizePixel = 0
mini2.Font = Enum.Font.GothamBold
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextColor3 = Color3.fromRGB(255, 255, 255)
mini2.TextSize = 22
mini2.TextStrokeTransparency = 1
mini2.Visible = false
mini2.AutoButtonColor = false
mini2.ZIndex = 10

config.Name = "Config"
config.Parent = main
config.BackgroundColor3 = Color3.fromRGB(75, 75, 80)
config.BackgroundTransparency = otherButtonsTransparency
config.BorderSizePixel = 0
config.Font = Enum.Font.GothamBold
config.Size = UDim2.new(0, 45, 0, 28)
config.Text = "⚙"
config.TextColor3 = Color3.fromRGB(255, 255, 255)
config.TextSize = 16
config.TextStrokeTransparency = 1
config.AutoButtonColor = false
config.ZIndex = 10

fpsLabel.Name = "FPS"
fpsLabel.Parent = main
fpsLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
fpsLabel.BackgroundTransparency = metricsTransparency
fpsLabel.BorderSizePixel = 0
fpsLabel.Size = UDim2.new(0, 190, 0, 20)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextSize = 12
fpsLabel.TextStrokeTransparency = 1
fpsLabel.Visible = showFPS or showMS
fpsLabel.ZIndex = 5
fpsLabel.TextScaled = true
fpsLabel.TextWrapped = false

deviceLabel.Name = "Device"
deviceLabel.Parent = main
deviceLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 43)
deviceLabel.BackgroundTransparency = metricsTransparency
deviceLabel.BorderSizePixel = 0
deviceLabel.Size = UDim2.new(0, 190, 0, 20)
deviceLabel.Font = Enum.Font.GothamBold
deviceLabel.Text = "DEVICE: " .. getDeviceName()
deviceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
deviceLabel.TextSize = 12
deviceLabel.TextScaled = true
deviceLabel.TextStrokeTransparency = 1
deviceLabel.ZIndex = 5

corner(up, 7)
corner(down, 7)
corner(onof, 7)
corner(TextLabel, 7)
corner(plus, 7)
corner(speed, 7)
corner(mine, 7)
corner(closebutton, 7)
corner(mini, 7)
corner(mini2, 7)
corner(config, 7)
corner(fpsLabel, 7)
corner(deviceLabel, 7)

local function clickAnimation(button)
	local original = button.Size

	button.MouseButton1Down:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(
				0.07,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size = UDim2.new(
					original.X.Scale,
					original.X.Offset - 3,
					original.Y.Scale,
					original.Y.Offset - 3
				)
			}
		):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(
				0.1,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),
			{
				Size = original
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(
			button,
			TweenInfo.new(
				0.1,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),
			{
				Size = original
			}
		):Play()
	end)
end

for _, button in ipairs({
	up,
	down,
	onof,
	plus,
	mine,
	closebutton,
	mini,
	mini2,
	config
}) do
	clickAnimation(button)
end

local function applyFont()
	local font = fontMap[selectedFont] or Enum.Font.GothamBold

	for _, object in ipairs(main:GetDescendants()) do
		if object:IsA("TextButton")
			or object:IsA("TextLabel")
			or object:IsA("TextBox") then

			object.Font = font
			object.TextStrokeTransparency = 1
		end
	end
end

local function applyButtonSize()
	local w = math.max(24, math.round(45 * buttonSizeScale))
	local h = math.max(18, math.round(28 * buttonSizeScale))
	for _, button in ipairs({closebutton, mini, mini2, config}) do button.Size = UDim2.fromOffset(w, h) end
	closebutton.TextSize = math.max(12, math.round(23 * buttonSizeScale))
	mini.TextSize = math.max(12, math.round(22 * buttonSizeScale))
	mini2.TextSize = math.max(12, math.round(22 * buttonSizeScale))
	config.TextSize = math.max(12, math.round(16 * buttonSizeScale))
end

local function updateMetricsLayout()
	if not fpsLabel or not deviceLabel then return end
	fpsLabel.Visible = showFPS or showMS
	deviceLabel.Visible = showDevice
	local pos = Frame.AbsolutePosition
	local size = Frame.AbsoluteSize
	local metricScale = math.clamp(interfaceScale * metricsScaleValue, 0.4, 5)
	local h = math.clamp(20 * metricScale, 14, 90)
	local gap = math.max(2, math.round(3 * interfaceScale))
	fpsLabel.Size = UDim2.fromOffset(math.max(size.X, 1), h)
	fpsLabel.Position = UDim2.fromOffset(pos.X, pos.Y + size.Y + gap)
	fpsLabel.TextSize = math.clamp(12 * metricScale, 8, 30)
	fpsLabel.BackgroundTransparency = metricsTransparency
	deviceLabel.Size = UDim2.fromOffset(math.max(size.X, 1), h)
	deviceLabel.Position = UDim2.fromOffset(pos.X, pos.Y + size.Y + gap + ((showFPS or showMS) and h + gap or 0))
	deviceLabel.TextSize = math.clamp(12 * metricScale, 8, 30)
	deviceLabel.BackgroundTransparency = metricsTransparency
end

local function updateTopButtons()
	local position = Frame.Position
	local w = math.max(24, math.round(45 * buttonSizeScale))
	local h = math.max(18, math.round(28 * buttonSizeScale))
	local gap = math.max(2, math.round(2 * buttonSizeScale))
	closebutton.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset - h - gap)
	mini.Position = UDim2.new(position.X.Scale, position.X.Offset + w + gap, position.Y.Scale, position.Y.Offset - h - gap)
	mini2.Position = mini.Position
	config.Position = UDim2.new(position.X.Scale, position.X.Offset + (w + gap) * 2, position.Y.Scale, position.Y.Offset - h - gap)
	applyButtonSize()
	updateMetricsLayout()
	if ConfigFrame then
		ConfigFrame.Position = UDim2.new(position.X.Scale, position.X.Offset + Frame.AbsoluteSize.X + 15, position.Y.Scale, position.Y.Offset)
	end
end

local function updateSpeed()
	speed.Text = string.format("%.1f", flySpeed)
end

local function setFlySpeed(value)
	local number = tonumber(value)

	if not number then
		updateSpeed()
		return
	end

	flySpeed = math.clamp(
		math.round(number * 10) / 10,
		0.1,
		150
	)

	updateSpeed()

	if saveSpeed then
		saveConfig()
	end
end

local function changeSpeed(amount)
	setFlySpeed(flySpeed + amount)
end

speed.FocusLost:Connect(function()
	local value = tonumber(speed.Text)

	if not value then
		updateSpeed()
		return
	end

	setFlySpeed(value)
end)

local function setBackgroundTransparency(value)
	backgroundTransparency = math.clamp(
		value,
		0,
		0.8
	)

	Frame.BackgroundTransparency = backgroundTransparency
	saveConfig()
end

local function setMainButtonsTransparency(value)
	mainButtonsTransparency = math.clamp(
		value,
		0,
		0.8
	)

	up.BackgroundTransparency = mainButtonsTransparency
	down.BackgroundTransparency = mainButtonsTransparency
	onof.BackgroundTransparency = mainButtonsTransparency
	plus.BackgroundTransparency = mainButtonsTransparency
	mine.BackgroundTransparency = mainButtonsTransparency
	speed.BackgroundTransparency = mainButtonsTransparency
	TextLabel.BackgroundTransparency = mainButtonsTransparency
	fpsLabel.BackgroundTransparency = mainButtonsTransparency

	saveConfig()
end

local function setOtherButtonsTransparency(value)
	otherButtonsTransparency = math.clamp(
		value,
		0,
		0.8
	)

	closebutton.BackgroundTransparency = otherButtonsTransparency
	mini.BackgroundTransparency = otherButtonsTransparency
	mini2.BackgroundTransparency = otherButtonsTransparency
	config.BackgroundTransparency = otherButtonsTransparency

	saveConfig()
end

local function setConfigTransparency(value)
	configTransparency = math.clamp(
		value,
		0,
		0.8
	)

	if ConfigFrame then
		ConfigFrame.BackgroundTransparency = configTransparency
	end

	saveConfig()
end

local currentFontIndex =
	table.find(fonts, selectedFont) or 1

local function setFontByIndex(index)
	currentFontIndex =
		((index - 1) % #fonts) + 1

	selectedFont =
		fonts[currentFontIndex]

	applyFont()

	local fontValue =
		ConfigFrame
		and ConfigFrame:FindFirstChild(
			"FontValue",
			true
		)

	if fontValue then
		fontValue.Text =
			selectedFont
	end

	saveConfig()
end

local function getConfigObject(name)
	if not ConfigFrame then
		return nil
	end

	return ConfigFrame:FindFirstChild(
		name,
		true
	)
end

local function updateConfigToggles()
	local saveToggle =
		getConfigObject("SaveToggle")

	local fpsToggle = getConfigObject("FPSToggle")
	local msToggle = getConfigObject("MSToggle")
	local deviceToggle = getConfigObject("DeviceToggle")
	local flyAnimationToggle = getConfigObject("FlyAnimationToggle")

	local pcFlyToggle =
		getConfigObject("PCFlyToggle")

	if saveToggle then
		saveToggle.Text =
			saveSpeed
			and "ON"
			or "OFF"

		saveToggle.BackgroundColor3 =
			saveSpeed
			and Color3.fromRGB(
				70,
				185,
				110
			)
			or Color3.fromRGB(
				95,
				95,
				100
			)
	end

	if fpsToggle then
		fpsToggle.Text =
			showFPS
			and "ON"
			or "OFF"

		fpsToggle.BackgroundColor3 =
			showFPS
			and Color3.fromRGB(
				70,
				185,
				110
			)
			or Color3.fromRGB(
				95,
				95,
				100
			)
	end

	if pcFlyToggle then
		pcFlyToggle.Text =
			pcFly
			and "ON"
			or "OFF"

		pcFlyToggle.BackgroundColor3 =
			pcFly
			and Color3.fromRGB(
				70,
				185,
				110
			)
			or Color3.fromRGB(
				95,
				95,
				100
			)
	end
end

local function updateLanguage()
	local text = getLanguage()

	onof.Text = text.fly
	TextLabel.Text = "Fly v4"

	if ConfigFrame then
		local title =
			getConfigObject("Title")

		local languageButton =
			getConfigObject("LanguageButton")

		local backgroundLabel =
			getConfigObject("BackgroundLabel")

		local mainButtonsLabel =
			getConfigObject("MainButtonsLabel")

		local otherButtonsLabel =
			getConfigObject("OtherButtonsLabel")

		local configTransparencyLabel =
			getConfigObject("ConfigTransparencyLabel")

		local sizeLabel =
			getConfigObject("SizeLabel")

		local configSizeLabel =
			getConfigObject("ConfigSizeLabel")

		local saveLabel =
			getConfigObject("SaveLabel")

		local fpsOptionLabel = getConfigObject("FPSOptionLabel")
		local msOptionLabel = getConfigObject("MSOptionLabel")
		local deviceOptionLabel = getConfigObject("DeviceOptionLabel")
		local metricsTransparencyLabel = getConfigObject("MetricsTransparencyLabel")
		local metricsSizeLabel = getConfigObject("MetricsSizeLabel")
		local buttonSizeLabel = getConfigObject("ButtonSizeLabel")
		local cornerLabel = getConfigObject("CornerLabel")
		local flyAnimationLabel = getConfigObject("FlyAnimationLabel")
		local flyAnimationToggle = getConfigObject("FlyAnimationToggle")

		local pcFlyLabel =
			getConfigObject("PCFlyLabel")

		local activationKeyLabel =
			getConfigObject("ActivationKeyLabel")

		local activationKeyButton =
			getConfigObject("ActivationKeyButton")

		local pcKey =
			getConfigObject("PCKey")

		local fontLabel =
			getConfigObject("FontLabel")

		local previousFont =
			getConfigObject("PreviousFont")

		local nextFont =
			getConfigObject("NextFont")

		if title then
			title.Text =
				text.title
		end

		if languageButton then
			if language == "PT" then
				languageButton.Text =
					text.languagePT
			elseif language == "EN" then
				languageButton.Text =
					text.languageEN
			else
				languageButton.Text =
					text.languageES
			end
		end

		if backgroundLabel then
			backgroundLabel.Text =
				text.background ..
				": " ..
				math.floor(
					backgroundTransparency * 100
				) ..
				"%"
		end

		if mainButtonsLabel then
			mainButtonsLabel.Text =
				text.mainButtons ..
				": " ..
				math.floor(
					mainButtonsTransparency * 100
				) ..
				"%"
		end

		if otherButtonsLabel then
			otherButtonsLabel.Text =
				text.otherButtons ..
				": " ..
				math.floor(
					otherButtonsTransparency * 100
				) ..
				"%"
		end

		if configTransparencyLabel then
			configTransparencyLabel.Text =
				text.configTransparency ..
				": " ..
				math.floor(
					configTransparency * 100
				) ..
				"%"
		end

		if sizeLabel then
			sizeLabel.Text =
				text.size ..
				": " ..
				math.floor(
					interfaceScale * 100
				) ..
				"%"
		end

		if configSizeLabel then
			configSizeLabel.Text =
				text.configSize ..
				": " ..
				math.floor(
					configScaleValue * 100
				) ..
				"%"
		end

		if saveLabel then
			saveLabel.Text =
				text.saveSpeed
		end

		if fpsOptionLabel then fpsOptionLabel.Text = text.showFPS end
		if msOptionLabel then msOptionLabel.Text = text.showMS end
		if deviceOptionLabel then deviceOptionLabel.Text = text.showDevice end
		if metricsTransparencyLabel then metricsTransparencyLabel.Text = text.metricsTransparency .. ": " .. math.floor(metricsTransparency * 100) .. "%" end
		if metricsSizeLabel then metricsSizeLabel.Text = text.metricsSize .. ": " .. math.floor(metricsScaleValue * 100) .. "%" end
		if buttonSizeLabel then buttonSizeLabel.Text = text.buttonSize .. ": " .. math.floor(buttonSizeScale * 100) .. "%" end
		if cornerLabel then cornerLabel.Text = text.corner .. ": " .. cornerRadius end
		if flyAnimationLabel then flyAnimationLabel.Text = text.flyAnimation end
		if flyAnimationToggle then flyAnimationToggle.Text = flyAnimation and "ON" or "OFF" end

		if pcFlyLabel then
			pcFlyLabel.Text =
				text.pcFly
		end

		if activationKeyLabel then
			activationKeyLabel.Text =
				text.activationKey
		end

		if activationKeyButton then
			if waitingForKey then
				activationKeyButton.Text =
					text.pressKey
			else
				activationKeyButton.Text =
					activationKey.Name
			end
		end

		if pcKey then
			pcKey.Text =
				activationKey.Name ..
				" = Fly"
		end

		if fontLabel then
			fontLabel.Text =
				text.font
		end

		if previousFont then
			previousFont.Text =
				"‹ " ..
				text.previous
		end

		if nextFont then
			nextFont.Text =
				text.next ..
				" ›"
		end
	end

	applyFont()
end

local function getDeviceName()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "MOBILE" end
	return "PC"
end

local function setFPSVisible(value)
	showFPS = value
	updateMetricsLayout()
	updateConfigToggles()
	saveConfig()
end

local function setMSVisible(value)
	showMS = value
	updateMetricsLayout()
	updateConfigToggles()
	saveConfig()
end

local function setDeviceVisible(value)
	showDevice = value
	deviceLabel.Text = "DEVICE: " .. getDeviceName()
	updateMetricsLayout()
	updateConfigToggles()
	saveConfig()
end

local function setMetricsTransparency(value)
	metricsTransparency = math.clamp(value, 0, 0.8)
	updateMetricsLayout()
	updateLanguage()
	saveConfig()
end

local function setMetricsScale(value)
	metricsScaleValue = math.clamp(value, 0.6, 1.8)
	updateMetricsLayout()
	updateLanguage()
	saveConfig()
end

local function bindActivationKey()
	ContextActionService:UnbindAction(activationActionName)
	if not pcFly or closing or waitingForKey then return end
	ContextActionService:BindActionAtPriority(activationActionName, function(_, state)
		if state == Enum.UserInputState.Begin and not waitingForKey and not closing then onof:Activate() end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, activationKey)
end

local function createConfig()
	if not ConfigFrame then
		ConfigFrame =
			Instance.new("Frame")

		ConfigFrame.Name =
			"ConfigFrame"

		ConfigFrame.Parent =
			main

		ConfigFrame.BackgroundColor3 =
			Color3.fromRGB(
				40,
				40,
				43
			)

		ConfigFrame.BackgroundTransparency =
			configTransparency

		ConfigFrame.BorderSizePixel =
			0

		ConfigFrame.Size =
			UDim2.new(
				0,
				250,
				0,
				330
			)

		ConfigFrame.ZIndex = 50
		ConfigFrame.Visible = false
		ConfigFrame.ClipsDescendants = true

		corner(
			ConfigFrame,
			12
		)

		ConfigScale =
			Instance.new("UIScale")

		ConfigScale.Scale = math.clamp(configScaleValue * interfaceScale, 0.4, 3.2)

		ConfigScale.Parent =
			ConfigFrame

		local title =
			Instance.new("TextLabel")

		title.Name = "Title"
		title.Parent = ConfigFrame
		title.BackgroundTransparency = 1

		title.Position =
			UDim2.new(
				0,
				12,
				0,
				8
			)

		title.Size =
			UDim2.new(
				1,
				-24,
				0,
				27
			)

		title.Font =
			fontMap[selectedFont]
			or Enum.Font.GothamBold

		title.TextColor3 =
			Color3.fromRGB(
				255,
				255,
				255
			)

		title.TextSize = 16
		title.TextXAlignment =
			Enum.TextXAlignment.Left

		title.TextStrokeTransparency = 1
		title.ZIndex = 51

		local scroll =
			Instance.new("ScrollingFrame")

		scroll.Name =
			"SettingsScroll"

		scroll.Parent =
			ConfigFrame

		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0

		scroll.Position =
			UDim2.new(
				0,
				8,
				0,
				42
			)

		scroll.Size =
			UDim2.new(
				1,
				-16,
				1,
				-50
			)

		scroll.CanvasSize =
			UDim2.new(
				0,
				0,
				0,
				1060
			)

		scroll.ScrollBarThickness = 4

		scroll.ScrollingDirection =
			Enum.ScrollingDirection.Y

		scroll.ZIndex = 51

		local function makeLabel(
			name,
			position,
			height
		)
			local object =
				Instance.new("TextLabel")

			object.Name = name
			object.Parent = scroll
			object.BackgroundTransparency = 1
			object.Position = position

			object.Size =
				UDim2.new(
					1,
					-8,
					0,
					height or 21
				)

			object.Font =
				fontMap[selectedFont]
				or Enum.Font.GothamBold

			object.TextColor3 =
				Color3.fromRGB(
					220,
					220,
					225
				)

			object.TextSize = 12

			object.TextXAlignment =
				Enum.TextXAlignment.Left

			object.TextStrokeTransparency = 1
			object.ZIndex = 52

			return object
		end

		local function makeButton(
			name,
			position,
			size
		)
			local object =
				Instance.new("TextButton")

			object.Name = name
			object.Parent = scroll

			object.BackgroundColor3 =
				Color3.fromRGB(
					70,
					70,
					75
				)

			object.BorderSizePixel = 0
			object.Position = position

			object.Size =
				size
				or UDim2.new(
					1,
					-8,
					0,
					32
				)

			object.Font =
				fontMap[selectedFont]
				or Enum.Font.GothamBold

			object.TextColor3 =
				Color3.fromRGB(
					255,
					255,
					255
				)

			object.TextSize = 12
			object.TextStrokeTransparency = 1
			object.ZIndex = 52

			corner(
				object,
				7
			)

			clickAnimation(object)

			return object
		end

		local languageButton =
			makeButton(
				"LanguageButton",
				UDim2.new(
					0,
					4,
					0,
					0
				)
			)

		local backgroundLabel =
			makeLabel(
				"BackgroundLabel",
				UDim2.new(
					0,
					4,
					0,
					38
				)
			)

		local backgroundDown =
			makeButton(
				"BackgroundDown",
				UDim2.new(
					0,
					4,
					0,
					62
				),
				UDim2.new(
					0.5,
					-6,
					0,
					30
				)
			)

		backgroundDown.Text = "−"

		local backgroundUp =
			makeButton(
				"BackgroundUp",
				UDim2.new(
					0.5,
					2,
					0,
					62
				),
				UDim2.new(
					0.5,
					-10,
					0,
					30
				)
			)

		backgroundUp.Text = "+"

		local mainButtonsLabel =
			makeLabel(
				"MainButtonsLabel",
				UDim2.new(
					0,
					4,
					0,
					98
				)
			)

		local mainButtonsDown =
			makeButton(
				"MainButtonsDown",
				UDim2.new(
					0,
					4,
					0,
					122
				),
				UDim2.new(
					0.5,
					-6,
					0,
					30
				)
			)

		mainButtonsDown.Text = "−"

		local mainButtonsUp =
			makeButton(
				"MainButtonsUp",
				UDim2.new(
					0.5,
					2,
					0,
					122
				),
				UDim2.new(
					0.5,
					-10,
					0,
					30
				)
			)

		mainButtonsUp.Text = "+"

		local otherButtonsLabel =
			makeLabel(
				"OtherButtonsLabel",
				UDim2.new(
					0,
					4,
					0,
					158
				)
			)

		local otherButtonsDown =
			makeButton(
				"OtherButtonsDown",
				UDim2.new(
					0,
					4,
					0,
					182
				),
				UDim2.new(
					0.5,
					-6,
					0,
					30
				)
			)

		otherButtonsDown.Text = "−"

		local otherButtonsUp =
			makeButton(
				"OtherButtonsUp",
				UDim2.new(
					0.5,
					2,
					0,
					182
				),
				UDim2.new(
					0.5,
					-10,
					0,
					30
				)
			)

		otherButtonsUp.Text = "+"

		local configTransparencyLabel =
			makeLabel(
				"ConfigTransparencyLabel",
				UDim2.new(
					0,
					4,
					0,
					218
				)
			)

		local configTransparencyDown =
			makeButton(
				"ConfigTransparencyDown",
				UDim2.new(
					0,
					4,
					0,
					242
				),
				UDim2.new(
					0.5,
					-6,
					0,
					30
				)
			)

		configTransparencyDown.Text = "−"

		local configTransparencyUp =
			makeButton(
				"ConfigTransparencyUp",
				UDim2.new(
					0.5,
					2,
					0,
					242
				),
				UDim2.new(
					0.5,
					-10,
					0,
					30
				)
			)

		configTransparencyUp.Text = "+"

		local sizeLabel =
			makeLabel(
				"SizeLabel",
				UDim2.new(
					0,
					4,
					0,
					278
				)
			)

		local sizeDown =
			makeButton(
				"SizeDown",
				UDim2.new(
					0,
					4,
					0,
					302
				),
				UDim2.new(
					0.5,
					-6,
					0,
					30
				)
			)

		sizeDown.Text = "−"

		local sizeUp =
			makeButton(
				"SizeUp",
				UDim2.new(
					0.5,
					2,
					0,
					302
				),
				UDim2.new(
					0.5,
					-10,
					0,
					30
				)
			)

		sizeUp.Text = "+"

		local configSizeLabel =
			makeLabel(
				"ConfigSizeLabel",
				UDim2.new(
					0,
					4,
					0,
					338
				)
			)

		local configSizeDown =
			makeButton(
				"ConfigSizeDown",
				UDim2.new(
					0,
					4,
					0,
					362
				),
				UDim2.new(
					0.5,
					-6,
					0,
					30
				)
			)

		configSizeDown.Text = "−"

		local configSizeUp =
			makeButton(
				"ConfigSizeUp",
				UDim2.new(
					0.5,
					2,
					0,
					362
				),
				UDim2.new(
					0.5,
					-10,
					0,
					30
				)
			)

		configSizeUp.Text = "+"

		local buttonSizeLabel = makeLabel("ButtonSizeLabel", UDim2.new(0, 4, 0, 398))
		local buttonSizeDown = makeButton("ButtonSizeDown", UDim2.new(0, 4, 0, 422), UDim2.new(0.5, -6, 0, 30)); buttonSizeDown.Text = "−"
		local buttonSizeUp = makeButton("ButtonSizeUp", UDim2.new(0.5, 2, 0, 422), UDim2.new(0.5, -10, 0, 30)); buttonSizeUp.Text = "+"
		local cornerLabel = makeLabel("CornerLabel", UDim2.new(0, 4, 0, 458))
		local cornerDown = makeButton("CornerDown", UDim2.new(0, 4, 0, 482), UDim2.new(0.5, -6, 0, 30)); cornerDown.Text = "−"
		local cornerUp = makeButton("CornerUp", UDim2.new(0.5, 2, 0, 482), UDim2.new(0.5, -10, 0, 30)); cornerUp.Text = "+"
		local flyAnimationLabel = makeLabel("FlyAnimationLabel", UDim2.new(0, 4, 0, 518))
		local flyAnimationToggle = makeButton("FlyAnimationToggle", UDim2.new(1, -58, 0, 514), UDim2.new(0, 50, 0, 28))

		local saveLabel =
			makeLabel(
				"SaveLabel",
				UDim2.new(
					0,
					4,
					0,
					554
				)
			)

		local saveToggle =
			makeButton(
				"SaveToggle",
				UDim2.new(
					1,
					-58,
					0,
					550
				),
				UDim2.new(
					0,
					50,
					0,
					28
				)
			)

		local fpsOptionLabel =
			makeLabel(
				"FPSOptionLabel",
				UDim2.new(
					0,
					4,
					0,
					590
				)
			)

		local fpsToggle =
			makeButton(
				"FPSToggle",
				UDim2.new(
					1,
					-58,
					0,
					586
				),
				UDim2.new(
					0,
					50,
					0,
					28
				)
			)

		local pcFlyLabel =
			makeLabel(
				"PCFlyLabel",
				UDim2.new(
					0,
					4,
					0,
					626
				)
			)

		local pcFlyToggle =
			makeButton(
				"PCFlyToggle",
				UDim2.new(
					1,
					-58,
					0,
					622
				),
				UDim2.new(
					0,
					50,
					0,
					28
				)
			)

		local msOptionLabel = makeLabel("MSOptionLabel", UDim2.new(0, 4, 0, 662))
		local msToggle = makeButton("MSToggle", UDim2.new(1, -58, 0, 658), UDim2.new(0, 50, 0, 28))
		local deviceOptionLabel = makeLabel("DeviceOptionLabel", UDim2.new(0, 4, 0, 698))
		local deviceToggle = makeButton("DeviceToggle", UDim2.new(1, -58, 0, 694), UDim2.new(0, 50, 0, 28))
		local metricsTransparencyLabel = makeLabel("MetricsTransparencyLabel", UDim2.new(0, 4, 0, 734))
		local metricsTransparencyDown = makeButton("MetricsTransparencyDown", UDim2.new(0, 4, 0, 758), UDim2.new(0.5, -6, 0, 30)); metricsTransparencyDown.Text = "−"
		local metricsTransparencyUp = makeButton("MetricsTransparencyUp", UDim2.new(0.5, 2, 0, 758), UDim2.new(0.5, -10, 0, 30)); metricsTransparencyUp.Text = "+"
		local metricsSizeLabel = makeLabel("MetricsSizeLabel", UDim2.new(0, 4, 0, 794))
		local metricsSizeDown = makeButton("MetricsSizeDown", UDim2.new(0, 4, 0, 818), UDim2.new(0.5, -6, 0, 30)); metricsSizeDown.Text = "−"
		local metricsSizeUp = makeButton("MetricsSizeUp", UDim2.new(0.5, 2, 0, 818), UDim2.new(0.5, -10, 0, 30)); metricsSizeUp.Text = "+"

		local pcKey =
			makeLabel(
				"PCKey",
				UDim2.new(
					0,
					4,
					0,
					858
				),
				18
			)

		pcKey.Text =
			activationKey.Name ..
			" = Fly"

		local activationKeyLabel =
			makeLabel(
				"ActivationKeyLabel",
				UDim2.new(
					0,
					4,
					0,
					882
				)
			)

		local activationKeyButton =
			makeButton(
				"ActivationKeyButton",
				UDim2.new(
					0,
					4,
					0,
					906
				),
				UDim2.new(
					1,
					-8,
					0,
					30
				)
			)

		activationKeyButton.Text =
			activationKey.Name

		local fontLabel =
			makeLabel(
				"FontLabel",
				UDim2.new(
					0,
					4,
					0,
					946
				)
			)

		local fontValue =
			makeLabel(
				"FontValue",
				UDim2.new(
					0,
					4,
					0,
					970
				),
				28
			)

		fontValue.BackgroundTransparency = 0

		fontValue.BackgroundColor3 =
			Color3.fromRGB(
				65,
				65,
				70
			)

		fontValue.TextXAlignment =
			Enum.TextXAlignment.Center

		corner(fontValue, cornerRadius)

		local previousFont =
			makeButton(
				"PreviousFont",
				UDim2.new(
					0,
					4,
					0,
					1004
				),
				UDim2.new(
					0.5,
					-6,
					0,
					29
				)
			)

		local nextFont =
			makeButton(
				"NextFont",
				UDim2.new(
					0.5,
					2,
					0,
					1004
				),
				UDim2.new(
					0.5,
					-10,
					0,
					29
				)
			)

		languageButton.MouseButton1Click:Connect(function()
			if language == "PT" then
				language = "EN"
			elseif language == "EN" then
				language = "ES"
			else
				language = "PT"
			end

			updateLanguage()
			saveConfig()
		end)

		backgroundDown.MouseButton1Click:Connect(function()
			setBackgroundTransparency(
				backgroundTransparency + 0.05
			)

			updateLanguage()
		end)

		backgroundUp.MouseButton1Click:Connect(function()
			setBackgroundTransparency(
				backgroundTransparency - 0.05
			)

			updateLanguage()
		end)

		mainButtonsDown.MouseButton1Click:Connect(function()
			setMainButtonsTransparency(
				mainButtonsTransparency + 0.05
			)

			updateLanguage()
		end)

		mainButtonsUp.MouseButton1Click:Connect(function()
			setMainButtonsTransparency(
				mainButtonsTransparency - 0.05
			)

			updateLanguage()
		end)

		otherButtonsDown.MouseButton1Click:Connect(function()
			setOtherButtonsTransparency(
				otherButtonsTransparency + 0.05
			)

			updateLanguage()
		end)

		otherButtonsUp.MouseButton1Click:Connect(function()
			setOtherButtonsTransparency(
				otherButtonsTransparency - 0.05
			)

			updateLanguage()
		end)

		configTransparencyDown.MouseButton1Click:Connect(function()
			setConfigTransparency(
				configTransparency + 0.05
			)

			updateLanguage()
		end)

		configTransparencyUp.MouseButton1Click:Connect(function()
			setConfigTransparency(
				configTransparency - 0.05
			)

			updateLanguage()
		end)

		sizeDown.MouseButton1Click:Connect(function()
			interfaceScale =
				math.clamp(
					interfaceScale - 0.1,
					0.4,
					2.9
				)

			scale.Scale = interfaceScale
			if ConfigScale then ConfigScale.Scale = math.clamp(configScaleValue * interfaceScale, 0.4, 3.2) end

			updateLanguage()
			updateTopButtons()
			saveConfig()
		end)

		sizeUp.MouseButton1Click:Connect(function()
			interfaceScale =
				math.clamp(
					interfaceScale + 0.1,
					0.4,
					2.9
				)

			scale.Scale = interfaceScale
			if ConfigScale then ConfigScale.Scale = math.clamp(configScaleValue * interfaceScale, 0.4, 3.2) end

			updateLanguage()
			updateTopButtons()
			saveConfig()
		end)

		configSizeDown.MouseButton1Click:Connect(function()
			configScaleValue =
				math.clamp(
					configScaleValue - 0.05,
					0.65,
					1.1
				)

			ConfigScale.Scale = math.clamp(configScaleValue * interfaceScale, 0.4, 3.2)

			updateLanguage()
			saveConfig()
		end)

		configSizeUp.MouseButton1Click:Connect(function()
			configScaleValue =
				math.clamp(
					configScaleValue + 0.05,
					0.65,
					1.1
				)

			ConfigScale.Scale = math.clamp(configScaleValue * interfaceScale, 0.4, 3.2)

			updateLanguage()
			saveConfig()
		end)

		buttonSizeDown.MouseButton1Click:Connect(function() buttonSizeScale = math.clamp(buttonSizeScale - 0.1, 0.6, 2); applyButtonSize(); updateTopButtons(); updateLanguage(); saveConfig() end)
		buttonSizeUp.MouseButton1Click:Connect(function() buttonSizeScale = math.clamp(buttonSizeScale + 0.1, 0.6, 2); applyButtonSize(); updateTopButtons(); updateLanguage(); saveConfig() end)
		cornerDown.MouseButton1Click:Connect(function() cornerRadius = math.clamp(cornerRadius - 1, 0, 25); applyCornerRadius(); updateLanguage(); saveConfig() end)
		cornerUp.MouseButton1Click:Connect(function() cornerRadius = math.clamp(cornerRadius + 1, 0, 25); applyCornerRadius(); updateLanguage(); saveConfig() end)
		flyAnimationToggle.MouseButton1Click:Connect(function() flyAnimation = not flyAnimation; updateConfigToggles(); updateLanguage(); saveConfig(); if nowe then stopFly(); startFly() end end)
		msToggle.MouseButton1Click:Connect(function() setMSVisible(not showMS) end)
		deviceToggle.MouseButton1Click:Connect(function() setDeviceVisible(not showDevice) end)
		metricsTransparencyDown.MouseButton1Click:Connect(function() setMetricsTransparency(metricsTransparency + 0.05) end)
		metricsTransparencyUp.MouseButton1Click:Connect(function() setMetricsTransparency(metricsTransparency - 0.05) end)
		metricsSizeDown.MouseButton1Click:Connect(function() setMetricsScale(metricsScaleValue - 0.1) end)
		metricsSizeUp.MouseButton1Click:Connect(function() setMetricsScale(metricsScaleValue + 0.1) end)

		saveToggle.MouseButton1Click:Connect(function()
			saveSpeed =
				not saveSpeed

			updateConfigToggles()
			saveConfig()
		end)

		fpsToggle.MouseButton1Click:Connect(function()
			setFPSVisible(
				not showFPS
			)

			updateConfigToggles()
		end)

		pcFlyToggle.MouseButton1Click:Connect(function()
			pcFly = not pcFly
			if pcFly then bindActivationKey() else ContextActionService:UnbindAction(activationActionName) end
			updateConfigToggles()
			saveConfig()
		end)

		activationKeyButton.MouseButton1Click:Connect(function()
			if waitingForKey then return end
			waitingForKey = true
			ContextActionService:UnbindAction(activationActionName)
			updateLanguage()
			if activationKeyConnection then activationKeyConnection:Disconnect(); activationKeyConnection = nil end
			activationKeyConnection = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode == Enum.KeyCode.Unknown then return end
				if input.KeyCode == Enum.KeyCode.Escape then
					waitingForKey = false
					if pcFly then bindActivationKey() end
					if activationKeyConnection then activationKeyConnection:Disconnect(); activationKeyConnection = nil end
					updateLanguage()
					return
				end
				activationKey = input.KeyCode
				waitingForKey = false
				if activationKeyConnection then activationKeyConnection:Disconnect(); activationKeyConnection = nil end
				if pcFly then bindActivationKey() end
				updateLanguage()
				saveConfig()
			end)
		end)

		previousFont.MouseButton1Click:Connect(function()
			setFontByIndex(
				currentFontIndex - 1
			)
		end)

		nextFont.MouseButton1Click:Connect(function()
			setFontByIndex(
				currentFontIndex + 1
			)
		end)
	end

	updateTopButtons()

	ConfigFrame.Visible = true

	ConfigScale.Scale = math.clamp(configScaleValue * interfaceScale, 0.4, 3.2)

	ConfigFrame.Size =
		UDim2.new(
			0,
			0,
			0,
			330
		)

	local tween =
		TweenService:Create(
			ConfigFrame,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),
			{
				Size =
					UDim2.new(
						0,
						250,
						0,
						330
					)
			}
		)

	tween:Play()

	updateLanguage()
	updateConfigToggles()
	applyFont()
end

config.MouseButton1Click:Connect(function()
	if not ConfigFrame then
		createConfig()
		return
	end

	if ConfigFrame.Visible then
		local tween =
			TweenService:Create(
				ConfigFrame,
				TweenInfo.new(
					0.15,
					Enum.EasingStyle.Quart,
					Enum.EasingDirection.In
				),
				{
					Size =
						UDim2.new(
							0,
							0,
							0,
							330
						)
				}
			)

		tween:Play()

		tween.Completed:Once(function()
			if ConfigFrame then
				ConfigFrame.Visible = false

				ConfigFrame.Size =
					UDim2.new(
						0,
						250,
						0,
						330
					)
			end
		end)
	else
		createConfig()
	end
end)

local function startSpeedHold(
	button,
	amount
)
	local holding = true

	task.spawn(function()
		task.wait(0.6)

		while holding
			and button:IsDescendantOf(game) do

			local oldSpeed =
				flySpeed

			setFlySpeed(
				flySpeed + amount
			)

			if flySpeed == oldSpeed then
				break
			end

			task.wait(0.08)
		end
	end)

	return function()
		holding = false
	end
end

local plusStop
local minusStop

plus.MouseButton1Down:Connect(function()
	changeSpeed(0.1)

	if plusStop then
		plusStop()
	end

	plusStop =
		startSpeedHold(
			plus,
			0.1
		)
end)

plus.MouseButton1Up:Connect(function()
	if plusStop then
		plusStop()
		plusStop = nil
	end
end)

plus.MouseLeave:Connect(function()
	if plusStop then
		plusStop()
		plusStop = nil
	end
end)

mine.MouseButton1Down:Connect(function()
	changeSpeed(-0.1)

	if minusStop then
		minusStop()
	end

	minusStop =
		startSpeedHold(
			mine,
			-0.1
		)
end)

mine.MouseButton1Up:Connect(function()
	if minusStop then
		minusStop()
		minusStop = nil
	end
end)

mine.MouseLeave:Connect(function()
	if minusStop then
		minusStop()
		minusStop = nil
	end
end)

local speeds = 1
local speaker = player
local chr = speaker.Character

local hum =
	chr
	and chr:FindFirstChildWhichIsA(
		"Humanoid"
	)

local nowe = false
local tpwalking = false

pcall(function()
	StarterGui:SetCore(
		"SendNotification",
		{
			Title = "Dont abuse!!",
			Text = "warn games can ban you it carefull",
			Icon =
				"rbxthumb://type=Asset&id=5107182114&w=150&h=150"
		}
	)
end)

local flyPoseMotors = {}
local flyAnimateScript
local flyAnimateWasEnabled = nil
local flyBaseCFrames = {}
local flyPoseStart = 0

local function getFlyMotor(character, name)
	local motor = character:FindFirstChild(name, true)
	if motor and motor:IsA("Motor6D") then
		return motor
	end
	return nil
end

local function captureFlyPose(character)
	table.clear(flyPoseMotors)
	table.clear(flyBaseCFrames)

	local names = {
		"RootJoint",
		"Root",
		"Waist",
		"Neck",
		"LeftShoulder",
		"RightShoulder",
		"Left Hip",
		"Right Hip",
		"LeftHip",
		"RightHip",
		"LeftElbow",
		"RightElbow",
		"LeftWrist",
		"RightWrist"
	}

	local seen = {}
	for _, name in ipairs(names) do
		local motor = getFlyMotor(character, name)
		if motor and not seen[motor] then
			seen[motor] = true
			flyPoseMotors[#flyPoseMotors + 1] = motor
			flyBaseCFrames[motor] = motor.Transform
		end
	end
end

local function stopCharacterAnimations(character)
	flyAnimateScript = character:FindFirstChild("Animate")
	if flyAnimateScript and (flyAnimateScript:IsA("LocalScript") or flyAnimateScript:IsA("Script")) then
		flyAnimateWasEnabled = flyAnimateScript.Enabled
		flyAnimateScript.Enabled = false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				pcall(function()
					track:Stop(0.08)
				end)
			end
		end
	end
end

local function restoreCharacterAnimations(character)
	for motor, transform in pairs(flyBaseCFrames) do
		if motor and motor.Parent then
			motor.Transform = transform
		end
	end

	table.clear(flyPoseMotors)
	table.clear(flyBaseCFrames)

	if flyAnimateScript and flyAnimateScript.Parent then
		flyAnimateScript.Enabled = flyAnimateWasEnabled ~= false
	end

	flyAnimateScript = nil
	flyAnimateWasEnabled = nil
end

local function updateFlyPose(t)
	if not flyAnimation then
		for motor, transform in pairs(flyBaseCFrames) do
			if motor and motor.Parent then
				motor.Transform = transform
			end
		end
		return
	end

	local character = speaker.Character
	if not character then
		return
	end

	local bob = math.sin(t * 3.4) * math.rad(2.5)
	local sway = math.sin(t * 2.2) * math.rad(3)

	for motor, base in pairs(flyBaseCFrames) do
		if motor and motor.Parent then
			local name = motor.Name
			local offset = CFrame.new()

			if name == "RootJoint" or name == "Root" then
				offset = CFrame.Angles(math.rad(-7) + bob, sway, 0)
			elseif name == "Waist" then
				offset = CFrame.Angles(math.rad(-10) + bob, sway, 0)
			elseif name == "Neck" then
				offset = CFrame.Angles(math.rad(4) - bob * 0.35, -sway * 0.35, 0)
			elseif name == "LeftShoulder" or name == "Left Shoulder" then
				offset = CFrame.Angles(math.rad(-34), math.rad(-12), math.rad(-8))
			elseif name == "RightShoulder" or name == "Right Shoulder" then
				offset = CFrame.Angles(math.rad(-34), math.rad(12), math.rad(8))
			elseif name == "LeftElbow" then
				offset = CFrame.Angles(math.rad(-18), 0, math.rad(-3))
			elseif name == "RightElbow" then
				offset = CFrame.Angles(math.rad(-18), 0, math.rad(3))
			elseif name == "LeftHip" or name == "Left Hip" then
				offset = CFrame.Angles(math.rad(9), 0, math.rad(-4))
			elseif name == "RightHip" or name == "Right Hip" then
				offset = CFrame.Angles(math.rad(9), 0, math.rad(4))
			end

			motor.Transform = base * offset
		end
	end
end

local function stopFly()
	nowe = false
	tpwalking = false

	if flyRenderConnection then
		flyRenderConnection:Disconnect()
		flyRenderConnection = nil
	end

	if flyInputBeganConnection then
		flyInputBeganConnection:Disconnect()
		flyInputBeganConnection = nil
	end

	if flyInputEndedConnection then
		flyInputEndedConnection:Disconnect()
		flyInputEndedConnection = nil
	end

	if flyBodyVelocity then
		flyBodyVelocity:Destroy()
		flyBodyVelocity = nil
	end

	if flyBodyGyro then
		flyBodyGyro:Destroy()
		flyBodyGyro = nil
	end

	for key in pairs(flyKeys) do
		flyKeys[key] = false
	end

	flyUpInput = 0
	flyDownInput = 0

	local character = speaker.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if character then
		restoreCharacterAnimations(character)
	end

	if root then
		root.AssemblyAngularVelocity = Vector3.zero
		root.AssemblyLinearVelocity = Vector3.zero
	end

	if humanoid then
		humanoid.PlatformStand = false
		humanoid.AutoRotate = true
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function startFly()
	stopFly()

	local character = speaker.Character or speaker.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root then
		return
	end

	nowe = true
	tpwalking = true
	flyPoseStart = os.clock()

	stopCharacterAnimations(character)
	captureFlyPose(character)

	humanoid.PlatformStand = true
	humanoid.AutoRotate = false
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.Name = "FlyV4Velocity"
	flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	flyBodyVelocity.P = 25000
	flyBodyVelocity.Velocity = Vector3.zero
	flyBodyVelocity.Parent = root

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.Name = "FlyV4Gyro"
	flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	flyBodyGyro.P = 35000
	flyBodyGyro.D = 1500
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root

	flyInputBeganConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not nowe then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.W then flyKeys.W = true
			elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = true
			elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = true
			elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = true
			elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true
			elseif input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.LeftControl = true
			end
		end
	end)

	flyInputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then flyKeys.W = false
		elseif input.KeyCode == Enum.KeyCode.S then flyKeys.S = false
		elseif input.KeyCode == Enum.KeyCode.A then flyKeys.A = false
		elseif input.KeyCode == Enum.KeyCode.D then flyKeys.D = false
		elseif input.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false
		elseif input.KeyCode == Enum.KeyCode.LeftControl then flyKeys.LeftControl = false
		end
	end)

	flyRenderConnection = RunService.RenderStepped:Connect(function(dt)
		if not nowe or closing then
			return
		end

		local currentCharacter = speaker.Character
		local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
		local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
		local camera = workspace.CurrentCamera

		if not currentHumanoid or not currentRoot or not flyBodyVelocity or not flyBodyGyro then
			return
		end

		if not flyBaseCFrames[next(flyBaseCFrames)] and currentCharacter then
			captureFlyPose(currentCharacter)
		end

		local cameraCF = camera and camera.CFrame or currentRoot.CFrame
		local forward = Vector3.new(cameraCF.LookVector.X, 0, cameraCF.LookVector.Z)
		local right = Vector3.new(cameraCF.RightVector.X, 0, cameraCF.RightVector.Z)

		if forward.Magnitude > 0 then forward = forward.Unit end
		if right.Magnitude > 0 then right = right.Unit end

		local move = Vector3.zero
		if flyKeys.W then move += forward end
		if flyKeys.S then move -= forward end
		if flyKeys.D then move += right end
		if flyKeys.A then move -= right end
		if move.Magnitude > 1 then move = move.Unit end

		local vertical = flyUpInput - flyDownInput
		if flyKeys.Space then vertical += 1 end
		if flyKeys.LeftControl then vertical -= 1 end
		vertical = math.clamp(vertical, -1, 1)

		local targetVelocity = move * (flySpeed * 55) + Vector3.new(0, vertical * flySpeed * 45, 0)
		local blend = 1 - math.exp(-12 * math.max(dt, 0))
		flyBodyVelocity.Velocity = flyBodyVelocity.Velocity:Lerp(targetVelocity, blend)

		local look = forward
		if look.Magnitude < 0.01 then
			local flatLook = Vector3.new(currentRoot.CFrame.LookVector.X, 0, currentRoot.CFrame.LookVector.Z)
			look = flatLook.Magnitude > 0 and flatLook.Unit or Vector3.new(0, 0, -1)
		end

		local targetCF = CFrame.lookAt(currentRoot.Position, currentRoot.Position + look, Vector3.yAxis)
		flyBodyGyro.CFrame = targetCF

		if flyAnimation then
			updateFlyPose(os.clock() - flyPoseStart)
		else
			for motor, transform in pairs(flyBaseCFrames) do
				if motor and motor.Parent then
					motor.Transform = transform
				end
			end
		end
	end)
end

-- GUI fly controls
onof.Activated:Connect(function()
	if closing then
		return
	end

	if nowe then
		stopFly()
	else
		startFly()
	end

	updateLanguage()
end)

up.MouseButton1Down:Connect(function()
	if nowe then flyUpInput = 1 end
end)

up.MouseButton1Up:Connect(function()
	flyUpInput = 0
end)

up.MouseLeave:Connect(function()
	flyUpInput = 0
end)

down.MouseButton1Down:Connect(function()
	if nowe then flyDownInput = 1 end
end)

down.MouseButton1Up:Connect(function()
	flyDownInput = 0
end)

down.MouseLeave:Connect(function()
	flyDownInput = 0
end)

local function closeGUI()
	if closing then
		return
	end

	closing = true

	ContextActionService:UnbindAction(activationActionName)
	stopFly()

	nowe = false
	tpwalking = false
	waitingForKey = false

	if activationKeyConnection then
		activationKeyConnection:Disconnect()
		activationKeyConnection = nil
	end

	if tis then
		tis:Disconnect()
		tis = nil
	end

	if dis then
		dis:Disconnect()
		dis = nil
	end

	if plusStop then
		plusStop()
		plusStop = nil
	end

	if minusStop then
		minusStop()
		minusStop = nil
	end

	saveConfig()
	main:Destroy()
end

closebutton.MouseButton1Click:Connect(function()
	if closing then
		return
	end

	local text =
		getLanguage()

	local confirm =
		Instance.new("Frame")

	confirm.Parent = main
	confirm.BackgroundColor3 =
		Color3.fromRGB(
			38,
			38,
			41
		)

	confirm.BorderSizePixel = 0
	confirm.AnchorPoint =
		Vector2.new(
			0.5,
			0.5
		)

	confirm.Position =
		UDim2.new(
			0.5,
			0,
			0.5,
			0
		)

	confirm.Size =
		UDim2.new(
			0,
			0,
			0,
			0
		)

	confirm.ZIndex = 100

	corner(
		confirm,
		10
	)

	local label =
		Instance.new("TextLabel")

	label.Parent = confirm
	label.BackgroundTransparency = 1

	label.Position =
		UDim2.new(
			0,
			10,
			0,
			10
		)

	label.Size =
		UDim2.new(
			1,
			-20,
			0,
			28
		)

	label.Font =
		fontMap[selectedFont]
		or Enum.Font.GothamBold

	label.Text =
		text.closeQuestion

	label.TextColor3 =
		Color3.fromRGB(
			255,
			255,
			255
		)

	label.TextSize = 16
	label.TextStrokeTransparency = 1
	label.ZIndex = 101

	local yes =
		Instance.new("TextButton")

	yes.Parent = confirm

	yes.BackgroundColor3 =
		Color3.fromRGB(
			70,
			180,
			105
		)

	yes.BorderSizePixel = 0

	yes.Position =
		UDim2.new(
			0,
			10,
			1,
			-38
		)

	yes.Size =
		UDim2.new(
			0.5,
			-15,
			0,
			28
		)

	yes.Font =
		fontMap[selectedFont]
		or Enum.Font.GothamBold

	yes.Text =
		text.yes

	yes.TextColor3 =
		Color3.fromRGB(
			255,
			255,
			255
		)

	yes.TextSize = 13
	yes.TextStrokeTransparency = 1
	yes.ZIndex = 101

	corner(
		yes,
		7
	)

	clickAnimation(yes)

	local no =
		Instance.new("TextButton")

	no.Parent = confirm

	no.BackgroundColor3 =
		Color3.fromRGB(
			190,
			65,
			65
		)

	no.BorderSizePixel = 0

	no.Position =
		UDim2.new(
			0.5,
			5,
			1,
			-38
		)

	no.Size =
		UDim2.new(
			0.5,
			-15,
			0,
			28
		)

	no.Font =
		fontMap[selectedFont]
		or Enum.Font.GothamBold

	no.Text =
		text.no

	no.TextColor3 =
		Color3.fromRGB(
			255,
			255,
			255
		)

	no.TextSize = 13
	no.TextStrokeTransparency = 1
	no.ZIndex = 101

	corner(
		no,
		7
	)

	clickAnimation(no)

	TweenService:Create(
		confirm,
		TweenInfo.new(
			0.22,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size =
				UDim2.new(
					0,
					210,
					0,
					105
				)
		}
	):Play()

	no.MouseButton1Click:Connect(function()
		local tween =
			TweenService:Create(
				confirm,
				TweenInfo.new(
					0.15,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.In
				),
				{
					Size =
						UDim2.new(
							0,
							0,
							0,
							0
						)
				}
			)

		tween:Play()

		tween.Completed:Once(function()
			confirm:Destroy()
		end)
	end)

	yes.MouseButton1Click:Connect(function()
		confirm:Destroy()
		closeGUI()
	end)
end)

main.Destroying:Connect(function()
	ContextActionService:UnbindAction(activationActionName)
	stopFly()
	if not closing then

		if activationKeyConnection then
			activationKeyConnection:Disconnect()
			activationKeyConnection = nil
		end
	end
end)

script.Destroying:Connect(function()
	ContextActionService:UnbindAction(activationActionName)
	stopFly()
	waitingForKey = false

	if activationKeyConnection then
		activationKeyConnection:Disconnect()
		activationKeyConnection = nil
	end

	if tis then
		tis:Disconnect()
		tis = nil
	end

	if dis then
		dis:Disconnect()
		dis = nil
	end
end)

Frame:GetPropertyChangedSignal(
	"Position"
):Connect(
	updateTopButtons
)
if pcFly then
	ContextActionService:BindActionAtPriority(activationActionName, function(_, state)
		if state == Enum.UserInputState.Begin and not waitingForKey and not closing then onof:Activate() end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, activationKey)
end


local loading = true

Frame.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
TextLabel.Font = Enum.Font.Code
TextLabel.Text = "Loading"
fpsLabel.Text = ""
deviceLabel.Text = ""

task.wait(1)

if not closing then
	loading = false
	TextLabel.Text = "Fly v4"
	updateLanguage()
	applyFont()
end

local fpsAccumulator = 0
local fpsFrames = 0
local msAccumulator = 0

RunService.RenderStepped:Connect(
	function(deltaTime)
		if not showFPS then
			return
		end

		fpsAccumulator += deltaTime
		fpsFrames += 1
		msAccumulator += deltaTime

		if fpsAccumulator >= 0.25 then
			local fps =
				math.floor(
					fpsFrames
					/ fpsAccumulator
					+ 0.5
				)

			local ms =
				math.floor(
					(msAccumulator / math.max(fpsFrames, 1))
					* 1000
					+ 0.5
				)

			fpsLabel.Text =
				"FPS: " ..
				fps ..
				"  |  MS: " ..
				ms

			local deviceType = "PC"

			if UserInputService.TouchEnabled
				and not UserInputService.KeyboardEnabled then
				if workspace.CurrentCamera
					and workspace.CurrentCamera.ViewportSize.X > 700 then
					deviceType = "TABLET"
				else
					deviceType = "ANDROID"
				end
			elseif UserInputService.GamepadEnabled
				and not UserInputService.KeyboardEnabled then
				deviceType = "CONSOLE"
			end

			deviceLabel.Text =
				"DEVICE: " ..
				deviceType

			fpsAccumulator = 0
			fpsFrames = 0
			msAccumulator = 0
		end
	end
)

local fpsAccumulator = 0
local fpsFrames = 0
local msAccumulator = 0
RunService.RenderStepped:Connect(function(dt)
	fpsAccumulator += dt
	fpsFrames += 1
	msAccumulator += dt
	if fpsAccumulator >= 0.25 then
		local fps = math.floor(fpsFrames / math.max(fpsAccumulator, 0.001) + 0.5)
		local ms = math.floor((msAccumulator / math.max(fpsFrames,1)) * 1000 + 0.5)
		local parts = {}
		if showFPS then table.insert(parts, "FPS: " .. fps) end
		if showMS then table.insert(parts, "MS: " .. ms) end
		fpsLabel.Text = table.concat(parts, "   |   ")
		if showDevice then deviceLabel.Text = "DEVICE: " .. getDeviceName() end
		fpsAccumulator = 0; fpsFrames = 0; msAccumulator = 0
		updateMetricsLayout()
	end
end)

updateSpeed()
applyFont()
applyButtonSize()
applyCornerRadius()
updateTopButtons()
updateLanguage()
updateConfigToggles()

Frame.BackgroundTransparency =
	backgroundTransparency

up.BackgroundTransparency =
	mainButtonsTransparency

down.BackgroundTransparency =
	mainButtonsTransparency

onof.BackgroundTransparency =
	mainButtonsTransparency

plus.BackgroundTransparency =
	mainButtonsTransparency

mine.BackgroundTransparency =
	mainButtonsTransparency

speed.BackgroundTransparency =
	mainButtonsTransparency

TextLabel.BackgroundTransparency =
	mainButtonsTransparency

closebutton.BackgroundTransparency =
	otherButtonsTransparency

mini.BackgroundTransparency =
	otherButtonsTransparency

mini2.BackgroundTransparency =
	otherButtonsTransparency

config.BackgroundTransparency =
	otherButtonsTransparency

fpsLabel.BackgroundTransparency =
	metricsTransparency

deviceLabel.BackgroundTransparency =
	metricsTransparency
fpsLabel.Visible =
	showFPS or showMS
deviceLabel.Visible =
	showDevice
deviceLabel.Text = "DEVICE: " .. getDeviceName()

scale.Scale =
	interfaceScale
applyButtonSize()
applyCornerRadius()
updateMetricsLayout()

if ConfigFrame then
	ConfigFrame.BackgroundTransparency =
		configTransparency

	ConfigScale.Scale = math.clamp(configScaleValue * interfaceScale, 0.4, 3.2)
end

pcall(function()
	StarterGui:SetCore(
		"SendNotification",
		{
			Title = "Fly v4",
			Text = "by ghost",
			Icon =
				"rbxthumb://type=Asset&id=5107182114&w=150&h=150"
		}
	)
end)
