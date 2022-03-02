import player

intro:list[str] = ["The most Epic Adventure game EVER!",
				   "Coded by Inksaver",
				   "Can you escape the dungeon?..."]
data:list[str] = ["I am the overlord, and I will help you to find my lost treasure",
				  "I just need to get to know you before I let you in..."]

greeting:list[str] = ["Hello {player.name}. You are the adventurer destined to find my lost treasure",
					  "Let me know your character, so you can be awarded your skills"]

start:list[str] = ["I see you are a {player.character} with {player.health} health and {player.strength} strength",
				   "Welcome. Serve me well and you will be rewarded"]

death_message:list[str] = ["Sorry you did not make it this time!", "Please try again!"]

end_message:list[str] = ["Thank you for playing! Remember to smash that 'Like' button and subscribe!"]

def format_message(message):
	'''
	example message "Hello {player.name}. You"
	extract player.name from {}
	get Player.Name from Player class
	message now is: "Hello Fred. You
	'''	
	start = message.find('{')
	end = -1
	while start > -1:
		begin = message[:start]
		end = message.find('}')
		prop = message[start + 1:end]
		data = player.get_property(prop)
		message = f"{begin}{data}{message[end + 1:]}"
		start = message.find('{')
		
	return message