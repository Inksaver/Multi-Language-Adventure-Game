local class = require "item"			-- use Iem as base class
local Weapon = class:derive("Weapon")	-- Weapon is derived from Item

function Weapon:new(name, description , craftitems, uses, container, damage)
	self.Name = name
	self.Description = description or ''
	self.CraftItems = craftitems or {}
	self.Uses = uses or 0
	self.Container = container or ''
	self.Damage = damage or 0
end

function Weapon:GetDamage()
	return self.Damage
end

function Weapon:SetDamage(value)
	self.Damage = value
end

return Weapon