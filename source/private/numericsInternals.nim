import macros

#===============================================================================
# Constants

const maxNDim* = 8
const maxNZippedGrids* = 4

const emptyIntArray* = (block: (var x: array[0, int]; x))

#===============================================================================
# AST Manipulation

proc newBracket*(args: varargs[NimNode]): NimNode {.compileTime.} =
  newNimNode(nnkBracket).add(args)

proc newBracketExpr*(args: varargs[NimNode]): NimNode {.compileTime.} =
  newNimNode(nnkBracketExpr).add(args)

proc newObjConstr*(args: varargs[NimNode]): NimNode {.compileTime.} =
  newNimNode(nnkObjConstr).add(args)

proc newTypeOfExpr*(arg: NimNode): NimNode {.compileTime.} =
  newNimNode(nnkTypeOfExpr).add(arg)

proc newForStmt*(args: varargs[NimNode]): NimNode {.compileTime.} =
  newNimNode(nnkForStmt).add(args)

proc newYieldStmt*(args: varargs[NimNode]): NimNode {.compileTime.} =
  newNimNode(nnkYieldStmt).add(args)

#===============================================================================
# Compile-Time Iteration

template forStatic*(index: expr, slice: Slice[int], predicate: stmt):
                    stmt {.immediate.} =
  const a = slice.a
  const b = slice.b
  when a <= b:
    template iterateStartingFrom(i: int): stmt {.dirty.} =
      when i <= b:
        iteration i
        iterateStartingFrom i + 1
    template iteration(i: int) {.dirty.} =
      block:
        const index = i
        predicate
    iterateStartingFrom a

proc toSeq*(slice: Slice[int]): seq[int] =
  result = newSeq[int]()
  for i in slice.a .. slice.b:
    result.add i
