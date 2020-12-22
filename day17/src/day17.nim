import strutils, sets, sequtils, algorithm, sugar, times, tables

const input = staticRead("./input")


func areNeighbours(p0, p1: (int, int, int)): bool {. inline .} =
  (not (p0[0] == p1[0] and p0[1] == p1[1] and p0[2] == p1[2])) and (p0[0] - p1[0]).abs <= 1 and (p0[1] - p1[1]).abs <= 1 and (p0[2] - p1[2]).abs <= 1
  
func areNeighbours(p0, p1: (int, int, int, int)): bool {. inline .} =
  (not (p0[0] == p1[0] and p0[1] == p1[1] and p0[2] == p1[2] and p0[3] == p1[3])) and (p0[0] - p1[0]).abs <= 1 and (p0[1] - p1[1]).abs <= 1 and (p0[2] - p1[2]).abs <= 1 and (p0[3] - p1[3]).abs <= 1

when isMainModule:
  let start = getTime()
  let lines = input.splitLines()
  var currentActiveP1 = initHashSet[(int, int, int)]()
  var previousActiveP1 = initHashSet[(int, int, int)]()
  var inactiveP1 = initCountTable[(int, int, int)]()

  var currentActiveP2 = initHashSet[(int, int, int, int)]()
  var previousActiveP2 = initHashSet[(int, int, int, int)]()
  var inactiveP2 = initCountTable[(int, int, int, int)]()
  
  for y, row in lines.pairs:
    for x, col in toSeq(row.items).pairs:
      if col == '#':
        previousActiveP1.incl((x, y, 1))
        previousActiveP2.incl((x, y, 1, 1))

  for _ in 0..<6:
    for p in previousActiveP1:
      let activeNeighbours = toSeq(previousActiveP1.items).filter(pn => areNeighbours(p, pn))
      if activeNeighbours.len >= 2 and activeNeighbours.len <= 3:
        currentActiveP1.incl(p)
      let inactiveNeighbours = @[@[p[0] - 1, p[0], p[0] + 1], @[p[1] - 1, p[1], p[1] + 1], @[p[2] - 1, p[2], p[2] + 1]].product().filter(pn => not previousActiveP1.contains((pn[0], pn[1], pn[2]))).map(pn => (pn[0], pn[1], pn[2]))
      for pn in inactiveNeighbours:
        inactiveP1.inc(pn)  

    for pn, activeNeighbours in inactiveP1.pairs:
      if activeNeighbours == 3:
        currentActiveP1.incl(pn)
    swap(previousActiveP1, currentActiveP1)
    currentActiveP1.clear()
    inactiveP1.clear()

    for p in previousActiveP2:
      let activeNeighbours = toSeq(previousActiveP2.items).filter(pn => areNeighbours(p, pn))
      if activeNeighbours.len >= 2 and activeNeighbours.len <= 3:
        currentActiveP2.incl(p)
      let inactiveNeighbours = @[@[p[0] - 1, p[0], p[0] + 1], @[p[1] - 1, p[1], p[1] + 1], @[p[2] - 1, p[2], p[2] + 1], @[p[3] - 1, p[3], p[3] + 1]].product().filter(pn => not previousActiveP2.contains((pn[0], pn[1], pn[2], pn[3]))).map(pn => (pn[0], pn[1], pn[2], pn[3]))
      for pn in inactiveNeighbours:
        inactiveP2.inc(pn)  

    for pn, activeNeighbours in inactiveP2.pairs:
      if activeNeighbours == 3:
        currentActiveP2.incl(pn)

    swap(previousActiveP2, currentActiveP2)
    currentActiveP2.clear()
    inactiveP2.clear()

  let p1 = previousActiveP1.len()
  let p2 = previousActiveP2.len()
  let endTime = getTime()
  echo "p1: " & $p1
  echo "p2: " & $p2
  echo "time: " & $(endTime - start).inMilliseconds & "ms"