#!/bin/sh

export VISUAL=vim
export EDITOR=$VISUAL
if [ -f ~/.term ]; then
  term=$(cat ~/.term)
  export TERMINAL="$term"
else
  export TERMINAL=uxterm
fi
export GPG_TTY=$(tty)
export GPG_AGENT_INFO=${HOME}/.gnupg/S.gpg-agent:0:1
source <(gopass completion bash)
export BROWSER=url-open
export TIMEZONE="Europe/Rome"
export TZ="$TIMEZONE"
if [ "$TERM" = rxvt ]; then
  export LC_ALL="en_US.ISO-8859-1"
else
  export LC_ALL="en_US.UTF-8"
fi
export LANG="$LC_ALL"
export LANGUAGE="$LANG"
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"
export XMODIFIERS="@im=fcitx"
export ADB_HOST=adbd
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"
export DOTNET_ROOT="$HOME/dotnet"
export PATH="$PATH:$HOME/dotnet"
export PATH="$PATH:$HOME/.cargo/bin"

# temporary TODO make packages for these
export PATH="$PATH:/home/loli/3src/chatterino2/build/bin"
export PATH="$PATH:/home/loli/src/bdf2x/bin"
export PATH="$PATH:/home/loli/src/tos-tools"
export PATH="$PATH:/home/loli/.gem/ruby/2.6.0/bin"

if aplay -l | grep -q PCH; then
  export ALSA_DEVICE="PCH"
else
  export ALSA_DEVICE="Intel"
fi

for b in qutebrowser icecat firefox; do
  if command -v "$b" >/dev/null 2>&1; then
    export ACTUAL_BROWSER="$b"
    break
  fi
done

if [ -z $ACTUAL_BROWSER ] && command -v apulse >/dev/null 2>&1; then
  for b in icecat firefox; do
    if command -v "$b" >/dev/null 2>&1; then
      export ACTUAL_BROWSER="apulse $b"
      break
    fi
  done
fi

_tmuxinit() {
  if [ "$(whoami)" != "loli" ] || [ ! -f /.dockerenv ] ; then
    tmux attach || tmux
    return $?
  fi

  # shellcheck disable=SC2009
  ps -f -u "$USER" | grep -q '[x]pra' || xpra start :9
  xpra attach :9 --opengl=no > /tmp/xpra-attach.log 2>&1 &
  export DISPLAY=:9

  if tmux attach; then
    xpra detach :9
    return $?
  fi

  cd || return $?

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
  tmux rename-window code
  tmux send-keys 'cd ~/src' C-m
  tmux split-window -h
  tmux send-keys 'cd ~/src' C-m

  tmux attach
  xpra detach :9
}

# -------------------------------------------------------------------------

case $- in
  *i*) ;;
  *) return ;;
esac

stty stop undef
stty start undef
case "$0" in
bash)
  # shellcheck disable=SC2039
  shopt -s checkwinsize ;;
esac

export IMX_SDK_DIR=~/toolchains/fsl-imx-fb
alias startx='exec startx'
alias ls='ls --color=auto'
alias t='_tmuxinit'
alias xo='xdg-open'
alias xi='sudo xbps-install'
alias xu='sudo xbps-install -Suv'
alias xr='sudo xbps-remove -R'
alias xq='xbps-query -Rs'
alias xl='xbps-query -l'
alias xff='xbps-query -Ro'
alias pi='sudo pacman -S'
alias pu='sudo pacman -Syuuu && sudo pacman -Fy'
alias pr='sudo pacman -Rs'
alias pq='pacman -Ss'
alias pl='pacman -Qqe'
alias pf='pacman -Fs'
alias e='echo $?'
alias nonascii='grep --color='auto' -P -n "[\x80-\xFF]"'

if [ "$(id -u)" -eq 0 ] ; then
  PS1=''\
'\[\033[01;31m\]( OwO) '\
'\[\033[01;33m\]\u@\h '\
'\[\033[01;90m\]\w '\
'\$\[\033[00m\] '\
''
else
  PS1=''\
'\[\033[00m\]( uwu) '\
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

screenres() {
  xrandr 2>&1 | awk -F '[ +]' '/primary/ { print $4 }'
}

halfscreenres() {
  size=$(screenres)
  w=$(echo "$size" | awk -Fx '{ print $1 }')
  h=$(echo "$size" | awk -Fx '{ print $2 }')
  echo "$(( w / 2 )):$(( h / 2 ))"
}

screencoords() {
  xrandr 2>&1 | awk -F '[ +]' '/primary/ { printf "%s,%s\n",$5,$6 }'
}

alias fcast='CAST_VF="scale=$(halfscreenres):flags=neighbor" cast -s $(screenres) -i ${DISPLAY}+0,0'
alias afcast='CAST_VF="scale=$(halfscreenres):flags=neighbor" cast -s $(screenres) -i ${DISPLAY}+0,0 -f alsa -i dsnooper'
alias lfcast='CAST_VF="scale=$(halfscreenres):flags=neighbor" cast -s $(screenres) -i ${DISPLAY}+0,0 -f alsa -i loopout'
alias frcast='cast -s $(screenres) -i ${DISPLAY}+$(screencoords)'
alias afrcast='cast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa -i dsnooper'
alias lfrcast='cast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa -i loopout'
alias afucast='ucast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa -i dsnooper'
alias lfucast='ucast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa -i loopout'
alias fucast='ucast -s $(screenres) -i ${DISPLAY}+$(screencoords)'
alias scast='cast $(ffrectsel)'
alias sucast='ucast $(ffrectsel)'

tgrep() {
  if [ "$#" -lt 1 ]; then
    echo "recursively grep directory and sort result by modification time"
    echo "usage: tgrep text [directory]"
    return 1
  fi
  find "${2:-.}" -type f \
    -exec grep -q "$1" {} \; \
    -exec find {} -printf "%T@ " \; \
    -exec grep -H "$1" {} \; |
  sort -n | awk '{ $1=""; print $0 }'
}

xf() {
  xbps-query -Ro "*/$1"
}

xls() {
  xbps-query -p install-date -s '' | awk '{ print $2,$3,$1 }' | sort
}

fbss() {
  dumpfile="$(autoname ~/pics/ss _fb.dump)"
  cp /dev/fb0 "$dumpfile" &&
  fbgrab -w 1920 -h 1080 -b 32 -f "$dumpfile" "$(autoname ~/pics/ss _fb.png)"
}

[ "$(tty)" = "/dev/tty1" ] && [ "$(whoami)" = "loli" ] &&
  ! pgrep -x Xorg >/dev/null && exec startx
