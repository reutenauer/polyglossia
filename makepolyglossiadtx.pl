#!/usr/bin/perl -w
#######  THIS IS BASED ON makedtx.pl  ########
# File          : makedtx
# Author        : Nicola L. C. Talbot
# Date          : 29 Oct 2004
# Last Modified : 19 Aug 2007
# Version       : 0.94b

# usage : makedtx [options] -src <expr>=><expr> -doc <filename> <basename>
#
# -h  : help message
# -src <expr>=><expr> : e.g. -src "(foo)src\.(bar)=>$1.$2" will add foosrc.bar to <basename>.dtx to be extracted to foo.bar
# -doc <filename> : file containing documentation.
# -prefinale <string> : text to add to dtx file just before \Finale (added to version 0.91b)
# <basename> : create <basename>.dtx and <basename>.ins

#BEGIN {
#  system("rm *.{dtx,sty,def,ldf,map,txt,tex,glo,log,ins,out,idx,aux,lua}");
#};


use open IO => ':encoding(utf8)';
use utf8;
use strict;
use Cwd;

my $basedir         = getcwd ;
my $srcdir          = "$basedir/tex";
my $docsrcdir       = "$basedir/doc";
my $fontmapsrcdir   = "$basedir/fontmapping";
my $docsrc          = "$docsrcdir/polyglossia.tex";
my $readme          = "$docsrcdir/README";
my @docsrcfiles     = qw(README
                          examples.tex
                          example-arabic.tex
                          example-thai.tex);
my $patternop       = "=";
my $verbose         = 0;
my $noins           = 0;
my $askforoverwrite = 0;
my $version         = '0.94b';
my $author          = 'Arthur Reutenauer';
my $email           = "<arthur 'dot' reutenauer 'at' normalesup 'dot' org>";
(my $sec, my $min, my $hour, my $mday, my $mon, my $year, my $wday, my $yday, my $isdst) 
    = localtime(time);

$year = $year + 1900;

my $preamble        = <<_END
  ____________________________

  The polyglossia package         
  (C) 2008–2010 François Charette    
  (C) 2010-$year Arthur Reutenauer
  (C) 2013 Elie Roux
  License information appended

