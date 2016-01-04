
#| Represent a raw Ruby VALUE
class Inline::Ruby::RbValue is repr('CPointer') {

  use NativeCall;
  constant RUBY = %?RESOURCES<libraries/rbhelper>.Str;

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


  # NativeCall routines for rb->p6 conversions
  sub p6_rb_type      (Inline::Ruby::RbValue $value) returns int   is native(RUBY) { * }
  sub rb_to_p6_fixnum (Inline::Ruby::RbValue $value) returns int   is native(RUBY) { * }
  sub rb_to_p6_string (Inline::Ruby::RbValue $value) returns Str   is native(RUBY) { * }
  sub rb_to_p6_dbl    (Inline::Ruby::RbValue $value) returns num64 is native(RUBY) { * }

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
    ::('Inline::Ruby::RbObject').new(value => self);
  }

  # NativeCall routines for P6->RB conversions
  sub p6_to_rb_int (int32 $n) returns Inline::Ruby::RbValue is native(RUBY) { * }
  sub p6_to_rb_str (Str $s)   returns Inline::Ruby::RbValue is native(RUBY) { * }
  # string -> symbol
  sub rb_intern(Str $val)
      returns Inline::Ruby::RbValue
      is native(RUBY) { * }

  # Ruby values don't need to be converted
  multi method from(Inline::Ruby::RbValue $rb_value) {
    $rb_value;
  }

  multi method from(Int $n) {
    p6_to_rb_int($n);
  }

  multi method from(Str $v) {
    p6_to_rb_str($v);
  }

  sub rb_funcall(
        Inline::Ruby::RbValue $obj,
        Inline::Ruby::RbValue $symbol,
        int32 $argc)
      returns Inline::Ruby::RbValue
      is native(RUBY) { * }

  # string -> symbol
  # sub rb_intern(Str $val)
  #     returns Inline::Ruby::RbValue
  #     is native(RUBY) { * }

  multi method from(Pair $v where $v.value === True) {
  # multi method from(Pair $v) {
    # say "Converting $v -> symbol";
    my $rb_str = Inline::Ruby::RbValue.from($v.key);
    my $r = rb_funcall($rb_str, rb_intern("to_sym"), 0);
    # say "Got back";
    $r;
  }

  multi method from($v) {
    say "Can't convert $v, passing on";
    $v;
  }

}
