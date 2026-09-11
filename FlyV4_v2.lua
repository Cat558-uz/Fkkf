local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local Config = {
	Enabled = true,

	PriorityEnabled = true,
	PriorityStuds = 19,
	PrioritizeNearest = true,
	PrioritizeEnemies = true,
	OnlyPriorityRange = true,
	MaxDistance = 250,
	UpdateRate = 0.025,

	DamageEnabled = true,
	DamageDelay = 0.05,
	DamageDuration = 0.8,
	DamageRise = 2.5,

	TextSize = 24,
	Font = Enum.Font.GothamBold,
	TextColor = Color3.fromRGB(255, 45, 45),
	TextTransparency = 0,

	StrokeEnabled = true,
	StrokeColor = Color3.fromRGB(255, 150, 150),
	StrokeTransparency = 0.2,
	StrokeThickness = 1,

	RandomPosition = true,
	RandomX = 1.2,
	RandomY = 0.7,
	RandomZ = 1.2,

	ThroughWalls = false,

	MouseDamage = false,
	MouseDamageOffsetX = 22,
	MouseDamageOffsetY = 0,

	ShowFPS = false,
	ShowMS = false,
	PerformanceOffsetX = 22,
	PerformanceOffsetY = 20,

	TracePlayer = false,
	TracePlayerMouse = false,
	TraceMouseDeadRed = true,
	TraceLength = 8,
	TraceThickness = 1.5,

	HealthPlayers = false,
	HealthTextSize = 16,
	HealthMaxDistance = 250,

	DeathEnabled = true,
	DeathText = "Dead",
	DeathDuration = 1.1,
	DeathRise = 3,
	DeathTextSize = 25,
	DeathTextColor = Color3.fromRGB(35, 35, 35),
	DeathStrokeEnabled = true,
	DeathStrokeColor = Color3.fromRGB(220, 220, 220),
	DeathStrokeTransparency = 0.25
}

local Connections = {}
local Tracked = {}
local HealthLabels = {}
local PlayerTraces = {}

local CurrentTarget = nil
local MouseTrace = nil

local MousePosition = UserInputService:GetMouseLocation()
local LastTouchPosition = MousePosition

local FPS = 0
local Frames = 0
local LastFPSUpdate = os.clock()
local LastTargetUpdate = 0

local DrawingAvailable =
	typeof(Drawing) == "table"
	and typeof(Drawing.new) == "function"

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DamageIndicator"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(330, 520)
Main.Position = UDim2.new(0.5, -165, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -55, 0, 45)
Header.Position = UDim2.fromOffset(15, 0)
Header.BackgroundTransparency = 1
Header.Text = "Damage Indicator"
Header.TextColor3 = Color3.new(1, 1, 1)
Header.TextSize = 17
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -42, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Close.Text = "×"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(45, 45)
OpenButton.Position = UDim2.fromOffset(15, 200)
OpenButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
OpenButton.Text = "⚙"
OpenButton.TextSize = 20
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenButton

local Sections = Instance.new("ScrollingFrame")
Sections.Size = UDim2.new(1, -20, 1, -58)
Sections.Position = UDim2.fromOffset(10, 50)
Sections.BackgroundTransparency = 1
Sections.BorderSizePixel = 0
Sections.ScrollBarThickness = 3
Sections.CanvasSize = UDim2.new()
Sections.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sections.Parent = Main

local SectionsLayout = Instance.new("UIListLayout")
SectionsLayout.Padding = UDim.new(0, 8)
SectionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SectionsLayout.Parent = Sections

local function CreateSection(Name, Order)
	local Section = Instance.new("Frame")
	Section.Name = Name
	Section.Size = UDim2.new(1, -5, 0, 0)
	Section.AutomaticSize = Enum.AutomaticSize.Y
	Section.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
	Section.BorderSizePixel = 0
	Section.LayoutOrder = Order
	Section.Parent = Sections

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 9)
	Corner.Parent = Section

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 8)
	Padding.PaddingBottom = UDim.new(0, 8)
	Padding.PaddingLeft = UDim.new(0, 10)
	Padding.PaddingRight = UDim.new(0, 10)
	Padding.Parent = Section

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 5)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Section

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 0, 27)
	Title.BackgroundTransparency = 1
	Title.Text = Name
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.TextSize = 14
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.LayoutOrder = 0
	Title.Parent = Section

	return Section
end

