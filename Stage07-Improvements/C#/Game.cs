using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Adventure_06_Improvements
{
    internal static class Game
    {
        static class Data
        {
            /// <summary>
            /// Used exclusively by LoadFromFile() when reading in data from text file
            /// </summary>
            public static string Name = "";
            public static string Description = "";
            public static int Uses = 0;
            public static string Container = "";
            public static int Damage = 0;
            public static int Health = 0;
            public static int Strength = 0;
            public static string Item = "";
            public static string Tonorth = "";
            public static string Toeast = "";
            public static string Tosouth = "";
            public static string Towest = "";
            public static string DropItem = "";
            public static string Enemy = "";
            public static string[] CraftItems = null;
            public static string[] Items = null;
            public static void Reset()
            {
                /// reset all Properties to default values
                Name = "";
                Description = "";
                Uses = 0;
                Container = "";
                Damage = 0;
                Health = 0;
                Strength = 0;
                Item = "";
                Tonorth = "";
                Toeast = "";
                Tosouth = "";
                Towest = "";
                DropItem = "";
                Enemy = "";
                CraftItems = null;
                Items = null;
            }
            public static int FixInt(string value, int defaultValue = 0)
            {
                /// If file contains string value, return integer
                if (int.TryParse(value, out int result))
                {
                    return result;
                }
                return defaultValue;
            }
            public static string[] FixList(string value)
            {
                /// return string[] array of file contents
                /// eg "pliers;key card;torch" -> ["pliers", "key card", "torch"]
                if (value == "")
                    return new string[0];
                else
                    return value.Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries);
            }
        }
        private static readonly int Delay = 2;
        private static void AddToItems(string name, string description, string[] craftitems, int uses = 0, string container = "")
        {
            /// helper function to create Item objects and store in Shared ///
            //List<string> copy = new List<string>craftitems.C
            Shared.Items.Add(name, new Item(name, description, craftitems, uses, container));
        }
        private static void AddToEnemies(string name, string description, int strength, int health, string dropitem)
        {
            /// helper function to create Enemy objects and store in Shared ///
            Shared.Enemies.Add(name, new Enemy(name, description, strength, health, dropitem));
        }
        private static void AddToWeapons(string name, string description, string[] craftitems, int uses, string container, int damage)
        {
            /// Adds a new Weapon object to the Shared.Items dictionary ///
            Shared.Items.Add(name, new Weapon(name, description, craftitems, uses, container, damage));
        }
        private static void AddToLocations(string name, string description, string tonorth, string toeast, string tosouth, string towest,
                                            string[] items = null, string itemRequired = "", string enemy = "")
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
                /// a key that does not exist in Shared.Locations has been found
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
                    Debug.DisplayLocations();
            }

            return true;
        }
        private static void CreateDefaultEnemies()
        {
            /// Create default game enemies if not loading from file ///
            AddToEnemies("rat", "a vicious brown rat, with angry red eyes", 50, 50, "key");

            if(Shared.Debug)
            {
                Debug.DisplayEnemies();
            }
        }
        private static bool CreateDefaultLocations()
        {
            /// Create default game locations if not loading from file ///
            /// If no items in the location, pass null
            AddToLocations("hotel room", "a damp hotel room",
                            "", "coridoor", "", "",
                            new string[] { "torch", "book" }, "key card");
    
            AddToLocations("coridoor", "a dark coridoor with a worn carpet",
                            "reception", "lift", "", "hotel room",
                            new string[] { "key card","sword"}, "");

            AddToLocations("lift", "a dangerous lift with doors that do not close properly",
                             "", "", "", "coridoor", null, "", "rat");

            AddToLocations("reception", "the end of the adventure. Well done",
                           "", "", "", "", null, "key"); //no exits: end game, needs key to enter

            Shared.CurrentLocation = "hotel room";
            // check if Locations are all correctly spelled and listed by the programmer:
            return CheckLocations();
        }
        private static void CreateDefaultItems()
        {
            /* Create default game items if not loading from file
             * If no text files in Games then use default hard-coded game.
            ************Hard-coded default game*************
            You can use the existing below or over-write them with your own objects and descriptions
            Make as many as you need

            */
            AddToItems(name:"key card", description:"a magnetic strip key card: Property of Premier Inns", craftitems:null);
            AddToItems("torch", "a magnificent flaming wooden torch. Maybe this is in the wrong adventure game?", null);
            AddToItems("book", "a copy of 'Python in easy steps' by Mike McGrath", null);
            AddToItems("key", "a Yale front door key: covered in rat vomit...", null);
            AddToWeapons(name:"sword", description:"a toy plastic sword: a dog has chewed the handle..Yuk!",
                        craftitems:null , uses:0, container:"", damage:25);

            if (Shared.Debug)
                Debug.DisplayItems();
        }
        private static void DisplayIntro(List<string> introText)
        {
            /// Displays an introduction to the adventure using the supplied introText list ///
            Console.Clear();
            int width = 80;
            string boxTop = $"╔{new string('═', width - 2)}╗";      // ══════ -> length of longest text +padding
            string boxBottom = $"╚{new string('═', width - 2)}╝";
            Console.WriteLine(boxTop);                              // ╔══════════════════╗
            foreach (string line in introText)                      // ║       text       ║
                Shared.PrintLines(line, width, "║", "centre");      
            Console.WriteLine(boxBottom);                           // ╚══════════════════╝
            Kboard.Sleep(3);
            Console.Clear();
        }
        private static bool LoadFromFile(string loadFileName)
        {
            /// Read text file and create objects ///
            /// using the completed counter allows properties to be read from file in any order
            /// only when all properties have been read will the object be created
            /// After that, completed = 0 and the Data properties are reset
            int completed = 0;
            string[] lines = File.ReadAllLines(loadFileName);
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
                        if (prop == "name")
                        {
                            Data.Name = value;
                            completed++;
                        }
                        else if (prop == "description")
                        {
                            Data.Description = value.Replace("\\n", "\n");
                            completed++;
                        }
                        else if (prop == "craftitems")
                        {
                            Data.CraftItems = Data.FixList(value);
                            completed++;
                        }
                        else if (prop == "uses")
                        {
                            Data.Uses = Data.FixInt(value);
                            completed++;
                        }
                        else if (prop == "container")
                        {
                            Data.Container = value;
                            completed++;
                        }
                        if (completed == 5)
                        {
                            AddToItems(Data.Name, Data.Description, Data.CraftItems, Data.Uses, Data.Container);
                            Data.Reset();
                            completed = 0;
                        }
                    }
                    else if (obj == "weapon")
                    {
                        if (prop == "name")
                        {
                            Data.Name = value;
                            completed++;
                        }
                        else if (prop == "description")
                        {
                            Data.Description = value.Replace("\\n", "\n");
                            completed++;
                        }
                        else if (prop == "craftitems")
                        {
                            Data.CraftItems = Data.FixList(value);
                            completed++;
                        }
                        else if (prop == "uses")
                        {
                            Data.Uses = Data.FixInt(value);
                            completed++;
                        }
                        else if (prop == "container")
                        {
                            Data.Container = value;
                            completed++;
                        }
                        else if (prop == "damage")
                        {
                            Data.Damage = Data.FixInt(value, 5);
                            completed++;
                        }
                        if (completed == 6)
                        {
                            AddToWeapons(Data.Name, Data.Description, Data.CraftItems, Data.Uses, Data.Container, Data.Damage);
                            Data.Reset();
                            completed = 0;
                        }
                    }
                    else if (obj == "enemy")
                    {
                        if (prop == "name")
                        {
                            Data.Name = value;
                            completed++;
                        }
                        else if (prop == "description")
                        {
                            Data.Description = value.Replace("\\n", "\n");
                            completed++;
                        }
                        else if (prop == "health")
                        {
                            Data.Health = Data.FixInt(value, 5);
                            completed++;
                        }
                        else if (prop == "strength")
                        {
                            Data.Strength = Data.FixInt(value, 5);
                            completed++;
                        }
                        else if (prop == "dropitem")
                        {
                            Data.DropItem = value;
                            completed++;
                        }
                        if (completed == 5)
                        {
                            AddToEnemies(Data.Name, Data.Description, Data.Health, Data.Strength, Data.DropItem);
                            Data.Reset();
                            completed = 0;
                        }
                    }
                    else if (obj == "location")
                    {
                        if (prop == "name")
                        {
                            Data.Name = value;
                            completed++;
                        }
                        else if (prop == "description")
                        {
                            Data.Description = value.Replace("\\n", "\n");
                            completed++;
                        }
                        else if (prop == "tonorth")
                        {
                            Data.Tonorth = value;
                            completed++;
                        }
                        else if (prop == "toeast")
                        {
                            Data.Toeast = value;
                            completed++;
                        }
                        else if (prop == "tosouth")
                        {
                            Data.Tosouth = value;
                            completed++;
                        }
                        else if (prop == "towest")
                        {
                            Data.Towest = value;
                            completed++;
                        }
                        else if (prop == "items")
                        {
                            Data.Items = Data.FixList(value);
                            completed++;
                        }
                        else if (prop == "itemrequired")
                        {
                            Data.Item = value;
                            completed++;
                        }
                        else if (prop == "enemy")
                        {
                            Data.Enemy = value;
                            completed++;
                        }
                        if (completed == 9)
                        {
                            AddToLocations(Data.Name, Data.Description, Data.Tonorth, Data.Toeast, Data.Tosouth, Data.Towest, Data.Items, Data.Item, Data.Enemy);
                            Data.Reset();
                            completed = 0;
                        }
                    }
                    else if (obj == "player")
                    {
                        if (prop == "name")             Player.Name = value;
                        else if (prop == "characters")  Player.Characters = Data.FixList(value).ToList();
                        else if (prop == "character")   Player.Character = value;
                        else if (prop == "health")      Player.Health = Data.FixInt(value, 60);
                        else if (prop == "strength")    Player.Strength = Data.FixInt(value, 60);
                        else if (prop == "inventory")   Player.Inventory = Data.FixList(value).ToList();
                        else if (prop == "iteminhand")  Player.ItemInHand = value;
                    }
                    else if (obj == "game")
                    {
                        if (prop == "currentlocation")  Shared.CurrentLocation = value;
                    }
                    else if (obj == "narrator")
                    {
                        if (prop == "intro")            Narrator.Intro = Data.FixList(value).ToList();
                        else if (prop == "data")        Narrator.Data = Data.FixList(value).ToList();
                        else if (prop == "greeting")
                        {
                            Narrator.Data = Data.FixList(value).ToList();
                            // greeting must have 2 lines
                            if(Narrator.Greeting.Count == 1)
                            {
                                Narrator.Greeting.Add("Let me know your character, so you can be awarded your skills");
                                Console.WriteLine("Narrator.Greeting must be 2 lines. Default entry added");
                                Kboard.Sleep(2);
                            }
                        }
                        else if (prop == "start")       Narrator.Start = Data.FixList(value).ToList();
                        else if (prop == "deathmessage") Narrator.DeathMessage = Data.FixList(value).ToList();
                        else if (prop == "endmessage")  Narrator.EndMessage = Data.FixList(value).ToList();
                    }
                }
            }
            if(Shared.Debug)
            {
                Debug.DisplayItems();
                Debug.DisplayEnemies();
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
                files = Directory.GetFiles(path:loadPath, searchPattern:"*.txt", SearchOption.TopDirectoryOnly).Select(Path.GetFileName).ToList();

            if (files.Count > 0 )                               // game files exist
            {
                int choice = Kboard.Menu(title:"Select the game you want to load", textLines:files, row:row, windowWidth:Console.WindowWidth);
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
            // get other Player properties from user if required at this point
            Console.WriteLine(new string('─', Console.WindowWidth - 1));
            Kboard.Print(Narrator.FormatMessage(Narrator.Greeting[0]));
            Console.WriteLine(new string('─', Console.WindowWidth - 1));
            Kboard.Sleep(Delay);
            row = Kboard.Clear();

            if (Player.Characters.Count > 0)
            {
                string title = Narrator.FormatMessage(Narrator.Greeting[1]);
                int choice = Kboard.Menu(title, Player.Characters, row, Console.WindowWidth);
                Player.Character = Player.Characters[choice];
                Player.UpdateStats(choice); // demo only: adds/removes health/strength based on choice
            }

            if (Shared.Debug)
            {
                Console.Clear();
                Debug.DisplayPlayer();
                Console.Write("Enter to continue");
                Console.ReadLine();
                row = Kboard.Clear();
            }
            Console.WriteLine(new string('─', Console.WindowWidth - 1));
            foreach (string message in Narrator.Start)
            {
                Kboard.Print(Narrator.FormatMessage(message));
                Kboard.Sleep(Delay);
            }
            Console.WriteLine(new string('─', Console.WindowWidth - 1));
            Kboard.Sleep(Delay);
            Console.Clear();
        }
    }
}
