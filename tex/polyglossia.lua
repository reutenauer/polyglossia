--
-- polyglossia.lua
-- part of polyglossia v2.1 -- 2024/03/07
--

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

local log_info = function(message, ...)
    luatexbase.module_info(module_name, message:format(...))
end
local log_warn = function(message, ...)
    luatexbase.module_warning(module_name, message:format(...))
end

polyglossia = polyglossia or {}
local polyglossia = polyglossia

local function load_tibt_eol()
    require('polyglossia-tibt')
end

-- predefined l@nohyphenation or LuaTeX's maximum value for \language
local nohyphid = luatexbase.registernumber'l@nohyphenation' or 16383
token.set_char('l@nohyphenation', nohyphid)

-- key `nohyphenation` is for .sty file when possibly undefined l@nohyphenation
local newloader_loaded_languages = { nohyphenation = nohyphid }

local newloader_available_languages = require'language.dat.lua'
-- Suggestion by Dohyun Kim on #129
local t = { }
for k, v in pairs(newloader_available_languages) do
    t[k] = v
    for _, vv in pairs(v.synonyms) do
        t[vv] = v
    end
end
newloader_available_languages = t

-- LaTeX's language register is \count19
local lang_register = 19

-- New hyphenation pattern loader: use language.dat.lua directly and the language identifiers
local function newloader(langentry)
    local loaded_language = newloader_loaded_languages[langentry]
    if loaded_language then
        local langid = lang.id(loaded_language)
        log_info('Language %s already loaded; id is %i', langentry, langid)
        return langid
    else
        local langdata = newloader_available_languages[langentry]
        if langdata then

            local special = langdata.special
            if special then
                -- language0 (USenglish) is already included in the format
                if special == 'language0' then
                    return 0

                -- disabled language should not be used for utf-8 text
                elseif special:find'^disabled:' then
                    log_warn('Hyphenation of language %s %s', langentry, special)
                    return nohyphid
                end
            end

            -- language info will be written into the .log file
            local s = { }
            for k, v in pairs(langdata) do
                if type(v) == 'table' then -- for 'synonyms'
                    s[#s+1] = k .. "\t" .. table.concat(v,',')
                else
                    s[#s+1] = k .. "\t" .. tostring(v)
                end
            end
            local a = {}
	    for _,n in pairs(s) do table.insert(a, n) end
            table.sort(a)
            log_info("Language data for " .. langentry .. "\n" .. table.concat(a,"\n"))

            --
            -- LaTeX's \newlanguage increases language register (count19),
            -- whereas LuaTeX's lang.new() increases its own language id.
            -- So when a user has declared, say, \newlanguage\lang@xyz, then
            -- these two numbers do not match each other. If we do not consider
            -- this possible situation, our newloader() function will
            -- unfortunately overwrite the language \lang@xyz.
            --
            -- Therefore here we will compare LaTeX's \newlanguage number with
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
            local newlangid = math.max(langcnt, langid)
            -- set language register for possible \newlanguage
            tex.setcount('global', lang_register, newlangid)
            -- get new lang object if needed
            if langid ~= newlangid then
                langobject = lang.new(newlangid)
            end

            -- load hyphenation patterns and exceptions
            for _,v in ipairs{ 'patterns', 'hyphenation' } do
                local data = langdata[v]
                if data and data ~= '' then
                    -- cope with comma separated list, such as serbian
                    for _,vv in ipairs(data:explode',+') do
                        local filepath = kpse.find_file(vv)
                        if filepath then
                            local fh = io.open(filepath)
                            lang[v](langobject, fh:read'a')
                            fh:close()
                        else
                            log_warn('Hyphenation file %s not found', vv)
                        end
                    end
                end
            end

            newloader_loaded_languages[langentry] = langobject

            log_info('Language %s was not yet loaded; created with id %i',
                     langentry, newlangid)
            return newlangid
        else
            log_warn('Language %s not found in language.dat.lua', langentry)
            return nohyphid
        end
    end
end

polyglossia.load_tibt_eol = load_tibt_eol
polyglossia.newloader = newloader
polyglossia.newloader_loaded_languages = newloader_loaded_languages
