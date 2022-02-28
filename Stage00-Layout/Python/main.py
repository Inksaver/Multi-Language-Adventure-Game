'''
This episode creates a template for the development of a text-based adventure game. 
Write a Shared static class for true global variables
Write a Narrator class to tell the story
Write a Console class to handle output appearance
There is no output at this stage
'''
import lib.kboard as kb #note use of lib. to locate file inside a subdirectory called lib
import lib.console as console
import narrator, game, shared

def play() -> None:
	''' make choices about items in locations, inventory, move around etc '''
	shared.gamestate = shared.gamestates['quit']
		
def	take_action(here, exits:list) -> None:
	''' choose player action '''
	
def main() -> None:
	''' Everything runs from here '''
	row = console.clear()
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
