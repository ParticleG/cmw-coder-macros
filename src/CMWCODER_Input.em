macro Input_init() {
  global Input

  //msg("Input_init")

  Input.keycode = 0
  Input.lastTime = ""
  Input.time = ""
  input.type = "none"
}

// macro Input_waitKey() {
//   global Input

//   Input.keycode = GetKey()
//   Input.time = Utils_DateTimeNow()
//   if (CmdFromKey(Input.keycode) != nil) {
//     Input.type = "command"
//   } else {
//     Input.type = "normal"
//   }
// }

macro Input_read(){
  global Input
  if (GetReg("keycode") == nil)
  {
    return nil
  }
  Input.keycode = Ascii(GetReg("keycode"))
  //msg("Input.keycode " # Input.keycode)
  SetReg("keycode", nil)
  //msg(Input.keycode)
  Input.time = Utils_DateTimeNow()
 // msg("Input.time  " # Input.time)
  if (Input.keycode == 27)
  {
    Input.type = "command"
  }
  else if (CmdFromKey(Input.keycode) != nil) {
    //msg( "command")
    Input.type = "command"
  } else {
   // msg( "normal")
    Input.type = "normal"
  }
  hwnd = GetCurrentWnd()
  hbuf = GetWndBuf(hwnd)
  SaveBuf(hbuf)
  return true
}

macro Input_saveTime() {
  global Input
  //msg("Input.lastTime: "# Input.lastTime # "  Input.time: "# Input.time)
  Input.lastTime = Input.time
}

macro Input_isNewTime() {
  global Input

  return Input.lastTime == "" || Input.time != Input.lastTime
}

macro Input_isCommand() {
  global Input

  return Input.type == "command"
}

macro Input_isNone() {
  global Input

  return Input.type == "none"
}

macro Input_isTab() {
  global Input

  return Input.keycode == 9
}

macro Input_isEscape() {
  global Input

  return Input.keycode == 27
}

macro Input_isEnter() {
  global Input

  return Input.keycode == 13
}

macro Input_runCmd()
{
  global Input

  if (Input_isCommand())
  {
    cmd = CmdFromKey(Input.keycode)
    index = strstr(cmd, "...")
    if (index != 0xffffffff)
    {
      cmd=strmid(cmd, 0, index)
    }
    RunCmd(cmd)
  }
  SaveBuf(GetCurrentBuf())
}

macro Input_isBackspace() {
  global Input

  return Input.keycode == 8
}

macro Input_writeBack() {
  global Input
  curBuf = GetCurrentBuf()
  cursor = Utils_getCurrentCursor()
  cursor.ichFirst = cursor.ichFirst + 1
  cursor.ichLim =  cursor.ichLim + 1
  line = Utils_getCurrentLine()
  if (!Config_isNew())
  {
    SetBufSelText(curBuf, CharFromKey(Input.keycode))
    SetWndSel(curBuf, cursor)
  }
  else
  {
    if (line != "")
    {
       SetBufSelText(curBuf, CharFromKey(Input.keycode))
    }
    else
    {
      PutBufLine(curBuf, cursor.lnFirst, CharFromKey(Input.keycode))
      SetWndSel(curBuf, cursor)
    }
  }
  SaveBuf(curBuf)
}

macro Input_Clear() {
  global Input

  Input.keycode = 0
}

