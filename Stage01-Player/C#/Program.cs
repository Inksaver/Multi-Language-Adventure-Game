using System;

namespace Adventure_01_Player
{
    internal class Program
    {
		/// <summary>
		/// Introduce a Shared.Debug flag, allowing debug data to be displayed 
		/// Write a player static class
		/// Setup the Player by getting input from the user
		/// </summary>
		private static void Play()
		{
			/// make choices about items in locations, inventory, move around etc ///
			Shared.Gamestate = Shared.Gamestates["quit"];
		}
		static void Main(string[] args)
        {
			/// Everything runs from here ///
			int row = Kboard.Clear();
			if(Shared.Debug)
            {
				Shared.Debug = !Kboard.GetBoolean("Debug mode is ON. Do you want to disable debug mode?", row);
				row = Kboard.Clear();
			}
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
				
			}
			Console.Write("Enter to quit");
			Console.ReadLine();
		}
    }
}
