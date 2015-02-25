import macros

#===============================================================================
# Constants

const maxNDim* = 8
const maxNZippedGrids* = 4

const emptyIntArray* = (block: (var x: array[0, int]; x))

#===============================================================================
# AST Manipulation

proc newBracket*(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkBracket).add(args)

proc newBracketExpr*(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkBracketExpr).add(args)

proc newObjConstr*(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkObjConstr).add(args)

proc newTypeOfExpr*(arg: PNimrodNode): PNimrodNode {.compileTime.} =
  newNimNode(nnkTypeOfExpr).add(arg)

proc newForStmt*(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkForStmt).add(args)

proc newYieldStmt*(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkYieldStmt).add(args)

#===============================================================================
# Compile-Time Iteration

template iterateFor*(a, b: static[int]): stmt =
  when a <= b:
    iteration a
    iterateFor a + 1, b

template forStatic*(index: expr, slice: Slice[int], pred: stmt):
                    stmt {.immediate.} =
  const a = slice.a
  const b = slice.b
  when a <= b:
    template iteration(i: int): stmt =
      block:
        const index = i
        pred
    iterateFor a, b

proc toSeq*(slice: Slice[int]): seq[int] =
  result = newSeq[int]()
  for i in slice.a .. slice.b:
    result.add i
