--!strict
--[[
	@PeccNeck:21005600
	   Nov 16, 2022
	        --
	   Dec 19, 2022
					  ]]--

--Get services
local RunService = game:GetService("RunService")

--Tables
local Module = {}
local External = {}

local DefaultAnimations --this is retrieved from Common later

local Connections = {}
local PlayConnections = {}

--selene: allow(unscoped_variables)
-- LastAnimation = {}

--Find or create dependencies
local Origin = script.Parent.Parent
local Character = Origin.Parent
local Humanoid = Character:WaitForChild("Humanoid")

--local KRemote = Origin:WaitForChild("KeyframeReached")
--local MRemote = Origin:WaitForChild("MarkerReached")

local StateEvent = Origin:FindFirstChild("MovementStateChanged")

External.Main = require(script.Parent.Main)
External.Animate = External.Main:Get("Animate")
External.Common = External.Main:Get("Common")

local LastAnimation = {}
External.Common.LastAnimations.Movement = LastAnimation

local Config = External.Main.Config

local print = External.Main.print
local warn = External.Main.warn

--Global variables
local JumpAnimTime = 0
local DoubleTransition = (Config.TransitionTime or 0.1) * 2
local QuadTransition = DoubleTransition * 2

--Module variables
Module.Enabled = false
Module.Animations = {}
Module.CurrentState = ""

--Private
local function ResetSeed()
	local Seed = External.Common:ResetSeed()
	math.randomseed(Seed)

	return Seed
end

local function OnRunning(Speed: number)
	local NewState = Module.CurrentState
	local Scale = 1

	if Speed <= 0.05 then
		NewState = "idle"
	else
		Scale = Speed / Config.WalkSpeed
		if Speed <= (Config.WalkSpeed * Config.WalkPercent) then
			NewState = "walk"
			Scale *= (1 / Config.WalkPercent)
		else
			NewState = "run"
		end
		Scale /= External.Common:GetHeightScale(Humanoid)
	end

	if Module.CurrentState == NewState then
		Module:Speed(Module.CurrentState, Scale)
	else
		Module:SwitchStates(NewState, DoubleTransition, Scale)
	end
end

local function OnClimbing(Speed: number)
	local Scale = Speed / Config.ClimbSpeed

	if Module.CurrentState == "climb" then
		Module:Speed(Module.CurrentState, Scale)
	else
		Module:SwitchStates("climb", Config.TransitionTime, Scale)
	end
end

local function OnSwimming(Speed: number)
	local NewState = Module.CurrentState
	local Scale = 1
	
	if Speed >= 1 then
		Scale = Speed / Config.SwimSpeed
		NewState = "swim"
	else
		NewState = "swimidle"
	end

	if NewState == Module.CurrentState then
		Module:Speed(Module.CurrentState, Scale)
	else
		Module:SwitchStates(NewState, QuadTransition, Scale)
	end
end

local function OnJumping(State)
	if not State then
		return
	end
	
	JumpAnimTime = Config.JumpDuration
	
	Module:SwitchStates("jump", Config.TransitionTime)
end

local function OnFreefall()
	if JumpAnimTime <= 0 then
		--print("OnFreefall", State)
		Module:SwitchStates("fall", DoubleTransition)
	end
end

local function OnSeated()
	Module:SwitchStates("sit", Config.TransitionTime)
end

--[[
local function StateChanged(_, NewState)
	print(NewState)
	if NewState == Enum.HumanoidStateType.Freefall then
		OnFreefall()
		--print(NewState)
	end
end
--]]

local function DeltaTimer(_, Delta)
	if JumpAnimTime > 0 then
		JumpAnimTime -= Delta
	elseif Module.CurrentState == "jump" then
		--print("DeltaTimer")
		OnFreefall()
	end
end

--Public
function Module:SwitchStates(NewState: string, Fade: number?, Speed: number?)

	--print("Movement: SwitchStates", CurrentState, NewState, Fade, Speed)

	if Module.CurrentState == NewState or not Module.Enabled then
		return
	end

	local PreviousState = Module.CurrentState
	Module.CurrentState = NewState
	
	StateEvent:Fire(NewState)
	
	if Module.Animations[PreviousState] ~= nil then
		Module:Stop(PreviousState, Fade)
	end

	if Module.Animations[NewState] ~= nil then
		Module:Play(NewState, Speed, Fade)
	end
end

