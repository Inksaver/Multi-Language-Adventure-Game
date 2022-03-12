local class = require "lib.class"
local Item = class:derive("Item")

function Item:new(name, description , craftitems, uses, container)
	self.Name = name
	self.Description = description or ''
	self.CraftItems = craftitems or {}
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

function Item:GetCraftItems()
	return table.concat(self.CraftItems, ",") -- "pliers,coat hanger"
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
