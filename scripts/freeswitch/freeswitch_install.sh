#!/bin/bash
#
# FreeSWITCH Installation script for CentOS 5.x/6.x and Debian based distros 
# (Debian 6.x , Ubuntu 10.04 and above)
#
# This script gears toward configuration files which are going to be used with vBilling
#
# Copyright (c) 2011 Digital Linx. See LICENSE for details.

# Define some variables

#####################################################
FS_GIT_REPO=git://git.freeswitch.org/freeswitch.git
FS_CONF_PATH_FSXML=https://raw.github.com/nbhatti/vBilling/master/scripts/freeswitch/freeswitch.xml
FS_CONF_PATH_MODULE=https://raw.github.com/nbhatti/vBilling/master/scripts/freeswitch/modules.conf
FS_INSTALLED_PATH=/usr/local/freeswitch
FS_BASE_PATH=/usr/src/
CURRENT_PATH=$PWD
#####################################################

# Identify Linux Distribution
if [ -f /etc/debian_version ] ; then
    DIST="DEBIAN"
elif [ -f /etc/redhat-release ] ; then
    DIST="CENTOS"
else
    echo ""
    echo "This Installer should be run on a CentOS or a Debian based system"
    echo ""
    exit 1
fi

clear
echo ""
echo "FreeSWITCH will be installed in $FS_INSTALLED_PATH"
echo "Press any key to continue or CTRL-C to exit"
echo ""
read INPUT

echo "Setting up Prerequisites and Dependencies for FreeSWITCH"
case $DIST in
    'DEBIAN')
        apt-get -y update
        apt-get -y install autoconf automake autotools-dev binutils bison build-essential cpp curl flex g++ gcc git-core libaudiofile-dev libc6-dev libdb-dev libexpat1 libgdbm-dev libgnutls-dev libmcrypt-dev libncurses5-dev libnewt-dev libpcre3 libpopt-dev libsctp-dev libsqlite3-dev libtiff4 libtiff4-dev libtool libx11-dev libxml2 libxml2-dev lksctp-tools lynx m4 make mcrypt ncftp nmap openssl sox sqlite3 ssl-cert ssl-cert unixodbc-dev unzip zip zlib1g-dev zlib1g-dev
        ;;
    'CENTOS')
        yum -y update
        yum -y install autoconf automake bzip2 cpio curl curl-devel curl-devel expat-devel fileutils gcc-c++ gettext-devel gnutls-devel libjpeg-devel libogg-devel libtiff-devel libtool libvorbis-devel make ncurses-devel nmap openssl openssl-devel openssl-devel perl patch unixODBC unixODBC-devel unzip wget zip zlib zlib-devel

        #install the RPMFORGE Repository
        if [ ! -f /etc/yum.repos.d/rpmforge.repo ];
            then
                # Install RPMFORGE Repo
        rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
        echo '
[rpmforge]
name = Red Hat Enterprise $releasever - RPMforge.net - dag
mirrorlist = http://apt.sw.be/redhat/el5/en/mirrors-rpmforge
enabled = 0
protect = 0
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
gpgcheck = 1
' > /etc/yum.repos.d/rpmforge.repo
        fi

        yum -y --enablerepo=rpmforge install git-core
    ;;
esac

# Install FreeSWITCH
cd $FS_BASE_PATH
git clone $FS_GIT_REPO
cd $FS_BASE_PATH/freeswitch
sh bootstrap.sh && ./configure

# We will download module.conf file customized for API
wget --no-check-certificate $FS_CONF_PATH_MODULE

# Good to go, let's now compile FreeSWITCH
make && make install

# Enable FreeSWITCH modules
cd $FS_INSTALLED_PATH

# We do not want any of the configs. Let's create our own
rm -rf conf

# Instead download the files
wget --no-check-certificate FS_CONF_PATH_FSXML

cd $CURRENT_PATH

# Install Complete
echo ""
echo ""
echo ""
echo "**************************************************************"
echo "Congratulations, FreeSWITCH is now installed at '$FS_INSTALLED_PATH'"
echo "**************************************************************"
echo
echo "* To Start FreeSWITCH in foreground :"
echo "    '$FS_INSTALLED_PATH/bin/freeswitch'"
echo
echo "* To Start FreeSWITCH in background :"
echo "    '$FS_INSTALLED_PATH/bin/freeswitch -nc'"
echo
echo "**************************************************************"
echo ""
echo ""
exit 0
