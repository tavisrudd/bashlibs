#!/bin/bash

# the color strings here are specially escaped for PS1 so readline can
# ignore their width in the prompt width calculation
# see https://wiki.archlinux.org/index.php/Color_Bash_Prompt
RESET_COLOR="\[\e[00m\]"

RED="\[\e[01;31m\]"
GREEN="\[\e[0;32m\]"
YELLOW="\[\e[0;33m\]"
BOLD_GREEN="\[\e[01;32m\]"
BOLD_MAGENTA="\[\e[01;35m\]"

if [[ "$HOSTNAME" == "vm1" ]]; then
    # my main host
    PROMPT_BORDER_FG="${PROMPT_BORDER_FG-"$GREEN"}"
    PROMPT_USERSTR="${PROMPT_USERSTR-"${RED}\\h"}"
fi
PROMPT_BORDER_FG="${PROMPT_BORDER_FG-"$BOLD_MAGENTA"}"
PROMPT_USERSTR="${PROMPT_USERSTR-"\\u@${RED}\\h"}"
PROMPT_PADDING="${PROMPT_PADDING-"   "}"

backgroundjobs() {
  echo "$_JOBS" | python -c 'if 1:
    import sys
    jobs = sys.stdin.read().splitlines()
    items = ["\033[36;1m%s\03" % x.split()[2] for x in jobs if x.strip()]
    if items:
      print "\033[37;1m running %s" % ", ".join(items)
  '
}
prompt_configure() {    
    ( hg help dss_prompt &> /dev/null ) && export use_dss_hg_prompt=true
    PROMPT_LINE1_PREFIX="$PROMPT_PADDING$(prompt_border ┌─)"
    PROMPT_MIDDLE_LINE_PREFIX="$PROMPT_PADDING$(prompt_border '│')"
    PROMPT_FINAL_LINE_PREFIX="$PROMPT_PADDING$(prompt_border └─)"
    export PS2="$PROMPT_BORDER_FG>$RESET_COLOR"
}
prompt_part() {
    echo "${PROMPT_BORDER_FG}[${RESET_COLOR}${*}${PROMPT_BORDER_FG}]${RESET_COLOR}"
}
prompt_git() {
    if rfind .git >/dev/null; then
        vcprompt -f"${RESET_COLOR}%s %r %b${RED}%m${YELLOW}%u${GREEN}%a $(git stash list | cut -f1 -d:)"
    fi 
}
prompt_vc() {
    if [[ $use_dss_hg_prompt ]]; then
        hg dss_prompt 2>/dev/null
    else
        prompt_git
    fi
}

prompt_border() {
    echo "${PROMPT_BORDER_FG}${*}${RESET_COLOR}"
}
prompt_virtualenv() {
    local venv_file="$(rfind .venv >/dev/null 2>&1)"
    local active="$VIRTUAL_ENV"
    local vprompt=""
    if [[ "$active" ]]; then
        active=$(basename "$active")
        vprompt="$vcprompt${RED}$active"
    fi
    if [[ "$venv_file" ]]; then
        local venv=$(< "$venv_file")
        if [[ "$venv" != "$active" ]]; then
            [[ "$active" ]] && vprompt="$vprompt "
            vprompt="$vprompt${YELLOW}$venv"
        fi
    fi
    echo "$vprompt"
}

render_ps1() {
    local EXITSTATUS=$1 # we're in a sub-shell so $? won't work
    local line1="$PROMPT_LINE1_PREFIX$(prompt_part "$PROMPT_USERSTR ${BOLD_GREEN}\\w $(prompt_vc)")"
    local vprompt="$(prompt_virtualenv)"
    if [[ "$vprompt" ]]; then 
        line1="${line1}$(prompt_border ——)$(prompt_part "$vprompt")"
    fi
    if [[ "$AWS_ENV" ]]; then
        line1="${line1}$(prompt_border ——)$(prompt_part "$AWS_ENV")"
    fi
    line1="${line1}$(prompt_border ——)$(prompt_part "${norm_color}$(date "+%b-%d") \\t")"
    [[ $EXITSTATUS -eq 0 || $EXITSTATUS -eq 128 ]] || local STATUSMARK="${RED} $EXITSTATUS"
    local hist_and_status="\\!${STATUSMARK}"
    local line1="${line1}$(prompt_part "$hist_and_status")"

    ## @@TR: add the minutes/hours my last hg commit - local repo vs all
    echo "$line1"
    local middle_line
    type prompt_middle &>/dev/null && prompt_middle | while read middle_line; do 
        echo "${PROMPT_MIDDLE_LINE_PREFIX} ${GREEN}$middle_line$RESET_COLOR"
    done 
    if [[ -n "$_JOBS" ]]; then
        middle_line=$(backgroundjobs)
        echo "${PROMPT_MIDDLE_LINE_PREFIX} ${GREEN}$middle_line$RESET_COLOR"
    fi
    echo "${PROMPT_FINAL_LINE_PREFIX}$PROMPT_BORDER_FG>${RESET_COLOR} "
}


set_fancy_prompt() {
    prompt_configure
    # the string below is not meant to be expanded till later
    export PROMPT_COMMAND='_EX=$?; export _JOBS="$(jobs)";PS1="$(render_ps1 $_EX)";history -a;'
}

set_norm_prompt() { # emerg reset
    export PROMPT_COMMAND='history -a'
    export PS1="${BOLD_GREEN}\w \$${RESET_COLOR} "
}

set_fancy_prompt # default
