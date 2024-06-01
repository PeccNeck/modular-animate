--!strict
--[[
	@PeccNeck:21005600
	   Dec 11, 2022
			--
	   Dec 18, 2022
					  ]]--

--Tables
local Module = {}
local External = {}

type AnimationsTable = {
	[string]: {
		[string]: {
			[string]: {
				number | string
			}
		}
	}
}

local AnimationsR15: AnimationsTable = {
	Movement = {
		idle = {
			Animation1 = {"http://www.roblox.com/asset/?id=507766388", 9},
			Animation2 = {"http://www.roblox.com/asset/?id=507766666", 1}
		},
		walk = {
			WalkAnim = {"http://www.roblox.com/asset/?id=913402848", 10}
		},
		run = {
			RunAnim = {"http://www.roblox.com/asset/?id=913376220", 10}
		},
		swim = {
			Swim = {"http://www.roblox.com/asset/?id=913384386", 10}
		},
		swimidle = {
			SwimIdle = {"http://www.roblox.com/asset/?id=913389285", 10}
		},
		jump = {
			JumpAnim = {"http://www.roblox.com/asset/?id=507765000", 10}
		},
		fall = {
			FallAnim = {"http://www.roblox.com/asset/?id=507767968", 10}
		},
		climb = {
			ClimbAnim = {"http://www.roblox.com/asset/?id=507765644", 10}
		},
		sit = {
			SitAnim = {"http://www.roblox.com/asset/?id=2506281703", 10}
		}
	},
	
	Emote = {
		wave = {
			WaveAnim = {"http://www.roblox.com/asset/?id=507770239", 10}
		},
		point = {
			PointAnim = {"http://www.roblox.com/asset/?id=507770453", 10}
		},
		dance = {
			Animation1 = {"http://www.roblox.com/asset/?id=507771019", 10},
			Animation2 = {"http://www.roblox.com/asset/?id=507771955", 10},
			Animation3 = {"http://www.roblox.com/asset/?id=507772104", 10}
		},
		dance2 = {
			Animation1 = {"http://www.roblox.com/asset/?id=507776043", 10},
			Animation2 = {"http://www.roblox.com/asset/?id=507776720", 10},
			Animation3 = {"http://www.roblox.com/asset/?id=507776879", 10}
		},
		dance3 = {
			Animation1 = {"http://www.roblox.com/asset/?id=507777268", 10},
			Animation2 = {"http://www.roblox.com/asset/?id=507777451", 10},
			Animation3 = {"http://www.roblox.com/asset/?id=507777623", 10}
		},
		laugh = {
			LaughAnim = {"http://www.roblox.com/asset/?id=507770818", 10}
		},
		cheer = {
			CheerAnim = {"http://www.roblox.com/asset/?id=507770677", 10}
		}
	},
	
	Tools = {
		toolnone = {
			ToolNoneAnim = {"http://www.roblox.com/asset/?id=507768375", 10}
		},
		toolslash = {
			ToolSlashAnim = {"http://www.roblox.com/asset/?id=522635514", 10}
		},
		toollunge = {
			ToolLungeAnim = {"http://www.roblox.com/asset/?id=522638767", 10},
		}
	}
}

local AnimationsR6: AnimationsTable = {
	Movement = {
		idle = {
			Animation1 = {"http://www.roblox.com/asset/?id=180435571", 9},
			Animation2 = {"http://www.roblox.com/asset/?id=180435792", 1}
		},
		walk = {
			WalkAnim = {"http://www.roblox.com/asset/?id=180426354", 10}
		},
		run = {
			RunAnim = {"http://www.roblox.com/asset/?id=180426354", 10}
		},
		swim = {
			Swim = {"http://www.roblox.com/asset/?id=180426354", 10}
		},
		swimidle = {
			SwimIdle = {"http://www.roblox.com/asset/?id=180426354", 10}
		},
		jump = {
			JumpAnim = {"http://www.roblox.com/asset/?id=125750702", 10}
		},
		fall = {
			FallAnim = {"http://www.roblox.com/asset/?id=180436148", 10}
		},
		climb = {
			ClimbAnim = {"http://www.roblox.com/asset/?id=180436334", 10}
		},
		sit = {
			SitAnim = {"http://www.roblox.com/asset/?id=178130996", 10}
		}
	},
	
	Emote = {
		wave = {
			WaveAnim = {"http://www.roblox.com/asset/?id=128777973", 10}
		},
		point = {
			PointAnim = {"http://www.roblox.com/asset/?id=128853357", 10}
		},
		dance = {
			Animation1 = {"http://www.roblox.com/asset/?id=182435998", 10},
			Animation2 = {"http://www.roblox.com/asset/?id=182491037", 10},
			Animation3 = {"http://www.roblox.com/asset/?id=182491065", 10}
		},
		dance2 = {
			Animation1 = {"http://www.roblox.com/asset/?id=182436842", 10},
			Animation2 = {"http://www.roblox.com/asset/?id=182491248", 10},
			Animation3 = {"http://www.roblox.com/asset/?id=182491277", 10}
		},
		dance3 = {
			Animation1 = {"http://www.roblox.com/asset/?id=182436935", 10},
			Animation2 = {"http://www.roblox.com/asset/?id=182491368", 10},
			Animation3 = {"http://www.roblox.com/asset/?id=182491423", 10}
		},
		laugh = {
			LaughAnim = {"http://www.roblox.com/asset/?id=129423131", 10}
		},
		cheer = {
			CheerAnim = {"http://www.roblox.com/asset/?id=129423030", 10}
		}
	},
	
	Tools = {
		toolnone = {
			ToolNoneAnim = {"http://www.roblox.com/asset/?id=182393478", 10}
		},
		toolslash = {
			ToolSlashAnim = {"http://www.roblox.com/asset/?id=129967390", 10}
		},
		toollunge = {
			ToolLungeAnim = {"http://www.roblox.com/asset/?id=129967478", 10},
		}
	}
}

