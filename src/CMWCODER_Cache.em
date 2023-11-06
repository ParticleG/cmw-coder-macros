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
  Cache.file = nil
  Cache.mode = 0
}

macro Cache_clearString() {
  global Cache

  Cache.completebuf = nil
  Cache.completesuf = nil
  Cache.pre = nil
  Cache.suf = nil
  Cache.curbuf = nil
  Cache.firstline = nil
}

macro Cache_nowrite(){
  currentCursor = Utils_getCurrentCursor()
  currentLine = Utils_getCurrentLine()
  hCurrentBuf = GetCurrentBuf()
  if (
    Cache.completebuf == nil ||
    currentCursor.lnFirst != Cache.rangeStartLine ||
    Cache.file != GetBufName(hCurrentBuf) //strlen(currentLine) == Cache.maxChar
  ) {
    // msg("Cache.completebuf " # Cache.completebuf)
    // msg("currentCursor " # currentCursor.lnFirst != Cache.rangeStartLine)
    return false
  }
  if (currentCursor.ichFirst > Cache.rangeStartChar) {
    curbuf = strmid(currentLine, Cache.rangeStartChar, currentCursor.ichFirst)

  } else if (currentCursor.ichFirst < Cache.rangeStartChar) {
    // msg("sd")
    return false
  }
  if (ComparePre(Cache.firstline, curbuf)) {
    
  } else if (currentCursor.ichFirst == Cache.rangeStartChar) {
    
  } else {
    // msg("sf")
    return false
  }
  return true
}

macro Cache_isHit() {
  global Cache
  // msg("Cache_isHit")
  currentCursor = Utils_getCurrentCursor()
  currentLine = Utils_getCurrentLine()
  hCurrentBuf = GetCurrentBuf()
  if (currentCursor == nil || currentLine == nil) {
    return false
  }
  // msg(1)
  // msg("currentCursor.ichLim: " # currentCursor.ichLim # " Cache.maxChar: " # Cache.maxChar )
  if (
    Cache.completebuf == nil ||
    currentCursor.lnFirst != Cache.rangeStartLine ||
    Cache.file != GetBufName(hCurrentBuf) //strlen(currentLine) == Cache.maxChar
  ) {
    return false
  }
  // msg(2)
  // note_index = strstr(currentLine, "/*")
  // if (note_index != 0xffffffff) {
  //   if (note_index < currentCursor.ichFirst) {
  //     return false
  //   }
  // }
  curbuf = nil
  if (currentCursor.ichFirst > Cache.rangeStartChar) {
    curbuf = strmid(currentLine, Cache.rangeStartChar, currentCursor.ichFirst)
    // msg(curbuf)
  } else if (currentCursor.ichFirst < Cache.rangeStartChar) {
    if (Cache.pre != nil) {
      Cache.pre = strmid(Cache.pre, 0, currentCursor.ichFirst)
    }
    return false
  }
  // msg(4)
  //  msg(curbuf)
  Cache.curbuf = curbuf

  // msg("curbuf: " # curbuf)
  // lineSeperatorIndex = Utils_findFirst(Cache.completebuf, "\\r\\n")
  // if (lineSeperatorIndex == invalid) {
  //   completebuf = Cache.completebuf
  // } else {
  //   completebuf = strmid(Cache.completebuf, 0, lineSeperatorIndex)
  // }
  // msg(Cache.firstline)
  if (ComparePre(Cache.firstline, curbuf)) {
    completebuf = strmid(Cache.firstline , strlen(curbuf), strlen(Cache.firstline))
    if (completebuf != nil) {
      if (Cache.mode) {
        tempbuf = Cache.pre # Cache.curbuf # "/*" # completebuf # Cache.suf
      } else {
        tempbuf = Cache.pre # Cache.curbuf # "/*" # completebuf # "*/" #Cache.suf
      }
      
    } else {
      tempbuf = Cache.pre # Cache.curbuf # Cache.suf
    }
  } else if (currentCursor.ichFirst == Cache.rangeStartChar) {
    // msg(1)
    return false
  } else {
    // msg(2)
    return false
  }

  //msg(currentCursor.lnFirst # "    " # curlinebuf)
  hCurrentWnd= GetCurrentWnd()
  // msg(3)
  PutBufLine(hCurrentBuf, currentCursor.lnFirst, tempbuf)
  SetWndSel(hCurrentWnd, currentCursor)
  return true
}

macro Cache_setRange(startline, startchar, endline, endchar) {
  global Cache

  Cache.rangeStartLine = startline
  Cache.rangeStartChar = startchar
  Cache.rangeEndLine = endline
  Cache.rangeEndChar = endchar
}
