using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Adventure_03_World
{
    internal class Item
    {
        public string Name { get; set; } = "";
        public string Description { get; set; } = "";
        public List<string> CraftItems { get; set; } = new List<string>();
        public int Uses { get; set; } = 0;
        public string Container { get; set; } = "";
        public Item(string name, string description, List<string> craftitems, int uses, string container)
        {
            Name = name;
            Description = description; 
            CraftItems = craftitems;
            Uses = uses;
            Container = container;
        }
    }
}
