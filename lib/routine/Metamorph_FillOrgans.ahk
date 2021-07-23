; Fill the metamorph panel when it first appears
Metamorph_FillOrgans()
{
  Global FillMetamorph
  H_Cell := (FillMetamorph.Y2 - FillMetamorph.Y1) // 5
  W_Cell := (FillMetamorph.X2 - FillMetamorph.X1) // 6
  yMarker := FillMetamorph.Y1 + ((H_Cell // 3) * 2)
  xMarker := FillMetamorph.X1 + (W_Cell // 2)
  Loop, 5
  {
    yMarker += (A_Index!=1?H_Cell:0)
    CtrlClick(xMarker,yMarker)
  }
  MouseMove % GameW//2,% yMarker + H_Cell // 4
  Return
}