_END
;
my $postamble = <<_END

 Copyright (C) $year by $author $email 

 This work may be distributed and/or modified under the
 conditions of the LaTeX Project Public License, either version 1.3
 of this license of (at your option) any later version.
 The latest version of this license is in
   http://www.latex-project.org/lppl.txt
 and version 1.3 or later is part of all distributions of LaTeX
 version 2005/12/01 or later.

 This work has the LPPL maintenance status `maintained'.

 The Current Maintainer of this work is $author.

_END
; 
my $stopeventually  = "";
my $prefinale       = "";
my $codetitle       = "Implementation";

my @source = qw/(polyglossia\.sty)=>$1 (.+cal\.sty)=>$1 (.+\.lua)=>$1 (.+\.def)=>$1 (gloss-.+\.ldf$)=>$1/;

my $basename = "polyglossia";

open DTX, ">$basename.dtx" or die "Can't open '$basename.dtx'\n";
binmode( DTX, ':utf8' );

if ($verbose)
{
   print "Documentation source : " . $docsrc . "\n";
}

# work out the derived files

my @srcdirfile = glob("$srcdir/*.{sty,ldf,def}");

my @srcdirluafile = glob("$srcdir/*.{lua}");

my @derivedfiles = ();

my @outputfiles = ();

my @derivedluafiles = ();

my @outputluafiles = ();

my @deriveddocfiles = ();

my @outputdocfiles = ();

my $numoutput = 0;

foreach my $source (@source)
{  

   my ($infile, $outfile, $remainder) = split /=>/, $source;

   if ($outfile eq "")
   {
      print "-src $source argument invalid (no output file specified)\n";

      &syntaxerror();
   }

   if ($remainder && $remainder ne "")
   {
      print "-src $source argument invalid (too many => specified)\n";

      &syntaxerror();
   }

   foreach my $srcdirfile (@srcdirfile)
   {
      my $fileexp = $srcdir . "/" . $infile;

      $_ = $srcdirfile;

      my $expr = "s$patternop$fileexp$patternop$outfile$patternop";

      if (eval($expr))
      {
         my $thisoutfile = $_;

         my $thisinfile  = $srcdirfile;

         $derivedfiles[$numoutput]{'in'} = $thisinfile;
         $derivedfiles[$numoutput]{'out'} = $thisoutfile;
         $outputfiles[$numoutput] = $thisoutfile;

         $numoutput++;
      }
   }
   
   $numoutput = 0;
   
   foreach my $srcdirluafile (@srcdirluafile)
   {
      my $fileexp = $srcdir . "/" . $infile;

      $_ = $srcdirluafile;

      my $expr = "s$patternop$fileexp$patternop$outfile$patternop";

      if (eval($expr))
      {
         my $thisoutfile = $_;

         my $thisinfile  = $srcdirluafile;

         $derivedluafiles[$numoutput]{'in'} = $thisinfile;
         $derivedluafiles[$numoutput]{'out'} = $thisoutfile;
         $outputluafiles[$numoutput] = $thisoutfile;

         $numoutput++;
      }
   }
   
}

foreach my $docfile (@docsrcfiles) {
  my $docin = "$docsrcdir/$docfile";
  push @deriveddocfiles, { in => $docin, out => $docfile };
  push @outputdocfiles, $docfile;
}

my @fontmapsrcfiles = glob("$fontmapsrcdir/*.map");

foreach my $fontmap (@fontmapsrcfiles) {
  my $fontmapout = $fontmap;
  $fontmapout =~ s|.+/([^/]+\.map)|$1|;
  push @derivedfiles, { in => $fontmap, out => $fontmapout };
  push @outputfiles, $fontmapout;
}


print DTX "\%\\iffalse\n";
print DTX "\% $basename.dtx generated using mkpolyglossiadtx.pl\n";
print DTX "\% (derived from makedtx.pl version $version (c) Nicola Talbot)\n";
print DTX "\% \n"; 
print DTX "\% To extract the files, use xetex polyglossia.dtx or luatex polyglossia.dtx\n";
print DTX "\% \n";

print DTX <<_END
%<*internal>
\\iffalse
%</internal>
%<*README>
_END
;
open README, "< $readme";
while (<README>) {
  print DTX $_;
};
close README;
print DTX <<_END
%</README>
%<*internal>
\\fi
%</internal>
%
%<*internal>
\\begingroup
%</internal>
%<*batchfile>
\\input docstrip.tex
\\keepsilent
\\let\\MetaPrefix\\relax
\\preamble
$preamble
\\endpreamble
\\postamble
$postamble
\\endpostamble
\\let\\MetaPrefix\\DoubleperCent
\\askforoverwritefalse
_END
;
for (my $idx = 0; $idx <= $#derivedfiles; $idx++) {
    my $outfile = $derivedfiles[$idx]{'out'};
    print DTX "\\generate{\\file{$outfile}{\\from{polyglossia.dtx}{$outfile}}}\n"
}

print DTX <<_END
\\def\\MetaPrefix{-- }
_END
;
for (my $idx = 0; $idx <= $#derivedluafiles; $idx++) {
    my $outfile = $derivedluafiles[$idx]{'out'};
    print DTX "\\generate{\\file{$outfile}{\\from{polyglossia.dtx}{$outfile}}}\n"
}

print DTX <<_END
\\let\\MetaPrefix\\DoubleperCent
%</batchfile>
%<batchfile>\\endbatchfile
%<*internal>
\\generate{\\file{polyglossia.ins}{\\from{polyglossia.dtx}{batchfile}}}
\\nopreamble\\nopostamble
_END
;
for (my $idx = 0; $idx <= $#deriveddocfiles; $idx++) {
    my $outfile = $deriveddocfiles[$idx]{'out'};
    print DTX "\\generate{\\file{$outfile}{\\from{polyglossia.dtx}{$outfile}}}\n"
}

print DTX<<_END
\\endgroup
%</internal>
%
_END
;

# driver

print DTX "\%<*driver>\n";

my $indoc=0;

open DOC, $docsrc or die "Can't open '$docsrc'\n";

while (<DOC>)
{
   s/\\usepackage{creatdtx}//;
    
   my $restofline = $_;

   my $beginline = "";
   my $line = $restofline;

   while ($restofline =~ /(.*)\\ifmakedtx(.*)/)
   {
      $beginline = $1;

      my ($group,$restofline,$done) = &getnextgroup($2);

      my $startline = $.;

      while (!$done)
      {
         if (my $nextline = <DOC>)
         {
            $line = $line . $nextline;

            $restofline = $restofline . $nextline;

            ($group,$restofline,$done) = &getnextgroup($restofline);
         }
         else
         {
            die "EOF found whilst scanning first argument to \\ifmakedtx on line $startline\n";
         }
      }

      # print first arg, ignore second

      $beginline = $beginline . $group;

      ($group,$restofline,$done) = &getnextgroup($restofline);

      while (!$done)
      {
         if (my $nextline = <DOC>)
         {
            $line = $line . $nextline;

            $restofline = $restofline . $nextline;

            ($group,$restofline,$done) = &getnextgroup($restofline);
         }
         else
         {
            die "EOF found whilst scanning second argument to \\ifmakedtx on line $startline\n";
         }
      }

      $line = $restofline;
   }

   $line = $beginline . $restofline;

   print DTX $line;

   if ($line=~/\\begin{document}/)
   {
      $indoc = 1;

      last;
   }
}

print DTX <<_END
\\ifxetex
  \\DocInput{$basename.dtx}
\\fi
\\end{document}
%</driver>
% 
% \\fi
% 
% \\errorcontextlines=999
% \\makeatletter
% 
_END
;

my $inverb=0;
my $stopfound=0;

print DTX "\% ";

while (<DOC>)
{
   my $inverb ;
   s/^\s*%+/^^A/ ; 

   if (/\\begin{verbatim}/)
   {
      $inverb=1;
   }

   if (/\\end{verbatim}/)
   {
      $inverb=0;
   }

   if (/\\StopEventually/ && ($inverb==0))
   {
      $stopfound=1;
   }

   my $restofline = $_;

   my $beginline = "";
   my $line = $restofline;

   while ($restofline =~ /(.*)\\ifmakedtx(.*)/)
   {  
      my $group; 
      my $done ;

      $beginline = $1;

      ($group,$restofline,$done) = &getnextgroup($2);

      my $startline = $.;

      while (!$done)
      {
         if (my $nextline = <DOC>)
         {
            $line = $line . $nextline;

            $restofline = $restofline . $nextline;

            ($group,$restofline,$done) = &getnextgroup($restofline);
         }
         else
         {
            die "EOF found whilst scanning first argument to \\ifmakedtx on line $startline\n";
         }
      }

      # print first arg, ignore second

      $beginline = $beginline . $group;

      ($group,$restofline,$done) = &getnextgroup($restofline);

      while (!$done)
      {
         if (my $nextline = <DOC>)
         {
            $line = $line . $nextline;

            $restofline = $restofline . $nextline;

            ($group,$restofline,$done) = &getnextgroup($restofline);
         }
         else
         {
            die "EOF found whilst scanning second argument to \\ifmakedtx on line $startline\n";
         }
      }

      $line = $restofline;
   }

   $line = $beginline . $restofline;

   if (($line=~/\\end{document}/) and not $inverb)
   {
      $indoc=0;

      $line=~s/\\end{document}//;
   }

   $line=~s/\n/\n\% /mg;

   print DTX "$line";
}

close DOC;

print DTX "\n";

if ($stopfound==0)
{
   print DTX "\% \\StopEventually{$stopeventually}\n";
}

print DTX "\% \\section{$codetitle}\n";

@derivedfiles = (@derivedfiles,@derivedluafiles);

for (my $idx = 0; $idx <= $#derivedfiles; $idx++)
{
   my $thisinfile = $derivedfiles[$idx]{'in'};
   my $thisoutfile = $derivedfiles[$idx]{'out'};

#   if ($verbose)
#   {
#         print "$srcdirfile -> $_ \n";
#   }

   open SRC, $thisinfile or die "Can't open infile no $idx `$thisinfile'\n";

   print DTX "\% \\iffalse\n" if $idx == 0;
   print DTX "\%<*$thisoutfile>\n";
   print DTX "\% \\fi\n";
   print DTX "\% \\clearpage\n";
   print DTX "\% \n";
   print DTX "\% \\subsection{$thisoutfile}\n";
   ## TODO only put this before the first occurence of \\ProvidePackage :
   print DTX "\%    \\begin{macrocode}\n";

   my $macrocode = 0;
   my $comment   = 0;

