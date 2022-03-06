using System.Collections.Generic;

namespace Adventure_05_Weapon
{
    internal static class Narrator
    {
        public static List<string> Intro = new List<string>
        {
            "The most Epic Adventure game EVER!",
            "Coded by Inksaver",
            "Can you escape the dungeon?..."
        };
        public static List<string> Data = new List<string>
        {
            "I am the overlord, and I will help you to find my lost treasure",
            "I just need to get to know you before I let you in..."
        };
        public static List<string> Greeting = new List<string>
        {
            "Hello {player.name}. You are the adventurer destined to find my lost treasure",
            "Let me know your character, so you can be awarded your skills"
        };
        public static List<string> Start = new List<string>
        {
            "I see you are a {player.character} with {player.health} health and {player.strength} strength",
            "Welcome. Serve me well and you will be rewarded"
        };
        public static List<string> DeathMessage = new List<string>
        {
            "Sorry you did not make it this time!",
            "Please try again!"
        };
        public static List<string> EndMessage = new List<string>
        {
            "Thank you for playing! Remember to smash that 'Like' button and subscribe!"
        };
        public static string FormatMessage(string message)
        {
            /// example message "Hello {player.name}. You"
            /// extract player.name from {}
            /// get Player.Name from Player class
            /// message now is: "Hello Fred. You
            int start = message.IndexOf('{');
            int ending = 0;
            while (start > -1)
            {
                string begin = message.Substring(0, start);
                ending = message.IndexOf('}');
                string property = message.Substring(start + 1, ending - start - 1);
                string data = Player.GetProperty(property);
                message = $"{begin}{data}{message.Substring(ending + 1)}";
                start = message.IndexOf('{');
            }
            return message;
        }
    }
}
