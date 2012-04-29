require 'lfs'
require 'lpeg'

local P, C, match = lpeg.P, lpeg.C, lpeg.match

local slash = P'/'
local nonslash = 1 - slash

local ego = arg[0]
local abspath = ego

if not match(slash, ego) then -- Path is not absolute
  abspath = lfs.currentdir() .. '/' .. ego
end

print(abspath)

-- TODO no idea why it doesn’t work the other way round: C((slash * nonslash^1)^1) * slash
local dirnamepatt = C(slash * (nonslash^1 * slash)^0)

local testdir = match(dirnamepatt, abspath)
print(testdir)

-- TODO I don’t like that at all ...
local alnum = lpeg.S'-_' + lpeg.R'az' + lpeg.R'AZ'
local dottex = alnum^0 * P'.tex' * -1

-- lfs.chdir(testdir + 'out')

local outdir = testdir .. 'out'
lfs.mkdir(outdir) -- returns nil and string 'File exists' if it exists already.
lfs.chdir(outdir)

for tex in lfs.dir(testdir) do
  if match(dottex, tex) then
    os.execute("xelatex " .. testdir .. '/' .. tex)
  end
end
