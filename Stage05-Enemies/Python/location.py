class Location:
	#constructor
	def __init__(self,
	             name:str,
	             description:str,
	             to_north:str = "",
	             to_east:str = "",
	             to_south:str = "",
	             to_west:str = "",
	             items:list[str] = [],
	             item_required:str = "",
				 enemy:str = ""):
		
		self._name:str = name
		self._description:str = description
		self._to_north:str = to_north.strip()
		self._to_east:str = to_east.strip()
		self._to_south:str = to_south.strip()
		self._to_west:str = to_west.strip()
		self._items:list[str] = items
		self._item_required:str = item_required
		self._enemy:str = enemy
		
	# properties
	@property
	def name(self) -> str:
		return self._name
	
	@property
	def display_name(self) -> str:
		return self._display_name	

	@property
	def description(self) -> str:
		return self._description

	@property
	def to_north(self) -> str:
		return self._to_north

	@property
	def to_east(self) -> str:
		return self._to_east

	@property
	def to_south(self) -> str:
		return self._to_south

	@property
	def to_west(self) -> str:
		return self._to_west
	
	@property
	def items(self) ->list:
		''' return a list of all items in this location '''
		return self._items
	
	@items.setter
	def items(self, list_of_items:list) -> None:
		''' allows items in this location to be set in bulk '''
		# list_of_items is a list of dictionary keys sent as
		# ["torch", "key"]
		self._items = list_of_items	
	
	@property
	def item_required(self) -> str:
		''' return item required to enter this location '''
		return self._item_required 
	
	@item_required.setter		
	def item_required(self, value:str) -> None:
		''' set the item required to enter this location '''
		self._item_required = value	
	
	@property
	def enemy(self):
		return self._enemy
	
	@enemy.setter
	def enemy(self, value):
		self._enemy = value
  
	# methods
	def add_item(self, item_key:str) -> None:
		''' add an item to the list of items in this location '''
		if item_key not in self._items:
			self._items.append(item_key)
	
	def remove_item(self, item_key:str) -> None:
		''' removes an item from list of items in this location '''
		if item_key in self._items:
			self._items.remove(item_key)
	
	def display_location(self) -> list:
		''' descrbe the current location, any items inside it, and exits '''
		exits:list = []
		if self._to_north != "":
			exits.append("north")
		if self._to_east != "":
			exits.append("east")
		if self._to_south!= "":
			exits.append("south")
		if self._to_west != "":
			exits.append("west")				
	
		print(f"You are in a {self._name}, {self._description}")
		if len(exits) == 0:
			print("There are no exits")
		row = 2
		if len(self._items) > 0:
			output = "In this location there is: "
			for item in self._items:
				output += item + ", "
			output = output.strip()[:-1] # remove comma
			print(output)
			row += 1
   
		if self._enemy != "":
			print(f"ENEMY: {self._enemy}!")
			row += 1
	
		return exits, row	# return exits list with name of exit as well as direction: ["east -> coridoor","north -> magic portal"]