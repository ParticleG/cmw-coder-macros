macro Cache_init() {
  global Cache

  Cache_clearString()
  Cache.rangeStartLine = 0
  Cache.rangeStartChar = 0
  Cache.rangeEndLine = 0
  Cache.rangeEndChar = 0
  Cache.isEntry = 0
  Cache.maxLine = 0
  Cache.maxChar = 0
}

macro Cache_clearString() {
  global Cache

  Cache.completebuf = nil
  Cache.pre = nil
  Cache.suf = nil
  Cache.curbuf = nil
}

macro Cache_isHit() {
  global Cache
  // msg("Cache_isHit")
  currentCursor = Utils_getCurrentCursor()
  currentLine = Utils_getCurrentLine()

  if (currentCursor == nil || currentLine == nil) {
    return false
  }
  // msg("currentCursor.ichLim: " # currentCursor.ichLim # " Cache.maxChar: " # Cache.maxChar )
  if (Cache.completebuf == nil || currentCursor.lnFirst != Cache.rangeStartLine) {
    return false
  }
  note_index = strstr(currentLine, "/*")
  if (note_index != 0xffffffff) {
    if (note_index < currentCursor.ichFirst) {
      return false
    }
  }
  curbuf = nil
  if (currentCursor.ichFirst > Cache.rangeStartChar) {
    curbuf = strmid(currentLine, Cache.rangeStartChar, currentCursor.ichFirst)
  } else if (currentCursor.ichFirst < Cache.rangeStartChar) {
    // if (Cache.pre != nil) {
    //   Cache.pre = strmid(Cache.pre, 0, currentCursor.ichFirst)
    // }
    return false
  }
  //  msg(curbuf)
  Cache.curbuf = curbuf
  // msg("curbuf: " # curbuf)
  // lineSeperatorIndex = Utils_findFirst(Cache.completebuf, "\\r\\n")
  // if (lineSeperatorIndex == invalid) {
  //   completebuf = Cache.completebuf
  // } else {
  //   completebuf = strmid(Cache.completebuf, 0, lineSeperatorIndex)
  // }
  if (ComparePre(Cache.completebuf, curbuf)) {
    completebuf = strmid(Cache.completebuf, strlen(curbuf), strlen(Cache.completebuf))
    if (completebuf != nil) {
      tempbuf = Cache.pre # Cache.curbuf # "/*" # completebuf # "*/" #Cache.suf
    } else {
      tempbuf = Cache.pre # Cache.curbuf # Cache.suf
    }
  } else if (currentCursor.ichFirst == Cache.rangeStartChar) {
    tempbuf = Cache.pre # Cache.curbuf # "/*" # Cache.completebuf # "*/" #Cache.suf
  } else {
    return false
  }
  hCurrentBuf = GetCurrentBuf()
  // msg(currentCursor.lnFirst # "    " # curlinebuf)
  PutBufLine(hCurrentBuf, currentCursor.lnFirst, tempbuf)
  SetWndSel(hCurrentBuf, currentCursor)
  return true
}

macro Cache_setRange(startline, startchar, endline, endchar) {
  global Cache

  Cache.rangeStartLine = startline
  Cache.rangeStartChar = startchar
  Cache.rangeEndLine = endline
  Cache.rangeEndChar = endchar
}

macro Cache_isSameCursor() {
  global Cache

  cursor = Utils_getCurrentCursor()
  if (cursor != nil) {
    return (
      Cache.rangeStartLine == cursor.lnFirst &&
      Cache.rangeStartChar == cursor.ichFirst
    )
  }
}
macro Completion_init() {
  global Completion

  Completion_updateContent()
}

macro Completion_hasContent() {
  global Completion

  return Completion.content!= nil
}

macro Completion_updateContent(content) {
  global Completion

  Completion.content = content
}

macro constructInstmp(insstr, index) {
  if (index >= strlen(insstr)-2) {
    return insstr
  }

  if (insstr[index] == "\\" || insstr[index] == "*" || insstr[index] == "/") {
    return insstr
  } else {
    chartmp = insstr[index]
    suffinsstr = strmid(insstr, index+1, strlen(insstr))
    //msg("suffinsstr: " # suffinsstr)
    if (index == 0) {
      return cat(cat(chartmp,"/*"),suffinsstr)
    } else {
      preinsstr = strmid(insstr, 0, index)
      //msg("preinsstr: " # preinsstr)
      tmp = preinsstr # "*/" # chartmp # "/*" # suffinsstr
      //msg("tmp" # tmp)
      return tmp
    }
  }
}

