#!/bin/bash
#author:yuzhuofan
#time:2022.12.21
#descriptin:OpenSSH升级脚本

#下载OpenSSL
wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1s.tar.gz
#解压
tar -zxvf openssl-1.1.1s.tar.gz
#进入openssl目录
cd openssl-1.1.1s/

yum install -y gcc gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel  pam-devel cpan
yum install -y pam* zlib* perl*

#编译安装
./config --prefix=/usr/local --openssldir=/usr/local/openssl && make && make install
#再次安装
./config shared && make && make install
#检查编译安装结果，如果输出为0，则代表安装成功
echo $?

#安装成功，查看openssl版本
openssl version

#下载openssh
wget --no-check-certificate https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/openssh-9.0p1.tar.gz
#解压
tar -zxvf openssh-9.0p1.tar.gz
#进入openssh目录
cd openssh-9.0p1/
#编译文件
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords --with-pam  --with-ssl-dir=/usr/local/openssl --with-zlib=/usr/local/lib64 --without-hardening
#检查输出结果，正确则返回0
echo $?
#安装
make
echo $?
chmod 600 /etc/ssh/ssh_host*
make install
echo $?
#配置ssh并启动
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
grep "^PermitRootLogin"  /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
grep  "UseDNS"  /etc/ssh/sshd_config
cp -a contrib/redhat/sshd.init /etc/init.d/sshd
cp -a contrib/redhat/sshd.pam /etc/pam.d/sshd.pam
chmod +x /etc/init.d/sshd
chkconfig --add sshd
systemctl enable sshd
chkconfig sshd on
#移走原先服务，有报错可以无视
mv /usr/lib/systemd/system/sshd.service  /home/
#重启sshd
/etc/init.d/sshd restart
#查看是否正常开放
netstat -antpl
#查看版本
ssh -V