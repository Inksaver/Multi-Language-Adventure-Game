local Shared = require("shared")
local Console = require "lib.console"
local class = require "lib.class"
local Location = class:derive("Location")

string.PadRight = Shared.PadRight
string.Trim 	= Shared.Trim

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

function Location:GetName()
	return self.Name 
end

function Location:GetDescription()
	return self.Description 
end

function Location:GetToNorth()
	return self.ToNorth 
end

function Location:GetToEast()
	return self.ToEast 
end

function Location:GetToSouth()
	return self.ToSouth
end

function Location:GetToWest()
	return self.ToWest
end

function Location:GetItems()
	return self.Items
end

function Location:GetItemRequired()
	return self.ItemRequired 
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

function Location:RemoveItem(item)
	self.Items = Shared.RemoveItem(self.Items, item)
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
	print((""):PadRight(Console.WindowWidth,"─"))
	print("You are in a ".. self.Name)
	local row = 2
	row = row + Shared.PrintLines(self.Description, Console.WindowWidth, "","left")
	if #exits == 0 then
		print("There are no exits")
		row = row + 1
	end
	if #self.Items > 0 then
		local output = "In this location there is: "
		for _, item in ipairs(self.Items) do
			output = output..item .. ", "
		end
		output = output:sub(1, output:len() - 2) -- remove comma
		row = row + Shared.PrintLines(output, Console.WindowWidth, "","left")
	end
	if self.Enemy ~= "" then
		print("ENEMY: "..self.Enemy.."!")
		row = row + 1
	end

	return exits, row	-- return exits list with name of exit as well as direction: {"east -> coridoor","north -> magic portal"}
end
return Location	