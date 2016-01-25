#include <ruby.h>
#include <stdio.h>

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

VALUE p6_rb_funcallv(VALUE obj, ID method, int argc, const VALUE* argv) {
  return rb_funcall2(obj, method, argc, argv);
}

VALUE protected_init_loadpath(VALUE obj) {
  printf("calling ruby_init_loadpath\n");
  ruby_init_loadpath();
  printf("back from calling ruby_init_loadpath\n");
  return Qnil;
}

int protect_ruby_init_loadpath() {
  // ruby_init_loadpath();
  VALUE result;
  int state;
  printf("calling rbprotect protected_init_loadpath\n");
  result = rb_protect(protected_init_loadpath, Qnil, &state);
  printf("back from calling rbprotect protected_init_loadpath\n");
  return state;
}
