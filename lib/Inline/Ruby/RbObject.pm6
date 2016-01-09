
# I feel like this should be OK going IN the class...
use Inline::Ruby::RbValue;

#| Represent a Ruby object. Anything you can do method calls on.
class Inline::Ruby::RbObject {

  use NativeCall;
  constant RUBY = %?RESOURCES<libraries/rbhelper>.Str;

  has Inline::Ruby::RbValue $.value;

  # These are inherited from Any... let's bypass that
  # so the actual Ruby gets called
  method sort(*@x)  { self.FALLBACK("sort",  |@x); }
  method first(*@x) { self.FALLBACK("first", |@x); }
  method push(*@x)  { self.FALLBACK("push",  |@x); }
  method join(*@x)  { self.FALLBACK("join",  |@x); }

  method Str()     { $.value.Str() }
  method Numeric() { $.value.Numeric() }
  method Bool()    { $.value.Bool() }
  method List()    { $.value.List() }
  method Array()   { $.value.Array() }

  sub rb_funcallv(
        Inline::Ruby::RbValue $obj,
        Inline::Ruby::RbValue $symbol,
        int32 $argc,
        CArray[Inline::Ruby::RbValue] $argv)
      returns Inline::Ruby::RbValue
      is native(RUBY) { * }

  # string -> symbol
  sub rb_intern(Str $val)
      returns Inline::Ruby::RbValue
      is native(RUBY) { * }

  #| Most methods can be called directly on the Ruby VALUE
  method FALLBACK($method_name, +@args) {
    # I'd rather do this, but it doesn't work; first there is a compile-time
    # issue with CArray[Inline::Ruby::RbValue] from within itself; then after
    # that it just kinda acts funny.
    # return $.value.invoke-method($method_name, @args).to_p6;

    # say "Calling $method_name with arguments: @args[]";
    my $argc = @args.elems;
    my $argv = CArray[Inline::Ruby::RbValue].new;
    $argv[$_] = Inline::Ruby::RbValue.from(@args[$_]) for ^@args.elems;
    Inline::Ruby::RbObject.from(
      rb_funcallv($.value, rb_intern($method_name), $argc, $argv)
    );
  }

  #| Build a new Ruby Object from a Perl 6 value, first wrapping it
  #| as an Inline::Ruby::RbValue
  method from($p6_value) {
    Inline::Ruby::RbObject.new( value => Inline::Ruby::RbValue.from($p6_value) );
  }

}

