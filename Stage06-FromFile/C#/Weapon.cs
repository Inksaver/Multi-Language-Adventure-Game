﻿using System.Collections.Generic;

namespace Adventure_06_Improvements
{
    internal class Weapon: Item
    {
        public int Damage { get; set; }
        public Weapon(string name, string description, List<string> craftitems, int uses, string container, int damage) :base(name, description, craftitems, uses, container)
        {
            Damage = damage;
        }
    }
}
