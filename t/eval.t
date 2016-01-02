#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Ruby;

sub circumfix:<RB[ ]>($code) {
  use MONKEY-SEE-NO-EVAL;
  EVAL $code, :lang<Ruby>;
}

subtest {
  isa-ok RB['true'], True;
  isa-ok RB['false'], False;
  isa-ok RB['5'], Int;
  isa-ok RB['1.0'], Num;
  isa-ok RB['"foo"'], Str;
}, 'Ruby to Perl6 types';

is RB['7 * 6'], 42, 'Basic math';

is RB['1.0 / 3'], (1e0/3), 'Float math';

is RB['Time'].now.class.to_s, 'Time', 'Call methods';

is RB['[2, 6, 8, 4]'].sort.to_s,
   "[2, 4, 6, 8]",
   'Can call sort and to_s on Array';

is RB['[2, 4, 6, 8]'].at(1),
   4,
   'Can call parameter methods on Array';

is RB['[2, 4, 6, 8]'].slice(1, 2).to_s,
   '[4, 6]',
   'Can call 2-parameter methods on Array';

is RB['[2, 4, 6, 8]'].push(1).to_s,
   "[2, 4, 6, 8, 1]",
   'Can modify an Array';

done-testing;


