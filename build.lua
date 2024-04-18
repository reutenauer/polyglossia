#!/usr/bin/env texlua

-- Identify the bundle and module
bundle = ""
module = "polyglossia"

stdengine    = "xetex"
checkengines = {"xetex","luatex"}

sourcefiles = {"tex/*.def", "tex/*.ldf", "tex/*.sty", "tex/*.tex", 
		"tex/*.lde", "tex/*.lua", "fontmapping/*.map"}
installfiles = {"*.def", "*.ldf", "*.sty", "*.tex", "*.lde", "*.lua", "*.map", "*.tec"}
tdslocations = {
	"fonts/misc/xetex/fontmapping/" .. module .. "/" .. "*.map",
	"fonts/misc/xetex/fontmapping/" .. module .. "/" .. "*.tec"
	}
unpackfiles = {"*.map"}
unpackexe = "teckit_compile"