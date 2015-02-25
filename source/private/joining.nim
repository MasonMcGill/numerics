import abstractGrids
import denseGrids
import numericsInternals

proc join*(inputs: InputGrid): auto =
  ## [doc]
  type Input = inputs.Element
  static: assert inputs.nDim <= Input.nDim
  var offsets: array[inputs.nDim, seq[int]]
  for dim in 0 .. <inputs.nDim:
    offsets[dim] = @[0]
    for i in 1 .. inputs.size[dim]:
      var indices: inputs.Indices
      indices[dim] = i - 1
      offsets[dim].add(offsets[dim][offsets[dim].high] +
                       inputs.get(indices).size[dim])
  var resultSize: Input.Indices
  for dim in 0 .. <inputs.nDim:
    resultSize[dim] = offsets[dim][offsets[dim].high]
  for dim in inputs.nDim .. <Input.nDim:
    var indices: inputs.Indices
    resultSize[dim] = inputs.get(indices).size[dim]
  result = newDenseGrid(Input.Element, resultSize)
  for i in inputs.indices:
    var offset {.noInit.}: inputs.Indices
    for dim in 0 .. <offset.len:
      offset[dim] = offsets[dim][i[dim]]
    let input = inputs.get(i)
    for j in input.indices:
      var adjustedJ {.noInit.}: Input.Indices
      forStatic dim, 0 .. <inputs.nDim:
        adjustedJ[dim] = offset[dim] + j[dim]
      forStatic dim, inputs.nDim .. <Input.nDim:
        adjustedJ[dim] = j[dim]
      result.put(adjustedJ, input.get(j))

proc `&`*(input0, input1: InputGrid): auto =
  ## [doc]
  @@[input0, input1].join()

proc collect*(input: InputGrid): auto =
  ## [doc]
  result = newDenseGrid(input.Element, input.size)
  for i, e in input:
    result.put(i, e)
