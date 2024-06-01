--[[
	@PeccNeck:21005600
	   Nov 08, 2022
					  ]]--

--Yield other scripts until internal loading has finished
local Yield = script:FindFirstChild("Yield") or Instance.new("BoolValue")
Yield.Name = "Yield"
Yield.Parent = script

--Yield until loading has completed
local Modules = script:WaitForChild("Modules")

--Do stuff
local Main = require(Modules:WaitForChild("Main"))

for _,Module in pairs(Modules:GetChildren()) do
	--print(Module)
	Main:Get(Module.Name)
end

Yield.Value = true