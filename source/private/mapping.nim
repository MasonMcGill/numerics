import complex
import macros
import math
import strutils
import abstractGrids
import denseGrids
import zipping

var exprNodes {.compileTime.} = newSeq[PNimrodNode]()

proc refExpr(exprNode: PNimrodNode): string {.compileTime.} =
  exprNodes.add exprNode
  "expr" & $(exprNodes.len - 1)

proc derefExpr(exprRef: string): PNimrodNode {.compileTime.} =
  exprNodes[parseInt(exprRef[4 .. -1])]

type Mapped*[Input: InputGrid, op: static[string]] = object
  ## [doc]
  input: Input
  typeClassTag_InputGrid*: byte

proc newMapped(input: InputGrid, op: static[string]): auto =
  Mapped[type(input), op](input: input)

macro map*(input: InputGrid, op: expr): expr =
  ## [doc]
  newCall(bindSym"newMapped", input, newLit(refExpr(op)))

proc size*[Input, op](grid: Mapped[Input, op]): auto =
  ## [doc]
  grid.input.size

proc get*[Input, op](grid: Mapped[Input, op], indices: array): auto =
  ## [doc]
  macro buildResult: expr =
    newCall(
      derefExpr(op),
      newCall(
        "get",
        newDotExpr(ident"grid", ident"input"),
        ident"indices"))
  result = buildResult()

# proc view*[Input, op](grid: Mapped[Input, op], slices: array): auto =
#   ## [doc]
#   newMapped(grid.input.view(slices), op)

proc box*[Input, op](grid: Mapped[Input, op], dim: static[int]): auto =
  ## [doc]
  newMapped(grid.input.box(dim), op)

proc unbox*[Input, op](grid: Mapped[Input, op], dim: static[int]): auto =
  ## [doc]
  newMapped(grid.input.unbox(dim), op)

proc `==`*[Input, op](grid0, grid1: Mapped[Input, op]): bool =
  ## [doc]
  abstractGrids.`==`(grid0, grid1)

proc `$`*[Input, op](grid: Mapped[Input, op]): string =
  ## [doc]
  abstractGrids.`$`(grid)

proc scalarRe(x: any): auto = x.re
proc scalarIm(x: any): auto = x.im
proc scalarAbs(x: any): auto = abs(x)
proc scalarSqrt(x: any): auto = sqrt(x)
proc scalarExp(x: any): auto = exp(x)
proc scalarLn(x: any): auto = ln(x)
proc scalarLog2(x: any): auto = log2(x)
proc scalarLog10(x: any): auto = log10(x)
proc scalarFloor(x: any): auto = floor(x)
proc scalarCeil(x: any): auto = ceil(x)
proc scalarRound(x: any): auto = round(x)
proc scalarSin(x: any): auto = sin(x)
proc scalarCos(x: any): auto = cos(x)
proc scalarTan(x: any): auto = tan(x)
proc scalarSinh(x: any): auto = sinh(x)
proc scalarCosh(x: any): auto = cosh(x)
proc scalarTanh(x: any): auto = tanh(x)
proc scalarArcsin(x: any): auto = arcsin(x)
proc scalarArccos(x: any): auto = arccos(x)
proc scalarArctan(x: any): auto = arctan(x)

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

proc `+`*(x: InputGrid): auto =
  x.map(`+`)

proc `+.`*(x: InputGrid): auto =
  x.map(`+`)

proc `-`*(x: InputGrid): auto =
  x.map(`-`)

proc `-.`*(x: InputGrid): auto =
  x.map(`-`)

proc `$.`*(x: InputGrid): auto =
  x.map(`$`)

proc `<.`*(x: InputGrid): auto =
  x.map(`<`)

proc re*(x: InputGrid): auto =
  x.map(scalarRe)

proc im*(x: InputGrid): auto =
  x.map(scalarIm)

proc abs*(x: InputGrid): auto =
  x.map(scalarAbs)

proc sqrt*(x: InputGrid): auto =
  x.map(scalarSqrt)

proc exp*(x: InputGrid): auto =
  x.map(scalarExp)

proc ln*(x: InputGrid): auto =
  x.map(scalarLn)

proc log2*(x: InputGrid): auto =
  x.map(scalarLog2)

proc log10*(x: InputGrid): auto =
  x.map(scalarLog10)

proc floor*(x: InputGrid): auto =
  x.map(scalarFloor)

proc ceil*(x: InputGrid): auto =
  x.map(scalarCeil)

proc round*(x: InputGrid): auto =
  x.map(scalarRound)

proc sin*(x: InputGrid): auto =
  x.map(scalarSin)

proc cos*(x: InputGrid): auto =
  x.map(scalarCos)

proc tan*(x: InputGrid): auto =
  x.map(scalarTan)

proc sinh*(x: InputGrid): auto =
  x.map(scalarSinh)

proc cosh*(x: InputGrid): auto =
  x.map(scalarCosh)

proc tanh*(x: InputGrid): auto =
  x.map(scalarTanh)

proc arcsin*(x: InputGrid): auto =
  x.map(scalarArcsin)

proc arccos*(x: InputGrid): auto =
  x.map(scalarArccos)

proc arctan*(x: InputGrid): auto =
  x.map(scalarArctan)

proc `+`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarAdd)

proc `+.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarAdd)

proc `-`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarSub)

proc `-.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarSub)

proc `*.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarMul)

proc `/.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarDiv)

proc `^.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarPow)

proc `<.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarLt)

proc `>.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarGt)

proc `<=.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarLe)

proc `>=.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarGe)

proc `==.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarEq)

proc `!=.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarNe)

proc `&.`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarCat)

proc `mod`*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarMod)

proc pow*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarPow)

proc arctan2*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarArctan2)

proc min*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarMin)

proc max*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarMax)

proc argmin*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarArgmin)

proc argmax*(x0: InputGrid0, x1: InputGrid1): auto =
  zip(x0, x1).map(scalarArgmax)

proc `+=`*(output: OutputGrid, input: InputGrid) =
  output[] = output +. input

proc `-=`*(output: OutputGrid, input: InputGrid) =
  output[] = output -. input

proc `*=`*(output: OutputGrid, input: InputGrid) =
  output[] = output *. input

proc `/=`*(output: OutputGrid, input: InputGrid) =
  output[] = output /. input

proc `^=`*(output: OutputGrid, input: InputGrid) =
  output[] = output ^. input
