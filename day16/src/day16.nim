import strutils, sequtils, regex, sugar, strformat, times, algorithm

type
  Field = object
    name: string
    validRanges: ((int, int), (int, int))


const input = staticRead("./input")

when isMainModule:
  let startTime = getTime()
  let input_parts: seq[seq[string]] = input.split("\n\n").map(blk => blk.split("\n"))
  let fields = input_parts[0].map(func (line: string): Field =
    match line, rex"(\w+ ?\w+?): (\d+)-(\d+) or (\d+)-(\d+)":
      result = Field(
        name: matches[0], 
        validRanges: (
          (matches[1].parseInt, matches[2].parseInt),
          (matches[3].parseInt, matches[4].parseInt)
        )
      )
  )

  let myTicket = input_parts[1][1..^1]
    .map(line => line.split(",").map(parseInt))[0]
  let nearbyTickets = input_parts[2][1..^1]
    .map(line => line.split(",").map(parseInt))

  var p1 = 0
  var validTickets: seq[seq[int]] = @[]
  for numbers in nearbyTickets:
    var numbers_valid = true
    for n in numbers:
      var nValid = false
      for f in fields:
        if n in f.validRanges[0][0]..f.validRanges[0][1] or n in f.validRanges[1][0]..f.validRanges[1][1]:
          nValid = true
      if not nValid:
        p1 += n
        numbers_valid = false
    if numbers_valid:
      validTickets.add(numbers)

  var candidates: seq[seq[string]] = newSeqWith(myTicket.len(), newSeq[string]())
  for idx, number in myTicket.pairs:
    var numberRange = @[number] 
    for numbers in validTickets:
      numberRange.add(numbers[idx])

    for f in fields:
      if numberRange.all(func (n: int): bool =
        n in f.validRanges[0][0]..f.validRanges[0][1] or
        n in f.validRanges[1][0]..f.validRanges[1][1]
      ):
        candidates[idx].add(f.name)

  while candidates.map(c => c.len).any(l => l > 1):
    let knownFields: seq[(int, string)] = collect(newSeq):
      for idx, c in candidates.pairs:
        if c.len == 1:
          (idx, c[0])
    for idx, c in candidates.mpairs:
      for f in knownFields:
        if idx == f[0]:
          continue
        let fieldIdx = c.find(f[1])
        if fieldIdx >= 0:
          c.del(fieldIdx)
  
  var part2 = 1
  for idx, c in candidates.pairs:
    if c[0].startsWith("departure"):
      part2 *= myTicket[idx]
  let endTime = getTime()  
  echo fmt("p1: {p1}\np2: {part2}\ntime: {(endTime - startTime).inMicroseconds()}us")