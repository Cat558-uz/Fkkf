local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
	DamageFollowMouse = true,
	DamageDelay = 0.03,
	DamageDuration = 0.8,
	DamageRise = 35,

	TextSize = 24,
	Font = Enum.Font.GothamBold,
	TextColor = Color3.fromRGB(255, 45, 45),
	TextTransparency = 0,

	StrokeEnabled = true,
	StrokeColor = Color3.fromRGB(255, 150, 150),
	StrokeTransparency = 0.2,
	StrokeThickness = 1,

	RandomPosition = true,
	RandomX = 35,
	RandomY = 15,

	ThroughWalls = false,

	MouseOffsetX = 20,
	MouseOffsetY = 0,

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
	DeathRise = 45,
	DeathTextSize = 25,

	SmallDamageEnabled = true,
	SmallDamageMinimum = 0
}

local Connections = {}
local CharacterConnections = {}
local TrackedPlayers = {}

local HealthLabels = {}
local PlayerTraces = {}

local CurrentTarget = nil
local MouseTrace = nil

local MousePosition = UserInputService:GetMouseLocation()

local FPS = 0
local FrameCount = 0
local LastFPSUpdate = os.clock()
local LastTargetUpdate = 0

local DrawingAvailable = false

pcall(function()
	DrawingAvailable =
		typeof(Drawing) == "table"
		and typeof(Drawing.new) == "function"
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DamageIndicator_New"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(350, 560)
Main.Position = UDim2.new(0.5, -175, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(19, 19, 23)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 13)
MainCorner.Parent = Main

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -60, 0, 45)
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
Close.BorderSizePixel = 0
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
OpenButton.BorderSizePixel = 0
OpenButton.Text = "⚙"
OpenButton.TextSize = 20
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 10)
OpenCorner.Parent = OpenButton

local Sections = Instance.new("ScrollingFrame")
Sections.Size = UDim2.new(1, -20, 1, -55)
Sections.Position = UDim2.fromOffset(10, 50)
Sections.BackgroundTransparency = 1
Sections.BorderSizePixel = 0
Sections.ScrollBarThickness = 3
Sections.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sections.CanvasSize = UDim2.new()
Sections.Parent = Main

local SectionLayout = Instance.new("UIListLayout")
SectionLayout.Padding = UDim.new(0, 8)
SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
SectionLayout.Parent = Sections

local function CreateSection(Name, Order)
	local Section = Instance.new("Frame")
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
	Title.Size = UDim2.new(1, 0, 0, 25)
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
	Button.Size = UDim2.new(1, 0, 0, 31)
	Button.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
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
			.. " ["
			.. (State and "ON" or "OFF")
			.. "]"

		Button.TextColor3 =
			State
			and Color3.fromRGB(100, 255, 145)
			or Color3.fromRGB(180, 180, 180)
	end

	Button.MouseButton1Click:Connect(function()
		Setter(not Getter())
		Refresh()
	end)

	Refresh()
end

local function CreateNumberBox(Parent, Name, Getter, Setter, Order)
	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(1, 0, 0, 31)
	Box.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
	Box.BorderSizePixel = 0
	Box.TextSize = 12
	Box.Font = Enum.Font.GothamMedium
	Box.TextColor3 = Color3.new(1, 1, 1)
	Box.TextXAlignment = Enum.TextXAlignment.Left
	Box.ClearTextOnFocus = false
	Box.LayoutOrder = Order
	Box.Text = "  " .. Name .. ": " .. tostring(Getter())
	Box.Parent = Parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Box

	Box.FocusLost:Connect(function()
		local Number =
			Box.Text:match(":%s*([%-]?[%d%.]+)")

		local Value = tonumber(Number)

		if Value
			and Value == Value
			and Value ~= math.huge
			and Value ~= -math.huge then

			Setter(Value)
		end

		Box.Text =
			"  "
			.. Name
			.. ": "
			.. tostring(Getter())
	end)
end

local PrioritySection =
	CreateSection("Target Priority", 1)

CreateToggle(
	PrioritySection,
	"Priority",
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
	"Nearest",
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
	"Prioritize Enemies",
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
	"Only Priority Range",
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
	"Priority Studs",
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
	"Max Distance",
	function()
		return Config.MaxDistance
	end,
	function(Value)
		Config.MaxDistance = math.max(1, Value)
	end,
	6
)

local DamageSection =
	CreateSection("Damage", 2)

