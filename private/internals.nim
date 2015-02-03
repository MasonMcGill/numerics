import complex
import future
import macros
import math
import sequtils
import strutils

import tuples

#===============================================================================
# Pointer Arithmetic

proc `+=`[E](p: var ptr E, i: int) =
  p = cast[ptr E](cast[int](p) + i * sizeOf(E))

#===============================================================================
# AST Manipulation

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
# Index Parsing/Packaging

proc pack(args: PNimrodNode): PNimrodNode {.compileTime.} =
  result = newNimNode nnkPar
  for i in 0 .. <args.len:
    result.add(newNimNode(nnkExprColonExpr).add(
      ident("field" & $i), args[i]))

proc nSlices(Tup: typedesc[tuple]): int =
  var t: Tup
  const tLen = t.len
  template countSlices(i: static[int]): expr {.genSym.} =
    when i < tLen:
      int(t[i] is Slice[int] or t[i] is StridedSlice[int]) + countSlices(i + 1)
    else:
      0
  countSlices 0

template nSlices(t: tuple): expr =
  const tLen = t.len
  template countSlices(i: static[int]): expr {.genSym.} =
    when i < tLen:
      int(t[i] is Slice[int] or t[i] is StridedSlice[int]) + countSlices(i + 1)
    else:
      0
  countSlices 0

template nSlicesBefore(t: tuple, n: int): expr =
  template countSlices(i: static[int]): expr {.genSym.} =
    when i < n:
      int(t[i] is Slice[int] or t[i] is StridedSlice[int]) + countSlices(i + 1)
    else:
      0
  countSlices 0

template upgradeSlice(i: expr): expr =
  when i is Slice[int]: i.by(1) else: i

#===============================================================================
# Expression Referencing/Dereferencing

var exprNodes {.compileTime.} = newSeq[PNimrodNode]()

# proc refExpr(exprNode: PNimrodNode): string {.compileTime.} =
#   exprNodes.add exprNode
#   "expr" & $(exprNodes.len - 1)

proc derefExpr(exprRef: string): PNimrodNode {.compileTime.} =
  exprNodes[parseInt(exprRef[4 .. -1])]

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
