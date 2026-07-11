local ls = require("luasnip")
local line_begin = require("luasnip.extras.conditions.expand").line_begin
local parse = ls.parser.parse_snippet

local function beginning(trig, name, body)
  return parse({
    trig = trig,
    name = name,
    condition = line_begin,
    show_condition = line_begin,
  }, body)
end

local function in_word(trig, name, body)
  return parse({ trig = trig, name = name, wordTrig = false }, body)
end

-- friendly-snippets intentionally wins equal-priority for/while/if/else triggers.
return {
  beginning("for", "for loop", [[for (int ${1:i}=${2:0}; $1<${3:n}; ++$1) {
    $0
}]]),
  beginning("rfor", "reverse for loop", [[for (int ${1:i}=${2:n-1}; $1>${3:-1}; --$1) {
    $0
}]]),
  beginning("while", "while loop", [[while ($1) {
    $2
}
$0]]),
  beginning("if", "if statement", [[if ($1) {
    $2
} $0]]),
  parse({ trig = "elif", name = "else if statement" }, [[else if ($1) {
    $2
} $0]]),
  parse({ trig = "else", name = "else statement" }, [[else ($1) {
    $2
} $0]]),
  in_word("ll", "long long", "long long"),
  parse({ trig = "vi", name = "vector int" }, "vector<int>"),
  parse({ trig = "vvi", name = "vector vector int" }, "vector<vector<int>>"),
  parse({ trig = "vll", name = "vector long long" }, "vector<long long>"),
  parse({ trig = "vb", name = "vector bool" }, "vector<bool>"),
  parse({ trig = "pii", name = "pair int int" }, "pair<int,int>"),
  parse({ trig = "piii", name = "tuple int int int" }, "tuple<int,int,int>"),
  parse({ trig = "vpii", name = "vector pair int int" }, "vector<pair<int,int>>"),
  in_word("pb", "vector push_back", "push_back($1);$0"),
  beginning("sort", "sort ordered data", "sort($1.begin(), $1.end());$0"),
  parse({ trig = "lb", name = "binary search geq" }, "lower_bound($1.begin(), $1.end(), $2);$0"),
  parse({ trig = "ub", name = "binary search >" }, "upper_bound($1.begin(), $1.end(), $2);$0"),
  in_word("rev", "greater comparator", "greater<${1:int}>()$0"),
  parse({ trig = "nn", name = "cout newline character" }, "<< '\\n';"),
  parse({ trig = "sp", name = "cout space character" }, "<< ' ';"),
}
