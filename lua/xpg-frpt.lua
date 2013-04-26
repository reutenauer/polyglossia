local add_to_callback = luatexbase.add_to_callback
local remove_from_callback = luatexbase.remove_from_callback
local priority_in_callback = luatexbase.priority_in_callback
local tokencreate = token.create
local mathfloor = math.floor
local tokenis_expandable = token.is_expandable
local tokenis_activechar = token.is_activechar
local tokenget_next = token.get_next
local texcount = tex.count
local tokencommand_name = token.command_name

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
--   * 4: french@punctthin
--   * 5: french@punctthick
--   * 6: french@punctguillstart
--   * 7: french@punctguillend

local charclasses = {
  [string.byte(':')] = 4,
  [string.byte('?')] = 5, [string.byte('!')] = 5, [string.byte(';')] = 5, [string.byte('‼')] = 5, 
  [string.byte('⁇')] = 5, [string.byte('⁈')] = 5, [string.byte('⁉')] = 5,
  [string.byte('«')] = 6, [string.byte('<')] = 6, --poses many problems
  [string.byte('»')] = 7, [string.byte('>')] = 7, --idem
  -- naive approach, we also put in this category anything with catcode != 11 or 12
  [string.byte(' ')] = 255, [string.byte(' ')] = 255,
  }
  
-- Here we have commented out > and < characters. That's because token_filter
-- get fed with *everything*, including things like \ifdim\foo>0pt, which would
-- make the function insert a token and would give something like 
-- \ifdim\foo\the\toksxx>0pt and break everything! I'm not even sure it can be
-- worked around... The best would be to change all this and work with nodes,
-- a much more reliable solution!

-- we have 5 possible toks to insert, we reference them in a table
-- corresponding to the arguments of XeTeXinterchartoks
-- the five toks are defined in gloss-french.ldf
local intercharclasses_toksnumbers = {
  [0] = {}, [255] = {}, [6] = {}, [7] = {}, [4] = {}}

-- It's better to use \the\toksxx than the name of the toks, so we create newtoks
-- in the .def file and feed lua with their allocationnumber
local map_toks = {}
local function map_toks_number (allocationnumber, toksnumber)
  map_toks[toksnumber] = allocationnumber
end

-- one we're done with newtoks, we can create the final table
local function create_intercharclasses_toksnumbers()
  intercharclasses_toksnumbers[0][4]   = map_toks[1] -- 'xpg@lu@toks@one'  {\nobreak\thinspace}%
  intercharclasses_toksnumbers[0][5]   = map_toks[2] -- 'xpg@lu@toks@two'  {\nobreakspace}%
  intercharclasses_toksnumbers[255][4] = map_toks[3] -- 'xpg@lu@toks@three'{\xpg@unskip\nobreak\thinspace}%
  intercharclasses_toksnumbers[255][5] = map_toks[4] -- 'xpg@lu@toks@four' {\xpg@unskip\nobreakspace}%
  intercharclasses_toksnumbers[6][0]   = map_toks[2] -- 'xpg@lu@toks@two'  {\nobreakspace}% "«a" -> "« a"
  intercharclasses_toksnumbers[0][7]   = map_toks[2] -- 'xpg@lu@toks@two'  {\nobreakspace}% "a»" -> "a »"
  intercharclasses_toksnumbers[6][255] = map_toks[5] -- 'xpg@lu@toks@five' {\nobreakspace\xpg@nospace}% "«  " -> "«~"
  intercharclasses_toksnumbers[255][7] = map_toks[4] -- 'xpg@lu@toks@four' {\xpg@unskip\nobreakspace}% "  »" -> "~»"
  intercharclasses_toksnumbers[7][4]   = map_toks[1] -- 'xpg@lu@toks@one'  {\nobreak\thinspace}% "»;" -> "» ;"
  intercharclasses_toksnumbers[7][5]   = map_toks[2] -- 'xpg@lu@toks@two'  {\nobreakspace}% "»:" -> "» :"
  intercharclasses_toksnumbers[4][7]   = map_toks[2] -- 'xpg@lu@toks@two'  {\nobreakspace}% "?»" -> "? »"
end
  
-- we store the previous character class
local previous_charclass
-- initalizing it to 255 seems safe
previous_charclass = 255


local function activate()
  if not priority_in_callback ("token_filter", "xpg-frpt.do_intertoks") then
    add_to_callback("token_filter", do_intertoks, "xpg-frpt.do_intertoks")
  end
end

local function desactivate()
  if priority_in_callback ("token_filter", "xpg-frpt.do_intertoks") then
    remove_from_callback("token_filter", "xpg-frpt.do_intertoks")
  end
end

function do_intertoks () 
  local tok = tokenget_next() 
  local newcharclass -- the char class of the current token
  -- an additional security, not sure if it's useful
  local commandname = tokencommand_name(tok)
  if texcount['xpg@interchartokenstate'] == 1 then 
      if tokenis_expandable(tok) or tokenis_activechar(tok) then
      --  previous_charclass = 254 -- we consider it's "invalid"
      --  return tok
      --end
      if tok[1] == 11 or  tok[1] == 12 then
        -- if catcode is letter or other, then fine
        newcharclass = charclasses[tok[2]] or 0
        if commandname == 'spacer' then
          newcharclass = 255
        end
      else 
        -- else we consider we're at a boundary of a text string
        newcharclass = 255
      end
      --texio.write_nl(unicode.utf8.char(tok[2])..' '..commandname)
      --texio.write_nl("previous_charclass: "..previous_charclass.."\nnewcharclass: "..newcharclass)
      local toks_to_insert = intercharclasses_toksnumbers[previous_charclass] and 
         intercharclasses_toksnumbers[previous_charclass][newcharclass]
      if toks_to_insert then
          local h = mathfloor(toks_to_insert / 100)
          local d = mathfloor((toks_to_insert - h*100) / 10)
          local u = toks_to_insert % 10
          --texio.write_nl(token.command_name(tok))
          tok = {
            -- \xpg@interchartokenstate=0 \the\toks<n> \xpg@interchartokenstate=1 tok
            token.create('xpg@interchartokenstate'),
            token.create(string.byte('='),12),
            token.create(string.byte(' '),10),
            token.create(string.byte('0'),12),
            token.create('relax'),
            tokencreate('the'),
            tokencreate('toks'),
            h and tokencreate(string.byte(h),12),
            d and tokencreate(string.byte(d),12),
            tokencreate(string.byte(u),12),
            tokencreate(string.byte(' '),10),
            token.create('xpg@interchartokenstate'),
            token.create(string.byte('='),12),
            token.create(string.byte(' '),10),
            token.create(string.byte('1'),12),
            token.create('relax'),
              {tok[1], tok[2], tok[3]}}               
      end
      previous_charclass = newcharclass
  end
  return tok
end

xpg_frpt.get_toks_number = get_toks_number
xpg_frpt.activate = activate
xpg_frpt.desactivate = desactivate
xpg_frpt.map_toks_number = map_toks_number 
xpg_frpt.create_intercharclasses_toksnumbers = create_intercharclasses_toksnumbers
