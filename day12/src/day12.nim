import sequtils, sugar, strutils, math, strformat

type Command = tuple[cmd: char, value: int]

const input = staticRead("./input.txt")

proc `+=`(a: var (int, int), b: (int, int)) =
  a[0] += b[0]
  a[1] += b[1]
  
proc `*`(dir: (int, int), f: int): (int, int) =
  (dir[0] * f, dir[1] * f)

proc normalize(dir: var (int, int)) =
  let len_recip = 1.0 / sqrt((dir[0] * dir[0]).float64 +  (dir[1] * dir[1]).float64)
  dir[0] = (dir[0].float64 * len_recip).int
  dir[1] = (dir[1].float64 * len_recip).int
  
proc rotate(dir: var (int, int), deg: int) =
  let cosDeg = cos(deg.toFloat.degToRad)
  let sinDeg = sin(deg.toFloat.degToRad)
  let tmpDir0 = cosDeg * dir[0].toFloat - sinDeg * dir[1].toFloat
  let tmpDir1 = sinDeg * dir[0].toFloat + cosDeg * dir[1].toFloat
  dir[0] = tmpDir0.toInt
  dir[1] = tmpDir1.toInt

when isMainModule:
  let commands: seq[Command] = input
    .splitLines()
    .map(s => (cmd: s[0], value: s[1..^1].parseInt()))

  var position_p1 = (0, 0)
  var direction_p1 = (1, 0)
  
  var position_p2 = (0, 0)
  var waypoint_offset = (10, 1)

  for (cmd, value) in commands:
    case cmd
      of 'F':
        position_p1 += direction_p1 * value
        position_p2 += waypoint_offset * value
      of 'N':
        position_p1 += (0, value)
        waypoint_offset += (0, value)
      of 'S':
        position_p1 += (0, -value)
        waypoint_offset += (0, -value)
      of 'E':
        position_p1 += (value, 0)
        waypoint_offset += (value, 0)
      of 'W':
        position_p1 += (-value, 0)
        waypoint_offset += (-value, 0)
      of 'L':
        direction_p1.rotate(value)
        waypoint_offset.rotate(value)
        direction_p1.normalize()
      of 'R':
        direction_p1.rotate(-value)
        waypoint_offset.rotate(-value)
        direction_p1.normalize()
      else:
        discard

  let p1 = abs(position_p1[0]) + abs(position_p1[1])
  let p2 = abs(position_p2[0]) + abs(position_p2[1])
  echo fmt("p1: {p1}\np2: {p2}")
