macro Symbol_get() {
  var symbol
  cursor = Utils_getCurrentCursor()
  hbuf = GetCurrentBuf()
  curSymbolLocation = GetSymbolLocationFromLn(hbuf, cursor.lnFirst)
  if (curSymbolLocation == nil) {
    return symbol
  }
  hsyml = SymbolChildren(curSymbolLocation)
  cchild = SymlistCount(hsyml)
  ichild = 0

  while(ichild < cchild) {
    childsym = SymListItem(hsyml,  ichild)
    if (childsym.Type != "Type Reference") {
      DeclaredSymbol = SymbolDeclaredType(childsym)
      if (DeclaredSymbol != nil) {
        if (DeclaredSymbol.Type == "Structure" || DeclaredSymbol.Type == "Type Definition") {
          //msg(DeclaredSymbol)
          name = procSymbolName(DeclaredSymbol.Symbol)
          symbol = symbol # "|" # name # "|" # DeclaredSymbol.File # "|" # DeclaredSymbol.lnFirst # "|" # DeclaredSymbol.lnLim # "|"
        }
      }
    }
    ichild = ichild + 1
  }
  return symbol
}

macro procSymbolName(symbol_name) {
  index = strstr(symbol_name, ".") 
  if (index != 0xffffffff) {
    return strmid(symbol_name, index, strlen(symbol_name))
  } else {
    return symbol_name
  }
}
