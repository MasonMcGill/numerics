import complex
import macros
import math
import strutils
import abstractGrids
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

proc view*[Input, op](grid: Mapped[Input, op], slices: array): auto =
  ## [doc]
  newMapped(grid.input.view(slices), op)

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

proc `+.`*(grid: InputGrid): auto =
  proc op(e: any): auto = +e
  grid.map(op)

proc `-.`*(grid: InputGrid): auto =
  proc op(e: any): auto = -e
  grid.map(op)

proc `$.`*(grid: InputGrid): auto =
  proc op(e: any): auto = $e
  grid.map(op)

proc `<.`*(grid: InputGrid): auto =
  proc op(e: any): auto = <e
  grid.map(op)

proc re*(grid: InputGrid): auto =
  proc op(e: any): auto = e.re
  grid.map(op)

proc im*(grid: InputGrid): auto =
  proc op(e: any): auto = e.im
  grid.map(op)

proc abs*(grid: InputGrid): auto =
  proc op(e: any): auto = abs(e)
  grid.map(op)

proc sqrt*(grid: InputGrid): auto =
  proc op(e: any): auto = sqrt(e)
  grid.map(op)

proc exp*(grid: InputGrid): auto =
  proc op(e: any): auto = exp(e)
  grid.map(op)

proc ln*(grid: InputGrid): auto =
  proc op(e: any): auto = ln(e)
  grid.map(op)

proc log2*(grid: InputGrid): auto =
  proc op(e: any): auto = log2(e)
  grid.map(op)

proc log10*(grid: InputGrid): auto =
  proc op(e: any): auto = log10(e)
  grid.map(op)

proc floor*(grid: InputGrid): auto =
  proc op(e: any): auto = floor(e)
  grid.map(op)

proc ceil*(grid: InputGrid): auto =
  proc op(e: any): auto = ceil(e)
  grid.map(op)

proc round*(grid: InputGrid): auto =
  proc op(e: any): auto = round(e)
  grid.map(op)

proc sin*(grid: InputGrid): auto =
  proc op(e: any): auto = sin(e)
  grid.map(op)

proc cos*(grid: InputGrid): auto =
  proc op(e: any): auto = cos(e)
  grid.map(op)

proc tan*(grid: InputGrid): auto =
  proc op(e: any): auto = tan(e)
  grid.map(op)

proc sinh*(grid: InputGrid): auto =
  proc op(e: any): auto = sinh(e)
  grid.map(op)

proc cosh*(grid: InputGrid): auto =
  proc op(e: any): auto = cosh(e)
  grid.map(op)

proc tanh*(grid: InputGrid): auto =
  proc op(e: any): auto = tanh(e)
  grid.map(op)

proc arcsin*(grid: InputGrid): auto =
  proc op(e: any): auto = arcsin(e)
  grid.map(op)

proc arccos*(grid: InputGrid): auto =
  proc op(e: any): auto = arccos(e)
  grid.map(op)

proc arctan*(grid: InputGrid): auto =
  proc op(e: any): auto = arctan(e)
  grid.map(op)

proc `+.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] + e[1]
  zip(grid0, grid1).map(op)

proc `-.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] - e[1]
  zip(grid0, grid1).map(op)

proc `*.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] * e[1]
  zip(grid0, grid1).map(op)

proc `/.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] / e[1]
  zip(grid0, grid1).map(op)

proc `^.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = pow(e[0], e[1])
  zip(grid0, grid1).map(op)

proc `<.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] > e[1]
  zip(grid0, grid1).map(op)

proc `>.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] < e[1]
  zip(grid0, grid1).map(op)

proc `<=.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] >= e[1]
  zip(grid0, grid1).map(op)

proc `>=.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] <= e[1]
  zip(grid0, grid1).map(op)

proc `==.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] == e[1]
  zip(grid0, grid1).map(op)

proc `!=.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] != e[1]
  zip(grid0, grid1).map(op)

proc `&.`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] != e[1]
  zip(grid0, grid1).map(op)

proc `mod`*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = e[0] mod e[1]
  zip(grid0, grid1).map(op)

proc pow*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = pow(e[0], e[1])
  zip(grid0, grid1).map(op)

proc arctan2*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = arctan2(e[0], e[1])
  zip(grid0, grid1).map(op)

proc min*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = min(e[0], e[1])
  zip(grid0, grid1).map(op)

proc max*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = max(e[0], e[1])
  zip(grid0, grid1).map(op)

proc argmin*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = int(e[0] > e[1])
  zip(grid0, grid1).map(op)

proc argmax*(grid0: InputGrid, grid1: InputGrid): auto =
  proc op(e: tuple): auto = int(e[0] <= e[1])
  zip(grid0, grid1).map(op)

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
