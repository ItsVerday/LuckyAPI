# LuckyAPI v0.1.0

LuckyAPI is a modloader for the indie game [Luck be a Landlord](https://store.steampowered.com/app/1404850/Luck_be_a_Landlord/). It's a really interesting game, go buy it on Steam!
LuckyAPI is heavily based on a [Luckloader](https://github.com/FeldrinH/Luckloader), which I found to be confusing, so I began writing my own modloader. The modloader is in a very early state, so don't expect too much out of it.

# Installation
Download the `luckyapi.zip` file from this repo, and place it in your executable folder for Luck be a Landlord. If you are on Steam, right-click on the game in your library and go to `Manage` -> `Browse local files` to get to this folder. Once you place the `luckyapi.zip` file in the folder, unzip it. Next, go back to Steam and right-click the game once again, and go to `Properties`. There will be a section called `Launch Options`, with a text field for custom launch options. In this text field, enter: `--script luckyapi/bootstrap.gd`. If you have done everything correctly, you should be able to launch the game with the modloader! If the modloader loads correctly, there will be text telling you the LuckyAPI version, as well as the number of mods loader, on the main menu.

# Mod installation
Mods are `.zip` files containing the mod's code and assets. Mods are placed in the `mods` folder in your save directory. To get to this directory, launch the game and press `F8`. This will take you to your run logs folder. Go one back in the file explorer, until you see a folder with the `LBAL.save` file in it. Create a new folder called `mods`, and place any mods in this folder. Once you launch the game again, the mods will be loaded into your game!

# Example mod
There is a basic example mod in the `luckyapi` folder. This mod is a directory that can be zipped into a funcional mod. The mod is very primitive, as it was mostly used to test LuckyAPI up until this point. It doesn't do anything interesting.