local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
	Enabled = true,

	TargetPriority = true,
	PrioritizeNearest = true,
	PrioritizeEnemies = true,
	PriorityStuds = 19,
	MaxDistance = 250,

	TextColor = Color3.fromRGB(255, 55, 55),
	StrokeColor = Color3.fromRGB(255, 150, 150),
	StrokeEnabled = true,
	StrokeTransparency = 0.2,
	StrokeThickness = 1,

	TextSize = 24,
	Font = Enum.Font.GothamBold,

	Delay = 0.5,
	Duration = 0.8,
	RiseHeight = 2.5,
	RandomOffset = 1.2,

	MouseDamage = false,
	MouseOffsetX = 0,
	MouseOffsetY = -35,

	ShowFPS = false,
	FPSOffsetX = 18,
	FPSOffsetY = 18,

	UpdateRate = 0.05
}

local Connections = {}
local Tracked = {}
local LastTarget = nil
local FPS = 0
local FrameCounter = 0
local LastFPSTime = os.clock()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DamageIndicator"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function CreateCorner(parent, radius)
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, radius)
	Corner.Parent = parent
	return Corner
end

local function CreateStroke(parent, color, transparency, thickness)
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = color
	Stroke.Transparency = transparency
	Stroke.Thickness = thickness
	Stroke.Parent = parent
	return Stroke
end

local function MakeDraggable(Frame, Handle)
	local Dragging = false
	local DragStart
	local StartPosition

	local function Update(Input)
		local Delta = Input.Position - DragStart
		Frame.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end

	Handle.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then

			Dragging = true
			DragStart = Input.Position
			StartPosition = Frame.Position

			local Connection
			Connection = Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
					Connection:Disconnect()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Dragging and (
			Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch
		) then
			Update(Input)
		end
	end)
end

local ConfigButton = Instance.new("TextButton")
ConfigButton.Name = "ConfigButton"
ConfigButton.Size = UDim2.fromOffset(44, 44)
ConfigButton.Position = UDim2.new(0, 15, 0.5, -22)
ConfigButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ConfigButton.Text = "⚙"
ConfigButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigButton.TextSize = 21
ConfigButton.Font = Enum.Font.GothamBold
ConfigButton.Parent = ScreenGui

CreateCorner(ConfigButton, 12)
CreateStroke(ConfigButton, Color3.fromRGB(65, 65, 75), 0, 1)

local Window = Instance.new("Frame")
Window.Name = "ConfigWindow"
Window.Size = UDim2.fromOffset(340, 460)
Window.Position = UDim2.new(0.5, -170, 0.5, -230)
Window.BackgroundColor3 = Color3.fromRGB(16, 16, 21)
Window.Visible = false
Window.Parent = ScreenGui

CreateCorner(Window, 14)
CreateStroke(Window, Color3.fromRGB(55, 55, 65), 0, 1)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.Parent = Window

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "Damage Indicator"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(40, 40)
Close.Position = UDim2.new(1, -47, 0, 6)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220, 220, 220)
Close.TextSize = 27
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

local Content = Instance.new("ScrollingFrame")
Content.Name = "Sections"
Content.Size = UDim2.new(1, -18, 1, -62)
Content.Position = UDim2.fromOffset(9, 57)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new()
Content.Parent = Window

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content

local function UpdateCanvas()
	Content.CanvasSize = UDim2.fromOffset(
		0,
		ContentLayout.AbsoluteContentSize.Y + 12
	)
end

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

local function CreateSection(Name, Height)
	local Section = Instance.new("Frame")
	Section.Name = Name
	Section.Size = UDim2.new(1, -4, 0, Height)
	Section.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	Section.LayoutOrder = #Content:GetChildren()
	Section.Parent = Content

	CreateCorner(Section, 10)
	CreateStroke(Section, Color3.fromRGB(45, 45, 55), 0, 1)

	local SectionTitle = Instance.new("TextLabel")
	SectionTitle.Size = UDim2.new(1, -20, 0, 30)
	SectionTitle.Position = UDim2.fromOffset(10, 4)
	SectionTitle.BackgroundTransparency = 1
	SectionTitle.Text = Name
	SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	SectionTitle.TextSize = 14
	SectionTitle.Font = Enum.Font.GothamBold
	SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	SectionTitle.Parent = Section

	return Section
