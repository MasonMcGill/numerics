import math
import complex
import abstractGrids
import mapping

proc scalarRe(x: any): auto = x.re
proc scalarIm(x: any): auto = x.im

proc `+.`*(x: InputGrid): auto =
  x.map(`+`)

proc `-.`*(x: InputGrid): auto =
  ## [doc]
  x.map(`-`)

proc `$.`*(x: InputGrid): auto =
  ## [doc]
  x.map(`$`)

proc `<.`*(x: InputGrid): auto =
  ## [doc]
  x.map(`<`)

proc re*(x: InputGrid): auto =
  ## [doc]
  x.map(scalarRe)

proc im*(x: InputGrid): auto =
  ## [doc]
  x.map(scalarIm)

proc abs*(x: InputGrid): auto =
  ## [doc]
  x.map(abs)

proc sqrt*(x: InputGrid): auto =
  ## [doc]
  x.map(sqrt)

proc exp*(x: InputGrid): auto =
  ## [doc]
  x.map(exp)

proc ln*(x: InputGrid): auto =
  ## [doc]
  x.map(ln)

proc log2*(x: InputGrid): auto =
  ## [doc]
  x.map(log2)

proc log10*(x: InputGrid): auto =
  ## [doc]
  x.map(log10)

proc floor*(x: InputGrid): auto =
  ## [doc]
  x.map(floor)

proc ceil*(x: InputGrid): auto =
  ## [doc]
  x.map(ceil)

proc round*(x: InputGrid): auto =
  ## [doc]
  x.map(round)

proc sin*(x: InputGrid): auto =
  ## [doc]
  x.map(sin)

proc cos*(x: InputGrid): auto =
  ## [doc]
  x.map(cos)

proc tan*(x: InputGrid): auto =
  ## [doc]
  x.map(tan)

proc sinh*(x: InputGrid): auto =
  ## [doc]
  x.map(sinh)

proc cosh*(x: InputGrid): auto =
  ## [doc]
  x.map(cosh)

proc tanh*(x: InputGrid): auto =
  ## [doc]
  x.map(tanh)

proc arcsin*(x: InputGrid): auto =
  ## [doc]
  x.map(arcsin)

proc arccos*(x: InputGrid): auto =
  ## [doc]
  x.map(arccos)

proc arctan*(x: InputGrid): auto =
  ## [doc]
  x.map(arctan)
