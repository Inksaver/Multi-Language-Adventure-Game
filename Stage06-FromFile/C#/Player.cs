using System;
using System.Collections.Generic;

namespace Adventure_06_Improvements
{
    internal static class Player
    {
        public static string Name = "";
        public static int Health = 100;
        public static int Strength = 100;
        public static string Character = "";
        public static string ItemInHand = "";
        public static List<string> Characters = new List<string>();
        public static List<string> Inventory = new List<string>();

        public static void AddToInventory(string item)
        {
            /// add an item to player inventory ///
            if (!Inventory.Contains(item))
                Inventory.Add(item);
        }
        public static string Attack(Location here)
        {
            string enemy = here.Enemy;
            string message = $"You attack the {enemy}";
            int damage = 10;
            string useItem = "fist";
            foreach(string item in Inventory)
            {
                if(Shared.Items[item] is Weapon)
                {
                    Weapon weapon = (Weapon)Shared.Items[item];
                    damage = weapon.Damage;
                    useItem = $" the {item}";
                    break;
                }
            }
            message += $" with {useItem} inflicting {damage} damage points";
            Shared.Enemies[enemy].ReceiveAttack(damage);

            return message;
        }
        public static void DisplayInventory()
        {
            /// display player's inventory ///
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.WriteLine("Player properties:");
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.Write("Characters available: ");
            foreach(string character in Characters)
                Console.Write($"{character}, ");
            Console.WriteLine($"\n{new string('═', Console.WindowWidth - 1)}");
            Console.WriteLine($"Name:                 {Name}");
            Console.WriteLine($"Health:               {Health}");
            Console.WriteLine($"Strength:             {Strength}");
            Console.WriteLine($"Character:            {Character}");
            Console.Write($"Inventory:            ");
            foreach (string item in Inventory)
                Console.Write($"{item}, ");
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
        }
        public static void DisplayPlayer()
        {
            /// main use for debug. prints all player properties ///
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.WriteLine("Player properties:");
            Console.WriteLine(new string('═', Console.WindowWidth - 1));
            Console.Write("Characters available: ");
            foreach (string character in Characters)
                Console.Write($"{character}, ");
            Console.WriteLine($"\n{new string('═', Console.WindowWidth - 1)}");
            Console.WriteLine($"Name:                 {Name}");
            Console.WriteLine($"Health:               {Health}");
            Console.WriteLine($"Strength:             {Strength}");
            Console.WriteLine($"Character:            {Character}");
            Console.Write($"Inventory:            ");
            foreach (string item in Inventory)
                Console.Write($"{item}, ");
            Console.WriteLine($"\n{new string('═', Console.WindowWidth - 1)}");
        }
        public static string GetProperty(string propertyName)
        {
            ///  used by narrator class to get a player properties ///
            if (propertyName.Contains("name"))
                return Name;
            else if (propertyName.Contains("health"))
                return Health.ToString();
            else if (propertyName.Contains("strength"))
                return Strength.ToString();
            else if (propertyName.Contains("character"))
                return Character;
            return "";
        }
        public static void ReceiveAttack(int damage)
        {
            Health -= damage;
            if(Health < 0)
                Health = 0;
        }

        public static void RemoveFromInventory(string item)
        {
            ///  remove an item from player inventory ///
            if(Player.Inventory.Contains(item))
                Player.Inventory.Remove(item);
        }
        public static void UpdateStats(int characterIndex)
        {
            ///  modify health and strength depending on character selected ///
            Health += characterIndex * 2;
            Strength += characterIndex * 2;
        }
    }
}