local function CreateToggle(Parent, Name, Getter, Setter, Order)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 0, 32)
	Button.BackgroundColor3 = Color3.fromRGB(35, 35, 41)
	Button.BorderSizePixel = 0
	Button.TextSize = 12
	Button.Font = Enum.Font.GothamMedium
	Button.TextXAlignment = Enum.TextXAlignment.Left
	Button.LayoutOrder = Order
	Button.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Button

	local function Refresh()
		local State = Getter()

		Button.Text =
			"  "
			.. Name
			.. "  ["
			.. (State and "ON" or "OFF")
			.. "]"

		Button.TextColor3 =
			State
			and Color3.fromRGB(120, 255, 150)
			or Color3.fromRGB(180, 180, 180)
	end

	Button.MouseButton1Click:Connect(function()
		Setter(not Getter())
		Refresh()
	end)

	Refresh()

	return Button
end

local function CreateNumberBox(Parent, Name, Getter, Setter, Order)
	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(1, 0, 0, 32)
	Box.BackgroundColor3 = Color3.fromRGB(35, 35, 41)
	Box.BorderSizePixel = 0
	Box.TextSize = 12
	Box.Font = Enum.Font.GothamMedium
	Box.TextColor3 = Color3.new(1, 1, 1)
	Box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	Box.TextXAlignment = Enum.TextXAlignment.Left
	Box.ClearTextOnFocus = false
	Box.LayoutOrder = Order
	Box.Text = "  " .. Name .. ": " .. tostring(Getter())
	Box.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Box

	Box.FocusLost:Connect(function()
		local Value = tonumber(
			Box.Text:match(":%s*([%-]?[%d%.]+)")
		)

		if Value then
			Setter(Value)
		end

		Box.Text =
			"  "
			.. Name
			.. ": "
			.. tostring(Getter())
	end)

	return Box
end

local FontList = {
	Enum.Font.Gotham,
	Enum.Font.GothamBold,
	Enum.Font.GothamBlack,
	Enum.Font.GothamMedium,
	Enum.Font.GothamSemibold,
	Enum.Font.SourceSans,
	Enum.Font.SourceSansBold,
	Enum.Font.SourceSansSemibold,
	Enum.Font.SourceSansLight,
	Enum.Font.Arial,
	Enum.Font.ArialBold,
	Enum.Font.Roboto,
	Enum.Font.RobotoMono,
	Enum.Font.RobotoCondensed,
	Enum.Font.Ubuntu,
	Enum.Font.FredokaOne
}

local FontIndex = 2

local function CreateFontSelector(Parent, Order)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 0, 32)
	Button.BackgroundColor3 = Color3.fromRGB(35, 35, 41)
	Button.BorderSizePixel = 0
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.TextSize = 12
	Button.Font = Enum.Font.GothamMedium
	Button.TextXAlignment = Enum.TextXAlignment.Left
	Button.LayoutOrder = Order
	Button.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Button

	local function Refresh()
		Button.Text =
			"  Fonte: "
			.. tostring(FontList[FontIndex]):gsub("Enum.Font.", "")
	end

	Button.MouseButton1Click:Connect(function()
		FontIndex += 1

		if FontIndex > #FontList then
			FontIndex = 1
		end

		Config.Font = FontList[FontIndex]

		Refresh()
	end)

	Refresh()
end

local PrioritySection = CreateSection("Prioridade do alvo", 1)

CreateToggle(
	PrioritySection,
	"Prioridade ativa",
	function()
		return Config.PriorityEnabled
	end,
	function(Value)
		Config.PriorityEnabled = Value
	end,
	1
)

CreateToggle(
	PrioritySection,
	"Mais próximo",
	function()
		return Config.PrioritizeNearest
	end,
	function(Value)
		Config.PrioritizeNearest = Value
	end,
	2
)

CreateToggle(
	PrioritySection,
	"Priorizar inimigos",
	function()
		return Config.PrioritizeEnemies
	end,
	function(Value)
		Config.PrioritizeEnemies = Value
	end,
	3
)

CreateToggle(
	PrioritySection,
	"Somente dentro do raio",
	function()
		return Config.OnlyPriorityRange
	end,
	function(Value)
		Config.OnlyPriorityRange = Value
	end,
	4
)

CreateNumberBox(
	PrioritySection,
	"Raio de prioridade",
	function()
		return Config.PriorityStuds
	end,
	function(Value)
		Config.PriorityStuds = math.max(1, Value)
	end,
	5
)

CreateNumberBox(
	PrioritySection,
	"Distância máxima",
	function()
		return Config.MaxDistance
	end,
	function(Value)
		Config.MaxDistance = math.max(1, Value)
	end,
	6
)

local DamageSection = CreateSection("Damage Indicator", 2)

CreateToggle(
	DamageSection,
	"Mostrar dano",
	function()
		return Config.DamageEnabled
	end,
	function(Value)
		Config.DamageEnabled = Value
	end,
	1
)

