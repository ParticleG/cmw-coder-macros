// Ctrl + Alt + Shift + F9
macro Export_CancelCompletion() {
  global isInit
  if (isInit == nil) {
    Event_init()
  }
  Completion_Cancel();
}

// Ctrl + Alt + Shift + F10
macro Export_AcceptCompletion() {
  Completion_Accept()
}

// Ctrl + Alt + Shift + F11
macro Export_AutoCompletion() {
  global isInit
  if (isInit == nil) {
    Event_init()
  }
  if (Config_GetAutoCompletion()) {
    Completion_Trigger()
  }
}

// Ctrl + Alt + Shift + F12
macro Export_InsertCompletion() {
  Completion_Insert()
}

macro Export_ManualCompletion() {
  global isInit
  if (isInit == nil) {
    Event_init()
  }
  Completion_Trigger()
}

macro Export_ChangeCompletionMode() {
  Config_ChangeAutoCompletion()
  Beep()
}
