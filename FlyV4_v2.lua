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
	MouseOffsetX = 22,
	MouseOffsetY = 0,

	ShowFPS = false,
	ShowMS = false,
	PerformanceOffsetX = 22,
	PerformanceOffsetY = 20,

	DeathEnabled = true,
	DeathText = "Dead",
	DeathDuration = 1.1,
	DeathRise = 3,
	DeathTextSize = 25,
	DeathTextColor = Color3.fromRGB(35, 35, 35),
	DeathStrokeEnabled = true,
	DeathStrokeColor = Color3.fromRGB(220, 220, 220),
	DeathStrokeTransparency = 0.25,

	UpdateRate = 0.025
}

local Connections = {}
local Tracked = {}
local CurrentTarget = nil

local LastTouchPosition = Vector2.new(400, 300)
local MousePosition = Vector2.new(0, 0)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DamageIndicator"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(330, 460)
Main.Position = UDim2.new(0.5, -165, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Main.BorderSizePixel = 0
Main.Visible = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -50, 0, 45)
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
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
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
		Button.Text = "  " .. Name .. "  [" .. (State and "ON" or "OFF") .. "]"
		Button.TextColor3 = State
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
		local Value = tonumber(Box.Text:match(":%s*(%-?[%d%.]+)"))

		if Value then
			Setter(Value)
		end

		Box.Text = "  " .. Name .. ": " .. tostring(Getter())
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
		Button.Text = "  Fonte: " .. tostring(FontList[FontIndex]):gsub("Enum.Font.", "")
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
	"Raio de prioridade (Studs)",
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

local DeathSection = CreateSection("Death Indicator", 3)

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

local PerformanceSection = CreateSection("FPS / MS / Mouse", 4)

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
PerformanceLabel.Size = UDim2.fromOffset(150, 30)
PerformanceLabel.BackgroundTransparency = 1
PerformanceLabel.TextColor3 = Color3.new(1, 1, 1)
PerformanceLabel.TextSize = 13
PerformanceLabel.Font = Enum.Font.GothamBold
PerformanceLabel.TextXAlignment = Enum.TextXAlignment.Left
PerformanceLabel.Visible = false
PerformanceLabel.Parent = ScreenGui

local function IsEnemy(Player)
	if not Player then
		return false
	end

	if not LocalPlayer.Team or not Player.Team then
		return true
	end

	return Player.Team ~= LocalPlayer.Team
end

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

local function GetNearestTarget()
	local Character = LocalPlayer.Character

	if not Character then
		return nil
	end

	local LocalRoot = Character:FindFirstChild("HumanoidRootPart")

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
				local Distance = (Root.Position - LocalRoot.Position).Magnitude

				if Distance <= Config.MaxDistance then
					local Candidate = {
						Player = Player,
						Root = Root,
						Distance = Distance,
						Enemy = IsEnemy(Player)
					}

					if Config.PriorityEnabled and Distance <= Config.PriorityStuds then
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

	local function SortByDistance(List)
		table.sort(List, function(A, B)
			return A.Distance < B.Distance
		end)

		return List
	end

	if Config.PriorityEnabled and #PriorityCandidates > 0 then
		if Config.PrioritizeEnemies then
			local PriorityEnemies = {}

			for _, Candidate in ipairs(PriorityCandidates) do
				if Candidate.Enemy then
					table.insert(PriorityEnemies, Candidate)
				end
			end

			if #PriorityEnemies > 0 then
				return SortByDistance(PriorityEnemies)[1].Player
			end
		end

		return SortByDistance(PriorityCandidates)[1].Player
	end

	if Config.OnlyPriorityRange then
		return nil
	end

	if Config.PrioritizeEnemies and #EnemyCandidates > 0 then
		return SortByDistance(EnemyCandidates)[1].Player
	end

	if #NormalCandidates > 0 then
		return SortByDistance(NormalCandidates)[1].Player
	end

	return nil
end

