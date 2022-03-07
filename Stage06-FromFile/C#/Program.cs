using System;
using System.Collections.Generic;

namespace Adventure_06_Improvements
{
    internal class Program
	{
		/// <summary>
		/// play() loop
		/// 1. exits = here.DisplayLocation() # gets exits list, so include exit name
		/// 2. exits is passed to TakeAction()
		/// 3. TakeAction() displays exits as part of the menu
		/// 4. menu returns "Go "* if an exit is chosen
		/// 5. direction currently gets exit from string splicing "Go direction" to "direction" (north, east, south, west)
		/// 6. if exit contained "Go east -> coridoor" improve string splicing to separate "east" and "coridoor"
		/// 
		/// Location.DisplayLocation()
		/// 1. return exit name for each exit: "east -> coridoor","north -> magic portal"
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
					Console.WriteLine($"You use the {itemRequired} in your inventory to enter...");
				else
				{
					Console.WriteLine($"You need {itemRequired} in your inventory to go that way.");
					nextLocation = here;
				}
				Kboard.Sleep(2);
			}

			return nextLocation.Name;
        }
		private static void Fight(Location here)
        {
			/// pick a fight with an enemy ///
			Enemy enemy = Shared.Enemies[here.Enemy];   // use variable for convenience
			Console.WriteLine(Player.Attack(here));     // player.attack() returns a string message
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

			Console.WriteLine(message);  // print attack details
			if (Player.Health == 0)
			{
				Console.WriteLine($"You died at the hands of the {enemy.Name}");
				Kboard.Sleep(2);
				Console.WriteLine("The game is over!");
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
				Console.WriteLine($"You examine the {param}");
				Console.WriteLine($"{Shared.Items[param].Description}");
				if (Shared.Items[param] is Weapon)
				{
					Weapon weapon = (Weapon)Shared.Items[param];
					Console.WriteLine($"It is a Weapon with {weapon.Damage} hit points!");
				}
				Kboard.Sleep(2);
			}
			else if (action == "take")
			{
				Console.WriteLine($"You take the {param} and put it in your backpack");
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
			while (choice != "Exit menu")
            {
				int row = Kboard.Clear();
				string title = "Choose your option:";
				List<string> options = new List<string>();
				foreach(string item in Player.Inventory)
                {
					options.Add($"Examine {item}");
					options.Add($"Drop {item}");
				}
				options.Add("Exit menu");
				choice = options[Kboard.Menu(title, options, row)];
				if(choice.Contains("Examine"))
                {
					string item = choice.Substring(8);
					Console.WriteLine($"You examine the {item}");
					Console.WriteLine($"It is {Shared.Items[item].Description}");
					if (Shared.Items[item] is Weapon)
					{
						Weapon weapon = (Weapon)Shared.Items[item];
						Console.WriteLine($"It is a Weapon with {weapon.Damage} hit points!");
					}
					Kboard.Sleep(3);
				}
				else if (choice.Contains("Drop"))
				{
					string item = choice.Substring(5);
					Console.WriteLine($"You drop the {item}");
					Shared.Locations[Shared.CurrentLocation].AddItem(item);
					Player.RemoveFromInventory(item);
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
				Shared.Debug = !Kboard.GetBoolean("Debug mode is ON. Do you want to disable debug mode?", row);
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

				Console.Clear();
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