macro constructIns(currentLine, insertion, index) {
  currentLineLength = strlen(currentLine)
  if (index < currentLineLength) {
    prefixline = strmid(currentLine, 0, index)
    suffixline = strmid(currentLine, index, currentLineLength)
  } else {
    prefixline = strmid(currentLine, 0, currentLineLength)
    suffixline = nil
  }

  insstrIndex = 0
  suffixIndex = 0
  tembuf = nil
  inserttmp = insertion
  while (insstrIndex < strlen(insertion) && suffixIndex < strlen(suffixline)) {
    //msg("insstrchar " # insertion[insstrIndex] # "suffixchar:  " # suffixline[suffixIndex])
    if (insertion[insstrIndex] == suffixline[suffixIndex]) {
      //msg("insstrIndex: " # insstrIndex)
      suffixIndex = suffixIndex +1
      //msg("inserttmp:  " # inserttmp)
    }
    insstrIndex = insstrIndex + 1
  }
  if (suffixIndex < strlen(suffixline)) {
    //msg("suffixIndex: " # suffixIndex # " suffixline: " # suffixline # " strlen: " # strlen(suffixline))
    tembuf = strmid(suffixline, suffixIndex, strlen(suffixline))
    //msg("str: " # str " tembuf: " # tembuf)
  }

  return prefixline # "/*" # insertion # "*/" # tembuf
}

macro Completion_insertLine(inputContent) {
  global Cache

  curLineBuf = Utils_getCurrentLine()
  currentCursor = Utils_getCurrentCursor()
  if (currentCursor == nil) {
    return false
  }
  currentCharactor = currentCursor.ichFirst
  Cache.completebuf = inputContent
  lineSeperatorIndex = Utils_findFirst(inputContent, "\\r\\n")
  if (lineSeperatorIndex == invalid) {
    // buf = cat(cat("/*", inputContent),"*/")
    buf = constructIns(curLineBuf, inputContent, currentCharactor)
  } else {
    // TODO: Seperate Cache and Completion.content
    Cache.completebuf = strmid(inputContent, 0, lineSeperatorIndex)
    Completion_updateContent(Cache.completebuf)
    buf = constructIns(
      curLineBuf,
      Cache.completebuf,
      currentCharactor
    )
  }

  if (currentCharactor < strlen(curLineBuf)) {
    Cache.pre = strmid(curLineBuf, 0, currentCharactor)
    Cache.suf = strmid(curLineBuf, currentCharactor, strlen(curLineBuf))
  } else {
    Cache.pre = strmid(curLineBuf, 0, strlen(curLineBuf))
    Cache.suf = nil
  }

  Cache_setRange(
    currentCursor.lnFirst,
    currentCursor.ichFirst,
    currentCursor.lnLast,
    currentCursor.ichFirst + strlen(Cache.completebuf) + 4
  )
  hCurrentBuf = GetCurrentBuf()
  Cache.maxLine = GetBufLineCount(hCurrentBuf)
  Cache.maxChar = strlen(buf)
  PutBufLine(GetCurrentBuf(), currentCursor.lnFirst, buf)
  SetWndSel(hCurrentBuf, currentCursor)
}

macro Completion_Accept() {
  global Cache
  global Type

  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  if (hwnd == 0) {
    return false
  }
  sel = GetWndSel(hwnd)
  lineNo = 0
  FS_processCompletionReaction(true)
  if (Cache.completebuf != nil) {
    tmpbuf = Cache.pre # Cache.completebuf # Cache.suf
    PutBufLine(hbuf, Cache.rangeStartLine, tmpbuf)
    sel.ichFirst = strlen(tmpbuf)
    sel.ichLim = strlen(tmpbuf)
    SetWndSel(hwnd, sel)
    SaveBuf(hbuf)
    lineNo = lineNo + 1
  } else {
    return false
  }

  if (Cache.rangeStartLine == Cache.rangeEndLine) {
    Cache_clearString()
    Type = 0
    return false
  }

  while(lineNo < Cache.rangeEndLine-1) {
    tmpbuf = GetBufLine(hbuf, Cache.rangeStartLine+lineNo)
    tmpbuf = cutstr(tmpbuf, "/*")
    tmpbuf = cutstr(tmpbuf, "*/")
    PutBufLine(hbuf, Cache.rangeStartLine+lineNo, tmpbuf)
    lineNo = lineNo + 1
  }
  Type = 0
}

