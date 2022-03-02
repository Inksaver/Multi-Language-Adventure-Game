using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;

/// <summary> 
/*
int row = Kboard.Clear();
string name = Kboard.GetString(prompt: "What is your name?", withTitle: true, min: 1, max: 10, row: row);
row += 2; // keep track of current line. User pressing Enter on Input increases line count
Kboard.Print($"Hello {name}");
int age = Kboard.GetInteger("How old are you", 5, 110, row);
row += 2;
Kboard.Print($"You are {age} years old");
double height = Kboard.GetRealNumber("How tall are you?", 0.5, 2.0, row);
Kboard.Print($"You are {height} metres tall");
row += 2;
bool likesPython = Kboard.GetBoolean("Do you like Python? (y/n)", row);
if (likesPython)
    Kboard.Print($"You DO like Python");
else
    Kboard.Print($"You DO NOT like Python");
string title = "Choose your favourite language";
row += 2;
List<string> options = new List<string> { "C#", "Python", "Lua", "Java" };
int choice = Kboard.Menu(title, options, row);
Kboard.Print($"Your favourite language is {options[choice]}");
*/
/// </summary>

namespace Adventure_02_Items
{
    internal class Kboard
    {
        public static int Delay = 2000;
        public static int Clear()
        {
            /// Clears the Console (Allows calls from other classes not involved with UI) ///
            Console.Clear();
            return 0;
        }
        private static void ClearInputField(int row)
        {
            if (row >= 0)
            {
                Console.SetCursorPosition(0, row); // left, top 0 based
                Console.Write("".PadRight(Console.WindowWidth - 1));
                Console.SetCursorPosition(0, row);
            }
        }
        private static void ErrorMessage(int row, string errorType, string userInput,  double minValue = 0, double maxValue = 0)
        {
            //row--;
            if (row < 0) row = 0;
            string message = "Just pressing the Enter key or spacebar doesn't work"; // default for "noinput"
            if (errorType == "string")
                message = $"Try entering text between {minValue} and {maxValue} characters";
            else if (errorType == "bool")
                message = "Only anything starting with y or n is accepted";
            else if (errorType == "nan")
                message = $"Try entering a number - {userInput} does not cut it";
            else if (errorType == "notint")
                message = $"Try entering a whole number - {userInput} does not cut it";
            else if (errorType == "range")
                message = $"Try a number from {minValue} to {maxValue}";
            else if (errorType == "intconversion")
                message = $"Try entering a whole number: {userInput} cannot be converted...";
            else if (errorType == "realconversion")
                message = $"Try entering a decimal number: {userInput} cannot be converted...";

            message = $">>> {message} <<<";
            ClearInputField(row);           // clear current line
            Console.Write(message);         // write message
            Thread.Sleep(Delay);            // pause 2 seconds
            ClearInputField(row);           // clear current line
        }
        public static bool GetBoolean(string prompt, int row = -1)
        {
            /// gets a boolean (yes/no) type entry from the user
            string userInput = ProcessInput(prompt, 1, 3, "bool", row);
            return Convert.ToBoolean(userInput);
        }
        public static double GetRealNumber(string prompt, double min, double max, int row = -1)
        {
            /// gets a float / double from the user
            string userInput = ProcessInput(prompt, min, max, "real", row);
            return Convert.ToDouble(userInput);
        }
        public static int GetInteger(string prompt, double min, double max, int row = -1)
        {
            /// Public Method: gets an integer from the user ///
            string userInput = ProcessInput(prompt, min, max, "int", row);
            return Convert.ToInt32(userInput);
        }
        public static string GetString(string prompt, bool withTitle, int min, int max, int row = -1)
        {
            /// Public Method: gets a string from the user ///
            string userInput = ProcessInput(prompt, min, max, dataType:"string", row);
            if (withTitle)
            {
                TextInfo textInfo = new CultureInfo("en-UK", false).TextInfo;
                userInput = textInfo.ToTitleCase(userInput);
            }
            return userInput;
        }
        public static string Input(string prompt, string ending = "_")
        {
            /// Get keyboard input from user (requires Enter )
            Console.Write($"{prompt}{ending}");
            return Console.ReadLine();
        }
        public static int Menu(string title, List<string> textLines, int row = -1)
        {
            /// displays a menu using the text in 'title', and a list of menu items (string)
            /// This menu will re-draw until user enters correct data
            int rows = -1;
            if (row >= 0) rows = row + textLines.Count + 2;

            Print($"{title}");                                      // print title
            for (int i = 0; i < textLines.Count; i++)
            {
                if (i < 9)  Print($"     {i + 1}) {textLines[i]}");  // print menu options 5 spaces
                else        Print($"    {i + 1}) {textLines[i]}");   // print menu options 4 spaces
            }
            Print(new string('═', Console.WindowWidth - 1));
            int userInput = GetInteger($"Type the number of your choice (1 to {textLines.Count})",  1, textLines.Count, rows);
            return userInput - 1;
        }
        public static int Print(string text = "")
        {
            Console.WriteLine(text);
            return 1;
        }
        public static void Sleep(int delay)
        {
            if (delay < 100) delay *= 1000;
            Thread.Sleep(delay);
        }
        private static string ProcessInput(string prompt, double min, double max, string dataType, int row)
        {
            bool valid = false;
            string userInput = "";
            while (!valid)
            {
                ClearInputField(row);
                userInput = Input(prompt);
                if (dataType == "string")
                {
                    if (userInput.Length == 0 && min > 0) ErrorMessage(row, "noinput", userInput);
                    else if (userInput.Length > max) ErrorMessage(row, "string", userInput, min, max);
                    else valid = true;
                }
                else //integer, float, bool
                {
                    if (userInput.Length == 0)                                      // just Enter pressed
                        ErrorMessage(row, "noinput", userInput);
                    else
                    {
                        if (dataType == "bool")
                        {
                            if (userInput.Substring(0, 1).ToLower() == "y")
                            {
                                userInput = "true";
                                valid = true;
                            }
                            else if (userInput.Substring(0, 1).ToLower() == "n")
                            {
                                userInput = "false";
                                valid = true;
                            }
                            else  ErrorMessage(row, "bool", userInput);
                        }
                        if (dataType == "int" || dataType == "real")                // integer / float / double
                        {
                            if (double.TryParse(userInput, out double conversion))  // is a number!
                            {
                                if (conversion >= min && conversion <= max)         // within range!
                                {
                                    if (dataType == "int")                          // check if int
                                    {
                                        if (int.TryParse(userInput, out int intconversion))
                                        {
                                            valid = true;                           // userInput can be converted to int
                                        }
                                        else ErrorMessage(row, "notint", userInput);// real number supplied
                                    }
                                    else valid = true;                              // userInput can be converted to float/double/decimal
                                }
                                else ErrorMessage(row, "range", userInput, min, max);// out of range
                            }
                            else ErrorMessage(row, "nan", userInput);               // not a number
                        }
                    }
                }
            }
            return userInput; //string can be converted to bool, int or float
        }
    }
}
