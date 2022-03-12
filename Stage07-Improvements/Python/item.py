class Item:
	#constructor
	def __init__(self, name:str, description:str = "", craftitems:list[str] = [], uses:int = 0, container:str = ""):
		self._name:str  = name
		self._description:str = description
		self._craft_items = craftitems
		self._uses = uses
		self._container = container
	
	'''
	example of traditional property getters and setters with function calls
	from outside the class using:
	torch = item.Item("torch"," a torch") # create an Item object 
	print(torch.get_description())                # note .get_description()
	torch.set_description("flaming wooden torch") # note set_description(value)
	'''		
	def get_description(self) -> str:
		return self._description
	
	def set_description(self, value:str) -> None:
		self._description = value
		
	'''
	example of more modern property getters and setters allowing direct access
	from outside the class using:
	torch = item.Item("torch"," a torch") # create an Item object (same as above)
	print(torch.name)                # note direct .name , rather than .get_name()
	torch.name = "LED torch"         # note direct .name = value rather than .set_name(value)
	'''
	@property
	def name(self) -> str:					# the @property decorator allows two def name(): functions 
		return self._name
	@name.setter
	def name(self, value:str) -> None:		# same signature but the @name.setter allows this
		self._name = value	
		
	@property
	def craft_items(self, as_list = False):
		if as_list:
			return self._craft_items
		output = ""
		for item in self._craft_items:
			output += f"{item},"
		return output
	
	@property
	def uses(self):
		return self._uses	
	
	@property
	def container(self):
		return self._container	