CreateToggle(
	DamageSection,
	"Damage Indicator",
	function()
		return Config.DamageEnabled
	end,
	function(Value)
		Config.DamageEnabled = Value
	end,
	1
)

CreateToggle(
	DamageSection,
	"Damage Follow Mouse",
	function()
		return Config.DamageFollowMouse
	end,
	function(Value)
		Config.DamageFollowMouse = Value
	end,
	2
)

CreateToggle(
	DamageSection,
	"Small Damage",
	function()
		return Config.SmallDamageEnabled
	end,
	function(Value)
		Config.SmallDamageEnabled = Value
	end,
	3
)

CreateToggle(
	DamageSection,
	"Random Position",
	function()
		return Config.RandomPosition
	end,
	function(Value)
		Config.RandomPosition = Value
	end,
	4
)

CreateToggle(
	DamageSection,
	"Through Walls",
	function()
		return Config.ThroughWalls
	end,
	function(Value)
		Config.ThroughWalls = Value
	end,
	5
)

CreateToggle(
	DamageSection,
	"Border",
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
	"Text Size",
	function()
		return Config.TextSize
	end,
	function(Value)
		Config.TextSize = math.max(8, Value)
	end,
	7
)

CreateNumberBox(
	DamageSection,
	"Damage Delay",
	function()
		return Config.DamageDelay
	end,
	function(Value)
		Config.DamageDelay = math.max(0, Value)
	end,
	8
)

CreateNumberBox(
	DamageSection,
	"Duration",
	function()
		return Config.DamageDuration
	end,
	function(Value)
		Config.DamageDuration = math.max(0.05, Value)
	end,
	9
)

CreateNumberBox(
	DamageSection,
	"Rise",
	function()
		return Config.DamageRise
	end,
	function(Value)
		Config.DamageRise = math.max(0, Value)
	end,
	10
)

CreateNumberBox(
	DamageSection,
	"Mouse X",
	function()
		return Config.MouseOffsetX
	end,
	function(Value)
		Config.MouseOffsetX = Value
	end,
	11
)

CreateNumberBox(
	DamageSection,
	"Mouse Y",
	function()
		return Config.MouseOffsetY
	end,
	function(Value)
		Config.MouseOffsetY = Value
	end,
	12
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
	13
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
	14
)

CreateNumberBox(
	DamageSection,
	"Border Transparency",
	function()
		return Config.StrokeTransparency
	end,
	function(Value)
		Config.StrokeTransparency =
			math.clamp(Value, 0, 1)
	end,
	15
)

local MouseSection =
	CreateSection("Mouse / Performance", 3)

CreateToggle(
	MouseSection,
	"FPS",
	function()
		return Config.ShowFPS
	end,
	function(Value)
		Config.ShowFPS = Value
	end,
	1
)

CreateToggle(
	MouseSection,
	"MS",
	function()
		return Config.ShowMS
	end,
	function(Value)
		Config.ShowMS = Value
	end,
	2
)

CreateNumberBox(
	MouseSection,
	"Performance X",
	function()
		return Config.PerformanceOffsetX
	end,
	function(Value)
		Config.PerformanceOffsetX = Value
	end,
	3
)

CreateNumberBox(
	MouseSection,
	"Performance Y",
	function()
		return Config.PerformanceOffsetY
	end,
	function(Value)
		Config.PerformanceOffsetY = Value
	end,
	4
)

local TraceSection =
	CreateSection("Trace", 4)

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
	"Dead Target Red",
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
	"Trace Length",
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
	"Trace Thickness",
	function()
		return Config.TraceThickness
	end,
	function(Value)
		Config.TraceThickness = math.max(0.5, Value)
	end,
	5
)

local HealthSection =
	CreateSection("Health Players", 5)

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
	"Health Text Size",
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
	"Health Distance",
	function()
		return Config.HealthMaxDistance
	end,
	function(Value)
		Config.HealthMaxDistance = math.max(1, Value)
	end,
	3
)

local DeathSection =
	CreateSection("Death", 6)

CreateToggle(
	DeathSection,
	"Death Indicator",
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
	"Death Duration",
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
	"Death Rise",
	function()
		return Config.DeathRise
	end,
	function(Value)
		Config.DeathRise = math.max(0, Value)
	end,
	3
)

local PerformanceLabel =
	Instance.new("TextLabel")

PerformanceLabel.Size =
	UDim2.fromOffset(230, 30)

