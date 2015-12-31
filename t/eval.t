#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Ruby;

sub eval-ruby($code) {
  EVAL($code, :lang<Ruby>);
}

subtest {
  isa-ok eval-ruby('true'), True;
  isa-ok eval-ruby('false'), False;
  isa-ok eval-ruby('5'), Int;
  isa-ok eval-ruby('1.0'), Num;
  isa-ok eval-ruby('"foo"'), Str;
}, 'Ruby to Perl6 types';

is eval-ruby('7 * 6'), 42, 'Basic math';
is eval-ruby('1.0 / 3'), (1e0/3), 'Float math';

done-testing;

