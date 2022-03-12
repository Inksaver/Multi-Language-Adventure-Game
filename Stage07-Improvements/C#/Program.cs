using System;
using System.Collections.Generic;

namespace Adventure_06_Improvements
{
    internal class Program
	{
		/// <summary>
		/// kboard -> modified menu and other functions to improve appearance
		/// console -> modified clear() and resize() to return row and width
		/// new class -> Debug all debug output moved here
		/// game -> loadFromFile improvements and display debug for all objects
		/// game -> DisplayIntro improved appearance
		/// game -> ModifyPlayer cosmetic changes
		/// location -> update displayLocation
		/// player -> Attack() updated, removed DisplayPlayer()
		/// shared -> FormatLine and PrintLine added, 3 new remove value/key/item from table
		/// </summary>
		private static string CheckExit(Location here, string direction)
        {
			/// check if next location has an itemRequired to enter ///
			Location nextLocation = here;
			if (direction == "north")
				nextLocation = Shared.Locations[here.ToNorth];
			else if (direction == "east")
				nextLocation = Shared.Locations[here.ToEast];
			else if (direction == "south")
				nextLocation = Shared.Locations[here.ToSouth];
			else if (direction == "west")
				nextLocation = Shared.Locations[here.ToWest];

			string itemRequired = nextLocation.ItemRequired;
			if (itemRequired != "")
			{
				if (Player.Inventory.Contains(itemRequired))
					Console.WriteLine($"You use the {itemRequired} in your inventory to enter...".PadRight(Console.WindowWidth - 1));
				else
				{
					Console.WriteLine($"You need {itemRequired} in your inventory to go that way.".PadRight(Console.WindowWidth - 1));
					nextLocation = here;
				}
				Kboard.Sleep(2);
			}

			return nextLocation.Name;
        }
		private static void Fight(Location here)
        {
			/// pick a fight with an enemy ///
			Console.Clear();
			Enemy enemy = Shared.Enemies[here.Enemy];   // use variable for convenience
			string weapon = "fist";						// in case inventory is empty
			if (Player.Inventory.Count > 0)
				weapon = Player.Inventory[Kboard.Menu("Choose your weapon", Player.Inventory, 0, Console.WindowWidth)];
			Console.WriteLine(Player.Attack(here, weapon).PadRight(Console.WindowWidth - 1));     // player.attack() returns a string message
			string message = "";
			if (enemy.Health == 0)
			{
				message = $"The {enemy.Name} is dead";
				if (enemy.DropItem != "")
					here.AddItem(enemy.DropItem);
				message += $" and dropped a {enemy.DropItem}";
				here.Enemy = "";
			}
			else
				message = enemy.Attack();

			Console.WriteLine(message.PadRight(Console.WindowWidth - 1));  // print attack details
			if (Player.Health == 0)
			{
				Console.WriteLine($"You died at the hands of the {enemy.Name}".PadRight(Console.WindowWidth - 1));
				Kboard.Sleep(2);
				Console.WriteLine("The game is over!".PadRight(Console.WindowWidth - 1));
				Kboard.Sleep(2);
				Shared.Gamestate = Shared.Gamestates["dead"];   // this breaks the gameloop in main()
			}
		}
		private static string[] TakeAction(Location here, List<string> exits, int row)
        {
			/// choose player action ///	
			List<string> options = new List<string>();
			// check for enemies
			string enemy = here.Enemy;
			if (enemy != "")
				options.Add($"Attack {enemy}!");
			// examine / take any items
			List<string> items = here.Items;
			foreach(string item in items)
            {
				options.Add($"Examine {item}");
				options.Add($"Take {item}");
			}
			// open inventory
			if (Player.Inventory.Count > 0)
				options.Add("Open your inventory");
			// take an exit
			foreach (string exit in exits)
			{
				options.Add($"Go {exit}");
			}
			// quit game
			options.Add("Quit");

			string choice = options[Kboard.Menu("What next?", options, row)];
			// choice examples: "Attack...", Examine...", "Go..." etc
			if (choice.Contains("Attack"))
				return new string[] { "fight", "" };
			else if (choice.Contains("Quit"))
				return new string[] { "quit", "" };
			else if (choice.Contains("Go "))
			{
				string[] data = choice.Split(new string[] {"->"}, StringSplitOptions.RemoveEmptyEntries); // "Go east -> coridoor" -> "Go east ", " corridoor"
				return new string[] { "go", data[0].Trim().Substring(3) }; // "Go east " -> "east"
			}
			else if (choice.Contains("Examine "))
				return new string[] { "examine", choice.Substring(8) };
			else if (choice.Contains("Take "))
				return new string[] { "take", choice.Substring(5) };
			else if (choice.Contains("inventory"))
				return new string[] { "inventory", "" };

			return new string[] { "", "" };
        }
		private static void Play()
		{
			/// make choices about items in locations, inventory, move around etc ///
			string action, param;
			int row = Kboard.Clear();
			Location here = Shared.Locations[Shared.CurrentLocation];	// Location object
			List<string> exits = here.DisplayLocation(ref row); // returns available exits and current console row
			string[] data = TakeAction(here, exits, row);
			action = data[0];
			param = data[1];
			if (action == "go")
				// check if next location has item_required
				Shared.CurrentLocation = CheckExit(here, param);
			else if (action == "examine")
			{
				Console.WriteLine($"You examine the {param}".PadRight(Console.WindowWidth - 1));
				Shared.PrintLines(Shared.Items[param].Description, Console.WindowWidth, "", "left");
				if (Shared.Items[param] is Weapon)
				{
					Weapon weapon = (Weapon)Shared.Items[param];
					Console.WriteLine($"It is a Weapon with {weapon.Damage} hit points!".PadRight(Console.WindowWidth - 1));
				}
				Kboard.Sleep(2);
			}
			else if (action == "take")
			{
				Console.WriteLine($"You take the {param} and put it in your backpack".PadRight(Console.WindowWidth - 1));
				Player.AddToInventory(param);
				here.RemoveItem(param);
				Kboard.Sleep(2);
			}
			else if (action == "inventory")
				// this action will only appear if Player.Inventory is not empty
				UseInventory();
			else if (action == "fight")
			{
				Fight(here);
				Kboard.Sleep(4);
			}
			else if (action == "quit")
				Shared.Gamestate = Shared.Gamestates["quit"];
		}
		private static void UseInventory()
        {
			string choice = "";
			List<string> options = new List<string>();
			while (choice != "Exit menu")
            {
				int row = Kboard.Clear();
				string title = "Choose your option:";
				options.Clear();
				foreach(string item in Player.Inventory)
                {
					options.Add($"Examine {item}");
					options.Add($"Drop {item}");
				}
				if(Player.Inventory.Count >= 2)
					options.Add("Craft a new item");
				options.Add("Exit menu");
				choice = options[Kboard.Menu(title, options, row)];
				if(choice.Contains("Examine"))
                {
					string item = choice.Substring(8);
					Console.WriteLine($"You examine the {item}".PadRight(Console.WindowWidth - 1));
					Shared.PrintLines($"It is {Shared.Items[item].Description}", Console.WindowWidth, "", "left");
					if (Shared.Items[item] is Weapon)
					{
						Weapon weapon = (Weapon)Shared.Items[item];
						Console.WriteLine($"It is a Weapon with {weapon.Damage} hit points!".PadRight(Console.WindowWidth - 1));
					}
					Kboard.Sleep(3);
				}
				else if (choice.Contains("Drop"))
				{
					string item = choice.Substring(5);
					Console.WriteLine($"You drop the {item}".PadRight(Console.WindowWidth - 1));
					Shared.Locations[Shared.CurrentLocation].AddItem(item);
					Player.RemoveFromInventory(item);
					Kboard.Sleep(3);
				}
				else if(choice.Contains("Craft"))
                {
					// open a new menu to select 2 items
					options.Clear();
					foreach (string item in Player.Inventory)
						options.Add(item);
					Console.Clear();
					string item1 = options[Kboard.Menu("Choose your first item", options, row)];
					options.Remove(item1);
					Console.Clear();
					string item2 = options[Kboard.Menu("Choose your second item", options, row)];
					string newItem = "";
					foreach(KeyValuePair<string, Item> kvp in Shared.Items)
                    {
						if(kvp.Value.CraftItems.Contains(item1) && kvp.Value.CraftItems.Contains(item2))
							newItem = kvp.Key;
                    }
					if (newItem == "")
						Console.WriteLine("Your crafting skills are inadequate".PadRight(Console.WindowWidth - 1));
                    else
                    {
						Console.WriteLine($"You crafted a {newItem}".PadRight(Console.WindowWidth - 1));
						Player.AddToInventory(newItem);
						if (Shared.Items[item1].Uses == 1)
							Player.RemoveFromInventory(item1);
						if (Shared.Items[item2].Uses == 1)
							Player.RemoveFromInventory(item2);
					}
					Kboard.Sleep(3);
				}
				if (Player.Inventory.Count == 0)
					choice = "Exit menu";
			}
        }
		static void Main(string[] args)
        {
			/// Everything runs from here ///
			Console.SetWindowSize(80, 25);
			int row = Kboard.Clear();
			if(Shared.Debug)
            {
				Shared.Debug = !Kboard.GetBoolean(prompt:"Debug mode is ON. Do you want to disable debug mode?", row:row);
				row = Kboard.Clear();
			}
			if (Game.LoadGame())    // load from file or use hard coded game if none exist
			{
				/// game loop ///
				Shared.Gamestate = Shared.Gamestates["play"];           // start at 'play'
				while (Shared.Gamestate < Shared.Gamestates["quit"])    // continue game while in 'menu', 'play' gamestate
				{
					Play();												// play the game.Gamestate can be changed in multiple places
				}

				Console.Clear();										// row not required so use direct call
				if (Shared.Gamestate == Shared.Gamestates["dead"])
					foreach(string message in Narrator.DeathMessage)
						Console.WriteLine(message);

				foreach (string message in Narrator.EndMessage)
					Console.WriteLine(message);
			}
			else
				Console.WriteLine("Please correct errors in game locations before trying again");

			Console.Write("Enter to quit");
			Console.ReadLine();
		}
    }
}
