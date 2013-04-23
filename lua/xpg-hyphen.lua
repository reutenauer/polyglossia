require('luatex-hyphen')

local luatexhyphen = luatexhyphen

xpg_hyphen = xpg_hyphen or {}

local function loadlang(lang, id)
  texio.write_nl("id: "..id.."\nlang: "..lang)
  if (id) and not luatexhyphen.lookupname(lang) then
    luatexhyphen.loadlanguage(lang, id) 
    texio.write_nl()
  end
end

xpg_hyphen.loadlang = loadlang
