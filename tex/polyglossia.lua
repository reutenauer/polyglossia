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
local newloader_loaded_languages = { nohyphenation = nohyphid }

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

-- LaTeX's language register is \count19
local lang_register = 19

-- New hyphenation pattern loader: use language.dat.lua directly and the language identifiers
local function newloader(langentry)
    local loaded_language = newloader_loaded_languages[langentry]
    if loaded_language then
        log_info('Language ' .. langentry .. ' already loaded; id is ' .. lang.id(loaded_language))
        -- texio.write_nl('term and log', 'Language ' .. langentry .. ' already loaded with patterns ' .. tostring(loaded_language) .. '; id is ' .. lang.id(loaded_language))
        -- texio.write_nl('term and log', 'Language ' .. langentry .. ' already loaded with patterns ' .. loaded_language['patterns'] .. '; id is ' .. lang.id(loaded_language))
        return lang.id(loaded_language)
    else
        local langdata = newloader_available_languages[langentry]
        if langdata and langdata['special'] == 'language0' then return 0 end

        if langdata then
            local s = "Language data for " .. langentry
            for k, v in pairs(langdata) do
				s = s .. "\n" .. k .. "\t" .. tostring(v)
            end

            --
            -- LaTeX's \newlanguage increases language register (count19),
            -- whereas LuaTeX's lang.new() increases its own language id.
            -- So when a user has declared, say, \newlanguage\lang@xyz, then
            -- these two numbers do not match each other. If we do not consider
            -- this possible situation, our newloader() function will
            -- unfortunately overwrite the language \lang@xyz.
            --
            -- Threfore here we will compare LaTeX's \newlanguage number with
            -- LuaTeX's lang.new() id and select the bigger one for our new
            -- language object. Also we will update LaTeX's language register
            -- by this new id, so that another possible \newlanguage should not
            -- overwrite our language object.
            --
            -- get next \newlanguage allocation number
            local langcnt = tex.count[lang_register] + 1
            -- get new lang object
            local langobject = lang.new()
            local langid = lang.id(langobject)
            -- get bigger one between \newlanguage and new lang obj id
            local maxlangid = math.max(langcnt, langid)
            -- set language register for possible \newlanguage
            tex.setcount('global', lang_register, maxlangid)
            -- get new lang object if needeed
            if langid ~= maxlangid then
              langobject = lang.new(maxlangid)
            end
			s = s .. "\npatterns: " .. langdata.patterns
			log_info(s)
            if langdata.patterns and langdata.patterns ~= '' then
                local pattfilepath = kpse.find_file(langdata.patterns)
                if pattfilepath then
                    local pattfile = io.open(pattfilepath)
                    lang.patterns(langobject, pattfile:read('*all'))
                    pattfile:close()
                end
            end
            if langdata.hyphenation and langdata.hyphenation ~= '' then
                local hyphfilepath = kpse.find_file(langdata.hyphenation)
                if hyphfilepath then
                    local hyphfile = io.open(hyphfilepath)
                    lang.hyphenation(langobject, hyphfile:read('*all'))
                    hyphfile:close()
                end
            end
            newloader_loaded_languages[langentry] = langobject

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
polyglossia.newloader_loaded_languages = newloader_loaded_languages
-- global variables:
-- polyglossia.default_language
-- polyglossia.current_language
