macro Cache_init() {
  global Cache

  Cache_clearString()
  Cache.rangeStartLine = -1
  Cache.rangeStartChar = -1
  Cache.rangeEndLine = -1
  Cache.rangeEndChar = -1
  Cache.maxLine = 0
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

macro Cache_setRange(startline, startchar, endline, endchar) {
  global Cache

  Cache.rangeStartLine = startline
  Cache.rangeStartChar = startchar
  Cache.rangeEndLine = endline
  Cache.rangeEndChar = endchar
}

macro Cache_isNewLine() {
  global Cache
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentWnd == nil) {
    return false
  }
  currentCursor = GetWndSel(hCurrentWnd)
  return Cache.rangeStartLine != currentCursor.lnFirst
}