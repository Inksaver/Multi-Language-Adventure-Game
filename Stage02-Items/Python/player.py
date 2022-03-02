''' This is a Python Module equivalent to a static class '''

# properties: Can be directly accessed for read/write

name:str = ""
health:int = 100
strength:int = 100
character:str = ""
characters:list = []
inventory:list = []

def add_to_inventory(item:str) -> None:
	''' add an item to player inventory '''

def display_inventory() -> None:
	''' display player's inventory '''
		
def display_player() -> None:
	''' main use for debug. prints all player properties '''
	print(''.ljust(80,'═'))
	print("Player properties:")
	print(''.ljust(80,'═'))
	print(f"Characters available: {characters}")
	print(''.ljust(80,'═'))
	print(f"Name:                 {name}")
	print(f"Health:               {health}")
	print(f"Strength:             {strength}")
	print(f"Character:            {character}")
	print(f"Inventory:            {inventory}")
	print(''.ljust(80,'═'))
	
def get_property(property_name):
	if "name" in property_name:
		return name
	elif "health" in property_name:
		return health
	elif "strength" in property_name:
		return strength
	elif "character" in property_name:
		return character	
	
def remove_from_inventory(item:str) -> None:
	''' remove an item to player inventory '''

def update_stats(character_index:int) -> None:
	''' modify health and strength depending on character selected '''
	global health, strength # major failing in Python. Declared in body of script = global?
	health += character_index * 2
	strength -= character_index * 2