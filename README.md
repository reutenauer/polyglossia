# Kurdish Latex (XeLaTeX)
Configuration for running Kurdish in the [Polyglossia](https://github.com/reutenauer/polyglossia) package.

This is a minimal working example:

```
\documentclass{article}
\usepackage{polyglossia}
\setdefaultlanguage{kurdish}
\newfontfamily\arabicfont[Script=Arabic,Scale=1]{Lateef}

\begin{document}

\section{ده‌سپێک}
ئه‌مه‌ یه‌كه‌م به‌شی پڕۆژه‌ نوێیه‌كه‌مه‌.

\end{document}
```

The current version is based on the Persian and the Arabic glosses, respectively `gloss-farsi.ldf` and `gloss-arabic.ldf`. Although the major structure is provided for Kurdish, there are a few points that I will complete in the future:

- **Dialects**: Kurdish is a multidialectal language, among which Kurmanji and Sorani are mostly used. The current configuration only included Sorani Kurdish.
- **Scripts**: Kurdish is a multi-script language too, i.e. there are more than one script for writing a Kurdish text. Two scripts are the most popular ones nowadays, one based on the Arabic-Persian script and the other one based on Latin. The current configuration file only includes the Arabic-Persian script.

Therefore, more configuraitons should be provided to includ Kurmanji and Latin script, for both dialects.
