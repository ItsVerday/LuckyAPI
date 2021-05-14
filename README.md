# LuckyAPI v0.1.0

LuckyAPI is a modloader for the indie game [Luck be a Landlord](https://store.steampowered.com/app/1404850/Luck_be_a_Landlord/). It's a really interesting game, go buy it on Steam!
LuckyAPI is heavily based on a [Luckloader](https://github.com/FeldrinH/Luckloader), which I found to be confusing, so I began writing my own modloader. The modloader is in a very early state, so don't expect too much out of it.

# Installation
Download this repository by going to the green `Download Code` button, and selecting `Download ZIP`. Place this `.zip` file in your executable folder for Luck be a Landlord. If you are on Steam, you can right-click on the game in your library and go to `Manage` -> `Browse local files` to get to this folder. Once you place the `LuckyAPI-master.zip` file in the Luck be a Landlord executable folder, unzip it. Go into the folder and find the first `luckyapi` folder (there should also be a folder called `mods` there). Move that folder so it is in the same folder as the executable. Next, go back to Steam and right-click the game once again, and go to `Properties`. There will be a section called `Launch Options`, with a text field for custom launch options. In this text field, paste: `--script luckyapi/bootstrap.gd`. If you have done everything correctly, you should be able to launch the game with the modloader! If the modloader loads correctly, there will be a label telling you the LuckyAPI version as well as the number of mods loaded on the main menu.

# Mod installation
Mods are folders containing the mod's code and assets. Mods are placed in the `mods` folder in your save directory. To get to this directory, launch the game and press `F8`. This will take you to your run logs folder. Go one back in the file explorer, until you see a folder with the `LBAL.save` file in it. Create a new folder called `mods`, and place any mods in this folder. If you download a mod as a `.zip` file, you must unzip it for the mod to load. Once you launch the game again, the mods will be loaded into your game!

# Example mod
There is a basic example mod in the `luckyapi` folder. It can be installed like any other mod. The mod is very primitive, as it was mostly used to test LuckyAPI. It doesn't do anything interesting.

# Valgo's Content Pack
My mod, which adds a handful of new symbols, can be found in the `mods` folder of this repository. Feel free to use it as a reference to develop your own mods.