require('polyglossia') -- just in case...

local add_to_callback = luatexbase.add_to_callback
local remove_from_callback = luatexbase.remove_from_callback
local priority_in_callback = luatexbase.priority_in_callback

local get_quad = luaotfload.aux.get_quad -- needs luaotfload > 20130516

local next, type = next, type

local nodes, fonts, node = nodes, fonts, node

local insert_node_before = node.insert_before
local insert_node_after  = node.insert_after
local remove_node        = nodes.remove
local end_of_math        = node.end_of_math
local has_attribute      = node.has_attribute

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

local left=1
local right=2
local byte = unicode.utf8.byte

-- Now there is a good question: how do we now, in lua, what a \thinspace is?
-- In the LaTeX source (ltspace.dtx) it is defined as:
-- \def\thinspace{\kern .16667em }. I see no way of seeing if it has been
-- overriden or not... So we stick to this value.
local thinspace  = 0.16667 
-- thickspace is defined in amsmath.sty as:
-- \renewcommand{\;}{\mspace+\thickmuskip{.2777em}}. Same problem as above, we
-- stick to this fixed value.
local thickspace = 0.2777 -- 5/18

local mappings =  {
 [byte(':')] = {left,  thickspace}, --really?
 [byte('!')] = {left,  thinspace},
 [byte('?')] = {left,  thinspace},
 [byte(';')] = {left,  thinspace},
 [byte('‼')] = {left,  thinspace},
 [byte('⁇')] = {left,  thinspace},
 [byte('⁈')] = {left,  thinspace},
 [byte('⁉')] = {left,  thinspace},
 [byte('»')] = {left,  thinspace},
 [byte('>')] = {left,  thinspace},
 [byte('«')] = {right, thinspace}, 
 [byte('‹')] = {right, thinspace}, 
 }

local function set_spacings(thinsp, thicksp)
  for _, m in pairs(mappings) do
    if m[2] == thinspace then
      m[2] = thinsp
    elseif m[2] == thickspace then
      m[2] = thicksp
    end
  end
  thickspace = thicksp
  thinspace = thinsp
end

-- from typo-spa.lua
local function process(head)
    local done = false
    local start = head
    -- head is always begin of par (whatsit), so we have at least two prev nodes
    -- penalty followed by glue
    while start do
        local id = start.id
        if id == glyph_code then
            local attr = has_attribute(start, xpgfrptattr)
            if attr and attr > 0 then
                local char = start.char
                local map = mappings[char]
                --node.unset_attribute(start, xpgfrptattr) -- needed?
                if map then
                    local quad = get_quad(start.font) -- might be optimized
                    local prev = start.prev
                    if map[1] == left and prev then
                        local prevprev = prev.prev
                        local somespace = somespace(prev,true)
                        -- TODO: there is a question here: do we override a preceding space or not?...
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
                        insert_node_after(head,start,get_glue_node(map[2]*quad))
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

local callback_name = "pre_linebreak_filter"

local function activate()
  if not priority_in_callback (callback_name, "polyglossia-frpt.process") then
    add_to_callback(callback_name, process, "polyglossia-frpt.process", 1)
  end
end

local function desactivate()
  if priority_in_callback (callback_name, "polyglossia-frpt.process") then
    remove_from_callback(callback_name, "polyglossia-frpt.process")
  end
end

polyglossia.activate_frpt    = activate
polyglossia.desactivate_frpt = desactivate
polyglossia.set_spacings     = set_spacings
polyglossia.thinspace        = thinspace
polyglossia.thickspace       = thickpace
