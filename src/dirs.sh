#!/bin/bash

doc () { :; }

_silent() {
    "$@" >/dev/null
}

_dirs() {
    local ds=($(command dirs))
    local i=0
    while [ "${ds[$i]}" != "" ]; do
        echo $i: ${ds[$i]};
        i=$((i+1));
    done
}

_silent_pushd() {
    _silent command pushd "$@"
}

_silent_popd() {
    _silent command popd "$@"
}

cs() {
    doc "a wrapper around cd which tracks dirs and updates emacs tramp"
    _silent_pushd .
    command cd "$@"
    _update_tramp
}

# ad(){
#     local DIR="$(if [[ -z "$1" ]]; then echo "$PWD"; else "$1"; fi)"
#     cp ~/.common_dirs ~/.common_dirs.bak
#     echo "$DIR" >> ~/.common_dirs
#     sort ~/.common_dirs | uniq > ~/.common_dirs.new
#     mv ~/.common_dirs.new ~/.common_dirs
# }

# rd(){
#     local DIR="$(if [[ -z "$1" ]]; then echo "$PWD"; else "$1"; fi)"
#     cp ~/.common_dirs ~/.common_dirs.bak
#     grep -v -F "$DIR" ~/.common_dirs > ~/.common_dirs.new
#     mv ~/.common_dirs.new ~/.common_dirs
# }

mcd () {
  mkdir -p "$@" && cs "$@"
}


dired() {
    doc "open the cwd inside Emacs' dired"
    local args=""
    [[ "$TERM" != "eterm-color" ]] && args=" -nw ";
    emacsclient $args -e "(find-file \"$PWD\")" >/dev/null
}

sunrise() {
    doc "open the cwd inside Emacs' sunrise-commander"
    local args=""
    [[ "$TERM" != "eterm-color" ]] && args=" -nw ";
    emacsclient $args -e "(let ((default-directory \"$PWD\")) (sunrise-cd))" >/dev/null
}


t() {
    tree -C $@ | LESS='FSRX' less
} 

setup_aliases() { 
    alias ..='cs ..'
    alias b='cd -'
    alias D='builtin dirs -v'
    alias p='_silent_pushd .'
    alias po='_silent_popd'
    alias ccd='[[ -e ~/.common_dirs ]] && cat ~/.common_dirs'
    
    alias up="cs .."
    alias up2="cs ../.."
    alias up3="cs ../../.."
    alias h="cs ~/"
    alias s="cs ~/src"
    
    alias drd=dired
    alias sn=sunrise
    alias ,=sunrise
}

# dir_bc_commondirs_cat () {
# 	# shape argument a bit - so it could be specified as "a b" in case
# 	# if it has spaces
# 	arg=`echo $2| sed -e 's/^"\(.*\)"/\1/g' \
#                       -e 's/\([^\]\) /\1\\\ /g'`
#         common_dirs | tail -n +2 | grep "$arg" | sed -e 's| |\\ |g'
# 	return 0
# }
# dir_bc_commondirs () {
# 	matches_num=`dir_bc_commondirs_cat '$1' "$2"| wc -l`
# 	if [ $matches_num -eq 1 ]; then
# 		# so we have only 1 match - it is safe to substitute!
# 		COMPREPLY=( [0]="$(dir_bc_commondirs_cat 'XXX' "$2")" )
# 	else
# 		# return original name (but not empty!) -- that seems to
# 		# forbid complition to get into the cmdline (which is what we
# 		# want since it would place the line which would not complete
# 		# anylonger to the same set as the original string)
# 		[ $1 == 'cd' ] || COMPREPLY=( "$2" )
# 	fi
# 	return 0
# }

# if [[ -f ~/tr_toolchain/bash/dyndirstack.sh ]]; then
#     . ~/tr_toolchain/bash/dyndirstack.sh
#     cs() {
#         dir_addcurrent
#         command cd $@
#         _update_tramp
#     }
#     #alias j='jcd'
#     alias j0='j 0'
#     alias j1='j 1'
#     alias j2='j 2'
#     alias j3='j 3'
#     alias j4='j 4'
#     alias j5='j 5'

#     alias D='dir_list_num| sed -e "s#$HOME#~#g" | tail -n+1'
#     alias jd=cd
#     complete -F dir_bc_commondirs -C dir_bc_commondirs_cat jd

# fi
