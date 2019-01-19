mkfontdir ~/.fonts
xset +fp ~/.fonts
xset +fp /usr/share/fonts/misc
xset fp rehash
xrdb ~/.Xresources
xset m 0 0
xset r rate 200 60
xset s off -dpms
xinput set-button-map "HUION 420 Pen Pen (0)" 1 0 0 0 0 0 0
rm -f ~/.local/share/chatterino/Misc/running_*
setxkbmap -option caps:swapescape
parcellite &
amixer set Speaker mute nocap
if xrandr | grep -q DVI-I-1; then
  xrandr --output DVI-I-1 --primary
fi
exec i3
