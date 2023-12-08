' Option Explicit
' Constants
Const boxTitle = "Comware Coder 插件安装"
Const url = "http://rdee.h3c.com/h3c-ai-assistant/plugin/sourceinsight/"
Const baseProjectPathRegistry = "HKEY_CURRENT_USER\Software\Source Dynamics\Source Insight\Installer\baseProjectPath"
Const programRootPathRegistry = "HKEY_CURRENT_USER\Software\Source Dynamics\Source Insight\Installer\programRootPath"
Const pluginPath = "C:\Windows\Temp\SourceInsight\"
Const downloadPath = "\\h3cbjnt23-fs\软件平台3\V7DEV\Comware Leopard 工具\SI插件\"
Const downloadRedConfigFile = "config-red.toml"
Const downloadYellowConfigFile = "config-yellow.toml"
Const downloadGreenConfigFile = "config-green.toml"
Const downLoadRouteConfigFile = "config-route.toml"
Const routeIp = "10.113.12.206"
Const vbsName = "update.vbs"

Dim defaultBaseProjectPath, nodeJsPath, downloadBaseFiles, defaultProgramRootPath
Dim objWMIService, colProcess
defaultBaseProjectPath = WScript.CreateObject("WScript.Shell").ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\Source Insight\Projects\Base"
nodeJsPath = WScript.CreateObject("WScript.Shell").ExpandEnvironmentStrings("%APPDATA%") & "\Source Insight\"
downloadBaseFiles = Array("CMWCODER.em", "loaderdll.dll", "Start.vbs", "editorInfo.vbs", "cmw-coder-loader.exe", "traybin/2.1.4/tray_windows_release.exe","cmw-coder-fastify.exe")
defaultProgramRootPath = "C:\Program Files (x86)\Source Insight 3"
Dim baseProjectPath, programRootPath, mutex
baseProjectPath = RegistryRead(baseProjectPathRegistry)
programRootPath = RegistryRead(programRootPathRegistry)

Set objWMIService = CreateObject("WbemScripting.SWbemLocator").ConnectServer(".", "root\cimv2")

' 使用WMI执行WMIC命令查询VBS脚本进程
Set colProcess = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'wscript.exe'")
' 遍历查询结果，如果存在同名脚本进程则退出脚本
Dim runningScriptCount
runningScriptCount = 0
For Each objProcess In colProcess
    if InStr(objProcess.CommandLine, vbsName) Then
      runningScriptCount = runningScriptCount + 1
    End If
Next

If runningScriptCount > 1 Then
    WScript.CreateObject("WScript.Shell").Popup "已运行",1, "update.vbs", 64
    WScript.Quit
End If

WScript.CreateObject("WScript.Shell").Popup "运行update.vbs",1, "update.vbs", 64
Call EnsureFolders()
Call Download()
WScript.CreateObject("WScript.Shell").Popup "下载完成，开始安装",1, "update.vbs", 64
If NOT CheckUpdate(baseProjectPath) Then
  WScript.Quit
End If

Dim si3NotRunning, si4NotRunning
si3NotRunning = EnsureSourceInsightNotRunning("Insight3.exe")
si4NotRunning = EnsureSourceInsightNotRunning("sourceinsight4.exe")

