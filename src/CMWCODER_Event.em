event DocumentOpen(sFile) {
  if (!Tabs_exist(sFile) && Utils_isCLangFile(sFile)) {
    Tabs_add(sFile)
  }
}

event DocumentClose(sFile) {
  if (Tabs_exist(sFile)) {
    Tabs_remove(sFile)
  }
}

// macro Macro_RecordInput() {
//   global isInit
//   if (isInit == nil)
//   {
//     return nil
//   }
//   Input_waitKey()
// }

macro Macro_CheckComplete() {
  global position
  global Cache
  global Input
  global isInit
  if (isInit == nil)
  {
    return nil
  }
  // if (Input_isNone()) {
  //   return nil
  // }

  if (Input_read() != nil) {
     //msg("isnewtime" # Input_isNewTime())
    //msg("1")
    Input_saveTime()
    if (Input_isCommand()) {
        // msg("1.1")
      if (Input_isTab()) {
        // msg("1.1.1")
        // msg("Cache.completebuf: " # Cache.completebuf)
        if(Cache.completebuf != nil) {
          // msg("1.1.1.1")
          Completion_Accept()
        } else {
          // msg("1.1.1.2")
          //Input_runCmd()
        }
      } else if(Input_isEscape()) {
        Completion_cancel()
        Cache_clearString()
      } else if (Input_isEnter()) {
        // msg("1.1.2")
        if (Cache.completebuf!= nil) {
          //  msg("1.1.2.1")
          Completion_cancel_entry()
          Cache_clearString()
          FS_processCompletionReaction(false)
        }
        // Input_runCmd()
        Completion_writeInfo(GetBufName(GetCurrentBuf()))
      } else if (Input_isBackspace()) {
        // Input_runCmd()
        if(Cache.completebuf != nil) {
          hCurrentBuf = GetCurrentBuf()
          if (GetBufLineCount(hCurrentBuf) != Cache.maxLine) {
            Completion_cancel_backspace_entry()
            Cache_clearString()
            FS_processCompletionReaction(false)
          } else if (Cache_isHit() == true){
            // msg("1.1.3.1")
          } else {
            Completion_cancel()
            Cache_clearString()
            FS_processCompletionReaction(false)
          }
        }

      } else {
      //  msg("1.1.4")
        //Input_runCmd()
      }
    } else {
      // msg("1.2")
      //Input_writeBack()
      if (Cache_isHit() == true)
      {
        // msg("Cache_isHit() " #  Cache_isHit())
        // msg("1.2.1")
      }
      else{
        // msg("1.2.2")
        Completion_cancel()
        Cache_clearString()
        FS_processCompletionReaction(false)
        Completion_writeInfo(GetBufName(GetCurrentBuf()))
      }
    }
  } else {
    //msg("2")
    cursor = Utils_getCurrentCursor()
    if (position.line == cursor.lnFirst && position.column == cursor.ichFirst) {
      //msg("2.1")
      // 一级缓存
      if (Cache_isHit() == true)
      {
        //  msg("2.1.1")

      }
      else{
        completion = FS_processCompletionGenerated()
        // msg("completion:'@completion@'")
        if (completion!= nil) {
          Completion_insertLine(completion)
        }
      }

    } else {
      // msg("2.2")
      position.line = cursor.lnFirst
      position.column = cursor.ichFirst
      if (Cache_isHit() == true)
      {
          //  msg("2.2.1")

      }
      else{
         Completion_cancel()
         Cache_clearString()
         FS_processCompletionReaction(false)
      }
    }
  }
  // msg("end")
}

event ProjectOpen(sProject) {
  Event_init()
}

event AppStart() {
  Event_init()
  scriptPath = "\"" # GetEnv("APPDATA") # "\\Source Insight\\Start.vbs\""
  ShellExecute("open", scriptPath, nil, nil, 2)
}

event AppShutdown() {
  SetReg("needClose", 1)
}

macro Event_init() {
  global isInit

  position_init()
  type_init()

  Config_init()
  FS_init()

  Cache_init()
  Completion_init()
  Input_init()
  Tabs_init()
  isInit = true
}

macro position_init() {
  global position

  position.line = 0
  position.column = 0
}

macro type_init() {
  global Type

  Type = 0
}
