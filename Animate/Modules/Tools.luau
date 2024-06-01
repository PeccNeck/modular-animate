--!strict
--[[
	@PeccNeck:21005600
	   Dec 18, 2022
					  ]]--

--Tables
local Module = {}
local External = {}

local DefaultAnimations
local ToolAnimations: Instance? --these are retrieved from Common and tools later, respectively

local Connections = {}
local PlayConnections = {}
local ToolConnections = {}

--selene: allow(unscoped_variables)
-- LastAnimation = {}

--Find or create dependencies
local Origin = script.Parent.Parent
local Character = Origin.Parent
local Humanoid = Character:WaitForChild("Humanoid")

--local KRemote = Origin:WaitForChild("KeyframeReached")
--local MRemote = Origin:WaitForChild("MarkerReached")

--local StateChangedEvent = script.Parent:WaitForChild("Movement"):WaitForChild("StateChanged")

External.Main = require(script.Parent.Main)
External.Animate = External.Main:Get("Animate")
--External.Movement = External.Main:Get("Movement")
External.Common = External.Main:Get("Common")

local LastAnimation = {}
External.Common.LastAnimations.Tools = LastAnimation

local Config = External.Main.Config

local print = External.Main.print
local warn = External.Main.warn

--Global variables
local CurrentTool: Tool? = nil

--Module variables
Module.Enabled = false
Module.Animations = {}
Module.CurrentState = nil :: string?

--Private
local function ResetSeed()
	local Seed = External.Common:ResetSeed()
	math.randomseed(Seed)

	return Seed
end

local function ToolUnequipped()
	CurrentTool = nil
	
	for _,Connect in pairs(ToolConnections) do
		Connect:Disconnect()
	end
	
	Module:SwitchStates(nil)
end

local function TagAdded(Child: Instance)
	if Child.Name == "toolanim" and Child:IsA("StringValue") then
		local ValueLower = Child.Value:lower()
		
		if ValueLower == "none" then
			Module:SwitchStates("toolnone")
		elseif ValueLower == "slash" then
			Module:SwitchStates("toolslash", 0, nil, true)
		elseif ValueLower == "lunge" then
			Module:SwitchStates("toollunge", 0, nil, true)
		end
		
		if ValueLower == "slash" or ValueLower == "lunge" then
			task.delay(Config.ToolAttackTime, function()
				if Module.CurrentState == "tool" .. ValueLower then
					Module:SwitchStates("toolnone")
				end
			end)
		end
		
		task.wait()
		Child:Destroy()
	end
end

local function ToolAdded(Child: Tool)
	if Child:IsA("Tool") then
		CurrentTool = Child

		Module:ReloadAll()

		table.insert(ToolConnections, Child.ChildAdded:Connect(TagAdded))
		Child.Unequipped:Once(ToolUnequipped)

		if ToolAnimations ~= nil and ToolAnimations:FindFirstChild("toolequip") then
			Module:Play("toolequip", nil, nil, true)
		end
		
		if Child.RequiresHandle or (ToolAnimations ~= nil and ToolAnimations:FindFirstChild("toolnone")) then
			Module:SwitchStates("toolnone")
		end
	end
end

--Public
function Module:SwitchStates(NewState: string?, Fade: number?, Speed: number?, CancelNone: boolean?)

	--print("Tools: SwitchStates", Module.CurrentState, NewState, Fade, Speed, CancelNone)

	if Module.CurrentState == NewState or not Module.Enabled then
		return
	end

	local PreviousState = Module.CurrentState
	Module.CurrentState = NewState

	if PreviousState and Module.Animations[PreviousState] ~= nil then
		Module:Stop(PreviousState, Fade)
	end

	if NewState and Module.Animations[NewState] ~= nil then
		Module:Play(NewState, Speed, Fade, CancelNone)
	end
end

function Module:Play(Name: string, Speed: number?, Fade: number?, CancelNone: boolean?)

	--print("Tools: Play", Name, Speed or 1, Fade or 0.1)
	
	Speed = Speed or 1
	Fade = Fade or Config.ToolTransitionTime

	local Anims = Module.Animations[Name]
	if not Anims then
		warn("Tools: Failed to play", tostring(Name) .. "! (No animations found)")
		return false
	end
	
	if Name == "toolnone" then
		CancelNone = true
	end

	local WeightedTable = {}
	if #Anims > 1 then
		for _,Anim in pairs(Anims) do
			for _ = 1, Anim[2] or 1, 1 do
				table.insert(WeightedTable, Anim[1])
			end
		end
	else
		table.insert(WeightedTable, Anims[1][1])
	end

	local SelectAnim, AnimInstance = External.Common:PlayRandom(Name, Speed, Fade, WeightedTable)
	LastAnimation[Name] = SelectAnim
	
	if Name == "toolnone" then
		PlayConnections[Name] = External.Common:PlayOnLoop(Name, Speed, Fade, Anims, WeightedTable)
	elseif not CancelNone then
		local Routine = coroutine.create(function()
			AnimInstance.Stopped:Wait()
			Module:SwitchStates("toolnone")
		end)
		
		coroutine.resume(Routine)

		task.delay(AnimInstance.Length + Config.ToolTransitionTime, function()
			coroutine.close(Routine)
		end)
	end

	return true
