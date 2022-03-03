--[[
This class is used to get console information.
On Windows ANSI codes can be 'reluctant' to start, so clearing the console is usually the best start
USE: Console = require "console" (or "folder.console" if stored elsewhere)
Call any console function eg Console.Clear() or Console.Initialise():
Console.Initialise() -> runs Console.Initialise() and sets isInitialised = true
Console.Clear() -> runs Console.Initialise() and sets isInitialised = true
populates properties:
Console.OSName
Console.IsConsole
Console.WindowWidth
Console.WindowHeight
Console.IDE

utf8 box characters stored here for easy copy/paste:

┌ ┬ ┐ ─ ╔ ╦ ╗ ═
 
├ ┼ ┤ │ ╠ ╬ ╣ ║
 
└ ┴ ┘   ╚ ╩ ╝

]]

local Console = {}

local isInitialised 	= false
Console.OSName  		= ""
Console.IsConsole 		= false
Console.WindowWidth 	= 0
Console.WindowHeight 	= 0
Console.IDE 			= ""

function Console.AddLines(numLines, currentLines) 
	--[[ overloaded function depending on currentLines == nil ]]
	local blank = string.rep(" ", Console.WindowWidth)
	if currentLines == nil then -- just print the number of lines requested
		if numLines > 0 then
			for i = 1, numLines do
				print(blank)
			end
		end
	else -- print enough lines to leave numLines empty at the foot of the console
		local leaveLines = numLines
		numLines = Console.WindowHeight - currentLines - leaveLines
		if numLines > 0 then
			for i = 1, numLines do
				print(blank)
			end
		end
	end
	return numLines
end	

function Console.Clear()
	--[[ clear console/terminal ]]
	if Console.IsConsole then
		row = 0
		if Console.OSName == 'nt' then
			os.execute("cls")
		else
			os.execute("clear")
		end
		return 0	-- if running in terminal/console row = 0
	else
		Console.AddLines(Console.WindowHeight) -- running in an IDE, so just add blank lines equivalent to console height
		return -1 	-- if running in ide row = -1
	end
end

function Console.GetTerminalSize()
	local rows = 0
	local cols = 0
	if Console.OSName == "nt" then
		local console = io.popen "mode"
		for line in console:lines() do
			if line:find("Lines:") ~= nil then -- Lines:          9001
				local lineAsString = line:sub(line:find("Lines:") + 7)
				lineAsString = lineAsString:Trim()
				rows = tonumber(lineAsString)
			end
			if line:find("Columns:") ~= nil then -- Columns:        120
				lineAsString = line:sub(line:find("Columns:") + 9)
				lineAsString = lineAsString:Trim()
				cols = tonumber(lineAsString)
			end
		end
		--[[
		Running from Zerobrane			Running from cmd
		Status for device COM1:
		-----------------------
			Baud:            1200
			Parity:          None
			Data Bits:       7
			Stop Bits:       1
			Timeout:         OFF
			XON/XOFF:        OFF
			CTS handshaking: OFF
			DSR handshaking: OFF
			DSR sensitivity: OFF
			DTR circuit:     ON
			RTS circuit:     ON


		Status for device CON:
		----------------------
			Lines:          9001		Lines:          25
			Columns:        120			Columns:        90
			Keyboard rate:  31
			Keyboard delay: 1
			Code page:      65001
		]]
	else
		
	end
	Console.WindowHeight = rows
	Console.WindowWidth = cols
	return rows, cols
end

function Console.GetEnvironment() 
	--[[ running in an IDE or terminal? 
	ZeroBrane:
	;.\?.dll;C:\Users\<user>\Dropbox\PortableApps\ZeroBraneStudio\App\bin\?.dll;
	C:\Users\<user>\Dropbox\PortableApps\ZeroBraneStudio\App\bin\loadall.dll;
	C:\Users\<user>\Dropbox\PortableApps\ZeroBraneStudio\App\bin/clibs/?.dll
	open-with: (set to lua53.exe)
	C:\Program Files (x86)\Lua\?.dll;
	C:\Program Files (x86)\Lua\..\lib\lua\5.3\?.dll;
	C:\Program Files (x86)\Lua\loadall.dll;.\?.dll
	]]
	local cpath = package.cpath
	local ide = ""
	if Console.GetOS() == 'nt' then
		if cpath:find('ZeroBrane') ~= nil then
			ide = "ZeroBraneStudio"
		elseif cpath:find('\\Lua') ~= nil or cpath:find('\\lua') ~= nil then
			ide = 'cmd'
		elseif cpath:find(';') == nil then
			ide = 'vscode'
		end
	else
		if cpath:find('zbstudio') ~= nil then
			ide = "ZeroBraneStudio"
		else
			ide = "terminal"
		end
	end
	
	Console.IDE = ide
	return ide
end

function Console.GetOS()
	--[[ If backslashes found: only on Windows! ]]
	local cpath = package.cpath
	if cpath:find('\\') == nil then
		return 'posix'
	else
		return 'nt'
	end
end

function Console.Initialise()
	if not isInitialised then
		Console.OSName = Console.GetOS() -- 'nt' or 'posix'
		local environment = Console.GetEnvironment()
		
		if environment ~= "cmd" and environment ~= "terminal" then
			Console.IsConsole = false
		else
			Console.IsConsole = true
		end
		local rows, cols = Console.GetTerminalSize()
		if rows == 9001 then
			if Console.IsConsole then
				Console.Resize(cols, 25)
				Console.GetTerminalSize()
			else
				Console.WindowHeight = 25
			end
		end
		isInitialised = true
	end
end

function Console.PadLeft(text, length, char)
	--[[Pads str to length len with char from left]]
	if char == nil then char = ' ' end
	local padding = ''
	local textlength = text:Utf8len()
	for i = 1, length - textlength do
		padding = padding..char
	end
	return padding..text
end

function Console.PadRight(text, length, char)
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

function Console.Resize(windowWidth, windowHeight, clear)
	--[[ resize console / terminal ]]
	if clear == nil then clear = true end
	if Console.IsConsole then
		if Console.OSName == 'nt' then
			os.execute("mode "..windowWidth..","..windowHeight)
		else
			local cmd = "'\\e[8;"..windowHeight..";"..windowWidth.."t'"
			os.execute("echo -e "..cmd)
		end
		if clear then
			Console.Clear()
		end
		isInitialised = false
		Console.Initialise()
	end
end	

function Console.Trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function Console.Utf8length(str)
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

string.Utf8len = Console.Utf8length -- if using as library: string.Utf8length = Console.Utf8length 
string.Trim = Console.Trim			-- if using as library: string.Trim = Console.Trim -> "  Hello  ":Trim() -> "Hello"

Console.Initialise()

return Console