#!/bin/sh
# at the moment this is only used by my thinkpad x200

xsudo() {
  xuser=$(ps aux | awk '/xinit/ { print $1; exit }')
  display=$(ps -a -x -o '%c %a' |
    awk -F ':' '/[x]init/ { print $2 }' |
    awk '{ print $1 }')
  sudo -u "$xuser" env DISPLAY=":$display" "$@"
}

x11lock() {
  scr=$(xsudo mktemp -d)
  xsudo scrot "$scr/lock.png"
  xsudo convert "$scr/lock.png" -blur 10x10 "/tmp/blur_lock.png"
  rm -rf "$scr"
  xsudo i3lock -i "/tmp/blur_lock.png" -f
}

lock_and_sleep() {
  x11lock
  printf mem >/sys/power/state
}

lock_and_suspend() {
  x11lock
  printf disk >/sys/power/state
}

case "$1" in
  button/prog1)
    logger 'ThinkVantage pressed'
    lock_and_suspend
    ;;
  button/sleep)
    case "$2" in
      SLPB|SBTN)
        logger 'SleepButton pressed'
        lock_and_sleep
        ;;
      *)
        logger "ACPI action undefined: $2"
        ;;
    esac
    ;;
  ac_adapter)
    case "$2" in
      AC|ACAD|ADP0)
        case "$4" in
          00000000)
            logger 'AC unpluged'
            ;;
          00000001)
            logger 'AC plugged'
            ;;
        esac
        ;;
      *)
        logger "ACPI action undefined: $2"
        ;;
    esac
    ;;
  battery)
    case "$2" in
      BAT0)
        case "$4" in
          00000000)
            logger 'Battery online'
            ;;
          00000001)
            logger 'Battery offline'
            ;;
        esac
        ;;
      CPU0)
        ;;
      *)  logger "ACPI action undefined: $2" ;;
    esac
    ;;
  button/lid)
    case "$3" in
      close)
        logger 'LID closed'
        lock_and_sleep
        ;;
      open)
        logger 'LID opened'
        /sys/power/resume
        ;;
      *)
        logger "ACPI action undefined: $3"
        ;;
  esac
  ;;
  button/screenlock)
    logger 'Screen locked'
    x11lock
    ;;
  *)
    logger "ACPI group/action undefined: $1 / $2"
    ;;
esac
