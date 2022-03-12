--[[
kboard static class returns string, integer, float, boolean and menu choices.
Use:

row = Kboard.Clear();
name = Kboard.GetString("What is your name?", true, 1, 10, row);
age = Kboard.GetInteger("How old are you", 5, 110, row);
height = Kboard.GetRealNumber("How tall are you?", 0.5, 2.0, row);
likesPython = Kboard.GetBoolean("Do you like C#? (y/n)", row);

options = {"Brilliant", "Not bad", "Could do better", "Rubbish"};
choice = Kboard.Menu("What do think of this utility?", options, row)
]]
local Kboard = {}
local blank = string.rep(" ", 79)
local delay = 2

local function trim(s)
	--[[ trim leading and trailing spaces ]]
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end
string.trim = trim
string.strip = trim
--[[from http://lua-users.org/wiki/StringRecipes
	Change an entire string to Title Case (i.e. capitalise the first letter of each word)
	Add extra characters to the pattern if you need to. _ and ' are
	found in the middle of identifiers and English words.
	We must also put %w_' into [%w_'] to make it handle normal stuff
	and extra stuff the same.
	This also turns hex numbers into, eg. 0Xa7d4
	
	str = str:gsub("(%a)([%w_']*)", tchelper)
]]
local function tchelper(first, rest)
   return first:upper()..rest:lower()
end

--[[  These local functions are private, not called directly from other files ]]
local function setCursorPos(row, col)
	--[[ position cursor in terminal at row, col ]]
	io.write(string.char(27).."["..row..";"..col.."H")
end

local function clearInputField(row)
	--[[ use setCursorPos to delete a line of text ]]
	if row >= 0 then
		setCursorPos(row, 0)
		print(blank)
		setCursorPos(row, 0)
	end
end

local function errorMessage(row, errorType, userInput, minValue, maxValue)
	--[[ Display error message to the user for <delay> seconds ]]
	minValue = minValue or 0
	maxValue = maxValue or 0
	local message = "Just pressing the Enter key or spacebar doesn't work" -- default for "noinput"
	if errorType == "string" then
		message = "Try entering text between "..minValue.." and "..maxValue.." characters"
	elseif errorType == "bool" then
		message = "Only anything starting with y or n is accepted"
	elseif errorType == "nan" then
		message = "Try entering a number - "..userInput.." does not cut it"
	elseif errorType == "notint" then
		message = "Try entering a whole number - "..userInput.." does not cut it"
	elseif errorType == "range" then
		message = "Try a number from "..minValue.." to "..maxValue
	end
	
	if row > 0 then
		message = ">>> "..message.." <<<"	-- output to console / terminal
	else
		message = message.."..."		-- output to IDE
	end
		
	if row >= 0 then
		clearInputField(row + 1)				-- clear row just used
	end
	print(message)
	if row >= 0 then
		Kboard.Sleep(delay)
		clearInputField(row + 1)
	end
end

local function getMaxLength(title, menuList, windowWidth)
	menuList = menuList or nil
	windowWidth = windowWidth or 0
	if windowWidth > 0 then
		return windowWidth - 2
	end
	
	local maxLen = title:len()
	for _, line in pairs(menuList) do
		if line:len() + 9 > maxLen then
			maxLen = line:len() + 9
		end
	end
	
	maxLen = maxLen + math.floor(maxLen / 4)
	if maxLen % 2 == 1 then
		maxLen = maxLen + 1
	end
	
	return maxLen
end

local function processInput(prompt, minValue, maxValue, dataType, row, windowWidth)
	--[[ validate input, raise error messages until input is valid ]]
	local validInput = false
	local userInput
	local width = windowWidth
	if width == 0 then width = 80 end
	while not validInput do
		if windowWidth > 0 then
			clearInputField(row + 2)
			clearInputField(row + 1)
			clearInputField(row)
		end
		print(string.rep("─", width))
		if windowWidth > 0 then
			print()
			print(string.rep("─", windowWidth))
			setCursorPos(row + 1 , 0)
		end
		io.write(prompt.."_")
		userInput = io.read():trim()
		local output = userInput
		if dataType == "string" then
			if string.len(userInput) == 0 and minValue > 0 then
				errorMessage(row, "noinput", output)
			else
				if string.len(userInput) < minValue or string.len(userInput) > maxValue then
					errorMessage(row, "string", output, minValue, maxValue)
				else
					validInput = true
				end
			end
		else
			if string.len(userInput) == 0 then
				errorMessage(row, "noinput", output)
			else
				if dataType == "bool" then		
					if userInput:sub(1, 1):lower() == "y" then
						userInput = true
						validInput = true
					elseif userInput:sub(1, 1):lower() == "n" then
						userInput = false
						validInput = true
					else
						errorMessage(row, "bool", output)
						
					end
				else
					if dataType == "int" or dataType == "float" then
						userInput = tonumber(userInput)			
					end
					if userInput == nil then
						errorMessage(row, "nan", output)
					else
						if userInput >= minValue and userInput <= maxValue then
							if math.floor(userInput / 1) ~= userInput and dataType == "int"  then
								errorMessage(row, "notint", output)
							else
								validInput = true
							end
						else
							errorMessage(row, "range", output, minValue, maxValue)
						end
					end
				end
			end
		end
	end
	return userInput
