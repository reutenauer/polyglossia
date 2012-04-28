require 'lfs'
require'lpeg'

local P, match = lpeg.P, lpeg.match

local slash = P'/'
local dot = P'.'

local dir = arg[0]
local testdir = dir

if not match(slash, dir) then -- Path is not absolute
  if match(dot, dir) then -- Path is relative
                          -- and can be appended to current directory
    testdir = lfs.currentdir() .. '/' .. dir
  else -- testdir is current directory
    testdir = lfs.currentdir()
  end
end

-- local dottex = (P(1) + P'-')^0 * P'.tex' * -1 -- Doesn’t work
-- local dottex = lpeg.R'az' * P'.tex' * -1 -- Doesn’t work
local dottex = (lpeg.S'-_' + lpeg.R'az' + lpeg.R'AZ')^0 * P'.tex' * -1
-- local dottex = lpeg.R'!~'^0 * P'.tex' * -1 -- Doesn’t work

for tex in lfs.dir(testdir) do
  if match(dottex, tex) then
    os.execute("xelatex " .. tex)
  end
end
