# TITLE

Inline::Ruby

# SYNOPSIS

```
    use Inline::Ruby;

    EVAL 'puts "Hello!"', :lang<Ruby>;

    # EVAL is pretty verbose, let's make a shorthand
    sub circumfix:<RB[ ]>($code) {
      use MONKEY-SEE-NO-EVAL;
      EVAL $code, :lang<Ruby>;
    }

    # Method calling, some simple params
    say RB['Time'].now.to_s;
    say RB['[2, 6, 8, 4]'.sort.slice(1,2).to_s;
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

# NOTES - Brainstorming and such.

* Mmm... maybe there should be two layers of .to_p6
  * One would do simple types -- strings, numbers
  * Second would do complex types -- Array, Hash
  * The simple would be called implicitly, the second explicit
* Would be neat: RB['[1,2,3]'].each: { puts $^a }
  * Where ruby 'each' is being passed a p6-callback-block

Imagine this:

    use CSV:from<Ruby>;

    CSV.foreach: 'customers.csv', -> $row {
      say $row[2];
    }

# LICENSE

The Artistic License 2.0 -- See LICENSE file.

# AUTHOR

Brock Wilcox <awwaiid@thelackthereof.org>
Some code from Stefan Seifert <nine@detonation.org>