CreateNumberBox(
	DamageSection,
	"Delay do dano",
	function()
		return Config.DamageDelay
	end,
	function(Value)
		Config.DamageDelay = math.max(0, Value)
	end,
	2
)

CreateNumberBox(
	DamageSection,
	"Duração",
	function()
		return Config.DamageDuration
	end,
	function(Value)
		Config.DamageDuration = math.max(0.05, Value)
	end,
	3
)

CreateNumberBox(
	DamageSection,
	"Altura",
	function()
		return Config.DamageRise
	end,
	function(Value)
		Config.DamageRise = math.max(0, Value)
	end,
	4
)

CreateNumberBox(
	DamageSection,
	"Tamanho do texto",
	function()
		return Config.TextSize
	end,
	function(Value)
		Config.TextSize = math.max(8, Value)
	end,
	5
)

CreateToggle(
	DamageSection,
	"Borda",
	function()
		return Config.StrokeEnabled
	end,
	function(Value)
		Config.StrokeEnabled = Value
	end,
	6
)

CreateNumberBox(
	DamageSection,
	"Transparência da borda",
	function()
		return Config.StrokeTransparency
	end,
	function(Value)
		Config.StrokeTransparency = math.clamp(Value, 0, 1)
	end,
	7
)

CreateNumberBox(
	DamageSection,
	"Espessura da borda",
	function()
		return Config.StrokeThickness
	end,
	function(Value)
		Config.StrokeThickness = math.max(0, Value)
	end,
	8
)

CreateToggle(
	DamageSection,
	"Posição aleatória",
	function()
		return Config.RandomPosition
	end,
	function(Value)
		Config.RandomPosition = Value
	end,
	9
)

CreateToggle(
	DamageSection,
	"Atravessar paredes",
	function()
		return Config.ThroughWalls
	end,
	function(Value)
		Config.ThroughWalls = Value
	end,
	10
)

CreateNumberBox(
	DamageSection,
	"Random X",
	function()
		return Config.RandomX
	end,
	function(Value)
		Config.RandomX = math.max(0, Value)
	end,
	11
)

CreateNumberBox(
	DamageSection,
	"Random Y",
	function()
		return Config.RandomY
	end,
	function(Value)
		Config.RandomY = math.max(0, Value)
	end,
	12
)

CreateNumberBox(
	DamageSection,
	"Random Z",
	function()
		return Config.RandomZ
	end,
	function(Value)
		Config.RandomZ = math.max(0, Value)
	end,
	13
)

CreateFontSelector(DamageSection, 14)

local PositionSection = CreateSection("Posição Mouse / FPS / MS", 3)

CreateNumberBox(
	PositionSection,
	"Damage Mouse X",
	function()
		return Config.MouseDamageOffsetX
	end,
	function(Value)
		Config.MouseDamageOffsetX = Value
	end,
	1
)

CreateNumberBox(
	PositionSection,
	"Damage Mouse Y",
	function()
		return Config.MouseDamageOffsetY
	end,
	function(Value)
		Config.MouseDamageOffsetY = Value
	end,
	2
)

CreateNumberBox(
	PositionSection,
	"FPS / MS X",
	function()
		return Config.PerformanceOffsetX
	end,
	function(Value)
		Config.PerformanceOffsetX = Value
	end,
	3
)

CreateNumberBox(
	PositionSection,
	"FPS / MS Y",
	function()
		return Config.PerformanceOffsetY
	end,
	function(Value)
		Config.PerformanceOffsetY = Value
	end,
	4
)

local TraceSection = CreateSection("Trace Player", 4)

CreateToggle(
	TraceSection,
	"Trace Player",
	function()
		return Config.TracePlayer
	end,
	function(Value)
		Config.TracePlayer = Value
	end,
	1
)

CreateToggle(
	TraceSection,
	"Trace Player Mouse",
	function()
		return Config.TracePlayerMouse
	end,
	function(Value)
		Config.TracePlayerMouse = Value
	end,
	2
)

CreateToggle(
	TraceSection,
	"Player morto = vermelho",
	function()
		return Config.TraceMouseDeadRed
	end,
	function(Value)
		Config.TraceMouseDeadRed = Value
	end,
	3
)

CreateNumberBox(
	TraceSection,
	"Comprimento",
	function()
		return Config.TraceLength
	end,
	function(Value)
		Config.TraceLength = math.max(1, Value)
	end,
	4
)

CreateNumberBox(
	TraceSection,
	"Espessura",
	function()
		return Config.TraceThickness
	end,
	function(Value)
		Config.TraceThickness = math.max(0.5, Value)
	end,
	5
)

local HealthSection = CreateSection("Health Players", 5)

