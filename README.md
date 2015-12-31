# TITLE

Inline::Ruby

# SYNOPSIS

```
    use Inline::Ruby;
    EVAL 'puts "Hello!"', :lang<Ruby>;
```

# DESCRIPTION

Module for executing Ruby code and accessing Ruby libraries from Perl 6.

# STATUS

* This only barely works!
* You can currently EVAL code
* Some return types converted to Perl 6 values:
  * TRUE
  * FALSE
  * NIL
  * FIXNUM
  * STRING
  * FLOAT

# AUTHOR

Brock Wilcox <awwaiid@thelackthereof.org>
Some code from Stefan Seifert <nine@detonation.org>
