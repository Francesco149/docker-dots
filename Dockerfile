FROM voidlinux/voidlinux
RUN xbps-install -Syu
RUN xbps-install -Sy vim gcc tmux git openssh bash glibc-locales wget \
  curl ncurses sudo make automake pkg-config libtool autoconf-archive \
  libressl-devel tzdata
RUN sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
  /etc/default/libc-locales && \
  xbps-reconfigure -f glibc-locales && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN echo 'TIMEZONE="Europe/Rome"' >> /etc/rc.conf
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
RUN xbps-install -Sy gtk+-devel
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
RUN ln -snvf "/usr/share/zoneinfo/Europe/Rome" /etc/localtime && \
  echo "Europe/Rome" > /etc/timezone
EXPOSE 22
CMD [ "/bin/bash", "-c", " \
  su loli - -c 'source ~/bashrc.sh && _tmuxinit'; \
  /usr/sbin/sshd -D" ]
