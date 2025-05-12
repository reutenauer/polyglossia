--
-- polyglossia-tibt.lua
-- part of polyglossia v2.5 -- 2025/05/12
--

require('polyglossia') -- just in case...

local add_to_callback = luatexbase.add_to_callback
local remove_from_callback = luatexbase.remove_from_callback
local declare_callback_rule = luatexbase.declare_callback_rule
local priority_in_callback = luatexbase.priority_in_callback

local next, type = next, type
local node = node

local insert_node_before = node.insert_before
local insert_node_after  = node.insert_after
local remove_node        = node.remove
local copy_node          = node.copy
local has_attribute      = node.has_attribute

local end_of_math        = node.end_of_math
if not end_of_math then -- luatex < .76
  local traverse_nodes = node.traverse_id
  local math_code      = node.id('math_char')
  local end_of_math = function (n)
    for n in traverse_nodes(math_code, n.next) do
      return n
    end
  end
end

-- node types as of April 2024
local glyph_code         = node.id('glyph')
local penalty_code       = node.id('penalty')
local kern_code          = node.id('kern')

-- we make a new node, so that we can copy it later on
local penalty_node  = node.new(penalty_code)
penalty_node.penalty = 50 -- corresponds to the penalty LaTeX sets at explicit hyphens

local function get_penalty_node()
  return copy_node(penalty_node)
end

local xpgtibtattr = luatexbase.attributes['xpg@tibteol']

local tsheg = unicode.utf8.byte('་')

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
                if start.char == tsheg then
                    if start.next then
                        insert_node_after(head,start,get_penalty_node())
                    end
                end
            end
        elseif id == math_code then
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
    add_to_callback(callback_name, process, "polyglossia-tibt.process")
    declare_callback_rule(callback_name,
    "polyglossia-tibt.process", "before", "luaotfload.node_processor")
end

local function desactivate()
	remove_from_callback(callback_name, "polyglossia-tibt.process")
end

polyglossia.activate_tibt_eol    = activate
polyglossia.desactivate_tibt_eol = desactivate
