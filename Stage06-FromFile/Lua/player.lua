local Player = {}
local Shared = require("shared")
--static player class - no constructor required
Player.Name 		= ""
Player.Health 		= 100
Player.Strength 	= 100
Player.Character 	= ""
Player.Characters 	= {'fighter','wizard','ninja','priest'}
Player.Inventory 	= {}
Player.ItemInHand 	= {}

local function TableIndex(tbl, item)
	for key, value in pairs(tbl) do
		if item == value then
			return key			-- found match
		end
	end
	
	return 0
end

function Player.AddToInventory(item)
	if TableIndex(Player.Inventory, item) == 0 then
		table.insert(Player.Inventory, item)
	end
end

function Player.Attack(here)
	local enemy = here:GetEnemy()
	local message = "You attack the "..enemy
	--[[
	if item_in_hand != "":
		if isinstance(shared.items[item_in_hand], weapon.Weapon):
			damage = shared.items[item_in_hand].damage
			message += f"with the {item_in_hand} inflicting {damage} damage points"
	else:
		message += " with your fist inflicting 10 damage points"
	]]
	local damage = 10
	local useItem = "your fist"
	for _, item in ipairs(Player.Inventory) do
		if Shared.Items[item].type == "Weapon" then
			damage = Shared.Items[item]:GetDamage()
			useItem = " the ".. item
			break
		end
	end
	
	message = message .. " with "..useItem.." inflicting "..damage.." damage points"
			
	Shared.Enemies[enemy]:ReceiveAttack(damage)
	
	return message	
end

function Player.DisplayInventory()
	--[[ display player;s inventory ]]
	if #Player.Inventory == 0 then
		print("Your inventory is empty")
	else
		print("In your inventory you have:")
		print(table.concat(Player.Inventory, ", "))
	end
end

function Player.DisplayPlayer()
	--[[ main use for debug. prints all player properties ]]
	print(string.rep('═', 80))
	print("Player properties:")
	print(string.rep('═', 80))
	print("Characters available: ".. table.concat(Player.Characters, ", "))
	print(string.rep('═', 80))
	print("Name:                 "..Player.Name)
	print("Health:               "..Player.Health)
	print("Strength:             "..Player.Strength)
	print("Character:            "..Player.Character)
	print("Inventory:            "..table.concat(Player.Inventory, ", "))
	print(string.rep('═', 80))
end

function Player.GetProperty(propertyName)
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

function Player.ReceiveAttack(damage)
	Player.Health = Player.Health - damage
	if Player.Health <= 0  then
		Player.Health = 0
	end
end

function Player.RemoveFromInventory(item)
	local index = TableIndex(Player.Inventory, item)
	if index > 0 then
		table.remove(Player.Inventory, index)
	end
end

function Player.UpdateStats(characterIndex)
	--[[ modify health and strength depending on character selected ]]
	Player.Health = Player.Health +  characterIndex * 2
	Player.Strength = Player.Health - characterIndex * 2
end

return Player

