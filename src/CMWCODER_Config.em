macro Config_init() {
  global Config

  Config.baseFolder = "C:\\ProgramData\\Source Insight\\"
  Config.version = "%PLUGIN_VERSION%"

  info = GetProgramInfo()
  Config.programMajorVersion = info.versionMajor

  autoCompletion = Env_GetAutoCompletion()
  if (autoCompletion == nil) {
    Config.autoCompletion = true
    Env_SetAutoCompletion(Config.autoCompletion)
  } else {
    Config.autoCompletion = autoCompletion
  }
}

macro Config_isNew() {
  global Config

  return Config.programMajorVersion == "4"
}

macro Config_version() {
  global Config

  return Config.version
}

macro Config_ChangeAutoCompletion() {
  global Config

  Config.autoCompletion = !Config.autoCompletion
  Env_SetAutoCompletion(Config.autoCompletion)
}
