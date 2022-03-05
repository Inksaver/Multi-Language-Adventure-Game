using System;
using System.Collections.Generic;

namespace Adventure_04_Gameloop
{
    internal static class Game
    {
        private static readonly int Delay = 2;

        private static void AddToItems(string name, string description, List<string> craftitems = null, int uses = 0, string container = "")
        {
            /// helper function to create Item objects and store in Shared ///
            Shared.Items.Add(name, new Item(name, description,craftitems, uses, container));
        }
        private static void AddToEnemies(string name, string description, int strength, int health, string dropitem)
        {
            /// helper function to create Enemy objects and store in Shared ///
        }
        private static void AddToWeapons(string name, string description, List<string> craftitems, int uses, string container, int damage)
        {
            /// Adds a new Weapon object to the Shared.Items dictionary ///
        }
        private static void AddToLocations(string name, string description, string tonorth, string toeast, string tosouth, string towest,
                                            List<string> items = null, string itemRequired = "", string enemy = "")
        {
            ///helper function to create Location objects and store in Shared///
            Shared.Locations.Add(name, new Location(name, description, tonorth, toeast, tosouth, towest, items, itemRequired, enemy));
        }
        private static bool CheckLocations()
        {
            /// Check keys used in locations are spelled correctly ///
            List<string> keys = new List<string>(Shared.Locations.Keys);
            List<string> wrongKeys = new List<string>();
            string availableKeys = "";
            foreach (string key in keys)
                availableKeys += $"{key}, ";
            availableKeys = availableKeys.Remove(availableKeys.Length - 2); // remove ', '

            if (Shared.CurrentLocation == "")
            {
                Console.WriteLine("Current location has not been set");
                return false;
            }
            else if (!keys.Contains(Shared.CurrentLocation))
            {
                Console.WriteLine($"Current location key has been set to '{Shared.CurrentLocation}'");
                Console.WriteLine($"Available keys: {availableKeys}");
                return false;
            }

            // check if each LocationToXXX corresponds with a key
            foreach(KeyValuePair<string, Location> kvp in Shared.Locations)
            {
                if(kvp.Value.ToNorth != "")
                    if(!keys.Contains(kvp.Value.ToNorth))
                        wrongKeys.Add(kvp.Value.ToNorth);
                if (kvp.Value.ToEast != "")
                    if (!keys.Contains(kvp.Value.ToEast))
                        wrongKeys.Add(kvp.Value.ToEast);
                if (kvp.Value.ToSouth != "")
                    if (!keys.Contains(kvp.Value.ToSouth))
                        wrongKeys.Add(kvp.Value.ToSouth);
                if (kvp.Value.ToWest != "")
                    if (!keys.Contains(kvp.Value.ToWest))
                        wrongKeys.Add(kvp.Value.ToWest);
            }
            if (wrongKeys.Count > 0)
            {
                Console.Clear();
                Console.WriteLine("Errors found when creating default game: ");
                Console.WriteLine($"Available keys: {availableKeys}");
                Console.Write("\nErroneous key names:\n");
                foreach(string key in wrongKeys)
                    Console.Write($"{key}, ");

                Console.WriteLine("\nEnter to continue");
                Console.ReadLine();
                return false;
            }
            else
            {
                if (Shared.Debug)
                {
                    int width = 112;
                    Console.SetWindowSize(width, 25);
                    Console.Clear();
                    Console.WriteLine("\nThe Dictionary Shared.Locations contains the following data:\n");
                    Console.WriteLine(new string('─', Console.WindowWidth - 1));
                    foreach (KeyValuePair<string, Location> kvp in Shared.Locations)
                    {
                        Console.WriteLine($"key: {kvp.Key.PadRight(22)}│ Description: {kvp.Value.Description}");
                        Console.Write($"North: {kvp.Value.ToNorth.PadRight(20)}");
                        Console.Write($"│ East: {kvp.Value.ToEast.PadRight(17)}");
                        Console.Write($"South: {kvp.Value.ToSouth.PadRight(17)}");
                        Console.WriteLine($"West: {kvp.Value.ToWest}");
                        Console.Write($"Item required: {kvp.Value.ItemRequired.PadRight(12)}│ Items ");
                        foreach (string item in kvp.Value.Items) // empty list or list of string key values
                            Console.Write($"{item}, ");
                        Console.Write("\n");
                        Console.WriteLine(new string('─', Console.WindowWidth - 1));
                    }
                    Console.Write("Enter to continue");
                    Console.ReadLine();
                    Console.SetWindowSize(80, 25);
                }
            }

            return true;
        }
        private static void CreateDefaultEnemies()
        {
            /// Create default game enemies if not loading from file ///
        }
        private static bool CreateDefaultLocations()
        {
            /// Create default game locations if not loading from file ///
            AddToLocations("hotel room", "a damp hotel room",
                            "", "coridoor", "", "",
                            new List<string> { "torch", "book" }, "key card");
    
            AddToLocations("coridoor", "a dark coridoor with a worn carpet",
                            "reception", "lift", "", "hotel room",
                            new List<string> { "key card","key"}, "");

            AddToLocations("lift", "a dangerous lift with doors that do not close properly",
                             "", "", "", "coridoor", new List<string>(), "");

            AddToLocations("reception", "the end of the adventure. Well done",
                           "", "", "", "", new List<string>(), "key"); //no exits: end game, needs key to enter

            Shared.CurrentLocation = "hotel room";
            // check if Locations are all correctly spelled and listed by the programmer:
            return CheckLocations();
        }
        private static void CreateDefaultItems()
        {
            /* Create default game items if not loading from file
             * If no text files in Games then use default hard-coded game.
            ************Hard-coded default game*************
            add_to_items("item identifier", "description of item", Damage it can inflict on enemies)
            DO NOT USE \n (newline) characters as game saves will corrupt
            You can use the existing below or over-write them with your own objects and descriptions
            Make as many as you need
            */
            AddToItems("key card", "a magnetic strip key card: Property of Premier Inns");
            AddToItems("torch", "a magnificent flaming wooden torch. Maybe this is in the wrong adventure game?");
            AddToItems("book", "a copy of 'Python in easy steps' by Mike McGrath");
            AddToItems("key", "a Yale front door key: covered in rat vomit...");

            if (Shared.Debug)
            {
                Console.SetWindowSize(112, 25);
                Console.WriteLine("The Dictionary shared.items contains the following objects:");
                Console.WriteLine("key/name  object description");
                Console.WriteLine(new string('═', Console.WindowWidth - 1));
                foreach (KeyValuePair<string, Item> item in Shared.Items)
                {
                    Console.Write(item.Key.PadRight(10));
                    if(item.Value is Item)
                        Console.Write("Item".PadRight(8));
                    Console.WriteLine(item.Value.Description);
                }
                Console.WriteLine(new string('═', Console.WindowWidth - 1));
                Console.Write("Enter to continue");
                Console.ReadLine();
                Console.SetWindowSize(80, 25);
            }

        }
        private static void DisplayIntro(List<string> introText)
        {
            /// Displays an introduction to the adventure using the supplied introText list ///
            Console.Clear();
            int size = 0; // set size of the text
            foreach (string line in introText)  //get longest text in supplied list
            {
                if (line.Length > size)
                    size = line.Length;
            }
            if (size % 2 == 1)
                size += 1;
            size += 12;
            string boxTop = $"╔{new string('═', size)}╗";       // ══════ -> length of longest text +padding
            string boxBottom = $"╚{new string('═', size)}╝";
            Console.WriteLine(boxTop);                          // ╔══════════════════╗
            foreach (string line in introText)
                Console.WriteLine(FormatLine(line, size));      // ║       text       ║
            Console.WriteLine(boxBottom);                       // ╚══════════════════╝
            Kboard.Sleep(3);
            Console.Clear();
        }
        private static string FormatLine(string text, int length)
        {
            /// private sub-function for use in displayIntro ///
            if (text.Length % 2 == 1)
                text += " ";

            string filler = new string(' ', (length - text.Length) / 2);
		    return $"║{filler}{text}{filler}║";
        }
        private static void GetFiles()
        {
            /// Read directory of available files ///
        }
        private static void LoadFromFile()
        {
            /// Read text file and create objects ///
        }
        public static bool LoadGame()
        {
            bool success = false;
            Console.Clear();
            Player.Characters = new List<string> { "Fighter", "Wizard", "Ninja", "Theif" };
            CreateDefaultItems();                       // create game items
            if (CreateDefaultLocations())               // create game locations. false means errors found
            {
                Shared.CurrentLocation = "hotel room";  // Set the starting Location
                success = true;
            }
            if (success)
            {
                DisplayIntro(Narrator.Intro);
                ModifyPlayer();
            }
            return success;
        }
        public static void ModifyPlayer()
        {
            /// gets player details. Change the text to suit your adventure theme ///
            int row = Kboard.Clear();
            foreach (string message in Narrator.Data)
            {
                Console.WriteLine(Narrator.FormatMessage(message));
                Kboard.Sleep(Delay);
                if (row >= 0)
                    row += 1;
            }
            Player.Name = Kboard.GetString("What is your name?", true, 2, 20, row);
            Kboard.Print(Narrator.FormatMessage(Narrator.Greeting[0]));
            Kboard.Sleep(Delay);
            row = Kboard.Clear();

            if (Player.Characters.Count > 0)
            {
                string title = Narrator.FormatMessage(Narrator.Greeting[1]);
                int choice = Kboard.Menu(title, Player.Characters, row);
                Player.Character = Player.Characters[choice];
                Player.UpdateStats(choice);
            }

            if (Shared.Debug)
            {
                Console.Clear();
                Player.DisplayPlayer();
                Console.Write("Enter to continue");
                Console.ReadLine();
                row = Kboard.Clear();
            }

            foreach(string message in Narrator.Start)
            {
                Kboard.Print(Narrator.FormatMessage(message));
                Kboard.Sleep(Delay);
            }
            Kboard.Sleep(Delay);
            Console.Clear();
        }
    }
}
