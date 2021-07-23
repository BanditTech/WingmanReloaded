; CoolTime - Return a more accurate MS value - Forbidden function! will cause massive CPU strain
CoolTime() {
  VarSetCapacity(PerformanceCount, 8, 0)
  VarSetCapacity(PerformanceFreq, 8, 0)
  DllCall("QueryPerformanceCounter", "Ptr", &PerformanceCount)
  DllCall("QueryPerformanceFrequency", "Ptr", &PerformanceFreq)
  return NumGet(PerformanceCount, 0, "Int64") / NumGet(PerformanceFreq, 0, "Int64")
}

