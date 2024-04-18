#!/usr/bin/env texlua

-- Identify the bundle and module
bundle = ""
module = "polyglossia"

stdengine    = "xetex"
checkengines = {"xetex","luatex"}

sourcefiledir = "tex"
sourcefiles = {"*.def", "*.ldf", "*.sty", "*.tex", "*.lde", "*.lua"}
installfiles = sourcefiles