macro Completion_cancel() {
  global Cache
  global Type

  //msg("escap")
  hCurrentBuf = GetCurrentBuf()
  cursor = Utils_getCurrentCursor()
  if (hCurrentBuf) {
    if (Cache.completebuf != nil) {
      PutBufLine(
        hCurrentBuf,
        Cache.rangeStartLine,
        Cache.pre # Cache.curbuf # Cache.suf
      )
      SetWndSel(hCurrentBuf, cursor)
    } else {
      return false
    }
    Type = 0
    return true
  }
  return false
}

macro Completion_cancel_entry(){
  global Cache
  global Type

  //msg("escap")
  hCurrentBuf = GetCurrentBuf()
  cursor = Utils_getCurrentCursor()
  if (hCurrentBuf) {
    if (Cache.completebuf != nil) {
      PutBufLine(
        hCurrentBuf,
        cursor.lnFirst
        Cache.suf
      )
      SetWndSel(hCurrentBuf, cursor)
    } else {
      return false
    }
    Type = 0
    return true
  }
  return false
}

macro Completion_cancel_backspace_entry(){
  global Cache
  global Type

  //msg("escap")
  hCurrentBuf = GetCurrentBuf()
  cursor = Utils_getCurrentCursor()
  pre = strmid(GetBufLine(hCurrentBuf, cursor.lnFirst), 0, cursor.ichFirst)
  // msg(pre # Cache.suf)
  if (hCurrentBuf) {
    if (Cache.completebuf != nil) {
      PutBufLine(
        hCurrentBuf,
        cursor.lnFirst
        pre # Cache.suf
      )
      SetWndSel(hCurrentBuf, cursor)
    } else {
      return false
    }
    Type = 0
    return true
  }
  return false
}

macro Completion_writeInfo(sFile) {
  global Type
  global Tabs
  var editorInfo

  // Get cursor info
  editorInfo.cursor = Utils_getCurrentCursor()
  // Current file path (absolute)
  editorInfo.path = sFile
  // Get project directory (absolute)
  editorInfo.project = GetProjDir(GetCurrentProj())
  // Get opened tabs' paths (absolute path)
  editorInfo.tabs = Tabs.paths
  // Completion type (0: Line, 1: Snippet)
  editorInfo.type = Type
  editorInfo.version = Config_version()
  editorInfo.symbols = Symbol_get()

  FS_processEditorInfo(editorInfo)
}
macro Config_init() {
  global Config

  Config.baseFolder = "C:\\ProgramData\\Source Insight\\"
  Config.version = "0.0.2"
  info = GetProgramInfo()
  Config.programMajorVersion = info.versionMajor
}

macro Config_isNew() {
  global Config

  return Config.programMajorVersion == "4"
}

macro Config_baseFolder() {
  global Config

  return Config.baseFolder
}

macro Config_version() {
  global Config

  return Config.version
}
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

