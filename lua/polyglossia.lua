require('luatex-hyphen')

local luatexhyphen = luatexhyphen

local module = {
    name          = "polyglossia",
    version       = 0.2,
    date          = "2013/04/23",
    description   = "Polyglossia",
    author        = "Elie Roux",
    copyright     = "Elie Roux",
    license       = "CC0"
}

local error, warning, info, log =
    luatexbase.provides_module(module)

polyglossia = polyglossia or {}

local current_language
local default_language

local function loadlang(lang, id)
  if id and luatexhyphen.lookupname(lang) then
    luatexhyphen.loadlanguage(lang, id) 
  end
end

local function select_language(lang, id)
  loadlang(lang, id)
  polyglossia.current_language = lang
end

local function set_default_language(lang, id)
  polyglossia.default_language = lang
end

local ids = fonts.identifiers or fonts.ids or fonts.hashes.identifiers

local function check_char(char) -- always in current font
    local otfdata = ids[font.current()].characters
    if otfdata and otfdata[char] then
        tex.print('1')
    else
        tex.print('0')
    end
end

local function load_frpt()
    require('polyglossia-frpt')
end

polyglossia.loadlang = loadlang
polyglossia.select_language = select_language
polyglossia.set_default_language = set_default_language
polyglossia.current_language = current_language -- doesn't seem to be working well :-(
polyglossia.default_language = default_language
polyglossia.check_char = check_char
polyglossia.load_frpt = load_frpt
