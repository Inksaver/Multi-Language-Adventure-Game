using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Adventure_00_Layout
{
    internal static class Game
    {
        private static readonly int Delay = 2;

        private static void AddToItems(string name, string description, List<string> craftitems, int uses, string container)
        {
            /// helper function to create Item objects and store in Shared ///
        }
        private static void AddToEnemies(string name, string description, int strength, int health, string dropitem)
        {
            /// helper function to create Enemy objects and store in Shared ///
        }
        private static void AddToWeapons(string name, string description, List<string> craftitems, int uses, string container, int damage)
        {
            /// Adds a new Weapon object to the Shared.Items dictionary ///
        }
        private static void AddToLocations(string name, string description, string tonorth, string toeast, string tosouth, string towest, List<string> items, string itemRequired, string enemy)
        {
            ///helper function to create Location objects and store in Shared///
        }
        private static void CheckLocations()
        {
            /// Check keys used in locations are spelled correctly ///
        }
        private static void CreateDefaultEnemies()
        {
            /// Create default game enemies if not loading from file ///
        }
        private static void CreateDefaultLocations()
        {
            /// Create default game locations if not loading from file ///
        }
        private static void CreateDefaultItems()
        {
            /// Create default game items if not loading from file ///
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
            DisplayIntro(Narrator.Intro);
            return true;
        }
        public static void ModifyPlayer()
        {

        }
    }
}