CreateToggle(
	HealthSection,
	"Health Players",
	function()
		return Config.HealthPlayers
	end,
	function(Value)
		Config.HealthPlayers = Value
	end,
	1
)

CreateNumberBox(
	HealthSection,
	"Tamanho da vida",
	function()
		return Config.HealthTextSize
	end,
	function(Value)
		Config.HealthTextSize = math.max(8, Value)
	end,
	2
)

CreateNumberBox(
	HealthSection,
	"Distância máxima",
	function()
		return Config.HealthMaxDistance
	end,
	function(Value)
		Config.HealthMaxDistance = math.max(1, Value)
	end,
	3
)

local DeathSection = CreateSection("Death Indicator", 6)

CreateToggle(
	DeathSection,
	"Mostrar Dead",
	function()
		return Config.DeathEnabled
	end,
	function(Value)
		Config.DeathEnabled = Value
	end,
	1
)

CreateNumberBox(
	DeathSection,
	"Duração do Dead",
	function()
		return Config.DeathDuration
	end,
	function(Value)
		Config.DeathDuration = math.max(0.05, Value)
	end,
	2
)

CreateNumberBox(
	DeathSection,
	"Altura do Dead",
	function()
		return Config.DeathRise
	end,
	function(Value)
		Config.DeathRise = math.max(0, Value)
	end,
	3
)

CreateNumberBox(
	DeathSection,
	"Tamanho do Dead",
	function()
		return Config.DeathTextSize
	end,
	function(Value)
		Config.DeathTextSize = math.max(8, Value)
	end,
	4
)

local PerformanceSection = CreateSection("FPS / MS / Mouse", 7)

CreateToggle(
	PerformanceSection,
	"Damage no mouse",
	function()
		return Config.MouseDamage
	end,
	function(Value)
		Config.MouseDamage = Value
	end,
	1
)

CreateToggle(
	PerformanceSection,
	"Mostrar FPS",
	function()
		return Config.ShowFPS
	end,
	function(Value)
		Config.ShowFPS = Value
	end,
	2
)

CreateToggle(
	PerformanceSection,
	"Mostrar MS",
	function()
		return Config.ShowMS
	end,
	function(Value)
		Config.ShowMS = Value
	end,
	3
)

local PerformanceLabel = Instance.new("TextLabel")
PerformanceLabel.Name = "Performance"
PerformanceLabel.Size = UDim2.fromOffset(200, 30)
PerformanceLabel.BackgroundTransparency = 1
PerformanceLabel.TextColor3 = Color3.new(1, 1, 1)
PerformanceLabel.TextSize = 13
PerformanceLabel.Font = Enum.Font.GothamBold
PerformanceLabel.TextXAlignment = Enum.TextXAlignment.Left
PerformanceLabel.Visible = false
PerformanceLabel.Parent = ScreenGui

local function GetRoot(Player)
	local Character = Player.Character

	if not Character then
		return nil
	end

	return Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(Player)
	local Character = Player.Character

	if not Character then
		return nil
	end

	return Character:FindFirstChildOfClass("Humanoid")
end

local function IsEnemy(Player)
	if not Player or Player == LocalPlayer then
		return false
	end

	if not LocalPlayer.Team or not Player.Team then
		return true
	end

	return Player.Team ~= LocalPlayer.Team
end

local function GetNearestTarget()
	local LocalRoot = GetRoot(LocalPlayer)

	if not LocalRoot then
		return nil
	end

	local PriorityCandidates = {}
	local EnemyCandidates = {}
	local NormalCandidates = {}

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer then
			local Root = GetRoot(Player)
			local Humanoid = GetHumanoid(Player)

			if Root and Humanoid and Humanoid.Health > 0 then
				local Distance =
					(Root.Position - LocalRoot.Position).Magnitude

				if Distance <= Config.MaxDistance then
					local Candidate = {
						Player = Player,
						Distance = Distance,
						Enemy = IsEnemy(Player)
					}

					if Config.PriorityEnabled
						and Distance <= Config.PriorityStuds then

						table.insert(PriorityCandidates, Candidate)
					elseif not Config.OnlyPriorityRange then
						if Candidate.Enemy then
							table.insert(EnemyCandidates, Candidate)
						else
							table.insert(NormalCandidates, Candidate)
						end
					end
				end
			end
		end
	end

	local function SortDistance(List)
		table.sort(List, function(A, B)
			return A.Distance < B.Distance
		end)

		return List
	end

	if Config.PriorityEnabled and #PriorityCandidates > 0 then
		if Config.PrioritizeEnemies then
			local EnemyPriority = {}

			for _, Candidate in ipairs(PriorityCandidates) do
				if Candidate.Enemy then
					table.insert(EnemyPriority, Candidate)
				end
			end

			if #EnemyPriority > 0 then
				SortDistance(EnemyPriority)

				return EnemyPriority[1].Player
			end
		end

		SortDistance(PriorityCandidates)

		return PriorityCandidates[1].Player
	end

	if Config.OnlyPriorityRange then
		return nil
	end

	if Config.PrioritizeEnemies and #EnemyCandidates > 0 then
		SortDistance(EnemyCandidates)

		return EnemyCandidates[1].Player
	end

	if #NormalCandidates > 0 then
		SortDistance(NormalCandidates)

		return NormalCandidates[1].Player
	end

	return nil
