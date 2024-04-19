#!/usr/bin/env texlua

-- Identify the bundle and module
bundle = ""
module = "polyglossia"

stdengine    = "xetex"
checkengines = {"xetex","luatex"}
checkruns = 2
checkconfigs = {"build","config-lua"}
sourcefiledir = "tex"
docfiledir = "doc"
sourcefiles = {"*.def", "*.ldf", "*.sty", "*.lua", "**/*.map"}
installfiles = {"*.def", "*.ldf", "*.sty", "*.lua", "*.map", "*.tec"}
tdslocations = {
	"fonts/misc/xetex/fontmapping/" .. module .. "/" .. "*.map",
	"fonts/misc/xetex/fontmapping/" .. module .. "/" .. "*.tec",
	}
unpackfiles = {"*.map"}
unpackexe = "teckit_compile"
packtdszip = true
typesetexe = "xelatex"
typesetfiles = {"polyglossia.tex"}

tagfiles = {"tex/polyglossia.sty", "tex/*.ldf", "tex/*.lua", "doc/polyglossia.tex", "README.md"}
function update_tag(file,content,tagname,tagdate)
  if string.match(file, "%.ldf$") then
    return string.gsub(content,
      "%% Language definition file %(part of polyglossia v%d%.%d+ %-%- %d%d%d%d/%d%d/%d%d%)\n",
      "%% Language definition file (part of polyglossia " .. tagname .. " -- " .. tagdate .. ")\n")
  elseif string.match(file, "%.lua$") then
    return string.gsub(content,
      "\n%-%- part of polyglossia v%d%.%d+ %-%- %d%d%d%d/%d%d/%d%d\n",
      "\n-- part of polyglossia " .. tagname .. " -- " .. tagdate .. "\n")
  elseif file == "polyglossia.tex" then
    return string.gsub(content,
      "\n\\subsection%*{%d%.%d %(forthcoming%)}\n",
      "\n\\subsection*{" .. tagname .. " (" .. tagdate .. ")}\n")
  elseif file == "polyglossia.sty" then
    return string.gsub(content,
      "\n  {polyglossia} {%d%d%d%d/%d%d/%d%d} {v%d%.%d+}\n",
      "\n  {polyglossia} {" .. tagdate .. "} {" .. tagname .. "}\n")
  elseif file == "README.md" then
    content = string.gsub(content,
      "# THE POLYGLOSSIA PACKAGE v%d%.%d\n",
      "# THE POLYGLOSSIA PACKAGE " .. tagname .. "\n")
    local names = {"Arthur", "Udi", "Jürgen"}
    for name = 1, #names do
      content  = string.gsub(content,
        "(%-%d%d%d%d) (" .. names[name] .. ")",
        "-" .. string.sub(tagdate, 1, 4) .. " %2")
    end
    return content
  end
  return content
end
