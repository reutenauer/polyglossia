#!/usr/bin/perl -W
# Copyright (c) Arthur Reutenauer 2011.
# You may freely use, copy, modify and distribute this file.
#
# This is a one-time usage file!

use strict;

my $chomped_line;

sub usage()
{
  print STDERR "Usage: $0 <dir to inspect>.\n";
}

sub main()
{
  if($#ARGV != 0)
  {
    usage();
    exit -1;
  }

  my $workdir = $ARGV[0];
  opendir WORKDIR, $workdir or die "Could not open directory $workdir: $!.\n";
  my @glossfiles = grep { /^gloss-.*\.ldf$/ && -f "$workdir/$_" } readdir(WORKDIR);
  closedir WORKDIR;

  foreach my $glossfile (@glossfiles)
  {
    rename "$workdir/$glossfile", "$workdir/$glossfile.bak";
    open GLOSSFILE, "$workdir/$glossfile.bak";
    open STDOUT, ">$workdir/$glossfile";
    while(<GLOSSFILE>)
    {
      $chomped_line = $_;
      chomp($chomped_line);

      if($chomped_line !~ /^\\makeat(letter|other)$/) { print }
    }
    close GLOSSFILE;
  }
}

main()
