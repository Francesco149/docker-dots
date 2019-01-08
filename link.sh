#!/bin/sh

if [ -d /etc/bash/bashrc.d ]; then
  sudo ln -svi "$HOME/bashrc.sh" /etc/bash/bashrc.d/bashrc.sh
elif [ -f /etc/bash.bashrc ]; then
  sudo ln -svi "$HOME/bashrc.sh" /etc/bash.bashrc
else
  echo "cannot find a suitable location for bashrc, linking to ~/.bashrc"
  echo "you should add a proper system-wide link so it works for root"
  ln -svi bashrc.sh "$HOME/.bashrc"
fi

for d in /etc/fonts /etc/fontconfig; do
  if [ -d "$d" ]; then
    sudo ln -svi "$HOME/local.conf" "$d/local.conf"
    break
  fi
done

if [ ! -f "$d/local.conf" ]; then
  echo "cannot find a suitable location for fontconfig local.conf"
  echo "using ~/.local/fontconfig/local.conf"
  mkdir -p "$HOME/.local/fontconfig/"
  ln -svi ../../local.conf "$HOME/.local/fontconfig/local.conf"
fi

if [ -d /usr/lib/dhcpcd/dhcpcd-hooks ]; then
  sudo ln -svi "$HOME/dhcpcd-hooks.sh" \
    /usr/lib/dhcpcd/dhcpcd-hooks/9999-misc
else
  echo "could not find a suitable location for dhcpcd hooks"
  echo "please link manually"
fi

if [ -d /etc/acpi ]; then
  sudo ln -svi "$HOME/acpi.sh" /etc/acpi/handler.sh
fi

for d in /root /home/root; do
  if [ -d "$d" ]; then
    sudo ln -svi "$HOME/.vimrc" "$d/.vimrc"
    sudo ln -svi "$HOME/.tmux.conf" "$d/.tmux.conf"
    break
  fi
done

if [ ! -d "$d" ]; then
  echo "couldn't locate root home folder"
  echo "config files have not been linked for root"
fi
