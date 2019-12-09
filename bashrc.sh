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
if [ "$(hostname)" != "libguestfs" ]; then
  export TOS_FSWRP="ssh -p 2224 192.168.1.2"
fi
export ADB_HOST=adbd
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export DOTNET_ROOT="$HOME/dotnet"
export PATH="$HOME/dotnet:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=0

# temporary TODO make packages for these
export PATH="$PATH:/home/loli/src/bdf2x/bin"
export PATH="$PATH:/home/loli/src/tos-tools"
export PATH="$PATH:/home/loli/.gem/ruby/2.6.0/bin"
export PATH="$PATH:/home/loli/src/v"
export PATH="/home/loli/.pyenv/bin:$PATH"
export PATH="/home/loli/sw/dex-tools-2.1-SNAPSHOT:$PATH"
if [ "$(id -u)" -ne 0 ] ; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

if command -v aplay 2>&1 >/dev/null && aplay -l | grep -q PCH; then
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
  export DISPLAY=:9
  ps -f -u "$USER" | grep -q '[x]pra' || xpra start :9
  xpra attach :9 --opengl=no > /tmp/xpra-attach.log 2>&1 &

  if tmux attach; then
    xpra detach :9
    return $?
  fi

  cd || return $?

  tmux new-session -d
  tmux rename-window grind
  tmux send-keys 'neomutt' C-m
  tmux split-window -h
  tmux send-keys 'hangups' C-m

  tmux new-window
  tmux rename-window char
  tmux send-keys 'weechat' C-m

  tmux new-window
  tmux rename-window code
  tmux send-keys 'cd ~/src' C-m
  tmux split-window -h
  tmux send-keys 'cd ~/src' C-m
  tmux select-pane -l

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
alias xf='xlocate'
alias pi='sudo pacman -S'
alias pu='sudo pacman -Syuuu && sudo pacman -Fy'
alias pr='sudo pacman -Rs'
alias pq='pacman -Ss'
alias pl='pacman -Qqe'
alias pf='pacman -Fs'
alias yi='yay -S'
alias yu='yay -Syuuu && sudo yay -Fy'
alias yr='yay -Rs'
alias yq='yay -Ss'
alias yl='yay -Qqe'
alias yf='yay -Fs'
alias e='echo $?'
alias nonascii='grep --color=auto -P -n "[\x80-\xFF]"'
alias nano='nano -liE -T2 --softwrap'
alias rs='rsync --archive --verbose --recursive'
alias xk='xkill -id $(xwininfo | grep id: | cut -d " " -f4)'

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

export ffmpeg_input_params="-thread_queue_size 512"

cast() {
  # shellcheck disable=SC2119
  nice --adjustment=-20 \
  ffmpeg \
    -f x11grab $ffmpeg_input_params \
    "${@}" \
    -c:v libx264 -r "${CAST_FPS:-60}" \
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
  nice --adjustment=-20 \
  ffmpeg \
    -f x11grab $ffmpeg_input_params \
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
alias afcast='CAST_VF="scale=$(halfscreenres):flags=neighbor" cast -s $(screenres) -i ${DISPLAY}+0,0 -f alsa $ffmpeg_input_params -i dsnooper'
alias lfcast='CAST_VF="scale=$(halfscreenres):flags=neighbor" cast -s $(screenres) -i ${DISPLAY}+0,0 -f alsa $ffmpeg_input_params -i loopout'
alias frcast='cast -s $(screenres) -i ${DISPLAY}+$(screencoords)'
alias frcast120='CAST_FPS=120 cast -s $(screenres) -i ${DISPLAY}+$(screencoords)'
alias afrcast='cast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa  $ffmpeg_input_params -i dsnooper '
alias lfrcast='cast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa  $ffmpeg_input_params -i loopout  '
alias afucast='ucast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa $ffmpeg_input_params -i dsnooper '
alias lfucast='ucast -s $(screenres) -i ${DISPLAY}+$(screencoords) -f alsa $ffmpeg_input_params -i loopout  '
alias fucast='ucast -s $(screenres) -i ${DISPLAY}+$(screencoords)'
alias scast='cast $(ffrectsel)'
alias scast120='CAST_FPS=120 cast $(ffrectsel)'
alias sucast='ucast $(ffrectsel)'
alias psc='pscircle --output-width=1920 --output-height=1080 --tree-font-size=10 --tree-radius-increment=170,100 --toplists-font-size=10 --background-color=000000 --dot-radius=3 --link-width=1.5 --dot-border-width=0 --link-color-min=333333 --link-color-max=666666 --dot-color-min=AF5500 --dot-color-max=FFCC00 --cpulist-center=700:0'

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

xls() {
  xbps-query -p install-date -s '' | awk '{ print $2,$3,$1 }' | sort
}

fbss() {
  dumpfile="$(autoname ~/pics/ss _fb.dump)"
  cp /dev/fb0 "$dumpfile" &&
  fbgrab -w 1920 -h 1080 -b 32 -f "$dumpfile" "$(autoname ~/pics/ss _fb.png)"
}

sget() {
  useragent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) QtWebEngine/5.11.3 Chrome/65.0.3325.230 Safari/537.36"
  wget --user-agent "$useragent" "$@"
}

[ "$(tty)" = "/dev/tty1" ] && [ "$(whoami)" = "loli" ] &&
  ! pgrep -x Xorg >/dev/null && exec startx

#command -v fish 2>&1 >/dev/null && exec fish
