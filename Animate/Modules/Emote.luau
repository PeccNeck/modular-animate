--!strict
--[[
	@PeccNeck:21005600
	   Dec 08, 2022
	   	    --
	   Dec 19, 2022
					  ]]--

--Tables
local Module = {}
local External = {}

local DefaultAnimations --this is retrieved from Common later

local Loopables = {
	wave = false,
	point = false,
	dance = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}

local Connections = {}
local PlayConnections = {}

-- roblox linter is gonna have to live with this one, it's unscoped on purpose
-- at least selene can be silenced
--selene: allow(unscoped_variables)
-- LastAnimation = {}

--Find or create dependencies
local Origin = script.Parent.Parent
local Character = Origin.Parent
local Humanoid = Character:WaitForChild("Humanoid")

--local KRemote = Origin:WaitForChild("KeyframeReached")
--local MRemote = Origin:WaitForChild("MarkerReached")

local ERemote = Origin:FindFirstChild("PlayEmote")

local StateChangedEvent = Origin:FindFirstChild("MovementStateChanged")

External.Main = require(script.Parent.Main)
External.Animate = External.Main:Get("Animate")
External.Movement = External.Main:Get("Movement")
External.Common = External.Main:Get("Common")

local LastAnimation = {}
External.Common.LastAnimations.Emote = LastAnimation

local Config = External.Main.Config

local print = External.Main.print
local warn = External.Main.warn

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

local function PlayEmote(Name: string)
	if Module.Animations[Name] == nil then
		return false
	end
	
	local ToReturn = Module:SwitchStates(Name)
	return ToReturn
end

local function StateChanged(NewState)
	if Module.CurrentState ~= nil and NewState ~= "emote" then
		Module:SwitchStates(nil)
	end
end

--Public
function Module:SwitchStates(NewState: string?, Fade: number?, Speed: number?)

	--print("Emote: SwitchStates", Module.CurrentState, NewState, Fade, Speed)

	if Module.CurrentState == NewState then
		return true
	end

	local MovementState = External.Movement.CurrentState

	if MovementState ~= "idle" and MovementState ~= "emote" and Module.CurrentState == nil then
		return false
	end

	local PreviousState = Module.CurrentState

	Module.CurrentState = NewState

	if MovementState == "idle" and NewState ~= nil then
		External.Movement:SwitchStates("emote", Fade)
	elseif Module.Animations[PreviousState] ~= nil then
		Module:Stop(PreviousState, Fade)
	end
	
	if Module.Animations[NewState] ~= nil then
		Module:Play(NewState, Speed, Fade)
	end

	return true
end

function Module:Play(Name: string?, Speed: number?, Fade: number?)

	--print("Emote: Play", Name, Speed or 1, Fade or 0.1)
	
	Speed = Speed or 1
	Fade = Fade or Config.EmoteTransitionTime

	local Anims = Module.Animations[Name]
	if not Anims then
		warn("Emote: Failed to play", tostring(Name) .. "! (No animations found)")
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

	local SelectAnim, AnimInstance = External.Common:PlayRandom(Name, Speed, Fade, WeightedTable)
	LastAnimation[Name] = SelectAnim
	
	if Loopables[Name] and #WeightedTable > 1 then
		--print("Emote: Looping", Name)
		PlayConnections[Name] = External.Common:PlayOnLoop(Name, Speed, Fade, Anims, WeightedTable)
	elseif not Loopables[Name] then
		local Routine = coroutine.create(function()
			--print("Emote: Single-play", Name)
			if AnimInstance.Looped then
				AnimInstance.DidLoop:Wait()
			else
				AnimInstance.Stopped:Wait()
			end
			
			Module:SwitchStates(nil, Config.EmoteTransitionTime)
			External.Movement:SwitchStates("idle", Config.EmoteTransitionTime)
			--Module:Stop(Module.CurrentState, Config.EmoteTransitionTime)
			--Module.CurrentState = nil
			--External.Movement.CurrentState = "idle"
			--External.Movement:Play("idle", 1, Config.EmoteTransitionTime)
		end)
		
		coroutine.resume(Routine)
		
		task.delay(AnimInstance.Length + Config.EmoteTransitionTime, function()
			coroutine.close(Routine)
		end)
	end

	return true
end

function Module:Stop(Name: string?, Fade: number?)
	
	--print("Emote: Stop", Name, Fade or 0.1)
	
	Fade = Fade or Config.EmoteTransitionTime

	local Anim = LastAnimation[Name]
	if not Anim then
		warn("Emote: Failed to stop", tostring(Name) .. "! (No animation found)")
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

function Module:Speed(Name: string, Speed: number?)

	--print("Emote: Speed", Name, Speed or 1)

	local Anims = LastAnimation[Name]
	if not Anims then
		warn("Emote: Failed to speed", tostring(Name) .. "! (No animations found)")
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
	DefaultAnimations = External.Common:GetDefaultAnimations(Humanoid).Emote

	for State,_ in pairs(DefaultAnimations) do
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

	table.clear(Connections)
	table.clear(PlayConnections)
	
	ERemote.OnInvoke = function() end
	
	Module.Enabled = false
end

function Module:Enable()
	if Module.Enabled then
		return
	end

	ResetSeed()

	Module:ReloadAll()
	
	table.insert(Connections, StateChangedEvent.Event:Connect(StateChanged))

	ERemote.OnInvoke = PlayEmote
	
	Module.Enabled = true
end

--Public: Initialize
function Module.Init()
	Module:Enable()
end

--Return
return Module