local Game = {}

local kb 		= require "lib.kboard"
local Console 	= require "lib.console"
local Narrator	= require "narrator"
local Shared 	= require "shared"		-- repository for shared variables and functions
local Player 	= require "player"
local Item 		= require "item"		-- used to create Item objects
local Enemy 	= require "enemy"		-- used to create Enemy objects
local Weapon 	= require "weapon"		-- used to create Weapon objects
local Location 	= require "location" 	-- used to create Location objects

Game.Delay = 2							-- Game.Delay so can be modified outside of class
string.Split = Shared.Split
local function AddToItems(keyName, description,  craftitems, uses, container)
	--[[  helper function to create Item objects and store in Shared  ]]
	Shared.Items[keyName] = Item(keyName, description,  craftitems, uses, container)
end

local function AddToEnemies(keyName, description, strength, health, dropItem)
	--[[  helper function to create Enemy objects and store in Shared  ]]
	Shared.Enemies[keyName] = Enemy(keyName, description, strength, health, dropItem)
end

local function AddToLocations(keyName, description, tonorth, toeast, tosouth, towest, items, itemRequired, enemy)
	--[[  helper function to create Location objects and store in Shared  ]]
	Shared.Locations[keyName] = Location(keyName, description,
										tonorth, toeast, tosouth, towest,
										items, itemRequired, enemy) -- create the object and pass string variables
end

local function AddToWeapons(keyName, description, craftitems, uses, container, damage)
    Shared.Items[keyName] = Weapon(keyName, description, craftitems, uses, container, damage)
end

local function CheckLocations()
	--[[ Check keys used in locations are spelled correctly ]]
	local lib = {}
	function lib.Add(items, wrongKeys, direction)
		if direction ~= "" then
			-- see if the string .LocationToNorth eg "home" is in the keys table
			if items[direction] == nil then
				table.insert(wrongKeys, direction)
			end
		end
		return wrongKeys
	end
	local keys = {}
	local wrongKeys = {}
	local retValue = true
	-- check if each LocationToXXX corresponds with a key
	for k, _ in pairs(Shared.Locations) do
		table.insert(keys, k) --eg {"home", "room1", "hallway"}
	end
	if Shared.CurrentLocation == "" then
		print("Current location has not been set")
		return false
	end
	local items = Shared.Set(keys) --{"home" = true, "room1" = true, "hallway" = true}
	for k, location in pairs(Shared.Locations) do
		wrongKeys = lib.Add(items, wrongKeys, location:GetToNorth())
		wrongKeys = lib.Add(items, wrongKeys, location:GetToEast())
		wrongKeys = lib.Add(items, wrongKeys, location:GetToSouth())
		wrongKeys = lib.Add(items, wrongKeys, location:GetToEast())
	end	
	
	if #wrongKeys > 0 then
		Console.Clear()
        print("Errors found when creating default game")
		print("\nAvailable keys:\n")
		for k,v in ipairs(keys) do
			io.write(v..', ')
		end
        print("\nErroneous key names:\n")
		for k,v in ipairs(wrongKeys) do
			io.write(v .. ', ')
		end
        retValue = false
        io.write("\nEnter to continue") 
		io.read()
	else
		if Shared.Debug then
			local width = 112 -- set for demonstration only
			Console.Resize(width, 25, true)
			print("\nThe Dictionary Shared.Locations contains the following data:\n")
            print(string.rep('─', width))
            for key,value in pairs(Shared.Locations) do
				print("Key: "..Shared.PadRight(key, 22, " ").."│ Description: ".. value:GetDescription())
				print("North: "..Shared.PadRight(value:GetToNorth(), 20, " ")..
					  "| East: ".. Shared.PadRight(value:GetToEast(), 17, " ")..
					  "South: "..Shared.PadRight(value:GetToSouth(), 17, " ")..
					  "West: ".. value:GetToWest())
                io.write("Item required: "..Shared.PadRight(value:GetItemRequired(), 12, " "))
				local itemString = "| Items: "
				for _, v in ipairs(value:GetItems()) do -- empty table or list of string key values
					itemString = itemString ..(v.. ", ")
				end
				io.write(Shared.PadRight(itemString, 49, " "))
				io.write("Enemies: "..value:GetEnemy())
				io.write("\n")
				print(string.rep('─', width))
			end
            io.write("Enter to continue")    
			io.read()
			Console.Resize(80, 25, true)
		end
	end
	
	return retValue
end

local function CreateDefaultItems()
	--[[
	If no text files in Games then use default hard-coded game.
    ************Hard-coded default game*************
    add_to_items("item identifier", "description of item", Damage it can inflict on enemies)
    DO NOT USE \n (newline) characters as game saves will corrupt
    You can use the existing below or over-write them with your own objects and descriptions
    Make as many as you need
	]]
	
    AddToItems("key card", "a magnetic strip key card: Property of Premier Inns")
    AddToItems("torch", "a magnificent flaming wooden torch. Maybe this is in the wrong adventure game?")
    AddToItems("book", "a copy of 'Python in easy steps' by Mike McGrath")
    AddToItems("key", "a Yale front door key: covered in rat vomit...")
    AddToWeapons("sword", "a toy plastic sword: a dog has chewed the handle..Yuk!", {}, 0, '', 25)
  
	if Shared.Debug then
		local width = 112
		Console.Resize(width, 25, true)
        print("The Dictionary shared.items contains the following objects:")
        print("key/name  object description")
		print(string.rep("═", width))
        for key, value in pairs(Shared.Items) do
			io.write(Shared.PadRight(key, 10, " "))
			io.write(Shared.PadRight(value.type, 8, " "))
			io.write(value:GetDescription().."\n")
		end
        print(string.rep("═", width))
        io.write("Enter to continue")
		io.read()
		Console.Resize(80, 25, true)
	end
