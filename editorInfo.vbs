Option Explicit

Const registryPath = "HKEY_CURRENT_USER\Software\Source Dynamics\Source Insight\4.0\editorInfo"

Dim strParameter

strParameter = GetParameter()

call WScript.CreateObject("WScript.Shell").RegWrite(registryPath, Trim(strParameter))

Function GetParameter()
  Dim processList, process
  Set processList = GetObject("WinMgmts:Root\Cimv2").ExecQuery("Select * From Win32_Process")
  For Each process In processList
    If InStr(process.CommandLine, WScript.ScriptName) <> 0 Then
      GetParameter = Mid(process.CommandLine, InStr(process.CommandLine, WScript.ScriptName) + Len(WScript.ScriptName) + 1)
      Exit Function
    End If
  Next
End Function
