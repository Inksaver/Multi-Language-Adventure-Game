import os, time
#import local files
import lib.kboard as kb
import lib.console as console
import shared, player, item, weapon, location, enemy, narrator, debug_display 

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

def add_to_weapons(key_name:str, description:str, craftitems:list[str], uses:int, container:str, damage:int ) -> None:
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
			debug_display.display_locations()         

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
		debug_display.display_items()


def create_default_enemies() -> None:
	'''
	add_to_enemies("enemy name", "enemy description", # (Strength), # (Health),  *item key)

	#: choose a number between 0 to 100 as a guide
	*: use the string key for the item, eg "torch"
	Shared.items["item name"]: Make sure this item has already been created in CreateItems()
	'''
	add_to_enemies("rat", "a vicious brown rat, with angry red eyes", 50, 50, "key")
	#add_to_enemies("dragon", "a fierce fire breathing beast", 50, 50, shared.items["dragon heart"])

	if shared.debug:
		debug_display.display_enemies()

def create_default_locations() -> bool:
	''' Create default game locations if not loading from file '''
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
	# check if Locations are all correctly spelled and listed by the programmer:

	return check_locations()

def display_intro(intro_text:list) -> None:
	''' Displays an introduction to the adventure using the supplied intro_text list '''
	width = 80								# console width if changing ensure even number
	console.resize(width, 25, True)			# reset and clear the console
	box_top = f'╔{"".ljust(width - 2, "═")}╗'	# ╔══════════════════╗ 80 chars total width
	box_bottom = f'╚{"".ljust(width - 2, "═")}╝'# ╚══════════════════╝ 80 chars total width
	print(box_top)						
	for string in intro_text:					# ╔══════════════════╗
		lines = shared.format_line(string, width, "║")
		for line in lines:
			print(line)							# ║       text       ║
	print(box_bottom)							# ╚══════════════════╝
	time.sleep(3)
	console.clear()

def game_load_menu(cwd, files, row, width) -> bool:
	''' Load game from file '''
	if len(files) > 0: # at least 1 game file
		choice = kb.menu("Select the game you want to load", files, row, width);
		return True, os.path.join(cwd, 'games', files[choice])

	return False, ""

def load_from_file(file_name) -> bool:
	''' Read text file and create objects '''
	def fix_int(value, default = 0):
		try:
			return int(value)
		except:
			return default       

	def fix_list(value):
		if value != '':
			return value.split(';')
		else:
			return []  
		
	def reset():
		data = {"name":"",
				"description":"",
				"uses" : 0,
				"container": "",
				"health": 0,
				"strength": 0,
				"item":"",
				"items":[],
				"craftitems":[],
				"damage":0,
				"tonorth":"",
				"toeast":"",
				"tosouth":"",
				"towest":"",
				"enemy":"",
				"dropitem":""}
		return data

	ret_value = False
	completed = 0
	#file_name is full path/name or ''
	if file_name != '':
		with open(file_name, 'r') as f:
			lines = [line.rstrip() for line in f] #error in linux
		# contents now in a list, with \n stripped from the end of each line
		data = reset()
		for line in lines:
			parts = line.split('=')     # item.name | key card
			temp = parts[0].split('.')  # item | name
			obj = temp[0]               # item
			prop = temp[1]              # name
			value = parts[1]            # key card
			if obj == 'item': # new item object
				if prop == 'name':
					data["name"] = value
					completed += 1
				elif prop == 'description':
					data["description"] = value.replace('\\n', '\n')
					completed += 1
				elif prop == 'craftitems':
					data["craftitems"] = fix_list(value) 
					completed += 1
				elif prop == 'uses':
					data["uses"] = fix_int(value)
					completed += 1
				elif prop == 'container':
					data["container"] = value
					completed += 1
				if completed == 5:
					add_to_items(data["name"], data["description"], data["craftitems"], data["uses"], data["container"])
					data = reset()
					completed = 0

			elif obj == 'weapon':
				if prop == 'name':
					data["name"] = value
					completed += 1
				elif prop == 'description':
					data["description"] = value.replace('\\n', '\n')
					completed += 1
				elif prop == 'craftitems':
					data["craftitems"] = fix_list(value)
					completed += 1
				elif prop == 'uses':
					data["uses"] = fix_int(value) 
					completed += 1
				elif prop == 'container':
					data["container"] = value
					completed += 1
				elif prop == 'damage':
					data["damage"] = fix_int(value, 5) 
					completed += 1
				if completed == 6:
					add_to_weapons(data["name"], data["description"], data["craftitems"], data["uses"], data["container"], data["damage"])
					data = reset()
					completed = 0

			elif obj == 'enemy':
				if prop == 'name':
					data["name"] = value
					completed += 1
				elif prop == 'description':
					data["description"] = value.replace('\\n', '\n')
					completed += 1
				elif prop == 'health':
					data["health"] = fix_int(value, 5)
					completed += 1
				elif prop == 'strength':
					data["strength"] = fix_int(value, 5)
					completed += 1
				elif prop == 'dropitem':
					data["dropitem"] = value
					completed += 1
				if completed == 5:
					add_to_enemies(data["name"], data["description"], data["health"], data["strength"], data["dropitem"])
					data = reset()
					completed = 0

			elif obj == 'location':
				if prop == 'name':
					data["name"] = value
					completed += 1
				elif prop == 'description':
					data["description"] = value.replace('\\n', '\n')
					completed += 1
				elif prop == 'tonorth':
					data["tonorth"] = value
					completed += 1
				elif prop == 'toeast':
					data["toeast"] = value
					completed += 1
				elif prop == 'tosouth':
					data["tosouth"] = value
					completed += 1
				elif prop == 'towest':
					data["towest"] = value
					completed += 1
				elif prop == 'items':
					data["items"] = fix_list(value)
					completed += 1
				elif prop == 'itemrequired':
					data["item"] = value
					completed += 1
				elif prop == 'enemy':
					data["enemy"] = value
					completed += 1
				if completed == 9:
					add_to_locations(data["name"], data["description"], data["tonorth"], data["toeast"], data["tosouth"], data["towest"], data["items"], data["item"], data["enemy"])
					data = reset()
					completed = 0

			elif obj == 'player':
				if prop == 'name':
					player.name = value
				elif prop == 'characters':
					player.characters = value.split(';')
				elif prop == 'character':
					player.character = value           
				elif prop == 'health':
					player.health = fix_int(value, 60)
				elif prop == 'strength':
					player.strength = fix_int(value, 60)              
				elif prop == 'inventory':
					player.inventory = fix_list(value)
				elif prop == 'iteminhand':
					player.item_in_hand = value

			elif obj == 'game':
				if prop == 'currentlocation':
					shared.current_location = value

			elif obj == 'narrator':
				if prop == 'intro':               
					narrator.intro = fix_list(value)
				elif prop == 'data':
					narrator.data = fix_list(value)            
				elif prop == 'greeting':
					narrator.greeting = fix_list(value)
				elif prop == 'start':
					narrator.start = fix_list(value)
				elif prop == 'deathmessage':
					narrator.death_message = fix_list(value)           
				elif prop == 'endmessage':
					narrator.end_message = fix_list(value)
	
	if shared.debug:
		debug_display.display_items()
		debug_display.display_enemies()
		
	return check_locations()