end

local function CreateToggle(Parent, Text, Position, Default, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -20, 0, 32)
	Button.Position = Position
	Button.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
	Button.TextColor3 = Color3.fromRGB(235, 235, 235)
	Button.TextSize = 13
	Button.Font = Enum.Font.GothamMedium
	Button.TextXAlignment = Enum.TextXAlignment.Left
	Button.Text = "  " .. Text .. ": " .. (Default and "ON" or "OFF")
	Button.Parent = Parent

	CreateCorner(Button, 7)

	local State = Default

	Button.Activated:Connect(function()
		State = not State
		Button.Text = "  " .. Text .. ": " .. (State and "ON" or "OFF")
		Callback(State)
	end)

	return Button
end

local function CreateCycle(Parent, Text, Position, Values, Current, Callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -20, 0, 32)
	Button.Position = Position
	Button.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
	Button.TextColor3 = Color3.fromRGB(235, 235, 235)
	Button.TextSize = 13
	Button.Font = Enum.Font.GothamMedium
	Button.TextXAlignment = Enum.TextXAlignment.Left
	Button.Parent = Parent

	CreateCorner(Button, 7)

	local Index = Current or 1

	local function Refresh()
		Button.Text = "  " .. Text .. ": " .. Values[Index].Name
	end

	Refresh()

	Button.Activated:Connect(function()
		Index += 1

		if Index > #Values then
			Index = 1
		end

		Callback(Values[Index].Value)
		Refresh()
	end)

	return Button
end

local function CreateNumberBox(Parent, Text, Position, Default, Min, Max, Callback)
	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(1, -20, 0, 32)
	Box.Position = Position
	Box.BackgroundColor3 = Color3.fromRGB(29, 29, 36)
	Box.TextColor3 = Color3.fromRGB(235, 235, 235)
	Box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
	Box.TextSize = 13
	Box.Font = Enum.Font.GothamMedium
	Box.TextXAlignment = Enum.TextXAlignment.Left
	Box.Text = "  " .. Text .. ": " .. tostring(Default)
	Box.ClearTextOnFocus = false
	Box.Parent = Parent

	CreateCorner(Box, 7)

	Box.FocusLost:Connect(function()
		local Number = tonumber(Box.Text:gsub("^%s*"..Text..":%s*", ""))

		if Number then
			Number = math.clamp(Number, Min, Max)
			Callback(Number)
			Box.Text = "  " .. Text .. ": " .. tostring(Number)
		else
			Box.Text = "  " .. Text .. ": " .. tostring(Default)
		end
	end)

	return Box
end

local TargetSection = CreateSection("Target Priority", 185)

CreateToggle(
	TargetSection,
	"Priorizar mais próximo",
	UDim2.fromOffset(10, 38),
	Config.PrioritizeNearest,
	function(Value)
		Config.PrioritizeNearest = Value
	end
)

CreateToggle(
	TargetSection,
	"Priorizar inimigos",
	UDim2.fromOffset(10, 76),
	Config.PrioritizeEnemies,
	function(Value)
		Config.PrioritizeEnemies = Value
	end
)

CreateToggle(
	TargetSection,
	"Filtro de prioridade",
	UDim2.fromOffset(10, 114),
	Config.TargetPriority,
	function(Value)
		Config.TargetPriority = Value
	end
)

CreateNumberBox(
	TargetSection,
	"Prioridade Studs",
	UDim2.fromOffset(10, 152),
	Config.PriorityStuds,
	1,
	500,
	function(Value)
		Config.PriorityStuds = Value
	end
)

local VisualSection = CreateSection("Damage Visual", 300)

