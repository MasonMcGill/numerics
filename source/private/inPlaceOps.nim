import abstractGrids
import binaryOps

proc `+=`*(output: OutputGrid, input: InputGrid) =
  ## [doc]
  output[] = output +. input

proc `-=`*(output: OutputGrid, input: InputGrid) =
  ## [doc]
  output[] = output -. input

proc `*=`*(output: OutputGrid, input: InputGrid) =
  ## [doc]
  output[] = output *. input

proc `/=`*(output: OutputGrid, input: InputGrid) =
  ## [doc]
  output[] = output /. input

proc `^=`*(output: OutputGrid, input: InputGrid) =
  ## [doc]
  output[] = output ^. input
