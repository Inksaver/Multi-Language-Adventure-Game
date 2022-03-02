import time
#import local files
import lib.kboard as kb
import lib.console as console
import shared, player, item, narrator

delay = 2

def add_to_items(key_name:str, description:str, craftitems:list[str] = [], uses:int = 0, container:str = "") -> None:
	''' Adds a new Item object to the shared.items dictionary '''
	shared.items.update({key_name: item.Item(key_name, description, craftitems, uses, container)})

def add_to_enemies(key_name:str, description:str) -> None:
	''' Adds a new Enemy object to the shared.enemies dictionary '''

def add_to_locations(key_name:str, description:str) -> None:
	''' Adds a new Location object to the shared.locations dictionary '''             

def add_to_weapons(key_name:str, description:str) -> None:
	''' Adds a new Weapon object to the shared.items dictionary '''

def check_locations() -> bool:
	''' Check keys used in locations are spelled correctly '''

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
	''' Create default game enemy if not loading from file  '''

def create_default_locations() -> bool:
	''' Create default game locations if not loading from file '''

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

	display_intro(narrator.intro)                   # display game intro 
	modify_player()                                 # modify player characteristics. player is passed by reference, so is updated directly 

	return True										# hard coded at this stage

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