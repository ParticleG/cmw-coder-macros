macro Completion_Accept() {
  global Cache

  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  if (hwnd == 0 || hbuf == 0) {
    return false
  }
  sel = GetWndSel(hwnd)
  if (Cache.completebuf != nil) {
    if (Cache.mode == 0)
    {
      tmpbuf = Cache.pre # Cache.completebuf # Cache.completesuf
      PutBufLine(hbuf, Cache.rangeStartLine, tmpbuf)
      sel.ichFirst = strlen(Cache.pre # Cache.completebuf)
      sel.ichLim = strlen(Cache.pre # Cache.completebuf)
      SetWndSel(hwnd, sel)
    } else {
      tmpbuf = Cache.pre # Cache.firstline
      PutBufLine(hbuf, Cache.rangeStartLine, tmpbuf)
      tmpbuf = GetBufLine(hbuf, Cache.rangeEndLine)
      tmpbuf = Utils_Strcut(tmpbuf, "*/")
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
  canceltype = Env_GetCancelType()

  if (Cache.completebuf == nil) {
    return nil
  }
  if (canceltype == "1") { // move curosor
    _Completion_CancelNoWrap()
  } else if (canceltype == "2") { // backspace character
    _Completion_CancelNoWrap()
  } else if (canceltype == "3") { // backspace line
    _Completion_CancelWrap()
  }
}

macro Completion_Insert() {
  global Cache
  hCurrentWnd = GetCurrentWnd()
  cursor = GetWndSel(hCurrentWnd)
  if (cursor.lnFirst == 0 && cursor.ichFirst == 0) {
    return nil
  }
  if (Cache.rangeStartLine != cursor.lnFirst && Cache.rangeStartChar != cursor.ichFirst) {
    return nil
  }
  completion = Env_GetCompletionGenerated()

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
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentBuf == hNil || hCurrentWnd == hNil) {
    return nil
  }  
  currentCursor = GetWndSel(hCurrentWnd)
  currentLine = GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  if (currentCursor.ichFirst < strlen(currentLine)){
    suf = strmid(currentLine, currentCursor.ichFirst, strlen(currentLine))
    suf = Utils_RTrim(suf)
    if(suf != " "){
      return nil
    }
  }
  _Completion_writeInfo(GetBufName(hCurrentBuf))
}

macro _Completion_CancelNoWrap() {
  global Cache

  hCurrentBuf = GetBufHandle(Cache.file)
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentBuf == nil || hCurrentWnd == nil){
    return nil
  }
  cursor = GetWndSel(hCurrentWnd)
  if (cursor.lnFirst == 0 && cursor.ichFirst == 0) {
    return nil
  }
  lineCount = GetBufLineCount(hCurrentBuf)
  if (Cache.rangeEndLine > lineCount){
    return nil
  }
  completionLine = GetBufLine(hCurrentBuf, Cache.rangeStartLine)
  completebuf = "/*" # Cache.firstline
  index = Utils_FindSubstring(completionLine, completebuf)
  if (index == 0xffffffff){
    return nil
  }
  pre = strmid(completionLine, 0, index)
  if (Cache.completebuf != nil) {
    if (Cache.rangeStartLine != Cache.rangeEndLine) {
      lineNo = Cache.rangeEndLine
      while (lineNo > Cache.rangeStartLine) {
        DelBufLine(hCurrentBuf, lineNo)
        lineNo = lineNo - 1
      }
    }
    DelBufLine(hCurrentBuf, Cache.rangeStartLine)
    InsBufLine(hCurrentBuf, Cache.rangeStartLine, pre)
    hCurrentWndBuf = GetWndBuf(hCurrentWnd)
    if (hCurrentWndBuf == hCurrentBuf)
    {
      if (cursor.lnFirst > Cache.rangeStartLine) {
        cursor.lnFirst = cursor.lnFirst - Cache.rangeEndLine + Cache.rangeStartLine
        cursor.lnLast = cursor.lnLast - Cache.rangeEndLine + Cache.rangeStartLine
      }
      SetWndSel(hCurrentWnd, cursor)
    }
  } 
}

macro _Completion_CancelWrap() {
  global Cache

  hCurrentBuf = GetCurrentBuf()
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentBuf == nil || hCurrentWnd == nil){
    return nil
  }
  cursor = GetWndSel(hCurrentWnd)
  if (cursor.lnFirst == 0 && cursor.ichFirst == 0) {
    return nil
  }
  lineCount = GetBufLineCount(hCurrentBuf)
  if (Cache.rangeEndLine > lineCount) {
    return nil
  }
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
      PutBufLine(hCurrentBuf, cursor.lnFirst, pre)
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
  hCurrentBuf = GetCurrentBuf()
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentBuf == nil || hCurrentWnd == nil) {
    return false
  }
  curLineBuf = GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  currentCursor = GetWndSel(hCurrentWnd)
  if (currentCursor == nil) {
    return false
  }
  currentCharactor = currentCursor.ichFirst
  Cache.completebuf = inputContent
  Cache.pre = curLineBuf
  buf = curLineBuf # "/*" # inputContent # "*/"

  Cache_setRange(
    currentCursor.lnFirst,
    currentCursor.ichFirst,
    currentCursor.lnLast,
    currentCursor.ichFirst + strlen(Cache.completebuf) + 4
  )
  Cache.maxLine = GetBufLineCount(hCurrentBuf)
  Cache.file = GetBufName(hCurrentBuf)
  Cache.mode = 0
  Cache.firstline = Cache.completebuf
  PutBufLine(hCurrentBuf, currentCursor.lnFirst, buf)
  SetWndSel(hCurrentWnd, currentCursor)
}

