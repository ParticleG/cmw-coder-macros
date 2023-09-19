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
  if (index >= strlen(insstr)-2)
  {
    return insstr
  }
  if (insstr[index] == "\\" || insstr[index] == "*" || insstr[index] == "/")
  {
    return insstr
  }
  else
  {
    chartmp = insstr[index]
    suffinsstr = strmid(insstr, index+1, strlen(insstr))
    //msg("suffinsstr: " # suffinsstr)
    if (index == 0)
    {
      return cat(cat(chartmp,"/*"),suffinsstr)
    }
    else
    {
      preinsstr = strmid(insstr, 0, index)
      //msg("preinsstr: " # preinsstr)
      tmp = cat(cat(cat(cat(preinsstr, "*/"),chartmp),"/*"),suffinsstr)
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
    suffixline = ""
  }

  insstrIndex = 0
  suffixIndex = 0
  tembuf = ""
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

  // return cat(prefixline, cat(inserttmp, tembuf))
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
    Cache.suf = ""
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
    if (Cache.completebuf != "") {
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
    if (Cache.completebuf != "") {
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
    if (Cache.completebuf != "") {
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








