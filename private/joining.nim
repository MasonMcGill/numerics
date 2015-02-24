#===============================================================================
# Definitions

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

#===============================================================================
# Tests

test "grids.join()":
  block:
    let g0 = @@[0.0]
    let g1 = @@[1.0, 2.0]
    let g2 = @@[3.0, 4.0]
    let g3 = @@[g0, g1, g2]
    assert g3.join() == @@[0.0, 1.0, 2.0, 3.0, 4.0]
  block:
    let g0 = @@[[0, 1]]
    let g1 = @@[[2, 3], [4, 5]]
    let g2 = @@[g0, g1]
    assert g2.join() == @@[[0, 1], [2, 3], [4, 5]]
  block:
    let g0 = @@[[0, 1]]
    let g1 = @@[[2, 3]]
    let g2 = @@[[4, 5]]
    let g3 = @@[[6, 7]]
    let g4 = @@[[g0, g1], [g2, g3]]
    assert g4.join() == @@[[0, 1, 2, 3], [4, 5, 6, 7]]

test "grid0 & grid1":
  assert(@@[0, 1] & @@[2, 3, 4] == @@[0, 1, 2, 3, 4])
  assert(@@[[0], [1]] & @@[[2]] == @@[[0], [1], [2]])
  assert(@@[[0, 1]] & @@[[2, 3]] == @@[[0, 1], [2, 3]])

test "grid.collect()":
  assert((0 .. 3).collect() == @@[0, 1, 2, 3])
  assert(newDenseGrid(int).collect() == newDenseGrid(int))
  assert(@@[[0, 1], [2, 3]].collect() == @@[[0, 1], [2, 3]])
