local ls = require("luasnip")
local conditions = require("luasnip.extras.conditions.expand")
local parse = ls.parser.parse_snippet
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function in_mathzone()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local function context(trig, name, opts)
  return vim.tbl_extend("force", { trig = trig, name = name }, opts or {})
end

local function manual(trig, name, body, opts, node_opts)
  return parse(vim.tbl_extend("force", context(trig, name, opts), node_opts or {}), body)
end

local function auto(trig, name, body, opts, node_opts)
  opts = vim.tbl_extend("force", { snippetType = "autosnippet" }, opts or {})
  return parse(vim.tbl_extend("force", context(trig, name, opts), node_opts or {}), body)
end

local function math_manual(trig, name, body, opts)
  return manual(trig, name, body, opts, {
    condition = in_mathzone,
    show_condition = in_mathzone,
  })
end

local function math_auto(trig, name, body, opts)
  return auto(trig, name, body, opts, {
    condition = in_mathzone,
    show_condition = in_mathzone,
  })
end

local function show_at_line_begin(line_to_cursor)
  return line_to_cursor:match("^%s*%S*$") ~= nil
end

local function at_line_begin(trig, name, body, autosnippet)
  local constructor = autosnippet and auto or manual
  return constructor(trig, name, body, nil, {
    condition = conditions.line_begin,
    show_condition = show_at_line_begin,
  })
end

local function math_spacing(args)
  local following = args[1][1] or ""
  if following ~= "" and not following:match("^[,%.%?%- ]") then
    return " "
  end
  return ""
end

local function parenthesized_fraction(_, snip)
  local stripped = snip.trigger:sub(1, -2)
  local depth = 0

  for index = #stripped, 1, -1 do
    local char = stripped:sub(index, index)
    if char == ")" then
      depth = depth + 1
    elseif char == "(" then
      depth = depth - 1
      if depth == 0 then
        return stripped:sub(1, index - 1) .. "\\frac{" .. stripped:sub(index + 1, -2) .. "}"
      end
    end
  end

  return stripped
end

local function dotted_letter(_, snip)
  local capture = snip.captures[1]
  return capture:sub(1, 1) .. "\\dot{" .. capture:sub(2) .. "}"
end

local snippets = {
  at_line_begin("beg", "begin{} / end{}", [[\begin{$1}
	$0
\end{$1}]]),
  manual("bf", "bold text", [[\textbf{$1}$0]], { wordTrig = false }),
  manual("cal", "mathcal text", [[\mathcal{$1}$0]], { wordTrig = false }),
  manual("fig", "figure", [[\begin{figure}[htb]
	\centering
	\includegraphics[width=$1\textwidth]{figs/$2}
	\caption{$3}
	\label{fig:$4}
\end{figure}]]),
  manual("sfig", "figure with side caption", [[\begin{figure}[htb]
    \hfill
	\begin{minipage}[c]{0.6\textwidth}
        \includegraphics[width=\textwidth]{figs/$1}
	\end{minipage}
	\begin{minipage}[c]{0.38\textwidth}
        \caption{$2}
        \label{fig:$3}
	\end{minipage}
\end{figure}]]),
  manual("mfig", "multiple figures", [[\begin{figure}[htb]
	\centering
	\subfloat[$1]{\includegraphics[width=${2:0.45}\textwidth]{figs/$3}
    \label{fig:$4}}
    \qquad
    \subfloat[$5]{\includegraphics[width=${6:0.45}\textwidth]{figs/$7}
    \label{fig:$8}}
	\caption{$9}
    \label{fig:$10}
\end{figure}]]),
  manual("tabl", "table", [[\begin{table}[htb]
	\centering
	\begin{tabular}{${1:c | c}}
        $2
    \end{tabular}
    \caption{$3}
	\label{tab:$4}
\end{table}]]),
  -- friendly-snippets intentionally wins the equal-priority "item" trigger.
  at_line_begin("item", "Itemize", [[\begin{itemize}
	\item $0
\end{itemize}]]),
  at_line_begin("it", "item", [[\item $0]]),
  at_line_begin("eq", "Equation", [[\begin{equation}
	${0:${LS_SELECT_RAW}}
\end{equation}]]),
  at_line_begin("eqn", "Equation without a number", [[\begin{equation*}
	${0:${LS_SELECT_RAW}}
\end{equation*}]]),
  -- friendly-snippets intentionally wins the equal-priority "ali" trigger.
  at_line_begin("ali", "Align", [[\begin{align}
	${1:${LS_SELECT_RAW}}
\end{align}]]),
  at_line_begin("aln", "Align without a number", [[\begin{align*}
	${1:${LS_SELECT_RAW}}
\end{align*}]]),
  manual("/", "Fraction", [[\frac{${LS_SELECT_RAW}}{$1}$0]], { wordTrig = false }),
  math_manual("sum", "sum", [[\sum_{n=${1:1}}^{${2:\infty}} ${3:a_n}]], { priority = 1100 }),
  math_manual("int", "integral", [[\int_{${1:-\infty}}^{${2:\infty}} $3 ]], { priority = 1100 }),
  manual("lim", "limit", [[\lim_{${1:n} \to ${2:\infty}} ]], { priority = 1100 }),
  math_manual("lr", "paren", [[\paren{${1:${LS_SELECT_RAW}}}$0]], { wordTrig = false, priority = 1100 }),
  math_manual("lr[]", "bracket", [[\bracket{${1:${LS_SELECT_RAW}}}$0]], { wordTrig = false, priority = 1100 }),
  math_manual("lr{}", "curly", [[\set{${1:${LS_SELECT_RAW}}}$0]], { wordTrig = false, priority = 1100 }),
  math_manual("lr|", "magnitude", [[\abs{${1:${LS_SELECT_RAW}}}$0]], { wordTrig = false, priority = 1100 }),
  math_manual("lr||", "norm", [[\norm{${1:${LS_SELECT_RAW}}}$0]], { wordTrig = false, priority = 1100 }),
  math_manual("gen", "inner product", [[\gen{${1:${LS_SELECT_RAW}}}$0]], { wordTrig = false, priority = 1100 }),
  manual("dv", "Derivative", [[\odv{${1:${LS_SELECT_RAW}}}{${2}}]], { priority = 1100 }),
  manual("pdv", "Partial Derivative", [[\pdv{${1:${LS_SELECT_RAW}}}{${2}}]], { priority = 1100 }),
  manual("si", "SI-Unit", [[\SI{${1:${LS_SELECT_RAW}}}{${2}}]], { priority = 1100 }),
  math_manual("vu", "unit vector", [[\vu{${1:x}}$0]], { wordTrig = false, priority = 1100 }),
}