end

local function NormalizeDamage(OldHealth, NewHealth)
	if typeof(OldHealth) ~= "number"
		or typeof(NewHealth) ~= "number" then
		return nil
	end

	if OldHealth ~= OldHealth or NewHealth ~= NewHealth then
		return nil
	end

	if math.abs(OldHealth) > 1000000
		or math.abs(NewHealth) > 1000000 then
		return nil
	end

	if NewHealth >= OldHealth then
		return nil
	end

	local Damage = OldHealth - NewHealth

	if Damage <= 0 then
		return nil
	end

	Damage = math.min(Damage, OldHealth)

	if Damage <= 0 or Damage > 1000000 then
		return nil
	end

	Damage = math.floor(Damage * 100 + 0.5) / 100

	if Damage == 0 then
		return nil
	end

	return Damage
end

local function FormatDamage(Damage)
	if Damage == nil then
		return nil
	end

	Damage = math.floor(Damage * 100 + 0.5) / 100

	if Damage % 1 == 0 then
		return string.format("%d", Damage)
	end

	return string.format("%.2f", Damage):gsub("0+$", ""):gsub("%.$", "")
end

local function CreateIndicator(Player, Damage)
	if not Config.DamageEnabled then
		return
	end

	local Root = GetRoot(Player)

	if not Root then
		return
	end

	local DamageText = FormatDamage(Damage)

	if not DamageText then
		return
	end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "DamageIndicator"
	Billboard.Adornee = Root
	Billboard.AlwaysOnTop = Config.ThroughWalls
	Billboard.Size = UDim2.fromOffset(150, 60)

	local OffsetX = 0
	local OffsetY = 2
	local OffsetZ = 0

	if Config.RandomPosition then
		OffsetX =
			math.random(-100, 100)
			/ 100
			* Config.RandomX

		OffsetY =
			2
			+ math.random(-100, 100)
			/ 100
			* Config.RandomY

		OffsetZ =
			math.random(-100, 100)
			/ 100
			* Config.RandomZ
	end

	Billboard.StudsOffset = Vector3.new(
		OffsetX,
		OffsetY,
		OffsetZ
	)

	Billboard.Parent = ScreenGui

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.fromScale(1, 1)
	Label.BackgroundTransparency = 1
	Label.Text = "-" .. DamageText
	Label.TextColor3 = Config.TextColor
	Label.TextTransparency = Config.TextTransparency
	Label.TextSize = Config.TextSize
	Label.Font = Config.Font
	Label.TextStrokeColor3 = Config.StrokeColor
	Label.TextStrokeTransparency =
		Config.StrokeEnabled
		and Config.StrokeTransparency
		or 1
	Label.Parent = Billboard

	local StartOffset = Billboard.StudsOffset

	task.delay(Config.DamageDelay, function()
		if not Billboard.Parent then
			return
		end

		local Info = TweenInfo.new(
			Config.DamageDuration,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)

		local PositionTween = TweenService:Create(
			Billboard,
			Info,
			{
				StudsOffset =
					StartOffset
					+ Vector3.new(0, Config.DamageRise, 0)
			}
		)

		local TextTween = TweenService:Create(
			Label,
			Info,
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)

		PositionTween:Play()
		TextTween:Play()

		PositionTween.Completed:Once(function()
			if Billboard then
				Billboard:Destroy()
			end
		end)
	end)
end

