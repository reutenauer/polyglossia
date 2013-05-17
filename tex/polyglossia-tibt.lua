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
penalty_node.penalty = -2000

local function get_penalty_node()
  return node.copy(penalty_node)
end

-- same for glue node
local glue_node  = node.new(glue_code)
glue_node.spec = node.new(glue_spec_code)

local function get_glue_node(dim)
  local n = node.copy(glue_node)
  n.spec.width = dim
  return n
end

-- we have here all possible space characters, referenced by their
-- unicode slot number, taken from char-def.lua
local space_chars = {[20]=1, [160]=1, [5760]=1, [6158]=1, [8192]=1, [8193]=1, [8194]=1, [8195]=1, 
  [8196]=1, [8197]=1, [8198]=1, [8199]=1, [8200]=1, [8201]=1, [8202]=1, [8239]=1, [8287]=1, [12288]=1}

-- from nodes-tst.lua, adapted
local function somespace(n,all)
    if n then
        local id = n.id
        if id == glue_code then
            return (all or (n.spec.width ~= 0)) and glue_code
        elseif id == kern_code then
            return (all or (n.kern ~= 0)) and kern_code
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
local function somepenalty(n,value)
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
        if id == glyph_code then -- 37 is glyph as of 2013/04
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
