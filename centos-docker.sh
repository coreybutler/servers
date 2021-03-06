#!/bin/bash

# Identify a secure SSH port
printf "Which port should SSH run on (Default is 22)? "
read SSHPORT < /dev/tty
printf "Allow root login (y/n)? "
read ROOTLOGIN < /dev/tty
printf "Papertrail URL (optional): "
read PAPERTRAIL < /dev/tty

# Create a non-root user
printf "Enter Username: "
read ME < /dev/tty
printf "Enter Password for $ME: "
read -s PWD < /dev/tty
clear
printf "id_rsa.pub contents for $ME: "
read RSA < /dev/tty
clear

if [[ "$SSHPORT" = "" ]]
then
  SSHPORT = "22"
fi

echo "SSH Port: $SSHPORT"
echo "Permit root login: $ROOTLOGIN"
echo "New User: $ME"

size=$((${#PWD}-2))
mask="${PWD:0:1}"
for (( c=1; c<=$size; c++ ))
do
  mask="$mask*"
done
mask="$mask${PWD: -1}"

echo "Password: $mask ($((${#PWD})) characters)"
if [[ "$RSA" != "" ]]
then
  echo "ID RSA: $RSA"
else
  echo "Password login only (no SSH key for $ME)."
fi
if [[ "$PAPERTRAIL" != "" ]]
then
  echo "Papertrail: $PAPERTRAIL"
fi
echo "----------------------"

while true; do
  echo "Is this correct [y/n]?"
  read yn < /dev/tty
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer (y)es or (n)o.";;
  esac
done

# Create a rollback script
if [ -f "./rollback" ]
then
  rm -rf ./rollback
fi
touch ./rollback
chmod +x ./rollback

# Create admin group and non-root user
groupadd admin
useradd -G admin $ME
echo "Using $PWD"
echo -e "$PWD\n$PWD" | passwd $ME
mkdir -p /home/$ME/.ssh

echo "groupdel admin" >> ./rollback
echo "userdel $ME" >> ./rollback
echo "rm -rf /home/$ME" >> ./rollback

# Setup SSH security
if [[ "$RSA" != "" ]]
then
  echo $RSA > /home/$ME/.ssh/authorized_keys
  chown -R $ME:$ME /home/$ME/.ssh
  chmod 700 /home/$ME/.ssh
  chmod 600 /home/$ME/.ssh/authorized_keys
  echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
else
  echo "No SSH keys associated with $ME account (login via password only)."
fi

cp /etc/ssh/sshd_confg /etc/ssh/sshd_config.original
echo "mv /etc/ssh/sshd_confg.original /etc/ssh/sshd_config" >> ./rollback

if [[ "$SSHPORT" != "22" ]]
then
  echo "Port $SSHPORT" >> /etc/ssh/sshd_config
fi

if [[ "$ROOTLOGIN" = "n" ]]
then
  echo "PermitRootLogin no" >> /etc/ssh/sshd_config
else
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi

# Setup Sudoers File
cp /etc/sudoers /etc/sudoers.original
echo "mv /etc/sudoers.original /etc/sudoers" >> ./rollback
echo "%admin  ALL=(ALL)       ALL" >> /etc/sudoers

# Setup Firewall
systemctl start firewalld
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --remove-port=22/tcp
firewall-cmd --permanent --add-port=$SSHPORT/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl restart firewalld

echo "firewall-cmd --permanent --remove-port=$SSHPORT/tcp" >> ./rollback
echo "firewall-cmd --permanent --add-port=22/tcp" >> ./rollback
echo "firewall-cmd --permanent --add-service=http" >> ./rollback
echo "firewall-cmd --permanent --add-service=https" >> ./rollback
echo "systemctl restart firewalld" >> ./rollback


# Setup Papertrail
if [[ "$PAPERTRAIL" != "" ]]
then
  curl https://papertrailapp.com/tools/papertrail-bundle.pem > /etc/papertrail-bundle.pem
  echo "rm -rf /etc/papertrail-bundle.pem" >> ./rollback
  cp /etc/rsyslog.conf /etc/rsyslog.conf.original
  echo "mv /etc/rsyslog.conf.original /etc/rsyslog.conf"
  echo "# Provides UDP syslog reception" >> /etc/rsyslog.conf
  echo "\$ModLoad imudp" >> /etc/rsyslog.conf
  echo "\$UDPServerRun 514" >> /etc/rsyslog.conf
  echo "" >> /etc/rsyslog.conf
  echo "# Provides TCP syslog reception" >> /etc/rsyslog.conf
  echo "\$ModLoad imtcp" >> /etc/rsyslog.conf
  echo "\$InputTCPServerRun 514" >> /etc/rsyslog.conf
  echo "" >> /etc/rsyslog.conf
  echo "\$PreserveFQDN on" >> /etc/rsyslog.conf
  echo "" >> /etc/rsyslog.conf
  echo "\$DefaultNetstreamDriverCAFile /etc/papertrail-bundle.pem # trust these CAs" >> /etc/rsyslog.conf
  echo "\$ActionSendStreamDriver gtls # use gtls netstream driver" >> /etc/rsyslog.conf
  echo "\$ActionSendStreamDriverMode 1 # require TLS" >> /etc/rsyslog.conf
  echo "\$ActionSendStreamDriverAuthMode x509/name # authenticate by hostname" >> /etc/rsyslog.conf
  echo "\$ActionSendStreamDriverPermittedPeer *.papertrailapp.com" >> /etc/rsyslog.conf
  echo "" >> /etc/rsyslog.conf 
  echo "\$ActionResumeInterval 10" >> /etc/rsyslog.conf
  echo "\$ActionQueueSize 100000" >> /etc/rsyslog.conf
  echo "\$ActionQueueDiscardMark 97500" >> /etc/rsyslog.conf
  echo "\$ActionQueueHighWaterMark 80000" >> /etc/rsyslog.conf
  echo "\$ActionQueueType LinkedList" >> /etc/rsyslog.conf
  echo "\$ActionQueueFileName papertrailqueue" >> /etc/rsyslog.conf
  echo "\$ActionQueueCheckpointInterval 100" >> /etc/rsyslog.conf
  echo "\$ActionQueueMaxDiskSpace 2g" >> /etc/rsyslog.conf
  echo "\$ActionResumeRetryCount -1" >> /etc/rsyslog.conf
  echo "\$ActionQueueSaveOnShutdown on" >> /etc/rsyslog.conf
  echo "\$ActionQueueTimeoutEnqueue 10" >> /etc/rsyslog.conf
  echo "\$ActionQueueDiscardSeverity 0" >> /etc/rsyslog.conf
  echo "" >> /etc/rsyslog.conf
  echo "*.*          @@$PAPERTRAIL" >> /etc/rsyslog.conf
fi

# Update the system
yum update --skip-broken -y
yum install -y epel-release
yum install -y nano git wget make openssl openssl-devel fail2ban

echo "yum remove -y epel-release nano git wget make openssl openssl-devel fail2ban" >> ./rollback

# Install Docker
rm -rf /etc/yum.repos.d/docker.repo
cat > /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
yum install docker-engine
systemctl enable docker
systemctl start docker
usermod -aG docker $ME

echo "rm -rf /etc/yum.repos.d/docker.repo" >> ./rollback

# Initialize everything else

###################################################
# CentOS initialization script for fresh installs #
###################################################

# Create common directories
if [ ! -d "/usr/src/SOFTWARE" ]; then
  mkdir /usr/src/SOFTWARE
  echo "rm -rf /usr/src/SOFTWARE" >> ./rollback
fi
if [ ! -d "/usr/src/SCRIPTS" ]; then
  mkdir /usr/src/SCRIPTS
  echo "rm -rf /usr/src/SCRIPTS" >> ./rollback
fi
if [ ! -d "/BACKUP" ]; then
  mkdir /BACKUP
  echo "rm -rf /BACKUP" >> ./rollback
fi

# Modify the startup script, add aliases and exports
cp /etc/bashrc /etc/bashrc.original
echo "mv /etc/bashrc.original /etc/bashrc" >> ./rollback
echo "alias soft='cd /usr/src/SOFTWARE'" >> /etc/bashrc
echo "alias ..='cd ../'" >> /etc/bashrc
echo "alias ...='cd ../../'" >> /etc/bashrc
echo "alias c='clear'" >> /etc/bashrc
echo "alias home='cd $HOME'" >> /etc/bashrc
echo "alias ssh='cd ~/.ssh'" >> /etc/bashrc
echo "alias ls='ls --color=auto'" >> /etc/bashrc
echo "alias grep='grep --color=auto'" >> /etc/bashrc
echo "alias egrep='egrep --color=auto'" >> /etc/bashrc
echo "alias fgrep='fgrep --color=auto'" >> /etc/bashrc
echo "alias ports='netstat -tulanp'" >> /etc/bashrc
echo "alias rm='rm -I --preserve-root'" >> /etc/bashrc
echo "alias mv='mv -i'" >> /etc/bashrc
echo "alias cp='cp -i'" >> /etc/bashrc
echo "alias ln='ln -i'" >> /etc/bashrc
echo "alias chown='chown --preserve-root'" >> /etc/bashrc
echo "alias chmod='chmod --preserve-root'" >> /etc/bashrc
echo "alias chgrp='chgrp --preserve-root'" >> /etc/bashrc
echo "alias meminfo='free -m -l -t'" >> /etc/bashrc
echo "alias psmem='ps auxf | sort -nr -k 4'" >> /etc/bashrc
echo "alias psmem10='ps auxf | sort -nr -k 4 | head -10'" >> /etc/bashrc
echo "alias pscpu='ps auxf | sort -nr -k 3'" >> /etc/bashrc
echo "alias pscpu10='ps auxf | sort -nr -k 3 | head -10'" >> /etc/bashrc
echo "alias cpuinfo='lscpu'" >> /etc/bashrc
echo -e "export PATH=:/usr/local/bin:/usr/src/SCRIPTS:\$PATH" >> /etc/bashrc

clear
source /etc/bashrc
echo "source /etc/bashrc" >> ./rollback

# Complete
echo "All done. You may need to re-login to use the new aliases."

IP=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
str="ssh $ME@$IP"

if [[ "$SSHPORT" != "22" ]]
then
  echo "REMEMBER SSH is running on port $SSHPORT! Update firewalls accordingly."
  str="$str -p $SSHPORT"
fi

if [[ "$RSA" != "" ]]
then
  echo "REMEMBER that users must have an SSH key to login!"
  str="$str -i \"/path/to/.ssh/id_rsa\""
fi

if [[ "$ROOTLOGIN" != "n" ]]
then
  echo "REMEMBER you cannot login as root!"
fi

echo "clear" >> ./rollback
echo "Rollback complete." >> ./rollback
echo "You will be able to login vis SSH (as root and/or original user) on port 22:" >> ./rollback
echo "" >> ./rollback
str2="ssh root@$IP -p 22"

if [ -f "/root/.ssh/authorized_keys" ] then
  str2="$str2 -i \"/path/to/id_rsa\""
fi

echo "You should be able to connect with the following command:"
echo "$str2"

echo "--------------------------------------------------------------------------------"
echo "$str -v"
