macro Completion_Accept() {
  global Cache

  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf == nil) {
    return false
  }

  completion = Env_GetCompletionGenerated()
  if (completion != nil) {
    _Completion_Insert(completion)
  } else {
    return false
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


macro _Completion_Insert(completionGenerated) {
  global Cache
  hCurrentWnd = GetCurrentWnd()
  hCurrentBuf = GetCurrentBuf()
  currentCursor = GetWndSel(hCurrentWnd)
  if (hCurrentBuf == nil || hCurrentWnd == nil || currentCursor == nil) {
    return false
  }

  Cursor = currentCursor
  index = Utils_FindSubstring(completionGenerated, "\\r\\n")
  pre_index = 0
  index_count = strlen(completionGenerated)
  // 防止\r\n出现在开头影响消除
  if (index == 0) {
    completionGenerated = strmid(completionGenerated, 4, index_count)
    index = Utils_FindSubstring(completionGenerated, "\\r\\n")
    index_count = strlen(completionGenerated)
  }
  // 添加第一行和单行补全
  if (index != -1) {
    Cache.firstline = strmid(completionGenerated, 0, index)
    PutBufLine(hCurrentBuf, Cursor.lnFirst, Cache.firstline)
    pre_index = index + 4
    Cursor.ichFirst = strlen(strmid(completionGenerated, 0, index))
    Cursor.ichLim = strlen(strmid(completionGenerated, 0, index))
    SetWndSel(hCurrentWnd, Cursor)
  } else {
    Cache.firstline = completionGenerated
    PutBufLine(hCurrentBuf, Cursor.lnFirst, Cache.firstline)
    Cursor.ichFirst = strlen(Cache.firstline)
    Cursor.ichLim = strlen(Cache.firstline)
    SetWndSel(hCurrentWnd, Cursor)
  }
  // 添加多行补全
  while (index != -1 ) {
    index = Utils_FindSubstring(strmid(completionGenerated, pre_index, index_count), "\\r\\n")
    if (index != -1) {
      index = index + pre_index
      completion = strmid(completionGenerated, pre_index, index)
      Cursor.lnFirst = Cursor.lnFirst + 1
      pre_index = index + 4
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
}

macro _Completion_writeInfo(sFile) {
  global Cache
  hCurrentWnd = GetCurrentWnd()
  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf == nil || hCurrentWnd == nil) {
    return false
  }
  curLineBuf = GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  currentCursor = GetWndSel(hCurrentWnd)
  if (Cache.rangeStartLine != currentCursor.lnFirst){
    PutEnv("CMWCODER_cursor", currentCursor)
    PutEnv("CMWCODER_path", sFile)
    PutEnv("CMWCODER_project", GetProjDir(GetCurrentProj()))
    PutEnv("CMWCODER_version", Config_version())
    PutEnv("CMWCODER_symbols", Symbol_get())
    Env_SetContext()
  } else {
    PutEnv("CMWCODER_currentPrefix", curLineBuf)
  }
}
