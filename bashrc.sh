#!/bin/sh

export VISUAL=vim
export EDITOR=$VISUAL
export TERMINAL=uxterm
export BROWSER=qutebrowser
export TIMEZONE="Europe/Rome"
export TZ="$TIMEZONE"
export ADB_HOST=adbd
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

_tmuxinit() {
  if tmux attach; then
    return $?
  fi

  if [ "$(whoami)" != "loli" ] || [ ! -f /.dockerenv ] ; then
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

case $- in
  *i*) ;;
  *) return ;;
esac

export TERM=xterm-256color
export IMX_SDK_DIR=~/toolchains/fsl-imx-fb
alias startx='exec startx'
alias ls='ls --color=auto'
alias t='_tmuxinit'
alias xi='sudo xbps-install'
alias xu='sudo xbps-install -Suv'
alias xr='sudo xbps-remove -R'
alias xq='xbps-query -Rs'
alias xl='xbps-query -l'
alias e='echo $?'

if [ "$(id -u)" -eq 0 ] ; then
  PS1=''\
'\[\033[01;31m\]( OwO) '\
'\[\033[01;33m\]\u@\h '\
'\[\033[01;30m\]\w '\
'\$\[\033[00m\] '\
''
else
  PS1=''\
'\[\033[01;30m\]( uwu) '\
'\[\033[01;32m\]\u@\h '\
'\[\033[01;34m\]\w '\
'\$\[\033[00m\] '\
''
fi

# generate an unique filename
#
# shellcheck disable=SC2120
autoname() {
  n=0
  basedir="${1:-.}"
  suffix="${2:-}"
  while true; do
    name="$basedir/$( date "+%F_%H-%M-%S_${n}${suffix}" )"
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
  if [ ! -v "$statcmd" ]; then
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

ffrectsel() {
    rect="$(xrectsel)"                       # wxh+x+y
    size="$(echo "${rect}" | cut -d'+' -f1)" # wxh
    w="$(echo "${size}" | cut -d'x' -f1)"    # w
    h="$(echo "${size}" | cut -d'x' -f2)"    # h
    w=$((w / 2 * 2))                         # round w h to multiples of 2
    h=$((h / 2 * 2))
    coords="$(echo "${rect}" | cut -d'+' -f2- | sed s/\+/,/g)" # x,y
    echo "|-s ${w}x${h} -i ${DISPLAY}+${coords}" | sed s/\|//g
}

cast() {
  # shellcheck disable=SC2119
  ffmpeg \
    -f x11grab \
    -thread_queue_size 512 \
    "${@}" \
    -c:v libx264 -r 60 \
    -vf "${CAST_VF:-null}" \
    -preset "${CAST_PRESET:-veryfast}" \
    -tune "${CAST_TUNE:-zerolatency}" \
    -pix_fmt "${CAST_PIXFMT:-yuv420p}" \
    -crf "${CAST_CRF:-23}" \
    -movflags "${CAST_MOVFLAGS:-+faststart}" \
    "$(autoname).mp4"
}

ucast() {
  # shellcheck disable=SC2119
  ffmpeg \
    -f x11grab \
    -thread_queue_size 512 \
    "${@}" \
    -c:v libx264rgb -qp 0 -r 60 \
    -preset "${CAST_PRESET:-ultrafast}" \
    "$(autoname).mp4"
}

# shellcheck disable=SC1004
alias fcast='CAST_VF="scale=960:540:flags=neighbor" \
  cast -s 1920x1080 -i ${DISPLAY}+0,0'
alias fucast='ucast -s 1920x1080 -i ${DISPLAY}+0,0'
alias scast='cast $(ffrectsel)'
alias sucast='ucast $(ffrectsel)'
