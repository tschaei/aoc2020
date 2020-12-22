import strutils, sequtils, sugar, strformat

const input = staticRead("./input.txt").splitLines

when isMainModule:
  let departure_time = input[0].parseInt
  let idStrings = input[1].split(",")
  let busIds = collect(newSeq):
    for idx, x in idStrings.pairs:
      if x != "x": (idx, x.parseInt)

  let p1 = busIds.map(proc (busId: (int, int)): (int, int) =
    var cnt = departure_time
    while cnt.mod(busId[1]) != 0:
      cnt += 1
    result = (busId[1], cnt - departure_time)
  ).foldl(if b[1] < a[1]: b else: a)
  
  var part2 = 0
  var inc = busIds[0][1]
  for (offset, time) in busIds[1..^1]:
    while (part2 + offset).mod(time) != 0:
      part2 += inc
    inc *= time

  echo fmt("p1: {p1[0] * p1[1]}")
  echo fmt("p2: {part2}")
