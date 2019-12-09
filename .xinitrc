source ~/bashrc.sh

# TODO: move these to services/hooks
sudo ip link set eno1 master br0
sudo ntpd -dnqp 0.it.pool.ntp.org &
sudo killall stupidlayers
for x in /dev/input/event*; do
  devname=$(cat $(echo $x | sed 's|dev|sys/class|g')/device/name)
  if [ "$devname" = "SONiX USB DEVICE" ]; then
    sudo stupidlayers $x &
    break
  fi
done

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
cp ~/bak/chatterino.json  .local/share/chatterino/Settings/settings.json
setxkbmap -option caps:swapescape
parcellite &
amixer set Speaker mute nocap
if xrandr | grep -q DVI-I-0; then
  xrandr --output DVI-I-0 --primary
fi
fcitx-autostart &
dunst &
exec i3
