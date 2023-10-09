macro Config_SnippetMode() {
  global Type

  Type = 1
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  sFile = GetBufName(hbuf)
  sel = GetWndSel(hwnd)
  Completion_cancel_normal()
  Cache_clearString()
  Completion_writeInfo(sFile)
}

macro Config_LineMode() {
  global Type

  Type = 0
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  sFile = GetBufName(hbuf)
  sel = GetWndSel(hwnd)
  if (Cache_isHit() == true) {

  } else {
    Completion_cancel_normal()
    Cache_clearString()
    Completion_writeInfo(sFile)
  }
}