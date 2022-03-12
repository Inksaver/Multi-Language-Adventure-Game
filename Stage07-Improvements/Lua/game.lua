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
local Debug		= require "debugDisplay"

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
			Debug.DisplayLocations()
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
        Debug.DisplayItems()
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
        Debug.DisplayEnemies()
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
	local width = 80
	Console.Resize(width, 25, true)

    local boxTop 	= "╔"..string.rep("═", width - 2).."╗"	-- ══════ -> length of longest text + padding 
	local boxBottom = "╚"..string.rep("═", width - 2).."╝"
    print(boxTop)										-- ╔══════════════════╗
    for _, string in ipairs(introText) do				
        local Lines = Shared.FormatLine(string, width, "║")
		for _, line in ipairs(Lines) do
			print(line)									-- ║       text       ║
		end
	end
	print(boxBottom)									-- ╚══════════════════╝
    Shared.Sleep(3)
    Console.Clear()
end

local function GetFiles(path, osName)
	--[[
	Lua implementation of PHP scandir function.
	popen opens a 'file' or command and pipes the contents.
	https://www.howtogeek.com/363639/how-to-use-the-dir-command-in-windows/
	popen('dir "C:\\Users\\Public" /b) reads all the folder/file names in that folder
	The /b switch removes attributes eg file size, time stamps
	]]
	local i = 0
	local fileList = {}
	local pfile
	
	if osName == 'nt' then
		-- local pfile = popen('dir "'..directory..'" /b /ad') --directories only
		pfile = io.popen('dir "'..path..'" /b')
	else
		pfile = io.popen('ls -a "'..path..'"')
	end
    for filename in pfile:lines() do
        i = i + 1
        fileList[i] = filename
    end
    pfile:close()
    return fileList
end

local function LoadFromFile(fileName)
	local lib = {}	-- create private functions for use in LoadFromFile
    function lib.Reset()
		data = 
		{
			name = "",
			description = "",
			uses = 0,
			container = "",
			health = 0,
			strength = 0,
			item = "",
			items = {},
			craftitems = {},
			damage = 0,
			tonorth = "",
			toeast = "",
			tosouth = "",
			towest = "",
			enemy = "",
			dropitem = ""
		}
		return data
	end
	function lib.FixInt(value, default)
		default = default or 0
		local convert = tonumber(value)
		if convert == nil then
			return default
		else
			return convert
		end
	end
	function lib.FixList(value)
		if value ~= '' then
			return value:Split(';')
		else
			return {}
		end
	end
	-- file_name is full path/name
	-- local f = io.open(fileName,'r')
	-- local content = f:read('*a') -- *a or *all reads the whole file
	-- f:close()
	local retValue = false
	local completed = 0
	if fileName ~= '' then
		local content = {}
		for line in io.lines(fileName) do
			table.insert(content, line)
		end
		local data = lib.Reset()
		-- contents now in a list, with \n still at the end of each line
		for _, line in pairs(content) do
			local cleanLine = line:match("^%s*(.-)%s*$") --remove leading/trailing whitespace and newline
			local parts = cleanLine:Split('=')     -- item.name | key card
			local temp = parts[1]:Split('.')  -- item | name
			local obj = temp[1]               -- item
			local prop = temp[2]              -- name
			local value = parts[2]            -- key card
			value = value or ''
			if obj == 'item' then -- new item object
				if prop == 'name' then
					data.name = value
					completed = completed + 1
				elseif prop == 'description' then
					-- python description = value.replace('\\n', '\n')
					data.description = value:gsub('\\n', '\n')
					completed = completed + 1
				elseif prop == 'craftitems' then
					data.craftitems = lib.FixList(value)
					completed = completed + 1
				elseif prop == 'uses' then
					data.uses = lib.FixInt(value)
					completed = completed + 1
				elseif prop == 'container' then
					data.container = value
					completed = completed + 1
				end
				if completed == 5 then
					AddToItems(data.name, data.description, data.craftitems, data.uses, data.container)
					data = lib.Reset()
					completed = 0
				end
			elseif obj == 'weapon' then
				if prop == 'name' then
					data.name = value
					completed = completed + 1
				elseif prop == 'description' then
					data.description = value:gsub('\\n', '\n')
					completed = completed + 1
				elseif prop == 'craftitems' then
					data.craftitems = lib.FixList(value)
					completed = completed + 1
				elseif prop == 'uses' then
					data.uses = lib.FixInt(value)
					completed = completed + 1
				elseif prop == 'container' then
					data.container = value
					completed = completed + 1
				elseif prop == 'damage' then
					data.damage = lib.FixInt(value, 5)
					completed = completed + 1
				end
				if completed == 6 then
					AddToWeapons(data.name, data.description, data.craftitems, data.uses, data.container, data.damage)
					data = lib.Reset()
					completed = 0
				end
			elseif obj == 'enemy' then
				if prop == 'name' then
					data.name = value
					completed = completed + 1
				elseif prop == 'description' then
					data.description = value:gsub('\\n', '\n')
					completed = completed + 1
				elseif prop == 'health' then
					data.health = lib.FixInt(value, 5)
					completed = completed + 1
				elseif prop == 'strength' then
					data.strength = lib.FixInt(value, 5)
					completed = completed + 1
				elseif prop == 'dropitem' then
					data.dropItem = value
					completed = completed + 1
					end
				if completed == 5 then
					AddToEnemies(data.name, data.description, data.health, data.strength, data.dropItem)
					data = lib.Reset()
					completed = 0
				end
			elseif obj == 'location' then
				if prop == 'name' then
					data.name = value
					completed = completed + 1
				elseif prop == 'description' then
					data.description = value:gsub('\\n', '\n')
					completed = completed + 1
				elseif prop == 'tonorth' then
					data.tonorth = value
					completed = completed + 1
				elseif prop == 'toeast' then
					data.toeast = value
					completed = completed + 1
				elseif prop == 'tosouth' then
					data.tosouth = value
					completed = completed + 1
				elseif prop == 'towest' then
					data.towest = value
					completed = completed + 1
				elseif prop == 'items' then
					data.items = lib.FixList(value)
					completed = completed + 1
				elseif prop == 'itemrequired' then
					data.item = value
					completed = completed + 1
				elseif prop == 'enemy' then
					data.enemy = value 
					completed = completed + 1
				end
				if completed == 9 then
					AddToLocations(data.name, data.description, data.tonorth, data.toeast, data.tosouth, data.towest, data.items, data.item, data.enemy)
					data = lib.Reset()
					completed = 0
				end
			elseif obj == 'player' then
				if prop == 'name' then
					Player.Name = value
				elseif prop == 'characters' then
					Player.Characters = value:Split(';')
				elseif prop == 'character' then
					Player.Character = value           
				elseif prop == 'health' then
					Player.Health = lib.FixInt(value, 60)
				elseif prop == 'strength' then
					Player.Strength = lib.FixInt(value, 60)            
				elseif prop == 'inventory' then
					Player.Inventory = lib.FixList(value)
				elseif prop == 'iteminhand' then
					Player.ItemInHand = value
				end
			elseif obj == 'game' then
				if prop == 'currentlocation' then
					Shared.CurrentLocation = value
				end
			elseif obj == 'narrator' then
				if prop == 'intro' then
					Narrator.Intro = lib.FixList(value)
				elseif prop == 'data' then
					Narrator.Data = lib.FixList(value)
				elseif prop == 'greeting' then
					Narrator.Greeting = lib.FixList(value)
					-- greeting must have 2 lines
					if #Narrator.Greeting == 1 then
						table.insert(Narrator.Greeting, "Let me know your character, so you can be awarded your skills")
						print("Narrator.Greeting must be 2 lines. Default entry added")
						Shared.Sleep(2)
					end
				elseif prop == 'start' then
					Narrator.Start = lib.FixList(value)
				elseif prop == 'deathmessage' then
					Narrator.DeathMessage = lib.FixList(value)
				elseif prop == 'endmessage' then
					Narrator.EndMessage = lib.FixList(value)
				end
			end
		end
	end
	
	if Shared.Debug then
		Debug.DisplayItems()
		Debug.DisplayEnemies()
	end
            
    return CheckLocations()
end

function Game.GameLoadMenu(cwd, files, row, width)
	--[[ Load game from file ]]

	local choice = kb.Menu("Select the game you want to load", files, row, width)
	return cwd.."/games/"..files[choice]

end

function Game.LoadGame()
	--[[ Display folder contents of game files ]]
	local row, width = Console.Clear()
	local success = false                                   -- set 'did we load or create a game?' to false
	local cwd = io.popen"cd":read'*l'
	local loadFileName = ''
	local loadPath = cwd..'/'..'games'						
	local files = GetFiles(loadPath, Console.OSName)      	-- fill the files list with any files in this directory
    if #files > 0 then               						-- if the list of new game files or save files is not empty
		loadFileName = Game.GameLoadMenu(cwd, files, row, width)
		row = Console.Clear()
        success = LoadFromFile(loadFileName)          		-- attempt to load the game True/False
    end
	
    if not success then										-- no game files so ? use default hard-coded game
		local useDefault = kb.GetBoolean("The file "..loadFileName.." had errors. Do you want to play the default game instead? (y/n)")
		if useDefault then
			Player.Characters = {"Fighter", "Wizard", "Ninja", "Theif"}	-- set the possible character types in player first
			CreateDefaultItems()                            -- create game items
			CreateDefaultEnemies()                          -- game.create_enemy()
			if CreateDefaultLocations() then                -- create game locations. false means errors found
				Shared.CurrentLocation = "hotel room"       -- Set the starting Location
				success = true                              -- set success flag as game is hard-coded
			end
		end
    end  
	if success then											-- file loaded or player chose to use default
		DisplayIntro(Narrator.Intro) 
		Game.ModifyPlayer()             	-- modify Player characteristics. Player is passed by reference, so is updated directly
	end
    return success
end

function Game.ModifyPlayer()
	-- [[ gets player details. Change the text to suit your adventure theme ]]
	local row, width = Console.Resize(80, 25, true) -- 0, 80 if isConsole else 0, -1
    for _, message in ipairs(Narrator.Data) do
        print(Narrator.FormatMessage(message))
        Shared.Sleep(Game.Delay)
        if row >= 0 then
			row = row + 1
		end
	end
	
	Player.Name = kb.getString("What is your name?", true, 2, 20, row, width)
	print(string.rep("─", Console.WindowWidth))
    print(Narrator.FormatMessage(Narrator.Greeting[1]))
	print(string.rep("─", 80))
    Shared.Sleep(Game.Delay)
    row = Console.Clear()
	if #Player.Characters > 0 then
		local title = Narrator.FormatMessage(Narrator.Greeting[2])
        local choice = kb.Menu(title, Player.Characters, row, width)
        Player.Character = Player.Characters[choice]
        Player.UpdateStats(choice)
	end
	if Shared.Debug then
        Console.Clear()
        Debug.DisplayPlayer()
		io.write("Enter to continue")
		io.read()
        row = Console.Clear()
	end
	print(string.rep("─", width))
	for _, message in ipairs(Narrator.Start) do
        print(Narrator.FormatMessage(message))
        Shared.Sleep(Game.Delay)
	end
	print(string.rep("─", width))

    Shared.Sleep(Game.Delay)
    Console.Clear() 
	
	return Player
end

return Game