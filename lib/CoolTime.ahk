; CoolTime - Return a more accurate MS value - Forbidden function! will cause massive CPU strain
CoolTime() {
  PerformanceCount := Buffer(8, 0)
  PerformanceFreq := Buffer(8, 0)
  DllCall("QueryPerformanceCounter", "Ptr", PerformanceCount)
  DllCall("QueryPerformanceFrequency", "Ptr", PerformanceFreq)
  return NumGet(PerformanceCount, 0, "Int64") / NumGet(PerformanceFreq, 0, "Int64")
}

