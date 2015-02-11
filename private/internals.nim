import complex
import future
import macros
import math
import sequtils
import strutils

#===============================================================================
# Constants

const maxNDim = 8
# const maxNZippedGrids = 4

#===============================================================================
# Pointer Arithmetic

proc `+=`[E](p: var ptr E, i: int) =
  p = cast[ptr E](cast[int](p) + i * sizeOf(E))

#===============================================================================
# AST Manipulation

proc newBracket(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkBracket).add(args)

proc newBracketExpr(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkBracketExpr).add(args)

# proc newObjConstr(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
#   newNimNode(nnkObjConstr).add(args)
#
# proc newTypeOfExpr(arg: PNimrodNode): PNimrodNode {.compileTime.} =
#   newNimNode(nnkTypeOfExpr).add(arg)

proc newForStmt(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkForStmt).add(args)

proc newYieldStmt(args: varargs[PNimrodNode]): PNimrodNode {.compileTime.} =
  newNimNode(nnkYieldStmt).add(args)

#===============================================================================
# Compile-Time Iteration

template iterateFor(a, b: static[int]): stmt =
  when a <= b:
    iteration a
    iterateFor a + 1, b

template forStatic(index: expr, slice: Slice[int], pred: stmt):
                    stmt {.immediate.} =
  const a = slice.a
  const b = slice.b
  when a <= b:
    template iteration(i: int): stmt =
      block:
        const index = i
        pred
    iterateFor a, b

proc toSeq(slice: Slice[int]): seq[int] =
  result = newSeq[int]()
  for i in slice.a .. slice.b:
    result.add i

# template staticMap(slice: Slice[int], pred: expr): expr =
#   ## [doc]
#   const a = slice.a
#   const b = slice.b
#   macro buildResult(predExpr: expr): expr {.genSym.} =
#     result = newPar()
#     for i in a .. b:
#       result.add(newColonExpr(
#         ident("field" & $(i - a)), newCall(predExpr, newLit(i))))
#   buildResult pred

#===============================================================================
# Index Parsing/Packaging

# proc pack(args: PNimrodNode): PNimrodNode {.compileTime.} =
#   result = newNimNode nnkPar
#   for i in 0 .. <args.len:
#     result.add(newNimNode(nnkExprColonExpr).add(
#       ident("field" & $i), args[i]))
#
# proc nSlices(Tup: typedesc[tuple]): int =
#   var t: Tup
#   const tLen = t.len
#   template countSlices(i: static[int]): expr {.genSym.} =
#     when i < tLen:
#       int(t[i] is Slice[int] or t[i] is StridedSlice[int]) + countSlices(i + 1)
#     else:
#       0
#   countSlices 0
#
# template nSlices(t: tuple): expr =
#   const tLen = t.len
#   template countSlices(i: static[int]): expr {.genSym.} =
#     when i < tLen:
#       int(t[i] is Slice[int] or t[i] is StridedSlice[int]) + countSlices(i + 1)
#     else:
#       0
#   countSlices 0
#
# template nSlicesBefore(t: tuple, n: int): expr =
#   template countSlices(i: static[int]): expr {.genSym.} =
#     when i < n:
#       int(t[i] is Slice[int] or t[i] is StridedSlice[int]) + countSlices(i + 1)
#     else:
#       0
#   countSlices 0
#
# template upgradeSlice(i: expr): expr =
#   when i is Slice[int]: i.by(1) else: i

#===============================================================================
# Expression Referencing/Dereferencing

# var exprNodes {.compileTime.} = newSeq[PNimrodNode]()
#
# proc refExpr(exprNode: PNimrodNode): string {.compileTime.} =
#   exprNodes.add exprNode
#   "expr" & $(exprNodes.len - 1)
#
# proc derefExpr(exprRef: string): PNimrodNode {.compileTime.} =
#   exprNodes[parseInt(exprRef[4 .. -1])]

#===============================================================================
# Test Construction

template test(name: expr, action: stmt): stmt {.immediate.} =
  when isMainModule and not defined(release):
    try:
      block: action
      echo "Test succeeded: \"", $name, "\"."
    except AssertionError:
      echo "Test failed: \"", $name, "\"."
      stderr.write(getCurrentException().getStackTrace())

#===============================================================================
# Test Grids

type TestInputGrid3x4 = object
  typeClassTag_InputGrid: byte

proc newTestInputGrid3x4: TestInputGrid3x4 =
  discard

proc size(grid: TestInputGrid3x4): array[2, int] =
  [3, 4]

proc get(grid: TestInputGrid3x4, indices: array[2, int]): array[2, string] =
  [$indices[0], $indices[1]]

type TestOutputGrid3x4 = object
  record: ref seq[string]
  typeClassTag_OutputGrid: byte

proc newTestOutputGrid3x4: TestOutputGrid3x4 =
  result.record = new(seq[string])
  result.record[] = newSeq[string]()

proc size(grid: TestOutputGrid3x4): array[2, int] =
  [3, 4]

proc put(grid: TestOutputGrid3x4, indices: array[2, int], value: int) =
  grid.record[].add("[" & $indices[0] & ", " & $indices[1] & "]: " & $value)
