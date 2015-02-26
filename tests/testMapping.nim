import unittest
import numerics

# test "grid.map(op)":
#   block:
#     let grid = @@[0, 1, 2].map((e: int) => e + 1)
#     assert(grid.size == (field0: 3))
#     assert(grid[0] == 1)
#     assert(grid[1] == 2)
#     assert(grid[2] == 3)
#   block:
#     let grid = @@[[0.0, 1.0, 2.0], [3.0, 4.0, 5.0]].map((e: float) => $e)
#     assert(grid.size == (2, 3))
#     assert(grid[0, 0] == "0.0")
#     assert(grid[0, 1] == "1.0")
#     assert(grid[0, 2] == "2.0")
#     assert(grid[1, 0] == "3.0")
#     assert(grid[1, 1] == "4.0")
#     assert(grid[1, 2] == "5.0")
#   block:
#     let grid = @@[[["0"]], [["1"]], [["2"]]].map((e: string) => e & "!")
#     assert(grid.size == (3, 1, 1))
#     assert(grid[0, 0, 0] == "0!")
#     assert(grid[1, 0, 0] == "1!")
#     assert(grid[2, 0, 0] == "2!")

# test "grid0 +. grid1":
#   let a = @@[[0.0, 1.0], [2.0, 3.0]]
#   let b = @@[[0.0, 2.0], [4.0, 6.0]]
#   static: echo "here"
#   let c = cos((sin(3.0 *. a +. b) +. 2.0) *. 3.0)
#   static: echo "there"
#   echo(@@c)