-- Private
local function GetScript()
	local FullName = debug.info(3, "s")
	local SplitName = FullName:split(".")
	return SplitName[#SplitName]
end

--Find or create dependencies
External.Main = require(script.Parent.Main)
External.Animate = External.Main:Get("Animate")

local Config = External.Main.Config

local print = External.Main.print
local warn = External.Main.warn

--Public
Module.LastAnimations = {}

function Module:ResetSeed()
	local Clock = tostring(os.clock())
	local ClockSplit =  string.split(Clock, ".")
	Clock = ClockSplit[1] .. ClockSplit[2]

	local Seed1 = tonumber(string.sub(Clock, -10, -1))

	if not Seed1 then
		-- This will literally never happen but the typechecker is a little baby
		return
	end

	-- local Seed1 = ClockSeed
	local Seed2 = tick()

	math.randomseed(Seed2)
	local mul = 1
	if math.random(0, 1) == 0 then
		mul = -1
	end

	local Seed = Seed2 + (Seed1 * mul)
	-- math.randomseed(Seed)

	return Seed
end

function Module:GetHeightScale(Humanoid: Humanoid)
	local Scale = 1
	
	if Humanoid.AutomaticScalingEnabled then
		Scale += (Humanoid.HipHeight - Config.HumanoidHipHeight) * Config.ScaleDampeningPercent / Config.HumanoidHipHeight
	end
	
	return Scale
end

function Module:PlayRandom(Name: string, Speed: number?, Fade: number?, Anims: {}, Environment: string?)
	local SelectAnim = Anims[math.random(1, #Anims)]
	
	-- deprecated? duly noted and ignored; we need the actual fenv itself, not a traceback
	-- local FEnv = getfenv(2)
	-- FEnv.LastAnimation[Name] = SelectAnim
	if not Environment then
		Environment = GetScript()
		-- print(Environment)
	end

	Module.LastAnimations[Environment][Name] = SelectAnim

	External.Animate:Play(SelectAnim, Speed, Fade)
	return SelectAnim, External.Animate:Get(SelectAnim)
end

function Module:PlayOnLoop(Name: string, Speed: number?, Fade: number?, Anims: {}, WeightedAnims: {})
	
	-- still not a use-case for debug.info, roblox
	-- local FEnv = getfenv(2)
	-- setfenv(self.PlayOnLoop, FEnv)

	local Environment = GetScript()
	-- print(Environment)
	
	local GetAnims = {}
	for _,Anim in pairs(Anims) do
		table.insert(GetAnims, External.Animate:Get(Anim[1]))
	end

	if table.find(GetAnims, nil) then
		warn("Common: Failed to randomize", tostring(Name) .. "! (One or more animations missing)")
		return {}
	end

	local Connects = {}

	for _,Anim in pairs(GetAnims) do
		local Connect

		if Anim.Looped then
			Connect = Anim.DidLoop:Connect(function()
				print("Common: DidLoop")
				External.Animate:Stop(Module.LastAnimations[Environment][Name], Fade)
				Module:PlayRandom(Name, Speed, Fade, WeightedAnims, Environment)
			end)
		else
			Connect = Anim.Stopped:Connect(function()
				print("Common: Ended")
				Module:PlayRandom(Name, Speed, Fade, WeightedAnims, Environment)
			end)
		end

		table.insert(Connects, Connect)
	end

	return Connects
end

function Module:GetDefaultAnimations(Humanoid: Humanoid)
	if Humanoid.RigType == Enum.HumanoidRigType.R6 then
		return AnimationsR6
	else
		return AnimationsR15
	end
end

return Module