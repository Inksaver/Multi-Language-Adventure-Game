'''
Introduce a shared.debug flag, allowing debug data to be displayed
Write a player static class
Setup the Player by getting input from the user
'''
import lib.kboard as kb #note use of lib. to locte file inside a subdirectory called lib
import lib.console as console
import narrator, game, shared
		
def play() -> None:
	''' make choices about items in locations, inventory, move around etc '''
	shared.gamestate = shared.gamestates['quit']
	
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

	if console.is_console:
		input("Enter to quit")
	
main()