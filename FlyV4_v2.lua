local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
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
local selectedFont = "GothamBold"

local uiCornerRadius = 7
local externalButtonScale = 1

local activationKey = Enum.KeyCode.F
local waitingForKey = false
local activationKeyConnection

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
		UICorner = uiCornerRadius,
		ExternalButtonScale = externalButtonScale
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

	if type(data.ShowMS) == "boolean" then
		showMS = data.ShowMS
	end

	if type(data.ShowDevice) == "boolean" then
		showDevice = data.ShowDevice
	end

	if type(data.MetricsTransparency) == "number" then
		metricsTransparency = math.clamp(
			data.MetricsTransparency,
			0,
			0.8
		)
	end

	if type(data.MetricsScale) == "number" then
		metricsScaleValue = math.clamp(
			data.MetricsScale,
			0.6,
			1.8
		)
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

	if type(data.UICorner) == "number" then
		uiCornerRadius = math.clamp(
			math.round(data.UICorner),
			0,
			30
		)
	end

	if type(data.ExternalButtonScale) == "number" then
		externalButtonScale = math.clamp(
			data.ExternalButtonScale,
			0.6,
			1.8
		)
	end
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
		configSize = "Tamanho da Config",
		uiCorner = "Arredondamento dos Cantos",
		externalButtonsSize = "Tamanho dos Botões Externos",
		saveSpeed = "Salvar Velocidade",
		showFPS = "Mostrar FPS",
		showMS = "Mostrar MS",
		showDevice = "Mostrar Dispositivo",
		metricsTransparency = "Transparência do FPS/MS/Dispositivo",
		metricsSize = "Tamanho do FPS/MS/Dispositivo",
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
		configSize = "Config Size",
		uiCorner = "Corner Radius",
		externalButtonsSize = "External Buttons Size",
		saveSpeed = "Save Speed",
		showFPS = "Show FPS",
		showMS = "Show MS",
		showDevice = "Show Device",
		metricsTransparency = "FPS/MS/Device Transparency",
		metricsSize = "FPS/MS/Device Size",
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
		configSize = "Tamaño de Config",
		uiCorner = "Redondeo de las Esquinas",
		externalButtonsSize = "Tamaño de los Botones Externos",
		saveSpeed = "Guardar Velocidad",
		showFPS = "Mostrar FPS",
		showMS = "Mostrar MS",
		showDevice = "Mostrar Dispositivo",
		metricsTransparency = "Transparencia de FPS/MS/Dispositivo",
		metricsSize = "Tamaño de FPS/MS/Dispositivo",
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

local function corner(object)
	local c = object:FindFirstChildOfClass("UICorner")

	if not c then
		c = Instance.new("UICorner")
		c.Parent = object
	end

	c.CornerRadius = UDim.new(0, uiCornerRadius)

	return c
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

corner(Frame)

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
fpsLabel.Text = ""
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
deviceLabel.Text = ""
deviceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
deviceLabel.TextSize = 12
deviceLabel.TextScaled = true
deviceLabel.TextStrokeTransparency = 1
deviceLabel.ZIndex = 5
deviceLabel.Visible = showDevice

corner(up)
corner(down)
corner(onof)
corner(TextLabel)
corner(plus)
corner(speed)
corner(mine)
corner(closebutton)
corner(mini)
corner(mini2)
corner(config)
corner(fpsLabel)
corner(deviceLabel)

local buttonBaseSizes = {}