function Module:Play(Name: string, Speed: number?, Fade: number?)
	
	Speed = Speed or 1
	Fade = Fade or Config.TransitionTime

	print("Movement: Play", Name, Speed, Fade)
	
	local Anims = Module.Animations[Name]
	if not Anims then
		warn("Movement: Failed to play", tostring(Name) .. "! (No animations found)")
		return false
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
	
	External.Common:PlayRandom(Name, Speed, Fade, WeightedTable)
	
	if #WeightedTable <= 1 then
		return true
	end
	
	PlayConnections[Name] = External.Common:PlayOnLoop(Name, Speed, Fade, Anims, WeightedTable, LastAnimation)
	
	return true
end

function Module:Stop(Name: string, Fade: number?)
	
	
	
	Fade = Fade or Config.TransitionTime

	print("Movement: Stop", Name, Fade)
	
	local Anim = LastAnimation[Name]
	if not Anim then
		warn("Movement: Failed to stop", tostring(Name) .. "! (No animation found)")
		return false
	end
	
	local Disconnects = PlayConnections[Name] or {}
	for _,Disconnect in pairs(Disconnects) do
		Disconnect:Disconnect()
	end
	PlayConnections[Name] = nil
	
	External.Animate:Stop(Anim, Fade)
	--External.Animate:Weight(Anim, Fade, 0)
	
	return true
end

function Module:Speed(Name: string, Speed: number)
	
	--print("Movement: Speed", Name, Speed or 1)
	
	local Anims = LastAnimation[Name]
	if not Anims then
		warn("Movement: Failed to play", tostring(Name) .. "! (No animations found)")
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
	
	local AnimsFolder = Origin:FindFirstChild("Animations")
	
	if AnimsFolder and AnimsFolder:FindFirstChild(Name) then
		for _,Anim in pairs(AnimsFolder[Name]:GetChildren()) do
			local AnimName = External.Animate:Load(Name .. "/" .. Anim.Name, Anim.AnimationId)
			local Weight = (Anim:FindFirstChild("Weight") or {Value = 10}).Value
			
			table.insert(LoadedAnims, {AnimName, Weight})
		end
		
	elseif DefaultAnimations[Name] then
		for Anim,AnimData in pairs(DefaultAnimations[Name]) do
			print(Anim)
			local AnimName = External.Animate:Load(Name .. "/" .. Anim, AnimData[1])
			
			table.insert(LoadedAnims, {AnimName, AnimData[2]})
		end
	end
	
	if #LoadedAnims > 0 then
		Module.Animations[Name] = LoadedAnims
		LastAnimation[Name] = LoadedAnims[1]
	end
	
	if Module.CurrentState == Name then
		Module:Play(Name)
	end
end

function Module:ReloadAll()
	DefaultAnimations = External.Common:GetDefaultAnimations(Humanoid).Movement
	
	for State,_ in pairs(DefaultAnimations) do
		Module:Reload(State)
	end
end

function Module:Disable()
	if not Module.Enabled then
		return
	end
	
	Module:Stop(Module.CurrentState)
	Module.CurrentState = ""
	
	for _,Connect in pairs(Connections) do
		Connect:Disconnect()
	end
	
	for _,Connect in pairs(PlayConnections) do
		Connect:Disconnect()
	end
	
	table.clear(Connections)
	table.clear(PlayConnections)
	Module.Enabled = false
end

function Module:Enable()
	if Module.Enabled then
		return
	end
	
	ResetSeed()
	
	Module:ReloadAll()
	
	table.insert(Connections, RunService.Stepped:Connect(DeltaTimer))
	
	table.insert(Connections, Humanoid.Running:Connect(OnRunning))
	table.insert(Connections, Humanoid.FreeFalling:Connect(OnFreefall))
	table.insert(Connections, Humanoid.Jumping:Connect(OnJumping))
	table.insert(Connections, Humanoid.Seated:Connect(OnSeated))
	table.insert(Connections, Humanoid.Climbing:Connect(OnClimbing))
	table.insert(Connections, Humanoid.Swimming:Connect(OnSwimming))
	--table.insert(Connections, Humanoid.StateChanged:Connect(StateChanged))
	
	--table.insert(Connections, KRemote.Event:Connect(KeyframeReached))
	
	Module.Enabled = true
end

--Public: Initialize
function Module.Init()
	Module:Enable()
end

--Return
return Module
