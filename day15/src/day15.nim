import tables, strformat, options


proc nth(target: int): int =
  let input = @[0, 6, 1, 7, 2, 19, 20]
  var idx = 0
  var numbers = initTable[int, int]()
  var previous = none[int]()
  
  for turn in 0..<target:
    let number = previous.map(func (p: int): int =
      let prev = numbers.getOrDefault(p, turn)
      numbers[p] = turn
      result = turn - prev
    )
    previous = if idx > input.high: number else: some(input[idx])
    idx += 1
    
  result = previous.get()

when isMainModule:
  echo fmt("p1: {nth(2020)}, p2: {nth(30000000)}")
    

  # var turn = input.len() + 1
  # while turn <= 30000000:
  #   if numbers[number][1] < 0:
  #     number = 0
  #   else:
  #     number = numbers[number][0] - numbers[number][1]
  #   if not numbers.hasKey(number):
  #     numbers[number] = (turn, -1)
  #   else:
  #     numbers[number][1] = numbers[number][0]
  #     numbers[number][0] = turn
  #   if turn == 2020:
  #     p1 = number
  #   turn += 1

  # echo fmt("p1: {p1}, p2: {number}")