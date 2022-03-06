import time
#import local files
import lib.kboard as kb
import lib.console as console
import shared, player, item, weapon, location, enemy, narrator
delay = 2

def add_to_items(key_name:str, description:str, craftitems:list[str] = [], uses:int = 0, container:str = "") -> None:
	''' Adds a new Item object to the shared.items dictionary '''
	shared.items.update({key_name: item.Item(key_name, description, craftitems, uses, container)})

def add_to_enemies(key_name:str, description:str, strength:int, health:int, drop_item:str = "") -> None:
	''' Adds a new Enemy object to the shared.enemies dictionary '''
	shared.enemies.update({key_name: enemy.Enemy(key_name, description, strength, health, drop_item)})

def add_to_locations(key_name:str, description:str,
                     tonorth:str = '', toeast:str = '', tosouth:str = '', towest:str = '',
                     items:list = [], item_required:str = "", enemy:str = "") -> None:	

	''' Adds a new Location object to the shared.locations dictionary '''	
	shared.locations.update({key_name: location.Location(key_name, description,
                                                         tonorth, toeast, tosouth, towest,
                                                         items, item_required, enemy)})

def add_to_weapons(key_name:str, description:str, craftitems:list[str], uses:int, container:str, damage:int, ) -> None:
	''' Adds a new Weapon object to the shared.items dictionary '''
	shared.items.update({key_name: weapon.Weapon(key_name, description, craftitems, uses, container, damage)})

def check_locations() -> bool:
	''' Check keys used in locations are spelled correctly '''
	keys = []
	wrong_keys = []
	ret_value = True
	# check if each LocationToXXX corresponds with a key
	for k in shared.locations.keys(): # "room", "magic portal", "lift"
		keys.append(k)
	if shared.current_location == "":
		print(f"Current location has not been set")
		return False
	elif shared.current_location not in keys:
		print(f"Current location key has been set to '{shared.current_location}'")
		print(f"\nAvailable keys:\n{keys}")
		return False 

	for location in shared.locations.values():
		if location.to_north != "":
			if location.to_north not in keys: # "roome" not in keys: mis-spell "room"
				wrong_keys.append(location.to_north)
		if location.to_east != "":
			if location.to_east not in keys:
				wrong_keys.append(location.to_east)
		if location.to_south != "":
			if location.to_south not in keys:
				wrong_keys.append(location.to_south)
		if location.to_west != "":
			if location.to_west not in keys:
				wrong_keys.append(location.to_west)

	if len(wrong_keys) > 0:
		console.clear()
		print("Errors found when creating default game")
		print(f"\nAvailable keys:\n{keys}")
		print(f"\nErroneous key names:\n{wrong_keys}")
		ret_value = False
		input("Enter to continue") 
	else:
		if shared.debug:
			width = 112
			console.resize(width, 25, True)			
			print("\nThe Dictionary shared.locations contains the following data:\n")
			print("".ljust(width,"─"))
			for key,value in shared.locations.items():
				print(f"key: {key.ljust(22)}│ Description: {value.description}")
				print(f"North: {value.to_north.ljust(20)}│ East: {value.to_east.ljust(17)}South: {value.to_south.ljust(17)}West: {value.to_west}")
				print(f"Item required: {value.item_required.ljust(12)}│ Items: {str(value.items).ljust(40)}Enemy: {value.enemy}")
				print("".ljust(width,"─"))
			#print("".ljust(width,"═") + '\n')
			input("\nEnter to continue")
			console.resize(80, 25, True)          

	return ret_value

def create_default_items() -> None:
	''' 
	If no text files in Games then use default hard-coded game.
	************Hard-coded default game*************
	add_to_items("item identifier", "description of item", Damage it can inflict on enemies)
	DO NOT USE \n (newline) characters as game saves will corrupt
	You can use the existing below or over-write them with your own objects and descriptions
	Make as many as you need
	'''
	add_to_items("key card", "a magnetic strip key card: Property of Premier Inns")
	add_to_items("torch", "a magnificent flaming wooden torch. Maybe this is in the wrong adventure game?")
	add_to_items("book", "a copy of 'Python in easy steps' by Mike McGrath")
	add_to_items("key", "a Yale front door key: covered in rat vomit...")    
	add_to_weapons("sword", "a toy plastic sword: a dog has chewed the handle..Yuk!", [], 0, "", 25)    

	if shared.debug:
		width = 112
		console.resize(width, 25, True)
		print("The Dictionary shared.items contains the following objects:")
		print("key/name  object                  description")
		print("".ljust(width,"═"))
		for key, value in shared.items.items():
			print(f"{key.ljust(10)}{str(type(value)).ljust(24)}{value.get_description()}")
		print("".ljust(width,"═"))
		input("Enter to continue")
		console.resize(80, 25, True)


