local module = {
    name = "xpg-frpt",
    version = 0.2,
    date = "2013/04/23",
    description = "Companion to Polyglossia for french punctuation",
    author = "Elie Roux",
    copyright = "Elie Roux",
    license = "CC0"
}

local error, warning, info, log =
    luatexbase.provides_module(module)

xpg_frpt = xpg_frpt or {}


local add_to_callback = luatexbase.add_to_callback
local remove_from_callback = luatexbase.remove_from_callback
local priority_in_callback = luatexbase.priority_in_callback

local next, type = next, type
local utfchar = utf.char

local nodes, fonts, node = nodes, fonts, node

local insert_node_before = node.insert_before
local insert_node_after  = node.insert_after
local remove_node        = nodes.remove
local end_of_math        = node.end_of_math
local has_attribute      = node.has_attribute

local texattribute       = tex.attribute


local nodepool           = nodes.pool
local tasks              = nodes.tasks

local new_penalty        = nodepool.penalty
local new_glue           = nodepool.glue


-- node types as of April 2013
local glue_code     = 10
local glue_spec_code= 47
local glyph_code    = 37
local penalty_code  = 12
local kern_code     = 11

-- we make a new node, so that we can copy it later on
local penalty_node  = node.new(penalty_code)
penalty_node.penalty = 10000

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

local xpgfrptattr = luatexbase.attributes['xpg@frpt']
--texio.write_nl(xpgfrptattr)

local left=1
local right=2
local byte = unicode.utf8.byte

local spacing = 0.16 -- \thinspace is 1/6 of em

local mappings =  {
 [byte(':')] = {left, 0.16},
 [byte('!')] = {left, 0.16},
 [byte('?')] = {left, 0.16},
 [byte(';')] = {left, 0.16},
 [byte('‼')] = {left, 0.16},
 [byte('⁇')] = {left, 0.16},
 [byte('⁈')] = {left, 0.16},
 [byte('⁉')] = {left, 0.16},
 [byte('»')] = {left, 0.16},
 [byte('>')] = {left, 0.16},
 [byte('«')] = {right, 0.16}, 
 [byte('‹')] = {right, 0.16}, 
 }

local function set_spacing(ems) -- em size
  if ems == spacing then return end
  spacing = ems
  for _, m in pairs(mappings) do
    m[2] = ems
  end
end

-- from typo-spa.lua
local function process(head)
    local done = false
    local start = head
    -- head is always begin of par (whatsit), so we have at least two prev nodes
    -- penalty followed by glue
    while start do
        local id = start.id
        if id == glyph_code then -- 37 is glyph as of 2013/04
            local attr = has_attribute(start, xpgfrptattr)
            if attr and attr > 0 then
                local char = start.char
                local map = mappings[char]
                --node.unset_attribute(start, xpgfrptattr) -- needed?
                if map then
                    local quad = font.fonts[start.font].parameters.quad -- might be optimized
                    local prev = start.prev
                    if map[1] == left and prev then
                        local prevprev = prev.prev
                        local somespace = somespace(prev,true)
                        if somespace then
                            local somepenalty = somepenalty(prevprev,10000)
                            if somepenalty then
                                head = remove_node(head,prev,true)
                                head = remove_node(head,prevprev,true)
                            else
                                head = remove_node(head,prev,true)
                            end
                        end
                        insert_node_before(head,start,get_penalty_node())
                        insert_node_before(head,start,get_glue_node(map[2]*quad))
                        done = true
                    end
                    local next = start.next
                    if map[1] == right and next then
                        local nextnext = next.next

                        local somepenalty = somepenalty(next,10000)
                        if somepenalty then
                            local somespace = somespace(nextnext,true)
                            if somespace then
                                head = remove_node(head,next,true)
                                head = remove_node(head,nextnext,true)
                            end
                        else
                            local somespace = somespace(next,true)
                            if somespace then
                                head = remove_node(head,next,true)
                            end
                        end
                        insert_node_after(head,start,get_glue_node(right*quad))
                        insert_node_after(head,start,get_penalty_node())
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

local function activate()
  if not priority_in_callback ("pre_linebreak_filter", "xpg-frpt.process") then
    add_to_callback("pre_linebreak_filter", process, "xpg-frpt.process")
  end
end

local function desactivate()
  if priority_in_callback ("pre_linebreak_filter", "xpg-frpt.process") then
    remove_from_callback("pre_linebreak_filter", "xpg-frpt.process")
  end
end

xpg_frpt.activate    = activate
xpg_frpt.desactivate = desactivate
xpg_frpt.set_spacing = set_spacing
xpg_frpt.spacing     = spacing
