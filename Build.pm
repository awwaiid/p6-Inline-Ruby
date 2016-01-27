use v6;
use Panda::Common;
use Panda::Builder;
use Shell::Command;
use LibraryMake;

class Build is Panda::Builder {

  #| Call out to Ruby to figure out what compile flags we should use
  sub ruby-cc-config {
    # shell(q{ ls -laR /home/travis/.rvm/rubies/ruby-2.3.0 });
    # shell(q{
    #   ruby -rmkmf -e '
    #     print RbConfig::CONFIG.inspect
    #   '
    # });
    my $rb-config-cmd = shell(q{
      ruby -rmkmf -e '
        print RbConfig::CONFIG["LIBS"]
        print " -lruby"
        print " -Wl,-rpath," + RbConfig::CONFIG["libdir"]
        print " -L" + RbConfig::CONFIG["libdir"]
        print " -I" + RbConfig::CONFIG["rubyarchhdrdir"]
        print " -I" + RbConfig::CONFIG["rubyhdrdir"]
      '
    }, :out);
    my $rb-config = $rb-config-cmd.out.slurp-rest;

    $rb-config;
  }

  method build($dir) {
    my %vars = get-vars($dir);
    %vars<rbhelper> = $*VM.platform-library-name('rbhelper'.IO);
    %vars<rb-gcc-args> = ruby-cc-config();
    mkdir "$dir/resources" unless "$dir/resources".IO.e;
    mkdir "$dir/resources/libraries" unless "$dir/resources/libraries".IO.e;
    process-makefile($dir, %vars);
    my $goback = $*CWD;
    chdir($dir);
    shell(%vars<MAKE>);
    chdir($goback);
  }
}

# vim: ft=perl6
