--
-- polyglossia-sanskrit.lua
-- part of polyglossia v1.59 -- 2022/11/29
--

require('polyglossia-punct')

-- How do we now, in Lua, what a \thinspace is? In the LaTeX source (latex.ltx)
-- it is defined as:
-- \def\thinspace{\leavevmode@ifvmode\kern .16667em }
-- I see no way of seeing if it has been overriden or not. So we stick to this
-- value.
local thinspace = 0.16667 -- 1/6

local function space_left(char)
    polyglossia.add_left_spaced_character('sanskrit', char, thinspace, 'quad')
end

polyglossia.clear_spaced_characters('sanskrit')
space_left('!')
space_left('?')
space_left('‼')
space_left('⁇')
space_left('⁈')
space_left('⁉')
space_left('‽') -- U+203D (interrobang)
space_left(':')
space_left(';')
space_left('।') -- danda, U+0964
space_left('॥') -- double danda, U+0965

local function activate_sanskrit_punct()
    polyglossia.activate_punct('sanskrit')
end

local function deactivate_sanskrit_punct()
    polyglossia.deactivate_punct()
end

polyglossia.activate_sanskrit_punct   = activate_sanskrit_punct
polyglossia.deactivate_sanskrit_punct = deactivate_sanskrit_punct
