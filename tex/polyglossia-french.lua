require('polyglossia-punct')

-- How do we now, in Lua, what a \thinspace is? In the LaTeX source (latex.ltx)
-- it is defined as:
-- \def\thinspace{\leavevmode@ifvmode\kern .16667em }
-- I see no way of seeing if it has been overriden or not. So we stick to this
-- value.
local thinspace = 0.16667 -- 1/6
-- thickspace is defined in amsmath.sty as:
-- \renewcommand{\;}{\tmspace+\thickmuskip{.2777em}}
-- \let\thickspace\;
-- Same problem as above, we stick to this fixed value.
local thickspace = 0.2777 -- 5/18

local function activate_french_punct()
    polyglossia.activate_punct('french')
    polyglossia.clear_spaced_characters('french')
    polyglossia.add_left_spaced_character('french',':',thickspace)
    polyglossia.add_left_spaced_character('french','!',thinspace)
    polyglossia.add_left_spaced_character('french','?',thinspace)
    polyglossia.add_left_spaced_character('french',';',thinspace)
    polyglossia.add_left_spaced_character('french','‼',thinspace)
    polyglossia.add_left_spaced_character('french','⁇',thinspace)
    polyglossia.add_left_spaced_character('french','⁈',thinspace)
    polyglossia.add_left_spaced_character('french','⁉',thinspace)
    polyglossia.add_left_spaced_character('french','»',thinspace)
    polyglossia.add_left_spaced_character('french','›',thinspace)
    polyglossia.add_right_spaced_character('french','«',thinspace)
    polyglossia.add_right_spaced_character('french','‹',thinspace)
end

local function deactivate_french_punct()
    polyglossia.deactivate_punct()
end

polyglossia.activate_french_punct   = activate_french_punct
polyglossia.deactivate_french_punct = deactivate_french_punct
