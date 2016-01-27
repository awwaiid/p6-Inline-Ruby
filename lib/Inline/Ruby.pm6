
unit class Inline::Ruby;

=NAME Inline::Ruby - Execute Ruby code and libraries from Perl 6 programs

=begin SYNOPSIS
  use Inline::Ruby;

  EVAL 'puts "Hello!"', :lang<Ruby>;

  # EVAL is pretty verbose, let's make a shorthand
  sub postfix:<:rb>($code) {
    use MONKEY-SEE-NO-EVAL;
    EVAL $code, :lang<Ruby>;
  }

  # Method calling, some simple params
  say 'Time':rb.now.to_s;
  say '[2, 6, 8, 4]':rb.sort.slice(1,2).to_s;
=end SYNOPSIS

=begin DESCRIPTION
  Module for executing Ruby code and accessing Ruby libraries from Perl 6.

  Simple types, such as numbers and strings, are automatically converted. For
  more complex types, such as arrays, mostly they are kept in their original
  language and converted either explicitly or as necessary.
=end DESCRIPTION

my $default_instance;

use NativeCall;
constant RUBY = %?RESOURCES<libraries/rbhelper>.Str;

# say "Ruby: " ~ RUBY;

our $wrap_in_rbobject = -> $val {
  ::('Inline::Ruby::RbObject').new( value => $val );
  # ::('Inline::Ruby')::RbObject.new( value => $val );
};

use Inline::Ruby::RbValue;
use Inline::Ruby::RbObject;

# Native functions

sub ruby_init() is native(RUBY) { * }
sub ruby_init_loadpath() is native(RUBY) { * }
sub protect_ruby_init_loadpath() returns int32 is native(RUBY) { * }
# sub rb_protect(Pointer, Inline::Ruby::RbValue, int32 $state is rw) is native(RUBY) { * }

sub rb_eval_string_protect(Str $code, int32 $state is rw)
    returns Inline::Ruby::RbValue
    is native(RUBY) { * }

sub ruby_exec_node(Pointer $node)
    is native(RUBY) { * }

sub ruby_options(int32 $argc, CArray[Str] $argv)
    returns Pointer
    is native(RUBY) { * }

method BUILD() {
#   say "Ruby lib: " ~ RUBY;
  $default_instance //= self;
  ruby_init();
  
  # say "Ruby init loadpath...";
  # my $state = protect_ruby_init_loadpath();
  # say "Load init state: $state";
  ruby_init_loadpath();
  # my int32 $state = 0;
  # rb_eval_string_protect('puts "Hello from Ruby"', $state);
  # exit;

  # TODO: What else do we need to do?
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
  Inline::Ruby::RbObject.from( $rb.run($code) );
}




=AUTHOR Brock Wilcox <awwaiid@thelackthereof.org>

