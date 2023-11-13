macro Cache_init() {
  global Cache

  Cache_clearString()
  Cache.rangeStartLine = 0
  Cache.rangeStartChar = 0
  Cache.rangeEndLine = 0
  Cache.rangeEndChar = 0
  Cache.maxChar = 0
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
