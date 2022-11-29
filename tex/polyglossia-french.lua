--
-- polyglossia-punct.lua
-- part of polyglossia v1.59 -- 2022/11/29
--

require('polyglossia-punct')

local function set_left_space(lang, char, kern, rubber)
    polyglossia.add_left_spaced_character(lang, char, kern, "space", rubber)
end

local function set_right_space(lang, char, kern, rubber)
    polyglossia.add_right_spaced_character(lang, char, kern, "space", rubber)
end

local function activate_french_punct(thincolonspace, autospaceguillemets)
    -- We need different language tags here to make switching of options possible
    -- within a paragraph.
    local lang = "french"
    if thincolonspace then
        lang = lang.."-thincolon"
    end
    if autospaceguillemets then
        lang = lang.."-autospace"
    end

    polyglossia.activate_punct(lang)
    polyglossia.clear_spaced_characters(lang)

    if thincolonspace then
        set_left_space(lang, ':', 0.5)
    else
        set_left_space(lang, ':', 1, true) -- stretchable and shrinkable space
    end

    set_left_space(lang, '!', 0.5)
    set_left_space(lang, '?', 0.5)
    set_left_space(lang, ';', 0.5)
    set_left_space(lang, '‼', 0.5)
    set_left_space(lang, '⁇', 0.5)
    set_left_space(lang, '⁈', 0.5)
    set_left_space(lang, '⁉', 0.5)
    set_left_space(lang, '‽', 0.5) -- U+203D (interrobang)

    if autospaceguillemets then
        set_left_space(lang, '»', 0.5)
        set_left_space(lang, '›', 0.5)
        set_right_space(lang, '«', 0.5)
        set_right_space(lang, '‹', 0.5)
    end
end

local function deactivate_french_punct()
    polyglossia.deactivate_punct()
end

polyglossia.activate_french_punct   = activate_french_punct
polyglossia.deactivate_french_punct = deactivate_french_punct
