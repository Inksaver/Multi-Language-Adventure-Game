Player = require "player"
local Narrator = {}

Narrator.Intro			= {"The most Epic Adventure game EVER!",
							"Coded by Inksaver",
							"Can you escape the dungeon?..."}
Narrator.Data			= {"I am the overlord, and I will help you to find my lost treasure",
							"I just need to get to know you before I let you in..."}

Narrator.Greeting		= {"Hello {player.name}. You are the adventurer destined to find my lost treasure",
							"Let me know your character, so you can be awarded your skills"}

Narrator.Start			= {"I see you are a {player.character} with {player.health} health and {player.strength} strength",
							"Welcome. Serve me well and you will be rewarded"}

Narrator.DeathMessage 	= {"Sorry you did not make it this time!", "Please try again!"}

Narrator.EndMessage 	= {"Thank you for playing! Remember to smash that 'Like' button and subscribe!"}

function Narrator.FormatMessage(message)
	local start = message:find('{')
	local ending = 0
	while start ~= nil do
		local begin = message:sub(1, start - 1)
		ending = message:find('}')
		local prop = message:sub(start + 1, ending - 1)
		local data = Player.GetProperty(prop)
		message = begin..data..message:sub(ending + 1)
		start = message:find('{')
	end
		
	return message
end

return Narrator