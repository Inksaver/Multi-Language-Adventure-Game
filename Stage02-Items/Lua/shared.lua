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

Shared.Debug 			= true
Shared.Gamestates 		= {menu = 1, play = 2, leaderboard = 3, quit = 4, dead = 5}
Shared.Gamestate 		= 1
Shared.Items 			= {}
Shared.Enemies 			= {}
Shared.Locations 		= {} 		--table of Location objects eg Shared.Locations["home"] = <Location object>
Shared.CurrentLocation 	= ''		-- will be a string key of a Location after creation.

--[[ Extender functions ]]
function Shared.Set(list) --from https://www.lua.org/pil/11.5.html
	-- eg list = {"red", "blue", "green"}
	local set = {}
	for _, v in ipairs(list) do set[v] = true end
	return set --{"red" = true, "blue" = true, "green" = true}
	--Use: local colours = Set(list)
	--if colours["red"] then -> true
end
function table.removeKey(t, k)
	local i = 0
	local keys, values = {},{}
	for k,v in pairs(t) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end

	while i>0 do
		if keys[i] == k then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end

	local a = {}
	for i = 1,#keys do
		a[keys[i]] = values[i]
	end

	return a
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

string.Split = Shared.Split
string.Trim = Shared.Trim			-- if using as library: string.Trim = Shared.Trim -> "  Hello  ":Trim() -> "Hello"
string.Utf8len = Shared.Utf8length -- if using as library: string.Utf8length = Shared.Utf8length
table.IsEmpty = Shared.IsEmpty

return Shared