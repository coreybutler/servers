#!/bin/bash
set -e

read -p "Username: " user

echo $user
echo "exiting"
exit


# export ME=$user

# # Update the system 
# yum update -y
# yum install -y nano
 
# # Add a non-root user
# groupadd admin
# useradd -a -G admin $ME
# mkdir /home/$ME/.ssh


###################################################
# CentOS initialization script for fresh installs #
###################################################

# Update with required software
# yum update -y
# yum install -y git wget make openssl openssl-devel

# # Create common directories
# if [ ! -d "/usr/src/SOFTWARE" ]; then
#   mkdir /usr/src/SOFTWARE
# fi
# if [ ! -d "/usr/src/SCRIPTS" ]; then
#   mkdir /usr/src/SCRIPTS
# fi
# if [ ! -d "/BACKUP" ]; then
#   mkdir /BACKUP
# fi

# # Modify the startup script, add aliases and exports
# cp /etc/bashrc /etc/bashrc.original
# echo "alias soft='cd /usr/src/SOFTWARE'" >> /etc/bashrc
# echo "alias ..='cd ../'" >> /etc/bashrc
# echo "alias ...='cd ../../'" >> /etc/bashrc
# echo "alias c='clear'" >> /etc/bashrc
# echo "alias home='cd $HOME'" >> /etc/bashrc
# echo "alias ssh='cd ~/.ssh'" >> /etc/bashrc
# echo "alias ls='ls --color=auto'" >> /etc/bashrc
# echo "alias grep='grep --color=auto'" >> /etc/bashrc
# echo "alias egrep='egrep --color=auto'" >> /etc/bashrc
# echo "alias fgrep='fgrep --color=auto'" >> /etc/bashrc
# echo "alias ports='netstat -tulanp'" >> /etc/bashrc
# echo "alias rm='rm -I --preserve-root'" >> /etc/bashrc
# echo "alias mv='mv -i'" >> /etc/bashrc
# echo "alias cp='cp -i'" >> /etc/bashrc
# echo "alias ln='ln -i'" >> /etc/bashrc
# echo "alias chown='chown --preserve-root'" >> /etc/bashrc
# echo "alias chmod='chmod --preserve-root'" >> /etc/bashrc
# echo "alias chgrp='chgrp --preserve-root'" >> /etc/bashrc
# echo "alias meminfo='free -m -l -t'" >> /etc/bashrc
# echo "alias psmem='ps auxf | sort -nr -k 4'" >> /etc/bashrc
# echo "alias psmem10='ps auxf | sort -nr -k 4 | head -10'" >> /etc/bashrc
# echo "alias pscpu='ps auxf | sort -nr -k 3'" >> /etc/bashrc
# echo "alias pscpu10='ps auxf | sort -nr -k 3 | head -10'" >> /etc/bashrc
# echo "alias cpuinfo='lscpu'" >> /etc/bashrc
# echo -e "export PATH=:/usr/local/bin:/usr/src/SCRIPTS:\$PATH" >> /etc/bashrc

# clear
source /etc/bashrc
#echo "You may need to re-login to use the new aliases."
