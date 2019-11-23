# Python script to generate bcp47-compliant alias files and language aliases.
# Below are mappings of the currently supported polyglossia languages
# (+ babelnames) to bcp47 tags and of bcp-47 tags to *.ldf file names.

import fileinput
import logging, sys

# Dic 1: babelname : bcp47
babelname2bcp47 = {
    "acadien" : "fr-CA",
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
    "latinclassic" : "la-xclassic",
    "latinecclesiastic" : "la-xecclesiastic",
    "latinmedieval" : "la-xmedieval",
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
    "de-AT-Latf" : "german",
    "de-AT" : "german",
    "de-CH-Latf" : "german",
    "de-CH" : "german",
    "de-DE-Latf" : "german",
    "de-DE" : "german",
    "de-AT-1901" : "german",
    "de-AT-1996" : "german",
    "de-CH-1901" : "german",
    "de-CH-1996" : "german",
    "de-DE-1901" : "german",
    "de-DE-1996" : "german",
    "de-Latf" : "german",
    "de-AT-1901-Latf" : "german",
    "de-AT-1996-Latf" : "german",
    "de-CH-1901-Latf" : "german",
    "de-CH-1996-Latf" : "german",
    "de-DE-1901-Latf" : "german",
    "de-DE-1996-Latf" : "german",
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
    "la-xclassic" : "latin",
    "la-xecclesiastic" : "latin",
    "la-xmedieval" : "latin",
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
    "sa-Deva" : "sanskrit",
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
    "ckb-Arab" : "variant=sorani",
    "ckb-Latn" : "variant=sorani",
    "de-AT-1901" : "variant=austrian,spelling=old",
    "de-AT-1996" : "variant=austrian,spelling=new",
    "de-CH-1901" : "variant=swiss,spelling=old",
    "de-CH-1996" : "variant=swiss,spelling=new",
    "de-DE-1901" : "variant=german,spelling=old",
    "de-DE-1996" : "variant=german,spelling=new",
    "de-Latf" : "script=blackletter",
    "de-AT-1901-Latf" : "variant=austrian,spelling=old,script=blackletter",
    "de-AT-1996-Latf" : "variant=austrian,spelling=new,script=blackletter",
    "de-CH-1901-Latf" : "variant=swiss,spelling=old,script=blackletter",
    "de-CH-1996-Latf" : "variant=swiss,spelling=new,script=blackletter",
    "de-DE-1901-Latf" : "variant=german,spelling=old,script=blackletter",
    "de-DE-1996-Latf" : "variant=german,spelling=new,script=blackletter",
    "de-AT-Latf" : "variant=austrian,spelling=new,script=blackletter",
    "de-AT" : "variant=austrian,spelling=new",
    "de-CH-Latf" : "variant=swiss,spelling=new,script=blackletter",
    "de-CH" : "variant=swiss,spelling=new",
    "de-DE-Latf" : "variant=german,spelling=new,script=blackletter",
    "de-DE" : "variant=german,spelling=new",
    "dsb" : "variant=lower",
    "el-monoton" : "variant=monotonic",
    "el-polyton" : "varant=polytonic",
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
    "la-xclassic" : "variant=classic",
    "la-xecclesiastic" : "variant=ecclesiastic",
    "la-xmedieval" : "variant=medieval",
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
    "zsm" : "variant=malaysian",
}

def main():
    generate_glosses()
    generate_aliases()
    generate_ids()


def generate_glosses():
    for key in bcp472lang:
        val = bcp472lang[key]
        f = open(("gloss-%s.ldf" % key),"w+")
        f.write(("\\ProvidesFile{gloss-%s.ldf}[polyglossia: module for %s (%s)]" % (key,key,val)))
        f.write("\n\n% We provide this as a bcp47-compliant alias")
        f.write(("\n\n\\xpg@load@master@language{%s}" % val))
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
        for line in fileinput.FileInput(file_path,inplace=1):
            if not glossval in aliases and not fertig and "% BCP-47 compliant aliases\n" in line:
                line = line.replace(line, line + addition + "\n")
                logging.debug("replace line: %s" % line)
                fertig = True
                aliases.append(glossval)
            print line,
        if not fertig:
            addition = "% BCP-47 compliant aliases\n" + addition
            for line in fileinput.FileInput(file_path,inplace=1):
                if not glossval in aliases and not fertig and line == "}\n":
                    line = line.replace(line, line + "\n" + addition)
                    logging.debug("replace line: %s" % line)
                    fertig = True
                    aliases.append(glossval)
                print line,

def generate_ids():
    aliases = []
    for key in babelname2bcp47:
        val = babelname2bcp47[key]
        gloss = key
        addition = ("  bcp47=%s,\n" % val)
        file_path = "../tex/" + ("gloss-%s.ldf" % gloss)
        for line in fileinput.FileInput(file_path,inplace=1):
            if "\\PolyglossiaSetup{" in line:
                line = line.replace(line, line + addition)
            print line,


if __name__ == "__main__":
    main()
