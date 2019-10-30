require('polyglossia') -- just in case...

local add_to_callback      = luatexbase.add_to_callback
local remove_from_callback = luatexbase.remove_from_callback
local priority_in_callback = luatexbase.priority_in_callback
local new_attribute        = luatexbase.new_attribute

local get_quad = luaotfload.aux.get_quad -- needs luaotfload > 20130516

local next = next

local nodes, node = nodes, node

local nodecodes          = nodes.nodecodes

local insert_node_before = node.insert_before
local insert_node_after  = node.insert_after
local remove_node        = node.remove
local has_attribute      = node.has_attribute
local node_copy          = node.copy
local new_node           = node.new

local math_code          = nodecodes.math
local end_of_math        = node.end_of_math
if not end_of_math then -- luatex < .76
    local traverse_nodes = node.traverse_id
    local end_of_math = function (n)
        for n in traverse_nodes(math_code, n.next) do
            return n
        end
    end
end

-- node types according to node.types()
local glue_code    = nodecodes.glue
local glyph_code   = nodecodes.glyph
local penalty_code = nodecodes.penalty
local kern_code    = nodecodes.kern

-- we make a new node, so that we can copy it later on
local kern_node = new_node(kern_code)

local function get_kern_node(dim)
    local n = node_copy(kern_node)
    n.kern = dim
    return n
end

-- we have here all possible space characters, referenced by their unicode slot
-- number, taken from char-def.lua
local space_chars = {[32] = true, [160] = true, [5760] = true, [6158] = true,
    [8192] = true, [8193] = true, [8194] = true, [8195] = true, [8196] = true,
    [8197] = true, [8198] = true, [8199] = true, [8200] = true, [8201] = true,
    [8202] = true, [8239] = true, [8287] = true, [12288] = true}

-- from nodes-tst.lua, adapted
local function somespace(n)
    if n then
        local id = n.id
        if id == glue_code then
            return glue_code
        elseif id == kern_code then
            return kern_code
        elseif id == glyph_code then
            if space_chars[n.char] then
                return true
            else
                return false
            end
        end
    end
    return false
end

-- idem
local function somepenalty(n, value)
    if n then
        local id = n.id
        if id == penalty_code then
            if value then
                return n.penalty == value
            else
                return true
            end
        end
    end
    return false
end

local punct_attr = new_attribute("polyglossia_punct")

local lang_id      = {}
local lang_counter = 0
local left_space   = {}
local right_space  = {}

local function ensure_lang_id(lang)
    if not lang_id[lang] then
        lang_counter = lang_counter + 1
        lang_id[lang] = lang_counter
    end
end

local function clear_spaced_characters(lang)
    ensure_lang_id(lang)
    left_space[lang_id[lang]] = {}
    right_space[lang_id[lang]] = {}
end

local function add_left_spaced_character(lang, char, kern)
    ensure_lang_id(lang)
    left_space[lang_id[lang]][char] = kern -- "kern" is meant as a fraction of a quad
end

local function add_right_spaced_character(lang, char, kern)
    ensure_lang_id(lang)
    right_space[lang_id[lang]][char] = kern -- "kern" is meant as a fraction of a quad
end

-- from typo-spa.lua, adapted
local function process(head)
    local done = false
    local start = head
    -- head is always begin of par (whatsit), so we have at least two prev nodes
    -- penalty followed by glue
    while start do
        local id = start.id
        if id == glyph_code then
            local attr = has_attribute(start, punct_attr)
            if attr then
                local char = utf8.char(start.char) -- requires Lua 5.3
                if left_space[attr][char] or right_space[attr][char] then
                    local quad = get_quad(start.font) -- might be optimized
                    local prev = start.prev
                    if left_space[attr][char] and prev then
                        local prevprev = prev.prev
                        if somespace(prev) then
                        -- TODO: there is a question here: do we override a preceding space or not?...
                            if somepenalty(prevprev, 10000) then
                                head = remove_node(head, prev)
                                head = remove_node(head, prevprev)
                            else
                                head = remove_node(head, prev)
                            end
                        end
                        insert_node_before(head, start, get_kern_node(left_space[attr][char]*quad))
                        done = true
                    end
                    local next = start.next
                    if right_space[attr][char] and next then
                        local nextnext = next.next
                        if somepenalty(next, 10000) then
                            if somespace(nextnext) then
                                head = remove_node(head, next)
                                head = remove_node(head, nextnext)
                            end
                        else
                            if somespace(next) then
                                head = remove_node(head, next)
                            end
                        end
                        insert_node_after(head, start, get_kern_node(right_space[attr][char]*quad))
                        done = true
                    end
                end
            end
        elseif id == math_code then
            -- warning: this is a feature of luatex > 0.76
            start = end_of_math(start) -- weird, can return nil .. no math end?
        end
        if start then
            start = start.next
        end
    end
    return head, done
end

local callback_name = "pre_linebreak_filter"

local function activate(lang)
    ensure_lang_id(lang)
    -- We set the punctuation attribute to a language id here. This is
    -- important to be able to intermix languages with different spacings
    -- in one paragraph.
    tex.setattribute(punct_attr, lang_id[lang])
    if not priority_in_callback(callback_name, "polyglossia-punct.process") then
        add_to_callback(callback_name, process, "polyglossia-punct.process", 1)
    end
end

local function deactivate()
    tex.setattribute(punct_attr, -0x7FFFFFFF) -- this value means "unset"
    -- Though it would make compilation slightly faster, it is not possible to
    -- safely uncomment the following lines. Imagine the following case: you
    -- start a paragraph by some spaced punctuation text, then, in the same
    -- paragraph, you change the language to something else, and thus call the
    -- following lines. This means that, at the end of the paragraph, the
    -- function won't be in the callback, so the beginning of the paragraph
    -- won't be processed by it.
    -- if priority_in_callback(callback_name, "polyglossia-punct.process") then
    --     remove_from_callback(callback_name, "polyglossia-punct.process")
    -- end
end

polyglossia.activate_punct             = activate
polyglossia.deactivate_punct           = deactivate
polyglossia.add_left_spaced_character  = add_left_spaced_character
polyglossia.add_right_spaced_character = add_right_spaced_character
polyglossia.clear_spaced_characters    = clear_spaced_characters