If si3NotRunning And si4NotRunning Then
  ' Process baseProjectPath
  Do While IsNullOrEmpty(baseProjectPath)
    baseProjectPath = inputbox("请输入 Source Insight 的 Base 项目所在文件夹的路径", boxTitle, defaultBaseProjectPath)
    If IsNullOrEmpty(baseProjectPath) Then
      Call MsgBox("Base 项目路径不能为空", vbOKOnly + vbInformation + vbSystemModal, boxTitle)
    Else
      Call RegistryWrite(baseProjectPathRegistry, baseProjectPath)
    End If
  Loop
  Call RemoveFilesStartWith("CMWCODER_", baseProjectPath)

  ' Process programRootPath
  Call programRootProcess()
  ' on error resume next
  ' Remove old files
  If ExistFile(baseProjectPath & "\Insight3.exe") Then
    Call RemoveFilesStartWith("msimg32", baseProjectPath)
  End If
  Call EnsureNodeJsNotRunning()
  Call RemoveFolder(nodeJsPath & "\plugins")
  Call RemoveFolder(nodeJsPath & "\routes")
  Call RemoveFolder(nodeJsPath & "\3.5")
  Call RemoveFolder(nodeJsPath & "\4.0")
  Call RemoveFilesStartWith("si-coding*", nodeJsPath)

  ' Copy nodejs
  If CheckConfigVersion() Then
    Call MsgBox("配置文件 config.toml 存在版本更新需要覆盖旧版配置，若自定义过配置文件内容，请确保已备份配置文件后再点击确定。")
    Call CopyFileToPath("config.toml", pluginPath, nodeJsPath)
  End If
  Call CopyFileToPath("cmw-coder-fastify.exe", pluginPath, nodeJsPath)
  Call CopyFileToPath("Start.vbs", pluginPath, nodeJsPath)
  Call CopyFileToPath("editorInfo.vbs", pluginPath, nodeJsPath)
  Call CopyFileToPath("traybin/2.1.4/tray_windows_release.exe", pluginPath, nodeJsPath)
  Call CopyFileToPath("CMWCODER.em", pluginPath, baseProjectPath)
  If Err.number <> 0 Then
    Set WshShell = WScript.CreateObject("Wscript.Shell")
    If Wscript.Arguments.Length = 0 Then
      Err.Clear
      Set ObjShell = CreateObject("Shell.Application")
      Call RemoveFilesStartWith("CMWCODER", baseProjectPath)
      ObjShell.ShellExecute "wscript.exe" , """" & WScript.ScriptFullName & """ RunAsAdministrator", , "runas", 1
      Wscript.Quit
    End IF
  End If
  Call MsgBox("安装完成，请重启 Source Insight", vbOKOnly + vbInformation + vbSystemModal, boxTitle)
Else
  Call MsgBox("请关闭所有 Source Insight 窗口后再运行此脚本", vbOKOnly + vbInformation + vbSystemModal, boxTitle)
END If

