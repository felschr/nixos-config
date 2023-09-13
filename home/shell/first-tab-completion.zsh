#!/usr/bin/env zsh
# shellcheck disable=all

first-tab-completion() {
  if [[ $#BUFFER == 0 ]]; then
    BUFFER="cd "
    CURSOR=3
    zle list-choices
    # zle backward-kill-word # breaks completion
  else
    zle expand-or-complete
  fi
}
zle -N first-tab-completion
