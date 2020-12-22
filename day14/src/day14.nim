import regex, strutils, sequtils, bitops, tables, strformat, algorithm, sugar, times

type
  InstructionKind = enum
    ikMask,
    ikMemSet
  Instruction = ref object
    case kind: InstructionKind
    of ikMask:
      ones, zeroes: int64
      bits: seq[seq[char]]
    of ikMemSet: address, value: int64


const input = staticRead("./input")
  .splitLines()
  
func toString(chars: seq[char]): string =
  result = newStringOfCap(chars.len())
  for c in chars:
    result.add(c)


func generateAddresses(address: int64, mask: seq[seq[char]]): seq[int] =
  let address: seq[seq[char]] = collect(newSeq):
    for idx, c in address.toBin(36).pairs:
      if mask[idx].len() == 2:
        mask[idx]
      elif mask[idx][0] == '1':
        @['1']
      else:
        @[c]
  result = address.product().map(s => s.toString().parseBinInt)

when isMainModule:
  let start = getTime()
  let instructions = input.map(
    proc (l: string): Instruction =
      if l.startsWith("mask ="):
        let mask = l.split("=")[1][1..^1]
        var ones = 0
        var zeroes = 0
        var bits: seq[seq[char]] = collect(newSeq):
          for _ in mask:
            newSeq[char]()
        for idx, c in mask.pairs:
          let bit_idx = mask.high - idx
          case c
          of '1':
            ones = ones or (1 shl bit_idx)
            bits[idx].add('1')
          of '0':
            zeroes = zeroes or (1 shl bit_idx)
            bits[idx].add('0')
          else:
            bits[idx].add('0')
            bits[idx].add('1')
        result = Instruction(kind: ikMask, ones: ones, zeroes: zeroes, bits: bits)
      else:
        match l, rex"mem\[(\d+)] = (\d+)":
          result = Instruction(kind: ikMemSet, address: matches[0].parseInt, value: matches[1].parseInt)
  )
  var positions: Table[int64, int64] = initTable[int64, int64]()
  var mask: Instruction
  for instruction in instructions:
    case instruction.kind
    of ikMask:
      mask = instruction
    of ikMemSet:
      var val = instruction.value
      val.setMask(mask.ones)
      val.clearMask(mask.zeroes)
      positions[instruction.address] = val

  
  let p1 = toSeq(positions.values).foldl(a + b)
  
  positions.clear()
  for instruction in instructions:
    case instruction.kind
    of ikMask:
      mask = instruction
    of ikMemSet:
      let addresses = generateAddresses(instruction.address, mask.bits)
      for address in addresses:
        positions[address] = instruction.value
  
  let p2 = toSeq(positions.values).foldl(a + b)

  let endTime = getTime()

  echo fmt("p1: {p1}\np2: {p2}\ntime: {(endTime - start).inMilliseconds()}ms")
