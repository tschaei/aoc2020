import strutils, sequtils

const input = staticRead("./input")

func toInt(c: char): int =
  result = ord(c) - ord('0')

when isMainModule:
  let lines = input.splitLines()
  var results: seq[int] = @[]
  var resultsP2: seq[int] = @[]
  
  var outputStackP1: seq[int]
  var operatorStackP1: seq[char]
  
  var outputStackP2: seq[int]
  var operatorStackP2: seq[char]
  

  # for line in lines:
  #   var result = 0
  #   var idx = 0
  #   while idx < line.len:
  #     let c = line[idx]
  #     if idx == 0:
  #       result = c.toInt
  #       idx += 1
  #     elif c == ' ':
  #       idx += 1
  #     else:
  #       if line[idx] == '+':
  #         result += line[idx + 2].toInt
  #       else:
  #         result *= line[idx + 2].toInt
  #       idx += 3
  #   results.add(result)
    
  for line in lines:
    for c in line:
      case c:
      of '0'..'9':
        outputStackP1.add(c.toInt)
        outputStackP2.add(c.toInt)
      of '+', '*':
        while operatorStackP1.len > 0 and operatorStackP1[operatorStackP1.high] != '(':
          let operator = operatorStackP1.pop()
          let operand0 = outputStackP1.pop()
          let operand1 = outputStackP1.pop()
          outputStackP1.add(
            if operator == '+':
              operand0 + operand1
            else:
              operand0 * operand1
          )
        operatorStackP1.add(c)
        
        while operatorStackP2.len > 0 and (c == '*' or (c == '+' and operatorStackP2[operatorStackP2.high] == '+')) and operatorStackP2[operatorStackP2.high] != '(':
          let operator = operatorStackP2.pop()
          let operand0 = outputStackP2.pop()
          let operand1 = outputStackP2.pop()
          outputStackP2.add(
            if operator == '+':
              operand0 + operand1
            else:
              operand0 * operand1
          )
        operatorStackP2.add(c)
      of '(':
        operatorStackP1.add(c)
        operatorStackP2.add(c)
      of ')':
        while operatorStackP1[operatorStackP1.high] != '(':
          let operator = operatorStackP1.pop()
          let operand0 = outputStackP1.pop()
          let operand1 = outputStackP1.pop()
          outputStackP1.add(
            if operator == '+':
              operand0 + operand1
            else:
              operand0 * operand1
          )
        discard operatorStackP1.pop()
        while operatorStackP2[operatorStackP2.high] != '(':
          let operator = operatorStackP2.pop()
          let operand0 = outputStackP2.pop()
          let operand1 = outputStackP2.pop()
          outputStackP2.add(
            if operator == '+':
              operand0 + operand1
            else:
              operand0 * operand1
          )
        discard operatorStackP2.pop()
      else:
        discard

    while operatorStackP1.len > 0:
          let operator = operatorStackP1.pop()
          let operand0 = outputStackP1.pop()
          let operand1 = outputStackP1.pop()
          outputStackP1.add(
            if operator == '+':
              operand0 + operand1
            else:
              operand0 * operand1
          )
    results.add(outputStackP1.pop())
    
    while operatorStackP2.len > 0:
          let operator = operatorStackP2.pop()
          let operand0 = outputStackP2.pop()
          let operand1 = outputStackP2.pop()
          outputStackP2.add(
            if operator == '+':
              operand0 + operand1
            else:
              operand0 * operand1
          )
    resultsP2.add(outputStackP2.pop())

  
  let p1 = results.foldl(a + b)
  let p2 = resultsP2.foldl(a + b)
  echo "p1: " & $p1
  echo "p2: " & $p2
        