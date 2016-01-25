
unit module Inline::Ruby::Sweet;

use Inline::Ruby;
# use Inline::Ruby :ALL :EXPORT;

sub postfix:<:rb>($code) is export {
  use MONKEY-SEE-NO-EVAL;
  EVAL $code, :lang<Ruby>;
}

multi sub infix:<+>(Inline::Ruby::RbObject $left-obj, Any $right-obj) is export {
  $left-obj."+"($right-obj);
}

multi sub infix:<->(Inline::Ruby::RbObject $left-obj, Any $right-obj) is export {
  $left-obj."-"($right-obj);
}

multi sub infix:<*>(Inline::Ruby::RbObject $left-obj, Any $right-obj) is export {
  $left-obj."*"($right-obj);
}

multi sub infix:</>(Inline::Ruby::RbObject $left-obj, Any $right-obj) is export {
  $left-obj."/"($right-obj);
}

multi sub infix:<%>(Inline::Ruby::RbObject $left-obj, Any $right-obj) is export {
  $left-obj."%"($right-obj);
}

multi sub postcircumfix:<[ ]>(Inline::Ruby::RbObject $left-obj, Any $right-obj) is export {
  $left-obj."[]"($right-obj);
}

# Ruby doesn't really differentiate between [] and {}
multi sub postcircumfix:<{ }>(Inline::Ruby::RbObject $left-obj, Any $right-obj) is export {
  $left-obj."[]"($right-obj);
}

use MONKEY-TYPING;
augment class Inline::Ruby::RbObject {
  method gist() {
    "«{ $.value }»:rb"
  }
}

role RubyPackage[Str $module] {
    # has $!parent;

    method new(*@args, *%args) {
      self.FALLBACK('new');
    }

    method FALLBACK($name, *@args) {
      # say "Calling $module method $name args @args[]";
      "$module":rb."$name"(|@args);
    }
}

sub ruby_require ($name, :$import is copy) is export {
  # say "Requiring ruby module $name";
  q:to/RUBYCODE/:rb;
    $created_class = []
    class Object
      def self.inherited(new_class)
        puts "Created: #{new_class}"
        $created_class << new_class
      end
    end
  RUBYCODE

  "require '$name'":rb;

  # TODO: Really we should back up and restore whatever was there
  q:to/RUBYCODE/:rb;
    class Object
      def self.inherited(new_class)
      end
    end
  RUBYCODE

  $import //= '$created_class':rb.List.map: { .Str };
  # say "Import: $import";

  for |$import -> $module {

    # Skip already existing classes
    if ::("$module") !~~ Failure {
      say "NOT creating proxy for class «$module»:rb (class already defined)";
      next;
    }

    # say "Creating proxy for class «$module»:rb";
    my $class := Metamodel::ClassHOW.new_type( name => $module );
    $class.^add_role(RubyPackage[$module]);

    $class.^compose;

    # register the new class by its name
    my @parts = $module.split('::');
    my $inner = @parts.pop;
    my $ns := ::GLOBAL.WHO;
    for @parts {
        $ns{$_} := Metamodel::PackageHOW.new_type(name => $_) unless $ns{$_}:exists;
        $ns := $ns{$_}.WHO;
    }
    my @existing = $ns{$inner}.WHO.pairs;
    $ns{$inner} := $class;
    $class.WHO{$_.key} := $_.value for @existing;
  }

}

class ::CompUnit::Repository::Ruby does CompUnit::Repository {

  my $prev-repo = $*REPO.repo-chain[*-1];
  $prev-repo.next-repo = CompUnit::Repository::Ruby.new;

  method id() {
      'ruby'
  }

  method need(CompUnit::DependencySpecification $spec, CompUnit::PrecompilationRepository $precomp) {
      # say "need {$spec.short-name} from {$spec.from}";
      if $spec.from eq 'Ruby' {
        # say "Loading a ruby lib... {$spec.perl}";
        # say "Loading a ruby lib...";
        ruby_require($spec.short-name);

        return CompUnit.new(
          short-name => $spec.short-name,
          handle     => CompUnit::Handle.from-unit(::($spec.short-name).WHO),
          repo       => self,
          repo-id    => $spec.short-name,
          from       => $spec.from,
        );

      } else {
        $prev-repo.next-repo = CompUnit::Repository;
        LEAVE {
            $prev-repo.next-repo = self;
        }
        $*REPO.need($spec)
      }
  }

  method loaded() {
      []
  }

  method path-spec() {
      'ruby#'
  }
}
