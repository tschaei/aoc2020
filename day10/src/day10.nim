import sequtils, strutils, algorithm

const input = staticRead("./input.txt")

template fold_left[T, U](sequence: iterator): untyped =
  discard

proc part1(jolts: seq[uint]): uint =
  jolts.foldl(case b:
    of 1:
      (a[0] + 1, a[1])
    of 3:
      (a[0], a[1] + 1)
    else:
      a
  )

var jolts = input.splitLines().map(parseUInt)
jolts.add(0)
jolts.sort()
jolts.add(jolts[jolts.high] + 3)