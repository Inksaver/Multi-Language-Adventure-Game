using System;
using System.Collections.Generic;

namespace Adventure_06_Improvements
{
    internal static class Player
    {
        #region Static Properties
        public static string Name = "";
        public static int Health = 100;
        public static int Strength = 100;
        public static string Character = "";
        public static string ItemInHand = "";
        public static List<string> Characters = new List<string>();
        public static List<string> Inventory = new List<string>();
        #endregion
        #region Methods
        public static void AddToInventory(string item)
        {
            /// add an item to player inventory ///
            if (!Inventory.Contains(item))
                Inventory.Add(item);
        }
        public static string Attack(Location here, string item)
        {
            /// Item already chosen, use here to attack enemy ///
            string enemy = here.Enemy;
            string message = $"You attack the {enemy}";
            int damage = 5;

            if(Shared.Items[item] is Weapon)                // Is the item a weapon?
            {
                Weapon weapon = (Weapon)Shared.Items[item]; // cast Item to Weapon to obtain Damage
                damage = weapon.Damage;
                item = $" the {item}";
            }
            message += $" with {item} inflicting {damage} damage points";
            Shared.Enemies[enemy].ReceiveAttack(damage);

            return message;
        }
        public static string GetProperty(string propertyName)
        {
            ///  used by narrator class to get player properties ///
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
            /// reduce health to min of 0 ///
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
        #endregion
    }
}
