FROM voidlinux/voidlinux
RUN xbps-install -Syu
RUN xbps-install -Sy vim gcc tmux git openssh bash glibc-locales wget \
  curl ncurses sudo make automake pkg-config libtool autoconf-archive \
  libressl-devel tzdata xz
RUN xbps-install -Sy void-repo-multilib && \
  xbps-install -Sy && \
  xbps-install -Sy gcc-multilib
RUN sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
  /etc/default/libc-locales && \
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
RUN xbps-install -Sy go
RUN xbps-install -Sy nodejs
RUN xbps-install -Sy gtk+-devel gtk+-devel-32bit
RUN xbps-install -Sy avr-gcc avr-binutils avr-libc
RUN xbps-install -Sy python python-pip
RUN pip install awscli
RUN xbps-install -Sy boost-devel
RUN xbps-install -Sy protobuf
RUN xbps-install -Sy android-tools
RUN xbps-install -Sy kotlin-bin
RUN xbps-install -Sy p7zip
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
RUN xbps-install -Sy shellcheck
RUN xbps-install -Sy neofetch
RUN xbps-install -Sy valgrind
RUN xbps-install -Sy man man-pages-posix
RUN xbps-install -Sy cvs
RUN xbps-install -Sy ruby && gem install gist
RUN xbps-install -Sy bdftopcf
RUN xbps-install -Sy ffmpeg
RUN pip install streamlink youtube_dl
RUN xbps-install -Sy xtools
RUN xbps-install -Sy busybox
RUN echo "X11Forwarding yes" >> /etc/ssh/sshd_config
RUN xbps-install -Sy xclip
RUN xbps-install -Sy xauth
RUN echo "X11DisplayOffset 10" >> /etc/ssh/sshd_config
RUN echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
RUN xbps-remove -Ry vim
RUN xbps-install -Sy vim-x11
RUN xbps-install -Sy cloc
RUN xbps-install -Sy imlib2-devel
EXPOSE 22
CMD [ "/bin/bash", "-c", " \
  su loli - -c 'source ~/bashrc.sh && _tmuxinit'; \
  /usr/sbin/sshd -D" ]
