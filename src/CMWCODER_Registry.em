macro Env_GetAutoCompletion() {
  return GetEnv("autoCompletion")
}

macro Env_SetAutoCompletion(value) {
  PutEnv("autoCompletion", value)
}

macro Env_GetCancelType() {
  return GetEnv("cancelType")
}

macro Env_GetCompletionGenerated() {
  return GetEnv("completionGenerated")
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

