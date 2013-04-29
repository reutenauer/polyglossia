require('luatex-hyphen')

local luatexhyphen = luatexhyphen

local module = {
    name          = "xpg-hyphen",
    version       = 0.2,
    date          = "2013/04/23",
    description   = "Companion to Polyglossia",
    author        = "Elie Roux",
    copyright     = "Elie Roux",
    license       = "CC0"
}

local error, warning, info, log =
    luatexbase.provides_module(module)

xpg_hyphen = xpg_hyphen or {}

local function loadlang(lang, id)
  if id and luatexhyphen.lookupname(lang) then
    luatexhyphen.loadlanguage(lang, id) 
  end
end

xpg_hyphen.loadlang = loadlang
