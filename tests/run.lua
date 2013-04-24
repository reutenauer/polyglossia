require 'lfs'
require 'lpeg'

-- TODO Un-hardcode that.
package.path = package.path .. ';/usr/local/texlive/2012/texmf-dist/tex/context/base/?.lua'
require 'l-table'

-- TODO Make that into a module.

local P, C, Cf, match = lpeg.P, lpeg.C, lpeg.Cf, lpeg.match

local slash = P'/'
local nonslash = 1 - slash

local ego = arg[0]
local abspath = ego

--[===[
We provide a couple of switches on the command line, see usage.

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
-- TODO collapse stretches of '<dir>/..'
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
  -- print(table.serialize(arg))
  if not match(slash, ego) then -- Path is not absolute
    for _, f in ipairs(arg) do
      print(f)
      table.insert(files, currdir .. '/' .. f)
    end
  end
end

local function join(a, b)
  local aa = match(C((slash * nonslash^1)^0), a)
  return aa .. '/' .. b
end

local dirnamepatt = Cf(C(slash) * (C(nonslash^1) * slash)^0, join)

local testdir = match(dirnamepatt, abspath)

-- TODO I don’t like that at all ...
local alnum = lpeg.S'-_' + lpeg.R'az' + lpeg.R'AZ' + lpeg.R'09'
local dottex = alnum^0 * P'.tex' * -1

-- lfs.chdir(testdir + 'out')

local outdir = join(testdir, 'out')
-- returns nil and string 'File exists' if it exists already, but doesn’t raise an error.
lfs.mkdir(outdir)
lfs.chdir(outdir)

local errors = { }
for _, format in ipairs(formats) do
  errors[format] = { }
end

local basenames = { }

-- TODO Use join a little bit all over the place
-- Designed for Lua 5.1 (see _VERSION).  os.execute returns only the command’s return value.
if #files > 0 then
  print(table.serialize(files, "files"))
  for _, f in ipairs(files) do
    local dt = P'.tex'
    local basename = match(C((1 - dt)^1) * dt * -1, f)
    if basename then
      print("matches")
      dirname, basename = match(dirnamepatt * C(nonslash^1), basename)
      table.insert(basenames, basename)
    end
  end
  -- TODO (in relation with the “does not yet work” above)
else
  for tex in lfs.dir(testdir) do
    if match(dottex, tex) then
      local basename = match(C(alnum^0), tex)
      table.insert(basenames, basename)
    end
  end
end

print(table.serialize(basenames, "basenames"))
print(table.serialize(formats, "formats"))

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
