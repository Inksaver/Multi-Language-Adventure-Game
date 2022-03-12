using System;
using System.Collections.Generic;

namespace Adventure_06_Improvements
{
    internal static class Debug
    {
        public static void DisplayEnemies()
        {
            Console.SetWindowSize(100, 25);
            Console.Clear();
            Console.WriteLine("The Dictionary Shared.Enemies contains the following data:");
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            foreach (KeyValuePair<string, Enemy> kvp in Shared.Enemies)
            {
                Shared.PrintLines($"Name: {kvp.Key.PadRight(20)}" +
                                  $"Strength: {kvp.Value.Strength.ToString().PadRight(10)}" +
                                  $"Health: {kvp.Value.Health.ToString().PadRight(10)}" +
                                  $"DropItem: {kvp.Value.DropItem}",
                                  Console.WindowWidth, "", "left");

                Shared.PrintLines($"{kvp.Value.Description}", Console.WindowWidth, "", "left");
            }
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.Write("Enter to continue");
            Console.ReadLine();
            Console.SetWindowSize(80, 25);
        }
        public static void DisplayItems()
        {
            int width = 100;
            int height = 25;
            Console.SetWindowSize(width, height);
            Console.Clear();
            Console.WriteLine("The Dictionary Shared.Items contains the following objects:");
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            int row = 2;
            foreach (KeyValuePair<string, Item> kvp in Shared.Items)
            {
                if(row > height - 4)
                {
                    Console.Write("Enter for next screen");
                    Console.ReadLine();
                    row = 0;
                    Console.Clear();
                }
                string itemType = "Item";
                if (kvp.Value is Weapon) itemType = "Weapon";
                row += Shared.PrintLines($"Name: {kvp.Key.PadRight(25)}" +
                                         $"Object: {itemType}", Console.WindowWidth, "", "left");
                row += Shared.PrintLines($"Uses: {(kvp.Value.Uses).ToString().PadRight(25)}" +
                                         $"CraftFrom: {kvp.Value.GetCraftItems()}", Console.WindowWidth, "", "left");
                row += Shared.PrintLines($"Description: {kvp.Value.Description}", Console.WindowWidth, "", "left");
                Console.WriteLine(new string('─', Console.WindowWidth -1));
                row++;
            }
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.Write("Enter to continue");
            Console.ReadLine();
            Console.SetWindowSize(80, 25);
        }
        public static void DisplayLocations()
        {
            int width = 100;
            int height = 25;
            Console.SetWindowSize(width, height);
            Console.Clear();
            Console.WriteLine("The Dictionary Shared.Locations contains the following data:");
            Console.WriteLine(new string('─', Console.WindowWidth - 1));
            int row = 2;
            foreach (KeyValuePair<string, Location> kvp in Shared.Locations)
            {
                if (row > height - 7)
                {
                    Console.Write("Enter for next screen");
                    Console.ReadLine();
                    row = 0;
                    Console.Clear();
                }

                Console.WriteLine($"Name: {kvp.Key.PadRight(22)}" +
                                  $"Item required: {kvp.Value.ItemRequired.PadRight(32)}" +
                                  $"Enemy: {kvp.Value.Enemy}");
                Console.Write($"North: {kvp.Value.ToNorth.PadRight(21)}");
                Console.Write($"East: {kvp.Value.ToEast.PadRight(17)}");
                Console.Write($"South: {kvp.Value.ToSouth.PadRight(17)}");
                Console.WriteLine($"West: {kvp.Value.ToWest}");
                row += 2;
                row += Shared.PrintLines($"Description: {kvp.Value.Description}", Console.WindowWidth, "", "left");
                Console.Write($"Items: ");
                foreach (string item in kvp.Value.Items) // empty list or list of string key values
                    Console.Write($"{item}, ");
                Console.Write("\n");
                Console.WriteLine(new string('─', Console.WindowWidth- 1));
                row += 2;
            }
            Console.Write("Enter to continue");
            Console.ReadLine();
            Console.SetWindowSize(80, 25);
        }
        public static void DisplayPlayer()
        {
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.WriteLine("Player properties:");
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.Write("Characters available: ");
            foreach (string character in Player.Characters)
                Console.Write($"{character}, ");
            Console.WriteLine($"\n{new string('═', Console.WindowWidth - 1)}");
            Console.WriteLine($"Name:                 {Player.Name}");
            Console.WriteLine($"Health:               {Player.Health}");
            Console.WriteLine($"Strength:             {Player.Strength}");
            Console.WriteLine($"Character:            {Player.Character}");
            Console.Write($"Inventory:            ");
            foreach (string item in Player.Inventory)
                Console.Write($"{item}, ");
            Console.WriteLine($"\n{new string('═', Console.WindowWidth - 1)}");
        }
    }
}
