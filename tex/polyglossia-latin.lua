require('polyglossia-punct')

-- For ecclesiastic Latin (and sometimes for Italian) a very small space is
-- used for the punctuation. The ecclesiastic package uses a space of
-- 0.3\fontdimen2, where \fontdimen2 is a interword space, which is typically
-- between 1/4 and 1/3 of a quad. We choose a half of a \thinspace here.
local hairspace = 0.08333 -- 1/12 quad

local function activate_latin_punct()
  polyglossia.activate_punct()
  polyglossia.clear_spaced_characters()
  polyglossia.add_left_spaced_character(':',hairspace)
  polyglossia.add_left_spaced_character('!',hairspace)
  polyglossia.add_left_spaced_character('?',hairspace)
  polyglossia.add_left_spaced_character(';',hairspace)
  polyglossia.add_left_spaced_character('‼',hairspace)
  polyglossia.add_left_spaced_character('⁇',hairspace)
  polyglossia.add_left_spaced_character('⁈',hairspace)
  polyglossia.add_left_spaced_character('⁉',hairspace)
  polyglossia.add_left_spaced_character('»',hairspace)
  polyglossia.add_left_spaced_character('›',hairspace)
  polyglossia.add_right_spaced_character('«',hairspace)
  polyglossia.add_right_spaced_character('‹',hairspace)
end

-- So far, the following function is empty. It is provided for symmetry.
local function deactivate_latin_punct()
  -- Though it would make compilation slightly faster, it is not possible to
  -- safely uncomment the following line. Imagine the following case: you start
  -- a paragraph by some ecclesiastical Latin text, then, in the same
  -- paragraph, you change the language to something else, and thus call the
  -- following line. This means that, at the end of the paragraph, the function
  -- won't be in the callback, so the beginning of the paragraph won't be
  -- processed by it.
  -- polyglossia.deactivate_punct()
end

polyglossia.activate_latin_punct   = activate_latin_punct
polyglossia.deactivate_latin_punct = deactivate_latin_punct
