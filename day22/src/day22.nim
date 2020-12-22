import strutils, sequtils, deques, algorithm, sugar, sets, strformat

const input = staticRead("./input")

type
  Player = enum
    pOne,
    pTwo
  GameResult = tuple[winner: Player, score: int]

proc sumPoints(acc, current: int, pointsMultiplier: var int): int =
    result = acc + (current * pointsMultiplier)
    pointsMultiplier += 1

proc calculateScore(deck: Deque[int]): int =
  var pointsMultiplier = 2
  result = toSeq(deck).reversed().foldl(sumPoints(a, b, pointsMultiplier))

func recursiveCombat(decks: var (Deque[int], Deque[int])): GameResult =  
  var decksHistory = initHashSet[(seq[int], seq[int])]()
  while decks[0].len > 0 and decks[1].len > 0:
    # case 1: configuration was seen before. P1 wins instantly
    let decksForHistory = (toSeq(decks[0]), toSeq(decks[1]))
    if decksHistory.containsOrIncl(decksForHistory):
      return (pOne, decks[0].calculateScore())

    let cardP1 = decks[0].popFirst()
    let cardP2 = decks[1].popFirst()
    
    # case 2: both players have enough cards remaining, play recursive game to determine winner of round
    let p1Wins = if decks[0].len >= cardP1 and decks[1].len >= cardP2:
      var subDecks = (toSeq(decks[0])[0..<cardP1].toDeque, toSeq(decks[1])[0..<cardP2].toDeque)
      recursiveCombat(subDecks).winner == pOne
    else:
      # case 3: regular round
      cardP1 > cardP2
    if p1Wins:
      decks[0].addLast(cardP1)
      decks[0].addLast(cardP2)
    else:
      decks[1].addLast(cardP2)
      decks[1].addLast(cardP1)
  result = if decks[0].len > 0: (pOne, decks[0].calculateScore()) else: (pTwo, decks[1].calculateScore())

when isMainModule:
  var decks = input
    .split("\n\n")
    .map(
      func (blk: string): Deque[int] =
        for n in blk.splitLines()[1..^1].map(parseInt):
          result.addLast(n)
    )
  var decksP2 = (decks[0], decks[1])

  while decks[0].len > 0 and decks[1].len > 0:
    let cardP1 = decks[0].popFirst()
    let cardP2 = decks[1].popFirst()
    
    if cardP1 > cardP2:
      decks[0].addLast(cardP1)
      decks[0].addLast(cardP2)
    else:
      decks[1].addLast(cardP2)
      decks[1].addLast(cardP1)
  
  let p1 = decks.filter(d => d.len > 0)[0].calculateScore()
  let p2 = recursiveCombat(decksP2).score
  echo fmt("p1: {p1} p2: {p2}")