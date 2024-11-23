--keep in mind this is from a game im just starting to make, so on a bigger game it may be bigger
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Modules = ServerStorage.Source.Modules
local Components = ServerStorage.Source.Components

local function AutoInitModules()
	for _, v in pairs(Modules:GetDescendants()) do
		if v.ClassName == "ModuleScript" then
			local mod = require(v)
			local init = mod["init"]
			if init ~= nil and type(init) == "function" then
				pcall(function()
					init()
					print(v.Name .. " Initialized!")
				end)
			end
		end
	end
end

local function LoadComponents()
	for _, v in pairs(Components:GetDescendants()) do
		if v.ClassName == "ModuleScript" then
			local comp = require(v)
			local Tag = comp["Tag"]
			local AddedComponent = comp["Added"]
			local RemovedComponent = comp["Removed"]

			if Tag ~= nil and type(Tag) == "string" then
				if AddedComponent ~= nil and type(AddedComponent) == "function" then
					CollectionService:GetInstanceAddedSignal(Tag):Connect(function(inst)
						AddedComponent(inst)
					end)

					for _, inst in pairs(CollectionService:GetTagged(Tag)) do
						AddedComponent(inst)
					end
				end
				if RemovedComponent ~= nil and type(RemovedComponent) == "function" then
					CollectionService:GetInstanceRemovedSignal(Tag):Connect(function(inst)
						RemovedComponent(inst)
					end)
				end
			end
		end
	end
end

AutoInitModules()
LoadComponents()

---------------------------

local HalloweenDoorModule = require(Modules.HalloweenDoorModule)
local ChildrenModule = require(Modules.ChildrenModule) --tbh, a bit confusing but theres literal children going too the halloween door lmao

HalloweenDoorModule.SetupPrompt()
HalloweenDoorModule.SetEvent("DoorOpen", function(enabled)
	local Prompt = HalloweenDoorModule.GetPrompt()
	if enabled then
		Prompt.ActionText = "Close Door"
		if #workspace.ChildrenRigs:GetChildren() <= 0 then
			local rig = HalloweenDoorModule.SpawnRig()
			ChildrenModule.SetupChild(rig)
		end
	else
		Prompt.ActionText = "Open Door"
	end
end)

ChildrenModule.SetEvent("PromptProcessed", function(rig)
	HalloweenDoorModule.DespawnRig(rig)
end)

----------------------------------------

local function UpdatePlayerCharacterCollisionGroup(char: Model)
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			v.CollisionGroup = "PlayerCharacter"
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	UpdatePlayerCharacterCollisionGroup(plr.Character or plr.CharacterAdded:Wait())
	plr.CharacterAdded:Connect(UpdatePlayerCharacterCollisionGroup)
end)
