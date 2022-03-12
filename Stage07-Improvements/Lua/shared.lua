--[[
	Lua equivalent of a static class, so does not have a constructor.

	This file is used to store global variables
	All other files in this project can:
	Shared = require "shared"

	use any of the variables and dictionaries by preceding the variable name with Shared
	Shared.Items       -- Dictionary of Item objects
	Shared.CurrentLocation -- Location object

	Use any of the functions:
	Shared.Sleep(2)
	Shared.Split() assgn first: string.Split = Shared.Split
]]

local Shared = {}

Shared.Items 			= {}
Shared.Enemies 			= {}
Shared.Locations 		= {} 		--table of Location objects eg Shared.Locations["home"] = <Location object>
Shared.CurrentLocation 	= ''		-- will be a string key of a Location after creation.
Shared.Debug 			= true
Shared.Gamestates 		= {menu = 1, play = 2, leaderboard = 3, quit = 4, dead = 5}
Shared.Gamestate 		= 1

--[[ Extender functions ]]
function Shared.Set(list) --from https://www.lua.org/pil/11.5.html
	-- eg list = {"red", "blue", "green"}
	local set = {}
	for _, v in ipairs(list) do set[v] = true end
	return set --{"red" = true, "blue" = true, "green" = true}
	--Use: local colours = Set(list)
	--if colours["red"] then -> true
end

