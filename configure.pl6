#!/usr/bin/env perl6

use v6;
use LibraryMake;

#| Call out to Ruby to figure out what compile flags we should use
sub ruby-cc-config {
  # shell(q{ ls -laR /home/travis/.rvm/rubies/ruby-2.3.0 });
  # shell(q{
  #   ruby -rmkmf -e '
  #     print RbConfig::CONFIG.inspect
  #   '
  # });
  my $rb-config-cmd = shell(q{
    ruby -rmkmf -e '
      print RbConfig::CONFIG["LIBS"]
      print " -L" + RbConfig::CONFIG["libdir"]
      # print " " + RbConfig::CONFIG["LIBRUBYARG"]
      print " -I" + RbConfig::CONFIG["rubyarchhdrdir"]
      print " -I" + RbConfig::CONFIG["rubyhdrdir"]
      print " -lruby"
    '
  }, :out);
  my $rb-config = $rb-config-cmd.out.slurp-rest;

  # For some reason travis leaves ${ORIGIN} in CONFIG
  my $rb-origin = shell('dirname `which ruby`', :out).out.slurp-rest.chomp;
  $rb-config ~~ s:g/ '${ORIGIN}' /$rb-origin/;

  $rb-config;
}

my %vars = get-vars('.');
%vars<rbhelper> = $*VM.platform-library-name('rbhelper'.IO);
%vars<rb-gcc-args> = ruby-cc-config();

mkdir "resources" unless "resources".IO.e;
mkdir "resources/libraries" unless "resources/libraries".IO.e;

say "pwd: %*ENV<PWD>";
say "destdir: %vars<DESTDIR>";
say qx/ruby -rmkmf -e 'print RbConfig::CONFIG.inspect'/;
# shell('ls -laR');

process-makefile('.', %vars);
shell(%vars<MAKE>);
# shell('ls -laR');

# vim: ft=perl6
