Const registryPath = "HKEY_CURRENT_USER\Software\Source Dynamics\Source Insight\4.0\editorInfo"
Set objArgs = WScript.Arguments
call WScript.CreateObject("WScript.Shell").RegWrite(registryPath, objArgs(0))