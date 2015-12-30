#!/usr/bin/env perl6

use v6;
use Inline::Ruby;

say '1..1';

EVAL '$stdout.sync = true', :lang<Ruby>;
EVAL 'print "ok 1 - basic eval\n"', :lang<Ruby>;

