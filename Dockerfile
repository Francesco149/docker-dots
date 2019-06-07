FROM voidlinux/voidlinux

RUN xbps-install -Syu && \
  xbps-install -Sy vim-x11 gcc tmux git openssh bash glibc-locales wget \
  curl ncurses sudo make automake pkg-config libtool autoconf-archive \
  libressl-devel tzdata xz

RUN xbps-install -Sy void-repo-multilib && \
  xbps-install -Sy && \
  xbps-install -Sy gcc-multilib

RUN xbps-install -Sy go nodejs python python-pip python3-pip ruby \
  kotlin-bin avr-gcc avr-binutils avr-libc swig cmake android-tools \
  meson autoconf213 cross-i686-w64-mingw32 cross-x86_64-w64-mingw32

RUN xbps-install -Sy \
  gtk+-devel gtk+-devel-32bit boost-devel protobuf glfw-devel \
  python3-devel python-wheel libxkbcommon-devel SDL-devel \
  SDL2-devel mysql++-devel lua-devel crypto++-devel vte-devel vte3-devel \
  python3-M2Crypto python-M2Crypto python-devel imlib2-devel \
  libunwind-devel gstreamer1-devel gst-plugins-base1-devel \
  gst-plugins-bad1-devel

RUN xbps-install -Sy \
  shellcheck neofetch valgrind man man-pages-posix cvs \
  bdftopcf ffmpeg xtools busybox xclip xauth cloc megatools \
  rxvt-unicode-terminfo apache-maven gnupg2 p7zip \
  hangups gopass neomutt msmtp isync clang llvm notmuch pass

RUN pip install awscli streamlink youtube_dl
RUN gem install gist

ENV android_sdk_sha256="92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9"
ENV android_sdk_file="sdk-tools-linux-4333796.zip"
ENV android_sdk_url="https://dl.google.com/android/repository/$android_sdk_file"
RUN wget "$android_sdk_url"
RUN echo "$android_sdk_sha256  $android_sdk_file" | sha256sum -c
RUN 7z x "$android_sdk_file" && rm -f "$android_sdk_file"
ENV android_sdk_root=/opt/android-sdk
RUN mkdir -p $android_sdk_root && mv tools $android_sdk_root/
RUN chmod +x $android_sdk_root/tools/bin/*
RUN yes | $android_sdk_root/tools/bin/sdkmanager \
  'platforms;android-28' 'build-tools;28.0.3' platform-tools

RUN rm -rf /usr/lib/python2.7/site-packages/pycparser && \
  xbps-install -Sy xpra procps-ng && mkdir -p /run/user/1000/xpra && \
  chown -R 1000:1000 /run/user/1000

RUN echo 'en_US.UTF-8 UTF-8' >> /etc/default/libc-locales && \
  echo 'en_US ISO-8859-1' >> /etc/default/libc-locales && \
  xbps-reconfigure -f glibc-locales && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
ENV TIMEZONE="Europe/Rome"
RUN echo "TIMEZONE=\"$TIMEZONE\"" >> /etc/rc.conf && \
  ln -snvf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime && \
  echo "$TIMEZONE" > /etc/timezone

RUN useradd -s /bin/bash -d /home/loli loli
RUN passwd -d root
RUN echo "loli ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN ln -sv /home/loli/bashrc.sh /etc/bash/bashrc.d/
RUN bash -c "\
  ln -sv /home/loli/hostkeys/ssh_host_{dsa,ecdsa,ed25519,rsa}_key{,.pub} \
  /etc/ssh/"
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN echo "X11Forwarding yes" >> /etc/ssh/sshd_config && \
  echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config && \
  echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

EXPOSE 22
CMD [ "/bin/bash", "-c", " \
  su loli - -c 'source ~/bashrc.sh && _tmuxinit'; \
  /usr/sbin/sshd -D" ]
