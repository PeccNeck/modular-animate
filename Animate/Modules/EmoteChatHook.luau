--!strict
--[[
	@PeccNeck:21005600
	   Dec 09, 2022
					  ]]--

--Get services
local PlrService = game:GetService("Players")

--Tables
local Module = {}

--Find or create dependencies
local Origin = script.Parent.Parent
local Player = PlrService.LocalPlayer

local ERemote = Origin:WaitForChild("PlayEmote")

--Public
function Module.Init()
	--You could make a proper command out of this, but it requires forking Chat
	--Your discretion; otherwise, I'm literally just using the old solution
	Player.Chatted:Connect(function(msg)
		local emote = ""
		if string.sub(msg, 1, 3) == "/e " then
			emote = string.sub(msg, 4)
		elseif string.sub(msg, 1, 7) == "/emote " then
			emote = string.sub(msg, 8)
		else
			return
		end
		
		ERemote:Invoke(emote:lower())
	end)
end

return Module