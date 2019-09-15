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
  polyglossia.activate_punct()
  polyglossia.clear_spaced_characters()
  polyglossia.add_left_spaced_character(':',thickspace)
  polyglossia.add_left_spaced_character('!',thinspace)
  polyglossia.add_left_spaced_character('?',thinspace)
  polyglossia.add_left_spaced_character(';',thinspace)
  polyglossia.add_left_spaced_character('‼',thinspace)
  polyglossia.add_left_spaced_character('⁇',thinspace)
  polyglossia.add_left_spaced_character('⁈',thinspace)
  polyglossia.add_left_spaced_character('⁉',thinspace)
  polyglossia.add_left_spaced_character('»',thinspace)
  polyglossia.add_left_spaced_character('›',thinspace)
  polyglossia.add_right_spaced_character('«',thinspace)
  polyglossia.add_right_spaced_character('‹',thinspace)
end

-- So far, the following function is empty. It is provided for symmetry.
local function deactivate_french_punct()
  -- Though it would make compilation slightly faster, it is not possible to
  -- safely uncomment the following line. Imagine the following case: you start
  -- a paragraph by some french text, then, in the same paragraph, you change
  -- the language to something else, and thus call the following line. This
  -- means that, at the end of the paragraph, the function won't be in the
  -- callback, so the beginning of the paragraph won't be processed by it.
  -- polyglossia.deactivate_punct()
end

polyglossia.activate_french_punct   = activate_french_punct
polyglossia.deactivate_french_punct = deactivate_french_punct
