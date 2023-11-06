macro Completion_Accept() {
  global Cache

  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  if (hwnd == 0) {
    return false
  }
  sel = GetWndSel(hwnd)
  if (Cache.completebuf != nil) {
    // FS_processCompletionReaction(true)
    if (Cache.mode == 0)
    {
      tmpbuf = Cache.pre # Cache.completebuf # Cache.completesuf
      PutBufLine(hbuf, Cache.rangeStartLine, tmpbuf)
      sel.ichFirst = strlen(Cache.pre # Cache.completebuf)
      sel.ichLim = strlen(Cache.pre # Cache.completebuf)
      SetWndSel(hwnd, sel)
      // SaveBuf(hbuf)
    } else {
      tmpbuf = Cache.pre # Cache.firstline
      PutBufLine(hbuf, Cache.rangeStartLine, tmpbuf)
      tmpbuf = GetBufLine(hbuf, Cache.rangeEndLine)
      tmpbuf = cutstr(tmpbuf, "*/")
      PutBufLine(hbuf, Cache.rangeEndLine, tmpbuf)
    }
  } else {
    return false
  }

  Cache_clearString()
  sel.lnFirst = Cache.rangeEndLine
  sel.lnLast = Cache.rangeEndLine
  sel.ichFirst = strlen(tmpbuf)
  sel.ichLim = strlen(tmpbuf)
  SetWndSel(hwnd, sel)
}

macro Completion_Cancel() {
  canceltype = REG_GetCancelType()

  if (Cache.completebuf == nil) {
    return nil
  }

  if (canceltype == "1") { // move curosor
    _Completion_CancelNoWrap()
  } else if (canceltype == "2") { // backspace character
    _Completion_CancelNoWrap()
    // if (Cache_isHit() == false) {
      
    // } else {
    //   // msg("return")
    //   return nil
    // }
  } else if (canceltype == "3") { // backspace line
    _Completion_CancelWrap()
  }

  // Cache_clearString()
}

macro _Completion_DisplayCompletion(currentLine, insertion, index) {
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

macro Completion_Insert() {
  global Cache
  cursor = Utils_getCurrentCursor()
  index = strstr(Utils_getCurrentLine(), "/*")
  if (index != 0xffffffff) {
    if (index + 1 < cursor.ichFirst) {
      return nil
    }
  }
  if (Cache.rangeStartLine != cursor.lnFirst || Cache.rangeStartChar != cursor.ichFirst) {
    return nil
  }
  completion = REG_GetCompletionGenerated()

  if (completion!= nil) {
    // Determine mode based on content
    mode = strmid(completion, 0, 1)
    completion = strmid(completion, 1, strlen(completion))
    if (mode){
      _Completion_InsertSnippet(completion)
    } else {
      _Completion_InsertLine(completion)
    }
  }
}

macro Completion_Trigger() {
  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf == hNil) {
    return nil
  }
  currentCursor = Utils_getCurrentCursor()
  currentLine = Utils_getCurrentLine()
  if (currentCursor.ichFirst < strlen(currentLine)){
    suf = strmid(currentLine, currentCursor.ichFirst, strlen(currentLine))
    suf = TrimRight(suf)
    if(suf != " "){
      return nil
    }
  }
  _Completion_writeInfo(GetBufName(hCurrentBuf))
  // if (Cache_nowrite() == true) {
  //   // TODO: Implement 1st cache layer
  // } else {
  //   // msg("writeInfo")
  //   // _Completion_CancelNoWrap()
  //   // Cache_clearString()
    
  // }
}

macro _Completion_CancelNoWrap() {
  global Cache

  // msg("escap")
  hCurrentBuf = GetBufHandle(Cache.file)
  cursor = Utils_getCurrentCursor()
  lineCount = GetBufLineCount(hCurrentBuf)
  if (Cache.rangeStartLine > lineCount){
    renturn nil
  }
  completionLine = GetBufLine(hCurrentBuf, Cache.rangeStartLine)
  completebuf = "/*" # Cache.firstline
  index = strstr(completionLine, completebuf)
  if (index == 0xffffffff){
    return nil
  }
  pre = strmid(completionLine, 0, index)

  if (hCurrentBuf) {
    if (Cache.completebuf != nil) {
      if (Cache.rangeStartLine != Cache.rangeEndLine) {
        lineNo = Cache.rangeEndLine
        while (lineNo > Cache.rangeStartLine) {
          DelBufLine(hCurrentBuf, lineNo)
          lineNo = lineNo - 1
        }
      }
      DelBufLine(hCurrentBuf, Cache.rangeStartLine)
      InsBufLine(
        hCurrentBuf,
        Cache.rangeStartLine,
        pre
      )
      hCurrentWnd = GetCurrentWnd()
      if (cursor.lnFirst > Cache.rangeStartLine) {
        cursor.lnFirst = cursor.lnFirst - Cache.rangeEndLine + Cache.rangeStartLine
        cursor.lnLast = cursor.lnLast - Cache.rangeEndLine + Cache.rangeStartLine
      }
      SetWndSel(hCurrentWnd, cursor)
    } else {
      return false
    }
    return true
  }
  return false
}

macro _Completion_CancelWrap() {
  global Cache

  hCurrentBuf = GetCurrentBuf()
  cursor = Utils_getCurrentCursor()

  pre = strmid(GetBufLine(hCurrentBuf, cursor.lnFirst), 0, cursor.ichFirst)
  if (hCurrentBuf) {
    if (Cache.completebuf != nil) {
      if (Cache.rangeStartLine != Cache.rangeEndLine) {
        lineCount = GetBufLineCount(hCurrentBuf)
        if (lineCount < Cache.maxLine) {
          Cache.rangeStartLine = Cache.rangeStartLine - 1
          Cache.rangeEndLine = Cache.rangeEndLine - 1
        } else if (lineCount > Cache.maxLine) {
          Cache.rangeStartLine = Cache.rangeStartLine + 1
          Cache.rangeEndLine = Cache.rangeEndLine + 1
        }
        lineNo = Cache.rangeEndLine
        while (lineNo > Cache.rangeStartLine) {
          DelBufLine(hCurrentBuf, lineNo)
          lineNo = lineNo - 1
        }
      }
      // msg(cursor.lnFirst)
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
    return true
  }
  return false
}

macro _Completion_InsertLine(inputContent) {
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
    buf = _Completion_DisplayCompletion(curLineBuf, inputContent, currentCharactor)
  } else {
    Cache.completebuf = strmid(inputContent, 0, lineSeperatorIndex)

    buf = _Completion_DisplayCompletion(curLineBuf, Cache.completebuf, currentCharactor)
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
  Cache.mode = 0
  Cache.firstline = Cache.completebuf
  PutBufLine(GetCurrentBuf(), currentCursor.lnFirst, buf)
  SetWndSel(hCurrentWnd, currentCursor)
}

macro _Completion_InsertSnippet(completionGenerated) {
  global Cache
  curLineBuf = Utils_getCurrentLine()
  currentCursor = Utils_getCurrentCursor()
  Cursor = Utils_getCurrentCursor()
  hCurrentWnd = GetCurrentWnd()
  hCurrentBuf = GetCurrentBuf()
  if (currentCursor == nil) {
    return false
  }
  currentCharactor = currentCursor.ichFirst
  Cache.completebuf = completionGenerated
  Cache.rangeStartLine = currentCursor.lnFirst
  Cache.rangeStartChar = currentCursor.ichFirst
  if (currentCharactor < strlen(curLineBuf)) {
    Cache.pre = strmid(curLineBuf, 0, currentCharactor)
    Cache.suf = strmid(curLineBuf, currentCharactor, strlen(curLineBuf))
  } else {
    Cache.pre = strmid(curLineBuf, 0, strlen(curLineBuf))
    Cache.suf = nil
  }

  index = strstr(completionGenerated, "\\r\\n")
  pre_index = 0
  index_count = strlen(completionGenerated)
  // 首行去重 -- 未完成
  pre = strmid(curLineBuf, 0, currentCharactor)
  suf = strmid(curLineBuf, currentCharactor, strlen(curLineBuf))
  if (index != 0xffffffff) {
    Cache.firstline = strmid(completionGenerated, 0, index)
    PutBufLine(hCurrentBuf, Cursor.lnFirst, pre # "/*" # Cache.firstline)
    Cache.maxChar = strlen(curLineBuf) + index
    pre_index = index + 4
    Cursor.ichFirst = strlen(pre # "/*" # strmid(completionGenerated, 0, index))
    Cursor.ichLim = strlen(pre # "/*" # strmid(completionGenerated, 0, index))
    SetWndSel(hCurrentWnd, Cursor)
  } else {
    Cache.firstline = completionGenerated
    setBufSelText(hCurrentBuf, "/*" # completionGenerated)
    Cache.maxChar = strlen(curLineBuf) + strlen(completionGenerated)
  }
  while (index != 0xffffffff ) {
    index = strstr(strmid(completionGenerated, pre_index, index_count), "\\r\\n")
    if (index != 0xffffffff) {
      index = index + pre_index
      completion = strmid(completionGenerated, pre_index, index)
      pre_index = index + 4
      Cursor.lnFirst = Cursor.lnFirst + 1
      Cursor.lnLast = Cursor.lnLast + 1
      Cursor.ichFirst = strlen(completion)
      Cursor.ichLim = strlen(completion)
      InsBufLine(hCurrentBuf, Cursor.lnFirst, completion)
      SetWndSel(hCurrentWnd, Cursor)
    }
  }
  if (pre_index != 0 && pre_index < index_count) {
    completion = strmid(completionGenerated, pre_index, index_count)
    Cursor.lnFirst = Cursor.lnFirst + 1
    Cursor.lnLast = Cursor.lnLast + 1
    Cursor.ichFirst = strlen(completion)
    Cursor.ichLim = strlen(completion)
    InsBufLine(hCurrentBuf, Cursor.lnFirst, completion)
    SetWndSel(hCurrentWnd, Cursor)
  }
  // PutBufLine(hCurrentBuf, Cursor.lnFirst, "*/"  )
  SetBufSelText(hCurrentBuf, "*/"# suf)
  Cache.rangeEndLine = Cursor.lnFirst
  Cache.file = GetBufName(hCurrentBuf)
  Cache.mode = 1
  Cache.maxLine = GetBufLineCount(hCurrentBuf)
  SetWndSel(hCurrentWnd, currentCursor)
}

macro _Completion_writeInfo(sFile) {
  global Tabs
  global Cache
  var editorInfo

  // Get cursor info
  currentCursor = Utils_getCurrentCursor()
  editorInfo.cursor = currentCursor
  Cache.rangeStartLine = currentCursor.lnFirst
  Cache.rangeStartChar = currentCursor.ichFirst
  // Current file path (absolute)
  editorInfo.path = sFile
  // Get project directory (absolute)
  editorInfo.project = GetProjDir(GetCurrentProj())
  // Get opened tabs' paths (absolute path)
  editorInfo.tabs = Tabs.paths
  // Completion type (0: Line, 1: Snippet)
  // TODO: Remove this later
  editorInfo.type = 0
  editorInfo.version = Config_version()
  editorInfo.symbols = Symbol_get()
  editorInfo.prefix = Utils_getPrefix()
  editorInfo.suffix = Utils_getSuffix()

  REG_SetEditorInfo(editorInfo)
}
