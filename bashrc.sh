#!/bin/sh

export VISUAL=vim
export EDITOR=$VISUAL
export TIMEZONE="Europe/Rome"
export TZ="$TIMEZONE"
export ADB_HOST=adbd
export PATH="$PATH:~/bin"

_tmuxinit() {
  if tmux attach; then
    return $?
  fi

  if [ ${USER} != "loli" ] || [ ! -f /.dockerenv ] ; then
    tmux
    return $?
  fi

  tmux new-session -d
  tmux rename-window grind
  tmux send-keys 'cd ~/grind/itl-linux-fw' C-m
  tmux send-keys 'vim src/daemon.cpp' C-m
  tmux split-window -h
  tmux send-keys 'cd ~/grind/itl-linux-fw' C-m

  tmux new-window
  tmux rename-window hours
  tmux send-keys 'cd ~/grind/hours' C-m
  tmux send-keys 'git pull' C-m
  tmux send-keys 'vim hours' C-m
  tmux split-window -h
  tmux send-keys 'cd ~/grind/hours' C-m
  tmux select-pane -l

  tmux new-window
  tmux rename-window shigebot
  tmux send-keys 'cd ~/src/disabled-shigebot' C-m
  tmux send-keys './shigebot' C-m

  tmux new-window
  tmux rename-window code
  tmux send-keys 'cd ~/src' C-m
  tmux split-window -h
  tmux send-keys 'cd ~/src' C-m

  tmux attach
}

# -------------------------------------------------------------------------

[[ $- != *i* ]] && return

export TERM=xterm-256color
export IMX_SDK_DIR=~/toolchains/fsl-imx-fb
alias ls='ls --color=auto'
alias t='_tmuxinit'
alias xi='sudo xbps-install'
alias xu='sudo xbps-install -Suv'
alias xr='sudo xbps-remove -R'
alias xq='xbps-query -Rs'
alias xl='xbps-query -l'

if [[ ${EUID} == 0 ]] ; then
    PS1='
\[\033[01;31m\]( OwO) \
\[\033[01;33m\]\u@\h \
\[\033[01;30m\]\w \
\$\[\033[00m\] \
'
else
    PS1='\
\[\033[01;30m\]( uwu) \
\[\033[01;32m\]\u@\h \
\[\033[01;34m\]\w \
\$\[\033[00m\] \
'
fi

# generate an unique filename
#
autoname() {
  n=0
  basedir="${1-.}"
  suffix="${2-}"
  while true; do
    name="$basedir/$( date +%F_%H-%M-%S_${n}${suffix} )"
    [ ! -e "$name" ] && break
    n=$(( n + 1 ))
  done
  echo "$name"
}

# print the nth most recently modified file(s) in the current
# directory
#
# $ recent
# newest_file
# $ recent 1 3 4
# latest_file
# 3rd_latest_file
# 4th_latest_file
#
recent() {
  statcmd="gstat"
  if ! which "$statcmd" 2>&1 >/dev/null; then
    statcmd="stat"
  fi
  unset sedexp
  for n in "${@}"; do
    sedexp="${sedexp}${n}p;"
  done
  find . -maxdepth 1 -exec $statcmd -c'%Z:%n' {} + |
    sort -r |
    cut -d':' -f2- |
    sed /^\.$/d |
    sed -n "${sedexp-1p;}"
}
