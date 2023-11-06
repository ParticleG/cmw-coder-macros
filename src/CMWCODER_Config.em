macro Config_init() {
  global Config

  Config.baseFolder = "C:\\ProgramData\\Source Insight\\"
  Config.version = "%PLUGIN_VERSION%"

  info = GetProgramInfo()
  Config.programMajorVersion = info.versionMajor

  autoCompletion = REG_GetAutoCompletion()
  if (autoCompletion == nil) {
    Config.autoCompletion = true
    REG_SetAutoCompletion(Config.autoCompletion)
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
  REG_SetAutoCompletion(Config.autoCompletion)
}

macro Config_GetAutoCompletion() {
  global Config

  return Config.autoCompletion
}
