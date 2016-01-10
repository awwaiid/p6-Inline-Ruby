#!/usr/bin/env perl6
use v6;
use LibraryMake;

# shell('perl -e "use v5.18;"')
#     or die "\nPerl 5 version requirement not met\n";

# shell('perl -MFilter::Simple -e ""')
#     or die "\nPlease install the Filter::Simple Perl 5 module!\n";

sub ruby-cc-config {
  shell(q{
    ruby -rmkmf -e '
      print RbConfig::CONFIG.inspect
    '
  }, :out);
  my $rb-config-cmd = shell(q{
    ruby -rmkmf -e '
      print RbConfig::CONFIG["LIBS"]
      print " " + RbConfig::CONFIG["LIBRUBYARG"]
      print " -I" + RbConfig::CONFIG["rubyhdrdir"]
      print " -I" + RbConfig::CONFIG["rubyarchhdrdir"]
    '
  }, :out);
  $rb-config-cmd.out.slurp-rest;
}

my %vars = get-vars('.');
%vars<rbhelper> = $*VM.platform-library-name('rbhelper'.IO);
%vars<rb-gcc-args> = ruby-cc-config();

mkdir "resources" unless "resources".IO.e;
mkdir "resources/libraries" unless "resources/libraries".IO.e;

process-makefile('.', %vars);
shell(%vars<MAKE>);

# vim: ft=perl6
