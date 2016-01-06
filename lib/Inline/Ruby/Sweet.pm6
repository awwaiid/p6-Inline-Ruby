
unit module Inline::Ruby::Sweet;

use Inline::Ruby;

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

use MONKEY-TYPING;
augment class Inline::Ruby::RbObject {
  method gist() {
    "«{ $.value }»:rb"
  }
}

