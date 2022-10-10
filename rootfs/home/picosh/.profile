# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
echo "Running post-install..." && sudo /home/picosh/post-install/run.sh 2>&1 | sudo tee /var/log/post-install.log >/dev/null 2>&1

# FIXME: Figure out how to run X as a non-root user (see https://wiki.gentoo.org/wiki/Xorg/Guide#Using_startx and https://wiki.gentoo.org/wiki/X_without_Display_Manager)
if [ "$(tty)" = "/dev/tty1" ]; then
    sudo startx ~/.xinitrc default -- -nocursor 2>&1 | sudo tee /var/log/startx.log >/dev/null 2>&1
fi
