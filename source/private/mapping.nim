#===============================================================================
# Definitions

type Mapped*[Input: InputGrid, op: static[string]] = object
  input: Input
  typeClassTag_InputGrid: type(())

proc newMapped(input: InputGrid, op: static[string]): auto =
  Mapped[type(input), op](input: input)

template map*(input: InputGrid, op: expr): expr {.dirty.} =
  block:
    proc doOp(x: any): auto = op(x)
    macro buildResult(inputExpr: expr): expr =
      newCall(bindSym"newMapped", inputExpr, newLit(refExpr(bindSym"doOp")))
    buildResult(input)

proc size*[Input, op](grid: Mapped[Input, op]): auto =
  grid.input.size

proc get*[Input, op](grid: Mapped[Input, op], indices: tuple): auto =
  macro buildResult: expr =
    newCall(
      derefExpr(op),
      newCall(
        "get",
        newDotExpr(ident"grid", ident"input"),
        ident"indices"))
  result = buildResult()

proc view*[Input, op](grid: Mapped[Input, op], indices: tuple): auto =
  newMapped(grid.input.view(indices), op)

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

proc `+.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] + e[1]
  zip(grid0, grid1).map(op)

proc `-.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] - e[1]
  zip(grid0, grid1).map(op)

proc `*.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] * e[1]
  zip(grid0, grid1).map(op)

proc `/.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] / e[1]
  zip(grid0, grid1).map(op)

proc `^.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = pow(e[0], e[1])
  zip(grid0, grid1).map(op)

proc `<.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] > e[1]
  zip(grid0, grid1).map(op)

proc `>.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] < e[1]
  zip(grid0, grid1).map(op)

proc `<=.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] >= e[1]
  zip(grid0, grid1).map(op)

proc `>=.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] <= e[1]
  zip(grid0, grid1).map(op)

proc `==.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] == e[1]
  zip(grid0, grid1).map(op)

proc `!=.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] != e[1]
  zip(grid0, grid1).map(op)

proc `&.`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] != e[1]
  zip(grid0, grid1).map(op)

proc `mod`*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = e[0] mod e[1]
  zip(grid0, grid1).map(op)

proc pow*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = pow(e[0], e[1])
  zip(grid0, grid1).map(op)

proc arctan2*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = arctan2(e[0], e[1])
  zip(grid0, grid1).map(op)

proc min*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = min(e[0], e[1])
  zip(grid0, grid1).map(op)

proc max*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = max(e[0], e[1])
  zip(grid0, grid1).map(op)

proc argmin*(grid0: InputGrid0, grid1: InputGrid1): auto =
  proc op(e: tuple): auto = int(e[0] > e[1])
  zip(grid0, grid1).map(op)

proc argmax*(grid0: InputGrid0, grid1: InputGrid1): auto =
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

#===============================================================================
# Tests

# test "grid.map(op)":
#   block:
#     let grid = @@[0, 1, 2].map((e: int) => e + 1)
#     assert(grid.size == (field0: 3))
#     assert(grid[0] == 1)
#     assert(grid[1] == 2)
#     assert(grid[2] == 3)
#   block:
#     let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]].map((e: float) => $e)
#     assert(grid.size == (2, 3))
#     assert(grid[0, 0] == "0.0")
#     assert(grid[0, 1] == "1.0")
#     assert(grid[0, 2] == "2.0")
#     assert(grid[1, 0] == "3.0")
#     assert(grid[1, 1] == "4.0")
#     assert(grid[1, 2] == "5.0")
#   block:
#     let grid = @@[[["0"]], [["1"]], [["2"]]].map((e: string) => e & "!")
#     assert(grid.size == (3, 1, 1))
#     assert(grid[0, 0, 0] == "0!")
#     assert(grid[1, 0, 0] == "1!")
#     assert(grid[2, 0, 0] == "2!")

# test "grid0 +. grid1":
#   let a = @@[[0.0, 1.0], [2.0, 3.0]]
#   let b = @@[[0.0, 2.0], [4.0, 6.0]]
#   static: echo "here"
#   let c = cos((sin(3.0 *. a +. b) +. 2.0) *. 3.0)
#   static: echo "there"
#   echo(@@c)
