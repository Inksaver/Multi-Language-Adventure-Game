'''
the items, enemies and locations are shared by multiple files, so are best kept in a code module
dictionaries of all these objects offer the greatest flexibility

Example of items dictionary, which is a dictionary of item objects
items["torch"] = <item object>

items["torch"].name = "torch"
items["torch"].description = "a flaming wooden torch"
items["key card"].name" = "key card",
items["key card"].description = "Property of Holiday Inn"

example of locations dictionary which is a dictionary of location objects
locations["hotel room"].name = "hotel room"
locations["hotel room"].description = "a damp hotel room"
locations["hotel room"].to_north = ""
locations["hotel room"].to_east = "coridoor"
locations["hotel room"].to_south = ""
locations["hotel room"].to_west = ""
locations["hotel room"].item_required = "key card"              # key of an item from the items dictionary
locations["hotel room"].items = ["torch","plastic sword"]       # a Python list of the dictionary keys of items in the location
'''

debug = True
gamestates = {'menu':0, 'play':1, 'dead':2, 'quit':3}
gamestate = gamestates['menu']
items:dict = {}
locations:dict = {}
enemies:dict = {}
current_location:str = ""

def format_line(text, length, border = "", align = "centre"):
	''' return line(s) of text that fit within the length in a list '''
	def pad_line(text, align, border):
		if len(text) % 2 == 1:
			text += " "		
		filler = ""
		if align == "centre":
			filler = "".ljust((length - len(text)) // 2," ")	# series of spaces to pad the text both sides
		elif align == "left":
			text = text.ljust(length - len(text), " ")
		else:													# assume align right
			text = text.rjust(length - len(text)," ")			# series of spaces to pad the text on the left
		return f"{border}{filler}{text}{filler}{border}"			
		
	return_list = []
	filler = ""
	if border != "":			# if border specified reduce length by 2
		length -= 2
	
	if len(text) < length:		# text fits ok
		return_list.append(pad_line(text, align, border))
	else: # text is longer than length chars so split it
		words = text.split(' ') # split into words
		text = ""				# re-use variable, so clear it
		num_words = len(words)
		for index in range(len(words)):
			if len(text) + len(words[index]) < length:
				text += f"{words[index]} "
			else:				# only reaches this if the text length is at maximum
				text = text.strip()
				if len(text) < length:
					return_list.append(pad_line(text, align, border))
				text = f"{words[index]} "
						
		text = text.strip()
		if len(text) > 0:
			#if len(text) < length:
			return_list.append(pad_line(text, align, border))

	return return_list	

def print_lines(text, length, border = "", align = "centre"):
	row = 0
	lines = format_line(text, length, border, align)
	for line in lines:
		print(line)
		row += 1	
	return row