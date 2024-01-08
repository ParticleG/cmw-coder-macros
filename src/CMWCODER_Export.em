// Ctrl + Alt + Shift + F9
macro Export_CancelCompletion() {}

// Ctrl + Alt + Shift + F10
macro Export_AcceptCompletion() {
  Completion_Accept()
}

// Ctrl + Alt + Shift + F11
macro Export_AutoCompletion() {
  global isInit
  if (isInit == nil) {
    Event_init()
    scriptPath = "\"" # GetEnv("APPDATA") # "\\Source Insight\\Start.vbs\""
    ShellExecute("open", scriptPath, nil, nil, 2)
  }
  Completion_Trigger()
}

// Ctrl + Alt + Shift + F12
macro Export_InsertCompletion() {}

macro Export_ManualCompletion() {}

macro Export_ChangeCompletionMode() {
  Config_ChangeAutoCompletion()
  Beep()
}

macro Export_VerifyScope() {
  hcurrentBuf = GetCurrentBuf()
  if (hcurrentBuf == hnil) {
    return nil
  }
  maxLineCount = GetBufLineCount(hcurrentBuf)
  scope = Env_GetVerificationScope()
  lineCount = scope.startLine
  if (scope.startLine > maxLineCount) {
    Env_SetActualScope(0, 0)
    return nil
  }
  content = ""

  endLine = scope.endLine
  if (scope.endLine > maxLineCount) {
    endLine = maxLineCount
  }
  
  while (lineCount < endLine) {
    currentLineBuf = GetBufLine(hcurrentBuf, lineCount)
    content = content # "\\r\\n" # currentLineBuf
    lineCount = lineCount + 1 
  }
  Env_SetVerifyContent(content)
  Env_SetActualScope(scope.startLine, endLine)
}