local function CreateMouseDamage(Damage)
	if not Config.MouseDamage then
		return
	end

	local DamageText = FormatDamage(Damage)

	if not DamageText then
		return
	end

	local Label = Instance.new("TextLabel")
	Label.Name = "MouseDamage"
	Label.Size = UDim2.fromOffset(120, 45)
	Label.BackgroundTransparency = 1
	Label.Text = "-" .. DamageText
	Label.TextColor3 = Config.TextColor
	Label.TextSize = Config.TextSize
	Label.Font = Config.Font
	Label.TextStrokeColor3 = Config.StrokeColor
	Label.TextStrokeTransparency =
		Config.StrokeEnabled
		and Config.StrokeTransparency
		or 1

	Label.Position = UDim2.fromOffset(
		MousePosition.X + Config.MouseDamageOffsetX,
		MousePosition.Y + Config.MouseDamageOffsetY
	)

	Label.Parent = ScreenGui

	local Start = Label.Position

	local Tween = TweenService:Create(
		Label,
		TweenInfo.new(
			Config.DamageDuration,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Position = UDim2.fromOffset(
				Start.X.Offset,
				Start.Y.Offset - 35
			),
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}
	)

	Tween:Play()

	Tween.Completed:Once(function()
		Label:Destroy()
	end)
end

local function CreateDeathIndicator(Player)
	if not Config.DeathEnabled then
		return
	end

	local Root = GetRoot(Player)

	if not Root then
		return
	end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "DeathIndicator"
	Billboard.Adornee = Root
	Billboard.AlwaysOnTop = Config.ThroughWalls
	Billboard.Size = UDim2.fromOffset(160, 60)
	Billboard.StudsOffset = Vector3.new(0, 2, 0)
	Billboard.Parent = ScreenGui

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.fromScale(1, 1)
	Label.BackgroundTransparency = 1
	Label.Text = Config.DeathText
	Label.TextColor3 = Config.DeathTextColor
	Label.TextSize = Config.DeathTextSize
	Label.Font = Enum.Font.GothamBlack
	Label.TextStrokeColor3 = Config.DeathStrokeColor
	Label.TextStrokeTransparency =
		Config.DeathStrokeEnabled
		and Config.DeathStrokeTransparency
		or 1
	Label.Parent = Billboard

	local Info = TweenInfo.new(
		Config.DeathDuration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local MoveTween = TweenService:Create(
		Billboard,
		Info,
		{
			StudsOffset =
				Vector3.new(
					0,
					2 + Config.DeathRise,
					0
				)
		}
	)

	local FadeTween = TweenService:Create(
		Label,
		Info,
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}
	)

	MoveTween:Play()
	FadeTween:Play()

	MoveTween.Completed:Once(function()
		Billboard:Destroy()
	end)
end

local function RemoveHealthLabel(Player)
	local Label = HealthLabels[Player]

	if Label then
		Label:Destroy()
		HealthLabels[Player] = nil
	end
end

local function CreateHealthLabel(Player)
	if HealthLabels[Player] then
		return HealthLabels[Player]
	end

	local Root = GetRoot(Player)

	if not Root then
		return nil
	end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "HealthPlayer"
	Billboard.Adornee = Root
	Billboard.Size = UDim2.fromOffset(120, 35)
	Billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	Billboard.AlwaysOnTop = Config.ThroughWalls
	Billboard.Parent = ScreenGui

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.fromScale(1, 1)
	Label.BackgroundTransparency = 1
	Label.Text = "100%"
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.TextStrokeColor3 = Color3.new(0, 0, 0)
	Label.TextStrokeTransparency = 0.2
	Label.TextSize = Config.HealthTextSize
	Label.Font = Enum.Font.GothamBold
	Label.Parent = Billboard

	HealthLabels[Player] = Billboard

	return Billboard
end

local function UpdateHealthPlayer(Player)
	if not Config.HealthPlayers then
		RemoveHealthLabel(Player)
		return
	end

	local Root = GetRoot(Player)
	local Humanoid = GetHumanoid(Player)
	local LocalRoot = GetRoot(LocalPlayer)

	if not Root or not Humanoid or not LocalRoot then
		RemoveHealthLabel(Player)
		return
	end

	local Distance =
		(Root.Position - LocalRoot.Position).Magnitude

	if Distance > Config.HealthMaxDistance then
		if HealthLabels[Player] then
			HealthLabels[Player].Enabled = false
		end

		return
	end

	local Billboard = CreateHealthLabel(Player)

	if not Billboard then
		return
	end

	Billboard.Enabled = true
	Billboard.AlwaysOnTop = Config.ThroughWalls

	local Label = Billboard:FindFirstChildOfClass("TextLabel")

	if not Label then
		return
	end

	local MaxHealth = math.max(Humanoid.MaxHealth, 1)

	local Percentage =
		math.clamp(
			(Humanoid.Health / MaxHealth) * 100,
			0,
			100
		)

	Label.Text =
		string.format(
			"%d%%",
			math.floor(Percentage + 0.5)
		)

	Label.TextSize = Config.HealthTextSize

	if Percentage <= 25 then
		Label.TextColor3 =
			Color3.fromRGB(255, 60, 60)
	elseif Percentage <= 50 then
		Label.TextColor3 =
			Color3.fromRGB(255, 200, 60)
	else
		Label.TextColor3 =
			Color3.fromRGB(255, 255, 255)
	end
