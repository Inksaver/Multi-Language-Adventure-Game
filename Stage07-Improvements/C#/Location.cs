using System;
using System.Collections.Generic;
using System.Linq;

namespace Adventure_06_Improvements
{
    internal class Location
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public string ToNorth { get; set; }
        public string ToEast { get; set; }
        public string ToSouth { get; set; }
        public string ToWest { get; set; }
        public List<string> Items { get; set; }
        public string ItemRequired { get; set; }
        public string Enemy { get; set; }
        public Location(string name, string description, string tonorth, string toeast, string tosouth, string towest,
                                            string[] items = null, string itemRequired = "", string enemy = "")
        {
            Name = name;
            Description = description;
            ToNorth = tonorth;
            ToEast = toeast;
            ToSouth = tosouth;
            ToWest = towest;
            if (items == null)
                Items = new List<string>();
            else
                Items = items.ToList();
            ItemRequired = itemRequired;
            Enemy = enemy;
        }
        public void AddItem(string item)
        {
            if(!Items.Contains(item))
                Items.Add(item);
        }
        public void RemoveItem(string item)
        {
            if(Items.Contains(item))
                Items.Remove(item);
        }
        public List<string> DisplayLocation(ref int row)
        {
            /// descrbe the current location, any items inside it, and exits ///
            List<string> exits = new List<string>();
            if(ToNorth != "")
                exits.Add($"north -> {ToNorth}");
            if(ToEast != "")
                exits.Add($"east -> {ToEast}");
            if(ToSouth != "")
                exits.Add($"south -> {ToSouth}");
            if(ToWest != "")
                exits.Add($"west -> {ToWest}");
            Console.WriteLine(new string('─', Console.WindowWidth - 1));
            Console.WriteLine($"You are in a {Name}");
            row = 2;
            row += Shared.PrintLines(Description, Console.WindowWidth, "", "left");
            if(exits.Count == 0)
            {
                Console.WriteLine("There are no exits");
                row += 1;
            }
            if(Items.Count > 0)
            {
                string output = "In this location there is: ";
                foreach(string item in Items)
                    output += item + ", ";
                output = output.Remove(output.Length - 2); // remove ', '
                row += Shared.PrintLines(output, Console.WindowWidth, "", "left");
            }
            if (Enemy != "")
            {
                Console.WriteLine($"ENEMY: {Enemy}!");
                row++;
            }
            return exits; // row is by reference so does not need to be returned
        }
    }
}