def load_game() -> bool:
	''' Display folder contents of game files '''
	row, width = console.clear()
	success = True
	from_file_attempt = False
	is_new_game = True
	
	files = []                                              # empty list
	cwd = os.getcwd()                                       # cwd = Current Working Directory
	load_path = os.path.join(cwd, "games")
	if os.path.exists(load_path):                           # does the folder cwd/games exist?
		files = os.listdir(load_path)                       # fill the files list with any files in this directory
	else:                                                   # game dir does not exist
		os.mkdir(load_path)                                 # create game dir

	if len(files) > 0:                                      # if the list of new game files is not empty
		is_new_game, load_file_name = game_load_menu(cwd, files, row, width)  # get user choice for game file
		row, width = console.clear()
		from_file_attempt = True
		success = load_from_file(load_file_name)            # attempt to load the game True/False

	if not success and not from_file_attempt:             	# no game files so use default hard-coded game                                                 
		player.characters = ["Fighter", "Wizard", "Ninja", "Theif"] 	# set the possible character types in player first
		create_default_items()                              # create game items
		create_default_enemies()                            # game.create_enemies()
		if create_default_locations():                      # create game locations. false means errors found
			shared.current_location = "hotel room"          # Set the starting Location
			success = True                                  # set success flag as game is hard-coded
			is_new_game = True   

	if success:
		display_intro(narrator.intro)          # display game intro

		if is_new_game:
			modify_player()                    # modify player characteristics. player is passed by reference, so is updated directly 

	return success

def modify_player() -> None:
	''' gets player details. Change the text to suit your adventure theme '''
	row, width = console.resize(80, 25, True) # 0, 80 if isConsole else 0, -1
	for message in narrator.data:
		print(narrator.format_message(message))
		time.sleep(delay)
		row += 1

	player.name = kb.get_string("What is your name?", True, 2, 20, row, width)
	print("".ljust(80,"─"))
	print(narrator.format_message(narrator.greeting[0]))
	print("".ljust(80,"─"))
	time.sleep(delay)
	console.clear()
	if len(player.characters) > 0:
		title:str = narrator.greeting[1]
		choice:int = kb.menu(title, player.characters, 0, width)
		player.character = player.characters[choice]
		player.update_stats(choice)

	if shared.debug:
		console.clear()
		debug_display.display_player()
		input("Enter to continue")
		console.clear()
	print("".ljust(80,"─"))
	for message in narrator.start:
		print(narrator.format_message(message))
		time.sleep(delay)
	print("".ljust(80,"─"))

	time.sleep(delay)
	console.clear() 