macro _Completion_InsertSnippet(completionGenerated) {
  global Cache
  hCurrentWnd = GetCurrentWnd()
  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf == nil || hCurrentWnd == nil) {
    return false
  }
  curLineBuf = GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  currentCursor = GetWndSel(hCurrentWnd)
  Cursor = currentCursor

  if (currentCursor == nil) {
    return false
  }
  currentCharactor = currentCursor.ichFirst
  Cache.completebuf = completionGenerated
  Cache.rangeStartLine = currentCursor.lnFirst
  Cache.rangeStartChar = currentCursor.ichFirst
  Cache.pre = curLineBuf
  Cache.suf = nil

  index = Utils_FindSubstring(completionGenerated, "\\r\\n")
  pre_index = 0
  index_count = strlen(completionGenerated)
  // 防止\r\n出现在开头影响消除
  if (index == 0) {
    completionGenerated = strmid(completionGenerated, 4, index_count)
    index = Utils_FindSubstring(completionGenerated, "\\r\\n")
    index_count = strlen(completionGenerated)
  }
  // 首行去重 -- 未完成
  pre = curLineBuf
  suf = nil
  if (index != 0xffffffff) {
    Cache.firstline = strmid(completionGenerated, 0, index)
    PutBufLine(hCurrentBuf, Cursor.lnFirst, pre # "/*" # Cache.firstline)
    pre_index = index + 4
    Cursor.ichFirst = strlen(pre # "/*" # strmid(completionGenerated, 0, index))
    Cursor.ichLim = strlen(pre # "/*" # strmid(completionGenerated, 0, index))
    SetWndSel(hCurrentWnd, Cursor)
  } else {
    Cache.firstline = completionGenerated
    setBufSelText(hCurrentBuf, "/*" # completionGenerated)
  }
  while (index != 0xffffffff ) {
    index = Utils_FindSubstring(strmid(completionGenerated, pre_index, index_count), "\\r\\n")
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
  SetBufSelText(hCurrentBuf, "*/" # suf)
  Cache.rangeEndLine = Cursor.lnFirst
  Cache.file = GetBufName(hCurrentBuf)
  Cache.mode = 1
  Cache.maxLine = GetBufLineCount(hCurrentBuf)
  SetWndSel(hCurrentWnd, currentCursor)
}

macro _Completion_writeInfo(sFile) {
  hCurrentWnd = GetCurrentWnd()
  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf == nil || hCurrentWnd == nil) {
    return false
  }
  curLineBuf = GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  currentCursor = GetWndSel(hCurrentWnd)
  if (Cache_isNewLine()){
    PutEnv("CMWCODER_cursor", currentCursor)
    PutEnv("CMWCODER_path", sFile)
    PutEnv("CMWCODER_project", GetProjDir(GetCurrentProj()))
    PutEnv("CMWCODER_version", Config_version())
    PutEnv("CMWCODER_symbols", Symbol_get())
    Env_SetContext()
  } else {
    PutEnv("CMWCODER_curfix", curLineBuf)
  }
  
  Cache_setRange(
    currentCursor.lnFirst,
    currentCursor.ichFirst,
    currentCursor.lnFirst,
    currentCursor.ichFirst,
  )
}
