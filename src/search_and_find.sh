#!/bin/bash

## Python related
killpycs(){
  find . -name "*.pyc" -exec rm -rf {} \;
}

pyfind() {
  local match
  if match="$(python -c "import $1; print $1.__file__")"; then
      match="${match/.pyc/.py}"
      grep -q '__init__.py$' <<< "$match" && dirname "$match" || echo "$match"
  else 
      return 1
  fi
}
