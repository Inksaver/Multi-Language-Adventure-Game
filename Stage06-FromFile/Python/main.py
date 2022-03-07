import time
import lib.kboard as kb #note use of lib. to locte file inside a subdirectory called lib
import lib.console as console
import game, player, shared, location, weapon, narrator

'''
play() loop
1. exits:list = here.display_location() # gets exits list, so include exit name
2. exits is passed to take_action()
3. take_action() displays exits as part of the menu
4. menu returns "Go "* if an exit is chosen
5. direction currently gets exit from string splicing "Go direction" to "direction" (north, east, south, west)
6. if exit contained "Go east -> coridoor" improve string splicing to separate "east" and "coridoor"

location.display_location()
1. return exit name for each exit: "east -> coridoor","north -> magic portal"
'''	
def check_exit(here:location.Location, direction:str) -> str:
	''' check if next location has an item_required to enter '''
	item_required:str = ""
	next_location:location.Location = here
	
	if direction == "to_north":
		next_location = shared.locations[here.to_north]
	elif direction == "to_east":
		next_location = shared.locations[here.to_east]
	elif direction == "to_south":
		next_location = shared.locations[here.to_south]
	elif direction == "to_west":
		next_location = shared.locations[here.to_west]
		
	item_required = next_location.item_required	
	if item_required != "":						# key or other item needed
		console.clear()
		if item_required in player.inventory: 	# is it in player inventory?
			print(f"You use the {item_required} in your inventory to enter...")
		else:
			print(f"You need {item_required} in your inventory to go that way")
			next_location = here
		time.sleep(2)
	
	return next_location.name	

def fight(here:location.Location):
	''' pick a fight with an enemy '''
	enemy = shared.enemies[here.enemy]		# use variable for convenience
	print(player.attack(here))				# player.attack() returns a string message
	message = ""
	if enemy.health == 0:
		message = f"The {here.enemy} is dead"
		if enemy.drop_item != "":
			here.add_item(enemy.drop_item)
			message += f" and dropped a {enemy.drop_item}"
		here.enemy = ""	
	else:
		message = enemy.attack(player)
	print(message)							# print attack details
	
	if player.health == 0:
		shared.gamestate = shared.gamestates['dead']		# this breaks the gameloop in main()

def play() -> None:
	''' make choices about items in locations, inventory, move around etc '''
	action:str = ""
	console.clear()
	here:location.Location = shared.locations[shared.current_location]
	exits, row = here.display_location() # returns available exits and current console row
	action, param = take_action(here, exits, row)
	if action == "go":
		#check if next location has item_required
		shared.current_location = check_exit(here, param)		
	elif action == "examine":
		print(f"You examine the {param}:")
		print(f"{shared.items[param].get_description()}")
		if type(shared.items[param]) == weapon.Weapon:
			print(f"It is a Weapon with {shared.items[param].damage} hit points!")
		time.sleep(2)
	elif action == "take":
		print(f"You take the {param} and put it in your backpack")
		player.add_to_inventory(param)
		here.remove_item(param)
		time.sleep(2)
	elif action == "inventory":
		# this action will only appear if player.inventory is not empty
		use_inventory()
	elif action == "fight":
		fight(here) # gamestate set to 'dead' if failed to win
		time.sleep(4)
	elif action == "quit":
		shared.gamestate = shared.gamestates['quit']

def	take_action(here:location.Location, exits:list, row:int) -> str:
	''' choose player action '''
	options:list = []
	# check for enemies
	if here.enemy != "":
		options.append(f"Attack {here.enemy} !")	# add "Attack..." to options
	# examine / take any items
	if len(here.items)> 0:
		for item in here.items:
			options.append(f"Examine {item}")
			options.append(f"Take {item}")
	# open inventory
	if len(player.inventory) > 0:
		options.append("Open your inventory")		# add "Open your inventory" to options
	# take an exit
	if len(exits) > 0:
		for exit in exits:
			options.append(f"Go {exit}")

	# quit the game	
	options.append("Quit")
	choice:str = options[kb.menu("What next?", options, row)]
	# choice examples: "Attack...", Examine...", "Go..." etc
	if "Attack" in choice:
		return "fight",""	
	elif choice == "Quit":
		return "quit", ""
	elif "Go " in choice:
		# get direction 
		# direction = f"to_{choice[3:]}" # to_north, to_east, etc
		# exit format "Go east -> coridoor" needs to be parsed differently
		data = choice[3:].split("->")
		direction = f"to_{data[0].strip()}" # to_north, to_east, etc
		return "go", direction
	elif "Examine" in choice:
		# get item
		item = choice[8:]
		return "examine", item
	elif "Take" in choice:
		item = choice[5:]
		return "take", item
	elif "inventory" in choice:
		# open inventory
		return "inventory", ""
	
def use_inventory():
	choice = ""
	while choice != "Exit menu":
		row = console.clear()
		title = "Choose your option:"
		options = []
		for item in player.inventory:
			options.append(f"Examine {item}")
			options.append(f"Drop {item}")

		options.append("Exit menu")
		choice = options[kb.menu(title, options, row)]
		if "Examine" in choice:
			item = choice[8:]
			row = console.clear()
			print(f"You examine the {item}")
			print(f"It is {shared.Items[item].description}")
			if type(shared.items[item]) == weapon.Weapon:
				print(f"It is a Weapon with {shared.items[item].damage} hit points!")

			time.sleep(3)
		elif "Drop" in choice:
			item = choice[5:]
			row = console.clear()
			print(f"You drop the {item}")
			shared.locations[shared.current_location].add_item(item)
			player.remove_from_inventory(item)
			time.sleep(3)

		if len(player.inventory) == 0:
			choice = "Exit menu"


def main() -> None:
	''' Everything runs from here '''
	console.resize(80, 25, False)
	row = console.clear()	# If you do not use os.system('cls') before trying to set cursor position in kb methods it shows the escape codes!
	if shared.debug:														# allow disabling debug mode
		shared.debug = not kb.get_boolean("Debug mode is ON. Do you want to disable debug mode?", row)
		console.clear()
	
	if game.load_game():
		''' game loop '''
		shared.gamestate = shared.gamestates['play']							# start at 'play'
		while shared.gamestate == shared.gamestates['play']:					# continue game while in 'play' gamestate
			play()																# play the game. Gamestate can be changed in multiple places
		
		console.clear()	
		if shared.gamestate == shared.gamestates['dead']:
			for message in narrator.death_message:
				print(message)
			
		for message in narrator.end_message:
			print(message)
	else:
		print("Please correct errors in game locations before trying again")

	if console.is_console:
		input("Enter to quit")
	
main()