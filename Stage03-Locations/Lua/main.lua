--[[
Write the Location class
Game -> Add some Location objects to the game
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

local function Play()
	--[[ make choices about items in locations, inventory, move around etc ]]
	Shared.Gamestate = Shared.Gamestates['quit']
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