local function CreateIndicator(Player, Amount)
	if not Config.DamageEnabled then
		return
	end

	local Root = GetRoot(Player)

	if not Root then
		return
	end

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "Damage_" .. Player.UserId
	Billboard.Adornee = Root
	Billboard.AlwaysOnTop = Config.ThroughWalls
	Billboard.Size = UDim2.fromOffset(150, 60)
	Billboard.StudsOffset = Vector3.new(
		Config.RandomPosition and math.random(-100, 100) / 100 * Config.RandomX or 0,
		Config.RandomPosition and math.random(-100, 100) / 100 * Config.RandomY + 2 or 2,
		Config.RandomPosition and math.random(-100, 100) / 100 * Config.RandomZ or 0
	)
	Billboard.Parent = ScreenGui

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.fromScale(1, 1)
	Label.BackgroundTransparency = 1
	Label.Text = "-" .. tostring(Amount)
	Label.TextColor3 = Config.TextColor
	Label.TextTransparency = Config.TextTransparency
	Label.TextSize = Config.TextSize
	Label.Font = Config.Font
	Label.TextStrokeTransparency = Config.StrokeEnabled and Config.StrokeTransparency or 1
	Label.TextStrokeColor3 = Config.StrokeColor
	Label.TextStrokeTransparency = Config.StrokeEnabled and Config.StrokeTransparency or 1
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

		local Tween = TweenService:Create(
			Billboard,
			Info,
			{
				StudsOffset = StartOffset + Vector3.new(0, Config.DamageRise, 0)
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

		Tween:Play()
		TextTween:Play()

		Tween.Completed:Once(function()
			Billboard:Destroy()
		end)
	end)
end

local function CreateMouseDamage(Amount)
	if not Config.MouseDamage then
		return
	end

	local Label = Instance.new("TextLabel")
	Label.Name = "MouseDamage"
	Label.Size = UDim2.fromOffset(120, 45)
	Label.BackgroundTransparency = 1
	Label.Text = "-" .. tostring(Amount)
	Label.TextColor3 = Config.TextColor
	Label.TextSize = Config.TextSize
	Label.Font = Config.Font
	Label.TextStrokeColor3 = Config.StrokeColor
	Label.TextStrokeTransparency = Config.StrokeEnabled and Config.StrokeTransparency or 1
	Label.Position = UDim2.fromOffset(
		MousePosition.X + Config.MouseOffsetX,
		MousePosition.Y + Config.MouseOffsetY
	)
	Label.Parent = ScreenGui

	local StartPosition = Label.Position

	local Tween = TweenService:Create(
		Label,
		TweenInfo.new(Config.DamageDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Position = UDim2.fromOffset(
				StartPosition.X,
				StartPosition.Y - 35
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
	Label.TextStrokeTransparency = Config.DeathStrokeEnabled
		and Config.DeathStrokeTransparency
		or 1
	Label.Parent = Billboard

	local TweenInfoData = TweenInfo.new(
		Config.DeathDuration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local PositionTween = TweenService:Create(
		Billboard,
		TweenInfoData,
		{
			StudsOffset = Vector3.new(0, 2 + Config.DeathRise, 0)
		}
	)

	local TextTween = TweenService:Create(
		Label,
		TweenInfoData,
		{
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}
	)

	PositionTween:Play()
	TextTween:Play()

	PositionTween.Completed:Once(function()
		Billboard:Destroy()
	end)
end

local function TrackPlayer(Player)
	if Player == LocalPlayer or Tracked[Player] then
		return
	end

	Tracked[Player] = true

	local function TrackCharacter(Character)
		local Humanoid = Character:WaitForChild("Humanoid", 5)

		if not Humanoid then
			return
		end

		local LastHealth = Humanoid.Health
		local DeadShown = false

		local HealthConnection = Humanoid.HealthChanged:Connect(function(NewHealth)
			if NewHealth < LastHealth then
				local Damage = LastHealth - NewHealth

				if Damage > 0 then
					local Root = GetRoot(Player)

					if Root and LocalPlayer.Character then
						local LocalRoot = GetRoot(LocalPlayer)

						if LocalRoot then
							local Distance = (Root.Position - LocalRoot.Position).Magnitude

							local Allowed = true

							if Config.PriorityEnabled and Config.OnlyPriorityRange then
								Allowed = Distance <= Config.PriorityStuds
							else
								Allowed = Distance <= Config.MaxDistance
							end

							if Allowed then
								CreateIndicator(Player, Damage)

								if CurrentTarget == Player then
									CreateMouseDamage(Damage)
								end
							end
						end
					end
				end
			end

			if NewHealth <= 0 and not DeadShown then
				DeadShown = true
				CreateDeathIndicator(Player)
			end

			LastHealth = NewHealth
		end)

		table.insert(Connections, HealthConnection)
	end

	if Player.Character then
		task.spawn(TrackCharacter, Player.Character)
	end

	table.insert(
		Connections,
		Player.CharacterAdded:Connect(function(Character)
			task.spawn(TrackCharacter, Character)
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

local LastTargetUpdate = 0

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

local FPS = 0
local Frames = 0
local LastFPSUpdate = os.clock()

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
				table.insert(Parts, "FPS: " .. tostring(FPS))
			end

			if Config.ShowMS then
				local Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
				table.insert(Parts, "Ms: " .. tostring(math.floor(Ping)))
			end

			PerformanceLabel.Text = table.concat(Parts, " | ")

			PerformanceLabel.Position = UDim2.fromOffset(
				MousePosition.X + Config.PerformanceOffsetX,
				MousePosition.Y + Config.PerformanceOffsetY
			)
		else
			PerformanceLabel.Visible = false
		end
	end)
)

table.insert(
	Connections,
	UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			MousePosition = UserInputService:GetMouseLocation()
		elseif Input.UserInputType == Enum.UserInputType.Touch then
			LastTouchPosition = Input.Position
			MousePosition = LastTouchPosition
		end
	end)
)

MousePosition = UserInputService:GetMouseLocation()

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

		local Delta = Input.Position - DragStart

		Main.Position = UDim2.new(
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
	table.clear(Tracked)

	if ScreenGui then
		ScreenGui:Destroy()
	end
end

script.Destroying:Connect(Cleanup)
