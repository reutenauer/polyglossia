local add_to_callback = luatexbase.add_to_callback
local remove_from_callback = luatexbase.remove_from_callback
local priority_in_callback = luatexbase.priority_in_callback

local module = {
    name          = "xpg-frpt",
    version       = 0.2,
    date          = "2013/04/23",
    description   = "Companion to Polyglossia for french punctuation",
    author        = "Elie Roux",
    copyright     = "Elie Roux",
    license       = "CC0"
}

local error, warning, info, log =
    luatexbase.provides_module(module)

xpg_frpt = xpg_frpt or {}

-- This mimics XeTeXintercharclasses, and is a tuned version of
-- http://wiki.luatex.org/index.php?title=Token_filter

-- We have four intercharclasses, we make a hash with
--   character -> intercharclass
-- In order to mimic the behaviour of XeTeX, we don't use class 0-3, we consider
-- that class 0 is the one of "normal" tokens, and that class 255 is the one of
-- text string boudaries (glue, kern, math, box, etc.).
-- 
-- Our new classes are (with the same names as in gloss-french.ldf:
--   * 1: french@punctthin
--   * 2: french@punctthick
--   * 3: french@punctguillstart
--   * 4: french@punctguillend

local charclasses = {
  [':'] = 1,
  ['?'] = 2, ['!'] = 2, [';'] = 2, ['‼'] = 2, ['⁇'] = 2, ['⁈'] = 2, ['⁉'] = 2,
  ['«'] = 3, ['<'] = 3,
  ['»'] = 4, ['>'] = 4,
  -- naive approach, we also put in this category anything with catcode != 11 or 12
  [' '] = 255, [' '] = 255,
  }

-- we have 5 possible toks to insert, we reference them in a table
-- corresponding to the arguments of XeTeXinterchartoks
-- the five toks are defined in gloss-french.ldf
local intercharclasses_toksnumbers = {
  [0] = {}, [255] = {}, [3] = {}, [4] = {}, [1] = {}}
  
intercharclasses_toksnumbers[0][1]   = 'xpg@lu@toks@one'   -- {\nobreak\thinspace}%
intercharclasses_toksnumbers[0][2]   = 'xpg@lu@toks@two'   -- {\nobreakspace}%
intercharclasses_toksnumbers[255][1] = 'xpg@lu@toks@three' -- {\xpg@unskip\nobreak\thinspace}%
intercharclasses_toksnumbers[255][2] = 'xpg@lu@toks@four'  -- {\xpg@unskip\nobreakspace}%
intercharclasses_toksnumbers[3][0]   = 'xpg@lu@toks@two'   -- {\nobreakspace}% "«a" -> "« a"
intercharclasses_toksnumbers[0][4]   = 'xpg@lu@toks@two'   -- {\nobreakspace}% "a»" -> "a »"
intercharclasses_toksnumbers[3][255] = 'xpg@lu@toks@five'  -- {\nobreakspace\xpg@nospace}% "«  " -> "«~"
intercharclasses_toksnumbers[255][4] = 'xpg@lu@toks@four'  -- {\xpg@unskip\nobreakspace}% "  »" -> "~»"
intercharclasses_toksnumbers[4][1]   = 'xpg@lu@toks@one'   -- {\nobreak\thinspace}% "»;" -> "» ;"
intercharclasses_toksnumbers[4][2]   = 'xpg@lu@toks@two'   -- {\nobreakspace}% "»:" -> "» :"
intercharclasses_toksnumbers[1][4]   = 'xpg@lu@toks@two'   -- {\nobreakspace}% "?»" -> "? »"
  
-- we store the previous character class
local previous_charclass
-- initalizing it to 255 seems safe
previous_charclass = 255

-- a variable to 
--local disable_

function do_intertoks () 
  local tok = token.get_next() 
  local newcharclass -- the char class of the current token
  if tex.count['xpg@interchartokenstate'] == 1 then
      --texio.write_nl("toto")
      if tok[1] == 11 or  tok[1] == 12 then
        -- if catcode is letter or other, then fine
        newcharclass = charclasses[tok[2]] or 0
      else 
        -- else we consider we're at a boundary of a text string
        newcharclass = 255
      end
      local toks_to_insert = intercharclasses_toksnumbers[previous_charclass] and 
         intercharclasses_toksnumbers[previous_charclass][newcharclass]
      if toks_to_insert then
          texio.write_nl("yeah!")
          insert = interchartoks[oc][nc]
          tok = {
            -- \xpg@interchartokenstate=0 \the\toks<n> \xpg@interchartokenstate=1
            token.create('xpg@interchartokenstate'),
            token.create(string.byte('='),12),
            token.create(string.byte('0'),12),
            token.create(string.byte(' '),10),
            token.create(toks_to_insert),
            token.create(string.byte(' '),10),
            token.create('xpg@interchartokenstate'),
            token.create(string.byte('='),12),
            token.create(string.byte('1'),12),
            token.create(string.byte(' '),10),
            {tok[1], tok[2], tok[3]}}               
      end
      previous_charclass = newcharclass
  end
  return tok
end

local function activate()
  add_to_callback("token_filter", do_intertoks, "xpg-frpt.do_intertoks")
end

local function desactivate()
  if priority_in_callback ("token_filter", "xpg-frpt.do_intertoks") then
    remove_from_callback("token_filter", "xpg-frpt.do_intertoks")
  end
end

xpg_frpt.get_toks_number = get_toks_number
xpg_frpt.activate = activate
xpg_frpt.desactivate = desactivate

