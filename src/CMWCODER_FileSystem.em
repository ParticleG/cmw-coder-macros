macro FS_init() {
  global FS

  baseFolder = Config_baseFolder()

  FS.completionGeneratedPath = baseFolder # "completion_generated"
  FS.completionGeneratedTime = nil
  FS.completionReactionPath = baseFolder # "completion_reaction"
  FS.editorInfoPath = baseFolder # "editor_info"

  _FS_ensurePath(FS.completionGeneratedPath)
  _FS_ensurePath(FS.completionReactionPath)
  _FS_ensurePath(FS.editorInfoPath)
}

macro _FS_ensurePath(path) {
  hFile = GetBufHandle(FS.editorInfoPath)
  if (!hFile) {
    hFile = OpenBuf(path)
    if (!hFile) {
      hFile = NewBuf(path)
      msg("Generating new files, please press 'Confirm'")
      SaveBuf(hFile)
    }
    ClearBuf(hFile)
    SaveBuf(hFile)
  }
  CloseBuf(hFile)
}

macro FS_processCompletionGenerated() {
  global FS
  var data

  hFile = OpenBuf(FS.completionGeneratedPath)
  if (hFile) {
    lineCount = GetBufLineCount(hFile)
    if (lineCount >= 2) {
      time = GetBufLine(hFile, lineCount - 1)
      if (FS.completionGeneratedTime != time) {
        // TODO: Support multiple completions
        data = GetBufLine(hFile, 0)
        FS.completionGeneratedTime = time
      }
    }
    CloseBuf(hFile)
  }
  return data
}

macro FS_processCompletionReaction(accepted) {
  global FS

  hFile = OpenBuf(FS.completionReactionPath)
  if (hFile) {
    ClearBuf(hFile)
    if (accepted) {
      data = "{\"accepted\": true}"
    } else {
      data = "{\"accepted\": false}"
    }
    AppendBufLine(hFile, data)
    AppendBufLine(hFile, Utils_DateTimeNow())
    SaveBuf(hFile)
    CloseBuf(hFile)
  }
}

macro FS_processEditorInfo(editorInfo) {
  global FS

  hFile = OpenBuf(FS.editorInfoPath)
  //msg("hFile:" # hFile)
  if (hFile) {
    ClearBuf(hFile)
    AppendBufLine(hFile, editorInfo)
    AppendBufLine(hFile, Utils_DateTimeNow())
    SaveBuf(hFile)
    CloseBuf(hFile)
  }
}