local autosnippets = {
  at_line_begin("enu", "Enumerate", [[\begin{enumerate}[(a), leftmargin=\parindent]
    \item
$0
\end{enumerate}]], true),
  at_line_begin("tikzcd", "cd diagram", [[\begin{equation*}
\begin{tikzcd}
    $0 \arrow[swap]{r}{f}
\end{tikzcd}
\end{equation*}]], true),
  -- Spacing updates on jump/InsertLeave; per-keystroke updates are intentionally deferred.
  s({ trig = "mk", name = "Math", snippetType = "autosnippet" }, {
    t("$"),
    i(1),
    t("$"),
    f(math_spacing, { 2 }),
    i(2),
  }),
  auto("dm", "Math", [[\[
${1:${LS_SELECT_RAW}}
\]
$0]]),
  math_auto("sq", [[\sqrt{}]], [[\sqrt{${1:${LS_SELECT_RAW}}} $0]], { wordTrig = false }),
  math_auto("sr", "^2", "^2", { wordTrig = false }),
  math_auto("cb", "^3", "^3", { wordTrig = false }),
  math_auto("tp", "superscript", [[^{$1}$0]], { wordTrig = false }),
  auto("__", "subscript", [[_{$1}$0]], { wordTrig = false }),
  math_auto("invs", "inverse", [[^{-1}]], { wordTrig = false }),
  math_auto("//", "Fraction", [[\frac{$1}{$2}$0]], { wordTrig = false }),
  math_auto(
    [[\v((\d+)|(\d*)(\\)?([A-Za-z]+)((\^|_)(\{\d+\}|\d))*)/]],
    "symbol frac",
    [[\frac{${LS_CAPTURE_1}}{$1}$0]],
    { trigEngine = "vim", hidden = true }
  ),
  s({
    trig = "^.*%)/",
    name = "() frac",
    trigEngine = "pattern",
    snippetType = "autosnippet",
    priority = 2000,
    hidden = true,
    condition = in_mathzone,
  }, {
    f(parenthesized_fraction),
    t("{"),
    i(1),
    t("}"),
    i(0),
  }),
  math_auto([[\v([A-Za-z])(\d)]], "auto subscript", "${LS_CAPTURE_1}_${LS_CAPTURE_2}", {
    trigEngine = "vim",
    hidden = true,
    priority = 2000,
  }),
  math_auto([[\v([A-Za-z])_(\d\d)]], "auto subscript2", "${LS_CAPTURE_1}_{${LS_CAPTURE_2}}", {
    trigEngine = "vim",
    hidden = true,
    priority = 2000,
  }),
  auto("==", "equals", [[&= $1 \\]], { wordTrig = false, priority = 2000 }),
  math_auto("tilde", "tilde", [[\widetilde{$1}$0]], { wordTrig = false, priority = 2000 }),
  math_auto("bar", "bar", [[\overline{$1}$0]], { wordTrig = false, priority = 1010 }),
  math_auto([[\v([a-zA-Z])bar]], "bar", [[\overline{${LS_CAPTURE_1}}]], {
    trigEngine = "vim",
    wordTrig = false,
    priority = 1100,
    hidden = true,
  }),
  math_auto("hat", "hat", [[\widehat{$1}$0]], { wordTrig = false, priority = 1010 }),
  math_auto([[\v([a-zA-Z])hat]], "hat", [[\widehat{${LS_CAPTURE_1}}]], {
    trigEngine = "vim",
    wordTrig = false,
    priority = 1100,
    hidden = true,
  }),
  s({
    trig = [[\v([^\\][a-zA-Z])dot]],
    name = "dot",
    trigEngine = "vim",
    snippetType = "autosnippet",
    wordTrig = false,
    priority = 1100,
    hidden = true,
    condition = in_mathzone,
  }, f(dotted_letter)),
  auto("CC", "C", [[\mathbb{C}]], { wordTrig = false, priority = 1100 }),
  auto("RR", "real", [[\mathbb{R}]], { wordTrig = false, priority = 1100 }),
  auto("QQ", "Q", [[\mathbb{Q}]], { wordTrig = false, priority = 1100 }),
  auto("ZZ", "Z", [[\mathbb{Z}]], { wordTrig = false, priority = 1100 }),
  auto("NN", "N", [[\mathbb{N}]], { wordTrig = false, priority = 1100 }),
  auto("EE", "expectation", [[\mathbb{E}]], { wordTrig = false, priority = 1100 }),
  auto("...", "ldots", [[\ldots]], { wordTrig = false, priority = 1100 }),
  math_auto("cc", "subset", [[\subset]], { wordTrig = false, priority = 1100 }),
  math_auto("dd", "Differential operator", [[\odif{${1:x}}$0]], { wordTrig = false, priority = 1100 }),
}

return snippets, autosnippets
