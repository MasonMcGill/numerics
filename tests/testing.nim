import numerics

template test(name: expr, action: stmt): stmt {.immediate.} =
  when isMainModule and not defined(release):
    try:
      block: action
      echo "Test succeeded: \"", $name, "\"."
    except AssertionError:
      echo "Test failed: \"", $name, "\"."
      stderr.write(getCurrentException().getStackTrace())

const emptyIntArray = (block: (var x: array[0, int]; x))
const emptySliceArray = (block: (var x: array[0, StridedSlice[int]]; x))

type TestInputGrid2D = object
  size: array[2, int]
  typeClassTag_InputGrid: byte

proc newTestInputGrid2D(size0, size1: int): TestInputGrid2D =
  TestInputGrid2D(size: [size0, size1])

proc get(grid: TestInputGrid2D, indices: array[2, int]): string =
  $indices[0] & "," & $indices[1]

type TestInputGrid3D = object
  size: array[3, int]
  typeClassTag_InputGrid: byte

proc newTestInputGrid3D(size0, size1, size2: int): TestInputGrid3D =
  TestInputGrid3D(size: [size0, size1, size2])

proc get(grid: TestInputGrid3D, indices: array[3, int]): string =
  $indices[0] & "," & $indices[1] & "," & $indices[2]

type TestOutputGrid2D = object
  size: array[2, int]
  record: ref seq[string]
  typeClassTag_OutputGrid: byte

proc newTestOutputGrid2D(size0, size1: int): TestOutputGrid2D =
  result.size = [size0, size1]
  result.record = new(seq[string])
  result.record[] = newSeq[string]()

proc put(grid: TestOutputGrid2D, indices: array[2, int], value: int) =
  grid.record[].add($indices[0] & "," & $indices[1] & " -> " & $value)

type TestOutputGrid3D = object
  size: array[3, int]
  record: ref seq[string]
  typeClassTag_OutputGrid: byte

proc newTestOutputGrid3D(size0, size1, size2: int): TestOutputGrid3D =
  result.size = [size0, size1, size2]
  result.record = new(seq[string])
  result.record[] = newSeq[string]()

proc put(grid: TestOutputGrid3D, indices: array[3, int], value: int) =
  grid.record[].add($indices[0] & "," & $indices[1] & "," & $indices[2] &
                    " -> " & $value)
