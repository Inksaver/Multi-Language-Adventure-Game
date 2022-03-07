using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Adventure_06_Improvements
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
            Shared.Enemies.Add(name, new Enemy(name, description, strength, health, dropitem));
        }
        private static void AddToWeapons(string name, string description, List<string> craftitems, int uses, string container, int damage)
        {
            /// Adds a new Weapon object to the Shared.Items dictionary ///
            Shared.Items.Add(name, new Weapon(name, description, craftitems, uses, container, damage));
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
                }
            }

            return true;
        }
        private static void CreateDefaultEnemies()
        {
            /// Create default game enemies if not loading from file ///
            AddToEnemies("rat", "a vicious brown rat, with angry red eyes", 50, 50, "key");

            if(Shared.Debug)
            {
                Console.WriteLine("\nThe Dictionary shared.enemies contains the following data:\n");
                Console.WriteLine("key/name  description                  strength health drop item");
                Console.WriteLine(new string('═', Console.WindowWidth - 1));
                foreach(KeyValuePair<string, Enemy> kvp in Shared.Enemies)
                {
                    string description = kvp.Value.Description;
                    if (description.Length > 24)
                        description = $"{description.Substring(0, 25)}... ";
                    else
                        description = description.PadRight(28);

                    Console.Write($"{kvp.Key.PadRight(10)}{description}{kvp.Value.Strength.ToString().PadRight(9)}{kvp.Value.Health.ToString().PadRight(7)}");
                    Console.WriteLine(kvp.Value.DropItem.PadRight(13));
                }
                Console.WriteLine(new string('═', Console.WindowWidth - 1));
                Console.Write("Enter to continue");
                Console.ReadLine();
            }
        }
        private static bool CreateDefaultLocations()
        {
            /// Create default game locations if not loading from file ///
            AddToLocations("hotel room", "a damp hotel room",
                            "", "coridoor", "", "",
                            new List<string> { "torch", "book" }, "key card");
    
            AddToLocations("coridoor", "a dark coridoor with a worn carpet",
                            "reception", "lift", "", "hotel room",
                            new List<string> { "key card","sword"}, "");

            AddToLocations("lift", "a dangerous lift with doors that do not close properly",
                             "", "", "", "coridoor", new List<string>(), "", "rat");

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
            AddToWeapons("sword", "a toy plastic sword: a dog has chewed the handle..Yuk!", new List<string>() , 0, "", 25);

            if (Shared.Debug)
            {
                Console.WriteLine("The Dictionary shared.items contains the following objects:");
                Console.WriteLine("key/name  object description");
                Console.WriteLine(new string('═', Console.WindowWidth - 1));
                foreach (KeyValuePair<string, Item> item in Shared.Items)
                {
                    Console.Write(item.Key.PadRight(10));
                    if(item.Value is Weapon)
                        Console.Write("Weapon".PadRight(8));
                    else
                        Console.Write("Item".PadRight(8));
                    Console.WriteLine(item.Value.Description);
                }
                Console.WriteLine(new string('═', Console.WindowWidth - 1));
                Console.Write("Enter to continue");
                Console.ReadLine();
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
        private static int FixInt(string value, int defaultValue = 0)
        {
            if(int.TryParse(value, out int result))
            {
                return result;
            }
            return defaultValue;
        }
        private static  List<string> FixList(string value)
        {
            List<string> list = new List<string>();
            if (value != "")
            {
                string[] data = value.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);
                foreach(string s in data)
                    list.Add(s);
            }
            return list;
        }
        private static bool LoadFromFile(string loadFileName)
        {
            /// Read text file and create objects ///
			bool retValue = true;
            string[] lines = File.ReadAllLines(loadFileName);
            string name = "";
            string description = "";
            List<string> craftitems = new List<string>();
            int uses = 0;
            string container = "";
            int health = 0;
            int strength = 0;
            List<string> items = new List<string>();
            string item = "";
            string tonorth = "";
            string toeast = "";
            string tosouth = "";
            string towest = "";
            foreach (string line in lines)
            {
                string[] parts = line.Split(new string[]{"="}, StringSplitOptions.RemoveEmptyEntries);//Shared.SplitClean(line, '=');  // item.name, key card
                if (parts.Length > 0) // successful split:line contained "=" should be up to 2 items 'item.craftitems','paper;wire' or only one part
                {
                    string[] temp = parts[0].Split('.');    // item | name 
                    string obj = temp[0];                   // item
                    string prop = temp[1];                  // name
                    string value = "";
                    if (parts.Length >= 2) value = parts[1].Trim();                // key card
                    if (obj == "item") // new item object
                    {
                        if (prop == "name")             name = value;
                        else if (prop == "description") description = value.Replace("\\n", "\n");
                        else if (prop == "craftitems")  craftitems = FixList(value);
                        else if (prop == "uses")        uses = FixInt(value);
                        else if (prop == "container")   AddToItems(name, description, craftitems, uses, value);
                    }
                    else if (obj == "weapon")
                    {
                        if (prop == "name")             name = value;
                        else if (prop == "description") description = value.Replace("\\n", "\n");
                        else if (prop == "craftitems")  craftitems = FixList(value);
                        else if (prop == "uses")        uses = FixInt(value);
                        else if (prop == "container")   container = value;
                        else if (prop == "damage")      AddToWeapons(name, description, craftitems, uses, container, FixInt(value, 5));
                    }
                    else if (obj == "enemy")
                    {
                        if (prop == "name")             name = value;
                        else if (prop == "description") description = value.Replace("\\n", "\n");
                        else if (prop == "health")      health = FixInt(value, 5);
                        else if (prop == "strength")    strength = FixInt(value, 5);
                        else if (prop == "dropitem")    AddToEnemies(name, description, health, strength, value);
                    }
                    else if (obj == "location")
                    {
                        if (prop == "name")             name = value;
                        else if (prop == "description") description = value.Replace("\\n", "\n");
                        else if (prop == "tonorth")     tonorth = value;
                        else if (prop == "toeast")      toeast = value;
                        else if (prop == "tosouth")     tosouth = value;
                        else if (prop == "towest")      towest = value;
                        else if (prop == "items")       items = FixList(value);
                        else if (prop == "itemrequired") item = value;
                        else if (prop == "enemy")       AddToLocations(name, description, tonorth, toeast, tosouth, towest, items, item, value);
                    }
                    else if (obj == "player")
                    {
                        if (prop == "name")             Player.Name = value;
                        else if (prop == "characters")  Player.Characters = FixList(value);
                        else if (prop == "character")   Player.Character = value;
                        else if (prop == "health")      Player.Health = FixInt(value, 60);
                        else if (prop == "strength")    Player.Strength = FixInt(value, 60);
                        else if (prop == "inventory")   Player.Inventory = FixList(value);
                        else if (prop == "iteminhand")  Player.ItemInHand = value;
                    }
                    else if (obj == "game")
                    {
                        if (prop == "currentlocation")  Shared.CurrentLocation = value;
                    }
                    else if (obj == "narrator")
                    {
                        if (prop == "intro")            Narrator.Intro = FixList(value);
                        else if (prop == "data")        Narrator.Data = FixList(value);
                        else if (prop == "greeting")
                        {
                            Narrator.Data = FixList(value);
                            // greeting must have 2 lines
                            if(Narrator.Greeting.Count == 1)
                            {
                                Narrator.Greeting.Add("Let me know your character, so you can be awarded your skills");
                                Console.WriteLine("Narrator.Greeting must be 2 lines. Default entry added");
                                Kboard.Sleep(2);
                            }
                        }
                        else if (prop == "start")       Narrator.Start = FixList(value);
                        else if (prop == "deathmessage") Narrator.DeathMessage = FixList(value);
                        else if (prop == "endmessage")  Narrator.EndMessage = FixList(value);
                    }
                }
            }
            return CheckLocations();
        }
        public static bool LoadGame()
        {
            int row = Kboard.Clear();
            bool success = false;                               // set 'did we load or create a game?' to False 
            string cwd = Directory.GetCurrentDirectory();       // cwd = Current Working Directory
            string loadPath = Path.Combine(cwd, "games");
            string loadFileName = "";
            List<string> files = new List<string>();
            if (Directory.Exists(loadPath))
                files = Directory.GetFiles(loadPath, "*.txt", SearchOption.TopDirectoryOnly).Select(Path.GetFileName).ToList();

            if (files.Count > 0 )                               // game files exist
            {
                int choice = Kboard.Menu("Select the game you want to load", files, row );
                loadFileName = Path.Combine(cwd, "games", files[choice]);
                success = LoadFromFile(loadFileName);           // attempt to load the game  from a text file successfully?
            }
            if (!success)                                       // failed to load from file due to errors
            {
                row = Kboard.Clear();
                bool useDefault = Kboard.GetBoolean($"The file {loadFileName} had errors. Do you want to play the default game instead? (y/n)");
                if (useDefault)
                { 
                    Player.Characters = new List<string> { "Fighter", "Wizard", "Ninja", "Theif" };
                    CreateDefaultItems();                       // create game items
                    CreateDefaultEnemies();                     // create default ememy
                    if (CreateDefaultLocations())               // create game locations. false means errors found
                    {
                        Shared.CurrentLocation = "hotel room";  // Set the starting Location
                        success = true;
                    }
                }
            }
            if (success) // file loaded or player chose to use default
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
