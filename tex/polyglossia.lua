require('luatex-hyphen')

local luatexhyphen = luatexhyphen
local byte = unicode.utf8.byte

local module_name = "polyglossia"
local polyglossia_module = {
    name          = module_name,
    version       = 1.3,
    date          = "2013/05/11",
    description   = "Polyglossia",
    author        = "Elie Roux",
    copyright     = "Elie Roux",
    license       = "CC0"
}

luatexbase.provides_module(polyglossia_module)

local log_info = function(message)
	luatexbase.module_info(module_name, message)
end
local log_warning = function(message)
	luatexbase.module_warning(module_name, message)
end

polyglossia = polyglossia or {}
local polyglossia = polyglossia

-- predefined l@nohyphenation or dummy new language
local nohyphid = luatexbase.registernumber'l@nohyphenation' or lang.id(lang.new())
-- key `nohyphenation` is for .sty file when possibly undefined l@nohyphenation
polyglossia.newloader_loaded_languages = { nohyphenation = nohyphid }
-- newloader_max_langid will be increased by 4 per language
local newloader_max_langid = 0
local newloader_available_languages = dofile(kpse.find_file('language.dat.lua'))
-- Suggestion by Dohyun Kim on #129
local t = { }
for k, v in pairs(newloader_available_languages) do
    t[k] = v
    for _, vv in pairs(v.synonyms) do
        t[vv] = v
    end
end
newloader_available_languages = t

local function loadlang(lang, id)
  if luatexhyphen.lookupname(lang) then
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

-- New hyphenation pattern loader: use language.dat.lua directly and the language identifiers
local function newloader(langentry)
    loaded_language = polyglossia.newloader_loaded_languages[langentry]
    if loaded_language then
        log_info('Language ' .. langentry .. ' already loaded; id is ' .. lang.id(loaded_language))
        -- texio.write_nl('term and log', 'Language ' .. langentry .. ' already loaded with patterns ' .. tostring(loaded_language) .. '; id is ' .. lang.id(loaded_language))
        -- texio.write_nl('term and log', 'Language ' .. langentry .. ' already loaded with patterns ' .. loaded_language['patterns'] .. '; id is ' .. lang.id(loaded_language))
        return lang.id(loaded_language)
    else
        langdata = newloader_available_languages[langentry]
        if langdata and langdata['special'] == 'language0' then return 0 end

        if langdata then
            local s = "Language data for " .. langentry
            for k, v in pairs(langdata) do
				s = s .. "\n" .. k .. "\t" .. tostring(v)
            end
            newloader_max_langid = newloader_max_langid + 4
            langobject = lang.new(newloader_max_langid)
			s = s .. "\npatterns: " .. langdata.patterns
			log_info(s)
            if langdata.patterns and langdata.patterns ~= '' then
                pattfilepath = kpse.find_file(langdata.patterns)
                if pattfilepath then
                    pattfile = io.open(pattfilepath)
                    lang.patterns(langobject, pattfile:read('*all'))
                    pattfile:close()
                end
            end
            if langdata.hyphenation and langdata.hyphenation ~= '' then
                hyphfilepath = kpse.find_file(langdata.hyphenation)
                if hyphfilepath then
                    hyphfile = io.open(hyphfilepath)
                    lang.hyphenation(langobject, hyphfile:read('*all'))
                    hyphfile:close()
                end
            end
            polyglossia.newloader_loaded_languages[langentry] = langobject

            log_info('Language ' .. langentry .. ' was not yet loaded; created with id ' .. lang.id(langobject))
            return lang.id(langobject)
        else
            log_warning('Language ' .. langentry .. ' not found in language.dat.lua')
            return nohyphid
        end
    end
end

polyglossia.loadlang = loadlang
polyglossia.select_language = select_language
polyglossia.set_default_language = set_default_language
polyglossia.check_char = check_char
polyglossia.load_frpt = load_frpt
polyglossia.load_tibt_eol = load_tibt_eol
polyglossia.newloader = newloader
-- global variables:
-- polyglossia.default_language
-- polyglossia.current_language
