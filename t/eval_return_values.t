#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Ruby;

plan 2;

my $rb = Inline::Ruby.new();
is $rb.run('5', :eval), 5;
is $rb.run('"Python"', :eval), 'Python';

# vim: ft=perl6
