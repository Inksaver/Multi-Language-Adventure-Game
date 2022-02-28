using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Adventure_00_Layout
{
    internal class Program
    {
        /// <summary>
        /// This episode creates a template for the development of a text-based adventure game. 
        /// Write a Shared static class for true global variables
        /// Write a Narrator class to tell the story
        /// </summary>
        static void Main(string[] args)
        {
			/// Everything runs from here ///
			Console.Clear();
			if (Game.LoadGame())    // load from file or use hard coded game if none exist
			{
				/// game loop ///
				Shared.Gamestate = Shared.Gamestates["play"];           // start at 'play'
				while (Shared.Gamestate < Shared.Gamestates["quit"])    // continue game while in 'menu', 'play' gamestate
				{
					Play();									// play the game.Gamestate can be changed in multiple places
				}

				Console.Clear();
				foreach (string message in Narrator.EndMessage)
					Console.WriteLine(message);
				
				Console.Write("Enter to quit");
				Console.Read();
			}

		}
        private static void Play()
        {
			/// make choices about items in locations, inventory, move around etc ///
			Shared.Gamestate = Shared.Gamestates["quit"];
		}
    }
}
