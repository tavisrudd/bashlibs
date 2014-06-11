#!/bin/bash

## Python related
killpycs(){
  find . -name "*.pyc" -exec rm -rf {} \;
}

pyfind() {
  local x="$(python -c "import $1; print $1.__file__" | sed 's/\.pyc$/\.py/')"
  [[ $? -ne 0 ]] && return $?
  grep -q "__init__.py$" <<< "$x" && echo $(dirname "$x") || echo "$x"
}
