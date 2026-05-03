{
  elisp = "(defvar bar 1)";
  overlay = _final: prev: { someNumber = prev.someNumber + 1; };
}