Function EnsureFolders()
  Dim fs
  Set fs = WScript.CreateObject("Scripting.FileSystemObject")
  ' 路径创建
  If NOT fs.FolderExists(pluginPath) Then
      Call fs.CreateFolder(pluginPath)
  End IF
  If NOT fs.FolderExists(pluginPath & "traybin\") Then
      Call fs.CreateFolder(pluginPath & "traybin\")
      Call fs.CreateFolder(pluginPath & "traybin\2.1.4\")
  ElseIf NOT fs.FolderExists(pluginPath & "traybin\2.1.4\") Then
      Call fs.CreateFolder(pluginPath & "traybin\2.1.4\")
  End IF
  If NOT fs.FolderExists(nodeJsPath) Then
      Call fs.CreateFolder(nodeJsPath)
  End IF
  If NOT fs.FolderExists(nodeJsPath & "traybin\") Then
      Call fs.CreateFolder(nodeJsPath & "traybin\")
      Call fs.CreateFolder(nodeJsPath & "traybin\2.1.4\")
  ElseIf NOT fs.FolderExists(nodeJsPath & "traybin\2.1.4\") Then
      Call fs.CreateFolder(nodeJsPath & "traybin\2.1.4\")
  End IF
  If NOT fs.FolderExists(defaultProgramRootPath) Then
    defaultProgramRootPath = "C:\Program Files (x86)\Source Insight 4.0"
    defaultBaseProjectPath = WScript.CreateObject("WScript.Shell").ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\Source Insight 4.0\Projects\Base"
  End IF
End Function

Function CheckUpdate(baseProjectPath)
  If IsNullOrEmpty(baseProjectPath) Then
    CheckUpdate = True
    Exit Function
  End If

  Dim localContent
  localContent = ReadFile(baseProjectPath & "\CMWCODER.em")
  If IsNullOrEmpty(localContent) Then
    CheckUpdate = True
    Exit Function
  End If

  Dim localVersion, remoteVersion
  Set localVersion = GetVersion(localContent)
  Set remoteVersion = GetVersion(ReadFile(pluginPath & "\CMWCODER.em"))
  If localVersion.Count <> 3 Then
    CheckUpdate = True
    Exit Function
  Else
    If _
      (localVersion("major") < remoteVersion("major")) Or _
      (localVersion("major") = remoteVersion("major") And localVersion("minor") < remoteVersion("minor")) Or _
      (localVersion("major") = remoteVersion("major") And localVersion("minor") = remoteVersion("minor") And localVersion("patch") < remoteVersion("patch")) _
    Then
      Dim response
      response = MsgBox("检测到新版本的 Comware Coder 插件，是否立即更新？", vbYesNo + vbQuestion + vbDefaultButton2 + vbSystemModal, boxTitle)
      If response = vbYes Then
        CheckUpdate = True
      Else
        Call MsgBox("将会在 4 小时之后再次检查更新", vbOKOnly + vbInformation + vbSystemModal, boxTitle)
        CheckUpdate = False
      End If
      Exit Function
    End If
  End If
End Function

Function GetVersion(content)
  Dim matches, re, version
  Set re = New RegExp
  re.Pattern = "Config.version = ""(\d+)\.(\d+)\.(\d+)"""
  Set matches = re.Execute(content)
  Set version = CreateObject("Scripting.Dictionary")
  If matches.count = 0 Then
    Set GetVersion = version
    Exit Function
  End If
  version("major") = matches(0).SubMatches(0)
  version("minor") = matches(0).SubMatches(1)
  version("patch") = matches(0).SubMatches(2)
  Set GetVersion = version
End Function

Function GetConfigVersion(content)
  Dim matches, re, version
  Set re = New RegExp
  re.Pattern = "configVersion = (\d+)"
  Set matches = re.Execute(content)
  If matches.count = 0 Then
    GetConfigVersion = 0
    Exit Function
  End If
  GetConfigVersion = matches(0).SubMatches(0)
End Function

Function CheckConfigVersion()
  Dim localContent
  localContent = ReadFile(nodeJsPath & "\config.toml")
  If IsNullOrEmpty(localContent) Then
    CheckConfigVersion = True
    Exit Function
  End If
  Dim localVersion, remoteVersion
  localVersion = GetConfigVersion(localContent)
  remoteVersion = GetConfigVersion(ReadFile(pluginPath & "config.toml"))
  If localVersion < remoteVersion Then
    CheckConfigVersion = True
    Exit Function
  End If
  CheckConfigVersion = False
End Function

Function EnsureSourceInsightNotRunning(processName)
  Dim processes, process
  Set processes = FindProcesses(processName)
  If processes.count > 0 Then
    Dim response
    response = MsgBox("需要关闭所有 Source Insight 窗口以继续安装流程，点击确定会自动强制关闭所有 Source Insight 窗口", vbOKCancel + vbExclamation + vbDefaultButton2 + vbSystemModal,  boxTitle)
    If response = vbOk Then
      Set processes = FindProcesses(processName)
      For Each process In processes
        process.Terminate()
      Next
      EnsureSourceInsightNotRunning = True
      Exit Function
    End If
    EnsureSourceInsightNotRunning = False
  Else
    EnsureSourceInsightNotRunning = True
  End If
End Function

Function EnsureNodeJsNotRunning()
  Dim processes, process
  Set processes = FindProcesses("cmw-coder-fastify.exe")

  If processes.count > 0 Then
    For Each process In processes
      process.Terminate()
    Next
  End If
End Function

Function FindProcesses(processName)
  Set FindProcesses = GetObject("winmgmts:\\.\root\cimv2").ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" & processName & "'")
End Function

Function RegistryRead(registryPath)
  on error resume next
  RegistryRead = WScript.CreateObject("WScript.Shell").RegRead(registryPath)
  If Err.number <> 0 Then
    RegistryRead = Null
  End If
End Function

Function RegistryWrite(registryPath, data)
  on error resume next
  Call WScript.CreateObject("WScript.Shell").RegWrite(registryPath, data)
  If Err.number <> 0 Then
    Call MsgBox("写入注册表失败，请以管理员身份运行脚本", vbOKOnly + vbCritical + vbSystemModal, boxTitle)
    WScript.Quit
  End If
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

Function ReadFile(path)
  on error resume next
  Dim file, content
  Set file = WScript.CreateObject("Scripting.FileSystemObject").OpenTextFile(path, 1)
  content = file.ReadAll()
  Call file.Close()
  If Err.number <> 0 Then
    ReadFile = Null
  Else
    ReadFile = content
  End If
End Function

Function RemoveFilesStartWith(prefix, folder)
  on error resume next
  Dim fs, file
  Set fs = WScript.CreateObject("Scripting.FileSystemObject")
  For Each file In fs.GetFolder(folder).Files
    If InStr(1, file.Name, prefix) = 1 Then
      Call fs.DeleteFile(file.Path)
    End If
  Next
End Function

Function RemoveFolder(folder)
  on error resume next
  WScript.CreateObject("Scripting.FileSystemObject").DeleteFolder(folder)
End Function

Function IsNullOrEmpty(stringValue)
  IsNullOrEmpty = (Len("" & stringValue) = 0)
End Function

Function MoveFlieName(filePath, srcName, destName)
  Dim fs
  Set fs = WScript.CreateObject("Scripting.FileSystemObject")
  If fs.FileExists(filePath & destName) Then
    Call fs.DeleteFile(filePath & destName)
  End IF
  If fs.FileExists(filePath & srcName) Then
    Call fs.MoveFile(filePath & srcName, filePath & destName)
  End IF
End Function

Function Download()
  if Ping("http://rdee.h3c.com/") Then
    Call downloadFiles()
  Else
    Call CopyFilesToPath()
    IF Ping(routeIp) Then
      Call CopyFileToPath(downLoadRouteConfigFile, downloadPath, pluginPath)
      SaveFileAsConfig(downLoadRouteConfigFile)
    Else
      Call CopyFileToPath(downloadRedConfigFile, downloadPath, pluginPath)
      SaveFileAsConfig(downloadRedConfigFile)
    End If
  End If
End Function

Function CopyFilesToPath()
    Dim fileName
    For Each fileName in downloadBaseFiles
        Call CopyFileToPath(fileName, downloadPath, pluginPath)
    Next
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

Function downloadFiles()
    Dim ipType
    Dim fileName
    For Each fileName in downloadBaseFiles
        Call getFileByHttp(url, pluginPath, fileName)
    Next
    ipType = getIpType()
    Call downloadConfigFile(ipType)
End Function

Function getIpType()
    Dim httpClient, parentWindow, iptype, html, ipInfo
    Set html = CreateObject("htmlfile")
    Set parentWindow = html.parentWindow
    Set httpClient = CreateObject("MSXML2.XMLHTTP.3.0")
    Call httpClient.Open("GET", "http://rdtest.h3c.com/kong/RdTestAiService-b/auth/judgment", False)
    httpClient.Send()
    If httpClient.Status = 200 Then
        parentWindow.execScript "var json = " & httpClient.ResponseText, "JScript" ' 解析 json
        Set ipInfo = parentWindow.json ' 获取解析后的对象
        getIpType = ipInfo.data
    Else
        Call MsgBox("get IP type err")
    End IF
End Function

Function downloadConfigFile(ipType)
    SELECT Case ipType
        Case 1
            If (getFileByHttp(url, pluginPath, downloadRedConfigFile)) Then
                SaveFileAsConfig(downloadRedConfigFile)
            End iF
        Case 2
            If (getFileByHttp(url, pluginPath, downloadYellowConfigFile)) Then
                SaveFileAsConfig(downloadYellowConfigFile)
            End iF
        Case 3
            If (getFileByHttp(url, pluginPath, downloadGreenConfigFile)) Then
                SaveFileAsConfig(downloadGreenConfigFile)
            End iF
        Case else
            WScript.Quit
    End SELECT
End Function

Function SaveFileAsConfig(srcFileName)
  Dim fs
  Set fs = WScript.CreateObject("Scripting.FileSystemObject")
  Call fs.CopyFile(pluginPath & srcFileName, pluginPath & "config.toml")
End Function

Function programRootProcess()
  on error resume next
  Do While IsNullOrEmpty(programRootPath)
    programRootPath = inputbox("请输入 Source Insight 安装路径，即 Source Insight 可执行程序所在文件夹的路径", boxTitle, defaultProgramRootPath)
    If IsNullOrEmpty(programRootPath) Then
      Call MsgBox("Source Insight 安装路径不能为空", vbOKOnly + vbInformation + vbSystemModal, boxTitle)
    Else
      Call RegistryWrite(programRootPathRegistry, programRootPath)
    End If
  Loop
  Call CopyFileToPath("loaderdll.dll", pluginPath, programRootPath)
  Call CopyFileToPath("cmw-coder-loader.exe", pluginPath, programRootPath)
  WScript.CreateObject("WScript.Shell").CurrentDirectory = programRootPath
  Call WScript.CreateObject("WScript.Shell").Run("cmw-coder-loader.exe /uninstall", 0, True)
  Call WScript.CreateObject("WScript.Shell").Run("cmw-coder-loader.exe /install", 0, True)
  If Err.number <> 0 Then
    Set WshShell = WScript.CreateObject("Wscript.Shell")
    If Wscript.Arguments.Length = 0 Then
      Err.Clear
      Set ObjShell = CreateObject("Shell.Application")
      Call RemoveFilesStartWith("CMWCODER", baseProjectPath)
      ObjShell.ShellExecute "wscript.exe" , """" & WScript.ScriptFullName & """ RunAsAdministrator", , "runas", 1
      Wscript.Quit
    End IF
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

Function ExistFile(filePath)
  ExistFile = WScript.CreateObject("Scripting.FileSystemObject").FileExists(filePath)
End Function
