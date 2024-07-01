# Python script to generate bcp47-compliant alias files and language aliases.
# Below are mappings of the currently supported polyglossia languages
# (+ babelnames) to bcp47 tags and of bcp-47 tags to *.ldf file names.

from __future__ import print_function

import fileinput
import logging
import sys

# Dic 1: babelname : bcp47
babelname2bcp47 = {
    "acadian" : "fr-CA",
    "afrikaans" : "af",
    "albanian" : "sq",
    "american" : "en-US",
    "amharic" : "am",
    "arabic" : "ar",
    "armenian" : "hy",
    "asturian" : "ast",
    "australian" : "en-AU",
    "austrian" : "de-AT-1901",
    "bahasa" : "id",
    "bahasai" : "id",
    "bahasam" : "zsm",
    "basque" : "eu",
    "belarusian" : "be",
    "bengali" : "bn",
    "bosnian" : "bs",
    "brazil" : "pt-BR",
    "breton" : "br",
    "british" : "en-GB",
    "bulgarian" : "bg",
    "canadian" : "en-CA",
    "canadien" : "fr-CA",
    "catalan" : "ca",
    "chinese" : "zh",
    "coptic" : "cop",
    "croatian" : "hr",
    "czech" : "cz",
    "danish" : "da",
    "divehi" : "dv",
    "dutch" : "nl",
    "english" : "en-US",
    "esperanto" : "eo",
    "estonian" : "et",
    "farsi" : "fa",
    "finnish" : "fi",
    "french" : "fr-FR",
    "friulan" : "fur",
    "friulian" : "fur",
    "gaelic" : "ga",
    "galician" : "gl",
    "georgian" : "ka",
    "german" : "de-DE",
    "germanb" : "de-DE-1901",
    "greek" : "el-monoton",
    "hebrew" : "he",
    "hindi" : "hi",
    "hungarian" : "hu",
    "icelandic" : "is",
    "interlingua" : "ia",
    "irish" : "ga",
    "italian" : "it",
    "japanese" : "ja",
    "kannada" : "kn",
    "khmer" : "km",
    "korean" : "ko",
    "kurdish" : "ckb",
    "kurmanji" : "kmr",
    "lao" : "lo",
    "latin" : "la",
    "classiclatin" : "la-x-classic",
    "ecclesiasticlatin" : "la-x-ecclesia",
    "medievallatin" : "la-x-medieval",
    "latvian" : "lv",
    "lithuanian" : "lt",
    "lowersorbian" : "dsb",
    "lsorbian" : "dsb",
    "macedonian" : "mk",
    "magyar" : "hu",
    "malay" : "id",
    "malayalam" : "ml",
    "marathi" : "mr",
    "mongolian" : "mn",
    "naustrian" : "de-AT-1996",
    "newzealand" : "en-NZ",
    "ngerman" : "de-DE-1996",
    "nko" : "nko",
    "norsk" : "nb",
    "norwegian" : "nn",
    "nswissgerman" : "de-CH-1996",
    "nynorsk" : "nn",
    "occitan" : "oc",
    "persian" : "fa",
    "piedmontese" : "pms",
    "polish" : "pl",
    "polutonikogreek" : "el-polyton",
    "portuges" : "pt-PT",
    "portuguese" : "pt-PT",
    "romanian" : "ro",
    "romansh" : "rm",
    "russian" : "ru",
    "sami" : "se",
    "samin" : "se",
    "sanskrit" : "sa-Deva",
    "scottish" : "gd",
    "serbian" : "sr-Latn",
    "serbianc" : "sr-Cyrl",
    "slovak" : "sk",
    "slovene" : "sl",
    "slovenian" : "sl",
    "sorbian" : "hsb",
    "spanish" : "es-ES",
    "spanishmx" : "es-MX",
    "swedish" : "sv",
    "swissgerman" : "de-CH-1901",
    "syriac" : "syr",
    "tamil" : "ta",
    "telugu" : "te",
    "thai" : "th",
    "tibetan" : "bo",
    "turkish" : "tr",
    "turkmen" : "tk",
    "ukrainian" : "uk",
    "uppersorbian" : "hsb",
    "urdu" : "ur",
    "usorbian" : "hsb",
    "vietnamese" : "vi",
    "welsh" : "cy",
}

