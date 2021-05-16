# LuckyAPI v0.1.0

LuckyAPI is a modloader for the indie game [Luck be a Landlord](https://store.steampowered.com/app/1404850/Luck_be_a_Landlord/). It's a really interesting game, go buy it on Steam!
LuckyAPI is heavily based on a [Luckloader](https://github.com/FeldrinH/Luckloader), which I found to be confusing, so I began writing my own modloader. The modloader is in an early state, so don't expect too much out of it just yet.

# Installation
Detailed installation instructions are on the GitHub Wiki for this repository, at [https://github.com/ValgoBoi/LuckyAPI/wiki/Installation](https://github.com/ValgoBoi/LuckyAPI/wiki/Installation)!

# Mod installation
Mods are folders containing the mod's code and assets. Mods are placed in the `mods` folder in your save directory. To get to this directory, launch the game and press `F8`. This will take you to your run logs folder. Go one back in the file explorer, until you see a folder with the `LBAL.save` file in it. Create a new folder called `mods`, and place any mods in this folder. If you download a mod as a `.zip` file, you must unzip it for the mod to load. Once you launch the game again, the mods will be loaded into your game!

# Example mod
There is a basic example mod in the `luckyapi` folder. It can be installed like any other mod. The mod is very primitive, as it was mostly used to test LuckyAPI. It doesn't do anything interesting.

# Valgo's Content Pack
My mod, which adds a handful of new symbols, can be found in the `mods` folder of this repository. Feel free to use it as a reference to develop your own mods.