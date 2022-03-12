class Enemy:
	#constructor
	def __init__(self, name, description, strength = 0, health = 0, drop_item = ""):
		self._name = name
		self._description = description
		self._strength = strength
		self._health = health
		self._max_health = health
		self._drop_item = drop_item
	
	# getters / setters
	@property
	def name(self):
		return self._name

	@property
	def description(self):
		return self._description

	@property
	def strength(self):
		return self._strength
	@strength.setter	
	def strength(self, value):
		self._strength = value	
		
	@property
	def health(self):
		return self._health
	@health.setter
	def health(self, value):
		self._health = value	
	
	@property
	def max_health(self):
		return self._max_health
	
	@property
	def drop_item(self):
		return self._drop_item
	
	@drop_item.setter		
	def drop_item(self, value):
		self._DropItem = value
	
	# methods
	def attack(self, player:object):
		message = f"{self._name} attacks you, inflicting {self._strength} damage"
		player.receive_attack(self._strength)
		
		return message			
		
	def receive_attack(self, damage):
		self._health -= damage
		if self._health <= 0 :
			self._health = 0	