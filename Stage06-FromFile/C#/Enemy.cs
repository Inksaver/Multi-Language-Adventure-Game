namespace Adventure_06_Improvements
{
    internal class Enemy
    {
        
        public string Name { get; set; }
        public string Description { get; set; }
        public int Health { get; set; }
        public int Strength { get; set; }
        public int MaxHealth { get; set; }
        public string DropItem { get; set; }
        public Enemy(string name, string description , int strength, int health, string dropItem)
        {
            Name = name;
            Description = description;
            Health = health;
            Strength = strength;
            MaxHealth = health;
            DropItem = dropItem;
        }
        public string Attack()
        {
            string message = $"{Name} attacks you, inflicting {Strength} damage";
            Player.ReceiveAttack(Strength);

            return message;
        }
        public void ReceiveAttack(int damage)
        {
            Health -= damage;
            if (Health < 0)
                Health = 0;
        }
    }
}
