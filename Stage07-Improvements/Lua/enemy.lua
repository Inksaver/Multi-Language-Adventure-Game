local class = require "lib.class"
local Enemy = class:derive("Enemy")

function Enemy:new(name, description , strength, health, dropItem)
	self.Name = name
	self.Description = description or ''
	self.Strength = strength or 0
	self.Health = health or 0
	self.MaxHealth = health
	self.DropItem = dropItem or ''
end
-- getters
function Enemy:GetName()
	return self.Name
end

function Enemy:GetDescription()
	return self.Description
end

function Enemy:GetStrength()
	return self.Strength
end
		
function Enemy:GetHealth()
	return self.Health
end

function Enemy:GetMaxHealth()
	return self.MaxHealth
end
		
function Enemy:GetDropItem()
	return self.DropItem
end

-- setters
function Enemy:SetDropItem(value)
	self.DropItem = value
end
			
function Enemy:SetHealth(value)
	self.Health = value
end
		
function Enemy:SetStrength(value)
	self.Strength = value
end

-- methods
function Enemy:Attack(Player)
	local message = self.Name.." attacks you, inflicting ".. self.Strength.." damage"
	Player.ReceiveAttack(self.Strength)
	
	return message	
end

function Enemy:ReceiveAttack(damage)
	self.Health = self.Health - damage
	if self.Health <= 0 then
		self.Health = 0
	end
end

return Enemy