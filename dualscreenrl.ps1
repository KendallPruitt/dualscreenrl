$settingsFile = ($HOME + "\Documents\My Games\Rocket League\TAGame\Config\TASystemSettings.ini")
$ini = Get-IniContent $settingsFile
$inibackup = ".\TASystemSettings.bak"
if (-not(Test-Path -Path $inibackup -PathType Leaf)) {
	Copy-Item $settingsFile -Destination $inibackup
}


function Show-Notification {
	[cmdletbinding()]
	Param (
		[string]
		$ToastTitle,
		[string]
		[parameter(ValueFromPipeline)]
		$ToastText
	)

	[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
	$Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

	$RawXml = [xml] $Template.GetXml()
	($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
	# ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

	$SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
	$SerializedXml.LoadXml($RawXml.OuterXml)

	$Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
	$Toast.Tag = "PowerShell"
	$Toast.Group = "PowerShell"
	$Toast.ExpirationTime = [DateTimeOffset]::Now.AddSeconds(1)

	$Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
	$Notifier.Show($Toast);
}

switch ($ini["SystemSettings"]["ResX"]) {
	"5120"  {$newres = "2560"; break}
	Default {$newres = "5120"; break}
}

attrib -R $settingsFile
$ini["SystemSettings"]["ResX"] = $newres
$ini | Out-IniFile -Force -FilePath $settingsFile

# Insert empty lines
$content = [System.IO.File]::ReadAllText($settingsFile)
$content = $content.replace("`[", "`n`[")
[System.IO.File]::WriteAllText($settingsFile, $content)

if ($newres -eq "5120") {
	attrib +R $settingsFile
	Show-Notification ("RL in dual monitor mode")
}
else {
	Show-Notification ("RL in single monitor mode")
}