CreateCycle(
	VisualSection,
	"Fonte",
	UDim2.fromOffset(10, 38),
	{
		{Name = "GothamBold", Value = Enum.Font.GothamBold},
		{Name = "GothamBlack", Value = Enum.Font.GothamBlack},
		{Name = "GothamMedium", Value = Enum.Font.GothamMedium},
		{Name = "SourceSansBold", Value = Enum.Font.SourceSansBold},
		{Name = "SourceSans", Value = Enum.Font.SourceSans},
		{Name = "Arcade", Value = Enum.Font.Arcade},
		{Name = "Code", Value = Enum.Font.Code},
		{Name = "Fantasy", Value = Enum.Font.Fantasy},
		{Name = "Antique", Value = Enum.Font.Antique},
		{Name = "SciFi", Value = Enum.Font.SciFi},
		{Name = "Highway", Value = Enum.Font.Highway},
		{Name = "Bodoni", Value = Enum.Font.Bodoni},
		{Name = "Cartoon", Value = Enum.Font.Cartoon}
	},
	1,
	function(Value)
		Config.Font = Value
	end
)

CreateNumberBox(
	VisualSection,
	"Tamanho",
	UDim2.fromOffset(10, 76),
	Config.TextSize,
	8,
	80,
	function(Value)
		Config.TextSize = Value
	end
)

CreateNumberBox(
	VisualSection,
	"Borda",
	UDim2.fromOffset(10, 114),
	Config.StrokeTransparency,
	0,
	1,
	function(Value)
		Config.StrokeTransparency = Value
	end
)

CreateNumberBox(
	VisualSection,
	"Espessura",
	UDim2.fromOffset(10, 152),
	Config.StrokeThickness,
	0,
	10,
	function(Value)
		Config.StrokeThickness = Value
	end
)

CreateToggle(
	VisualSection,
	"Borda",
	UDim2.fromOffset(10, 190),
	Config.StrokeEnabled,
	function(Value)
		Config.StrokeEnabled = Value
	end
)

CreateNumberBox(
	VisualSection,
	"Subida",
	UDim2.fromOffset(10, 228),
	Config.RiseHeight,
	0,
	10,
	function(Value)
		Config.RiseHeight = Value
	end
)

CreateNumberBox(
	VisualSection,
	"Aleatoriedade",
	UDim2.fromOffset(10, 266),
	Config.RandomOffset,
	0,
	5,
	function(Value)
		Config.RandomOffset = Value
	end
)

local MouseSection = CreateSection("Mouse / FPS", 185)

CreateToggle(
	MouseSection,
	"Dano no mouse",
	UDim2.fromOffset(10, 38),
	Config.MouseDamage,
	function(Value)
		Config.MouseDamage = Value
	end
)

CreateToggle(
	MouseSection,
	"FPS seguindo mouse",
	UDim2.fromOffset(10, 76),
	Config.ShowFPS,
	function(Value)
		Config.ShowFPS = Value
	end
)

CreateNumberBox(
	MouseSection,
	"Mouse X",
	UDim2.fromOffset(10, 114),
	Config.MouseOffsetX,
	-200,
	200,
	function(Value)
		Config.MouseOffsetX = Value
	end
)

CreateNumberBox(
	MouseSection,
	"Mouse Y",
	UDim2.fromOffset(10, 152),
	Config.MouseOffsetY,
	-200,
	200,
	function(Value)
		Config.MouseOffsetY = Value
	end
)

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPS"
FPSLabel.Size = UDim2.fromOffset(80, 25)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: 0"
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextSize = 14
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Visible = false
FPSLabel.Parent = ScreenGui

local FPSStroke = Instance.new("UIStroke")
FPSStroke.Color = Color3.fromRGB(0, 0, 0)
FPSStroke.Thickness = 2
FPSStroke.Parent = FPSLabel

MakeDraggable(Window, Header)

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

local function IsAlive(Character)
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	return Humanoid and Humanoid.Health > 0
end

local function IsEnemy(Player)
	if not LocalPlayer.Team or not Player.Team then
		return true
	end

	return Player.Team ~= LocalPlayer.Team
end

local function GetNearestTarget()
	local MyCharacter = LocalPlayer.Character
	local MyRoot = MyCharacter and GetRoot(MyCharacter)

	if not MyRoot then
		return nil
	end

	local BestPlayer
	local BestDistance = math.huge
	local EnemyBest
	local EnemyDistance = math.huge

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LocalPlayer and Player.Character and IsAlive(Player.Character) then
			local Root = GetRoot(Player.Character)

			if Root then
				local Distance = (Root.Position - MyRoot.Position).Magnitude

				if Distance <= Config.MaxDistance then
					if Distance < BestDistance then
						BestDistance = Distance
						BestPlayer = Player
					end

					if Config.PrioritizeEnemies and IsEnemy(Player) and Distance < EnemyDistance then
						EnemyDistance = Distance
						EnemyBest = Player
					end
				end
			end
		end
	end

	if Config.PrioritizeEnemies and EnemyBest then
		if not Config.TargetPriority or EnemyDistance <= Config.PriorityStuds then
			return EnemyBest
		end
	end

	if Config.PrioritizeNearest then
		if not Config.TargetPriority then
			return BestPlayer
		end

		if BestPlayer and BestDistance <= Config.PriorityStuds then
			return BestPlayer
		end
	end

	return BestPlayer
