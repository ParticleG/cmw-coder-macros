macro Utils_findFirst(left, right) {
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

macro strcmp(left, right) {
  index = 0
  while (left[index]) {
    if (left[index] != right[index]) {
      return AsciiFromChar(left[index]) - AsciiFromChar(right[index])
    }
  }
  return 0
}

macro sleep(int) {
  int= int * 250
  cout = 0
  while (cout < int) {
    cout = cout + 1
  }
}

macro ComparePre(str, substr) {
  sublen = strlen(substr)
  strlen = strlen(str)

  if (strlen < sublen) {
    return 0
  }
  tmpbuf = strmid(str, 0, sublen)
  //msg("ComparePre  tmpbuf: " # tmpbuf # " substr: " # substr)
  if (tmpbuf == substr) {
    return 1
  } else {
    return 0
  }
}

macro calcuSizes(sFile) {
  lenth = strlen(sFile)
  sizes = "000" + lenth
  if (strlen(sizes) < 3) {
    sizes = cat("0", sizes)
  }
  return sizes
}

macro Utils_isCLangFile(sFile) {
  return (
    Utils_findFirst(sFile, ".c") != invalid ||
    Utils_findFirst(sFile, ".h") != invalid
  )
}

macro cutstr(source, cutter) {
  cutIndex = Utils_findFirst(source, cutter);
  if (cutIndex == invalid) {
    return source
  }
  return cat(
    strmid(source, 0, cutIndex),
    strmid(source, cutIndex + strlen(cutter), strlen(source))
  )
}

macro Utils_getCurrentCursor() {
  hCurrentWnd = GetCurrentWnd()
  if (hCurrentWnd) {
    return GetWndSel(hCurrentWnd)
  }
}

macro Utils_getCurrentLine() {
  hCurrentBuf = GetCurrentBuf()
  if (hCurrentBuf) {
    return GetBufLine(hCurrentBuf, GetBufLnCur(hCurrentBuf))
  }
}

macro Utils_getPrefix() {
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
      //bufline = TrimString(bufline)
      tmpbuf = strmid(bufline, 0, charNo)
    } else {
      bufline = TrimString(bufline)
      tmpbuf = cat(bufline, "\\r\\n")
    }

    prefix = cat(tmpbuf, prefix)
    lineNo = lineNo - 1
  }
  return prefix
}

macro Utils_getSuffix() {
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
      if (CompareLast(suffix, "\\r\\n") == 1) {
        suffixLine = suffixLine + 1
        continue
      }
    }

    if (suffix == "\\r\\n") {
      tmpbuf = bufline
    } else {
      if (suffixLine == 0 && charNo > 0 && charNo < strlen(bufline)) {
        //bufline = TrimString(bufline)
        tmpbuf = strmid(bufline, charNo, strlen(bufline))
      } else if (suffixLine == 0 && charNo == strlen(bufline)) {
        tmpbuf = nil
      } else {
        //bufline = TrimString(bufline)
        tmpbuf = cat("\\r\\n", bufline)
      }
    }

    suffix = cat(suffix, tmpbuf)
    suffixLine = suffixLine + 1
  }
  return suffix
}



macro strstr(str1,str2) {
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

macro CompareLast(str, substr) {
  sublen = strlen(substr)
  strlen = strlen(str)
  if (strlen < sublen) {
    return 0
  }
  return strmid(str, strlen - sublen, strlen) == substr
}

macro TrimString(szLine) {
  szLine = TrimLeft(szLine)
  szLIne = TrimRight(szLine)
  return szLine
}

macro TrimLeft(szLine) {
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

macro TrimRight(szLine) {
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

