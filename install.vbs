Option Explicit
Const installerRegistery = "HKEY_CURRENT_USER\Software\Source Dynamics\Source Insight\Installer"
Const pluginPath = "\\h3cbjnt23-fs\软件平台3\V7DEV\Comware Leopard 工具\SI插件\"
Const url = "http://rdee.h3c.com/h3c-ai-assistant/plugin/sourceinsight/"

Dim nodeJsPath
nodeJsPath = WScript.CreateObject("WScript.Shell").ExpandEnvironmentStrings("%APPDATA%") & "\Source Insight\"
Dim fs
Set fs = WScript.CreateObject("Scripting.FileSystemObject")
WScript.CreateObject("WScript.Shell").Popup "运行install.vbs",1, "update.vbs", 64
If NOT fs.FolderExists(nodeJsPath) Then
    call fs.CreateFolder(nodeJsPath)
End IF

If Ping("http://rdee.h3c.com/") Then
  Call getFileByHttp(url, nodeJsPath, "download.vbs")
Else
  Call CopyFileToPath("download.vbs", nodeJsPath)
End If

call RemoveScheduledTask("cmw-coder-update")
call RegistryDelete(installerRegistery & "\baseProjectPath")
call RegistryDelete(installerRegistery & "\programRootPath")

call WScript.CreateObject("WScript.Shell").Run("Wscript.exe """ & nodeJsPath & "download.vbs""")
call CreateScheduledTaskHourly("cmw-coder-update", nodeJsPath & "download.vbs", 4)

Function CreateScheduledTaskHourly(taskName, taskPath, hours)
  call WScript.CreateObject("WScript.Shell").Run("schtasks /create /sc hourly /mo " & hours & " /tn """ & taskName & """ /tr ""Wscript.exe '" & taskPath & "'""", 0, True)
End Function

Function getFileByHttp(url, desPath, fileName)
  Dim httpClient
  Dim oStream

  Set httpClient = CreateObject("MSXML2.XMLHTTP.3.0")

  httpClient.Open "GET", url & fileName, False
  httpClient.Send

  If httpClient.Status = 200 Then
      Set oStream = CreateObject("ADODB.Stream")
      oStream.Open
      oStream.Type = 1
      oStream.Write httpClient.responseBody
      oStream.SaveToFile desPath & fileName, 2
      oStream.Close
  else
      If fs.FileExists(pluginPath & "download.vbs") Then
        call CopyFileToPath("download.vbs", nodeJsPath)
      Else
        msgbox "get" & fileName & "to fail"
        WScript.Quit
      End If
  End If
End Function

Function CopyFileToPath(fileName, destPath)
  Dim fs
  Set fs = WScript.CreateObject("Scripting.FileSystemObject")
  If fs.FolderExists(destPath) Then
    call fs.CopyFile(pluginPath & "\" & fileName, destPath & "\" & fileName)
  Else
    call fs.CreateFolder(destPath)
    call fs.CopyFile(pluginPath & "\" & fileName, destPath & "\" & fileName)
  End If
End Function

Function RegistryDelete(registryPath)
  on error resume next
  RegistryRead = WScript.CreateObject("WScript.Shell").RegDelete(registryPath)
End Function

Function RemoveScheduledTask(taskName)
  call WScript.CreateObject("WScript.Shell").Run("schtasks /delete /tn """ & taskName & """ /f", 0, True)
End Function

Function Ping(strHostName)
  ' Standard housekeeping
  Dim colPingResults, objPingResult, strQuery
  ' Define the WMI query
  strQuery = "SELECT * FROM Win32_PingStatus WHERE Address = '" & strHostName & "'"
  ' Run the WMI query
  Set colPingResults = GetObject("winmgmts:root\cimv2").ExecQuery(strQuery)
  ' Translate the query results to either True or False
  For Each objPingResult In colPingResults
    If Not IsObject(objPingResult) Then
      Ping = False
    Else
      If objPingResult.StatusCode = 0 Then
        Ping = True
      Else
        Ping = False
      End If
      'WScript.Echo "Ping status code for " & strHostName & ": " & objPingResult.StatusCode
    End If
  Next
  Set colPingResults = Nothing
End Function