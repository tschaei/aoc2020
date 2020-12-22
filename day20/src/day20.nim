import strutils, tables, sequtils, sugar, strformat, algorithm

const input = staticRead("./input")

type
  Tile = ref object
    id: int
    top, left, right, bottom: seq[bool]
    neighbours: Neighbours
  Neighbours = object
    top, left, right, bottom: SharedEdge
  SharedEdge = ref object
    neighbourId: int
    tileEdge, neighbourEdge: EdgeDirection
    reversed: bool
  EdgeDirection = enum
    edTop,
    edLeft,
    edRight,
    edBottom
  TileP2 = object
    id: int
    top, left, right, bottom: seq[bool]
    data: seq[seq[bool]]
    neighbours: seq[TileP2]
  Direction = enum
    dUp,
    dLeft,
    dRight,
    dDown
  Dy = distinct int
  Dx = distinct int

proc `<`(dy: Dy, v: int): bool {. borrow .}
proc `<`(dx: Dx, v: int): bool {. borrow .}
proc `<`(v: int, dy: Dy): bool {. borrow .}
proc `<`(v: int, dx: Dx): bool {. borrow .}
proc `==`(dx: Dx, v: int): bool {. borrow .}
proc `+`(dy: Dy, v: Dy): Dy {. borrow .}
proc `+`(i: int, dy: Dy): Dy = i.Dy + dy
proc `+=`(dy: var Dy, v: Dy) {. borrow .}
proc `+=`(dy: var Dy, v: int) =
  dy = dy + v.Dy
proc `+`(dx: Dx, v: Dx): Dx {. borrow .}
proc `+`(i: int, dx: Dx): Dx = i.Dx + dx
proc `+=`(dx: var Dx, v: Dx) {. borrow .}
proc `+=`(dx: var Dx, v: int) =
  dx = dx + v.Dx

func toDirection(dy: Dy): EdgeDirection =
  result = if dy < 0: edTop else: edBottom

func toDirection(dx: Dx): EdgeDirection =
  result = if dx < 0: edLeft else: edRight

func `$`(se: SharedEdge): string =
  if se == nil:
    result = "nil"
  else:
    result = fmt("{{ neighbourId: {se.neighbourId}, tileEdge: {se.tileEdge}, neighbourEdge: {se.neighbourEdge}, reversed: {se.reversed} }}")

func `$`(n: Neighbours): string =
  result = fmt("{{ top: {n.top}, left: {n.left}, right: {n.right}, bottom: {n.bottom} }}")

func `$`(t: Tile): string =
  result = fmt("{{\n  id: {t.id},\n  neighbours: {t.neighbours}\n}}")

func toSeq(n: Neighbours): seq[int] =
  if n.top != nil:
    result.add(n.top.neighbourId)
  if n.left != nil:
    result.add(n.left.neighbourId)
  if n.bottom != nil:
    result.add(n.bottom.neighbourId)
  if n.right != nil:
    result.add(n.right.neighbourId)


func isOpposite(d1, d2: EdgeDirection): bool =
  if d1 == edTop:
    result = d2 == edBottom
  elif d1 == edLeft:
    result = d2 == edRight
  elif d1 == edBottom:
    result = d2 == edTop
  elif d1 == edRight:
    result = d2 == edLeft

func getSharedEdge[T](t0, t1: T, edgeDirection: EdgeDirection): SharedEdge =
    let candidates = {
      edTop: t1.top,
      edBottom: t1.bottom,
      edLeft: t1.left,
      edRight: t1.right,
    }.toTable
    
    debugEcho fmt("edges {t0.id}:\n{t0.top}\n{t0.left}\n{t0.right}\n{t0.left}")

    for edgeName, edge in candidates.pairs:
      case edgeDirection:
      of edTop:
        if t0.top == edge:
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: false)
        elif t0.top == edge.reversed():
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: true)
      of edLeft:
        if t0.left == edge:
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: false)
        elif t0.left == edge.reversed():
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: true)
      of edRight:
        if t0.right == edge:
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: false)
        elif t0.right == edge.reversed():
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: true)
      of edBottom:
        if t0.bottom == edge:
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: false)
        elif t0.bottom == edge.reversed():
          result = SharedEdge(neighbourId: t1.id, tileEdge: edgeDirection, neighbourEdge: edgeName, reversed: true)

func len(n: Neighbours): int =
  if n.top != nil:
    result += 1
  if n.left != nil:
    result += 1
  if n.right != nil:
    result += 1
  if n.bottom != nil:
    result += 1

func flipHorizontally(tile: var TileP2) =
  tile.top.reverse()
  tile.bottom.reverse()

  swap(tile.left, tile.right)

func flipVertically(tile: var TileP2) =
  tile.left.reverse()
  tile.right.reverse()

  swap(tile.top, tile.bottom)



func getNextTile(tile: var TileP2, ed: EdgeDirection, tiles: var Table[int, TileP2]): TileP2 =
  for t2 in tile.neighbours.mitems:
    var sharedEdge = tile.getSharedEdge(t2, ed)
    debugEcho fmt("tile {tile.id} and {t2.id} maybe share edge: {sharedEdge}")
    if sharedEdge != nil:
      while not sharedEdge.tileEdge.isOpposite(sharedEdge.neighbourEdge):
        swap(t2.top, t2.left) # left has correct edge
        swap(t2.top, t2.right) # top has correct edge, right has bottom
        swap(t2.bottom, t2.right) # all edges correct
        sharedEdge = tile.getSharedEdge(t2, ed)
        debugEcho fmt("after rotate sharedEdge is: {sharedEdge}")
      if sharedEdge.reversed:
        if sharedEdge.tileEdge == edTop or sharedEdge.tileEdge == edBottom:
          # flip horizontally
          t2.flipHorizontally
        else:
          # flip vertically
          t2.flipVertically
      return t2


