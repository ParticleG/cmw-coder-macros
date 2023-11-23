macro Symbol_get() {
  var symbol
  var paramet_symbol
  hCurrentWnd = GetCurrentWnd()
  hbuf = GetCurrentBuf()
  if (hCurrentWnd == nil || hbuf == nil) {
    return nil
  }
  cursor = GetWndSel(hCurrentWnd)
  curSymbolLocation = GetSymbolLocationFromLn(hbuf, cursor.lnFirst)
  if (curSymbolLocation == nil) {
    return symbol
  }
  hsyml = SymbolChildren(curSymbolLocation)
  cchild = SymlistCount(hsyml)
  ichild = 0
  
  while(ichild < cchild) {
    // 最大值在60-65之间，为保险使用55
    if (ichild > 55){
      return symbol # paramet_symbol
    }
    childsym = SymListItem(hsyml,  ichild)
    if (childsym.Type == "Parameter"){
      DeclaredSymbol = SymbolDeclaredType(childsym)
      if (DeclaredSymbol != nil) {
        if (DeclaredSymbol.Type == "Structure" || DeclaredSymbol.Type == "Type Definition") {
          name = procSymbolName(DeclaredSymbol.Symbol)
          paramet_symbol = paramet_symbol # "|" # name # "|" # DeclaredSymbol.File # "|" # DeclaredSymbol.lnFirst # "|" # DeclaredSymbol.lnLim # "|"
        }
      }
    } else if (childsym.Type != "Type Reference") {
      DeclaredSymbol = SymbolDeclaredType(childsym)
      if (DeclaredSymbol != nil) {
        if (DeclaredSymbol.Type == "Structure" || DeclaredSymbol.Type == "Type Definition") {
          name = procSymbolName(DeclaredSymbol.Symbol)
          symbol = symbol # "|" # name # "|" # DeclaredSymbol.File # "|" # DeclaredSymbol.lnFirst # "|" # DeclaredSymbol.lnLim # "|"
        }
      }
    }
    ichild = ichild + 1
  }
  return symbol # paramet_symbol
}

macro procSymbolName(symbol_name) {
  index = Utils_FindSubstring(symbol_name, ".") 
  if (index != 0xffffffff) {
    return strmid(symbol_name, index, strlen(symbol_name))
  } else {
    return symbol_name
  }
}