def create_default_enemies() -> None:
	'''
	add_to_enemies("enemy name", "enemy description", strength, health,  item)
	strength/health choose a number between 0 to 100 as a guide
	item: use the string key for the item, eg "secret_key"
	'''
	add_to_enemies("rat", "a vicious brown rat, with angry red eyes", 50, 50, "key")

	if shared.debug:
		width = 90
		console.resize(width, 25, True)		
		print("The Dictionary shared.enemies contains the following enemies:")
		print("".ljust(width,"═"))
		for key,value in shared.enemies.items():
			print(f"Name:     {key.ljust(10)} Description: {value.description}")
			print(f"Strength: {str(value.strength).ljust(10,' ')} Health: {str(value.health).ljust(10, ' ')} DropItem: {value.drop_item}")
			print("".ljust(width,"═"))
		input("Enter to continue")
		console.resize(80, 25, True)
		

def create_default_locations() -> bool:
	add_to_locations("hotel room", "a damp hotel room",
                     "", "coridoor", "", "",
                     ["torch","book"],"key card")

	add_to_locations("coridoor", "a dark coridoor with a worn carpet",
                     "reception", "lift", "", "hotel room",
                    ["key card","sword"], "")

	add_to_locations("lift", "a dangerous lift with doors that do not close properly",
                     "", "", "", "coridoor", [], "", "rat")

	add_to_locations("reception", "the end of the adventure. Well done",
                     "", "", "", "", [], "key") # no exits: end game, needs key to enter
	shared.current_location = "hotel room"    
	#check if Locations are all correctly spelled and listed by the programmer:

	return check_locations()

def display_intro(intro_text:list) -> None:
	''' Displays an introduction to the adventure using the supplied intro_text list '''
	def format_line(text, length):
		''' private sub-function for use in display_intro '''
		if len(text) % 2 == 1:  						# contains odd no of characters
			text += " "									# add extra space 
		filler = "".ljust((length - len(text)) // 2," ")# series of spaces to pad the text both sides
		return f"║{filler}{text}{filler}║"

	console.clear()							# clear the console
	size = 0								# set size of the text
	for string in intro_text:				# get longest text in supplied list
		if len(string) > size:
			size = len(string)
	if size % 2 == 1:
		size += 1 
	size += 12
	box_top = f'╔{"".ljust(size, "═")}╗'	# ══════ -> length of longest text + padding 
	box_bottom = f'╚{"".ljust(size, "═")}╝'
	print(box_top)						
	for string in intro_text:				# ╔══════════════════╗
		print(format_line(string, size))	# ║       text       ║
	print(box_bottom)						# ╚══════════════════╝
	time.sleep(3)
	console.clear()

def game_load_menu(cwd, files, save_files) -> bool:
	''' Load game from file '''

def load_from_file(file_name) -> bool:
	''' Read text file and create objects '''

def load_game() -> bool:
	''' Display folder contents of game files ''' 
	player.characters = ["Fighter", "Wizard", "Ninja", "Theif"] 	# set the possible character types in player first
	create_default_items()                              # create game items
	create_default_enemies()                            # game.create_enemies()
	if create_default_locations():                      # create game locations. false means errors found
		shared.current_location = "hotel room"          # Set the starting Location
		success = True                                  # set success flag as game is hard-coded

	if success:
		display_intro(narrator.intro)                   # display game intro 
		modify_player()                                 # modify player characteristics. player is passed by reference, so is updated directly 

	return success

def modify_player() -> None:
	''' gets player details. Change the text to suit your adventure theme '''
	row = 0
	for message in narrator.data:
		print(narrator.format_message(message))
		time.sleep(delay)
		row += 1

	player.name = kb.get_string("What is your name?", True, 2, 20, row)
	print(narrator.format_message(narrator.greeting[0]))
	time.sleep(delay)
	console.clear()
	if len(player.characters) > 0:
		title:str = narrator.greeting[1]
		choice:int = kb.menu(title, player.characters, 0)
		player.character = player.characters[choice]
		player.update_stats(choice)

	if shared.debug:
		console.clear()
		player.display_player()
		input("Enter to continue")
		console.clear()

	for message in narrator.start:
		print(narrator.format_message(message))
		time.sleep(delay)

	time.sleep(delay)
	console.clear()