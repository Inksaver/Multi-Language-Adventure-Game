'''
the items, enemies and locations are shared by multiple files, so are best kept in a code module

'''

debug = True
gamestates = {'menu':0, 'play':1, 'dead':2, 'quit':3}
gamestate = gamestates['menu']
items:dict = {}
locations:dict = {}
enemies:dict = {}
current_location:str = ""
	

