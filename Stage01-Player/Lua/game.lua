local Game = {}

local kb 		= require "lib.kboard"
local Console 	= require "lib.console"
local Narrator	= require "narrator"
local Shared 	= require "shared"		-- repository for shared variables and functions
local Player 	= require "player"

Game.Delay = 2							-- Game.Delay so can be modified outside of class
string.Split = Shared.Split
local function AddToItems(keyName, description,  craftitems, uses, container)
	--[[  helper function to create Item objects and store in Shared  ]]
end

local function AddToEnemies(keyName, description, strength, health, dropItem)
	--[[  helper function to create Enemy objects and store in Shared  ]]
end

local function AddToLocations(keyName, description, tonorth, toeast, tosouth, towest, items, itemRequired, enemy)
	--[[  helper function to create Location objects and store in Shared  ]]
end

local function AddToWeapons(keyName, description, craftitems, uses, container, damage)
	--[[ Adds a new Weapon object to the shared.items dictionary ]]
end

local function CheckLocations()
	--[[ Check keys used in locations are spelled correctly ]]
end

local function CreateDefaultItems()
	--[[ Create default game items if not loading from file ]]
end

local function CreateDefaultEnemies()
	--[[ Create default game enemy if not loading from file ]]
end 

local function CreateDefaultLocations()
	--[[ Create default game locations if not loading from file	]]
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
	
	Player.Characters = {"Fighter", "Wizard", "Ninja", "Theif"}	-- set the possible character types in player first
	DisplayIntro(Narrator.Intro) 
	Game.ModifyPlayer()             	-- modify Player characteristics. Player is passed by reference, so is updated directly
    return true
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