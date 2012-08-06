-- Generate (very) simple tests for gloss files.

-- TODO Make that into a module

local P, C, S, R, match = lpeg.P, lpeg.C, lpeg.S, lpeg.R, lpeg.match

local slash = P'/'
local nonslash = 1 - slash

local ego = arg[0]
local abspath = ego

if not match(slash, ego) then -- Path is not absolute
  abspath = lfs.currentdir() .. '/' .. ego
end

local dirnamepatt = C(slash * (nonslash^1 * slash)^0)
local glossdir = match(dirnamepatt, abspath) .. '../tex'

local alnum = S'-_' + R'az' + R'AZ' + R'09'
local glosspatt = P'gloss-' * C(alnum^0) * P'.ldf' * -1

local basenames = { }
for gloss in lfs.dir(glossdir) do
  local lang = match(glosspatt, gloss)
  if lang then
    print(lang)
  end
end
