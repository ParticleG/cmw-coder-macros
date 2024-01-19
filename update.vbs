Const url = "http://rdee.h3c.com/h3c-ai-assistant/plugin/sourceinsight/"
Const pluginPath = "C:\Windows\Temp\ComwareCoder\"
Const pluginPathPre = "C:\Windows\Temp\SourceInsight"
Const downloadPath = "\\h3cbjnt23-fs\软件平台3\V7DEV\Comware Leopard 工具\SI插件\"
Const downloadBaseFile = "Comware Coder Setup 1.0.0.exe"

Dim nodeJsPath
nodeJsPath = WScript.CreateObject("WScript.Shell").ExpandEnvironmentStrings("%APPDATA%") & "\Source Insight"

main()

Function main()
    runCheck()
    folderProc()
    download()
    RunExecutable()
    RemoveScheduledTask("cmw-coder-update")
End Function

Function runCheck()
    Dim objWMIService, colProcess, runningScriptCount
    Set objWMIService = CreateObject("WbemScripting.SWbemLocator").ConnectServer(".", "root\cimv2")

    ' 使用WMI执行WMIC命令查询VBS脚本进程
    Set colProcess = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'wscript.exe'")
    ' 遍历查询结果，如果存在同名脚本进程则退出脚本
    runningScriptCount = 0
    For Each objProcess In colProcess
        if InStr(objProcess.CommandLine, wscript.scriptname) Then
        runningScriptCount = runningScriptCount + 1
        End If
    Next

    If runningScriptCount > 1 Then
        WScript.CreateObject("WScript.Shell").Popup "已运行",1, "update.vbs", 64
        WScript.Quit
    End If
End Function

Function folderProc()
    Dim fs
    Set fs = WScript.CreateObject("Scripting.FileSystemObject")
    RemoveFolder(nodeJsPath)
    RemoveFolder(pluginPathPre)
    If NOT fs.FolderExists(pluginPath) Then
      Call fs.CreateFolder(pluginPath)
    End IF
End Function

Function RemoveFolder(folder)
    Dim fs
    Set fs = WScript.CreateObject("Scripting.FileSystemObject")
    If fs.FolderExists(folder) Then
        call fs.DeleteFolder(folder)
    End If
End Function

Function download()
    on error resume next
        downloadFiles()
    If Err.number <> 0 Then
        CopyFilesToPath()
    End If
End Function

Function downloadFiles()
    Call getFileByHttp(url, pluginPath, downloadBaseFile)
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
      WScript.sleep 3000
      oStream.Write httpClient.responseBody
      oStream.SaveToFile desPath & fileName, 2
      oStream.Close
      getFileByHttp = True
  else
      getFileByHttp = False
  End If
End Function

Function CopyFilesToPath()
    Call CopyFileToPath(downloadBaseFile, downloadPath, pluginPath)
End Function

Function CopyFileToPath(fileName, srcPath, destPath)

    Dim fs
    Set fs = WScript.CreateObject("Scripting.FileSystemObject")
    If fs.FolderExists(destPath) Then
        Call fs.CopyFile(srcPath & "\" & fileName, destPath & "\" & fileName)
    Else
        Call fs.CreateFolder(destPath)
        Call fs.CopyFile(srcPath & "\" & fileName, destPath & "\" & fileName)
    End If
End Function

Function RemoveScheduledTask(taskName)
  call WScript.CreateObject("WScript.Shell").Run("schtasks /delete /tn """ & taskName & """ /f", 0, True)
End Function

Function RunExecutable()
    WScript.CreateObject("WScript.Shell").Run "cmd.exe /c" & pluginPath & """" & downloadBaseFile & """",vbhide
End Function