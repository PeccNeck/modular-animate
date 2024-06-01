--!strict
--[[
	@PeccNeck:21005600
	   Nov 07, 2022
	        --
	   Dec 18, 2022
					  ]]--

--Tables
local Main = {}
local Modules = {}

--Metatables
local DefaultConfig = {
	__index = {
		
		Debug = false,
		
		HumanoidHipHeight = 2,
		ScaleDampeningPercent = 1,
		
		ToolAttackTime = 0.3,
		JumpDuration = 0.31,
		
		ClimbSpeed = 5,
		SwimSpeed = 10,
		
		EmoteTransitionTime = 0.1,
		ToolTransitionTime = 0.1,
		TransitionTime = 0.1,
		
		WalkPercent = 0.5,
		WalkSpeed = 16,
	}
}
Main.Config = table.clone(DefaultConfig.__index)
setmetatable(Main.Config, DefaultConfig)


--Find or create dependencies
local SelfScript = script
local Source = SelfScript.Parent
local Origin = Source.Parent

--Private
local KRemote = Origin:FindFirstChild("KeyframeReached") or Instance.new("BindableEvent")
KRemote.Name = "KeyframeReached"
KRemote.Parent = Origin

local SubRemote = Origin:FindFirstChild("MarkerReached") or Instance.new("BindableEvent")
SubRemote.Name = "MarkerReached"
SubRemote.Parent = Origin

local StateEvent = Origin:FindFirstChild("MovementStateChanged") or Instance.new("BindableEvent")
StateEvent.Name = "MovementStateChanged"
StateEvent.Parent = Origin

local ERemote = Origin:FindFirstChild("PlayEmote") or Instance.new("BindableFunction")
ERemote.Name = "PlayEmote"
ERemote.Parent = Origin

local function Init(Name, Cancel)
	if not Cancel and Modules[Name].Init then
		local Success, Err = pcall(Modules[Name].Init)
		if not Success then
			Main.warn("Failed to initialize", Name, "|", Err)
		end
	end
end

--Public
function Main:Get(Name: string, CancelInit: boolean?)
	
	if Modules[Name] then
		return Modules[Name]
	end
	
	if Source:FindFirstChild(Name) and Source[Name]:IsA("ModuleScript") then
		-- i don't even know what this one means roblox
		Modules[Name] = require(Source[Name])
		Init(Name, CancelInit)
		return Modules[Name]
	end
	
	return nil
end

function Main.print(...)
	if Main.Config.Debug then
		-- cry about it; we're deliberately exploiting some goofy global nonsense here
		--selene: allow(incorrect_standard_library_use)
		script = getfenv(2).script
		print(...)
	end
end

function Main.warn(...)
	if Main.Config.Debug then
		--selene: allow(incorrect_standard_library_use)
		script = getfenv(2).script
		warn(...)
	end
end

--Public: Initialize
function Main.Init()
	local Config = Source.Parent:WaitForChild("Config")
	Source.Parent:WaitForChild("Animations", 1)
	
	local Humanoid = Source.Parent.Parent:WaitForChild("Humanoid")
	
	for _,v in pairs(Config:GetChildren()) do
		if v:IsA("ValueBase") then
			Main.Config[v.Name] = v.Value
		end
	end
	
	local Dir = "R15"
	if Humanoid.RigType == Enum.HumanoidRigType.R6 then
		Dir = "R6"
	end
	
	if Config:FindFirstChild(Dir) then
		for _,v in pairs(Config[Dir]:GetChildren()) do
			if v:IsA("ValueBase") then
				Main.Config[v.Name] = v.Value
			end
		end
	end
		
	if not game:GetService("RunService"):IsStudio() then
		Main.Config.Debug = false
	end
	
	--print(Main.Config)
end

--Return
return Main