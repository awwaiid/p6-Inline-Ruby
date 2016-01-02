
unit class Inline::Ruby;

my $default_instance;

use NativeCall;
constant RUBY = %?RESOURCES<libraries/rbhelper>.Str;

class RbObject { ... }

class RbValue is repr('CPointer') {

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


  # Here are the actual NativeCall functions.
  sub p6_rb_type      (RbValue $value) returns int   is native(RUBY) { * }
  sub rb_to_p6_fixnum (RbValue $value) returns int   is native(RUBY) { * }
  sub rb_to_p6_string (RbValue $value) returns Str   is native(RUBY) { * }
  sub rb_to_p6_dbl    (RbValue $value) returns num64 is native(RUBY) { * }

  multi method to_p6() {
    my $type = p6_rb_type(self);
    # say "Converting $type to p6";
    self.to_p6($type);
  }

  multi method to_p6($type where RUBY_T_FIXNUM) {
    rb_to_p6_fixnum(self);
  }

  multi method to_p6($type where RUBY_T_TRUE) {
    True;
  }

  multi method to_p6($type where RUBY_T_FALSE) {
    False;
  }

  multi method to_p6($type where RUBY_T_NIL) {
    Any;
  }

  multi method to_p6($type where RUBY_T_STRING) {
    rb_to_p6_string(self);
  }

  multi method to_p6($type where RUBY_T_FLOAT) {
    rb_to_p6_dbl(self);
  }

  multi method to_p6($type) {
    # say "Wrapping $type in RbObject";
    RbObject.new(value => self);
    # die "Type $type not defined";
  }

  sub p6_to_rb_int (int32 $n) returns RbValue is native(RUBY) { * }
  sub p6_to_rb_str (Str $s)   returns RbValue is native(RUBY) { * }

  multi method from(Int $n) {
    p6_to_rb_int($n);
  }

  multi method from(Str $v) {
    p6_to_rb_str($v);
  }

}

# Native functions

sub ruby_init()
    is native(RUBY) { * }

sub ruby_init_loadpath()
    is native(RUBY) { * }

sub ruby_exec_node(Pointer $node)
    is native(RUBY) { * }

sub ruby_options(int32 $argc, CArray[Str] $argv)
    returns Pointer
    is native(RUBY) { * }

sub rb_eval_string_protect(Str $code, int32 $state is rw)
    returns RbValue
    is native(RUBY) { * }

sub rb_funcall(RbValue $obj, RbValue $symbol)
    returns RbValue
    is native(RUBY) { * }

sub rb_funcallv(
      RbValue $obj,
      RbValue $symbol,
      int32 $argc,
      CArray[RbValue] $argv)
    returns RbValue
    is native(RUBY) { * }

sub rb_gv_get(Str $var)
    returns RbValue
    is native(RUBY) { * }

# string -> symbol
sub rb_intern(Str $val)
    returns RbValue
    is native(RUBY) { * }

sub to_ruby(Int $n) {
}

class RbObject {
  has RbValue $.value;

  method sort(*@x) {
    self.FALLBACK("sort", |@x);
  }
  method first(*@x) {
    self.FALLBACK("first", |@x);
  }
  method push(*@x) {
    self.FALLBACK("push", |@x);
  }

  method FALLBACK($name, *@x) {
    # say "Calling $name";
    my $argc = @x.elems;
    my $argv = CArray[RbValue].new;
    $argv[$_] = RbValue.from(@x[$_]) for ^@x.elems;
    rb_funcallv($.value, rb_intern($name), $argc, $argv).to_p6;
  }

  method from($v) {
    RbObject.new( value => RbValue.from($v) );
  }
}


method BUILD() {
  $default_instance //= self;
  ruby_init();

  # TODO: What else do we need to do?
  # Inline::Ruby::ruby_init_loadpath();
  # rb_gc_start();
  # rb_funcall(rb_stdout, rb_intern("sync="), 1, 1);

  # Setting options to -enil lets us start ruby
  # without complaint about not having some stuff.
  # my $opts = CArray[Str].new;
  # $opts[0] = "";
  # $opts[1] = "-enil";
  # my $options = ruby_options(2, $opts);
  # ruby_exec_node($options);

}

# Singleton instances for common uses
method default_instance {
  # say "loading default...";
  $default_instance //= self.new;
}

method run($str) {
  my int32 $state = 0;
  my $result = rb_eval_string_protect($str, $state);
  if $state {
    my $msg = EVAL('$!.to_s', :lang<Ruby>) || "ERROR";
    die "EVAL-RUBY EXCEPTION: $msg";
  }
  $result;
}


multi sub EVAL(
  Cool $code,
  Str :$lang where { ($lang // '') eq 'Ruby' },
  PseudoStash :$context
) is export {
  state $rb //= Inline::Ruby.default_instance;
  my $result = $rb.run($code);
  $result.to_p6;
}

