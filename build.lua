#!/usr/bin/env texlua

-- Identify the bundle and module
bundle = ""
module = "polyglossia"

stdengine    = "xetex"
checkengines = {"xetex","luatex"}
checkruns = 2
checkconfigs = {"build","configfiles/config-lua","configfiles/config-autogen"}
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

function gen_test_from_gloss()
	local testdoc = [[
\input{regression-test.tex}
\documentclass{article}
\AddToHook{package/bidi/before}{\let\xpgorigtypeout\typeout
\def\typeout#1{\let\typeout\xpgorigtypeout}}
\usepackage{polyglossia}
\START
\setmainlanguage{%s}
\OMIT
\begin{document}
\day=6
\month=8
\year=2012
\setbox0=\hbox{\today.}
\TIMO\showbox0\END
			]]
	local gloss_files = filelist("./tex", "gloss-*.ldf")
	for file = 1, #gloss_files do
		local file_name = gloss_files[file]
		local gloss_name = jobname(file_name)
		local language = gloss_name:sub(7)
		if fileexists('testfiles/autogen/test-gloss-' .. language .. '.lvt') and
			not true then else -- change to true to overwrite existing tests
		f = io.open('testfiles/autogen/test-gloss-' .. language .. '.lvt', 'w')
    		f:write(string.format(testdoc, language))
    		f:close()
    		print(language .. ": " .. file .. "/" .. #gloss_files)
    		run('.', 'l3build save -cconfigfiles/config-autogen test-gloss-' .. language)
    		run('.', 'l3build save -e luatex -cconfigfiles/config-autogen test-gloss-' .. language)
	end end
	return 0
end

function gen_pdf_from_example()
   local example_files = filelist("./doc", "*.tex")
   local error_level = 0
   error_level = mkdir("./build/genpdf")
   for example = 1, #example_files do
       local example_name = jobname(example_files[example])
       if example_name == "polyglossia" then
           error_level = error_level + (
               tex("./../../doc/polyglossia", "./build/genpdf", "xelatex --interaction=nonstopmode") +
               tex("./../../doc/polyglossia", "./build/genpdf", "xelatex --interaction=nonstopmode") +
               tex("./../../doc/polyglossia", "./build/genpdf", "xelatex --interaction=nonstopmode")
           )
       else
           error_level = error_level +
               tex("./../../doc/" .. example_name, "./build/genpdf", "xelatex --interaction=nonstopmode")
       end
   end
   error_level = error_level + cp("*.pdf", "./build/genpdf", "./generated")
   return error_level
end

function pre_release()
    call({"."}, "tag")
    gen_pdf_from_example()
    call({"."}, "ctan", {})
    rm("./doc", "*.pdf")    
end

--option_list["force"] = { desc  = "overwrite existing tests with gentest", -- does not work... why?
--			type = "boolean"}
target_list["gentest"] = { func = gen_test_from_gloss, 
			desc = "generate minimal test files from gloss fies"}
target_list["prerelease"] = { func = pre_release, 
			desc = "update tags, generate pdfs, build zip for ctan"}
target_list["genpdf"] = { func = gen_pdf_from_example, 
			desc = "generate pdf files in the generated directory from the files in the doc directory"}

