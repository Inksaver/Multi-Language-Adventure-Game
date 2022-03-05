local class = require "lib.class"
local Item = class:derive("Item") -- allows the use of print(object.type) -> "Item"

function Item:new(name, description , craftitems, uses, container)
	self.Name = name
	self.Description = description or ''
	self.Craftitems = craftitems or {}
	self.Uses = uses or 0
	self.Container = container or ''
end

function Item:GetName()
	return self.Name
end

function Item:GetDescription()
	return self.Description
end

function Item:SetDescription(value)
	self.Description = value
end

function Item:GetCraftitems()
	return self.Craftitems -- {'pliers', 'coat hanger'}
end

function Item:GetUses()
	return self.Uses
end

function Item:GetContainer()
	return self.Container
end

function Item:SetContainer(value)
	self.Container = value
end

return Item
