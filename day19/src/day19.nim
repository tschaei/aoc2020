import strutils, sequtils, sugar, tables, re

const input = staticRead("./input")

type
  RuleKind = enum
    rkChar,
    rkRules
  Rule = object
    case kind: RuleKind:
    of rkChar: c: char
    of rkRules: rules: seq[seq[int]]


func buildRegexString(rules: Table[int, Rule], s: var string, r: int, part2: bool) =
  if part2:
    if r == 8:
      buildRegexString(rules, s, 42, true)
      s.add("+")
      return
    elif r == 11:
      s.add("(")
      buildRegexString(rules, s, 42, true)
      s.add("(?1)?")
      buildRegexString(rules, s, 31, true)
      s.add(")")
      return
  case rules[r].kind:
  of rkChar:
    s.add(rules[r].c)
  of rkRules:
    s.add("(?:")
    var separator = ""
    for list in rules[r].rules:
      s.add(separator)
      for rule in list:
        buildRegexString(rules, s, rule, part2)
      separator = "|"
    s.add(")")

func buildRegex(rules: Table[int, Rule], part2: bool): Regex =
  var s = "^"
  buildRegexString(rules, s, 0, part2)
  s.add("$")
  result = re(s)
  
func count(rules: Table[int, Rule], inputs: seq[string], part2: bool): int =
  let regx = buildRegex(rules, part2)
  result = inputs.filter(line => line.match(regx)).len

when isMainModule:
  let inputBlocks = input.split("\n\n")
  let rulesInput = inputBlocks[0].splitLines()
  let inputs = inputBlocks[1].splitLines()
  let rules = collect(initTable(rulesInput.len)):
    for line in rulesInput:
      let parts = line.split(": ")
      let number = parts[0].parseInt
      let ruleStr = parts[1]
      let rule = if ruleStr.startsWith("\""):
        Rule(kind: rkChar, c: ruleStr[1])
      else:
        let alternatives = ruleStr.split(" | ").map(s => s.splitWhitespace().map(parseInt))
        Rule(kind: rkRules, rules: alternatives)
      {number: rule}

  echo "p1: " & $count(rules, inputs, false)
  echo "p2: " & $count(rules, inputs, true)



















# func parseRule(rule: int, rules: ptr Table[int, string], rulesInputs: Table[int, string]): string =
#   if rules[].hasKey(rule):
#     result = rules[][rule]
#   else:
#     let str = rulesInputs[rule]
#     if str.contains("\""):
#       result = $str[1]
#       rules[][rule] = result
#     elif str.contains("|"):
#       let groups = str.split(" | ").map(s => s.strip().split(" ").map(n => n.parseInt).map(n => parseRule(n, rules, rulesInputs)).join(""))
#       result = "(" & groups.join("|") & ")"
#       rules[][rule] = result
#     else:
#       result = str.strip().split(" ").map(n => n.parseInt).map(n => parseRule(n, rules, rulesInputs)).join("")
#       rules[][rule] = result

# func parseRuleP2(rule: int, depth: int, maxDepth: int, rules: ptr Table[int, string], rulesInputs: Table[int, string]): string =
#   if rules[].hasKey(rule):
#     result = rules[][rule]
#   else:
#     let str = rulesInputs[rule]
#     if str.contains("\""):
#       result = $str[1]
#       rules[][rule] = result
#     elif str.contains("|"):
#       let groups = str.split(" | ").map(s => s.strip().split(" ").map(n => n.parseInt)).filter(func (rules: seq[int]): bool =
#         result = (not rules.any(n => n == rule)) or depth < maxDepth 
#       ).map(func (rls: seq[int]): string =
#         result = rls.map(func (r: int): string =
#           if r == rule:
#             parseRuleP2(r, depth + 1, maxDepth, rules, rulesInputs)
#           else:
#             parseRuleP2(r, depth, maxDepth, rules, rulesInputs)
#         ).join("")
#       )
#       result = "(" & groups.join("|") & ")"
#       if rule != 8 and rule != 11:
#         rules[][rule] = result
#     else:
#       result = str.strip().split(" ").map(n => n.parseInt).map(n => parseRuleP2(n, depth, maxDepth, rules, rulesInputs)).join("")
#       rules[][rule] = result



# when isMainModule:
#   let inputBlocks = input.split("\n\n")
#   var rulesInputs = collect(initTable(0)):
#     for value in inputBlocks[0].splitLines().map(func (line: string): (int, string) =
#       let parts = line.split(": ")
#       (parts[0].parseInt, parts[1].strip())
#     ):
#       {value[0]: value[1]}
#   var rules = initTable[int, string](rulesInputs.len)
#   let rule0 = re(parseRule(0, rules.addr, rulesInputs))
#   rules.clear()
#   rulesInputs[8] = "42 | 42 8"
#   rulesInputs[11] = "42 31 | 42 11 31"
#   var p1 = 0
#   var maxLen = 5
#   for line in inputBlocks[1].splitLines():
#     # if line.len > maxLen:
#       # maxLen = line.len
#     if line.match(rule0):
#       p1 += 1

#   var p2 = 0
#   let rule0P2 = re(parseRuleP2(0, 0, maxLen, rules.addr, rulesInputs))
#   for line in inputBlocks[1].splitLines():
#     if line.match(rule0P2):
#       p2 += 1

#   echo "p1: " & $p1
#   echo "p2: " & $p2