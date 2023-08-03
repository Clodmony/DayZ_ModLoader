# DayZ Mods Downloader

This script downloads mods for the game DayZ using SteamCMD. It is written in PowerShell.

## Configuration

Before running the script, you need to edit the `workshop.json` configuration file and add the path to SteamCMD and the path to the server folder. You can do this by opening the file in a text editor and updating the values for `scriptcfg.steamcmd` and `scriptcfg.serverpath`.

You also need to update the Steam credentials in the script by replacing `CHANGEME` with your Steam username and password.

## Usage

To use the script, simply run it in a PowerShell console. The script will read the configuration from `workshop.json`, download all mods specified in the file using SteamCMD, create symlinks to all mods in the DayZ server folder, copy `.bikey` files to the server's keys folder, and create a `start.bat` file to start the server.

## Notes

- The script assumes that SteamCMD is installed and that you have a valid Steam account with access to the DayZ mods.
- The script creates symlinks from the download location to the server folder. This means that if you delete or move the downloaded mods, the symlinks will be broken.
- The script only copies `.bikey` files if they do not already exist in the server's keys folder.
- The `start.bat` file created by the script starts the DayZ server with all downloaded mods enabled.
