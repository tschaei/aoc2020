import strutils, sequtils, tables, sugar, strformat, sets

const input = staticRead("./input")

when isMainModule:
  let foods = input.splitLines()
  var allergensToIngredients = initTable[string, CountTable[string]]()
  var ingredientCounts = initCountTable[string]()
  var allergenCandidates = initHashSet[string]()

  for food in foods:
    let allergensStart = food.find("(contains ")
    var allergens = food[(allergensStart + "(contains ".len)..^2].split(",").map(s => s.strip)
    for ingredient in food[0..<allergensStart].strip().split(" "):
      ingredientCounts.inc(ingredient)
      for allergen in allergens:
        allergensToIngredients.mgetOrPut(allergen, initCountTable[string]()).inc(ingredient)

  for allergen, ingredientsMap in allergensToIngredients.mpairs:
    var max = 0
    for ingredientCount in ingredientsMap.values:
      if ingredientCount > max:
        max = ingredientCount 
    
    var ingredientsToDelete = newSeq[string]()
    for ingredient, ingredientCount in ingredientsMap.pairs:
      if ingredientCount == max:
        allergenCandidates.incl(ingredient)
      else:
        ingredientsToDelete.add(ingredient)

    for ingredient in ingredientsToDelete:
      ingredientsMap.del(ingredient) 
      
  var p1 = 0
  var allergenFreeIngredientCount = 0
  for ingredient in ingredientCounts.keys:
    if not allergenCandidates.contains(ingredient):
      p1 += ingredientCounts[ingredient]
      allergenFreeIngredientCount += 1
  
  echo fmt("allergen free ingredients: {allergenFreeIngredientCount}")

  var solvedAllergens = initOrderedTable[string, string]()
  while true:
    if solvedAllergens.len == allergensToIngredients.len:
      break
    for allergen, ingredientsMap in allergensToIngredients.pairs:
      if solvedAllergens.hasKey(allergen):
        continue
      if ingredientsMap.len() == 1:
        let ingredient = ingredientsMap.largest[0]
        solvedAllergens[allergen] = ingredient
        for otherIngredientsMap in allergensToIngredients.mvalues:
          if otherIngredientsMap == ingredientsMap:
            continue
          otherIngredientsMap.del(ingredient)

  solvedAllergens.sort(cmp)
  var p2Seq = newSeq[string]()
  for ingredient in solvedAllergens.values:
    p2Seq.add(ingredient)
  var p2 = p2Seq.join(",")

  echo fmt("p1: {p1}")
  echo fmt("p2: {p2}")