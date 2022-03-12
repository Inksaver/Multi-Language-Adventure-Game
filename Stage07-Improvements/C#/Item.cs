using System.Collections.Generic;
using System.Linq;

namespace Adventure_06_Improvements
{
    internal class Item
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public List<string> CraftItems { get; set; }
        public int Uses { get; set; }
        public string Container { get; set; }
        public Item(string name, string description, string[] craftitems, int uses, string container)
        {
            // note: craftitems parameter changed from List<string> to string[] array
            Name = name;
            Description = description;
            if (craftitems == null)
                CraftItems = new List<string>();
            else
                CraftItems = craftitems.ToList();
            Uses = uses;
            Container = container;
        }
        public string GetCraftItems()
        {
            string list = "";
            foreach (string item in CraftItems)
                list += $"{item}, ";
            return list;
        }
    }
}
