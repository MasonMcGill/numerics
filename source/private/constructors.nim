import macros
import math
import abstractGrids
import denseGrids
import indexing
import numericsInternals

proc repeat*[E, R](element: E, size: array[R, int]): auto =
  ## [doc]
  result = newDenseGrid(E, size)
  result[] = element

proc zeros*[R](size: array[R, int]): auto =
  ## [doc]
  newDenseGrid(float, size)

proc zeros*[R](Element: typedesc, size: array[R, int]): auto =
  ## [doc]
  newDenseGrid(Element, size)

proc ones*[R](size: array[R, int]): auto =
  ## [doc]
  repeat(1.0, size)

proc ones*[R](Element: typedesc, size: array[R, int]): auto =
  ## [doc]
  repeat(cast[Element](1), size)

proc falses*[R](size: array[R, int]): auto =
  ## [doc]
  repeat(false, size)

proc trues*[R](size: array[R, int]): auto =
  ## [doc]
  repeat(true, size)

proc rand*[R](size: array[R, int]): auto =
  ## [doc]
  result = newDenseGrid(float, size)
  for i in result.indices:
    result[i] = math.random(1.0)

proc linSpace*(first, last: float, nSamples = 50): DenseGrid[1, float] =
  ## [doc]
  assert nSamples > 1
  result = newDenseGrid(float, [nSamples])
  let step = (last - first) / float(nSamples - 1)
  for i in 0 .. <nSamples:
    result[i] = first + step * float(i)

proc logSpace*(first, last: float, nSamples = 50): DenseGrid[1, float] =
  ## [doc]
  assert nSamples > 1
  result = newDenseGrid(float, [nSamples])
  let step = (last - first) / float(nSamples - 1)
  for i in 0 .. <nSamples:
    result[i] = math.pow(10.0, first + step * float(i))

proc reshape*[R](grid: InputGrid, size: array[R, int]): auto =
  ## [doc]
  result = newDenseGrid(grid.Element, size)
  var data = result.data
  for i in grid.indices:
    data[] = grid[i]
    data += 1