# Dic2: bcp57 : langname
# This refers to the master ldf files.
bcp472lang = {
    "aeb" : "arabic",# Tunisia
    "af" : "afrikaans",
    "afb" : "arabic",# Gulf States
    "am" : "amharic",
    "apd" : "arabic",# Sudan
    "ar" : "arabic",
    "ar-MR" : "arabic",# Mauritania
    "ar-IQ" : "arabic",# Iraq
    "ar-JO" : "arabic",# Jordan
    "ar-LB" : "arabic",# Lebanon
    "ar-PS" : "arabic",# Lebanon
    "ar-SY" : "arabic",# Syria
    "ar-YE" : "arabic",# Yemen
    "arq" : "arabic",# Algeria
    "ary" : "arabic",# Morocco
    "arz" : "arabic",# Egypt
    "ast" : "asturian",
    "ayl" : "arabic",# Libya
    "be" : "belarusian",
    "be-tarask" : "belarusian",
    "bg" : "bulgarian",
    "bn" : "bengali",
    "bo" : "tibetan",
    "br" : "breton",
    "bs" : "bosnian",
    "ca" : "catalan",
    "ckb" : "kurdish",
    "ckb-Arab" : "kurdish",
    "ckb-Latn" : "kurdish",
    "cop" : "coptic",
    "cy" : "welsh",
    "cz" : "czech",
    "da" : "danish",
    "de" : "german",
    "de-Latf-AT" : "german",
    "de-AT" : "german",
    "de-Latf-CH" : "german",
    "de-CH" : "german",
    "de-Latf-DE" : "german",
    "de-DE" : "german",
    "de-AT-1901" : "german",
    "de-AT-1996" : "german",
    "de-CH-1901" : "german",
    "de-CH-1996" : "german",
    "de-DE-1901" : "german",
    "de-DE-1996" : "german",
    "de-Latf" : "german",
    "de-Latf-AT-1901" : "german",
    "de-Latf-AT-1996" : "german",
    "de-Latf-CH-1901" : "german",
    "de-Latf-CH-1996" : "german",
    "de-Latf-DE-1901" : "german",
    "de-Latf-DE-1996" : "german",
    "dsb" : "sorbian",
    "dv" : "divehi",
    "el" : "greek",
    "el-monoton" : "greek",
    "el-polyton" : "greek",
    "en" : "english",
    "en-AU" : "english",
    "en-CA" : "english",
    "en-GB" : "english",
    "en-NZ" : "english",
    "en-US" : "english",
    "eo" : "esperanto",
    "es" : "spanish",
    "es-ES" : "spanish",
    "es-MX" : "spanish",
    "et" : "estonian",
    "eu" : "basque",
    "fa" : "persian",
    "fi" : "finnish",
    "fr" : "french",
    "fr-CA" : "french",
    "fr-FR" : "french",
    "fur" : "friulian",
    "ga" : "gaelic",
    "gd" : "gaelic",
    "gl" : "galician",
    "grc" : "greek",
    "he" : "hebrew",
    "hi" : "hindi",
    "hr" : "croatian",
    "hsb" : "sorbian",
    "hu" : "hungarian",
    "hy" : "armenian",
    "ia" : "interlingua",
    "id" : "malay",
    "is" : "icelandic",
    "it" : "italian",
    "ja" : "japanese",
    "ka" : "georgian",
    "km" : "khmer",
    "kmr" : "kurdish",
    "kmr-Arab" : "kurdish",
    "kmr-Latn" : "kurdish",
    "kn" : "kannada",
    "ko" : "korean",
    "ku" : "kurdish",
    "ku-Arab" : "kurdish",
    "ku-Latn" : "kurdish",
    "la" : "latin",
    "la-x-classic" : "latin",
    "la-x-ecclesia" : "latin",
    "la-x-medieval" : "latin",
    "lo" : "lao",
    "lt" : "lithuanian",
    "lv" : "latvian",
    "mk" : "macedonian",
    "ml" : "malayalam",
    "mn" : "mongolian",
    "mr" : "marathi",
    "nb" : "norwegian",
    "nko" : "nko",
    "nl" : "dutch",
    "nn" : "norwegian",
    "oc" : "occitan",
    "pl" : "polish",
    "pms" : "piedmontese",
    "pt" : "portuguese",
    "pt-BR" : "portuguese",
    "pt-PT" : "portuguese",
    "rm" : "romansh",
    "ro" : "romanian",
    "ru" : "russian",
    "ru-petr1708" : "russian",
    "ru-luna1918" : "russian",
    "sa" : "sanskrit",
    "sa-Deva" : "sanskrit",
    "sa-Beng" : "sanskrit",
    "sa-Gujr" : "sanskrit",
    "sa-Knda" : "sanskrit",
    "sa-Mlym" : "sanskrit",
    "sa-Telu" : "sanskrit",
    "se" : "sami",
    "sk" : "slovak",
    "sl" : "slovenian",
    "sq" : "albanian",
    "sr" : "serbian",
    "sr-Cyrl" : "serbian",
    "sr-Latn" : "serbian",
    "sv" : "swedish",
    "syr" : "syriac",
    "ta" : "tamil",
    "te" : "telugu",
    "th" : "thai",
    "tk" : "turkmen",
    "tr" : "turkish",
    "uk" : "ukrainian",
    "ur" : "urdu",
    "vi" : "vietnamese",
    "zh" : "chinese",
    "zh-CN" : "chinese",
    "zh-TW" : "chinese",
    "zsm" : "malay",
}

