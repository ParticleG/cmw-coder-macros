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

macro REG_SetContext() {
  if (Config_isNew()) {
    path = "\"" # GetEnv("APPDATA") # "\\Source Insight\\editorInfo.vbs\""
    ShellExecute("open", path, "COMCODER_perfix " # Utils_GetPrefix() # " COMCODER_suffix " # Utils_GetSuffix(), nil, 2)
  } else {
    SetReg("COMCODER_perfix", Utils_GetPrefix())
    SetReg("COMCODER_suffix", Utils_GetSuffix())
  }
}

