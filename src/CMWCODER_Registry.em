macro REG_GetAutoCompletion() {
  return GetReg("autoCompletion")
}

macro REG_SetAutoCompletion(value) {
  SetReg("autoCompletion", value)
}

macro REG_GetCancelType() {
  return GetReg("cancelType")
}

macro REG_GetCompletionGenerated() {
  return GetReg("completionGenerated")
}

macro REG_SetEditorInfo(editorInfo) {
  if (Config_isNew()) {
    path = "\"" # GetEnv("APPDATA") # "\\Source Insight\\editorInfo.vbs\""
    ShellExecute("open", path, editorInfo, nil, 2)
  } else {
    SetReg("editorInfo", editorInfo)
  }
}

