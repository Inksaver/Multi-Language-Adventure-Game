'''
This class is used to get console information.
On Windows ANSI codes can be 'reluctant' to start, so clearing the console is usually the best start
USE: import console" (or folder.console if stored elsewhere)
Call any console function eg console.clear() or console.initialise():
console.clear() -> runs console.initialise() sets is_initialised = True, then clears the screen
populates properties:
os_name
is_console
window_width
window_height

utf8 box characters stored here for easy copy/paste:

┌ ┬ ┐ ─ ╔ ╦ ╗ ═
 
├ ┼ ┤ │ ╠ ╬ ╣ ║
 
└ ┴ ┘   ╚ ╩ ╝

'''
import os

window_width:int    = 0
window_height:int   = 0
is_console:bool     = False
os_name:str         = ""
is_initialised:bool = False
CLEARLINE:str       = '\x1b[2K'  	# ansi code to clear the current line

def add_lines(num_lines:int, current_lines:int = 0) -> int: #default 30 lines if not given
	''' adds blank lines to non-console IDE to simulate screen clearing '''
	# use 1: add_lines(5) adds 5 additional blank lines
	# use 2: add_lines(5, 19) adds sufficient lines to fill 25 line console to last 5 lines (as 19 are already used)
	blank = "".rjust(window_width); # string of spaces across entire width of Console
	if current_lines != 0:
		leave_lines = num_lines
		num_lines = window_height - current_lines - leave_lines;
		
	if num_lines > 0:
		for i in range(num_lines):
			print(blank)

	return num_lines;	

def clear() -> None:
	''' clears console using appropriate method for current platform'''
	if is_console:
		if os.name == 'nt':
			os.system('cls')
		else:
			os.system('clear')
		return 0		# if running in terminal/console row = 0
	else:
		add_lines(window_height)
		return -1		# if running in ide row = -1
		
def clear_line(line_no:int) -> None:
	''' Clear one line in console '''
	set_cursor_pos(1, line_no)
	print(CLEARLINE, end = '')
	
def initialise() -> None:
	''' runs on load to get console/terminal info '''
	global window_width, window_height, is_console, is_initialised
	if not is_initialised:
		try:
			window_width = os.get_terminal_size().columns # this will fail if NOT in a console
			window_height = os.get_terminal_size().lines # this will fail if NOT in a console
			is_console = True
		except:
			window_width = 80
			window_height = 25
			is_console = False
		is_initialised = True
		
def resize(width:int, height:int, do_clear:bool = True) -> None:
	''' resize the console / terminal '''
	global window_width, window_height
	if is_console:
		window_width = width      # set global window_width
		window_height = height    # set global window_height
		if os.name == 'nt':
			os.system(f'mode {window_width},{window_height}')
		else:    
			cmd = f"'\\e[8;{window_height};{window_width}t'"
			os.system("echo -e " + cmd) 
		if do_clear:
			clear()
			
initialise() # runs when console class is first referenced
