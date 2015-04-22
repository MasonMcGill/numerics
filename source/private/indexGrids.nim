import abstractGrids
import slices

type IndexGrid*[nDim: static[int]] = object
  size: array[nDim, int]
  typeClassTag_InputGrid*: byte

proc indices*[R](size: array[R, int]): auto =
  ## [doc]
  IndexGrid[size.len](size: size)

proc indices*(grid: SomeGrid): auto =
  ## [doc]
  IndexGrid[grid.size.len](size: grid.size)

proc size*[n](grid: IndexGrid[n]): auto =
  ## [doc]
  grid.size

proc get*[n](grid: IndexGrid[n], indices: array[n, int]): auto =
  ## [doc]
  indices

proc `==`*[n](grid0, grid1: IndexGrid[n]): bool =
  ## [doc]
  abstractGrids.`==`(grid0, grid1)

proc `$`*[n](grid: IndexGrid[n]): string =
  ## [doc]
  abstractGrids.`$`(grid)
