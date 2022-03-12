kb = require "lib.kboard"
--Shared = require "shared"
Console = require "lib.console"


local function Trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end
string.Trim = Trim

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
	-- local pfile = popen('dir "'..directory..'" /b /ad') --directories only
	local pfile = popen('dir "'..directory..'" /b')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function testScandir()
	--print(io.popen("dir").__gc)
	--current_dir=io.popen"cd":read'*l'
	--print(current_dir)
	local cwd = io.popen"cd":read'*l'
	local loadPath = ''
	local savePath = ''
	local loadFileName = ''
	loadPath = cwd..'/'..'games'
	savePath = cwd..'/'..'saves'
	--os.execute( "mkdir "..'"'..loadPath..'"' )
	--os.execute( "mkdir "..'"'..savePath..'"' )
	local files = scandir(loadPath)
	for _, v in ipairs(files) do
		print(v)
	end
end

local function getRow(row, rows)
	rows = rows or 1
	if row == -1 then
		return -1
	else
		return row + rows
	end
end

function testKboard()
	Shared.Clear()
	local row = -1
	if Shared.IsConsole then
		row = 0
	end
	local name = kb.getString("What is your name?", true, 1, 10, row)
	print("Hello "..name)
	row = getRow(row, 2)
	local age = kb.getInteger("How old are you?", 5, 110, row)
	print("You are ".. age.. " years old.")
	row = getRow(row, 2)
	local height = kb.getFloat("How tall are you?", 0.5, 2.0, row)
	print("You are ".. height.." metres tall.")
	row = getRow(row, 2)
	local likesPython = kb.getBoolean("Do you like Python? (y/n)", row)
	if likesPython then
		print("You DO like Python!")
	else
		print("You DO NOT like Python!")
	end
	local title = "Choose your favourite language"
	local options = {"C#", "Python", "Lua", "Java"}
	row = getRow(row, 2)
	local choice = kb.menu(title, options, row)
	print("Your favourite language is "..options[choice])
end


function testConsole()
	print("Environment: ".. Console.GetEnvironment())
	print("Console.OSName: "..Console.OSName)
	print("Console.IsConsole: "..tostring(Console.IsConsole))
	print("Console.WindowWidth: "..Console.WindowWidth)
	print("Console.WindowHeight: "..Console.WindowHeight)
	print("Console.IDE: "..Console.IDE)
	Console.Resize(90, 25, false)
	print("Environment: ".. Console.GetEnvironment())
	print("Console.OSName: "..Console.OSName)
	print("Console.IsConsole: "..tostring(Console.IsConsole))
	print("Console.WindowWidth: "..Console.WindowWidth)
	print("Console.WindowHeight: "..Console.WindowHeight)
	print("Console.IDE: "..Console.IDE)
	string.Trim = Console.Trim
	test = "    test    "
	print("'"..test.."' trimmed: '"..test:Trim().."'")
	test = "PadRight to 20"
	print(Console.PadRight(test, 20, "+"))
	test = "PadLeft to 20"
	print(Console.PadLeft(test, 20, "+"))
end
--testScandir()
--testKboard()
--console()
testConsole()
if Console.IDE == "cmd" then
	io.write("Enter to quit")
	io.read()
end
