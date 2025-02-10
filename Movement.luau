local NodesFolder = workspace.Nodes

local TargetPart = workspace.Parts:WaitForChild("TargetPart")
local TargetPos = TargetPart.Position

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')
local HumanoidRootPart = Character:WaitForChild('HumanoidRootPart')

local function create_node(pos)
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

local function bezier_curve(length, startPos, endPos, controlPos)
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

		local node = create_node(Vector3.new(F.X, TargetPos.Y, F.Z)) -- Do TargetPos.Y + Vector3.new(0, 1, 0) for most cases
		table.insert(Nodes, node)
		wait(dT)
	end
	return Nodes
end

local function Move(curve)
	for _, node in next, curve do
		Humanoid:MoveTo(node.Position)
		Humanoid.MoveToFinished:Wait()
	end
end

local midpoint = (HumanoidRootPart.Position + TargetPos) / 2
local controlPoint = midpoint + Vector3.new(20, 0, 0) 

local curve = bezier_curve(1, HumanoidRootPart.Position, TargetPos, controlPoint)

task.wait(2)

Move(curve)