PerformanceLabel.BackgroundTransparency = 1
PerformanceLabel.TextColor3 = Color3.new(1, 1, 1)
PerformanceLabel.TextSize = 13
PerformanceLabel.Font = Enum.Font.GothamBold
PerformanceLabel.TextXAlignment =
	Enum.TextXAlignment.Left
PerformanceLabel.Visible = false
PerformanceLabel.Parent = ScreenGui

local function GetCharacter(Player)
	return Player.Character
end

local function GetRoot(Player)
	local Character = GetCharacter(Player)

	if not Character then
		return nil
	end

	return Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(Player)
	local Character = GetCharacter(Player)

	if not Character then
		return nil
	end

	return Character:FindFirstChildOfClass("Humanoid")
end

local function IsEnemy(Player)
	if not Player or Player == LocalPlayer then
		return false
	end

	if not LocalPlayer.Team
		or not Player.Team then
		return true
	end

	return LocalPlayer.Team ~= Player.Team
end

local function GetNearestTarget()
	local LocalRoot =
		GetRoot(LocalPlayer)

	if not LocalRoot then
		return nil
	end

	local PriorityCandidates = {}
	local NormalCandidates = {}

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer then

			local Root = GetRoot(Player)
			local Humanoid = GetHumanoid(Player)

			if Root
				and Humanoid
				and Humanoid.Health > 0 then

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

						table.insert(
							PriorityCandidates,
							Candidate
						)

					elseif not Config.OnlyPriorityRange then

						table.insert(
							NormalCandidates,
							Candidate
						)
					end
				end
			end
		end
	end

	local function Sort(List)
		if Config.PrioritizeNearest then
			table.sort(List, function(A, B)
				return A.Distance < B.Distance
			end)
		end

		return List
	end

	if Config.PrioritizeEnemies then

		local EnemyPriority = {}

		for _, Candidate in ipairs(PriorityCandidates) do
			if Candidate.Enemy then
				table.insert(
					EnemyPriority,
					Candidate
				)
			end
		end

		if #EnemyPriority > 0 then
			Sort(EnemyPriority)
			return EnemyPriority[1].Player
		end
	end

	if #PriorityCandidates > 0 then
		Sort(PriorityCandidates)
		return PriorityCandidates[1].Player
	end

	if Config.OnlyPriorityRange then
		return nil
	end

	if Config.PrioritizeEnemies then

		local EnemyNormal = {}

		for _, Candidate in ipairs(NormalCandidates) do
			if Candidate.Enemy then
				table.insert(
					EnemyNormal,
					Candidate
				)
			end
		end

		if #EnemyNormal > 0 then
			Sort(EnemyNormal)
			return EnemyNormal[1].Player
		end
	end

	if #NormalCandidates > 0 then
		Sort(NormalCandidates)
		return NormalCandidates[1].Player
	end

	return nil
end

local function FormatDamage(Damage)
	if typeof(Damage) ~= "number" then
		return nil
	end

	if Damage ~= Damage then
		return nil
	end

	if Damage == math.huge
		or Damage == -math.huge then
		return nil
	end

	if Damage <= 0 then
		return nil
	end

	if Damage > 100000 then
		return nil
	end

	if not Config.SmallDamageEnabled
		and Damage < Config.SmallDamageMinimum then
		return nil
	end

	Damage =
		math.floor(Damage * 100 + 0.5) / 100

	if Damage % 1 == 0 then
		return string.format("%d", Damage)
	end

	return string.format("%.2f", Damage)
		:gsub("0+$", "")
		:gsub("%.$", "")
end

