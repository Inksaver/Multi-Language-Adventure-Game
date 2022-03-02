import time
#import local files
import lib.kboard as kb
import lib.console as console
import narrator, shared, player

delay = 2

def add_to_items(key_name:str, description:str) -> None:
	''' Adds a new Item object to the shared.items dictionary '''

def add_to_enemies(key_name:str, description:str) -> None:
	''' Adds a new Enemy object to the shared.enemies dictionary '''

def add_to_locations(key_name:str, description:str) -> None:
	''' Adds a new Location object to the shared.locations dictionary '''             

def add_to_weapons(key_name:str, description:str) -> None:
	''' Adds a new Weapon object to the shared.items dictionary '''

def check_locations() -> bool:
	''' Check keys used in locations are spelled correctly '''

def create_default_items() -> None:
	''' Create default game items if not loading from file '''

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