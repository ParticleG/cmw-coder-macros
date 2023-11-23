event DocumentOpen(sFile) {
  PutEnv("CMWCODER_tab", "o" # sFile)
}

event DocumentClose(sFile) {
  PutEnv("CMWCODER_tab", "c" # sFile)
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
  isInit = true
}