end

function Module:Stop(Name: string?, Fade: number?)

	--print("Tools: Stop", Name, Fade or 0.1)
	
	Fade = Fade or Config.ToolTransitionTime

	local Anim = LastAnimation[Name]
	if not Anim then
		warn("Tools: Failed to stop", tostring(Name) .. "! (No animation found)")
		return false
	end

	local Disconnects = PlayConnections[Name] or {}
	for _,Disconnect in pairs(Disconnects) do
		Disconnect:Disconnect()
	end
	PlayConnections[Name] = nil

	External.Animate:Stop(Anim, Fade)

	return true
end

function Module:Speed(Name: string, Speed: number)

	--print("Tools: Speed", Name, Speed or 1)

	local Anims = LastAnimation[Name]
	if not Anims then
		warn("Tools: Failed to speed", tostring(Name) .. "! (No animations found)")
		return false
	end

	local SelectAnim = LastAnimation[Name]
	External.Animate:Speed(SelectAnim, Speed or 1)
	return true
end

function Module:Reload(Name: string)
	if Module.CurrentState == Name then
		Module:Stop(Name)
	end

	if Module.Animations[Name] then
		for _,Anim in pairs(Module.Animations[Name]) do
			External.Animate:Unload(Anim[1])
		end
	end

	Module.Animations[Name] = nil

	local LoadedAnims = {}

	local AnimsFolder = ToolAnimations or Origin:FindFirstChild("Animations")

	if AnimsFolder and AnimsFolder:FindFirstChild(Name) then
		for _,Anim in pairs(AnimsFolder[Name]:GetChildren()) do
			local AnimName = External.Animate:Load(Name .. "/" .. Anim.Name, Anim.AnimationId)
			local Weight = (Anim:FindFirstChild("Weight") or {Value = 10}).Value

			table.insert(LoadedAnims, {AnimName, Weight})
		end

	elseif DefaultAnimations[Name] then
		for Anim,AnimData in pairs(DefaultAnimations[Name]) do
			local AnimName = External.Animate:Load(Name .. "/" .. Anim, AnimData[1])

			table.insert(LoadedAnims, {AnimName, AnimData[2]})
		end
	end

	if #LoadedAnims > 0 then
		Module.Animations[Name] = LoadedAnims
		LastAnimation[Name] = LoadedAnims[1][1]
	end

	if Module.CurrentState == Name then
		Module:Play(Name)
	end
end

function Module:ReloadAll()
	DefaultAnimations = External.Common:GetDefaultAnimations(Humanoid).Tools
	
	local ToReload: {[string]: boolean?} = {}
	
	if CurrentTool ~= nil then
		ToolAnimations = CurrentTool:FindFirstChild("Animations")

		if ToolAnimations then
			for _,State in pairs(ToolAnimations:GetChildren()) do
				if ToReload[State.Name] == nil then
					ToReload[State.Name] = true
				end
			end
		end
	else
		ToolAnimations = nil
	end
	
	for State,_ in pairs(Module.Animations) do
		if ToReload[State] == nil then
			ToReload[State] = true
		end
	end

	for State,_ in pairs(ToReload) do
		Module:Reload(State)
	end
end

function Module:Disable()
	if not Module.Enabled then
		return
	end

	Module:Stop(Module.CurrentState)
	Module.CurrentState = nil

	for _,Connect in pairs(Connections) do
		Connect:Disconnect()
	end

	for _,Connect in pairs(PlayConnections) do
		Connect:Disconnect()
	end
	
	for _,Connect in pairs(ToolConnections) do
		Connect:Disconnect()
	end

	table.clear(Connections)
	table.clear(PlayConnections)
	table.clear(ToolConnections)
	
	Module.Enabled = false
end

function Module:Enable()
	if Module.Enabled then
		return
	end

	ResetSeed()

	Module:ReloadAll()
	
	table.insert(Connections, Character.ChildAdded:Connect(ToolAdded))
	
	if Character:FindFirstChildWhichIsA("Tool") then
		ToolAdded(Character:FindFirstChildWhichIsA("Tool"))
	end
	
	Module.Enabled = true
end

--Public: Initialize
function Module.Init()
	Module:Enable()
end

--Return
return Module