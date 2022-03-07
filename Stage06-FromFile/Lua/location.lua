local Shared = require("shared")
local class = require "lib.class"
local Location = class:derive("Location")

function Location:new(name,
	             description,
	             toNorth,
	             toEast,
	             toSouth,
	             toWest,
	             items,
	             itemRequired,
	             enemy)
	self.Name 			= name
	self.Description 	= description			-- string
	self.ToNorth 		= toNorth or ""			-- string
	self.ToEast 		= toEast or ""			-- string
	self.ToSouth 		= toSouth or ""			-- string
	self.ToWest 		= toWest or ""			-- string
	self.Items 			= items or {}			-- Item keys
	self.ItemRequired 	= itemRequired or ""	-- Item key
	self.Enemy 			= enemy	or ""			-- Enemy key
end

function table.removeKey(tbl, value)
	local index = 0
	for k,v in pairs(tbl) do
		if v == value then
			index = k
			break
		end
	end
	if index > 0 then
		table.remove(tbl, index)
	end
	return tbl
end

local function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end
string.trim = trim
local function TrimEnd(s, char)
	if s:sub(#s - #char + 1) == char then
		return s:sub(1, #s - #char)
	else
		return s
	end
	--return (s:match( "(.-)%s*$" ))
end
string.TrimEnd = TrimEnd

function Location:GetName()
	return self.Name --string
end

function Location:GetDescription()
	return self.Description --string
end

function Location:GetToNorth()
	return self.ToNorth --string
end

function Location:GetToEast()
	return self.ToEast --string
end

function Location:GetToSouth()
	return self.ToSouth --string
end

function Location:GetToWest()
	return self.ToWest --string
end

function Location:GetItems()
	return self.Items
end

function Location:GetItemRequired()
	return self.ItemRequired -- Item key
end

function Location:GetEnemy()
	return self.Enemy
end

function Location:SetEnemy(value)
	self.Enemy = value
end

--[[  public methods ]]
function Location:AddItem(item) -- add item key
	table.insert(self.Items, item)
end

function Location:RemoveItem(itemKey)
	self.Items = table.removeKey(self.Items, itemKey)
end

function Location:DisplayLocation()
	--[[  descrbe the current location, any items inside it, and exits ]]
	local exits = {}
	if self.ToNorth ~= "" then
		table.insert(exits, "north -> "..self.ToNorth) -- adds name of exit to list
	end
	if self.ToEast ~= "" then
		table.insert(exits, "east -> "..self.ToEast) -- adds name of exit to list
	end
	if self.ToSouth ~= "" then
		table.insert(exits, "south -> "..self.ToSouth) -- adds name of exit to list
	end
	if self.ToWest ~= "" then
		table.insert(exits, "west -> "..self.ToWest) -- adds name of exit to list
	end
	local row = 1
	print("You are in a ".. self.Name..", "..self.Description)
	if #exits == 0 then
		print("There are no exits")
		row = 2
	end
	if #self.Items > 0 then
		local output = "In this location there is: "
		for _, item in ipairs(self.Items) do
			output = output..item .. ", "
		end
		output = output:sub(1, output:len() - 2) -- remove comma
		print(output)
		row = row + 1
	end
	if self.Enemy ~= "" then
		print("ENEMY: "..self.Enemy.."!")
		row = row + 1
	end

	return exits, row	-- return exits list with name of exit as well as direction: {"east -> coridoor","north -> magic portal"}
end
return Location	