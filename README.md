note: this repository also doubles as my dotfiles for client machines,
which means it includes configs for graphical stuff that aren't used
by the docker container itself

I've been experimenting with using a Dockerfile as a whole system
config for a headless environment that I ssh into for daily non-graphical
workflow like coding, building and deploying stuff, managing files,
transcoding videos, basically anything that I do from the terminal

note that this setup is not meant to be safe from malware or attackers
that managed to get into the container. its purpose is simply to avoid
polluting the host system with software I install and containing any
mistakes I might make so it's much harder to accidentally break the host

I made it so you can modify the Dockerfile and the startup script from
within the container and rebuild and reboot it by killing sshd as root

you might ask, why not simply persist most of the rootfs and mount it to a
container? well, I like keeping my system clean and often times when
experimenting with new software I make a mess, or slowly pile up garbage.
using a Dockerfile as my whole system config ensures that I can always go
back to a clean state as the only thing I'm persisting at the moment
is my home and a few files I symlink to rootfs

so far it's quite neat, so these are my dotfiles for my current setup

# usage
if you're not me you'll want to customize the software installed in
the Dockerfile, replace my username with yours (must match the host
machine) and edit the mounts and devices in ```once.sh```

also, ```once.sh``` binds ssh to port 22 but you most likely already have
ssh running on this port on your host machines so either change your
host ssh port or edit the port there to, for example,
```--publish 2222:22``` for 2222

now you can either start ```./run.sh``` in a screen or tmux session or
create a service that runs ```once.sh``` as your user and restarts it when
it dies, for example on systemd it would be:

```
[Unit]
Description=(docker) memevault

[Service]
Type=simple
ExecStart=/home/loli/memevault/once.sh
ExecStop=/usr/bin/docker rm -f memevault
Restart=always
User=loli
Group=loli

[Install]
WantedBy=multi-user.target
```

which you would put in ```/etc/systemd/system/memevault.service``` ,
enable with ```systemctl enable memevault``` and start with
```systemctl start memevault```

once the container is up and running, you can ssh into it on the port you
specified in ```once.sh```

you can deploy this on a headless server and remotely ssh into it. this
is especially good when you have a rock stable system like centOS and want
to work or play with cutting edge software on the same machine without
polluting the host environment or spinning up a virtual machine

# editing and rebuilding the container from within itself
* edit ~/Dockerfile and add your install commands at the bottom before
  ```EXPOSE 22``` to maximize rebuild speed (previous layers won't need
  to be rebuilt)
* test your commands in the shell to make sure they won't fail, otherwise
  the container will not come up and you'll have to ssh into the host
  to fix the error
* ```sudo killall sshd```
* wait for the ssh to come back up with your changes applied. this should
  not take much longer than the execution time of the commands you added

you can apply the same procedure with once.sh, but you need to be extra
careful here because this script is executed by the host, so you could
potentially pollute your home folder on the host if you make mistakes
