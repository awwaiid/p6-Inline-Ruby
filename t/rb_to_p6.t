#!/usr/bin/env perl6

use v6;
use Test;
use Inline::Ruby::Sweet;

is '[1, 2, 3]':rb.TO-P6.WHAT, List, 'rb array -> List';
is-deeply '[1, 2, 3]':rb.TO-P6, (1, 2, 3), 'Simple array';
is-deeply '[1, [4, 5], 3]':rb.TO-P6, (1, (4, 5), 3), 'Nested array';

done-testing;


