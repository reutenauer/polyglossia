#!/bin/sh

version="$1"
announcement="$2"
filename=polyglossia.zip

curl -i \
    -d "pkg=polyglossia&vers=$version&author=Arthur%20Reutenauer&email=arthur%2Ereutenauer%40normalesup%2Eorg&description=Polyglossia%20is%20an%20alternative%20to%20Babel%20for%20XeLaTeX%20and%20LuaLaTeX&ctanPath=%2Fmacros%2Flatex%2Fcontrib%2Fpolyglossia&type=announce&announcement=$announcement&license=lppl&file=`cat "filename"`" \
    http://ctan.org/upload/save
