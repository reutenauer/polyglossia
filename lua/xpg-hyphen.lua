local dofile = dofile
local kpse, texio = kpse, texio
dofile(kpse.find_file('luatex-hyphen.lua'))
local luatexhyphen = luatexhyphen

module('xpg_hyphen')
-- kpse.set_program_name('lualatex', 'lualatex')

local language_dat_filename = kpse.find_file('language.dat.lua')
local language_dat

if language_dat_filename then
  language_dat = dofile(language_dat_filename)
else
  language_dat = { }
end

function findlang(lang)
  return language_dat[lang]
end

function loadlang(lang, id)
  texio.write_nl('term and log', "Trying to load pattern for lang " ..  lang .. ", id " .. id)
  if findlang(lang) then
    luatexhyphen.loadlanguage(lang, id)
  end
end
