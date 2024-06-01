--!strict
--[[
	@PeccNeck:21005600
	   Nov 07, 2022
	        --
	   Dec 19, 2022
					  ]]--

--Tables
local Module = {}
local External = {}

local AnimsById = {}

local Subscriptions = {}

--Find or create dependencies
local Origin = script.Parent.Parent
local Character = Origin.Parent
--local AnimsFolder = Origin:WaitForChild("Module.Animations")

local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local KRemote = Origin:FindFirstChild("KeyframeReached")

local SubRemote = Origin:FindFirstChild("MarkerReached")

External.Main = require(script.Parent.Main)

local print = External.Main.print
local warn = External.Main.warn

--Module variables
Module.Animations = {}

--Private
local function IsolateId(Id: number | string)
	local IdSplit = tostring(Id):split("=")
	IdSplit = IdSplit[#IdSplit]:split("/")

	return IdSplit[#IdSplit]
end

local function FormatId(Id: number | string)
	return "rbxassetid://" .. ((type(Id) == "number" and tostring(Id)) or IsolateId(Id))
end

local function KeyframeReached(...)
	KRemote:Fire(...)
end

local function MarkerReached(...)
	SubRemote:Fire(...)
end

--Public
function Module:GetAnimation(NameOrId: number | string)
	if AnimsById[tonumber(NameOrId)] then
		NameOrId = AnimsById[tonumber(NameOrId)]
	end
	return(Module.Animations[NameOrId][1])
end

function Module:Load(Name: string, Anim: Animation | number | string)
	local AnimInstance: Animation = nil

	if typeof(Anim) ~= "Instance" then
		local Id = FormatId(Anim)
		AnimInstance = Instance.new("Animation")
		AnimInstance.AnimationId = Id
	else
		AnimInstance = Anim
	end

	--selene: allow(shadowing)
	local Anim: Animation = AnimInstance

	local Id = IsolateId(Anim.AnimationId)
	if AnimsById[Id] then
		print("Animate: Id conflict when attempting to load", tostring(Id), "as", tostring(Name) .. "! (" .. AnimsById[Id] .. ")")
		return AnimsById[Id]
	end

	if rawget(Module.Animations, Name) then
		warn("Animate: Naming conflict when attempting to load", tostring(Name) .. "! (" .. Anim.AnimationId .. ")")
		local add = 0
		repeat add += 1 until not rawget(Module.Animations, Name .. tostring(add))
		print("Animate:", tostring(Name), "will be automatically renamed to", tostring(Name) .. tostring(add))
		Name ..= tostring(add)
	end

	local Success, AnimTrack = pcall(Animator.LoadAnimation, Animator, Anim)

	if not Success then
		warn("Animate: Failed to load", Name .. "! (" .. Anim.AnimationId .. ")")
		warn(Anim)
		return nil
	end
	
	local Connections = {AnimTrack.KeyframeReached:Connect(KeyframeReached)}
	
	for Sub,SubConnections in pairs(Subscriptions) do
		local Connect = AnimTrack:GetMarkerReachedSignal(Sub):Connect(function(Param)
			MarkerReached(Sub, Param)
		end)
		
		table.insert(Connections, Connect)
		table.insert(SubConnections, Connect)
	end
	
	Module.Animations[Name] = {AnimTrack, Connections}
	AnimsById[Id] = Name

	return Name
end

function Module:Play(Name: string, Speed: number?, Fade: number?, Weight: number?)
	
	--print("Animate: Play", Name, Speed, Fade, Weight)
	
	local Anim = Module.Animations[Name][1]
	if not Anim then
		warn("Animate: Failed to play", tostring(Name) .. "! (No loaded AnimationTrack found)")
		return false
	end
	
	Anim:Play(Fade or 0.1, Weight or 1, Speed or 1)
	return true
end

function Module:Stop(Name: string, Fade: number?)
	
	--print("Animate: Stop", Name, Fade)
	
	local Anim = Module.Animations[Name][1]
	if not Anim then
		warn("Animate: Failed to stop", tostring(Name) .. "! (No loaded AnimationTrack found)")
		return false
	end

	Anim:Stop(Fade or 0.1)
	return true
end

function Module:Speed(Name: string, Speed: number?)
	
	--print("Animate: Speed", Name, Speed)
	
	local Anim = Module.Animations[Name][1]
	if not Anim then
		warn("Animate: Failed to speed", tostring(Name) .. "! (No loaded AnimationTrack found)")
		return false
	end
	
	if not Anim.IsPlaying then
		print("Animate: Failed to speed", tostring(Name) .. ". (Animation is not playing)")
		return false
	end
	
	Anim:AdjustSpeed(Speed or 1)
	return true
end

function Module:Weight(Name: string, Fade: number?, Weight: number?)
	
	--print("Animate: Weight", Name, Fade, Weight)
	
	local Anim = Module.Animations[Name][1]
	if not Anim then
		warn("Animate: Failed to weight", tostring(Name) .. "! (No loaded AnimationTrack found)")
		return false
	end

	if not Anim.IsPlaying then
		print("Animate: Failed to weight", tostring(Name) .. ". (Animation is not playing)")
		return false
	end

	Anim:AdjustWeight(Weight or 1, Fade or 0.1)
	return true
end

function Module:SetPosition(Name: string, Position: number)
	local Anim = Module.Animations[Name][1]
	if not Anim then
		warn("Animate: Failed to seek", tostring(Name) .. "! (No loaded AnimationTrack found)")
		return false
	end

	if not Anim.IsPlaying then
		print("Animate: Failed to seek", tostring(Name) .. ". (Animation is not playing)")
		return false
	end

	Anim.TimePosition = Position
	return true
end

function Module:Unload(Name: string)
	local Anim = Module.Animations[Name]
	if #Anim < 1 then
		print("Animate: Failed to unload", tostring(Name) .. ". (No loaded AnimationTrack found)")
		return
	end
	
	local Id = IsolateId(Anim[1].Animation.AnimationId)
	
	AnimsById[Id] = nil
	Module.Animations[Name] = nil
	
	Anim[1]:Stop()
	
	for _,v in pairs(Anim[2]) do
		for _,Sub in pairs(Subscriptions) do
			local Index = table.find(Sub, v)
			if Index then
				table.remove(Sub, Index)
			end
		end
		v:Disconnect()
	end
	
	Anim[1]:Destroy()
	return
end

function Module:Subscribe(Name: string)
	if Subscriptions[Name] then
		print("Animate: Failed to subscribe", tostring(Name) .. ". (Already subscribed)")
		return
	end
	
	local Connections = {}
	for _,Anim in pairs(Module.Animations) do
		local Connect = Anim[1]:GetMarkerReachedSignal(Name):Connect(function(Param)
			MarkerReached(Name, Param)
		end)
		table.insert(Connections, Connect)
		table.insert(Anim[2], Connect)
	end
	
	Subscriptions[Name] = Connections
	print(Subscriptions)
end

function Module:Unsubscribe(Name: string)
	local Sub = Subscriptions[Name]
	if not Sub then
		print("Animate: Failed to unsubscribe", tostring(Name) .. ". (No subscription found)")
		return
	end
	
	for _,Anim in pairs(Module.Animations) do
		for AnimIndex,Disconnect in pairs(Anim[2]) do
			if table.find(Sub, Disconnect) then
				Disconnect:Disconnect()
				table.remove(Anim[2], AnimIndex)
				break
			end
		end
	end
	
	Subscriptions[Name] = nil
end

function Module:StopAll()
	for Name,_ in pairs(Module.Animations) do
		Module:Stop(Name)
	end
end

--Aliases
function Module:Seek(...)
	return(Module:SetPosition(...))
end

function Module:LoadAnimation(...)
	return(Module:Load(...))
end

function Module:PlayAnimation(...)
	return(Module:Play(...))
end

function Module:StopAnimation(...)
	return(Module:Stop(...))
end

function Module:UnloadAnimation(...)
	return(Module:Unload(...))
end

function Module:Get(...)
	return(Module:GetAnimation(...))
end

--Public: Initialize
function Module.Init()
	--Metatables
	setmetatable(Module.Animations, {
		__index = function()
			return {}
		end,
	})
end

--Return
return Module