end

local function CreateMouseDamage(Damage)
	if not Config.MouseDamage then
		return
	end

	local Position = UserInputService:GetMouseLocation()

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.fromOffset(110, 40)
	Label.Position = UDim2.fromOffset(
		Position.X + Config.MouseOffsetX,
		Position.Y + Config.MouseOffsetY
	)
	Label.BackgroundTransparency = 1
	Label.Text = "-" .. tostring(math.floor(Damage))
	Label.TextColor3 = Config.TextColor
	Label.TextSize = Config.TextSize
	Label.Font = Config.Font
	Label.TextTransparency = 0
	Label.TextStrokeColor3 = Config.StrokeColor
	Label.TextStrokeTransparency = Config.StrokeEnabled and Config.StrokeTransparency or 1
	Label.Parent = ScreenGui

	local Move = TweenService:Create(
		Label,
		TweenInfo.new(
			Config.Duration,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Position = Label.Position + UDim2.fromOffset(
				math.random(-20, 20),
				-Config.RiseHeight * 15
			),
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}
	)

	Move:Play()

	Move.Completed:Once(function()
		Label:Destroy()
	end)
end

local function CreateDamage(Character, Damage)
	if not Config.Enabled or Damage <= 0 then
		return
	end

	local Root = GetRoot(Character)

	if not Root then
		return
	end

	local MyCharacter = LocalPlayer.Character
	local MyRoot = MyCharacter and GetRoot(MyCharacter)

	if MyRoot then
		if (Root.Position - MyRoot.Position).Magnitude > Config.MaxDistance then
			return
		end
	end

	task.delay(Config.Delay, function()
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
		Text.Size = UDim2.fromScale(1, 1)
		Text.BackgroundTransparency = 1
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
					math.random(-30, 30) / 100,
					Config.RiseHeight,
					math.random(-30, 30) / 100
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

	CreateMouseDamage(Damage)
end

local function TrackCharacter(Player, Character)
	if Player == LocalPlayer then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		or Character:WaitForChild("Humanoid", 5)

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
			CreateDamage(Character, LastHealth - NewHealth)
		end

		LastHealth = NewHealth
	end)

	Connections[#Connections + 1] = Connection

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

	Connections[#Connections + 1] = Player.CharacterAdded:Connect(function(Character)
		task.wait(0.1)
		TrackCharacter(Player, Character)
	end)
end

for _, Player in ipairs(Players:GetPlayers()) do
	TrackPlayer(Player)
end

Connections[#Connections + 1] = Players.PlayerAdded:Connect(TrackPlayer)

local TargetTimer = 0

Connections[#Connections + 1] = RunService.Heartbeat:Connect(function(Delta)
	FrameCounter += 1
	TargetTimer += Delta

	if TargetTimer >= Config.UpdateRate then
		TargetTimer = 0
		LastTarget = GetNearestTarget()
	end

	if Config.ShowFPS then
		FPSLabel.Visible = true

		local MousePosition = UserInputService:GetMouseLocation()

		FPSLabel.Position = UDim2.fromOffset(
			MousePosition.X + Config.FPSOffsetX,
			MousePosition.Y + Config.FPSOffsetY
		)
	else
		FPSLabel.Visible = false
	end
end)

Connections[#Connections + 1] = RunService.RenderStepped:Connect(function()
	if os.clock() - LastFPSTime >= 0.5 then
		FPS = math.floor(FrameCounter / (os.clock() - LastFPSTime))
		FrameCounter = 0
		LastFPSTime = os.clock()

		FPSLabel.Text = "FPS: " .. tostring(FPS)
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
