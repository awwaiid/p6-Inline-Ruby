
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

  # string -> symbol
  sub rb_intern(Str $val)
      returns Inline::Ruby::RbValue
      is native(RUBY) { * }

  sub rb_funcall(
        Inline::Ruby::RbValue $obj,
        Inline::Ruby::RbValue $symbol,
        int32 $argc)
      returns Inline::Ruby::RbValue
      is native(RUBY) { * }


  # NativeCall routines for rb->p6 conversions
  sub p6_rb_type      (Inline::Ruby::RbValue $value) returns int32 is native(RUBY) { * }
  sub rb_to_p6_fixnum (Inline::Ruby::RbValue $value) returns int32 is native(RUBY) { * }
  sub rb_to_p6_string (Inline::Ruby::RbValue $value) returns Str   is native(RUBY) { * }
  sub rb_to_p6_dbl    (Inline::Ruby::RbValue $value) returns num64 is native(RUBY) { * }

  # Array helpers
  sub p6_rb_array_length (Inline::Ruby::RbValue $value)
      returns int32
      is native(RUBY) { * }
  sub rb_ary_entry       (Inline::Ruby::RbValue $value, int32 $offset)
      returns Inline::Ruby::RbValue
      is native(RUBY) { * }

  multi method TO-P6() {
    self.TO-P6(p6_rb_type(self))
  }

  multi method TO-P6($type where RUBY_T_FIXNUM) {
    self.Numeric
  }

  multi method TO-P6($type where RUBY_T_TRUE) {
    self.Bool
  }

  multi method TO-P6($type where RUBY_T_FALSE) {
    self.Bool
  }

  multi method TO-P6($type where RUBY_T_NIL) {
    Any;
  }

  multi method TO-P6($type where RUBY_T_STRING) {
    self.Str
  }

  multi method TO-P6($type where RUBY_T_FLOAT) {
    self.Numeric
  }

  multi method TO-P6($type where RUBY_T_ARRAY) {
    self.List.map(*.TO-P6).list;
  }

  method Str() {
    if p6_rb_type(self) ~~ RUBY_T_STRING {
      rb_to_p6_string(self);
    } else {
      rb_to_p6_string( rb_funcall(self, rb_intern("to_s"), 0) );
    }
  }

  method Numeric() {
    given p6_rb_type(self) {
      when RUBY_T_STRING { rb_to_p6_string(self).Numeric() }
      when RUBY_T_FIXNUM { rb_to_p6_fixnum(self) }
      when RUBY_T_FLOAT  { rb_to_p6_dbl(self) }
      default { warn "Cannot convert to Numeric"; 0 }
    }
  }

  method Bool() {
    given p6_rb_type(self) {
      when RUBY_T_NIL   { False }
      when RUBY_T_FALSE { False }
      when RUBY_T_TRUE  { True }
      default { True }
    }
  }

  method List() {
    given p6_rb_type(self) {
      when RUBY_T_ARRAY {
        my $len = p6_rb_array_length(self);
        my @p6_array = [];
        for ^$len -> $offset {
          # @p6_array[$offset] = rb_ary_entry(self, $offset);
          @p6_array[$offset] = ::('Inline::Ruby::RbObject').new(value => rb_ary_entry(self, $offset));
        }
        @p6_array;
      }
      default { warn "Cannot convert to List" }
    }
  }

  # NativeCall routines for P6->RB conversions
  sub p6_to_rb_int (int32 $n) returns Inline::Ruby::RbValue is native(RUBY) { * }
  sub p6_to_rb_str (Str $s)   returns Inline::Ruby::RbValue is native(RUBY) { * }


  # Ruby values don't need to be converted
  multi method from(Inline::Ruby::RbValue $rb_value) {
    # say "from rbVal";
    $rb_value;
  }

  multi method from(Int $n) {
    # say "from int";
    p6_to_rb_int($n);
  }

  multi method from(Str $v) {
    # say "from str";
    p6_to_rb_str($v);
  }

  # Maybe not a good idea for :bleh<True> -> :bleh
  multi method from(Pair $v where $v.value === True) {
    my $rb_str = Inline::Ruby::RbValue.from($v.key);
    rb_funcall($rb_str, rb_intern("to_sym"), 0);
  }

  # VALUE rb_proc_new(VALUE (*)(ANYARGS/* VALUE yieldarg[, VALUE procarg] */), VALUE);
  # sub p6_to_rb_proc (Inline::Ruby::RbValue, Inline::Ruby::RbValue) returns Inline::Ruby::RbValue;


  multi method from($v) {
    say "Can't convert {$v.gist}, passing on";
    $v;
  }

}
