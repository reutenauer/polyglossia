# THE POLYGLOSSIA PACKAGE v1.59
## Multilingual typesetting with XeLaTeX and LuaLaTeX

This package provides an alternative to Babel for users of XeLaTeX and LuaLaTeX.
This version includes support for over 80 different languages, some of which in
different regional or national varieties, or using a different writing system.

Polyglossia makes it possible to automate the following tasks:

* Loading the appropriate hyphenation patterns.
* Setting the script and language tags of the current font (if possible and
  available), using the package fontspec.
* Switching to a font assigned by the user to a particular script or language.
* Adjusting some typographical conventions in function of the current language
  (such as afterindent, frenchindent, spaces before or after punctuation marks,
  etc.).
* Redefining the document strings (like “chapter”, “figure”, “bibliography”).
* Adapting the formatting of dates (for non-gregorian calendars via external
  packages bundled with polyglossia: currently the Hebrew, Islamic and Farsi
  calendars are supported).
* For languages that have their own numeration system, modifying the formatting
  of numbers appropriately.
* Ensuring the proper directionality if the document contains languages
  written from right to left (via the packages bidi and luabidi, available
  separately).

# LICENCE

Copyright (c) 2008-2010 François Charette, 2013 Élie Roux, 2011-2022 Arthur Reutenauer,
Copyright (c) 2019-2022 Bastien Roucariès, 2019-2022 Jürgen Spitzmüller

Except where otherwise noted, Polyglossia is placed under the terms of the MIT licence
(https://opensource.org/licenses/MIT).

# BUGS

If you run into a bug, or suspect you do, or you have a request or comment, please
use the GitHub issue tracker: http://github.com/reutenauer/polyglossia/issues

This is more efficient than contacting the maintainer by email as it allows us
to track the issues and follow progress.
