macro Config_SnippetMode() {
  global Type

  Type = 1

  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf == hNil) {
    return nil
  }

  Completion_cancel_normal()
  Cache_clearString()
  Completion_writeInfo(GetBufName(hCurrentBuf))
}

macro Config_LineMode() {
  global Type

  Type = 0

  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf == hNil) {
    return nil
  }

  if (Cache_isHit() == true) {
    // TODO: Implement 1st cache layer
  } else {
    Completion_cancel_normal()
    Cache_clearString()
    Completion_writeInfo(GetBufName(hCurrentBuf))
  }
}