function Shared.RemoveItem(tbl, item)
	--[[ remove an item from a list (table) using it's value]]
	local returnTable = {}
	for _, v in ipairs(tbl) do
        if v ~= item then
            table.insert(returnTable, v)
        end
    end
    return returnTable
end

function Shared.RemoveKey(tbl, key)
	--[[ remove an item from a table using it's key]]
	local returnTable = {}
	for k, v in pairs(tbl) do
        if k ~= key then
            returnTable[k] = v
        end
    end
    return returnTable
end

function Shared.RemoveValue(tbl, value)
	--[[ remove an item from a table using it's value]]
	local returnTable = {}
	for k, v in pairs(tbl) do
        if v ~= value then
            returnTable[k] = v
        end
    end
    return returnTable
end

--[[ Shared functions ]]
function Shared.FileExists(name)
	local f = io.open(name,"r")
	if f ~=nil then
	   io.close(f)
	   return true
	else
		return false
	end
end

function Shared.FormatLine(text, length, border, align)
	--[[ formats text to fit in required width  ]]
	border = border or ""										-- could be eg: ║
	align = align or "centre"									-- could be "left"
	
	local lib = {}													-- alternative method of private function
	function lib.PadLine(text, align, border)
		if text:len() % 2 == 1 then									-- make sure text has even no of chars
			text = text.." "
		end
		local filler = ""
		if align == "centre" then
			filler = (""):PadRight(math.floor((length - text:len()) / 2)," ")	-- series of spaces to pad the text both sides
		elseif align == "left" then
			text = text:PadRight(length - text:len(), " ")			-- add spaces on right side
		else
			text = text:PadLeft(length - text:len()," ")			-- add spaces on left side
		end
		return border..filler..text..filler..border					-- return padded line: "║   text   ║"
	end
	
	returnList = {}												-- empty table
	local filler = ""
	if border ~= "" then										-- decrease length if ║ or similar is used
		length = length - 2
	end
	if text:len() < length then									-- no line splitting required
		table.insert(returnList, lib.PadLine(text, align , border))
	else														-- line too long: split at space char
		local words = text:Split(" ")							-- table of words
		text = ""
		numWords = #words
		for i = 1, #words do
			if text:len() + words[i]:len() < length then		-- add each word to a string while less than length
				text = text..words[i].." "
			else												-- can't add this word as string too long
				text = text:Trim()								-- remove final space and add to table
				table.insert(returnList, lib.PadLine(text, align , border))
				text = words[i].." "									-- text contains first word only
			end
		end
		text = text:Trim()										-- remove trailing space from remaining words
		if text:len() > 0 then									-- add to table
			table.insert(returnList, lib.PadLine(text, align , border))
		end
	end
	
	return returnList
end

function Shared.InList(data, value)
	-- look for item in keys or value
	for k,v in pairs(data) do
		if k == value or v == value then
			return true
		end
	end
	return false
end

function Shared.IsEmpty(tbl)
	--[[ USE: table.IsEmpty = Shared.IsEmpty
			  if tbl:IsEmpty() then... ]]
	if tbl ~= nil then
		if next(tbl, nil) ~= nil then -- true if any items
			return false
		end
	end
	return true
end

function Shared.PadLeft(text, length, char)
	--[[Pads str to length len with char from left]]
	if char == nil then char = ' ' end
	local padding = ''
	local textlength = text:utf8len()
	for i = 1, length - textlength do
		padding = padding..char
	end
	return padding..text
end

function Shared.PadRight(text, length, char)
	--[[Pads str to length len with char from right
		test = test:lpad(8, ' ') or test = string.lpad(test, 8, ' ')]]
	if char == nil then char = ' ' end
	local padding = ''
	local textlength = text:Utf8len()
	for i = 1, length - textlength do
		padding = padding..char
	end
	return text..padding
end

function Shared.Sleep(s)
	local ntime = os.clock() + s * 0.7
    repeat until os.clock() > ntime
end

function Shared.PrintLines(text, length, border, align)
	border = border or ""
	align = align or "centre"
	local row = 0
	local Lines = Shared.FormatLine(text, length, border, align)
	for _, line in ipairs(Lines) do
		print(line)
		row = row + 1
	end

	return row
end

function Shared:Split(sSeparator, nMax, bRegexp)
	--[[use: tblSplit = SplitTest:Split('~') or tblSplit = string.Split(SplitTest, '~')]]   
	assert(sSeparator ~= '','separator must not be empty string')
	assert(nMax == nil or nMax >= 1, 'nMax must be >= 1 and not nil')

	local aRecord = {}
	local newRecord = {}

	if self:len() > 0 then
		local bPlain = not bRegexp
		nMax = nMax or -1

		local nField, nStart = 1, 1
		local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
		while nFirst and nMax ~= 0 do
			aRecord[nField] = self:sub(nStart, nFirst-1)
			nField = nField+1
			nStart = nLast+1
			nFirst,nLast = self:find(sSeparator, nStart, bPlain)
			nMax = nMax-1
		end
		aRecord[nField] = self:sub(nStart)
		
		for i = 1, #aRecord do
			if aRecord[i] ~= "" then
				table.insert(newRecord, aRecord[i])
			end
		end
	end
	
	return newRecord
end

function Shared.Trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function Shared.Utf8length(str)
	--[[ # or .len counts the bytes of a string, so gives incorrect length of UTF8 chars
		 use: local length = text:utf8len() 
	]]
	local asciiLength = 0
	local utf8length = 0
	for i = 1, #str do
		if string.byte(str:sub(i,i)) < 128 then
			asciiLength = asciiLength + 1
		else
			utf8length = utf8length + 1
		end
	end
	if utf8length > 0 then -- only 3 byte chars used in this script
		utf8length = utf8length / 3
	end
	
	return asciiLength + utf8length
end

string.Split 	= Shared.Split
string.Trim 	= Shared.Trim			-- if using as library: string.Trim = Shared.Trim -> "  Hello  ":Trim() -> "Hello"
string.Utf8len 	= Shared.Utf8length 	-- if using as library: string.Utf8length = Shared.Utf8length
string.PadRight	= Shared.PadRight
string.PadLeft 	= Shared.PadLeft
table.IsEmpty 	= Shared.IsEmpty
table.RemoveKey = Shared.RemoveKey		-- if using as library: table.RemoveKey = Shared.RemoveKey

return Shared