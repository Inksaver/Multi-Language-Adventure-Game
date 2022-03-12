import lib.console as console
import shared, player

def display_items():
	width = 112
	height = 25
	console.resize(width, height, True)
	print("The Dictionary shared.items contains the following objects:")
	print("".ljust(width,"═"))
	row = 2
	for key, value in shared.items.items():
		if row > height - 5:
			input("Enter for next screen")
			row, _ = console.clear()		
		row += shared.print_lines(	f"Name: {key.ljust(25)}" +
									f"{str(type(value)).ljust(25)}" +
									f"Uses: {str(value.uses).ljust(8)}" +
									f"CraftFrom: {value.craft_items}", console.window_width, "", "left")
									
		row += shared.print_lines(f"Description: {value.get_description()}", console.window_width, "", "left")
		print("".ljust(width,"─"))
		row += 1
		if not console.is_console:
			row = -1		
		
	print("".ljust(width,"═"))
	input("Enter to continue")
	console.resize(80, 25, True)	
	
def display_locations():
	width = 112
	height = 25
	console.resize(width, height, True)			
	print("The Dictionary shared.locations contains the following data:")
	print("".ljust(width,"─"))
	row = 2
	for key,value in shared.locations.items():
		if row > height - 7:
			input("Enter for next screen")
			row, _ = console.clear()		
		print(f"Name: {key.ljust(22)}Item required: {value.item_required.ljust(32)}Enemy: {value.enemy}")
		print(f"North: {value.to_north.ljust(21)}East: {value.to_east.ljust(17)}South: {value.to_south.ljust(17)}West: {value.to_west}")
		row += 2
		row += shared.print_lines(f"Description: {value.description}", width, "", "left")				
		print(f"Items: {str(value.items).ljust(40)}")
		print("".ljust(width,"─"))
		row += 2
		if not console.is_console:
			row = -1
			
	input("\nEnter to continue game")
	console.resize(80, 25, True)    
	
def display_enemies():
	width = 112
	console.resize(width, 25, True)		
	print("The Dictionary shared.enemies contains the following enemies:")
	print("".ljust(width,"═"))
	for key,value in shared.enemies.items():
		shared.print_lines(f"Name: {key.ljust(20)}Strength: {str(value.strength).ljust(10,' ')} Health: {str(value.health).ljust(10, ' ')} DropItem: {value.drop_item}", console.window_width, "", "left")
		shared.print_lines(f"Description: {value.description}", console.window_width, "", "left")
		#print(f"Strength: {str(value.strength).ljust(10,' ')} Health: {str(value.health).ljust(10, ' ')} DropItem: {value.drop_item}")
		print("".ljust(width,"═"))
	input("Enter to continue")
	console.resize(80, 25, True)	
	
def display_player() -> None:
	''' main use for debug. prints all player properties '''
	print(''.ljust(80,'─'))
	print("Player properties:")
	print(''.ljust(80,'─'))
	print(f"Characters available: {player.characters}")
	print(''.ljust(80,'─'))
	print(f"Name:                 {player.name}")
	print(f"Health:               {player.health}")
	print(f"Strength:             {player.strength}")
	print(f"Character:            {player.character}")
	print(f"Inventory:            {player.inventory}")
	print(''.ljust(80,'─'))