local function CreateDamageIndicator(Player, Damage)
	if not Config.Enabled
		or not Config.DamageEnabled then
		return
	end

	local Text = FormatDamage(Damage)

	if not Text then
		return
	end

	local Root = GetRoot(Player)

	if not Root then
		return
	end

	local Billboard =
		Instance.new("BillboardGui")

	Billboard.Name = "DamageIndicator"

	Billboard.Size =
		UDim2.fromOffset(160, 60)

	Billboard.AlwaysOnTop =
		Config.ThroughWalls

	Billboard.Adornee = Root

	local UseMouse =
		Config.DamageFollowMouse

	if UseMouse then
		Billboard.Adornee = nil
		Billboard.Parent = ScreenGui

		local X =
			MousePosition.X
			+ Config.MouseOffsetX

		local Y =
			MousePosition.Y
			+ Config.MouseOffsetY

		if Config.RandomPosition then
			X +=
				math.random(
					-Config.RandomX,
					Config.RandomX
				)

			Y +=
				math.random(
					-Config.RandomY,
					Config.RandomY
				)
		end

		Billboard.Position =
			UDim2.fromOffset(X, Y)

	else
		local X = 0
		local Y = 2
		local Z = 0

		if Config.RandomPosition then
			X =
				math.random(
					-100,
					100
				) / 100
				* 1.2

			Y =
				2
				+ math.random(
					-100,
					100
				) / 100
				* 0.7

			Z =
				math.random(
					-100,
					100
				) / 100
				* 1.2
		end

		Billboard.StudsOffset =
			Vector3.new(X, Y, Z)

		Billboard.Parent = ScreenGui
	end

	local Label =
		Instance.new("TextLabel")

	Label.Size =
		UDim2.fromScale(1, 1)

	Label.BackgroundTransparency = 1
	Label.Text = "-" .. Text
	Label.TextColor3 = Config.TextColor
	Label.TextSize = Config.TextSize
	Label.Font = Config.Font
	Label.TextTransparency =
		Config.TextTransparency

	Label.TextStrokeColor3 =
		Config.StrokeColor

	Label.TextStrokeTransparency =
		Config.StrokeEnabled
		and Config.StrokeTransparency
		or 1

	Label.Parent = Billboard

	task.delay(Config.DamageDelay, function()

		if not Billboard.Parent then
			return
		end

		if UseMouse then

			local Start =
				Billboard.Position

			local End =
				UDim2.fromOffset(
					Start.X.Offset,
					Start.Y.Offset
					- Config.DamageRise
				)

			local Tween =
				TweenService:Create(
					Billboard,
					TweenInfo.new(
						Config.DamageDuration,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						Position = End
					}
				)

			local Fade =
				TweenService:Create(
					Label,
					TweenInfo.new(
						Config.DamageDuration,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}
				)

			Tween:Play()
			Fade:Play()

			Tween.Completed:Once(function()
				if Billboard.Parent then
					Billboard:Destroy()
				end
			end)

		else

			local Start =
				Billboard.StudsOffset

			local Tween =
				TweenService:Create(
					Billboard,
					TweenInfo.new(
						Config.DamageDuration,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						StudsOffset =
							Start
							+ Vector3.new(
								0,
								Config.DamageRise,
								0
							)
					}
				)

			local Fade =
				TweenService:Create(
					Label,
					TweenInfo.new(
						Config.DamageDuration,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}
				)

			Tween:Play()
			Fade:Play()

			Tween.Completed:Once(function()
				if Billboard.Parent then
					Billboard:Destroy()
				end
			end)
		end
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

	local Billboard =
		Instance.new("BillboardGui")

	Billboard.Name = "Dead"
	Billboard.Adornee = Root
	Billboard.Size =
		UDim2.fromOffset(150, 55)

	Billboard.StudsOffset =
		Vector3.new(0, 2, 0)

	Billboard.AlwaysOnTop =
		Config.ThroughWalls

	Billboard.Parent = ScreenGui

	local Label =
		Instance.new("TextLabel")

	Label.Size =
		UDim2.fromScale(1, 1)

	Label.BackgroundTransparency = 1
	Label.Text = Config.DeathText
	Label.TextColor3 =
		Color3.fromRGB(35, 35, 35)

	Label.TextSize =
		Config.DeathTextSize

	Label.Font =
		Enum.Font.GothamBlack

	Label.TextStrokeColor3 =
		Color3.fromRGB(220, 220, 220)

	Label.TextStrokeTransparency = 0.2
	Label.Parent = Billboard

	local Tween =
		TweenService:Create(
			Billboard,
			TweenInfo.new(
				Config.DeathDuration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				StudsOffset =
					Vector3.new(
						0,
						2 + Config.DeathRise,
						0
					)
			}
		)

	local Fade =
		TweenService:Create(
			Label,
			TweenInfo.new(
				Config.DeathDuration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}
		)

	Tween:Play()
	Fade:Play()

	Tween.Completed:Once(function()
		if Billboard.Parent then
			Billboard:Destroy()
		end
	end)
end

local function RemoveHealth(Player)
	if HealthLabels[Player] then
		HealthLabels[Player]:Destroy()
		HealthLabels[Player] = nil
	end
end

local function UpdateHealth(Player)
	if not Config.HealthPlayers then
		RemoveHealth(Player)
		return
	end

	local Root = GetRoot(Player)
	local Humanoid = GetHumanoid(Player)
	local LocalRoot = GetRoot(LocalPlayer)

	if not Root
		or not Humanoid
		or not LocalRoot then

		RemoveHealth(Player)
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

	local Billboard =
		HealthLabels[Player]

	if not Billboard then

		Billboard =
			Instance.new("BillboardGui")

		Billboard.Name = "Health"
		Billboard.Size =
			UDim2.fromOffset(120, 35)

		Billboard.StudsOffset =
			Vector3.new(0, 3.2, 0)

		Billboard.Adornee = Root
		Billboard.Parent = ScreenGui

		local Label =
			Instance.new("TextLabel")

		Label.Name = "Value"
		Label.Size =
			UDim2.fromScale(1, 1)

		Label.BackgroundTransparency = 1
		Label.TextSize =
			Config.HealthTextSize

		Label.Font =
			Enum.Font.GothamBold

		Label.TextStrokeColor3 =
			Color3.new(0, 0, 0)

		Label.TextStrokeTransparency = 0.2
		Label.Parent = Billboard

		HealthLabels[Player] = Billboard
	end

	Billboard.Enabled = true
	Billboard.Adornee = Root
	Billboard.AlwaysOnTop =
		Config.ThroughWalls

	local Label =
		Billboard:FindFirstChild("Value")

	if not Label then
		return
	end

	local MaxHealth =
		math.max(Humanoid.MaxHealth, 1)

	local Percentage =
		math.clamp(
			Humanoid.Health
				/ MaxHealth
				* 100,
			0,
			100
		)

	Label.Text =
		string.format(
			"%d%%",
			math.floor(
				Percentage + 0.5
			)
		)

	Label.TextSize =
		Config.HealthTextSize

	if Percentage <= 25 then
		Label.TextColor3 =
			Color3.fromRGB(
				255,
				60,
				60
			)
	elseif Percentage <= 50 then
		Label.TextColor3 =
			Color3.fromRGB(
				255,
				200,
				60
			)
	else
		Label.TextColor3 =
			Color3.fromRGB(
				255,
				255,
				255
			)
	end
end

local function RemoveTrace(Player)
	local Data =
		PlayerTraces[Player]

	if Data and Data.Line then
		pcall(function()
			Data.Line:Remove()
		end)
	end

	PlayerTraces[Player] = nil
end

local function UpdateTrace(Player)
	if not DrawingAvailable then
		return
	end

	local Data =
		PlayerTraces[Player]

	if not Config.TracePlayer then
		if Data then
			Data.Line.Visible = false
		end

		return
	end

	local Character =
		Player.Character

	local Root =
		GetRoot(Player)

	local Head =
		Character
		and Character:FindFirstChild("Head")

	local Humanoid =
		GetHumanoid(Player)

	local Camera =
		workspace.CurrentCamera

	if not Root
		or not Head
		or not Humanoid
		or Humanoid.Health <= 0
		or not Camera then

		if Data then
			Data.Line.Visible = false
		end

		return
	end

	if not Data then
		local Success, Line =
			pcall(function()
				return Drawing.new("Line")
			end)

		if not Success or not Line then
			return
		end

		Line.Visible = false
		Line.Transparency = 1
		Line.Color =
			Color3.fromRGB(
				50,
				255,
				90
			)

		PlayerTraces[Player] = {
			Line = Line
		}

		Data =
			PlayerTraces[Player]
	end

	local Start =
		Camera:WorldToViewportPoint(
			Head.Position
		)

	local End =
		Camera:WorldToViewportPoint(
			Head.Position
			+ Root.CFrame.LookVector
				* Config.TraceLength
		)

	Data.Line.From =
		Vector2.new(
			Start.X,
			Start.Y
		)

	Data.Line.To =
		Vector2.new(
			End.X,
			End.Y
		)

	Data.Line.Thickness =
		Config.TraceThickness

	Data.Line.Visible =
		Start.Z > 0
		or End.Z > 0
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

	if not MouseTrace then
		local Success, Line =
			pcall(function()
				return Drawing.new("Line")
			end)

		if not Success or not Line then
			return
		end

		Line.Visible = false
		Line.Transparency = 1

		MouseTrace = Line
	end

	if not CurrentTarget then
		MouseTrace.Visible = false
		return
	end

	local Root =
		GetRoot(CurrentTarget)

	local Humanoid =
		GetHumanoid(CurrentTarget)

	local Camera =
		workspace.CurrentCamera

	if not Root
		or not Humanoid
		or not Camera then

		MouseTrace.Visible = false
		return
	end

	local Position, Visible =
		Camera:WorldToViewportPoint(
			Root.Position
		)

	if not Visible
		or Position.Z <= 0 then

		MouseTrace.Visible = false
		return
	end

	MouseTrace.From =
		MousePosition

	MouseTrace.To =
		Vector2.new(
			Position.X,
			Position.Y
		)

	MouseTrace.Thickness =
		Config.TraceThickness

	if Humanoid.Health <= 0
		and Config.TraceMouseDeadRed then

		MouseTrace.Color =
			Color3.fromRGB(
				255,
				40,
				40
			)
	else

		MouseTrace.Color =
			Color3.fromRGB(
				50,
				255,
				90
			)
	end

	MouseTrace.Visible = true
end

local function TrackPlayer(Player)
	if Player == LocalPlayer
		or TrackedPlayers[Player] then
		return
	end

	TrackedPlayers[Player] = true

	local function TrackCharacter(Character)

		if CharacterConnections[Player] then
			for _, Connection in
				ipairs(
					CharacterConnections[Player]
				) do

				Connection:Disconnect()
			end
		end

		CharacterConnections[Player] = {}

		local Humanoid =
			Character:WaitForChild(
				"Humanoid",
				5
			)

		if not Humanoid then
			return
		end

		local LastHealth =
			Humanoid.Health

		local DeadShown = false

		local Connection =
			Humanoid.HealthChanged:Connect(
				function(NewHealth)

					if typeof(NewHealth)
						~= "number" then
						return
					end

					if NewHealth ~= NewHealth
						or NewHealth == math.huge
						or NewHealth == -math.huge then
						return
					end

					if NewHealth < LastHealth then

						local Damage =
							LastHealth - NewHealth

						if Damage > 0
							and Damage <= 100000
							and Damage <= math.max(
								LastHealth,
								0
							) then

							Damage =
								math.floor(
									Damage * 100
										+ 0.5
								) / 100

							local Root =
								GetRoot(Player)

							local LocalRoot =
								GetRoot(LocalPlayer)

							if Root and LocalRoot then

								local Distance =
									(
										Root.Position
										- LocalRoot.Position
									).Magnitude

								local ValidRange =
									Distance
									<= Config.MaxDistance

								if Config.PriorityEnabled
									and Config.OnlyPriorityRange then

									ValidRange =
										Distance
										<= Config.PriorityStuds
								end

								if ValidRange then

									if Config.DamageFollowMouse then

										if CurrentTarget
											== Player then

											CreateDamageIndicator(
												Player,
												Damage
											)
										end

									else

										CreateDamageIndicator(
											Player,
											Damage
										)
									end
								end
							end
						end
					end

					if NewHealth <= 0
						and not DeadShown then

						DeadShown = true

						CreateDeathIndicator(
							Player
						)
					end

					LastHealth =
						NewHealth
				end
			)

		table.insert(
			CharacterConnections[Player],
			Connection
		)

		local DiedConnection =
			Humanoid.Died:Connect(
				function()

					if not DeadShown then
						DeadShown = true

						CreateDeathIndicator(
							Player
						)
					end
				end
			)

		table.insert(
			CharacterConnections[Player],
			DiedConnection
		)
	end

	if Player.Character then
		task.spawn(
			TrackCharacter,
			Player.Character
		)
	end

	local CharacterConnection =
		Player.CharacterAdded:Connect(
			function(Character)
				task.spawn(
					TrackCharacter,
					Character
				)
			end
		)

	table.insert(
		Connections,
		CharacterConnection
	)
end

for _, Player in
	ipairs(Players:GetPlayers()) do

	TrackPlayer(Player)
end

table.insert(
	Connections,
	Players.PlayerAdded:Connect(
		function(Player)
			TrackPlayer(Player)
		end
	)
)

table.insert(
	Connections,
	Players.PlayerRemoving:Connect(
		function(Player)

			RemoveTrace(Player)
			RemoveHealth(Player)

			if CharacterConnections[Player] then
				for _, Connection in
					ipairs(
						CharacterConnections[Player]
					) do

					Connection:Disconnect()
				end
			end

			CharacterConnections[Player] = nil
			TrackedPlayers[Player] = nil
		end
	)
)

table.insert(
	Connections,
	UserInputService.InputChanged:Connect(
		function(Input)

			if Input.UserInputType
				== Enum.UserInputType.MouseMovement then

				MousePosition =
					UserInputService:GetMouseLocation()

			elseif Input.UserInputType
				== Enum.UserInputType.Touch then

				MousePosition =
					Vector2.new(
						Input.Position.X,
						Input.Position.Y
					)
			end
		end
	)
)

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(
	function(Input)

		if Input.UserInputType
			== Enum.UserInputType.MouseButton1
			or Input.UserInputType
			== Enum.UserInputType.Touch then

			Dragging = true
			DragStart = Input.Position
			StartPosition = Main.Position
		end
	end
)

Header.InputEnded:Connect(
	function(Input)

		if Input.UserInputType
			== Enum.UserInputType.MouseButton1
			or Input.UserInputType
			== Enum.UserInputType.Touch then

			Dragging = false
		end
	end
)

table.insert(
	Connections,
	UserInputService.InputChanged:Connect(
		function(Input)

			if not Dragging then
				return
			end

			if Input.UserInputType
				~= Enum.UserInputType.MouseMovement
				and Input.UserInputType
				~= Enum.UserInputType.Touch then
				return
			end

			local Delta =
				Input.Position
				- DragStart

			Main.Position =
				UDim2.new(
					StartPosition.X.Scale,
					StartPosition.X.Offset
						+ Delta.X,

					StartPosition.Y.Scale,
					StartPosition.Y.Offset
						+ Delta.Y
				)
		end
	)
)

Close.MouseButton1Click:Connect(
	function()
		Main.Visible = false
		OpenButton.Visible = true
	end
)

OpenButton.MouseButton1Click:Connect(
	function()
		Main.Visible = true
		OpenButton.Visible = false
	end
)

table.insert(
	Connections,
	RunService.Heartbeat:Connect(
		function()

			if not Config.Enabled then
				CurrentTarget = nil
				return
			end

			local Now = os.clock()

			if Now - LastTargetUpdate
				>= Config.UpdateRate then

				LastTargetUpdate = Now

				CurrentTarget =
					GetNearestTarget()
			end
		end
	)
)

table.insert(
	Connections,
	RunService.RenderStepped:Connect(
		function()

			FrameCount += 1

			local Now = os.clock()

			if Now - LastFPSUpdate >= 1 then
				FPS = FrameCount
				FrameCount = 0
				LastFPSUpdate = Now
			end

			if Config.ShowFPS
				or Config.ShowMS then

				PerformanceLabel.Visible = true

				local Parts = {}

				if Config.ShowFPS then
					table.insert(
						Parts,
						"FPS: "
							.. tostring(FPS)
					)
				end

				if Config.ShowMS then

					local Ping = 0

					pcall(
						function()

							Ping =
								Stats.Network
								.ServerStatsItem[
									"Data Ping"
								]:GetValue()
						end
					)

					table.insert(
						Parts,
						"Ms: "
							.. tostring(
								math.floor(
									Ping
								)
							)
					)
				end

				PerformanceLabel.Text =
					table.concat(
						Parts,
						" | "
					)

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

			for _, Player in
				ipairs(
					Players:GetPlayers()
				) do

				if Player ~= LocalPlayer then

					UpdateTrace(Player)
					UpdateHealth(Player)
				end
			end

			UpdateMouseTrace()
		end
	)
)

local function Cleanup()

	for _, Connection in
		ipairs(Connections) do

		pcall(function()
			Connection:Disconnect()
		end)
	end

	for _, PlayerConnections in
		pairs(CharacterConnections) do

		for _, Connection in
			ipairs(PlayerConnections) do

			pcall(function()
				Connection:Disconnect()
			end)
		end
	end

	for Player in
		pairs(PlayerTraces) do

		RemoveTrace(Player)
	end

	if MouseTrace then
		pcall(function()
			MouseTrace:Remove()
		end)

		MouseTrace = nil
	end

	for Player in
		pairs(HealthLabels) do

		RemoveHealth(Player)
	end

	if ScreenGui then
		ScreenGui:Destroy()
	end
end

if script then
	pcall(function()
		script.Destroying:Connect(Cleanup)
	end)
end