end

function Kboard.getString(prompt, withTitle, minValue, maxValue, row, windowWidth) 
	--[[ Return a string. withTitle, minValue and maxValue are given defaults if not passed ]]
	withTitle = withTitle or false
	minValue = minValue or 1
	maxValue = maxValue or 20
	row = row or -1
	windowWidth = windowWidth or 0
	if row >= 0 then
		row = row + 1
	end
	local userInput = processInput(prompt, minValue, maxValue, "string", row, windowWidth)
	if withTitle then
		userInput = Kboard.toTitle(userInput)
	end
	return userInput
end

function Kboard.getFloat(prompt, minValue, maxValue, row, windowWidth) 
	--[[ Return a real number. minValue and maxValue are given defaults if not passed ]]
	minValue = minValue or 0
	maxValue = maxValue or 1000000.0
	row = row or -1
	windowWidth = windowWidth or 0
	if row >= 0 then
		row = row + 1
	end
	return processInput(prompt, minValue, maxValue, "float", row, windowWidth)
end

function Kboard.getInteger(prompt, minValue, maxValue, row, windowWidth) 
	--[[ Return an integer. minValue and maxValue are given defaults if not passed ]]
	minValue = minValue or 0
	maxValue = maxValue or 65536
	row = row or -1
	windowWidth = windowWidth or 0
	if row >= 0 then
		row = row + 1
	end

	return processInput(prompt, minValue, maxValue, "int", row, windowWidth)
end
		
function Kboard.getBoolean(prompt, row, windowWidth)
	--[[ Return a boolean. Based on y(es)/ n(o) response ]]
	row = row or -1
	windowWidth = windowWidth or 0
	if row >= 0 then
		row = row + 1	
	end
	return processInput(prompt, 1, 3, "bool", row, windowWidth)
end
	
function Kboard.toTitle(Text) 
	--[[ converts any string to Title Case ]]
	return Text:gsub("(%a)([%w_']*)", tchelper)
end

function Kboard.PadRight(text, length, char)
	--[[
	Pads string to length len with chars from right
	test = Console.PadRight("test", 10, "+") -> "test++++++"]]
	if char == nil then char = ' ' end
	local padding = ''
	local textlength = text:Utf8len()
	for i = 1, length - textlength do
		padding = padding..char
	end
	return text..padding
end

function Kboard.Sleep(s) 
    --[[ Lua version of Python time.sleep(2) ]]
	local sec = tonumber(os.clock() + s); 
    while (os.clock() < sec) do end 
end

function Kboard.Menu(title, list, row, windowWidth)
	--[[ displays a menu using the text in 'title', and a list of menu items (string) ]]
	row = row or -1
	windowWidth = windowWidth or 0
	local width = windowWidth
	if width == 0 then width = 80 end
	
	if title:len() % 2 == 1 then
		title = title.." "
	end
	
	local rows  = -1
	if row >= 0 then
		rows = row + #list + 4
	end
	
	local maxLen = getMaxLength(title, list, width)
	local filler = string.rep(" ", math.floor((maxLen - title:len()) / 2))
	local index = 1
	print("╔"..string.rep("═", maxLen).."╗")
	print("║"..filler..title..filler.."║")
	print("╠"..string.rep("═", maxLen).."╣")
	for _, item in ipairs(list) do
		if index < 10 then
			print("║     "..index..") "..item:PadRight(maxLen - 8, " ").."║")
		else
			print("║    "..index..") "..item:PadRight(maxLen - 8, " ").."║")
		end
		index = index + 1
	end
	print("╚"..string.rep("═", maxLen).."╝")
	return Kboard.getInteger("Type the number of your choice (1 to "..index-1 ..")", 1, #list, rows, windowWidth)
end

function Kboard.Utf8length(str)
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

string.PadRight = Kboard.PadRight	-- if using as library: string.PadRight = Kboard.PadRight 
string.Utf8len = Kboard.Utf8length 	-- if using as library: string.Utf8length = Kboard.Utf8length 
	
return Kboard