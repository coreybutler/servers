export ME=$1

# Update the system 
yum update -y
yum install -y nano
 
# Add a non-root user
groupadd admin
useradd -a -G admin $ME
mkdir /home/$ME/.ssh
