macro Tabs_init() {
  global Tabs

  Tabs.count = 0
  Tabs.sizes = nil
  Tabs.paths = nil
}

macro Tabs_exist(sFile) {
  global Tabs

  return Utils_FindFirst(Tabs.paths, sFile) != invalid
}

macro Tabs_add(sFile) {
  global Tabs

  Tabs.count = Tabs.count + 1
  Tabs.sizes = cat(Tabs.sizes, Utils_CalcSizes(sFile))
  Tabs.paths = cat(Tabs.paths, sFile)
  //msg("Tabs_add: " # sFile)
}

macro Tabs_remove(sFile) {
  global Tabs

  current_index = 0
  sizes_before = 0
  while (current_index < Tabs.count) {
    current_size = strmid(Tabs.sizes, current_index * 3, (current_index + 1) * 3)
    //msg("Tabs.sizes: " # strmid(Tabs.sizes, current_index * 3, (current_index + 1) * 3))
    current_size = 0 + current_size
    //msg("Tabs.paths: " # Tabs.paths # " sizes_before: " # sizes_before # " current_size: " # current_size)
    current_path = strmid(Tabs.paths, sizes_before, sizes_before + current_size)

    if (current_path == sFile) {
      Tabs.sizes = cat(strmid(
        Tabs.sizes,
        0,
        current_index * 3
      ), strmid(
        Tabs.sizes,
        (current_index + 1) * 3,
        strlen(Tabs.sizes)
      ))

      Tabs.paths = cat(strmid(
        Tabs.paths,
        0,
        sizes_before
      ), strmid(
        Tabs.paths,
        sizes_before + current_size,
        strlen(Tabs.paths)
      ))

      Tabs.count = Tabs.count - 1
      //msg("end Tabs: " # Tabs)
      return nil
    }

    sizes_before = sizes_before + current_size
    current_index = current_index + 1
  }
}
