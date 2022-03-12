using System;
using System.Collections.Generic;

namespace Adventure_06_Improvements
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
        public static bool Debug = true;                            // When game completed, set this to false
        public static Dictionary<string, int> Gamestates = new Dictionary<string, int> 
        {
            { "menu",       0},
            { "play",       1},
            { "quit",       2},
            { "dead",       3}
        };
        public static int Gamestate = 1;                        // set to "play" by default
        public static Dictionary<string, Item> Items            = new Dictionary<string, Item>();
        public static Dictionary<string, Location> Locations    = new Dictionary<string, Location>();
        public static Dictionary<string, Enemy> Enemies         = new Dictionary<string, Enemy>();
        public static string CurrentLocation = "";

        private static string PadLine(string text, int length, string align, string border)
        {
            /// Pads a line of text with spaces to a specific length                    ///
            /// If a character used for the border eg "|", they are placed at both ends ///
            if (text.Length % 2 == 1)                                   // ? even number of chars
                text += " ";                                            // it is now!
            string filler = "";
            if(align == "centre")
                filler = new string(' ', (length - text.Length) / 2);   // enough spaces to pad both sides
            else if (align == "left")
                text = text.PadRight(length - text.Length, ' ');        // pad right side
            else if (align == "right")
                text = text.PadLeft(length - text.Length, ' ');         // pad left side
            return $"{border}{filler}{text}{filler}{border}";           // '|   text   |'
        }
        public static List<string> FormatLine(string text, int length, string border, string align)
        {
            /// break a line of text to fit in multiple lines of specified length ///
            
            List<string> returnList = new List<string>();               // empty list
            if (border != "")                                           // reduce length to compensate border chars
                length -= 2;
            if (text.Length < length)                                   // no need to break the line so format and add to list
                returnList.Add(PadLine(text, length, align, border));
            else                                                        // separate text into array of words and re-assemble
            {
                string[] words = text.Split(' ');
                text = "";
                for (int i = 0; i < words.Length; i++)                  // iterate array of words
                {
                    if(text.Length + words[i].Length < length)          // add next word unless line length > max
                        text += $"{words[i]} ";
                    else                                                // line at max length
                    {
                        text = text.Trim();                             // remove trailing space and add to list
                        returnList.Add(PadLine(text, length, align, border));
                        text = $"{words[i]} ";                          // clear text and add current word + space
                    }
                }
                text = text.Trim();                                     // any words not already in list are trimmmed
                if(text.Length > 0)
                    returnList.Add(PadLine(text, length, align, border));   // add final part of original text
            }
            return returnList;
        }
        public static int PrintLines(string text, int length, string border = "", string align = "centre")
        {
            /// uses the FormatLine to produce a list of lines and prints them out ///
            int row = 0;
            List<string> Lines = FormatLine(text, length, border, align);
            foreach(string line in Lines)
            {
                Console.WriteLine(line);
                row++;
            }

            return row; // number of rows used to print lines
        }
    }
}
