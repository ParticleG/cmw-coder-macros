macro REG_GetAutoCompletion() {
  return GetReg("CMWCODER_autoCompletion")
}

macro REG_SetAutoCompletion(value) {
  SetReg("CMWCODER_autoCompletion", value)
}

macro Env_GetCancelType() {
  return GetEnv("CMWCODER_cancelType")
}

macro Env_GetCompletionGenerated() {
  return GetEnv("CMWCODER_completionGenerated")
}

macro Env_SetDebugLog(value) {
  SetReg("CMWCODER_debugLog", value)
}

macro Env_SetContext() {
  if (Config_isNew()) {
    path = "\"" # GetEnv("APPDATA") # "\\Source Insight\\editorInfo.vbs\""
    ShellExecute("open", path, "CMWCODER_prefix " # Utils_GetPrefix() # " CMWCODER_suffix " # Utils_GetSuffix(), nil, 2)
  } else {
    PutEnv("CMWCODER_prefix", Utils_GetPrefix())
    PutEnv("CMWCODER_suffix", Utils_GetSuffix())
  }
}

macro Env_SetSelection(cursor){
  PutEnv("CMWCODER_selection", cursor)
}

macro Env_GetVerificationScope(){
  var scope
  scope.startLine = GetEnv("CMWCODER_verifyStartLine")
  scope.endLine = GetEnv("CMWCODER_verifyEndLine")
  return scope
}

macro Env_SetVerifyContent(content) {
  if (Config_isNew()) {
    path = "\"" # GetEnv("APPDATA") # "\\Source Insight\\editorInfo.vbs\""
    ShellExecute("open", path, "CMWCODER_verifyContent " # content, nil, 2)
  } else {
    PutEnv("CMWCODER_verifyContent", content)
  }
}