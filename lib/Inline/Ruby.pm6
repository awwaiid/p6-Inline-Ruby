
unit class Inline::Ruby;

my $default_instance;

use NativeCall;
# constant RUBY = 'ruby-2.1';
# constant RUBY = 'ruby';
constant RUBY = './resources/libraries/librbhelper.so';
# sub native(Sub $sub) {
#     my Str $path = %?RESOURCES<libraries/p5helper>.Str;
#     unless $path {
#         die "unable to find p5helper library";
#     }
#     trait_mod:<is>($sub, :native($path));
# }

our sub ruby_init()
  is native(RUBY)
  { * }
our sub ruby_init_loadpath()
  is native(RUBY)
  { * }
our sub ruby_exec_node(Pointer $node)
  is native(RUBY)
  { * }
our sub ruby_options(int32 $argc, CArray[Str] $argv)
  returns Pointer
  is native(RUBY)
  { * }
our sub rb_eval_string_protect(Str $code, int32 $state is rw)
  returns Pointer is native(RUBY)
  { * }
our sub rb_string_value_cstr(Pointer $value) returns Str
  is native(RUBY)
  { * }
our sub p6_rb_type(Pointer $value) returns int
  is native(RUBY)
  { * }
our sub rb_to_p6_fixnum(Pointer $obj) returns int
  is native(RUBY)
  { * }
our sub rb_to_p6_string(Pointer $obj) returns Str
  is native(RUBY)
  { * }
our sub rb_to_p6_dbl(Pointer $obj) returns num64
  is native(RUBY)
  { * }

# our sub rb_funcall(Pointer $obj, Pointer $method, Pointer $params) returns Pointer
#   is native(RUBY)
#   { * }


method BUILD() {
  Inline::Ruby::ruby_init();
  # TODO: What else do we need to do?
  # Inline::Ruby::ruby_init_loadpath();
  # rb_gc_start();
  # rb_funcall(rb_stdout, rb_intern("sync="), 1, 1);
  my $opts = CArray[Str].new;
  $opts[0] = "";
  $opts[1] = "-enil";
  my $options = Inline::Ruby::ruby_options(2, $opts);
  Inline::Ruby::ruby_exec_node($options);
  $default_instance //= self;
}

method default_instance {
  $default_instance //= self.new;
}

method run($str) is export {
  my int32 $state = 0;
  my $result = Inline::Ruby::rb_eval_string_protect($str, $state);
  if $state {
    # VALUE c = rb_funcall(rb_gv_get("$!"), rb_intern("to_s"), 0);
    die "RUBY EXCEPTION" if $state;
  }
  $result;
}

enum ruby_value_type (
  RUBY_T_NONE     => 0x00,

  RUBY_T_OBJECT   => 0x01,
  RUBY_T_CLASS    => 0x02,
  RUBY_T_MODULE   => 0x03,
  RUBY_T_FLOAT    => 0x04,
  RUBY_T_STRING   => 0x05,
  RUBY_T_REGEXP   => 0x06,
  RUBY_T_ARRAY    => 0x07,
  RUBY_T_HASH     => 0x08,
  RUBY_T_STRUCT   => 0x09,
  RUBY_T_BIGNUM   => 0x0a,
  RUBY_T_FILE     => 0x0b,
  RUBY_T_DATA     => 0x0c,
  RUBY_T_MATCH    => 0x0d,
  RUBY_T_COMPLEX  => 0x0e,
  RUBY_T_RATIONAL => 0x0f,

  RUBY_T_NIL      => 0x11,
  RUBY_T_TRUE     => 0x12,
  RUBY_T_FALSE    => 0x13,
  RUBY_T_SYMBOL   => 0x14,
  RUBY_T_FIXNUM   => 0x15,

  RUBY_T_UNDEF    => 0x1b,
  RUBY_T_NODE     => 0x1c,
  RUBY_T_ICLASS   => 0x1d,
  RUBY_T_ZOMBIE   => 0x1e,

  RUBY_T_MASK     => 0x1f
);

multi sub rb_to_p6(Pointer $obj) {
  my $type = p6_rb_type($obj);
  rb_to_p6($obj, $type);
}

multi sub rb_to_p6(Pointer $obj, $type where RUBY_T_FIXNUM) {
  rb_to_p6_fixnum($obj);
}

multi sub rb_to_p6(Pointer $obj, $type where RUBY_T_TRUE) {
  True;
}

multi sub rb_to_p6(Pointer $obj, $type where RUBY_T_FALSE) {
  False;
}

multi sub rb_to_p6(Pointer $obj, $type where RUBY_T_NIL) {
  Any;
}

multi sub rb_to_p6(Pointer $obj, $type where RUBY_T_STRING) {
  rb_to_p6_string($obj);
}

multi sub rb_to_p6(Pointer $obj, $type where RUBY_T_FLOAT) {
  rb_to_p6_dbl($obj);
}

multi sub rb_to_p6(Pointer $obj, $type) {
  die "Type not defined";
}

multi sub EVAL(
    Cool $code,
    Str :$lang where { ($lang // '') eq 'Ruby' },
    PseudoStash :$context)
    is export {
  state $rb //= ::("Inline::Ruby").default_instance;
  my $result = $rb.run($code);
            CATCH {
              #X::Eval::NoSuchLang.new(:$lang).throw;
              note $_;
              }
  rb_to_p6($result);
  # p6_rb_type($result);
  # rb_to_p6_fixnum($result);
  # rb_type($result);
  # rb_string_value_cstr($rb.run($code));
}