end

local function RemovePlayerTrace(Player)
	local Data = PlayerTraces[Player]

	if not Data then
		return
	end

	if Data.Line then
		Data.Line:Remove()
	end

	PlayerTraces[Player] = nil
end

local function GetPlayerTrace(Player)
	if not DrawingAvailable then
		return nil
	end

	if PlayerTraces[Player] then
		return PlayerTraces[Player]
	end

	local Line = Drawing.new("Line")

	Line.Visible = false
	Line.Color = Color3.fromRGB(50, 255, 90)
	Line.Thickness = Config.TraceThickness
	Line.Transparency = 1

	PlayerTraces[Player] = {
		Line = Line
	}

	return PlayerTraces[Player]
end

local function UpdatePlayerTrace(Player)
	if not DrawingAvailable then
		return
	end

	local Data = PlayerTraces[Player]

	if not Config.TracePlayer then
		if Data and Data.Line then
			Data.Line.Visible = false
		end

		return
	end

	local Character = Player.Character

	if not Character then
		return
	end

	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Head = Character:FindFirstChild("Head")
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if not Root
		or not Head
		or not Humanoid
		or Humanoid.Health <= 0 then

		if Data and Data.Line then
			Data.Line.Visible = false
		end

		return
	end

	local Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local StartWorld = Head.Position
	local EndWorld =
		StartWorld
		+ Root.CFrame.LookVector * Config.TraceLength

	local StartPosition, StartVisible =
		Camera:WorldToViewportPoint(StartWorld)

	local EndPosition, EndVisible =
		Camera:WorldToViewportPoint(EndWorld)

	Data = GetPlayerTrace(Player)

	if not Data then
		return
	end

	local Line = Data.Line

	Line.From = Vector2.new(
		StartPosition.X,
		StartPosition.Y
	)

	Line.To = Vector2.new(
		EndPosition.X,
		EndPosition.Y
	)

	Line.Color = Color3.fromRGB(50, 255, 90)
	Line.Thickness = Config.TraceThickness
	Line.Visible = StartVisible or EndVisible
end

local function CreateMouseTrace()
	if not DrawingAvailable or MouseTrace then
		return
	end

	MouseTrace = Drawing.new("Line")

	MouseTrace.Visible = false
	MouseTrace.Color = Color3.fromRGB(50, 255, 90)
	MouseTrace.Thickness = Config.TraceThickness
	MouseTrace.Transparency = 1
end

local function UpdateMouseTrace()
	if not DrawingAvailable then
		return
	end

	if not Config.TracePlayerMouse then
		if MouseTrace then
			MouseTrace.Visible = false
		end

		return
	end

	CreateMouseTrace()

	if not MouseTrace then
		return
	end

	local Target = CurrentTarget

	if not Target then
		MouseTrace.Visible = false
		return
	end

	local Root = GetRoot(Target)
	local Humanoid = GetHumanoid(Target)
	local Camera = workspace.CurrentCamera

	if not Root or not Humanoid or not Camera then
		MouseTrace.Visible = false
		return
	end

	local TargetPosition, Visible =
		Camera:WorldToViewportPoint(Root.Position)

	if not Visible then
		MouseTrace.Visible = false
		return
	end

	MouseTrace.From = MousePosition

	MouseTrace.To = Vector2.new(
		TargetPosition.X,
		TargetPosition.Y
	)

	if Humanoid.Health <= 0
		and Config.TraceMouseDeadRed then

		MouseTrace.Color =
			Color3.fromRGB(255, 45, 45)
	else
		MouseTrace.Color =
			Color3.fromRGB(50, 255, 90)
	end

	MouseTrace.Thickness = Config.TraceThickness
	MouseTrace.Visible = true
end

