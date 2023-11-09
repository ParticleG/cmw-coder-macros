event DocumentOpen(sFile) {
  if (!Tabs_exist(sFile) && Utils_IsCLangFile(sFile)) {
    Tabs_add(sFile)
  }
}

event DocumentClose(sFile) {
  if (Tabs_exist(sFile)) {
    Tabs_remove(sFile)
  }
}

event ProjectOpen(sProject) {
  Event_init()
}

event AppStart() {
  Event_init()
  scriptPath = "\"" # GetEnv("APPDATA") # "\\Source Insight\\Start.vbs\""
  ShellExecute("open", scriptPath, nil, nil, 2)
}

event AppShutdown() {}

macro Event_init() {
  global isInit
  
  Config_init()
  Cache_init()
  Tabs_init()
  isInit = true
}


