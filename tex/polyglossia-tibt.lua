require('polyglossia') -- just in case...

local add_to_callback = luatexbase.add_to_callback
local remove_from_callback = luatexbase.remove_from_callback
local priority_in_callback = luatexbase.priority_in_callback

local next, type = next, type

local nodes, fonts, node = nodes, fonts, node

local insert_node_before = node.insert_before
local insert_node_after  = node.insert_after
local remove_node        = nodes.remove
local end_of_math        = node.end_of_math
local has_attribute      = node.has_attribute
local utf8_char          = unicode.utf8.char
local utf8_byte          = unicode.utf8.byte

-- node types as of April 2013
local glue_code     = 10
local glue_spec_code= 47
local glyph_code    = 37
local penalty_code  = 12
local kern_code     = 11

-- we make a new node, so that we can copy it later on
local penalty_node  = node.new(penalty_code)
penalty_node.penalty = -2000 -- rather arbitrary... if someone has a better idea...?

local function get_penalty_node()
  return node.copy(penalty_node)
end

local xpgtibtattr = luatexbase.attributes['xpg@tibteol']

local tsheg = utf8_byte('་')

texio.write_nl(tsheg)

-- from typo-spa.lua
local function process(head)
    local start = head
    -- head is always begin of par (whatsit), so we have at least two prev nodes
    -- penalty followed by glue
    while start do
        local id = start.id
        if id == glyph_code then 
            local attr = has_attribute(start, xpgtibtattr)
            if attr and attr > 0 then
                local char = start.char
                if char == tsheg then
                    if start.next then
                        insert_node_after(head,start,get_penalty_node())
                    end
                end
                local next = start.next
            end
        elseif id == math_code then
            -- warning: this is a feature of luatex > 0.76
            start = end_of_math(start) -- weird, can return nil .. no math end?
        end
        if start then
            start = start.next
        end
    end
    return head
end

local callback_name = "pre_linebreak_filter"

local function activate()
  if not priority_in_callback (callback_name, "polyglossia-tibt.process") then
    add_to_callback(callback_name, process, "polyglossia-tibt.process", 1)
  end
end

local function desactivate()
  if priority_in_callback (callback_name, "polyglossia-tibt.process") then
    remove_from_callback(callback_name, "polyglossia-tibt.process")
  end
end

polyglossia.activate_tibt_eol    = activate
polyglossia.desactivate_tibt_eol = desactivate
