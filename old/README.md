# EC2 Server Setup
This repository was created to quickly setup new CentOS Servers, specifically on Amazon EC2 infrastructure.

# Setup

First, login to the server. If you haven`t already, type `sudo su` to become the **root** user. This is required for
pretty much everything to work properly.

- After logging into the server, install git via `yum`:

```sh
yum install git
```

- Clone this repository:

```sh
git clone https://github.com/coreybutler/ec2-server.git
```

- Go into the new directory created for you.

```sh
cd ./ec2-server
```

- Make the code executable

```sh
chmod +x install
```

- Run the installer

```sh
./install
```

- Follow along until completion.

- Exit and Re-login

# Scripts & Aliases
This package includes some easy to use scripts and aliases

## Scripts

**makessl**

Used by simply typing `makessl` at the command prompt.

This will launch a wizard to create a self-signed SSL certificate.

## Aliases
There are several aliases available that act as shortcuts for the command line:

### bkp
`cd $BACKUP`

### soft
`cd $SOFTWARE`

### web
`cd /web/websites`

### rm**
`rm -i`

### cp
`cp -i`

### mv
`mv -i`

### mkdir
`mkdir -p`

### md
`mkdir -p`

### ..
`cd ..`

### ...
`cd ../../`

### nd
`sudo node`

### du
`du -kh`

### df
`df -kTh`

### ll
`ls -l --group-directories-first`

### ls 
_add colors for filetype recognition_

`ls -hF --color`

### la 
_show hidden files_

`ls -Al`

### lx 
_sort by extension_

`ls -lXB`

### lk 
_sort by size, biggest last_

`ls -lSr`

### lc 
_sort by and show change time, most recent last_

`ls -ltcr`

### lu 
_sort by and show access time, most recent last_

`ls -ltur`

### lt 
_sort by date, most recent last_

`ls -ltr`

### lm 
_pipe through 'more'_

`ls -al |more`

### lr 
_recursive ls_

`ls -lR`

### tree 
_nice alternative to 'recursive ls'_

`tree -Csu`

### home
`cd $home`

### dl
`cd $DOWNLOADS`

### flushdns
`/sbin/service nscd restart`

### scripts
`cd $SCRIPTS`

### ngc
`nano /opt/nginx/conf/nginx.conf`

### nodev
`NODE_ENV=dev node `

### nodep
`NODE_ENV=prod node `

### nodegrep
`ps -ef | grep node`

**ngrep
`ps -ef | grep node`

**k
`kill -9 `