#   foreach my $expr (@comment)
#   {
#      if ($thisoutfile =~ m/$expr/)
#      {
#         print DTX "\%\\iffalse\n";
#
#            $comment = 1;
#      }
#   }
#
#   foreach $expr (@macrocode)
#   {
#      if ($thisoutfile =~ m/$expr/)
#      {
#         print DTX "\%    \\begin{macrocode}\n";
#
#         $macrocode = 1;
#      }
#   }
#
   while (<SRC>)
   {  
      last if m/^\\endinput/;
      print DTX "$_";
   }

   if ($macrocode == 1)
   {
      print DTX "\%    \\end{macrocode}\n";
   }

   if ($comment == 1)
   {
      print DTX "\%\\fi\n";
   }

   print DTX "\%    \\end{macrocode}\n";
   print DTX "\% \\iffalse\n";
   print DTX "\%</$thisoutfile>\n";
   close SRC;
}

print DTX <<_END
% \\fi
% \\clearpage
% \\PrintChanges
% \\Finale
% 
_END
;

# auxiliary files

for (my $idx = 0; $idx <= $#deriveddocfiles; $idx++)
{
   my $thisinfile = $deriveddocfiles[$idx]{'in'};
   my $thisoutfile = $deriveddocfiles[$idx]{'out'};

   open SRC, $thisinfile or die "Can't open infile no $idx `$thisinfile'\n";

   print DTX "\% \\iffalse\n" if $idx == 0;
   print DTX "\%<*$thisoutfile>\n";

   while (<SRC>)
   {  
      print DTX "$_";
   }

   print DTX "\%</$thisoutfile>\n";
   close SRC;
}

print DTX <<_END
% \\fi
% 
% \\typeout{*************************************************************}
% \\typeout{*}
% \\typeout{* To finish the installation you have to move the following}
% \\typeout{* file into a directory searched by TeX:}
% \\typeout{*}
% \\typeout{* \\space\\space\\space all *.sty, *.lua, *.def and *.ldf files}
% \\typeout{*}
% \\typeout{* You also need to compile the *.map files with teckit_compile}
% \\typeout{* and place the resulting *.tec files under}
% \\typeout{* .../fonts/misc/xetex/fontmapping}
% \\typeout{*}
% \\typeout{*************************************************************}
\\endinput
_END
;

close DTX;

sub syntaxerror
{
   die "Syntax : makedtx [options] <basename>\nUse -h for help\n";
}

sub help
{
   print "makedtx Help\n\n";

   print "Current Version : $version\n\n";

   print "usage : makedtx [options] -src \"<expr>=><expr>\" -doc <filename> <basename>\n\n";

   print "makedtx can be used to construct a LaTeX2e dtx and ins file from\n";
   print "the specified source code.  The final command line argument\n";
   print "<basename> should be used to specify the basename of the dtx\n";
   print "and ins files.\n\n";

   print "-src \"<expr1>=><expr2>\"\n";
   print "The command line switch -src identifies the original source code and the name\n";
   print "of the file to which it will utimately be extracted on latexing the ins file\n";
   print "<expr1> can be a Perl expression, such as (foo)src.(sty), and <expr2> can\n";
   print "a Perl substitution style expression, such as $1.$2\n";
   print "Note that double quotes must be used to prevent shell expansion\n";
   print "Multiple invocations of -src are permitted\n";
   print "See examples below.\n\n";

   print "-doc <filename>\n";
   print "The name of the documentation source code.  This should be a LaTeX2e document\n\n";

   print "Optional Arguments:\n\n";

   print "-dir <directory>   : search for source files in <directory>\n";
   print "-op <character>    : set the pattern matching operator (default '$patternop')\n";
   print "-askforoverwrite   : set askforoverwrite switch in INS file to true\n";
   print "-noaskforoverwrite : set askforoverwrite switch in INS file to false (default)\n";
   print "-preamble <text>   : set the preamble.  Standard one inserted if omitted\n";
   print "-postamble <text>  : set the postamble.\n";
   print "-setambles \"<pattern>=><text>\" : set pre- and postambles to <text> if file matches pattern\n";
   print "-author <text>     : name of author (inserted into standard preamble. User name inserted if omitted)\n";
   print "-date <text>       : copyright date\n";
   print "-ins               : create the ins file (default)\n";
   print "-noins             : don't create the ins file\n";
   print "-prefinale <text>  : add <text> immediately prior to \\Finale\n";
   print "-macrocode <expr>  : surround any file which matches <expr> in a macrocode environment\n";
   print "-comment <expr>    : surround any file which matches <expr> with \\iffalse \\fi pair\n";
   print "-codetitle <text>  : The title for the documented code section (default: The Code)\n";
   print "-license <license> : use the given license for the preamble.\n";
   print "                     Known licenses: lppl (default), bsd, gpl.\n";
   print "-h                 : help message\n";
   print "-v                 : verbose\n\n";

   print "Examples:\n\n";

   print "Example 1:\n";
   print "Documentation is in foodoc.tex\n";
   print "Source code is in foosrc.sty.  The final extracted version should be \n";
   print "called foo.sty. The dtx file should be called foo.dtx and the ins file\n";
   print " should be called foo.ins\n\n";

   print "makedtx -src \"foosrc\\.sty=>foo.sty\" -doc foodoc.tex foo\n\n";

   print "Example 2:\n";
   print "Documentation is in bardoc.tex\n";
   print "Source code is in barsrc.sty.  The final extracted version should be\n";
   print "called bar.sty.  Source code is also in barsrc.bst.  The final extracted\n";
   print "version should be called bar.bst.  The dtx file should be called bar.dtx and\n";
   print "the ins file should be called bar.ins\n\n";

   print "makedtx -src \"barsrc\\.sty=>bar.sty\" -src \"barsrc\\.bst=>bar.bst\" -doc bardoc.tex bar\n\n";

   print "Or\n\n";

   print "makedtx -src \"barsrc\\.(bst|sty)=>bar.\$1\" -doc bardoc.tex bar\n\n";

   die;
}

sub eatinitialspaces
{
   my ($STR) = @_;

   while (substr($STR,0,1) =~ /^\s$/)
   {
      $STR = substr($STR,1);
   }

   return $STR;
}

sub getnextgroup
{
   my($curline) = @_;

   $curline = &eatinitialspaces($curline);

   # check to see if current string is blank

   if ($curline!~/[^\s]+/m)
   {
      return ("","",0);
   }

   if ((my $group = substr($curline,0,1)) ne "{")
   {
       # next group hasn't been delimited with braces
       # return first non-whitespace character

       $curline = substr($curline,1);

       # unless it's a backslash, in which case get command name

       if ($group eq "\\")
       {
          if ($curline=~/([a-zA-Z]+)(^[a-zA-Z].*)/m)
          {
             $group = $1;

             $curline = $2;
          }
          else
          {
             # command is made up of backslash followed by symbol

             $curline=~/([\W_0-9\s\\])(.*)/m;

             $group = $1;

             $curline = $2;
          }
       }

       return ($group,$curline,1);
   }

   my $pos=index($curline, "{");
   my $startpos=$pos;
   my $posopen=0;
   my $posclose=0;

   my $bracelevel = 1;

   my $done=0;

   while (!$done)
   {
      $pos++;

      $posopen = index($curline, "{", $pos);

      # check to make sure it's not a \{

      while ((substr($curline, $posopen-1,1) eq "\\") and ($posopen > 0))
      {
         # count how many backlashes come before it.

         my $i = $posopen-1;

         my $numbs = 1;

         while ((substr($curline, $i-1,1) eq "\\") and ($i > 0))
         {
            $numbs++;
            $i--;
         }

         # is $numbs is odd, we have a \{, otherwise we have \\{

         if ($numbs%2 == 0)
         {
            last;
         }
         else
         {
            $posopen = index($curline, "{", $posopen+1);
         }
      }

      $posclose= index($curline, "}", $pos);

      # check to make sure it's not a \}

      while ((substr($curline, $posclose-1,1) eq "\\") and ($posclose > 0))
      {
         # count how many backlashes come before it.

         my $i = $posclose-1;

         my $numbs = 1;

         while ((substr($curline, $i-1,1) eq "\\") and ($i > 0))
         {
            $numbs++;
            $i--;
         }

         # is $numbs is odd, we have a \}, otherwise we have \\}

         if ($numbs%2 == 0)
         {
            last;
         }
         else
         {
            $posclose = index($curline, "}", $posclose+1);
         }
      }

      if (($posopen==-1) and ($posclose==-1))
      {
         $done=1;
      }
      elsif ($posopen==-1)
      {
         $pos=$posclose;

         $bracelevel--;

         if ($bracelevel==0)
         {
            my $group = substr($curline, $startpos+1, $pos-$startpos-1);

            $curline = substr($curline, $pos+1);

            return ($group,$curline,1);
         }
      }
      elsif ($posclose==-1)
      {
         $pos=$posopen;

         $bracelevel++;
      }
      elsif ($posopen<$posclose)
      {
         $pos=$posopen;

         $bracelevel++;
      }
      elsif ($posclose<$posopen)
      {
         $pos=$posclose;

         $bracelevel--;

         if ($bracelevel==0)
         {
            my $group = substr($curline, $startpos+1, $pos-$startpos-1);

            $curline = substr($curline, $pos+1);

            return ($group,$curline,1);
         }
      }
   }

   # closing brace must be on another line

   return ("", $curline, 0);
}
1;
