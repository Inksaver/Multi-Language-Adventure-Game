import os
'''
the items, enemies and locations are shared by multiple files, so are best kept in a code module
'''

debug:bool = True
gamestates:dict = {'menu':0, 'play':1, 'dead':2, 'quit':3}
gamestate:int = gamestates['menu']
items:dict = {}
locations:dict = {}
enemies:dict = {}
current_location:str = ""
