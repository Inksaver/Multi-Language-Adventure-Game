--[[
kboard -> modified menu and other functions to improve appearance
console -> modified clear() and resize() to return row and width
new class -> Debug all debug output moved here
game -> loadFromFile improvements and display debug for all objects
game -> DisplayIntro improved appearance
game -> ModifyPlayer cosmetic changes
location -> update displayLocation
player -> Attack() updated, removed DisplayPlayer()
shared -> FormatLine and PrintLine added, 3 new remove value/key/item from table
]]

local kb = require"lib.kboard"
local Console = require "lib.console"
local Narrator = require "narrator"
local Player = require "player"
local Shared = require "shared"
local Game = require "game"
--[[
global variables needed are dictionaries of Items, Enemies and Locations.
All global variables are stored in 'Shared.lua' and prefixed with Shared.
e.g. Shared.dictItems = {} holds a dictionary of Item objects available to any file via 'require("Shared")
]]

string.Split = Shared.Split
string.Trim = Shared.Trim
table.IsEmpty = Shared.IsEmpty
table.RemoveKey = Shared.RemoveKey
string.PadRight = Shared.PadRight

local function CheckExit(here, direction)
	--[[ check if next location has an item_required to enter ]]
	local nextLocation
	if direction == "north" then
		nextLocation = Shared.Locations[here:GetToNorth()]
	elseif direction == "east" then
		nextLocation = Shared.Locations[here:GetToEast()]
	elseif direction == "south" then
		nextLocation = Shared.Locations[here:GetToSouth()]
	elseif direction == "west" then
		nextLocation = Shared.Locations[here:GetToWest()]
	end	
	
	local itemRequired = nextLocation:GetItemRequired()	
	if itemRequired ~= "" then					-- key or other item needed
		if Shared.InList(Player.Inventory, itemRequired) then -- is it in player inventory?
			print("You use the "..itemRequired.." in your inventory to enter...")
		else
			print("You need "..itemRequired.." in your inventory to go that way")
			nextLocation = here
		end
		Shared.Sleep(2)
	end
	
	return nextLocation:GetName()	
end

local function Fight(here)
	--[[ pick a fight with an enemy ]]
	local row, width = Console.Resize(80, 25, true) -- 0, 80 if console else -1, 0 
	local enemy = Shared.Enemies[here:GetEnemy()]	-- use variable for convenience
	local weapon = "fist"
	if #Player.Inventory > 0 then
		weapon = Player.Inventory[kb.Menu("Choose your weapon", Player.Inventory, row, width)]
	end
	print(Player.Attack(here, weapon):PadRight(Console.WindowWidth, " "))						-- player.attack() returns a string message
	local message = ""
	if enemy:GetHealth() == 0 then
		message = "The "..enemy:GetName().." has been defeated"
		if enemy:GetDropItem() ~= "" then
			here:AddItem(enemy:GetDropItem())
			message = message .." and dropped a ".. enemy:GetDropItem()
		end
		here:SetEnemy("")	
	else
		message = enemy:Attack(Player)
	end
	print(message:PadRight(Console.WindowWidth, " "))									-- print attack details
	
	if Player.Health == 0 then
		print("You died at the hands of the "..enemy:GetName():PadRight(Console.WindowWidth, " "))
		Shared.Sleep(2)
		print(("The game is over!"):PadRight(Console.WindowWidth, " "))
		Shared.Sleep(2)
		Shared.Gamestate = Shared.Gamestates['dead']-- this breaks the gameloop in main()
	end
end	

local function TakeAction(here, exits, row)
	--[[ choose player action ]]
	local options = {}
	-- check for enemies
	local enemy = here:GetEnemy()
	if enemy ~= "" then
		table.insert(options, "Attack "..enemy.. "!")	-- add "Attack..." to options
	end
	-- examine / take any items
	local items = here:GetItems()
	if #items > 0 then
		for _, item in ipairs(items) do
			table.insert(options, "Examine "..item)
			table.insert(options, "Take "..item)
		end
	end
	-- open inventory
	if #Player.Inventory > 0 then
		table.insert(options, "Open your inventory")
	end
	-- take an exit
	if #exits > 0 then
		for _, exit in pairs(exits) do
			table.insert(options, "Go "..exit)
		end
	end
	
	-- quit the game	
	table.insert(options, "Quit")
	local choice = options[kb.Menu("What next?", options, row, 0)]
	-- choice examples: "Attack...", Examine...", "Go..." etc
	if choice:find("Attack") ~= nil then
		return "fight",""	
	elseif choice:find("Quit") ~= nil then
		return "quit", ""
	elseif choice:find("Go ") ~= nil then
		-- exit format "Go east -> coridoor" needs to be parsed differently
		local data = choice:Split("->")			-- "Go east -> coridoor" -> "Go east ", " corridoor"
		local direction = data[1]:sub(4):Trim() -- "Go east " -> "east"
		return "go", direction
	elseif choice:find("Examine") ~= nil then
		return "examine", choice:sub(9)
	elseif choice:find("Take") ~= nil then
		return "take", choice:sub(6)
	elseif choice:find("inventory") ~= nil then
		-- open inventory
		return "inventory", ""
	end
end