bcp472opts = {
    "aeb" : "locale=tunisia",
    "afb" : "locale=default",
    "apd" : "locale=default",
    "ar-MR" : "locale=mauritania",
    "ar-IQ" : "locale=mashriq",
    "ar-JO" : "locale=mashriq",
    "ar-LB" : "locale=mashriq",
    "ar-PS" : "locale=mashriq",
    "ar-SY" : "locale=mashriq",
    "ar-YE" : "locale=default",
    "arq" : "locale=algeria",
    "ary" : "locale=morocco",
    "arz" : "locale=default",
    "ayl" : "locale=libya",
    "be-tarask" : "spelling=classic",
    "ckb" : "variant=sorani",
    "ckb-Arab" : "variant=sorani,script=Arabic",
    "ckb-Latn" : "variant=sorani,script=Latin",
    "de-AT-1901" : "variant=austrian,spelling=old",
    "de-AT-1996" : "variant=austrian,spelling=new",
    "de-CH-1901" : "variant=swiss,spelling=old",
    "de-CH-1996" : "variant=swiss,spelling=new",
    "de-DE-1901" : "variant=german,spelling=old",
    "de-DE-1996" : "variant=german,spelling=new",
    "de-Latf" : "script=blackletter",
    "de-Latf-AT-1901" : "variant=austrian,spelling=old,script=blackletter",
    "de-Latf-AT-1996" : "variant=austrian,spelling=new,script=blackletter",
    "de-Latf-CH-1901" : "variant=swiss,spelling=old,script=blackletter",
    "de-Latf-CH-1996" : "variant=swiss,spelling=new,script=blackletter",
    "de-Latf-DE-1901" : "variant=german,spelling=old,script=blackletter",
    "de-Latf-DE-1996" : "variant=german,spelling=new,script=blackletter",
    "de-Latf-AT" : "variant=austrian,spelling=new,script=blackletter",
    "de-AT" : "variant=austrian,spelling=new",
    "de-Latf-CH" : "variant=swiss,spelling=new,script=blackletter",
    "de-CH" : "variant=swiss,spelling=new",
    "de-Latf-DE" : "variant=german,spelling=new,script=blackletter",
    "de-DE" : "variant=german,spelling=new",
    "dsb" : "variant=lower",
    "el-monoton" : "variant=monotonic",
    "el-polyton" : "variant=polytonic",
    "en-AU" : "variant=australian",
    "en-CA" : "variant=canadian",
    "en-NZ" : "variant=newzealand",
    "en-GB" : "variant=british",
    "en-US" : "variant=us",
    "es-ES" : "variant=spanish",
    "es-MX" : "variant=mexican",
    "fr-CA" : "variant=canadian",
    "fr-FR" : "variant=french",
    "ga" : "variant=irish",
    "gd" : "variant=scottish",
    "grc" : "variant=ancient",
    "hsb" : "variant=upper",
    "id" : "variant=indonesian",
    "kmr" : "variant=kurmanji",
    "kmr-Arab" : "variant=kurmanji,script=Arabic",
    "kmr-Latn" : "variant=kurmanji,script=Latin",
    "ku-Arab" : "script=Arabic",
    "ku-Latn" : "script=Latin",
    "la-x-classic" : "variant=classic",
    "la-x-ecclesia" : "variant=ecclesiastic",
    "la-x-medieval" : "variant=medieval",
    "nb" : "variant=bokmal",
    "nn" : "variant=nynorsk",
    "pt-BR" : "variant=brazilian",
    "pt-PT" : "variant=portuguese",
    "ru-petr1708" : "spelling=old",
    "ru-luna1918" : "spelling=modern",
    "sa-Deva" : "script=Devanagari",
    "sa-Beng" : "script=Bengali",
    "sa-Gujr" : "script=Gujarati",
    "sa-Knda" : "script=Kannada",
    "sa-Mlym" : "script=Malayalam",
    "sa-Telu" : "script=Telugu",
    "sa-Latn" : "script=Latin",
    "sr-Cyrl" : "script=Cyrillic",
    "sr-Latn" : "script=Latin",
    "zh-CN" : "variant=simplified",
    "zh-TW" : "variant=traditional",
    "zsm" : "variant=malaysian",
}