macro Macro_CheckComplete() {
  global position
  global Cache
  global Input
  global isInit
  if (isInit == nil) {
    return nil
  }

  if (Input_read() != nil) {
    Input_saveTime()
    if (Input_isCommand()) {
        // msg("1.1")
      if (Input_isTab()) {
        // msg("1.1.1")
        // msg("Cache.completebuf: " # Cache.completebuf)
        if (Cache.completebuf != nil) {
          // msg("1.1.1.1")
          Completion_Accept()
        } else {
          // msg("1.1.1.2")
        }
      } else if (Input_isEscape()) {
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
        Completion_writeInfo(GetBufName(GetCurrentBuf()))
      } else if (Input_isBackspace()) {
        if (Cache.completebuf != nil) {
          hCurrentBuf = GetCurrentBuf()
          if (GetBufLineCount(hCurrentBuf) != Cache.maxLine) {
            Completion_cancel_backspace_entry()
            Cache_clearString()
            FS_processCompletionReaction(false)
          } else if (Cache_isHit() == true) {
            // msg("1.1.3.1")
          } else {
            Completion_cancel()
            Cache_clearString()
            FS_processCompletionReaction(false)
          }
        }
      }
    } else {
      // msg("1.2")
      if (Cache_isHit() == true) {
        // msg("Cache_isHit() " #  Cache_isHit())
        // msg("1.2.1")
      } else {
        // msg("1.2.2")
        Completion_cancel()
        Cache_clearString()
        FS_processCompletionReaction(false)
        Completion_writeInfo(GetBufName(GetCurrentBuf()))
      }
    }
  } else {
    // msg("2")
    cursor = Utils_getCurrentCursor()
    if (position.line == cursor.lnFirst && position.column == cursor.ichFirst) {
      // msg("2.1")
      // 1st layer cache
      if (Cache_isHit() == true) {
        // msg("2.1.1")
      } else {
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
      if (Cache_isHit() == true) {
        // msg("2.2.1")
      } else {
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
macro FS_init() {
  global FS

  baseFolder = Config_baseFolder()

  FS.completionGeneratedPath = baseFolder # "completion_generated"
  FS.completionGeneratedTime = nil
  FS.completionReactionPath = baseFolder # "completion_reaction"
  FS.editorInfoPath = baseFolder # "editor_info"

  _FS_ensurePath(FS.completionGeneratedPath)
  _FS_ensurePath(FS.completionReactionPath)
  _FS_ensurePath(FS.editorInfoPath)
}

macro _FS_ensurePath(path) {
  hFile = GetBufHandle(FS.editorInfoPath)
  if (!hFile) {
    hFile = OpenBuf(path)
    if (!hFile) {
      hFile = NewBuf(path)
      msg("Generating new files, please press 'Confirm'")
      SaveBuf(hFile)
    }
    ClearBuf(hFile)
    SaveBuf(hFile)
  }
  CloseBuf(hFile)
}

macro FS_processCompletionGenerated() {
  global FS
  var data

  hFile = OpenBuf(FS.completionGeneratedPath)
  if (hFile) {
    lineCount = GetBufLineCount(hFile)
    if (lineCount >= 2) {
      time = GetBufLine(hFile, lineCount - 1)
      if (FS.completionGeneratedTime != time) {
        // TODO: Support multiple completions
        data = GetBufLine(hFile, 0)
        FS.completionGeneratedTime = time
      }
    }
    CloseBuf(hFile)
  }
  return data
}

macro FS_processCompletionReaction(accepted) {
  global FS

  hFile = OpenBuf(FS.completionReactionPath)
  if (hFile) {
    ClearBuf(hFile)
    if (accepted) {
      data = "{\"accepted\": true}"
    } else {
      data = "{\"accepted\": false}"
    }
    AppendBufLine(hFile, data)
    AppendBufLine(hFile, Utils_DateTimeNow())
    SaveBuf(hFile)
    CloseBuf(hFile)
  }
}

macro FS_processEditorInfo(editorInfo) {
  global FS

  hFile = OpenBuf(FS.editorInfoPath)
  //msg("hFile:" # hFile)
  if (hFile) {
    ClearBuf(hFile)
    AppendBufLine(hFile, editorInfo)
    AppendBufLine(hFile, Utils_DateTimeNow())
    SaveBuf(hFile)
    CloseBuf(hFile)
  }
}
macro Input_init() {
  global Input

  Input.keycode = 0
  Input.lastTime = nil
  Input.time = nil
  input.type = "none"
}

macro Input_read(){
  global Input

  if (GetReg("keycode") == nil) {
    return nil
  }

  Input.keycode = Ascii(GetReg("keycode"))
  // msg("Input.keycode " # Input.keycode)
  SetReg("keycode", nil)
  // msg(Input.keycode)
  Input.time = Utils_DateTimeNow()
  // msg("Input.time  " # Input.time)
  if (Input.keycode == 27) {
    Input.type = "command"
  } else if (CmdFromKey(Input.keycode) != nil) {
    //msg( "command")
    Input.type = "command"
  } else {
   // msg( "normal")
    Input.type = "normal"
  }
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  SaveBuf(hbuf)
  return true
}

macro Input_saveTime() {
  global Input

  Input.lastTime = Input.time
}

macro Input_isNewTime() {
  global Input

  return Input.lastTime == nil || Input.time != Input.lastTime
}

macro Input_isCommand() {
  global Input

  return Input.type == "command"
}

macro Input_isNone() {
  global Input

  return Input.type == "none"
}

macro Input_isTab() {
  global Input

  return Input.keycode == 9
}

macro Input_isEscape() {
  global Input

  return Input.keycode == 27
}

macro Input_isEnter() {
  global Input

  return Input.keycode == 13
}

macro Input_runCmd() {
  global Input

  if (Input_isCommand()) {
    cmd = CmdFromKey(Input.keycode)
    index = strstr(cmd, "...")
    if (index != 0xffffffff) {
      cmd=strmid(cmd, 0, index)
    }
    RunCmd(cmd)
  }
  SaveBuf(GetCurrentBuf())
}

macro Input_isBackspace() {
  global Input

  return Input.keycode == 8
}

macro Input_writeBack() {
  global Input
  curBuf = GetCurrentBuf()
  cursor = Utils_getCurrentCursor()
  cursor.ichFirst = cursor.ichFirst + 1
  cursor.ichLim =  cursor.ichLim + 1
  line = Utils_getCurrentLine()
  if (!Config_isNew()) {
    SetBufSelText(curBuf, CharFromKey(Input.keycode))
    SetWndSel(curBuf, cursor)
  } else {
    if (line != nil) {
       SetBufSelText(curBuf, CharFromKey(Input.keycode))
    } else {
      PutBufLine(curBuf, cursor.lnFirst, CharFromKey(Input.keycode))
      SetWndSel(curBuf, cursor)
    }
  }
  SaveBuf(curBuf)
}

macro Input_Clear() {
  global Input

  Input.keycode = 0
}
macro Config_SnippetMode() {
  global Type

  Type = 1
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  sFile = GetBufName(hbuf)
  sel = GetWndSel(hwnd)
  Completion_cancel()
  Cache_clearString()
  Completion_writeInfo(sFile, hwnd, hbuf, sel)
}

macro Config_LineMode() {
  global Type

  Type = 0
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  sFile = GetBufName(hbuf)
  sel = GetWndSel(hwnd)
  Completion_cancel()
  Cache_clearString()
  Completion_writeInfo(sFile, hwnd, hbuf, sel)
}macro Symbol_get() {
  var symbol
  cursor = Utils_getCurrentCursor()
  hbuf = GetCurrentBuf()
  curSymbolLocation = GetSymbolLocationFromLn(hbuf, cursor.lnFirst)
  if (curSymbolLocation == nil) {
    return symbol
  }
  hsyml = SymbolChildren(curSymbolLocation)
  cchild = SymlistCount(hsyml)
  ichild = 0

  while(ichild < cchild) {
    childsym = SymListItem(hsyml,  ichild)
    if (childsym.Type != "Type Reference") {
      DeclaredSymbol = SymbolDeclaredType(childsym)
      if (DeclaredSymbol != nil) {
        if (DeclaredSymbol.Type == "Structure" || DeclaredSymbol.Type == "Type Definition") {
          //msg(DeclaredSymbol)
          name = procSymbolName(DeclaredSymbol.Symbol)
          symbol = symbol # "|" # name # "|" # DeclaredSymbol.File # "|" # DeclaredSymbol.lnFirst # "|" # DeclaredSymbol.lnLim # "|"
        }
      }
    }
    ichild = ichild + 1
  }
  return symbol
}

macro procSymbolName(symbol_name) {
  index = strstr(symbol_name, ".") 
  if (index != 0xffffffff) {
    return strmid(symbol_name, index, strlen(symbol_name))
  } else {
    return symbol_name
  }
}
macro Tabs_init() {
  global Tabs

  Tabs.count = 0
  Tabs.sizes = nil
  Tabs.paths = nil
}

macro Tabs_exist(sFile) {
  global Tabs

  return Utils_findFirst(Tabs.paths, sFile) != invalid
}

macro Tabs_add(sFile) {
  global Tabs

  Tabs.count = Tabs.count + 1
  Tabs.sizes = cat(Tabs.sizes, calcuSizes(sFile))
  Tabs.paths = cat(Tabs.paths, sFile)
  //msg("Tabs_add: " # sFile)
}

macro Tabs_remove(sFile) {
  global Tabs

  current_index = 0
  sizes_before = 0
  while (current_index < Tabs.count) {
    current_size = strmid(Tabs.sizes, current_index * 3, (current_index + 1) * 3)
    //msg("Tabs.sizes: " # strmid(Tabs.sizes, current_index * 3, (current_index + 1) * 3))
    current_size = 0 + current_size
    //msg("Tabs.paths: " # Tabs.paths # " sizes_before: " # sizes_before # " current_size: " # current_size)
    current_path = strmid(Tabs.paths, sizes_before, sizes_before + current_size)

    if (current_path == sFile) {
      Tabs.sizes = cat(strmid(
        Tabs.sizes,
        0,
        current_index * 3
      ), strmid(
        Tabs.sizes,
        (current_index + 1) * 3,
        strlen(Tabs.sizes)
      ))

      Tabs.paths = cat(strmid(
        Tabs.paths,
        0,
        sizes_before
      ), strmid(
        Tabs.paths,
        sizes_before + current_size,
        strlen(Tabs.paths)
      ))

      Tabs.count = Tabs.count - 1
      //msg("end Tabs: " # Tabs)
      return nil
    }

    sizes_before = sizes_before + current_size
    current_index = current_index + 1
  }
}
macro Utils_findFirst(left, right) {
  leftIndex = 0
  while (leftIndex < strlen(left) - strlen(right) + 1) {
    rightIndex = 0
    while (rightIndex < strlen(right)) {
      if (left[leftIndex + rightIndex] != right[rightIndex]) {
        break
      }
      if (rightIndex == strlen(right) - 1) {
        return leftIndex;
      }
      rightIndex = rightIndex + 1
    }
    leftIndex = leftIndex + 1
  }
  return invalid
}

macro strcmp(left, right) {
  index = 0
  while (left[index]) {
    if (left[index] != right[index]) {
      return AsciiFromChar(left[index]) - AsciiFromChar(right[index])
    }
  }
  return 0
}

macro sleep(int) {
  int= int * 250
  cout = 0
  while (cout < int) {
    cout = cout + 1
  }
}

macro ComparePre(str, substr) {
  sublen = strlen(substr)
  strlen = strlen(str)

  if (strlen < sublen) {
    return 0
  }
  tmpbuf = strmid(str, 0, sublen)
  //msg("ComparePre  tmpbuf: " # tmpbuf # " substr: " # substr)
  if (tmpbuf == substr) {
    return 1
  } else {
    return 0
  }
}

macro calcuSizes(sFile) {
  lenth = strlen(sFile)
  sizes = "000" + lenth
  if (strlen(sizes) < 3) {
    sizes = cat("0", sizes)
  }
  return sizes
}

macro Utils_isCLangFile(sFile) {
  return (
    Utils_findFirst(sFile, ".c") != invalid ||
    Utils_findFirst(sFile, ".h") != invalid
  )
}

macro cutstr(source, cutter) {
  cutIndex = Utils_findFirst(source, cutter);
  if (cutIndex == invalid) {
    return source
  }
  return cat(
    strmid(source, 0, cutIndex),
    strmid(source, cutIndex + strlen(cutter), strlen(source))
  )
}

macro Utils_getCurrentCursor() {
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentWnd) {
    return GetWndSel(hCurrentWnd)
  }
}

macro Utils_getCurrentLine() {
  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf) {
    return GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  }
}

macro isEnter(Cache) {
  if (Cache.completebuf != nil) {
    //msg("isEnter(Cache)")
    CurrentCursor = Utils_getCurrentCursor()
    if (CurrentCursor.lnFirst > Cache.rangeStartLine) {
      return 1
    } else if (CurrentCursor.lnFirst < Cache.rangeStartLine) {
      return 2
    }
  }
  return 0
}

macro Utils_DateTimeNow() {
  timeInfo = GetSysTime(false)
  date = timeInfo.Year # "/" # timeInfo.Month # "/" # timeInfo.Day
  time = (timeInfo.Hour + 8) # ":" # timeInfo.Minute # ":" # timeInfo.Second # "." # timeInfo.Milliseconds
  return date # " " # time
}

macro strstr(str1,str2) {
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if ((len1 == 0) || (len2 == 0)) {
      return 0xffffffff
    }

    while ( i < len1) {
      if (str1[i] == str2[j]) {
        while (j < len2) {
          j = j + 1
          if (str1[i+j] != str2[j]) {
            break
          }
        }
        if (j == len2) {
          return i
        }
        j = 0
      }
      i = i + 1
    }
    return 0xffffffff
}
