import macros
import abstractGrids
import numericsInternals

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
