#include "ruby.h"

int p6_rb_type(VALUE obj) {
  return TYPE(obj);
}

int rb_to_p6_fixnum(VALUE obj) {
  return FIX2INT(obj);
}

char* rb_to_p6_string(VALUE obj) {
  return StringValuePtr(obj);
}

double rb_to_p6_dbl(VALUE obj) {
  return NUM2DBL(obj);
}

