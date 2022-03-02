local Player = {}
local Shared = require("shared")
--static player class - no constructor required
Player.Name 		= ""
Player.Health 		= 100
Player.Strength 	= 100
Player.Character 	= ""
Player.Characters 	= {}
Player.Inventory 	= {}

function Player.AddToInventory(item)
	--[[ add an item to player inventory ]]
end

function Player.DisplayInventory()
	--[[ display player's inventory ]]
end

function Player.DisplayPlayer()
	--[[ main use for debug. prints all player properties ]]
	print(string.rep('═', 60))
	print("Player properties:")
	print(string.rep('═', 60))
	print("Characters available: ".. table.concat(Player.Characters, ", "))
	print(string.rep('═', 60))
	print("Name:                 "..Player.Name)
	print("Health:               "..Player.Health)
	print("Strength:             "..Player.Strength)
	print("Character:            "..Player.Character)
	print("Inventory:            "..table.concat(Player.Inventory, ", "))
	print(string.rep('═', 60))
end

function Player.GetProperty(propertyName)
	--[[  used by narrator class to get a player property  ]]
	if propertyName:find("name") ~= nil then
		return Player.Name
	elseif propertyName:find("health") ~= nil then
		return Player.Health
	elseif propertyName:find("strength") ~= nil then
		return Player.Strength
	elseif propertyName:find("character") ~= nil then
		return Player.Character
	end
end

function Player.RemoveFromInventory(item)
	--[[  remove an item from player inventory ]]
end

function Player.UpdateStats(characterIndex)
	--[[ modify health and strength depending on character selected ]]
	Player.Health = Player.Health +  characterIndex * 2
	Player.Strength = Player.Strength - characterIndex * 2
end

return Player

