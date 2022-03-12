local Debug = {}
local Console = require "lib.console"
local Shared = require "shared"
local Player = require "player"
string.PadRight = Shared.PadRight

function Debug.DisplayEnemies()
	local height, width = Console.Resize(100, 25) -- 25, 100 if console else  -1, 0
	width = Console.WindowWidth
	print("The Dictionary shared.enemies contains the following data:")
	print(string.rep("═", width))
	for key,value in pairs(Shared.Enemies) do
		Shared.PrintLines(	"Name: "..key:PadRight(20)..
							"Strength: "..tostring(value:GetStrength()):PadRight(10)..
							"Health: "..tostring(value:GetHealth()):PadRight(10)..
							"DropItem: "..value:GetDropItem(), width, "", "left")
		Shared.PrintLines("Description: "..value:GetDescription(), width, "", "left")
		print(string.rep("═", width))
	end
	io.write("Enter to continue")
	io.read()
	Console.Resize(80, 25)
end

function Debug.DisplayItems()
	local width = 100
	local height = 25
	Console.Resize(width, height, true)
	print("The Dictionary shared.items contains the following objects:")
	print(string.rep("═", width)) -- 100 if console, 100 in zerobrane
	row = 2
	for key, value in pairs(Shared.Items) do
		if row > height - 5 then
			io.write("Enter for next screen")
			io.read()
			row, _ = Console.Clear() -- 0, 100 if console, -1, 0 if zerobrane
		end
		row = row + Shared.PrintLines( 	"Name: "..key:PadRight(25)..
										"Object: "..value.type, width, "", "left")
									
		row = row + Shared.PrintLines( 	"Uses: "..tostring(value:GetUses()):PadRight(25)..
										"CraftFrom: "..value:GetCraftItems(), width, "", "left")
									
		row = row + Shared.PrintLines( 	"Description: "..value:GetDescription(), width, "", "left")
		print(string.rep("─", width))
		row = row + 1
		if not Console.IsConsole then row = -1 end
	end
	print(string.rep("═", width))
	io.write("Enter to continue")
	io.read()
end

function Debug.DisplayLocations()
	local width = 100
	local height = 25
	Console.Resize(width, height, true)
	print("The Dictionary Shared.Locations contains the following data:")
	print(string.rep('─', width))
	--local row = -1
	local row = 2
	if height > -1 then row = 2 end
	for key, value in pairs(Shared.Locations) do
		--if row > -1 and row > height - 7 then
		if row > height - 7 then
			io.write("Enter for next screen")
			io.read()
			row, _ = Console.Clear() -- 0, 100 if console, -1, 0 if zerobrane
		end
		print("Name: "..tostring(key):PadRight(22).."Item required: "..value:GetItemRequired():PadRight(32).."Enemy: "..value:GetEnemy())
		print("North: "..value:GetToNorth():PadRight(21).."East: "..value:GetToEast():PadRight(17).."South: "..value:GetToSouth():PadRight(17).."West: "..value:GetToWest())
		row = row + 2
		row = row + Shared.PrintLines("Description: "..value:GetDescription(), width, "", "left")				
		print("Items: "..table.concat(value:GetItems(), ", "):PadRight(40))
		print(string.rep('─', width))
		row = row + 2
		if not Console.IsConsole then row = -1 end
	end
	io.write("Enter to continue")    
	io.read()
	Console.Resize(80, 25, true)
end

function Debug.DisplayPlayer()
	--[[ main use for debug. prints all player properties ]]
	print(string.rep('═', 80))
	print("Player properties:")
	print(string.rep('═', 80))
	print("Characters available: ".. table.concat(Player.Characters, ", "))
	print(string.rep('═', 80))
	print("Name:                 "..Player.Name)
	print("Health:               "..Player.Health)
	print("Strength:             "..Player.Strength)
	print("Character:            "..Player.Character)
	print("Inventory:            "..table.concat(Player.Inventory, ", "))
	print(string.rep('═', 80))
end

return Debug