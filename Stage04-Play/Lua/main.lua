--[[
Write the play() function
Write the takeAction() function
Write the checkExit() function
]]
kb 			= require"lib.kboard"
Console 	= require "lib.console"
Narrator 	= require "narrator"
Player 		= require "player"
Shared 		= require "shared"
Game 		= require "game"
--[[
global variables needed are dictionaries of Items, Enemies and Locations.
All global variables are stored in 'Shared.lua' and prefixed with Shared.
e.g. Shared.Items = {} holds a dictionary of Item objects available to any file via 'require "Shared"
]]

string.Split = Shared.Split
string.Trim = Shared.Trim
table.IsEmpty = Shared.IsEmpty

local function CheckExit(here, direction)
	--[[ check if next location has an itemRequired to enter ]]
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

local function TakeAction(here, exits, row)
	--[[ choose player action ]]
	local options = {}
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
	local choice = options[kb.menu("What next?", options, row)]
	-- choice examples: "Attack...", Examine...", "Go..." etc
	if choice:find("Quit") ~= nil then
		return "quit", ""
	elseif choice:find("Go ") ~= nil then
		-- exit format "Go east"
		return "go", choice:sub(4)
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
		local row = Console.Clear()
		local title = "Choose your option:"
		local options = {}
		for _, item in pairs(Player.Inventory) do
			table.insert(options, "Examine "..item)
			table.insert(options, "Drop "..item)
		end
		table.insert(options, "Exit menu")
		choice = options[kb.menu(title, options, row)]
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
		end
		if #Player.Inventory == 0 then
			choice = "Exit menu"
		end
	end
end

local function Play()
	--[[ make choices about items in locations, inventory, move around etc ]]
	local action, param
	local here = Shared.Locations[Shared.CurrentLocation]	-- Location object
	local exits = {}
	local row = Console.Clear()
	exits, row = here:DisplayLocation() 					-- returns available exits and current console row
	if not Console.IsConsole then row = -1 end				-- prevent 033[7;0H in ZeroBrane
	action, param = TakeAction(here, exits, row)
	--row = Console.Clear()
	if action == "go" then
		-- check if next location has item_required
		Shared.CurrentLocation = CheckExit(here, param)		
	elseif action == "examine" then
		print("You examine the "..param)
		print(Shared.Items[param]:GetDescription())
		Shared.Sleep(2)
	elseif action == "take" then
		print("You take the "..param.." and put it in your backpack")
		Player.AddToInventory(param)
		here:RemoveItem(param)
		Shared.Sleep(2)
	elseif action == "inventory" then
		-- this action will only appear if Player.Inventory is not empty
		UseInventory()
	elseif action == "quit" then
		Shared.Gamestate = Shared.Gamestates['quit']
	end
end

local function main()
	--[[ Everything runs from here ]]
	Console.Resize(80, 25, false)
	local row = Console.Clear()
	if Shared.Debug then							-- allow disabling debug mode
		Shared.Debug = not kb.getBoolean("Debug mode is ON. Do you want to disable debug mode?", row)
		row = Console.Clear()
	end
	if Game.LoadGame() then						-- load from file or use hard coded game if none exist
		--[[ game loop ]]
		Shared.Gamestate = Shared.Gamestates['play']							-- start at 'play'
		while Shared.Gamestate < Shared.Gamestates['quit'] do					-- continue game while in 'menu', 'play' gamestate
			Play()																-- play the game. Gamestate can be changed in multiple places
		end
		Console.Clear()	
		for _, message in ipairs(Narrator.EndMessage) do
			print(message)
		end
	else
		print("Please correct errors in game locations before trying again")
	end
	if Console.IsConsole then
		io.write("Enter to quit")
		io.read()
	end
end
-- Program runs from here:
main()
