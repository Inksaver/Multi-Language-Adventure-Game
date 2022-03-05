'''
Write the play() function
Write the take_action() function
Write the check_exit() function
'''
import time
import lib.kboard as kb #note use of lib. to locte file inside a subdirectory called lib
import lib.console as console
import narrator, game, shared, player, location

def check_exit(here:location.Location, direction:str) -> str:
	''' check if next location has an item_required to enter'''
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

def play() -> None:
	''' make choices about items in locations, inventory, move around etc '''
	action:str = ""
	row = console.clear()
	here:location.Location = shared.locations[shared.current_location]
	exits, row = here.display_location() # returns available exits and current console row
	action, param = take_action(here, exits, row)
	if action == "go":
		#check if next location has item_required
		shared.current_location = check_exit(here, param)		
	elif action == "examine":
		print(f"You examine the {param}:")
		print(f"{shared.items[param].get_description()}")
		time.sleep(2)
	elif action == "take":
		print(f"You take the {param} and put it in your backpack")
		player.add_to_inventory(param)
		here.remove_item(param)
		time.sleep(2)
	elif action == "inventory":
		# this action will only appear if player.inventory is not empty
		use_inventory()
	elif action == "quit":
		shared.gamestate = shared.gamestates['quit']

def	take_action(here:location.Location, exits:list, row:int) -> [str,str]:
	''' choose player action '''
	options:list = []
	# examine / take any items
	if len(here.items)> 0:
		for item in here.items:
			options.append(f"Examine {item}")
			options.append(f"Take {item}")
	# open inventory
	if len(player.inventory) > 0:
		options.append("Open your inventory")
	# take an exit
	if len(exits) > 0:
		for exit in exits:
			options.append(f"Go {exit}")

	# quit the game	
	options.append("Quit")
	choice:str = options[kb.menu("What next?", options, row)]

	if choice == "Quit":
		return "quit", ""
	elif "Go " in choice:
		# get direction 
		direction = f"to_{choice[3:]}" # to_north, to_east, etc
		return "go", direction
	elif "Examine" in choice:
		# get item
		item = choice[8:]
		return "examine", item
	elif "Take" in choice:
		item = choice[5:]
		return "take", item
	else:
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
			print(f"You examine the {item}")
			print(f"It is {shared.items[item].get_description()}")
			time.sleep(3)
		elif "Drop" in choice:
			item = choice[5:]
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
		for message in narrator.end_message:
			print(message)
	else:
		print("Please correct errors in game locations before trying again")
  
	if console.is_console:
		input("Enter to quit")
	
main()