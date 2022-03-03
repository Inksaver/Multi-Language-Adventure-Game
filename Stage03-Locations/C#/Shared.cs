using System.Collections.Generic;

namespace Adventure_03_World
{
    /*
    The Items, Enemies and Locations are shared by multiple files, so are best kept in a code module.
    dictionaries of all these objects offer the greatest flexibility.

    Example of Items dictionary, which is a dictionary of item objects
    Items["torch"] = <Item object>
    Items["torch"].Name = "torch"
    Items["torch"].Description = "a flaming wooden torch"
    Items["key card"].Name = "key card",
    Items["key card"].Description = "Property of Holiday Inn"

    Example of Locations dictionary which is a dictionary of location objects
    Locations["hotel room"].Name = "hotel room"
    Locations["hotel room"].Description = "a damp hotel room"
    Locations["hotel room"].ToNorth = ""
    Locations["hotel room"].ToEast = "coridoor"
    Locations["hotel room"].ToSouth = ""
    Locations["hotel room"].ToWest = ""
    Locations["hotel room"].ItemRequired = "key card"              // key of an item from the items dictionary
    Locations["hotel room"].Items = {"torch","plastic sword"}      // a List of the dictionary keys of items in the location
    */

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
        public static  Dictionary<string, Item> Items = new Dictionary<string, Item>();
        public static Dictionary<string, Location> Locations = new Dictionary<string, Location>();
        public static string CurrentLocation = "";
    }
}
