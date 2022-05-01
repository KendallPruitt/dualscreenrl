$settingsFile = ($HOME + "\Documents\My Games\Rocket League\TAGame\Config\TASystemSettings.ini")
$ini = Get-IniContent $settingsFile
$inibackup = ".\TASystemSettings.bak"
if (-not(Test-Path -Path $inibackup -PathType Leaf)) {
	Copy-Item $settingsFile -Destination $inibackup
}

attrib -R $settingsFile
if ($ini["SystemSettings"]["ResX"] -eq "5120") {
	echo "2560"
	$newres = "2560"
	$ini["SystemSettings"]["ResX"] = $newres
	$ini | Out-IniFile -Force -FilePath $settingsFile
}
else {
	echo "5120"
	$newres = "5120"
	$ini["SystemSettings"]["ResX"] = $newres
	$ini | Out-IniFile -Force -FilePath $settingsFile
	attrib +R $settingsFile
}