def main():
    Glosses = False
    Aliases = False
    IDS     = False
    Table   = False

    if len(sys.argv) == 1:
        Glosses = True
        Aliases = True
        IDS     = True
        Table   = True

    if "-g" in sys.argv:
        Glosses = True
    if "-a" in sys.argv:
        Aliases = True
    if "-i" in sys.argv:
        IDS     = True
    if "-t" in sys.argv:
        Table   = True

    if Glosses:
        generate_glosses()
    if Aliases:
        generate_aliases()
    if IDS:
        generate_ids()
    if Table:
        generate_table()


def generate_glosses():
    for key in bcp472lang:
        val = bcp472lang[key]
        f = open(("gloss-%s.ldf" % key),"w+")
        f.write(("\\ProvidesFile{gloss-%s.ldf}[polyglossia: module for %s (%s)]" % (key,key,val)))
        f.write("\n\n% We provide this as a bcp47-compliant alias")
        f.write(("\n\n\\InheritGlossFile{%s}" % val))
        f.write("\n\n\\endinput\n")
        f.close()

logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

def generate_aliases():
    aliases = []
    for key in bcp472lang:
        val = key
        gloss = bcp472lang[val]
        fertig = False
        addition = ("\\setlanguagealias*{%s}{%s}\n" % (gloss, val))
        file_path = "../tex/" + ("gloss-%s.ldf" % gloss)
        logging.debug("file path: %s" % file_path)
        glossval = gloss + ":" + val
        if val in bcp472opts:
            addition = ("\\setlanguagealias*[%s]{%s}{%s}" % (bcp472opts[val], gloss, val))
        for line in fileinput.FileInput(file_path,inplace=True):
            if glossval not in aliases and not fertig and "% BCP-47 compliant aliases\n" in line:
                line = line.replace(line, line + addition + "\n")
                logging.debug("replace line: %s" % line)
                fertig = True
                aliases.append(glossval)
            print(line, end="")
        if not fertig:
            addition = "% BCP-47 compliant aliases\n" + addition
            for line in fileinput.FileInput(file_path,inplace=True):
                if glossval not in aliases and not fertig and line == "}\n":
                    line = line.replace(line, line + "\n" + addition)
                    logging.debug("replace line: %s" % line)
                    fertig = True
                    aliases.append(glossval)
                print(line, end="")

def generate_ids():
    for key in babelname2bcp47:
        val = babelname2bcp47[key]
        gloss = key
        addition = ("  bcp47=%s,\n" % val)
        file_path = "../tex/" + ("gloss-%s.ldf" % gloss)
        for line in fileinput.FileInput(file_path,inplace=True):
            if "\\PolyglossiaSetup{" in line:
                line = line.replace(line, line + addition)
            print(line, end="")

def generate_table():
    f = open("bcp47table.tex","w+")
    f.write("\\begin{longtable}[c]{lll}\n")
    f.write("\\caption{\\label{tab:BCP47-polyglossia}BCP47-polyglossia language name matching}")
    f.write("\\\\\n")
    f.write("\\toprule\n")
    f.write("\\textbf{BCP-47 tag} & \\textbf{Polyglossia name} & \\textbf{Polyglossia options}\\\\\n")
    f.write("\\midrule\n")
    f.write("\\endfirsthead\n")
    f.write("\\toprule\n")
    f.write("\\textbf{BCP-47 tag} & \\textbf{Polyglossia name} & \\textbf{Polyglossia options}\\\\\n")
    f.write("\\midrule\n")
    f.write("\\endhead\n")
    for key, gloss in sorted(bcp472lang.items()):
        val = key
        col1 = val
        col2 = gloss
        col3 = ""
        if val in bcp472opts:
            col3 = bcp472opts[val]
        f.write("%s & %s & %s \\\\\n" % (col1, col2, col3))
    f.write("\\bottomrule\n")
    f.write("\\end{longtable}\n")
    f.close()


if __name__ == "__main__":
    main()
