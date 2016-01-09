use lib "lib";
use Inline::Ruby;

EVAL 'puts "Hello!"', :lang<Ruby>;

use Inline::Ruby::Sweet;

"5":rb + 2;

use csv:from<Ruby>;
say CSV.read('examples/hiya.csv');

