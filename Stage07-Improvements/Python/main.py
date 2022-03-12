import time
import lib.kboard as kb #note use of lib. to locte file inside a subdirectory called lib
import lib.console as console
import game, player, shared, location, weapon, narrator

'''
kboard -> modified menu and other functions to improve appearance
console -> modified clear() and resize() to return row and width
new class -> debug_display all debug output moved here
game -> load_from_file improvements and display debug for all objects
game -> display_intro improved appearance
game -> modify_player cosmetic changes
location -> update display_location
player -> attack() updated, removed display_player()
shared -> format_line and print_line added
weapon -> constructor modified
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
		if item_required in player.inventory: 	# is it in player inventory?
			print(f"You use the {item_required} in your inventory to enter...".ljust(console.window_width, " "))
		else:
			print(f"You need {item_required} in your inventory to go that way".ljust(console.window_width, " "))
			next_location = here
		time.sleep(2)
		
	return next_location.name	

def fight(here:location.Location):
	''' pick a fight with an enemy '''
	row, width = console.clear()
	enemy = shared.enemies[here.enemy]		# use variable for convenience
	weapon = "fist"
	if len(player.inventory) > 0:
		weapon = player.inventory[kb.menu("Choose your weapon", player.inventory, row, width)]
	print(player.attack(here, weapon).ljust(console.window_width))				# player.attack() returns a string message
	message = ""
	if enemy.health == 0:
		message = f"The {here.enemy} is defeated"
		if enemy.drop_item != "":
			here.add_item(enemy.drop_item)
			message += f" and dropped a {enemy.drop_item}"
		here.enemy = ""	
	else:
		message = enemy.attack(player)
	print(message.ljust(console.window_width))							# print attack details
	
	if player.health == 0:
		print(f"You died at the hands of the {enemy.name.ljust(console.window_width)}")
		time.sleep(2)
		print("The game is over!".ljust(console.window_width))
		time.sleep(2)		
		shared.gamestate = shared.gamestates['dead']		# this breaks the gameloop in main()

def play() -> None:
	''' make choices about items in locations, inventory, move around etc '''
	action:str = ""
	console.clear()
	here:location.Location = shared.locations[shared.current_location]
	exits, row = here.display_location() # returns available exits and current console row
	if not console.is_console:
		row = -1				# prevent /033[7;0H in IDE
	action, param = take_action(here, exits, row)
	if action == "go":
		#check if next location has item_required
		shared.current_location = check_exit(here, param)		
	elif action == "examine":
		print(f"You examine the {param}:".ljust(console.window_width, " "))
		print(f"{shared.items[param].get_description()}".ljust(console.window_width, " "))
		if type(shared.items[param]) == weapon.Weapon:
			print(f"It is a Weapon with {shared.items[param].damage} hit points!")
		time.sleep(2)
	elif action == "take":
		print(f"You take the {param} and put it in your backpack".ljust(console.window_width, " "))
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
	choice:str = options[kb.menu("What next?", options, row, 0)]
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
		row, width = console.clear()
		title = f"Inventory: ({player.health} Health) Choose your option:"
		options = []
		for item in player.inventory:
			options.append(f"Examine {item}")
			options.append(f"Drop {item}")
		
		if len(player.inventory) >= 2:
			options.append("Craft a new item")
			
		options.append("Exit menu")
		choice = options[kb.menu(title, options, row, width)]
		row, width = console.clear()
		if "Examine" in choice:
			item = choice[8:]
			print(f"You examine the {item}")
			print(f"It is {shared.Items[item].description}")
			if type(shared.items[item]) == weapon.Weapon:
				print(f"It is a Weapon with {shared.items[item].damage} hit points!")

			time.sleep(3)
		elif "Drop" in choice:
			item = choice[5:]
			print(f"You drop the {item}")
			shared.locations[shared.current_location].add_item(item)
			player.remove_from_inventory(item)
			time.sleep(3)
		elif "Craft" in choice:
			# open a new menu to select 2 items
			options.clear()
			for item in player.inventory:
				options.append(item)
			item1 = options[kb.menu("Choose your first item", options, row, width)]
			options.remove(item1)
			row, _ = console.clear()
			item2 = options[kb.menu("Choose your second item", options, row, width)]
			# can anything be crafted from selected items?
			new_item = ""
			for key, item in shared.items.items():
				if item1 in item.craft_items and item2 in item.craft_items:
					new_item = key
					if shared.items[item1].uses == 1:
						player.remove_from_inventory(item1)
					if shared.items[item2].uses == 1:
						player.remove_from_inventory(item2)					
			
			if new_item == "":
				print("Your crafting skills are inadequate".ljust(console.window_width, " "))
			else:
				print(f"You crafted a {new_item}".ljust(console.window_width, " "))
				player.add_to_inventory(new_item)
			time.sleep(3)

		if len(player.inventory) == 0:
			choice = "Exit menu"

def main() -> None:
	''' Everything runs from here '''
	console.resize(80, 25, False)	# 0, 80 if console else -1, 0
	''' Windows only: If you do not use os.system('cls') before trying to set
		cursor position in kb methods it shows the escape codes! '''
	row, width = console.clear()	
	if shared.debug:											# allow disabling debug mode
		shared.debug = not kb.get_boolean("Debug mode is ON. Do you want to disable debug mode?", row, width)
		console.clear()
	
	if game.load_game():
		''' game loop '''
		shared.gamestate = shared.gamestates['play']			# start at 'play'
		while shared.gamestate == shared.gamestates['play']:	# continue game while in 'play' gamestate
			play()												# play the game. Gamestate can be changed in multiple places
		''' game over '''
		console.clear()	
		if shared.gamestate == shared.gamestates['dead']:
			for message in narrator.death_message:
				print(message)
			
		for message in narrator.end_message:
			print(message)
	else:
		print("Please correct errors in game locations before trying again")

	if console.is_console:			# ? running in a console/terminal
		input("Enter to quit")
	
main()