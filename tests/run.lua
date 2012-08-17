require 'lfs'
require 'lpeg'

-- TODO Make that into a module.

local P, C, Cf, match = lpeg.P, lpeg.C, lpeg.Cf, lpeg.match

local slash = P'/'
local nonslash = 1 - slash

local ego = arg[0]
local abspath = ego

--[===[
We may provide a couple of switches on the command line, see usage.

TODO: add the possibility to run on a list of directories too.
]===]

usage = [==[
Usage:
	<ego> [-h | -x | -l] [file1[, file2, etc.]]

  -h prints a help message
  -x uses XeTeX exclusively
  -l uses LuaTeX exclusively
  (Default: both)

  The remainder of the arguments is a list of files: we run them
  consecutively (instead of the content of the directory containing
  <ego>)
]==]

-- Resolve absolute path of <ego>
local currdir = lfs.currentdir()
if not match(slash, ego) then -- Path is not absolute
  abspath = currdir .. '/' .. ego
end


-- Parse command-line arguments
local arg1 = arg[1]

formats = { 'xelatex', 'lualatex' }
files = { }

if arg1 == '-h' then
  print(usage)
  return
elseif arg1 == '-x' then
  formats = { 'xelatex' }
elseif arg1 == '-l' then
  formats = { 'lualatex' }
elseif #arg > 0 then -- arg is a list of files
  -- TODO does not yet work.
  if not match(slash, ego) then -- Path is not absolute
    for _, f in ipairs(arg) do
      table.insert(files, currdir .. '/' .. f)
    end
  end
end

local function join(a, b)
  local aa = match(C((slash * nonslash^1)^0), a)
  return aa .. '/' .. b
end

local dirnamepatt = Cf(C(slash) * (C(nonslash^1) * slash)^0, join)

local testdir, a, b, c = match(dirnamepatt, abspath)
print(testdir)
error()

-- TODO I don’t like that at all ...
local alnum = lpeg.S'-_' + lpeg.R'az' + lpeg.R'AZ' + lpeg.R'09'
local dottex = alnum^0 * P'.tex' * -1

-- lfs.chdir(testdir + 'out')

local outdir = testdir .. 'out'
lfs.mkdir(outdir) -- returns nil and string 'File exists' if it exists already.
lfs.chdir(outdir)

local basenames = { }
for tex in lfs.dir(testdir) do
  if match(dottex, tex) then
    local basename = match(C(alnum^0), tex)
    table.insert(basenames, basename)
  end
end

local errors = { }
for _, format in ipairs(formats) do
  errors[format] = { }
end

-- TODO TODO TODO Test with LuaTeX as well, now!
-- Designed for Lua 5.1 (see _VERSION).  os.execute returns only the command’s return value.
if #files > 0 then
  -- TODO (in relation with the “does not yet work” above)
else
  for _, format in ipairs(formats) do
    for _, basename in ipairs(basenames) do
      local tex = basename .. '.tex'
      if match(dottex, tex) then
        os.execute(format .. " " .. testdir .. '/' .. tex)
        os.execute("pdftotext -layout -enc UTF-8 " .. outdir .. '/' .. basename ..  '.pdf' .. ' >/dev/null')
        local retvalue = os.execute("diff " .. testdir .. '/ref/' .. basename .. '.txt ' ..  testdir .. '/out/' .. basename .. '.txt')
        if(retvalue == 0) then
          errors[format][tex] = false
          print('Test file ' .. tex .. ' OK.')
        else
          errors[format][tex] = true
          print('Something went wrong with ' .. tex)
        end
      end
    end
  end
end

local success = true
for form, formerrs in pairs(errors) do
  for _, err in pairs(formerrs) do
    if err then success = false; break end
  end
end

print()

if success then
  print('All tests passed.')
else
  print('Some tests are failing.  There were problems with the following files: ')
  for form, formerrs in pairs(errors) do
    print('---- ' .. form)
    for tex, err in pairs(formerrs) do
      if err then
        print(tex)
      end
    end
  end
  print('----')
  print()
  print('Sorry!')
end
