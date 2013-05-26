require('luatex-hyphen')

local luatexhyphen = luatexhyphen
local byte = unicode.utf8.byte

local polyglossia_module = {
    name          = "polyglossia",
    version       = 1.3,
    date          = "2013/05/11",
    description   = "Polyglossia",
    author        = "Elie Roux",
    copyright     = "Elie Roux",
    license       = "CC0"
}

local error, warning, info, log =
    luatexbase.provides_module(polyglossia_module)

polyglossia = polyglossia or {}
local polyglossia = polyglossia

local current_language
local last_language
local default_language

local function loadlang(lang, id)
  if luatexhyphen.lookupname(lang) then
    luatexhyphen.loadlanguage(lang, id) 
  end
end

local function select_language(lang, id)
  loadlang(lang, id)
  current_language = lang
  last_language = lang
end

local function set_default_language(lang, id)
  polyglossia.default_language = lang
end

local function falsefun()
  return false
end

local function disable_hyphenation()
  luatexbase.add_to_callback("hyphenate", falsefun, "polyglossia.disable_hyphenation")
end

local function enable_hyphenation()
  luatexbase.remove_from_callback("hyphenate", "polyglossia.disable_hyphenation")
end

local check_char

if luaotfload and luaotfload.aux and luaotfload.aux.font_has_glyph then
  local font_has_glyph = luaotfload.aux.font_has_glyph
  function check_char(chr)
    local codepoint = tonumber(chr)
    if not codepoint then codepoint = byte(chr) end
    if font_has_glyph(font.current(), codepoint) then
      tex.sprint('1')
    else
      tex.sprint('0')
    end
  end
else
  local ids = fonts.identifiers or fonts.ids or fonts.hashes.identifiers
  function check_char(chr) -- always in current font
      local otfdata = ids[font.current()].characters
      local codepoint = tonumber(chr)
      if not codepoint then codepoint = byte(chr) end
      if otfdata and otfdata[codepoint] then
          tex.print('1')
      else
          tex.print('0')
      end
  end
end

local function load_frpt()
    require('polyglossia-frpt')
end

local function load_tibt_eol()
    require('polyglossia-tibt')
end

polyglossia.loadlang = loadlang
polyglossia.select_language = select_language
polyglossia.set_default_language = set_default_language
polyglossia.current_language = current_language -- doesn't seem to be working well :-(
polyglossia.default_language = default_language
polyglossia.check_char = check_char
polyglossia.load_frpt = load_frpt
polyglossia.load_tibt_eol = load_tibt_eol
polyglossia.disable_hyphenation = disable_hyphenation
polyglossia.enable_hyphenation = enable_hyphenation
