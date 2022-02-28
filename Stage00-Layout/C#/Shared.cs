using System.Collections.Generic;

namespace Adventure_00_Layout
{
    internal static class Shared
    {
        public static bool Debug = true;
        public static Dictionary<string, int> Gamestates = new Dictionary<string, int> 
        {
            { "menu",       0},
            { "play",       1},
            { "leaderboard",2},
            { "quit",       3},
            { "dead",       4}
        };
        public static int Gamestate = 1;
    }
}