end

local function CreateDefaultEnemies()
	--[[
	 add_to_enemies("enemy name", "enemy description", # (Strength), # (Health),  *item key)
		    
    #: choose a number between 0 to 100 as a guide
    *: use the string key for the item, eg "torch"
    Shared.items["item name"]: Make sure this item has already been created in CreateItems()
	]]

    AddToEnemies("rat", "a vicious brown rat, with angry red eyes", 50, 50, "key")

    if Shared.Debug then
        print("\nThe Dictionary shared.enemies contains the following data:\n")
        print("key/name  description                  strength health drop item")
		print(string.rep("═", 80))
        for key,value in pairs(Shared.Enemies) do
            local description = value:GetDescription()
            if description:len() > 24 then
                description = description:sub(1,25).. "... "
            else
                description = Shared.PadRight(description, 28," ")
			end
			io.write(Shared.PadRight(key, 10," ")..description.. 
					 Shared.PadRight(tostring(value:GetStrength()), 9," ")..
					 Shared.PadRight(tostring(value:GetHealth()), 7," "))
            print(Shared.PadRight(value:GetDropItem(), 13," "))
		end
		print(string.rep("═", 80))
		io.write("Enter to continue")
		io.read()
	end
end 

local function CreateDefaultLocations()
	--[[ Create default game locations if not loading from file	]]
    AddToLocations("hotel room", "a damp hotel room",
                     "", "coridoor", "", "",
                     {"torch","book"},"key card")
    
    AddToLocations("coridoor", "a dark coridoor with a worn carpet",
                    "reception", "lift", "", "hotel room",
                    {"key card","sword"}, "")
    
    AddToLocations("lift", "a dangerous lift with doors that do not close properly",
                     "", "", "", "coridoor", {}, "", "rat")
    
    AddToLocations("reception", "the end of the adventure. Well done",
                     "", "", "", "", {}, "key") -- no exits: end game, needs key to enter
	
	Shared.CurrentLocation = "hotel room"
	-- check if Locations are all correctly spelled and listed by the programmer:  
    return CheckLocations()
end

local function DisplayIntro(introText)
	--[[ Displays an introduction to the adventure using the supplied intro_text list ]]
	function FormatLine(text, length)
		--[[ private sub-function for use in displayIntro  ]]
		if text:len() % 2 == 1 then
			text = text .. " "
		end
		local filler = string.rep(" ", (length - text:len()) / 2)
		return "║"..filler..text..filler.."║"
	end
	local row = Console.Clear()
	local size = 0							-- set size of the text
    for _, string in ipairs(introText) do	-- get longest text in supplied list
        if string:len() > size then
            size = string:len()
		end
	end
    if size % 2 == 1 then
        size = size + 1 
	end
    size = size + 12
    local boxTop 	= "╔"..string.rep("═", size).."╗"	-- ══════ -> length of longest text + padding 
	local boxBottom = "╚"..string.rep("═", size).."╝"
    print(boxTop)										-- ╔══════════════════╗
    for _, string in ipairs(introText) do				
        print(FormatLine(string, size))					-- ║       text       ║
	end
	print(boxBottom)									-- ╚══════════════════╝
    Shared.Sleep(3)
    Console.Clear()
end

local function GetFiles(path, osName)
	--[[ Read directory of available files ]]
end

local function LoadFromFile(fileName)
	--[[ Read text file and create objects ]]
end

function Game.GameLoadMenu(cwd, files, row)
	--[[ Load game from file ]]
end

function Game.LoadGame()
	--[[ Display folder contents of game files ]]
	local row = Console.Clear()
	local success = false

	Player.Characters = {"Fighter", "Wizard", "Ninja", "Theif"}	-- set the possible character types in player first
	CreateDefaultItems()                                -- create game items
	CreateDefaultEnemies()                              -- game.create_enemy()
	if CreateDefaultLocations() then                    -- create game locations. false means errors found
		Shared.CurrentLocation = "hotel room"           -- Set the starting Location
		success = true                                  -- set success flag as game is hard-coded
	end
	if success then
		DisplayIntro(Narrator.Intro) 
		Game.ModifyPlayer()             	-- modify Player characteristics. Player is passed by reference, so is updated directly
	end
    return success
end

function Game.ModifyPlayer()
	-- [[ gets player details. Change the text to suit your adventure theme ]]
	local row = Console.Clear()
    for _, message in ipairs(Narrator.Data) do
        print(Narrator.FormatMessage(message))
        Shared.Sleep(Game.Delay)
        if row >= 0 then
			row = row + 1
		end
	end
	
	Player.Name = kb.getString("What is your name?", true, 2, 20, row)
    print(Narrator.FormatMessage(Narrator.Greeting[1]))
    Shared.Sleep(Game.Delay)
    row = Console.Clear()
	if #Player.Characters > 0 then
		local title = Narrator.FormatMessage(Narrator.Greeting[2])
        local choice = kb.menu(title, Player.Characters, row)
        Player.Character = Player.Characters[choice]
        Player.UpdateStats(choice)
	end
	if Shared.Debug then
        Console.Clear()
        Player.DisplayPlayer()
		io.write("Enter to continue")
		io.read()
        row = Console.Clear()
	end
	for _, message in ipairs(Narrator.Start) do
        print(Narrator.FormatMessage(message))
        Shared.Sleep(Game.Delay)
	end

    Shared.Sleep(Game.Delay)
    Console.Clear() 
	
	return Player
end

return Game