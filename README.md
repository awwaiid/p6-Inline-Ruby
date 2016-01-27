# TITLE

Inline::Ruby


# SYNOPSIS

```
    use Inline::Ruby;

    EVAL 'puts "Hello!"', :lang<Ruby>;
    say EVAL('Time', :lang<Ruby>).now.to_s;

    # Sweet version, some of this will be pulled into Inline::Ruby
    # Includes more extreme or experimental features

    use Inline::Ruby::Sweet;

    # Method calling, some simple params, cast to Str
    say ~'Time':rb.now;
    say ~'[2, 6, 8, 4]':rb.sort.slice(1,2);
```

# DESCRIPTION

Module for executing Ruby code and accessing Ruby libraries from Perl 6.

# BUILD / DEV

In theory you can get it from panda. Let me know if that's
true :)

I'm running Debian unstable with ruby2.2-dev. Then:

    ./configure.pl6  # Creates Makefile and runs make
    make test        # or prove -e 'perl6 -Ilib' -v

# STATUS

Master (released) branch [![Build Status](https://travis-ci.org/awwaiid/p6-Inline-Ruby.svg?branch=master)](https://travis-ci.org/awwaiid/p6-Inline-Ruby)

Develop branch [![Build Status](https://travis-ci.org/awwaiid/p6-Inline-Ruby.svg?branch=develop)](https://travis-ci.org/awwaiid/p6-Inline-Ruby)

* This only barely works!
  * Lots of missing features
  * Sometimes segfaults!
  * Only tested on my machine!
* You can currently EVAL code
* Some return types converted to Perl 6 values:
  * TRUE
  * FALSE
  * NIL
  * FIXNUM
  * STRING
  * FLOAT
  * Objects are wrapped in an RbObject
* You can call basic methods!
* Some param types converted to Ruby values:
  * Int
  * Str

# Ruby::Inline::Sweet - Experimental!

In addition to the above, there is an even MORE experimental module for you to
try! Beware that it tends to segfault instead of catching and showing
exceptions :)

    use Inline::Ruby::Sweet;

    # Add :rb postfix to eval a string
    # In a string context, .to_s is called in ruby
    # In perl6, .gist is called during printing, which wraps native-ruby values
    # in «...»:rb. So when you see that, you know you are looking at a wrapped
    # native Ruby object

    say '5':rb;      #=> «5»:rb

    # If you do some basic math (+,-,*,/), they will auto-convert

    say '5':rb + 2   #=> «7»:rb

    # Do it the other way around and you'll get Perl6 values instead

    say 2 + '5':rb   #=> 7

    # Experimental native 'use'. Tries to import things

    use csv:from<Ruby>;
    my $data = CSV.read('examples/hiya.csv')
    #=> «[["id", "name"], ["1", "andy"], ["2", "bella"], ["3", "chad"], ["4", "dua"]]»:rb

    # That gets importing wrong sometimes, so you can do it more directly
    # Here we'll slurp the file in Perl6, feeding the resulting string to Ruby JSON

    BEGIN { ruby_require 'json', :import<JSON> };
    my $data = JSON.parse("examples/slide-up.json".IO.slurp);
    #=> «[{"type"=>"ClutterGroup", "id"=>"actor", ... }]»:rb

    # Now $data contains a ruby Array with nested hashes, wrapped in a P6 proxy
    # object. You can call methods and some operators, such as []. Note that ruby
    # uses [] and not {} for hash access! But we alias {} so you can still use it.

    say $data.length       #=> «2»:rb
    say $data[0]["type"]   #=> «ClutterGroup»:rb
    say $data[0]<type>     #=> «ClutterGroup»:rb

    # The value there is still a RbObject (proxy object). You can force Str or
    # Num context

    say $data[0]<children>[1]<depth>    #=> «20.0»:rb
    say ~$data[0]<children>[1]<depth>   #=> 20.0

    # Can call methods with blocks!

    "[1,2,3]":rb.map: -> $n { 1 + $n }         #=> «2, 3, 4»:rb

    use csv:from<Ruby>;
    CSV.foreach: 'customers.csv', -> $row {
      say $row[2];
    }


# NOTES/TODO - Brainstorming and such.

* Nice reference https://silverhammermba.github.io/emberb/c/
* A big trick is deciding when and how much to auto-convert between langs
  * It's nice to leave things in Ruby if they start there, so we don't have to copy it all over
  * Final values are nice to have as native Perl 6
  * Maybe we should only explicit-convert
* Mmm... maybe there should be two layers of .to_p6
  * One would do simple types -- strings, numbers
  * Second would do complex types -- Array, Hash
  * The simple would be called implicitly, the second explicit
* Would be neat: RB['[1,2,3]'].each: { puts $^a }
  * Where ruby 'each' is being passed a p6-callback-block
* Use https://doc.perl6.org/language/subscripts instead of postcircumfix
* Write up Lang Integration Guide
* Separate out reusable roles

Imagine this:


# LICENSE

The Artistic License 2.0 -- See LICENSE file.

# AUTHOR

Brock Wilcox <awwaiid@thelackthereof.org>
Some code from Stefan Seifert <nine@detonation.org>
