-- || Settings || --

local autofarm = true

local StarsFolder = game:GetService("Workspace").LocalStars["Spawn Lobby"]
local NodesFolder = Instance.new("Folder", workspace)
NodesFolder.Name = "Nodes"

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')
local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')

local function getStar()
	for _, star in ipairs(StarsFolder:GetChildren()) do
		if star:IsDescendantOf(workspace) and star.Primary then
			return star 
		end
	end
	return nil
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
	if not target or not target:IsDescendantOf(workspace) or not target.Primary then return end

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
	local targetCoin = getStar()
	if targetCoin then
		MoveTo(Humanoid, HumanoidRootPart, targetCoin)
	end
	wait(0.1)
end