local function UseInventory()
	local choice = ""
	while choice ~= "Exit menu" do
		local row, width = Console.Clear()
		local title = "Choose your option:"
		local title = "Inventory: ("..Player.Health.." Health) Choose your option:"
		local options = {}
		for _, item in pairs(Player.Inventory) do
			table.insert(options, "Examine "..item)
			table.insert(options, "Drop "..item)
		end
		if #Player.Inventory >= 2 then
			table.insert(options, "Craft a new item")
		end
		table.insert(options, "Exit menu")
		choice = options[kb.Menu(title, options, row, width)]
		if choice:find("Examine") ~= nil then
			local item = choice:sub(9)
			print("You examine the ".. item)
			print("It is "..Shared.Items[item]:GetDescription())
			if Shared.Items[item].type == "Weapon" then
				print("It is a Weapon with "..Shared.Items[item]:GetDamage().." hit points!")
			end
			Shared.Sleep(3)
		elseif choice:find("Drop") ~= nil then
			local item = choice:sub(6)
			print("You drop the ".. item)
			Shared.Locations[Shared.CurrentLocation]:AddItem(item)
			Player.RemoveFromInventory(item)
			Shared.Sleep(3)
		elseif choice:find("Craft") ~= nil then
			-- open a new menu to select 2 items
			options = {}
			for _, value in pairs(Player.Inventory) do
				table.insert(options, value)
			end
			Console.Clear()
			local choice = kb.Menu("Choose your first item", options, row, width)
			local item1 = options[choice]
			table.remove(options, choice)
			Console.Clear()
			choice = kb.Menu("Choose your second item", options, row, width)
			local item2 = options[choice]
			local newItem = ""
			for key, value in pairs(Shared.Items) do
				local content = value:GetCraftItems()
				if content:find(item1) and content:find(item2) then
					newItem = key
				end
			end
			if newItem == "" then
				print(("Your crafting skills are inadequate"):PadRight(Console.WindowWidth, " "))
			else
				print(("You crafted a "..newItem):PadRight(Console.WindowWidth, " "))
				Player.AddToInventory(newItem)
				if Shared.Items[item1]:GetUses() == 1 then
					Player.RemoveFromInventory(item1)
				end
				if Shared.Items[item2]:GetUses() == 1 then
					Player.RemoveFromInventory(item2)
				end
			end
			Shared.Sleep(3)
		end
		if #Player.Inventory == 0 then
			choice = "Exit menu"
		end
	end
end

local function Play()
	--[[ make choices about items in locations, inventory, move around etc ]]
	local action, param
	local row = Console.Clear()
	local here = Shared.Locations[Shared.CurrentLocation]	-- Location object
	local exits = {}
	exits, row = here:DisplayLocation() 					-- returns available exits and current console row
	if not Console.IsConsole then row = -1 end				-- prevent /033[7;0H in ZeroBrane
	action, param = TakeAction(here, exits, row)
	--row = Console.Clear()
	if action == "go" then
		-- check if next location has item_required
		Shared.CurrentLocation = CheckExit(here, param)		
	elseif action == "examine" then
		print("You examine the "..param)
		print(Shared.Items[param]:GetDescription())
		if Shared.Items[param].type == "Weapon" then
			print("It is a Weapon with "..Shared.Items[param]:GetDamage().." hit points!")
		end
		Shared.Sleep(2)
	elseif action == "take" then
		print("You take the "..param.." and put it in your backpack")
		Player.AddToInventory(param)
		here:RemoveItem(param)
		Shared.Sleep(2)
	elseif action == "inventory" then
		-- this action will only appear if Player.Inventory is not empty
		UseInventory()
	elseif action == "fight" then
		Fight(here) -- gamestate set to 'dead' if failed to win
		Shared.Sleep(4)
	elseif action == "quit" then
		Shared.Gamestate = Shared.Gamestates['quit']
	end
end

local function main()
	--[[ Everything runs from here ]]
	Console.Resize(80, 25, false)
	--[[ Windows only: If you do not use os.system('cls') before trying to set
		cursor position in kb methods it shows the escape codes!]]
	local row, width = Console.Clear()								-- 0, 80 if console else -1, 0
	if Shared.Debug then											-- allow disabling debug mode
		Shared.Debug = not kb.getBoolean("Debug mode is ON. Do you want to disable debug mode?", row, width)
		Console.Clear()
	end
	if Game.LoadGame() then											-- load from file or use hard coded game if none exist
		--[[ game loop ]]
		Shared.Gamestate = Shared.Gamestates['play']				-- start at 'play'
		while Shared.Gamestate < Shared.Gamestates['quit'] do		-- continue game while in 'menu', 'play' gamestate
			Play()													-- play the game. Gamestate can be changed in multiple places
		end
		--[[ game over ]]
		Console.Clear()	
		if Shared.Gamestate == Shared.Gamestates['dead'] then
			for _, message in ipairs(Narrator.DeathMessage) do
				print(message)
			end
		end
		for _, message in ipairs(Narrator.EndMessage) do
			print(message)
		end
	else
		print("Please correct errors in game locations before trying again")
	end
	if Console.IsConsole then	-- ? running in a console/terminal
		io.write("Enter to quit")
		io.read()
	end
end
-- Program runs from here:
main()