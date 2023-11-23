Option Explicit
Const registryPrefixPath = "HKEY_CURRENT_USER\Software\COWCODER\CMWCODER_prefix"
Const registrySuffixPath = "HKEY_CURRENT_USER\Software\COWCODER\CMWCODER_suffix"
Const prefixName = "CMWCODER_prefix"
Const suffxiName = "CMWCODER_suffix"

Dim strParameter, prefixInfo, suffixInfo

strParameter = GetParameter()
if InStr(strParameter, prefixName) <> 0 Then
  prefixInfo = Mid(strParameter, InStr(strParameter, prefixName) + Len(prefixName) + 1,  InStr(strParameter, suffxiName) - InStr(strParameter, prefixName) - 1)
  
  call WScript.CreateObject("WScript.Shell").RegWrite(registryPrefixPath, Trim(prefixInfo))
End if
if InStr(strParameter, suffxiName) <> 0 Then
  suffixInfo = Mid(strParameter, InStr(strParameter, suffxiName) + Len(suffxiName) + 1)
  call WScript.CreateObject("WScript.Shell").RegWrite(registrySuffixPath, Trim(suffixInfo))
End if

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
