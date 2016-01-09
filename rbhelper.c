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

int p6_to_rb_int(int n) {
  return INT2FIX(n);
}

int p6_to_rb_str(char* s) {
  return rb_str_new2(s);
}

int p6_rb_array_length(VALUE obj) {
  return RARRAY_LENINT(obj);
}

