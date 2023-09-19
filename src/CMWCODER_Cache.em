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

  Cache.completebuf = ""
  Cache.pre = ""
  Cache.suf = ""
  Cache.curbuf = ""
}

macro Cache_isHit() {
  global Cache
  // msg("Cache_isHit")
  currentCursor = Utils_getCurrentCursor()
  currentLine = Utils_getCurrentLine()
  
  if (currentCursor == nil ||
      currentLine == nil) {
    return false
  }
  //msg("currentCursor.ichLim: " # currentCursor.ichLim # " Cache.maxChar: " # Cache.maxChar )
  if (Cache.completebuf == nil ||
      currentCursor.lnFirst != Cache.rangeStartLine //strlen(currentLine) == Cache.maxChar
      ) {
    return false
  }
  note_index = strstr(currentLine, "/*")
  if (note_index != 0xffffffff) {
    if (note_index < currentCursor.ichFirst)
    {
      return false
    }
  }
  curbuf = ""
  if (currentCursor.ichFirst > Cache.rangeStartChar) {
    curbuf = strmid(currentLine, Cache.rangeStartChar, currentCursor.ichFirst)
  } else if(currentCursor.ichFirst < Cache.rangeStartChar) {
  	//if (Cache.pre != "")
  	//{
  	//  Cache.pre = strmid(Cache.pre, 0, currentCursor.ichFirst)
  	//}
  	return false
  }

  //  msg(curbuf)
  Cache.curbuf = curbuf
  //  msg("curbuf: " # curbuf)
  // lineSeperatorIndex = Utils_findFirst(Cache.completebuf, "\\r\\n")
  // if (lineSeperatorIndex == invalid) {
  //   completebuf = Cache.completebuf
  // } else {
  //   completebuf = strmid(Cache.completebuf, 0, lineSeperatorIndex)
  // }
  if(ComparePre(Cache.completebuf, curbuf))
  {
    completebuf = strmid(Cache.completebuf, strlen(curbuf), strlen(Cache.completebuf))
    if (completebuf != "")
    {
    	tempbuf = Cache.pre # Cache.curbuf # "/*" # completebuf # "*/" #Cache.suf
    }
    else
    {
    	tempbuf = Cache.pre # Cache.curbuf # Cache.suf
    }
  }
  else if(currentCursor.ichFirst == Cache.rangeStartChar)
  {
    tempbuf = Cache.pre # Cache.curbuf # "/*" # Cache.completebuf # "*/" #Cache.suf
  }
  else
  {
    return false
  }
  hCurrentBuf = GetCurrentBuf()
  //msg(currentCursor.lnFirst # "    " # curlinebuf)
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
    return (Cache.rangeStartLine == cursor.lnFirst &&
            Cache.rangeStartChar == cursor.ichFirst)
  }
}
