''' as this sub-class of Item is a separate file, Item has to be imported '''
import item
class Weapon(item.Item): #inherits item.Item class
	def __init__(self, name:str, description:str = "", craftitems:list[str] = [], uses:int = 0, container:str = "", damage:int = 0):
		item.Item.__init__(self, name, description, craftitems, uses, container)	# invoking the __init__ of the parent class	
		self._damage = damage
	
	@property
	def damage(self):
		return self._damage
	@damage.setter
	def damage(self, value):
		self._damage = value