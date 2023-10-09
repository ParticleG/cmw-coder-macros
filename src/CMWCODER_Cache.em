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
}

macro Cache_clearString() {
  global Cache

  Cache.completebuf = nil
  Cache.completesuf = nil
  Cache.pre = nil
  Cache.suf = nil
  Cache.curbuf = nil
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
  // msg("currentCursor.ichLim: " # currentCursor.ichLim # " Cache.maxChar: " # Cache.maxChar )
  if (
    Cache.completebuf == nil ||
    currentCursor.lnFirst != Cache.rangeStartLine ||
    Cache.file != GetBufName(hCurrentBuf) //strlen(currentLine) == Cache.maxChar
  ) {
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
    if (Cache.pre != nil) {
      Cache.pre = strmid(Cache.pre, 0, currentCursor.ichFirst)
    }
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

  //msg(currentCursor.lnFirst # "    " # curlinebuf)
  hCurrentWnd= GetCurrentWnd()
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
