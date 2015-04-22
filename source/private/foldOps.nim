import abstractGrids
import folding
import zipping

proc sum*(grid: InputGrid, dim: static[int]): auto =
  ## [doc]
  grid.fold(`+`, grid.Element(0), dim)

proc sum*(grid: InputGrid): auto =
  ## [doc]
  grid.fold(`+`, grid.Element(0))

proc product*(grid: InputGrid, dim: static[int]): auto =
  ## [doc]
  grid.fold(`*`, grid.Element(1), dim)

proc product*(grid: InputGrid): auto =
  ## [doc]
  grid.fold(`*`, grid.Element(1))

proc min*(grid: InputGrid, dim: static[int]): auto =
  ## [doc]
  static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
  const init = when grid.Element is SomeOrdinal: high(grid.Element) else: Inf
  grid.fold(system.min, init, dim)

proc min*(grid: InputGrid): auto =
  ## [doc]
  static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
  const init = when grid.Element is SomeOrdinal: high(grid.Element) else: Inf
  grid.fold(system.min, init)

proc max*(grid: InputGrid, dim: static[int]): auto =
  ## [doc]
  static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
  const init = when grid.Element is SomeOrdinal: low(grid.Element) else: NegInf
  grid.fold(system.max, init, dim)

proc max*(grid: InputGrid): auto =
  ## [doc]
  static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
  const init = when grid.Element is SomeOrdinal: low(grid.Element) else: NegInf
  grid.fold(system.max, init)

# proc argmin*(grid: InputGrid, dim: static[int]): auto =
#   static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
#   const init = when grid.Element is SomeOrdinal: high(grid.Element) else: Inf
#   proc kernel(a, b: tuple): auto = if b[0] < a[0]: b[1] else a[1]
#   zip(grid, grid.indices).fold(kernel, dim)
#
# proc argmin*(grid: InputGrid): auto =
#   static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
#   const init = when grid.Element is SomeOrdinal: high(grid.Element) else: Inf
#   proc kernel(a, b: tuple): auto = if b[0] < a[0]: b[1] else a[1]
#   zip(grid, grid.indices).fold(kernel)
#
# proc argmax*(grid: InputGrid, dim: static[int]): auto =
#   static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
#   const init = when grid.Element is SomeOrdinal: low(grid.Element) else: NegInf
#   proc kernel(a, b: tuple): auto = if b[0] > a[0]: b[1] else a[1]
#   zip(grid, grid.indices).fold(kernel, dim)
#
# proc argmax*(grid: InputGrid): auto =
#   static: assert grid.Element is SomeOrdinal or grid.Element is SomeReal
#   const init = when grid.Element is SomeOrdinal: low(grid.Element) else: NegInf
#   proc kernel(a, b: tuple): auto = if b[0] > a[0]: b[1] else a[1]
#   zip(grid, grid.indices).fold(kernel)
