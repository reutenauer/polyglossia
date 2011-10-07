#!/usr/bin/perl -W
# Copyright (c) Arthur Reutenauer 2011.
# You may freely use, copy, modify and distribute this file.
#
# This is a one-time usage file!

use strict;

my $endinput_found = 0;
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
  # my @glossfiles = readdir(WORKDIR);
  closedir WORKDIR;
  print STDERR "Found $#glossfiles gloss files.\n";

  foreach my $glossfile (@glossfiles)
  {
    print STDERR "Opening $glossfile.\n";
    rename "$workdir/$glossfile", "$workdir/$glossfile.bak";
    open GLOSSFILE, "$workdir/$glossfile.bak";
    open STDOUT, ">$workdir/$glossfile";
    while(<GLOSSFILE>)
    {
      $chomped_line = $_;
      chomp($chomped_line);

      if($chomped_line =~ /^\\endinput/)
      {
        print "\\makeatother\n$_\n";
        $endinput_found = 1;
      }
      else { print }
    }
    close GLOSSFILE;
  }

  if(!$endinput_found) { warn "No \\endinput found in this file!\n" }
}

main()
