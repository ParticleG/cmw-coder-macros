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

  Cache.completesuf = tembuf
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
  hCurrentWnd= GetCurrentWnd()
  Cache.maxLine = GetBufLineCount(hCurrentBuf)
  Cache.maxChar = strlen(buf)
  Cache.file = GetBufName(hCurrentBuf)
  PutBufLine(GetCurrentBuf(), currentCursor.lnFirst, buf)
  SetWndSel(hCurrentWnd, currentCursor)
}

macro Completion_insert() {
  cursor = Utils_getCurrentCursor()
  index = strstr(Utils_getCurrentLine(), "/*")
  if (index != 0xffffffff) {
    if (index + 1 < cursor.ichFirst) {
      return nil
    }
  }
  completion = REG_CompletionGenerated()
  // msg("completion:'@completion@'")
  if (completion!= nil) {
    Completion_insertLine(completion)
  }
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
  if (Cache.completebuf != nil) {
    // FS_processCompletionReaction(true)
    tmpbuf = Cache.pre # Cache.completebuf # Cache.completesuf
    PutBufLine(hbuf, Cache.rangeStartLine, tmpbuf)
    sel.ichFirst = strlen(tmpbuf)
    sel.ichLim = strlen(tmpbuf)
    SetWndSel(hwnd, sel)
    // SaveBuf(hbuf)
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

macro Completion_cancel_normal() {
  global Cache
  global Type

  //msg("escap")
  hCurrentBuf = GetBufHandle(Cache.file)
  cursor = Utils_getCurrentCursor()
  if (hCurrentBuf) {
    if (Cache.completebuf != nil) {
      PutBufLine(
        hCurrentBuf,
        Cache.rangeStartLine,
        Cache.pre # Cache.curbuf # Cache.suf
      )
      hCurrentWnd = GetCurrentWnd()
      SetWndSel(hCurrentWnd, cursor)
    } else {
      return false
    }
    Type = 0
    return true
  }
  return false
}

macro Completion_cancel_entry() {
  global Cache
  global Type

  //msg("escap")
  hCurrentBuf = GetCurrentBuf()
  cursor = Utils_getCurrentCursor()
  pre = strmid(GetBufLine(hCurrentBuf, cursor.lnFirst), 0, cursor.ichFirst)
  if (hCurrentBuf) {
    if (Cache.completebuf != nil) {
      PutBufLine(
        hCurrentBuf,
        cursor.lnFirst
        pre # Cache.suf
      )
      hCurrentWnd = GetCurrentWnd()
      SetWndSel(hCurrentWnd, cursor)
    } else {
      return false
    }
    Type = 0
    return true
  }
  return false
}

macro Completion_cancel() {
  canceltype = GetReg("cancelType")
  
  if (Cache.completebuf == nil) {
    return nil
  }
  // move curosor
  if (canceltype == "1") {
    Completion_cancel_normal()
  } else if (canceltype == "2") {
    // backspace char
    if (Cache_isHit() == true) {
      return nil
    } else {
      Completion_cancel_normal()
    }
  } else if (canceltype == "3") {
    // backspace line
    Completion_cancel_entry()
  }
  Cache_clearString()
  // FS_processCompletionReaction(false)
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
  editorInfo.prefix = Utils_getPrefix()
  editorInfo.suffix = Utils_getSuffix()

  REG_EditorInfo(editorInfo)
}
