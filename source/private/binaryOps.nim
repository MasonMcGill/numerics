import math
import complex
import abstractGrids
import mapping
import zipping

proc scalarAdd(x: tuple): auto = x[0] + x[1]
proc scalarSub(x: tuple): auto = x[0] - x[1]
proc scalarMul(x: tuple): auto = x[0] * x[1]
proc scalarDiv(x: tuple): auto = x[0] / x[1]
proc scalarPow(x: tuple): auto = pow(x[0], x[1])
proc scalarLt(x: tuple): auto = x[0] < x[1]
proc scalarGt(x: tuple): auto = x[0] > x[1]
proc scalarLe(x: tuple): auto = x[0] <= x[1]
proc scalarGe(x: tuple): auto = x[0] >= x[1]
proc scalarEq(x: tuple): auto = x[0] == x[1]
proc scalarNe(x: tuple): auto = x[0] != x[1]
proc scalarCat(x: tuple): auto = x[0] & x[1]
proc scalarMod(x: tuple): auto = x[0] mod x[1]
proc scalarArctan2(x: tuple): auto = arctan2(x[0], x[1])
proc scalarMin(x: tuple): auto = min(x[0], x[1])
proc scalarMax(x: tuple): auto = max(x[0], x[1])
proc scalarArgmin(x: tuple): auto = int(x[0] > x[1])
proc scalarArgmax(x: tuple): auto = int(x[0] <= x[1])

proc `+.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarAdd)

proc `-.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarSub)

proc `*.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarMul)

proc `/.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarDiv)

proc `^.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarPow)

proc `<.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarLt)

proc `>.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarGt)

proc `<=.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarLe)

proc `>=.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarGe)

proc `==.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarEq)

proc `!=.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarNe)

proc `&.`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarCat)

proc `mod`*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarMod)

proc pow*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarPow)

proc arctan2*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarArctan2)

proc min*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarMin)

proc max*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarMax)

proc argmin*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarArgmin)

proc argmax*(x0: InputGrid0, x1: InputGrid1): auto =
  ## [doc]
  zip(x0, x1).map(scalarArgmax)