local function clickAnimation(button)
	buttonBaseSizes[button] = button.Size

	local function getOriginalSize()
		return buttonBaseSizes[button] or button.Size
	end

	local function restore()
		local original = getOriginalSize()

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
	end

	button.MouseButton1Down:Connect(function()
		local original = getOriginalSize()

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

	button.MouseButton1Up:Connect(restore)
	button.MouseLeave:Connect(restore)
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

local function applyCornerRadius()
	for _, object in ipairs(main:GetDescendants()) do
		if object:IsA("UICorner") then
			object.CornerRadius = UDim.new(0, uiCornerRadius)
		end
	end
end

local function updateExternalButtonSizes()
	local buttonWidth = math.max(
		20,
		math.round(45 * externalButtonScale)
	)

	local buttonHeight = math.max(
		16,
		math.round(28 * externalButtonScale)
	)

	local buttons = {
		closebutton,
		mini,
		mini2,
		config
	}

	for _, button in ipairs(buttons) do
		button.Size = UDim2.fromOffset(
			buttonWidth,
			buttonHeight
		)

		buttonBaseSizes[button] = button.Size
	end

	closebutton.TextSize = math.max(
		12,
		math.round(23 * externalButtonScale)
	)

	mini.TextSize = math.max(
		12,
		math.round(22 * externalButtonScale)
	)

	mini2.TextSize = math.max(
		12,
		math.round(22 * externalButtonScale)
	)

	config.TextSize = math.max(
		10,
		math.round(16 * externalButtonScale)
	)
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

local function updateMetricsLayout()
	local showMetrics = showFPS or showMS

	fpsLabel.Visible = showMetrics
	deviceLabel.Visible = showDevice

	local framePosition = Frame.AbsolutePosition
	local frameSize = Frame.AbsoluteSize

	local baseScale = math.max(interfaceScale, 0.01)

	local metricScale = math.clamp(
		baseScale * metricsScaleValue,
		0.4,
		5
	)

	local width = math.max(frameSize.X, 1)

	local height = math.clamp(
		20 * metricScale,
		14,
		90
	)

	local gap = math.max(
		3 * baseScale,
		2
	)

	fpsLabel.Size = UDim2.fromOffset(
		width,
		height
	)

	fpsLabel.Position = UDim2.fromOffset(
		framePosition.X,
		framePosition.Y + frameSize.Y + gap
	)

	fpsLabel.TextSize = math.clamp(
		12 * metricScale,
		8,
		30
	)

	fpsLabel.BackgroundTransparency = metricsTransparency

	deviceLabel.Size = UDim2.fromOffset(
		width,
		height
	)

	deviceLabel.Position = UDim2.fromOffset(
		framePosition.X,
		framePosition.Y
			+ frameSize.Y
			+ gap
			+ (showMetrics and (height + gap) or 0)
	)

	deviceLabel.TextSize = math.clamp(
		12 * metricScale,
		8,
		30
	)

	deviceLabel.BackgroundTransparency = metricsTransparency
end

local function updateTopButtons()
	local position = Frame.Position

	local buttonWidth = math.max(
		20,
		math.round(45 * externalButtonScale)
	)

	local buttonHeight = math.max(
		16,
		math.round(28 * externalButtonScale)
	)

	local topOffset = buttonHeight + 1

	closebutton.Position = UDim2.new(
		position.X.Scale,
		position.X.Offset,
		position.Y.Scale,
		position.Y.Offset - topOffset
	)

	mini.Position = UDim2.new(
		position.X.Scale,
		position.X.Offset + buttonWidth,
		position.Y.Scale,
		position.Y.Offset - topOffset
	)

	mini2.Position = UDim2.new(
		position.X.Scale,
		position.X.Offset + buttonWidth,
		position.Y.Scale,
		position.Y.Offset - topOffset
	)

	config.Position = UDim2.new(
		position.X.Scale,
		position.X.Offset + buttonWidth * 2,
		position.Y.Scale,
		position.Y.Offset - topOffset
	)

	updateMetricsLayout()

	if ConfigFrame then
		ConfigFrame.Position = UDim2.new(
			position.X.Scale,
			position.X.Offset + 205,
			position.Y.Scale,
			position.Y.Offset
		)
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

	fpsLabel.BackgroundTransparency = metricsTransparency
	deviceLabel.BackgroundTransparency = metricsTransparency

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

local currentFontIndex = table.find(
	fonts,
	selectedFont
) or 1

local function setFontByIndex(index)
	currentFontIndex = ((index - 1) % #fonts) + 1

	selectedFont = fonts[currentFontIndex]

	applyFont()

	local fontValue = ConfigFrame
		and ConfigFrame:FindFirstChild(
			"FontValue",
			true
		)

	if fontValue then
		fontValue.Text = selectedFont
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
	local saveToggle = getConfigObject("SaveToggle")
	local fpsToggle = getConfigObject("FPSToggle")
	local msToggle = getConfigObject("MSToggle")
	local deviceToggle = getConfigObject("DeviceToggle")
	local pcFlyToggle = getConfigObject("PCFlyToggle")

	local function updateToggle(button, value)
		if not button then
			return
		end

		button.Text = value and "ON" or "OFF"

		button.BackgroundColor3 = value
			and Color3.fromRGB(70, 185, 110)
			or Color3.fromRGB(95, 95, 100)
	end

	updateToggle(saveToggle, saveSpeed)
	updateToggle(fpsToggle, showFPS)
	updateToggle(msToggle, showMS)
	updateToggle(deviceToggle, showDevice)
	updateToggle(pcFlyToggle, pcFly)
end

local function updateLanguage()
	local text = getLanguage()

	onof.Text = text.fly
	TextLabel.Text = "Fly v4"

	if ConfigFrame then
		local title = getConfigObject("Title")
		local languageButton = getConfigObject("LanguageButton")
		local backgroundLabel = getConfigObject("BackgroundLabel")
		local mainButtonsLabel = getConfigObject("MainButtonsLabel")
		local otherButtonsLabel = getConfigObject("OtherButtonsLabel")
		local configTransparencyLabel = getConfigObject("ConfigTransparencyLabel")
		local configSizeLabel = getConfigObject("ConfigSizeLabel")
		local uiCornerLabel = getConfigObject("UICornerLabel")
		local externalButtonsSizeLabel = getConfigObject("ExternalButtonsSizeLabel")
		local saveLabel = getConfigObject("SaveLabel")
		local fpsOptionLabel = getConfigObject("FPSOptionLabel")
		local msOptionLabel = getConfigObject("MSOptionLabel")
		local deviceOptionLabel = getConfigObject("DeviceOptionLabel")
		local metricsTransparencyLabel = getConfigObject("MetricsTransparencyLabel")
		local metricsSizeLabel = getConfigObject("MetricsSizeLabel")
		local pcFlyLabel = getConfigObject("PCFlyLabel")
		local activationKeyLabel = getConfigObject("ActivationKeyLabel")
		local activationKeyButton = getConfigObject("ActivationKeyButton")
		local pcKey = getConfigObject("PCKey")
		local fontLabel = getConfigObject("FontLabel")
		local fontValue = getConfigObject("FontValue")
		local previousFont = getConfigObject("PreviousFont")
		local nextFont = getConfigObject("NextFont")

		if title then
			title.Text = text.title
		end

		if languageButton then
			if language == "PT" then
				languageButton.Text = text.languagePT
			elseif language == "EN" then
				languageButton.Text = text.languageEN
			else
				languageButton.Text = text.languageES
			end
		end

		if backgroundLabel then
			backgroundLabel.Text =
				text.background
				.. ": "
				.. math.floor(
					backgroundTransparency * 100
				)
				.. "%"
		end

		if mainButtonsLabel then
			mainButtonsLabel.Text =
				text.mainButtons
				.. ": "
				.. math.floor(
					mainButtonsTransparency * 100
				)
				.. "%"
		end

		if otherButtonsLabel then
			otherButtonsLabel.Text =
				text.otherButtons
				.. ": "
				.. math.floor(
					otherButtonsTransparency * 100
				)
				.. "%"
		end

		if configTransparencyLabel then
			configTransparencyLabel.Text =
				text.configTransparency
				.. ": "
				.. math.floor(
					configTransparency * 100
				)
				.. "%"
		end

		if configSizeLabel then
			configSizeLabel.Text =
				text.configSize
				.. ": "
				.. math.floor(
					configScaleValue * 100
				)
				.. "%"
		end

		if uiCornerLabel then
			uiCornerLabel.Text =
				text.uiCorner
				.. ": "
				.. uiCornerRadius
				.. " px"
		end

		if externalButtonsSizeLabel then
			externalButtonsSizeLabel.Text =
				text.externalButtonsSize
				.. ": "
				.. math.floor(
					externalButtonScale * 100
				)
				.. "%"
		end

		if saveLabel then
			saveLabel.Text = text.saveSpeed
		end

		if fpsOptionLabel then
			fpsOptionLabel.Text = text.showFPS
		end

		if msOptionLabel then
			msOptionLabel.Text = text.showMS
		end

		if deviceOptionLabel then
			deviceOptionLabel.Text = text.showDevice
		end

		if metricsTransparencyLabel then
			metricsTransparencyLabel.Text =
				text.metricsTransparency
				.. ": "
				.. math.floor(
					metricsTransparency * 100
				)
				.. "%"
		end

		if metricsSizeLabel then
			metricsSizeLabel.Text =
				text.metricsSize
				.. ": "
				.. math.floor(
					metricsScaleValue * 100
				)
				.. "%"
		end

		if pcFlyLabel then
			pcFlyLabel.Text = text.pcFly
		end

		if activationKeyLabel then
			activationKeyLabel.Text = text.activationKey
		end

		if activationKeyButton then
			if waitingForKey then
				activationKeyButton.Text = text.pressKey
			else
				activationKeyButton.Text = activationKey.Name
			end
		end

		if pcKey then
			pcKey.Text =
				activationKey.Name
				.. " = Fly"
		end

		if fontLabel then
			fontLabel.Text = text.font
		end

		if fontValue then
			fontValue.Text = selectedFont
		end

		if previousFont then
			previousFont.Text =
				"‹ "
				.. text.previous
		end

		if nextFont then
			nextFont.Text =
				text.next
				.. " ›"
		end
	end

	applyFont()
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

local function getDeviceName()
	if UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled then
		return "MOBILE"
	end

	return "PC"
end

local function setDeviceVisible(value)
	showDevice = value
	deviceLabel.Text = "DEVICE: " .. getDeviceName()
	updateMetricsLayout()
	updateConfigToggles()
	saveConfig()
end

local function setMetricsTransparency(value)
	metricsTransparency = math.clamp(
		value,
		0,
		0.8
	)

	fpsLabel.BackgroundTransparency = metricsTransparency
	deviceLabel.BackgroundTransparency = metricsTransparency

	updateLanguage()
	updateMetricsLayout()
	saveConfig()
end

local function setMetricsScale(value)
	metricsScaleValue = math.clamp(
		value,
		0.6,
		1.8
	)

	updateMetricsLayout()
	updateLanguage()
	saveConfig()
end

local function createConfig()
	if not ConfigFrame then
		ConfigFrame = Instance.new("Frame")

		ConfigFrame.Name = "ConfigFrame"
		ConfigFrame.Parent = main
		ConfigFrame.BackgroundColor3 = Color3.fromRGB(
			40,
			40,
			43
		)
		ConfigFrame.BackgroundTransparency = configTransparency
		ConfigFrame.BorderSizePixel = 0
		ConfigFrame.Size = UDim2.new(
			0,
			250,
			0,
			330
		)
		ConfigFrame.ZIndex = 50
		ConfigFrame.Visible = false
		ConfigFrame.ClipsDescendants = true

		corner(ConfigFrame)

		ConfigScale = Instance.new("UIScale")
		ConfigScale.Scale = configScaleValue
		ConfigScale.Parent = ConfigFrame

		local title = Instance.new("TextLabel")

		title.Name = "Title"
		title.Parent = ConfigFrame
		title.BackgroundTransparency = 1
		title.Position = UDim2.new(
			0,
			12,
			0,
			8
		)
		title.Size = UDim2.new(
			1,
			-24,
			0,
			27
		)
		title.Font =
			fontMap[selectedFont]
			or Enum.Font.GothamBold
		title.TextColor3 = Color3.fromRGB(
			255,
			255,
			255
		)
		title.TextSize = 16
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextStrokeTransparency = 1
		title.ZIndex = 51

		local scroll = Instance.new("ScrollingFrame")

		scroll.Name = "SettingsScroll"
		scroll.Parent = ConfigFrame
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.Position = UDim2.new(
			0,
			8,
			0,
			42
		)
		scroll.Size = UDim2.new(
			1,
			-16,
			1,
			-50
		)
		scroll.CanvasSize = UDim2.new(
			0,
			0,
			0,
			970
		)
		scroll.ScrollBarThickness = 4
		scroll.ScrollingDirection = Enum.ScrollingDirection.Y
		scroll.ZIndex = 51

		local function makeLabel(
			name,
			position,
			height
		)
			local object = Instance.new("TextLabel")

			object.Name = name
			object.Parent = scroll
			object.BackgroundTransparency = 1
			object.Position = position
			object.Size = UDim2.new(
				1,
				-8,
				0,
				height or 21
			)
			object.Font =
				fontMap[selectedFont]
				or Enum.Font.GothamBold
			object.TextColor3 = Color3.fromRGB(
				220,
				220,
				225
			)
			object.TextSize = 12
			object.TextXAlignment = Enum.TextXAlignment.Left
			object.TextStrokeTransparency = 1
			object.ZIndex = 52

			return object
		end

		local function makeButton(
			name,
			position,
			size
		)
			local object = Instance.new("TextButton")

			object.Name = name
			object.Parent = scroll
			object.BackgroundColor3 = Color3.fromRGB(
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
			object.TextColor3 = Color3.fromRGB(
				255,
				255,
				255
			)
			object.TextSize = 12
			object.TextStrokeTransparency = 1
			object.ZIndex = 52

			corner(object)
			clickAnimation(object)

			return object
		end

		local languageButton = makeButton(
			"LanguageButton",
			UDim2.new(
				0,
				4,
				0,
				0
			)
		)

		local backgroundLabel = makeLabel(
			"BackgroundLabel",
			UDim2.new(
				0,
				4,
				0,
				38
			)
		)

		local backgroundDown = makeButton(
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

		local backgroundUp = makeButton(
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

		local mainButtonsLabel = makeLabel(
			"MainButtonsLabel",
			UDim2.new(
				0,
				4,
				0,
				98
			)
		)

		local mainButtonsDown = makeButton(
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

		local mainButtonsUp = makeButton(
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

		local otherButtonsLabel = makeLabel(
			"OtherButtonsLabel",
			UDim2.new(
				0,
				4,
				0,
				158
			)
		)

		local otherButtonsDown = makeButton(
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

		local otherButtonsUp = makeButton(
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

		local configTransparencyLabel = makeLabel(
			"ConfigTransparencyLabel",
			UDim2.new(
				0,
				4,
				0,
				218
			)
		)

		local configTransparencyDown = makeButton(
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

		local configTransparencyUp = makeButton(
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

		local configSizeLabel = makeLabel(
			"ConfigSizeLabel",
			UDim2.new(
				0,
				4,
				0,
				278
			)
		)

		local configSizeDown = makeButton(
			"ConfigSizeDown",
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

		configSizeDown.Text = "−"

		local configSizeUp = makeButton(
			"ConfigSizeUp",
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

		configSizeUp.Text = "+"

		local uiCornerLabel = makeLabel(
			"UICornerLabel",
			UDim2.new(
				0,
				4,
				0,
				338
			)
		)

		local uiCornerDown = makeButton(
			"UICornerDown",
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

		uiCornerDown.Text = "−"

		local uiCornerUp = makeButton(
			"UICornerUp",
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

		uiCornerUp.Text = "+"

		local externalButtonsSizeLabel = makeLabel(
			"ExternalButtonsSizeLabel",
			UDim2.new(
				0,
				4,
				0,
				398
			)
		)

		local externalButtonsSizeDown = makeButton(
			"ExternalButtonsSizeDown",
			UDim2.new(
				0,
				4,
				0,
				422
			),
			UDim2.new(
				0.5,
				-6,
				0,
				30
			)
		)

		externalButtonsSizeDown.Text = "−"

		local externalButtonsSizeUp = makeButton(
			"ExternalButtonsSizeUp",
			UDim2.new(
				0.5,
				2,
				0,
				422
			),
			UDim2.new(
				0.5,
				-10,
				0,
				30
			)
		)

		externalButtonsSizeUp.Text = "+"

		local saveLabel = makeLabel(
			"SaveLabel",
			UDim2.new(
				0,
				4,
				0,
				458
			)
		)

		local saveToggle = makeButton(
			"SaveToggle",
			UDim2.new(
				1,
				-58,
				0,
				454
			),
			UDim2.new(
				0,
				50,
				0,
				28
			)
		)

		local fpsOptionLabel = makeLabel(
			"FPSOptionLabel",
			UDim2.new(
				0,
				4,
				0,
				494
			)
		)

		local fpsToggle = makeButton(
			"FPSToggle",
			UDim2.new(
				1,
				-58,
				0,
				490
			),
			UDim2.new(
				0,
				50,
				0,
				28
			)
		)

		local pcFlyLabel = makeLabel(
			"PCFlyLabel",
			UDim2.new(
				0,
				4,
				0,
				530
			)
		)

		local pcFlyToggle = makeButton(
			"PCFlyToggle",
			UDim2.new(
				1,
				-58,
				0,
				526
			),
			UDim2.new(
				0,
				50,
				0,
				28
			)
		)

		local msOptionLabel = makeLabel(
			"MSOptionLabel",
			UDim2.new(
				0,
				4,
				0,
				566
			)
		)

		local msToggle = makeButton(
			"MSToggle",
			UDim2.new(
				1,
				-58,
				0,
				562
			),
			UDim2.new(
				0,
				50,
				0,
				28
			)
		)

		local deviceOptionLabel = makeLabel(
			"DeviceOptionLabel",
			UDim2.new(
				0,
				4,
				0,
				602
			)
		)

		local deviceToggle = makeButton(
			"DeviceToggle",
			UDim2.new(
				1,
				-58,
				0,
				598
			),
			UDim2.new(
				0,
				50,
				0,
				28
			)
		)

		local metricsTransparencyLabel = makeLabel(
			"MetricsTransparencyLabel",
			UDim2.new(
				0,
				4,
				0,
				638
			)
		)

		local metricsTransparencyDown = makeButton(
			"MetricsTransparencyDown",
			UDim2.new(
				0,
				4,
				0,
				662
			),
			UDim2.new(
				0.5,
				-6,
				0,
				30
			)
		)

		metricsTransparencyDown.Text = "−"

		local metricsTransparencyUp = makeButton(
			"MetricsTransparencyUp",
			UDim2.new(
				0.5,
				2,
				0,
				662
			),
			UDim2.new(
				0.5,
				-10,
				0,
				30
			)
		)

		metricsTransparencyUp.Text = "+"

		local metricsSizeLabel = makeLabel(
			"MetricsSizeLabel",
			UDim2.new(
				0,
				4,
				0,
				698
			)
		)

		local metricsSizeDown = makeButton(
			"MetricsSizeDown",
			UDim2.new(
				0,
				4,
				0,
				722
			),
			UDim2.new(
				0.5,
				-6,
				0,
				30
			)
		)

		metricsSizeDown.Text = "−"

		local metricsSizeUp = makeButton(
			"MetricsSizeUp",
			UDim2.new(
				0.5,
				2,
				0,
				722
			),
			UDim2.new(
				0.5,
				-10,
				0,
				30
			)
		)

		metricsSizeUp.Text = "+"

		local pcKey = makeLabel(
			"PCKey",
			UDim2.new(
				0,
				4,
				0,
				758
			),
			18
		)

		pcKey.Text = activationKey.Name .. " = Fly"

		local activationKeyLabel = makeLabel(
			"ActivationKeyLabel",
			UDim2.new(
				0,
				4,
				0,
				782
			)
		)

		local activationKeyButton = makeButton(
			"ActivationKeyButton",
			UDim2.new(
				0,
				4,
				0,
				806
			),
			UDim2.new(
				1,
				-8,
				0,
				30
			)
		)

		activationKeyButton.Text = activationKey.Name

		local fontLabel = makeLabel(
			"FontLabel",
			UDim2.new(
				0,
				4,
				0,
				846
			)
		)

		local fontValue = makeLabel(
			"FontValue",
			UDim2.new(
				0,
				4,
				0,
				870
			),
			28
		)

		fontValue.BackgroundTransparency = 0
		fontValue.BackgroundColor3 = Color3.fromRGB(
			65,
			65,
			70
		)
		fontValue.TextXAlignment = Enum.TextXAlignment.Center

		corner(fontValue)

		local previousFont = makeButton(
			"PreviousFont",
			UDim2.new(
				0,
				4,
				0,
				904
			),
			UDim2.new(
				0.5,
				-6,
				0,
				29
			)
		)

		local nextFont = makeButton(
			"NextFont",
			UDim2.new(
				0.5,
				2,
				0,
				904
			),
			UDim2.new(
				0.5,
				-10,
				0,
				29
			)
		)

		local function beginKeySelection()
			if waitingForKey then
				return
			end

			waitingForKey = true
			updateLanguage()

			if activationKeyConnection then
				activationKeyConnection:Disconnect()
				activationKeyConnection = nil
			end

			activationKeyConnection = UserInputService.InputBegan:Connect(
				function(input, processed)
					if processed
						or input.UserInputType
							~= Enum.UserInputType.Keyboard then
						return
					end

					if input.KeyCode == Enum.KeyCode.Unknown then
						return
					end

					if input.KeyCode == Enum.KeyCode.Escape then
						waitingForKey = false

						if activationKeyConnection then
							activationKeyConnection:Disconnect()
							activationKeyConnection = nil
						end

						updateLanguage()
						return
					end

					activationKey = input.KeyCode
					waitingForKey = false

					if activationKeyConnection then
						activationKeyConnection:Disconnect()
						activationKeyConnection = nil
					end

					updateLanguage()
					saveConfig()
				end
			)
		end

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

		configSizeDown.MouseButton1Click:Connect(function()
			configScaleValue = math.clamp(
				configScaleValue - 0.05,
				0.65,
				1.1
			)

			ConfigScale.Scale = configScaleValue

			updateLanguage()
			saveConfig()
		end)

		configSizeUp.MouseButton1Click:Connect(function()
			configScaleValue = math.clamp(
				configScaleValue + 0.05,
				0.65,
				1.1
			)

			ConfigScale.Scale = configScaleValue

			updateLanguage()
			saveConfig()
		end)

		uiCornerDown.MouseButton1Click:Connect(function()
			uiCornerRadius = math.clamp(
				uiCornerRadius - 1,
				0,
				30
			)

			applyCornerRadius()
			updateLanguage()
			saveConfig()
		end)

		uiCornerUp.MouseButton1Click:Connect(function()
			uiCornerRadius = math.clamp(
				uiCornerRadius + 1,
				0,
				30
			)

			applyCornerRadius()
			updateLanguage()
			saveConfig()
		end)

		externalButtonsSizeDown.MouseButton1Click:Connect(function()
			externalButtonScale = math.clamp(
				externalButtonScale - 0.05,
				0.6,
				1.8
			)

			updateExternalButtonSizes()
			updateTopButtons()
			updateLanguage()
			saveConfig()
		end)

		externalButtonsSizeUp.MouseButton1Click:Connect(function()
			externalButtonScale = math.clamp(
				externalButtonScale + 0.05,
				0.6,
				1.8
			)

			updateExternalButtonSizes()
			updateTopButtons()
			updateLanguage()
			saveConfig()
		end)

		saveToggle.MouseButton1Click:Connect(function()
			saveSpeed = not saveSpeed

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

			updateConfigToggles()
			saveConfig()
		end)

		msToggle.MouseButton1Click:Connect(function()
			setMSVisible(not showMS)
		end)

		deviceToggle.MouseButton1Click:Connect(function()
			setDeviceVisible(not showDevice)
		end)

		metricsTransparencyDown.MouseButton1Click:Connect(function()
			setMetricsTransparency(
				metricsTransparency + 0.05
			)
		end)

		metricsTransparencyUp.MouseButton1Click:Connect(function()
			setMetricsTransparency(
				metricsTransparency - 0.05
			)
		end)

		metricsSizeDown.MouseButton1Click:Connect(function()
			setMetricsScale(
				metricsScaleValue - 0.1
			)
		end)

		metricsSizeUp.MouseButton1Click:Connect(function()
			setMetricsScale(
				metricsScaleValue + 0.1
			)
		end)

		activationKeyButton.MouseButton1Click:Connect(
			beginKeySelection
		)

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

	updateExternalButtonSizes()
	updateTopButtons()

	ConfigFrame.Visible = true

	ConfigScale.Scale = configScaleValue

	ConfigFrame.Size = UDim2.new(
		0,
		0,
		0,
		330
	)

	local tween = TweenService:Create(
		ConfigFrame,
		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.new(
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
	applyCornerRadius()
end

config.MouseButton1Click:Connect(function()
	if not ConfigFrame then
		createConfig()
		return
	end

	if ConfigFrame.Visible then
		local tween = TweenService:Create(
			ConfigFrame,
			TweenInfo.new(
				0.15,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.In
			),
			{
				Size = UDim2.new(
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

				ConfigFrame.Size = UDim2.new(
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

local function startSpeedHold(button, amount)
	local holding = true

	task.spawn(function()
		task.wait(0.6)

		while holding
			and button:IsDescendantOf(game) do

			local oldSpeed = flySpeed

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

	plusStop = startSpeedHold(
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

	minusStop = startSpeedHold(
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

local hum = chr and chr:FindFirstChildWhichIsA(
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
			Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
		}
	)
end)

local function toggleFly()
	if closing then
		return
	end

	if nowe == true then
		nowe = false

		local character = speaker.Character

		local humanoid = character
			and character:FindFirstChildOfClass(
				"Humanoid"
			)

		if humanoid then
			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Climbing,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.FallingDown,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Flying,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Freefall,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.GettingUp,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Jumping,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Landed,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Physics,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.PlatformStanding,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Ragdoll,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Running,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.RunningNoPhysics,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.GettingUp,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Seated,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.StrafingNoPhysics,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Swimming,
				true
			)

			humanoid:ChangeState(
				Enum.HumanoidStateType.RunningNoPhysics
			)
		end
	else
		nowe = true

		for i = 1, speeds do
			task.spawn(function()
				local hb = RunService.Heartbeat

				tpwalking = true

				local character =
					Players.LocalPlayer.Character

				local humanoid =
					character
					and character:FindFirstChildWhichIsA(
						"Humanoid"
					)

				while tpwalking
					and hb:Wait()
					and character
					and humanoid
					and humanoid.Parent do

					if humanoid.MoveDirection.Magnitude > 0 then
						character:TranslateBy(
							humanoid.MoveDirection
								* flySpeed
						)
					end
				end
			end)
		end

		local character = Players.LocalPlayer.Character

		if character then
			local animate = character:FindFirstChild(
				"Animate"
			)

			if animate then
				animate.Disabled = true
			end

			local humanoid =
				character:FindFirstChildOfClass(
					"Humanoid"
				)

			if humanoid then
				for _, track in ipairs(
					humanoid:GetPlayingAnimationTracks()
				) do
					track:AdjustSpeed(0)
				end

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Climbing,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.FallingDown,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Flying,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Freefall,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.GettingUp,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Jumping,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Landed,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Physics,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.PlatformStanding,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Ragdoll,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Running,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.RunningNoPhysics,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Seated,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.StrafingNoPhysics,
					false
				)

				humanoid:SetStateEnabled(
					Enum.HumanoidStateType.Swimming,
					false
				)

				humanoid:ChangeState(
					Enum.HumanoidStateType.Swimming
				)
			end
		end
	end

	local character = Players.LocalPlayer.Character

	local humanoid =
		character
		and character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid then
		return
	end

	if humanoid.RigType ==
		Enum.HumanoidRigType.R6 then

		local plr = Players.LocalPlayer

		local torso =
			plr.Character
			and plr.Character:FindFirstChild(
				"Torso"
			)

		if not torso then
			nowe = false
			tpwalking = false
			return
		end

		local ctrl = {
			f = 0,
			b = 0,
			l = 0,
			r = 0
		}

		local lastctrl = {
			f = 0,
			b = 0,
			l = 0,
			r = 0
		}

		local speedValue = 0

		local bg = Instance.new(
			"BodyGyro",
			torso
		)

		bg.P = 9e4

		bg.MaxTorque = Vector3.new(
			9e9,
			9e9,
			9e9
		)

		bg.CFrame = torso.CFrame

		local bv = Instance.new(
			"BodyVelocity",
			torso
		)

		bv.Velocity = Vector3.new(
			0,
			0.1,
			0
		)

		bv.MaxForce = Vector3.new(
			9e9,
			9e9,
			9e9
		)

		if nowe == true then
			humanoid.PlatformStand = true
		end

		while nowe == true
			or (
				Players.LocalPlayer.Character
				and Players.LocalPlayer.Character:FindFirstChildOfClass(
					"Humanoid"
				)
				and Players.LocalPlayer.Character:FindFirstChildOfClass(
					"Humanoid"
				).Health == 0
			) do

			RunService.RenderStepped:Wait()

			local maxspeed = 50 * flySpeed

			if ctrl.l + ctrl.r ~= 0
				or ctrl.f + ctrl.b ~= 0 then

				speedValue =
					speedValue
					+ 0.5
					+ (
						speedValue
						/ math.max(
							maxspeed,
							0.1
						)
					)

				if speedValue > maxspeed then
					speedValue = maxspeed
				end

			elseif speedValue ~= 0 then
				speedValue = speedValue - 1

				if speedValue < 0 then
					speedValue = 0
				end
			end

			if ctrl.l + ctrl.r ~= 0
				or ctrl.f + ctrl.b ~= 0 then

				bv.Velocity =
					(
						workspace.CurrentCamera.CFrame.LookVector
						* (
							ctrl.f + ctrl.b
						)
					)
					+
					(
						(
							workspace.CurrentCamera.CFrame
							* CFrame.new(
								ctrl.l + ctrl.r,
								(
									ctrl.f + ctrl.b
								) * 0.2,
								0
							).Position
						)
						-
						workspace.CurrentCamera.CFrame.Position
					)

				bv.Velocity =
					bv.Velocity
					* speedValue

				lastctrl = {
					f = ctrl.f,
					b = ctrl.b,
					l = ctrl.l,
					r = ctrl.r
				}

			elseif speedValue ~= 0 then

				bv.Velocity =
					(
						workspace.CurrentCamera.CFrame.LookVector
						* (
							lastctrl.f + lastctrl.b
						)
					)
					+
					(
						(
							workspace.CurrentCamera.CFrame
							* CFrame.new(
								lastctrl.l + lastctrl.r,
								(
									lastctrl.f + lastctrl.b
								) * 0.2,
								0
							).Position
						)
						-
						workspace.CurrentCamera.CFrame.Position
					)

				bv.Velocity =
					bv.Velocity
					* speedValue

			else
				bv.Velocity = Vector3.new(
					0,
					0,
					0
				)
			end

			bg.CFrame =
				workspace.CurrentCamera.CFrame
				* CFrame.Angles(
					-math.rad(
						(ctrl.f + ctrl.b)
						* 50
						* speedValue
						/ math.max(
							maxspeed,
							0.1
						)
					),
					0,
					0
				)
		end

		bg:Destroy()
		bv:Destroy()

		if plr.Character then
			local currentHumanoid =
				plr.Character:FindFirstChildOfClass(
					"Humanoid"
				)

			if currentHumanoid then
				currentHumanoid.PlatformStand = false
			end

			local animate =
				plr.Character:FindFirstChild(
					"Animate"
				)

			if animate then
				animate.Disabled = false
			end
		end

		tpwalking = false
	else
		local plr = Players.LocalPlayer

		local upperTorso =
			plr.Character
			and plr.Character:FindFirstChild(
				"UpperTorso"
			)

		if not upperTorso then
			nowe = false
			tpwalking = false
			return
		end

		local ctrl = {
			f = 0,
			b = 0,
			l = 0,
			r = 0
		}

		local lastctrl = {
			f = 0,
			b = 0,
			l = 0,
			r = 0
		}

		local speedValue = 0

		local bg = Instance.new(
			"BodyGyro",
			upperTorso
		)

		bg.P = 9e4

		bg.MaxTorque = Vector3.new(
			9e9,
			9e9,
			9e9
		)

		bg.CFrame = upperTorso.CFrame

		local bv = Instance.new(
			"BodyVelocity",
			upperTorso
		)

		bv.Velocity = Vector3.new(
			0,
			0.1,
			0
		)

		bv.MaxForce = Vector3.new(
			9e9,
			9e9,
			9e9
		)

		if nowe == true then
			humanoid.PlatformStand = true
		end

		while nowe == true
			or (
				Players.LocalPlayer.Character
				and Players.LocalPlayer.Character:FindFirstChildOfClass(
					"Humanoid"
				)
				and Players.LocalPlayer.Character:FindFirstChildOfClass(
					"Humanoid"
				).Health == 0
			) do

			RunService.Heartbeat:Wait()

			local maxspeed = 50 * flySpeed

			if ctrl.l + ctrl.r ~= 0
				or ctrl.f + ctrl.b ~= 0 then

				speedValue =
					speedValue
					+ 0.5
					+ (
						speedValue
						/ math.max(
							maxspeed,
							0.1
						)
					)

				if speedValue > maxspeed then
					speedValue = maxspeed
				end

			elseif speedValue ~= 0 then
				speedValue = speedValue - 1

				if speedValue < 0 then
					speedValue = 0
				end
			end

			if ctrl.l + ctrl.r ~= 0
				or ctrl.f + ctrl.b ~= 0 then

				bv.Velocity =
					(
						workspace.CurrentCamera.CFrame.LookVector
						* (
							ctrl.f + ctrl.b
						)
					)
					+
					(
						(
							workspace.CurrentCamera.CFrame
							* CFrame.new(
								ctrl.l + ctrl.r,
								(
									ctrl.f + ctrl.b
								) * 0.2,
								0
							).Position
						)
						-
						workspace.CurrentCamera.CFrame.Position
					)

				bv.Velocity =
					bv.Velocity
					* speedValue

				lastctrl = {
					f = ctrl.f,
					b = ctrl.b,
					l = ctrl.l,
					r = ctrl.r
				}

			elseif speedValue ~= 0 then

				bv.Velocity =
					(
						workspace.CurrentCamera.CFrame.LookVector
						* (
							lastctrl.f + lastctrl.b
						)
					)
					+
					(
						(
							workspace.CurrentCamera.CFrame
							* CFrame.new(
								lastctrl.l + lastctrl.r,
								(
									lastctrl.f + lastctrl.b
								) * 0.2,
								0
							).Position
						)
						-
						workspace.CurrentCamera.CFrame.Position
					)

				bv.Velocity =
					bv.Velocity
					* speedValue

			else
				bv.Velocity = Vector3.new(
					0,
					0,
					0
				)
			end

			bg.CFrame =
				workspace.CurrentCamera.CFrame
				* CFrame.Angles(
					-math.rad(
						(ctrl.f + ctrl.b)
						* 50
						* speedValue
						/ math.max(
							maxspeed,
							0.1
						)
					),
					0,
					0
				)
		end

		bg:Destroy()
		bv:Destroy()

		if plr.Character then
			local currentHumanoid =
				plr.Character:FindFirstChildOfClass(
					"Humanoid"
				)

			if currentHumanoid then
				currentHumanoid.PlatformStand = false
			end

			local animate =
				plr.Character:FindFirstChild(
					"Animate"
				)

			if animate then
				animate.Disabled = false
			end
		end

		tpwalking = false
	end
end

onof.Activated:Connect(toggleFly)

local tis

up.MouseButton1Down:Connect(function()
	tis = up.MouseEnter:Connect(function()
		while tis do
			task.wait()

			local character =
				Players.LocalPlayer.Character

			local root =
				character
				and character:FindFirstChild(
					"HumanoidRootPart"
				)

			if root then
				root.CFrame =
					root.CFrame
					* CFrame.new(
						0,
						1,
						0
					)
			end
		end
	end)
end)

up.MouseLeave:Connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)

local dis

down.MouseButton1Down:Connect(function()
	dis = down.MouseEnter:Connect(function()
		while dis do
			task.wait()

			local character =
				Players.LocalPlayer.Character

			local root =
				character
				and character:FindFirstChild(
					"HumanoidRootPart"
				)

			if root then
				root.CFrame =
					root.CFrame
					* CFrame.new(
						0,
						-1,
						0
					)
			end
		end
	end)
end)

down.MouseLeave:Connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)

player.CharacterAdded:Connect(function(char)
	task.wait(0.7)

	if nowe then
		nowe = false
		tpwalking = false
	end

	local humanoid =
		char:FindFirstChildOfClass(
			"Humanoid"
		)

	if humanoid then
		humanoid.PlatformStand = false
	end

	local animate =
		char:FindFirstChild(
			"Animate"
		)

	if animate then
		animate.Disabled = false
	end
end)

UserInputService.InputBegan:Connect(function(
	input,
	processed
)
	if processed
		or not pcFly
		or closing
		or waitingForKey then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.Keyboard
		and input.KeyCode == activationKey then

		toggleFly()
	end
end)

mini.MouseButton1Click:Connect(function()
	if minimized then
		return
	end

	minimized = true

	if ConfigFrame then
		ConfigFrame.Visible = false
	end

	TweenService:Create(
		Frame,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.InOut
		),
		{
			Size = UDim2.new(
				0,
				190,
				0,
				28
			)
		}
	):Play()

	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	mine.Visible = false

	mini.Visible = false
	mini2.Visible = true
	config.Visible = true

	updateTopButtons()
end)

mini2.MouseButton1Click:Connect(function()
	if not minimized then
		return
	end

	minimized = false

	TweenService:Create(
		Frame,
		TweenInfo.new(
			0.25,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.InOut
		),
		{
			Size = UDim2.new(
				0,
				190,
				0,
				57
			)
		}
	):Play()

	task.delay(
		0.12,
		function()
			if closing then
				return
			end

			up.Visible = true
			down.Visible = true
			onof.Visible = true
			plus.Visible = true
			speed.Visible = true
			mine.Visible = true

			mini.Visible = true
			mini2.Visible = false
			config.Visible = true

			updateTopButtons()
		end
	)
end)

local function closeGUI()
	if closing then
		return
	end

	closing = true

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

	local text = getLanguage()

	local confirm = Instance.new("Frame")

	confirm.Parent = main
	confirm.BackgroundColor3 = Color3.fromRGB(
		38,
		38,
		41
	)
	confirm.BorderSizePixel = 0
	confirm.AnchorPoint = Vector2.new(
		0.5,
		0.5
	)
	confirm.Position = UDim2.new(
		0.5,
		0,
		0.5,
		0
	)
	confirm.Size = UDim2.new(
		0,
		0,
		0,
		0
	)
	confirm.ZIndex = 100

	corner(confirm)

	local label = Instance.new("TextLabel")

	label.Parent = confirm
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(
		0,
		10,
		0,
		10
	)
	label.Size = UDim2.new(
		1,
		-20,
		0,
		28
	)
	label.Font =
		fontMap[selectedFont]
		or Enum.Font.GothamBold
	label.Text = text.closeQuestion
	label.TextColor3 = Color3.fromRGB(
		255,
		255,
		255
	)
	label.TextSize = 16
	label.TextStrokeTransparency = 1
	label.ZIndex = 101

	local yes = Instance.new("TextButton")

	yes.Parent = confirm
	yes.BackgroundColor3 = Color3.fromRGB(
		70,
		180,
		105
	)
	yes.BorderSizePixel = 0
	yes.Position = UDim2.new(
		0,
		10,
		1,
		-38
	)
	yes.Size = UDim2.new(
		0.5,
		-15,
		0,
		28
	)
	yes.Font =
		fontMap[selectedFont]
		or Enum.Font.GothamBold
	yes.Text = text.yes
	yes.TextColor3 = Color3.fromRGB(
		255,
		255,
		255
	)
	yes.TextSize = 13
	yes.TextStrokeTransparency = 1
	yes.ZIndex = 101

	corner(yes)
	clickAnimation(yes)

	local no = Instance.new("TextButton")

	no.Parent = confirm
	no.BackgroundColor3 = Color3.fromRGB(
		190,
		65,
		65
	)
	no.BorderSizePixel = 0
	no.Position = UDim2.new(
		0.5,
		5,
		1,
		-38
	)
	no.Size = UDim2.new(
		0.5,
		-15,
		0,
		28
	)
	no.Font =
		fontMap[selectedFont]
		or Enum.Font.GothamBold
	no.Text = text.no
	no.TextColor3 = Color3.fromRGB(
		255,
		255,
		255
	)
	no.TextSize = 13
	no.TextStrokeTransparency = 1
	no.ZIndex = 101

	corner(no)
	clickAnimation(no)

	TweenService:Create(
		confirm,
		TweenInfo.new(
			0.22,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.new(
				0,
				210,
				0,
				105
			)
		}
	):Play()

	no.MouseButton1Click:Connect(function()
		local tween = TweenService:Create(
			confirm,
			TweenInfo.new(
				0.15,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				Size = UDim2.new(
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
	if not closing then
		nowe = false
		tpwalking = false

		if activationKeyConnection then
			activationKeyConnection:Disconnect()
			activationKeyConnection = nil
		end
	end
end)

script.Destroying:Connect(function()
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
end)

Frame:GetPropertyChangedSignal(
	"Position"
):Connect(
	updateTopButtons
)

local loading = true

Frame.BackgroundColor3 = Color3.fromRGB(
	45,
	45,
	48
)

TextLabel.Font = Enum.Font.Code
TextLabel.Text = "Loading..."

fpsLabel.Text = ""
deviceLabel.Text = ""

fpsLabel.Visible = false
deviceLabel.Visible = false

updateExternalButtonSizes()
updateTopButtons()

task.wait(1)

if not closing then
	loading = false

	TextLabel.Text = "Fly v4"

	updateLanguage()
	applyFont()
	updateMetricsLayout()
	applyCornerRadius()
	updateExternalButtonSizes()
	updateTopButtons()
end

local fpsAccumulator = 0
local fpsFrames = 0
local msAccumulator = 0

RunService.RenderStepped:Connect(function(deltaTime)
	fpsAccumulator += deltaTime
	fpsFrames += 1
	msAccumulator += deltaTime

	if fpsAccumulator >= 0.25 then
		local fps = math.floor(
			fpsFrames
			/ math.max(
				fpsAccumulator,
				0.001
			)
			+ 0.5
		)

		local ms = math.floor(
			(
				msAccumulator
				/ math.max(
					fpsFrames,
					1
				)
			)
			* 1000
			+ 0.5
		)

		local metrics = {}

		if showFPS then
			table.insert(
				metrics,
				"FPS: " .. fps
			)
		end

		if showMS then
			table.insert(
				metrics,
				"MS: " .. ms
			)
		end

		fpsLabel.Text = table.concat(
			metrics,
			"  |  "
		)

		deviceLabel.Text =
			"DEVICE: "
			.. getDeviceName()

		fpsAccumulator = 0
		fpsFrames = 0
		msAccumulator = 0

		updateMetricsLayout()
	end
end)

updateSpeed()
applyFont()
applyCornerRadius()
updateExternalButtonSizes()
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

scale.Scale = interfaceScale

updateMetricsLayout()

if ConfigFrame then
	ConfigFrame.BackgroundTransparency =
		configTransparency

	ConfigScale.Scale =
		configScaleValue
end

pcall(function()
	StarterGui:SetCore(
		"SendNotification",
		{
			Title = "Fly v4",
			Text = "by ghost",
			Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150"
		}
	)
end)
