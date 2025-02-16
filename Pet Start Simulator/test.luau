-- || Settings || --

local autofarm = true

local CoinsFolder = workspace.LocalStars["Green Heart Forest"]
local NodesFolder = Instance.new("Folder")
NodesFolder.Parent = workspace
NodesFolder.Name = "Nodes"

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')
local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')

local CoinPriority = {
	Coin = 0,
	Coin2 = 1,
	Coin3 = 3,
}

local function getHighestPriorityCoin()
	local bestCoin
	local highestPriority = -1

	for _, coin in ipairs(CoinsFolder:GetChildren()) do
		local priority = CoinPriority[coin.Name] or -1
		if priority > highestPriority then
			highestPriority = priority
			bestCoin = coin
		end
	end
	return bestCoin
end

local function CreateNode(pos)
	local NodeInstance = Instance.new("Part")
	NodeInstance.Size = Vector3.new(1, 1, 1)
	NodeInstance.Shape = Enum.PartType.Ball
	NodeInstance.Color = Color3.fromRGB(255, 255, 255)
	NodeInstance.Transparency = 0.25
	NodeInstance.Material = Enum.Material.Neon
	NodeInstance.Anchored = true
	NodeInstance.CanCollide = false
	NodeInstance.Parent = NodesFolder
	NodeInstance.Position = pos
	return NodeInstance
end

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function BezierCurve(length, startPos, endPos, controlPos, HumanoidRootPart)
	local Nodes = {}
	local t = 0
	local A = startPos
	local B = endPos
	local C = controlPos
	local dT = (1 / length) / 10

	for i = 0, length * 10 - 1 do
		t += dT
		local D = lerp(A, C, t)  
		local E = lerp(C, B, t)  
		local F = lerp(D, E, t) 
		local node = CreateNode(Vector3.new(F.X, HumanoidRootPart.Position.Y, F.Z))
		table.insert(Nodes, node)
	end
	return Nodes
end

local function MoveTo(Humanoid, HumanoidRootPart, target)
	local targetPos = target.Primary.Position
	local midpoint = (HumanoidRootPart.Position + targetPos) / 2
	local controlPoint = midpoint + Vector3.new(math.random(-20, 20), 0, 0)
	local curve = BezierCurve(1, HumanoidRootPart.Position, targetPos, controlPoint, HumanoidRootPart)
	
	for _, node in next, curve do
		Humanoid:MoveTo(node.Position)
		Humanoid.MoveToFinished:Wait()
	end
	NodesFolder:ClearAllChildren()
end

while autofarm do
    print("Autofarm")
	local targetCoin = getHighestPriorityCoin()
	if targetCoin then
		MoveTo(Humanoid, HumanoidRootPart, targetCoin)
	end
	wait(0.1)
end
