require('polyglossia-punct')

-- How do we now, in Lua, what a \thinspace is? In the LaTeX source (latex.ltx)
-- it is defined as:
-- \def\thinspace{\leavevmode@ifvmode\kern .16667em }
-- I see no way of seeing if it has been overriden or not. So we stick to this
-- value.
local thinspace = 0.16667 -- 1/6

local function activate_sanskrit_punct()
    polyglossia.activate_punct('sanskrit')
    polyglossia.clear_spaced_characters('sanskrit')
    polyglossia.add_left_spaced_character('sanskrit','!',thinspace)
    polyglossia.add_left_spaced_character('sanskrit','?',thinspace)
    polyglossia.add_left_spaced_character('sanskrit','‼',thinspace)
    polyglossia.add_left_spaced_character('sanskrit','⁇',thinspace)
    polyglossia.add_left_spaced_character('sanskrit','⁈',thinspace)
    polyglossia.add_left_spaced_character('sanskrit','⁉',thinspace)
    polyglossia.add_left_spaced_character('sanskrit',':',thinspace)
    polyglossia.add_left_spaced_character('sanskrit',';',thinspace)
    polyglossia.add_left_spaced_character('sanskrit','।',thinspace) -- danda, U+0964
    polyglossia.add_left_spaced_character('sanskrit','॥',thinspace) -- double danda, U+0965
end

local function deactivate_sanskrit_punct()
    polyglossia.deactivate_punct()
end

polyglossia.activate_sanskrit_punct   = activate_sanskrit_punct
polyglossia.deactivate_sanskrit_punct = deactivate_sanskrit_punct
