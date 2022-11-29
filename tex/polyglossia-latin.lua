--
-- polyglossia-latin.lua
-- part of polyglossia v1.59 -- 2022/11/29
--

require('polyglossia-punct')

-- For ecclesiastic Latin (and sometimes for Italian) a very small space is
-- used for the punctuation. The ecclesiastic package uses a space of
-- 0.3\fontdimen2, where \fontdimen2 is a interword space, which is typically
-- between 1/4 and 1/3 of a quad. We choose a half of a \thinspace here.
local hairspace = 0.08333 -- 1/12

local function space_left(char)
    polyglossia.add_left_spaced_character('latin', char, hairspace, 'quad')
end

local function space_right(char)
    polyglossia.add_right_spaced_character('latin', char, hairspace, 'quad')
end

polyglossia.clear_spaced_characters('latin')
space_left('!')
space_left('?')
space_left('‼')
space_left('⁇')
space_left('⁈')
space_left('⁉')
space_left('‽') -- U+203D (interrobang)
space_left(':')
space_left(';')
space_left('»')
space_left('›')
space_right('«')
space_right('‹')

local function activate_latin_punct()
    polyglossia.activate_punct('latin')
end

local function deactivate_latin_punct()
    polyglossia.deactivate_punct()
end

polyglossia.activate_latin_punct   = activate_latin_punct
polyglossia.deactivate_latin_punct = deactivate_latin_punct
