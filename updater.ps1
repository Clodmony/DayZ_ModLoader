
$config_file = ".\workshop.json"
$mods = (Get-Content $config_file | ConvertFrom-Json)


if ( ($null -eq $mods.scriptcfg.steamcmd) -or ($null -eq $mods.scriptcfg.serverpath) ) {
    
    Write-Output "Please edit the config file and add the path to steamcmd and the path to the server folder"
    
    exit
} else {

    $steamcmdpath = $mods.scriptcfg.steamcmd  # Location of SteamCMD folder
    $Modfolder = $mods.scriptcfg.serverpath  # Location of Arma 3 server folder

}

# Steam Credentials
$username = "CHANGEME" #Read-Host -Prompt 'Enter username to use with SteamCMD'
$password = "CHANGEME" #Read-Host -Prompt 'Enter password to use with SteamCMD'

$steamcmd = Join-Path -Path $steamcmdpath -ChildPath "\steamcmd.exe"

$modslocation = Join-Path -Path $steamcmdpath -ChildPath "\steamapps\workshop\content\221100\" 

# Create steamcmd commands file to download all mods 

foreach ($mod in $mods.steamWsMods.workshopId) {

	Add-Content -path $steamcmdpath\steamcmnds.txt -value "workshop_download_item 221100 $mod validate"
	
} 

Add-Content -path $steamcmdpath\steamcmnds.txt -value "quit"

# Download all mods
& $steamcmd '+login' $username $password '+runscript steamcmnds.txt'

# Remove steamcmd commands file
Set-Content -path $steamcmdpath\steamcmnds.txt -value ""

foreach ($mod in $mods.steamWsMods) {
	
	if ($mod.download -eq "true") {

		write-output "Creating symlink to all Mods in DayZ Server folder"
		# Create symlink from download location to server folder
		$sourcedir = Join-Path -Path $modslocation -ChildPath $mod.workshopId
		$destdir = Join-Path -Path $modfolder -ChildPath $mod.name
		if (!(Test-Path $destdir)){
			cmd "/c mklink /D $destdir $sourcedir"
		} else {
			write-output "Symlink already exists"
		}

		write-output "Copying .bikey file to server's keys folder"
		# Copy bikey file to server's keys folder
		$keysource = Join-Path -Path $modslocation -ChildPath $mod.workshopId
		$keydest = Join-Path -Path $modfolder -ChildPath "keys"
		$bikeypath = Get-ChildItem -Path $keysource -Recurse -Filter *.bikey
		if (!(Test-Path $keydest)) {
			Copy-Item -Path $bikeypath.FullName -Destination $keydest
		} else {
			write-output "Bikey already exists"
		}
		
	}

}

#create start.bat file to start the server
$batfile = Join-Path -Path $modfolder -ChildPath "start.bat"

$count = $mods.steamWsMods.name.Count

$count = $mods.steamWsMods.name.Count
$mods.steamWsMods.name.ForEach({
    $modlist += $_
    if (--$count -gt 0) {
        $modlist += ";"
    }
})

$server_command = @"
@echo off
start DayZServer_x64.exe -config=serverDZ.cfg -port=2302 "-mod=$modlist" -profiles=ServerProfile -netlog
"@

Set-Content -Path $batfile -Value $server_command

$modlist = $null