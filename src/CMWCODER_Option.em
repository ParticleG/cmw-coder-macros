macro Config_SnippetMode() {
  global Type

  Type = 1
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  sFile = GetBufName(hbuf)
  sel = GetWndSel(hwnd)
  Completion_cancel()
  Cache_clearString()
  Completion_writeInfo(sFile, hwnd, hbuf, sel)
}

macro Config_LineMode() {
  global Type

  Type = 0
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  sFile = GetBufName(hbuf)
  sel = GetWndSel(hwnd)
  Completion_cancel()
  Cache_clearString()
  Completion_writeInfo(sFile, hwnd, hbuf, sel)
}