Const url = "http://rdee.h3c.com/h3c-ai-assistant/plugin/sourceinsight/"
Const pluginPath = "\\h3cbjnt23-fs\软件平台3\V7DEV\Comware Leopard 工具\SI插件\"
Const downloadRedConfigFile = "config.toml"
Const downloadYellowConfigFile = "config-yellow.toml" 
Const downloadGreenConfigFile = "config-green.toml"
Const nodeJsTmpPath = "C:\Windows\Temp\SourceInsight\"
Dim nodeJsPath
Dim downloadBaseFiles
WScript.CreateObject("WScript.Shell").Popup "运行download.vbs",1, "update.vbs", 64
nodeJsPath = WScript.CreateObject("WScript.Shell").ExpandEnvironmentStrings("%APPDATA%") & "\Source Insight\"
downloadBaseFiles = Array("update.vbs")
Dim fs
Set fs = WScript.CreateObject("Scripting.FileSystemObject")

If NOT fs.FolderExists(nodeJsTmpPath) Then
    call fs.CreateFolder(nodeJsTmpPath)
End IF
If NOT fs.FolderExists(nodeJsPath) Then
    call fs.CreateFolder(nodeJsPath)
End IF

If Ping("http://rdee.h3c.com/") Then
    call downloadFiles()
Else
    call CopyFilesToPath()
End If

call WScript.CreateObject("WScript.Shell").Run("Wscript.exe """ & nodeJsTmpPath & "update.vbs""")



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
      WScript.sleep 3000
      oStream.Write httpClient.responseBody
      oStream.SaveToFile desPath & fileName, 2
      oStream.Close
      getFileByHttp = True

  else 
      getFileByHttp = False
  End If
End Function

Function downloadFiles()
    Dim ipType
    For Each fileName in downloadBaseFiles
        call getFileByHttp(url, nodeJsTmpPath, fileName)
    Next
End Function

Function getIpType()
    Dim httpClient
    Dim iptype
    Set html = CreateObject("htmlfile")
    Set parentWindow = html.parentWindow
    Set httpClient = CreateObject("MSXML2.XMLHTTP.3.0")
    httpClient.Open "GET","http://rdtest.h3c.com/kong/RdTestAiService-b/auth/judgment", False
    httpClient.Send()
    If httpClient.Status = 200 Then
        parentWindow.execScript "var json = " & httpClient.ResponseText, "JScript" ' 解析 json
        Set ipInfo = parentWindow.json ' 获取解析后的对象
        getIpType = ipInfo.data
    Else
        msgbox "get IP type err"
    End IF
End Function

Function downloadConfigFile(ipType)
    SELECT Case ipType
        Case 1
            if (getFileByHttp(url, nodeJsTmpPath, downloadRedConfigFile)) Then
                SaveFileAsConfig(downloadRedConfigFile)
            End iF
        Case 2
            if (getFileByHttp(url, nodeJsTmpPath, downloadYellowConfigFile)) Then
                SaveFileAsConfig(downloadYellowConfigFile)
            End iF
        Case 3
            if (getFileByHttp(url, nodeJsTmpPath, downloadGreenConfigFile)) Then
                SaveFileAsConfig(downloadGreenConfigFile)
            End iF
        Case else
            MsgBox "other IP"
            WScript.Quit
    End SELECT
End Function

Function SaveFileAsConfig(srcFileName)
    Dim fs
    Set fs = WScript.CreateObject("Scripting.FileSystemObject")
    call fs.CopyFile(nodeJsTmpPath & srcFileName, nodeJsTmpPath & "config.toml" )
End Function

Function CopyFilesToPath()
    For Each fileName in downloadBaseFiles
        call CopyFileToPath(fileName, nodeJsTmpPath)
    Next
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