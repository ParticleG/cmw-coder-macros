macro Utils_FindFirst(left, right) {
  leftIndex = 0
  while (leftIndex < strlen(left) - strlen(right) + 1) {
    rightIndex = 0
    while (rightIndex < strlen(right)) {
      if (left[leftIndex + rightIndex] != right[rightIndex]) {
        break
      }
      if (rightIndex == strlen(right) - 1) {
        return leftIndex;
      }
      rightIndex = rightIndex + 1
    }
    leftIndex = leftIndex + 1
  }
  return invalid
}

macro Utils_Strcmp(left, right) {
  index = 0
  while (left[index]) {
    if (left[index] != right[index]) {
      return AsciiFromChar(left[index]) - AsciiFromChar(right[index])
    }
  }
  return 0
}

macro Utils_Sleep(int) {
  int= int * 250
  cout = 0
  while (cout < int) {
    cout = cout + 1
  }
}

macro Utils_StrcmpPre(str, substr) {
  sublen = strlen(substr)
  strlen = strlen(str)

  if (strlen < sublen) {
    return 0
  }
  tmpbuf = strmid(str, 0, sublen)
  //msg("Utils_StrcmpPre  tmpbuf: " # tmpbuf # " substr: " # substr)
  if (tmpbuf == substr) {
    return 1
  } else {
    return 0
  }
}

macro Utils_CalcSizes(sFile) {
  lenth = strlen(sFile)
  sizes = "000" + lenth
  if (strlen(sizes) < 3) {
    sizes = cat("0", sizes)
  }
  return sizes
}

macro Utils_IsCLangFile(sFile) {
  return (
    Utils_FindFirst(sFile, ".c") != invalid ||
    Utils_FindFirst(sFile, ".h") != invalid
  )
}

macro Utils_Strcut(source, cutter) {
  cutIndex = Utils_FindFirst(source, cutter);
  if (cutIndex == invalid) {
    return source
  }
  return cat(
    strmid(source, 0, cutIndex),
    strmid(source, cutIndex + strlen(cutter), strlen(source))
  )
}

macro Utils_GetCurrentCursor() {
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentWnd) {
    return GetWndSel(hCurrentWnd)
  }
}

macro Utils_GetCurrentLine() {
  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf) {
    return GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  }
}

macro Utils_GetPrefix() {
  hwnd = GetCurrentWnd()
  if (!hwnd) {
    return nil
  }
  sel = GetWndSel(hwnd)
  hbuf = GetWndBuf(hwnd)
  maxLines = GetBufLineCount(hbuf)
  lineNo = sel.lnFirst
  charNo = sel.ichFirst
  spaceLine = 0
  var prefix
  while (lineNo >= 0 && (sel.lnFirst - lineNo - spaceLine) < 10) {
    bufline = GetBufLine(hbuf, lineNo)

    if (prefix == "\\r\\n") {
      tmpbuf = cat(bufline, "")
      spaceLine = spaceLine + 1
    } else if (lineNo == sel.lnFirst && charNo > 0 && charNo <= strlen(bufline)) {
      //bufline = Utils_Trim(bufline)
      tmpbuf = strmid(bufline, 0, charNo)
    } else {
      bufline = Utils_Trim(bufline)
      tmpbuf = cat(bufline, "\\r\\n")
    }

    prefix = cat(tmpbuf, prefix)
    lineNo = lineNo - 1
  }
  return prefix
}

macro Utils_GetSuffix() {
  hwnd = GetCurrentWnd()
  if (!hwnd) {
    return nil
  }
  sel = GetWndSel(hwnd)
  hbuf = GetWndBuf(hwnd)
  maxLines = GetBufLineCount(hbuf)
  var suffix
  var tmpbuf
  charNo = sel.ichFirst
  suffixLine = 0
  while(suffixLine < 10 && (sel.lnFirst + suffixLine) < maxLines) {
    bufline = GetBufLine(hbuf, sel.lnFirst + suffixLine)
    if (bufline == nil && strlen(suffix) > 0) {
      if (_Utils_CompareLast(suffix, "\\r\\n") == 1) {
        suffixLine = suffixLine + 1
        continue
      }
    }

    if (suffix == "\\r\\n") {
      tmpbuf = bufline
    } else {
      if (suffixLine == 0 && charNo > 0 && charNo < strlen(bufline)) {
        //bufline = Utils_Trim(bufline)
        tmpbuf = strmid(bufline, charNo, strlen(bufline))
      } else if (suffixLine == 0 && charNo == strlen(bufline)) {
        tmpbuf = nil
      } else {
        //bufline = Utils_Trim(bufline)
        tmpbuf = cat("\\r\\n", bufline)
      }
    }

    suffix = cat(suffix, tmpbuf)
    suffixLine = suffixLine + 1
  }
  return suffix
}

macro Utils_FindSubstring(str1, str2) {
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if ((len1 == 0) || (len2 == 0)) {
      return 0xffffffff
    }

    while ( i < len1) {
      if (str1[i] == str2[j]) {
        while (j < len2) {
          j = j + 1
          if (str1[i + j] != str2[j]) {
            break
          }
        }
        if (j == len2) {
          return i
        }
        j = 0
      }
      i = i + 1
    }
    return 0xffffffff
}

macro Utils_Trim(szLine) {
  szLine = Utils_LTrim(szLine)
  szLIne = Utils_RTrim(szLine)
  return szLine
}

macro Utils_LTrim(szLine) {
  nLen = strlen(szLine)
  if (nLen == 0) {
    return szLine
  }
  nIdx = 0
  while (nIdx < nLen) {
    if ((szLine[nIdx] != " ") && (szLine[nIdx] != "\t")) {
      break
    }
    nIdx = nIdx + 1
  }
  return strmid(szLine, nIdx, nLen)
}

macro Utils_RTrim(szLine) {
    nLen = strlen(szLine)
    if (nLen == 0) {
      return szLine
    }
    nIdx = nLen
    while (nIdx > 0) {
      nIdx = nIdx - 1
      if ((szLine[nIdx] != " ") && (szLine[nIdx] != "\t")) {
        break
      }
    }
    return strmid(szLine, 0, nIdx+1)
}

macro _Utils_CompareLast(str, substr) {
  sublen = strlen(substr)
  strlen = strlen(str)
  if (strlen < sublen) {
    return 0
  }
  return strmid(str, strlen - sublen, strlen) == substr
}
