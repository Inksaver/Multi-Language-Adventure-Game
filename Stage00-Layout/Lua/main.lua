--[[
This episode creates a template for the development of a text-based adventure game. 
Write a Shared static class for true global variables
Write a Narrator class to tell the story
Write a Console class to handle output appearance
Lua does not have many built-in functions so roll your own in Shared
]]
kb 			= require "lib.kboard"
Console 	= require "lib.console"
Narrator 	= require "narrator"
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
	local row = Console.Clear()
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
	end
	if Console.IsConsole then
		io.write("Enter to quit")
		io.read()
	end
end

-- Program runs from here:
main()
