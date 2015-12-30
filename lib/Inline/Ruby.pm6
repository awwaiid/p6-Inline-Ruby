
unit class Inline::Ruby;

my $default_instance;

use NativeCall;
constant RUBY = 'ruby-2.1';

our sub ruby_init()
  is native(RUBY)
  { * }
our sub ruby_init_loadpath()
  is native(RUBY)
  { * }
our sub ruby_exec_node(OpaquePointer $node)
  is native(RUBY)
  { * }
our sub ruby_options(int32 $argc, CArray[Str] $argv)
  returns OpaquePointer
  is native(RUBY)
  { * }
our sub rb_eval_string_protect(Str $code, int32 $state is rw)
  returns OpaquePointer is native(RUBY)
  { * }
our sub rb_string_value_cstr(OpaquePointer $value) returns Str
  is native(RUBY)
  { * }

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
  die "RUBY EXCEPTION" if $state;
  $result;
}

multi sub EVAL(Cool $code, Str :$lang where { ($lang // '') eq 'Ruby' }, PseudoStash :$context) is export {
    state $rb;
    unless $rb {
        {
            my $compunit := $*REPO.need(CompUnit::DependencySpecification.new(:short-name<Inline::Ruby>));
            GLOBAL.WHO.merge-symbols($compunit.handle.globalish-package.WHO);
            #CATCH {
              ##X::Eval::NoSuchLang.new(:$lang).throw;
              #note $_;
              #}
        }
        $rb = ::("Inline::Ruby").default_instance;
    }
    $rb.run($code);
    # rb_string_value_cstr($rb.run($code));
}
