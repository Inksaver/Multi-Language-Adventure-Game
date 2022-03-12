namespace Adventure_06_Improvements
{
    internal class Weapon: Item
    {
        public int Damage { get; set; }
        public Weapon(string name, string description, string[] craftitems, int uses, string container, int damage) :base(name, description, craftitems, uses, container)
        {
            // note: craftitems parameter changed from List<string> to string[] array
            Damage = damage;
        }
    }
}