local function TrackPlayer(Player)
	if Player == LocalPlayer or Tracked[Player] then
		return
	end

	Tracked[Player] = true

	local function TrackCharacter(Character)
		local Humanoid =
			Character:WaitForChild("Humanoid", 5)

		if not Humanoid then
			return
		end

		local LastHealth = Humanoid.Health
		local DeadShown = false

		local HealthConnection =
			Humanoid.HealthChanged:Connect(function(NewHealth)

				local Damage =
					NormalizeDamage(
						LastHealth,
						NewHealth
					)

				if Damage then
					local Root = GetRoot(Player)
					local LocalRoot = GetRoot(LocalPlayer)

					if Root and LocalRoot then
						local Distance =
							(Root.Position - LocalRoot.Position).Magnitude

						local Allowed

						if Config.PriorityEnabled
							and Config.OnlyPriorityRange then

							Allowed =
								Distance <= Config.PriorityStuds
						else
							Allowed =
								Distance <= Config.MaxDistance
						end

						if Allowed then
							CreateIndicator(
								Player,
								Damage
							)

							if CurrentTarget == Player then
								CreateMouseDamage(Damage)
							end
						end
					end
				end

				if NewHealth <= 0 and not DeadShown then
					DeadShown = true
					CreateDeathIndicator(Player)
				end

				if typeof(NewHealth) == "number"
					and NewHealth == NewHealth then

					LastHealth = NewHealth
				end
			end)

		table.insert(
			Connections,
			HealthConnection
		)

		table.insert(
			Connections,
			Humanoid.Died:Connect(function()
				if not DeadShown then
					DeadShown = true
					CreateDeathIndicator(Player)
				end
			end)
		)
	end

	if Player.Character then
		task.spawn(
			TrackCharacter,
			Player.Character
		)
	end

	table.insert(
		Connections,
		Player.CharacterAdded:Connect(function(Character)
			task.spawn(
				TrackCharacter,
				Character
			)
		end)
	)
end

for _, Player in ipairs(Players:GetPlayers()) do
	TrackPlayer(Player)
end

table.insert(
	Connections,
	Players.PlayerAdded:Connect(TrackPlayer)
)

table.insert(
	Connections,
	Players.PlayerRemoving:Connect(function(Player)
		RemovePlayerTrace(Player)
		RemoveHealthLabel(Player)
		Tracked[Player] = nil
	end)
)

table.insert(
	Connections,
	UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			MousePosition =
				UserInputService:GetMouseLocation()

		elseif Input.UserInputType == Enum.UserInputType.Touch then
			LastTouchPosition = Input.Position
			MousePosition = LastTouchPosition
		end
	end)
)

table.insert(
	Connections,
	RunService.Heartbeat:Connect(function()
		local Now = os.clock()

		if Now - LastTargetUpdate >= Config.UpdateRate then
			LastTargetUpdate = Now
			CurrentTarget = GetNearestTarget()
		end
	end)
)

table.insert(
	Connections,
	RunService.RenderStepped:Connect(function()
		Frames += 1

		local Now = os.clock()

		if Now - LastFPSUpdate >= 1 then
			FPS = Frames
			Frames = 0
			LastFPSUpdate = Now
		end

		if Config.ShowFPS or Config.ShowMS then
			PerformanceLabel.Visible = true

			local Parts = {}

			if Config.ShowFPS then
				table.insert(
					Parts,
					"FPS: " .. tostring(FPS)
				)
			end

			if Config.ShowMS then
				local Ping = 0

				pcall(function()
					Ping =
						Stats.Network
						.ServerStatsItem["Data Ping"]
						:GetValue()
				end)

				table.insert(
					Parts,
					"Ms: "
					.. tostring(math.floor(Ping))
				)
			end

			PerformanceLabel.Text =
				table.concat(Parts, " | ")

			PerformanceLabel.Position =
				UDim2.fromOffset(
					MousePosition.X
					+ Config.PerformanceOffsetX,
					MousePosition.Y
					+ Config.PerformanceOffsetY
				)
		else
			PerformanceLabel.Visible = false
		end

		for _, Player in ipairs(Players:GetPlayers()) do
			if Player ~= LocalPlayer then
				UpdatePlayerTrace(Player)
				UpdateHealthPlayer(Player)
			end
		end

		UpdateMouseTrace()
	end)
)

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position
	end
end)

Header.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then

		Dragging = false
	end
end)

table.insert(
	Connections,
	UserInputService.InputChanged:Connect(function(Input)
		if not Dragging then
			return
		end

		if Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local Delta =
			Input.Position - DragStart

		Main.Position =
			UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,
				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			)
	end)
)

Close.MouseButton1Click:Connect(function()
	Main.Visible = false
	OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
	Main.Visible = true
	OpenButton.Visible = false
end)

local function Cleanup()
	for _, Connection in ipairs(Connections) do
		if Connection then
			Connection:Disconnect()
		end
	end

	table.clear(Connections)

	for _, Data in pairs(PlayerTraces) do
		if Data.Line then
			Data.Line:Remove()
		end
	end

	table.clear(PlayerTraces)

	if MouseTrace then
		MouseTrace:Remove()
		MouseTrace = nil
	end

	for _, Label in pairs(HealthLabels) do
		if Label then
			Label:Destroy()
		end
	end

	table.clear(HealthLabels)

	if ScreenGui then
		ScreenGui:Destroy()
	end
end

script.Destroying:Connect(Cleanup)