when isMainModule:
  let tilesInput = input.split("\n\n")
  var tiles = initTable[int, Tile]()
  var tilesP2 = initTable[int, TileP2]()
  var sideLen = 0
  for tileStr in tilesInput:
    let tileLines = tileStr.splitLines()
    var tileId = tileLines[0].split(" ")[1].split(":")[0].parseInt
    sideLen = tileLines[1].len

    var top = newSeqWith(sideLen, false)
    var left = newSeqWith(sideLen, false)
    var right = newSeqWith(sideLen, false)
    var bottom = newSeqWith(sideLen, false)
    var neighbours = Neighbours(top: nil, left: nil, right: nil, bottom: nil)

    var tile = Tile(id: tileId, left: left, right: right, top: top, bottom: bottom, neighbours: neighbours)
    var tileP2 = TileP2(id: tileId, left: left, right: right, top: top, bottom: bottom, neighbours: @[])
    for idx, line in tileLines[1..^1].pairs:
      if idx == 0: 
        for cIdx, c in line:
          if c == '#':
            tile.top[cIdx] = true
            tileP2.top[cIdx] = true
      elif idx == (tileLines.high - 1):
        for cIdx, c in line:
          if c == '#':
            tile.bottom[tileLines[0].high - cIdx] = true
            tileP2.bottom[tileLines[0].high - cIdx] = true
      if line[0] == '#':
        tile.left[tileLines[0].high - idx] = true
        tileP2.left[tileLines[0].high - idx] = true
      if line[line.high] == '#':
        tile.right[idx] = true
        tileP2.right[idx] = true
    
    tiles[tileId] = tile
    tilesP2[tileId] = tileP2

  for mtile in tiles.mvalues:
    for tile in tiles.values:
      if tile == mtile:
        continue
      var sharedEdge = mtile.getSharedEdge(tile, edTop)
      if sharedEdge != nil:
        mtile.neighbours.top = sharedEdge
        tilesP2[mtile.id].neighbours.add(tilesP2[sharedEdge.neighbourId])
        continue
      sharedEdge = mtile.getSharedEdge(tile, edLeft)
      if sharedEdge != nil:
        mtile.neighbours.left = sharedEdge
        tilesP2[mtile.id].neighbours.add(tilesP2[sharedEdge.neighbourId])
        continue
      sharedEdge = mtile.getSharedEdge(tile, edRight)
      if sharedEdge != nil:
        mtile.neighbours.right = sharedEdge
        tilesP2[mtile.id].neighbours.add(tilesP2[sharedEdge.neighbourId])
        continue
      sharedEdge = mtile.getSharedEdge(tile, edBottom)
      if sharedEdge != nil:
        mtile.neighbours.bottom = sharedEdge
        tilesP2[mtile.id].neighbours.add(tilesP2[sharedEdge.neighbourId])
        continue

  var cornerTiles = newSeq[int]()
  for tileId,tile in tiles.pairs:
    if tile.neighbours.len == 2:
      cornerTiles.add(tileId)

  let startTile = tiles[cornerTiles[0]]
  var currentTile = tilesP2[startTile.id]
  var pos = (0.Dx, 0.Dy)
  var dx = 0.Dx
  var dy = 0.Dy
  if startTile.neighbours.top != nil and startTile.neighbours.right != nil: # start bottom left
    pos = (0.Dx, (sideLen - 1).Dy)
    dx = 1.Dx
    dy = (-1).Dy
  elif startTile.neighbours.top != nil and startTile.neighbours.left != nil: # start bottom right
    pos = ((sideLen - 1).Dx, (sideLen - 1).Dy)
    dx = (-1).Dx
    dy = (-1).Dy
  elif startTile.neighbours.bottom != nil and startTile.neighbours.right != nil: # start top left
    pos = (0.Dx, 0.Dy)
    dx = 1.Dx
    dy = 1.Dy
  elif startTile.neighbours.bottom != nil and startTile.neighbours.left != nil: # start top right
    pos = ((sideLen - 1).Dx, 0.Dy)
    dx = (-1).Dx
    dy = 1.Dy

  var tilesPlaced = 1

  while tilesPlaced < sideLen * sideLen:
    let tileAtStart = currentTile
    if dx < 0:
      if pos[0] == 0:
        currentTile = currentTile.getNextTile(dy.toDirection, tilesP2)
        pos = ((sideLen - 1).Dx, pos[1] + dy)
      else:
        currentTile = currentTile.getNextTile(dx.toDirection, tilesP2)
        pos[0] += dx
    elif dx > 0:
      if pos[0] == sideLen - 1:
        currentTile = currentTile.getNextTile(dy.toDirection, tilesP2)
        pos = (0.Dx, pos[1] + dy)
      else:
        currentTile = currentTile.getNextTile(dx.toDirection, tilesP2)
        pos[0] += dx
    if currentTile != tileAtStart:
      echo fmt("placed tile: {currentTile}")
      if currentTile.id == 0:
        echo fmt("no tile found after tile {tileAtStart}. Should have neighbours: {tiles[tileAtStart.id]}")
        break
      tilesPlaced += 1
      tilesP2.del(currentTile.id)
      
  
  echo "p1: " & $cornerTiles.foldl(a * b)
  
    
