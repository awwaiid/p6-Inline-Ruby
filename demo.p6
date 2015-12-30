use lib "lib";
use Inline::Ruby;

EVAL 'puts "Hello!"', :lang<Ruby>;

use LREP;
LREP::here;
