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
	global inventory
	if item not in inventory:
		inventory.append(item)

def display_inventory() -> None:
	''' display player's inventory '''
	# global not needed as the value of inventory is not being changed
	if len(inventory) == 0:
		print("Your inventory is empty")
	else:
		print("In your inventory you have:")
		output:str = ""
		for item in inventory:
			output += f"{item}, "
		output = output.strip()[:-1]
		print(output)
		
def display_player() -> None:
	''' main use for debug. prints all player properties '''
	print(''.ljust(60,'-'))
	print("Player properties:")
	print(''.ljust(60,'-'))
	print(f"Characters available: {characters}")
	print(''.ljust(60,'-'))
	print(f"Name:                 {name}")
	print(f"Health:               {health}")
	print(f"Strength:             {strength}")
	print(f"Character:            {character}")
	print(f"Inventory:            {inventory}")
	print(''.ljust(60,'-'))

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
	global inventory
	if item in inventory:
		inventory.remove(item)
	
def update_stats(character_index:int) -> None:
	''' modify health and strength depending on character selected '''
	global health, strength # major failing in Python. Declared in body of script = global?
	health += character_index * 2
	strength -= character_index * 2