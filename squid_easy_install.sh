#!/bin/bash
##控制台字体颜色
cblack_start="\033[30m"
cred_start="\033[31m"
cgreen_start="\033[32m"
cyellow_start="\033[33m"
cblue_start="\033[34m"
cpurple_start="\033[35m"
cbluesky_start="\033[36m"
cwhite_start="\033[37m"
##控制台字体颜色(带背景色)
cb_white_bgblack_start="\033[40;37m"
cb_black_bgwhite_start="\033[41;30m"
cb_blue_bggreen_start="\033[42;34m"
cb_blue_bgyellow_start="\033[43;34m"
cb_black_bgblue="\033[44;30m"
cb_black_bgpurple_start="\033[45;30m"
cb_black_bgbluesky_start="\033[46;30m"
cb_blue_bgwhite_start="\033[47;34m"
##控制台字体样式结束符
color_end="\033[0m"

if [ $# -lt 2 ]; then
    echo '缺少参数';
    echo "sh squid_easy_install.sh <user> <password>";
    exit -1;
fi;
default_user=$1
default_passwd=$2

echo '开始自动化部署Squid代理服务'
sleep 3;
echo '安装相关软件包...';
sleep 3
yum install -y vim curl httpd.x86_64 squid
if [[ $? -ne 0 ]];then
    echo '安装软件包过程中发生错误, 请排查';
    exit 1;
fi;
if [[ ! -f '/etc/squid/squid.conf' ]];then
    echo 'squid服务配置文件不存在, 请检查'
    exit 1
fi;
if [[ ! -f '/usr/bin/htpasswd' ]];then
    echo 'htpasswd可执行文件不存在,无法配置squid用户验证, 请检查'
    exit 1
fi;
echo '重新配置squid配置文件...'
sleep 1;
echo "#reconfigure by squid_easy_install.sh">/etc/squid/squid.conf
echo "acl localnet src 10.0.0.0/8" >>/etc/squid/squid.conf
echo "acl localnet src 172.16.0.0/12" >>/etc/squid/squid.conf
echo "acl localnet src 192.168.0.0/16" >>/etc/squid/squid.conf
echo "acl localnet src fc00::/7" >>/etc/squid/squid.conf
echo "acl localnet src fe80::/10" >>/etc/squid/squid.conf
echo "acl SSL_ports port 443" >>/etc/squid/squid.conf
echo "acl Safe_ports port 80" >>/etc/squid/squid.conf
echo "acl Safe_ports port 21" >>/etc/squid/squid.conf
echo "acl Safe_ports port 443" >>/etc/squid/squid.conf
echo "acl Safe_ports port 70" >>/etc/squid/squid.conf
echo "acl Safe_ports port 210" >>/etc/squid/squid.conf
echo "acl Safe_ports port 1025-65535" >>/etc/squid/squid.conf
echo "acl Safe_ports port 280" >>/etc/squid/squid.conf
echo "acl Safe_ports port 488" >>/etc/squid/squid.conf
echo "acl Safe_ports port 591" >>/etc/squid/squid.conf
echo "acl Safe_ports port 777" >>/etc/squid/squid.conf
echo "acl CONNECT method CONNECT" >>/etc/squid/squid.conf
echo "client_db on" >>/etc/squid/squid.conf
echo "acl allowmax maxconn 60" >>/etc/squid/squid.conf
echo "http_access deny allowmax" >>/etc/squid/squid.conf
echo "http_access deny !Safe_ports" >>/etc/squid/squid.conf
echo "http_access deny CONNECT !SSL_ports" >>/etc/squid/squid.conf
echo "http_access allow localhost manager" >>/etc/squid/squid.conf
echo "http_access deny manager" >>/etc/squid/squid.conf
echo "#use follow command to create login user" >>/etc/squid/squid.conf
echo "#/usr/bin/htpasswd -c /etc/squid/passwd [username]" >>/etc/squid/squid.conf
echo "auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd" >>/etc/squid/squid.conf
echo "auth_param basic children 100" >>/etc/squid/squid.conf
echo "auth_param basic casesensitive off" >>/etc/squid/squid.conf
echo "auth_param basic realm DeMaXiYa" >>/etc/squid/squid.conf
echo "auth_param basic credentialsttl 1 hours" >>/etc/squid/squid.conf
echo "acl auth_user proxy_auth REQUIRED" >>/etc/squid/squid.conf
echo "http_access allow auth_user" >>/etc/squid/squid.conf
echo "http_access allow localnet" >>/etc/squid/squid.conf
echo "http_access allow localhost" >>/etc/squid/squid.conf
echo "http_access deny all" >>/etc/squid/squid.conf
echo "http_port 3128" >>/etc/squid/squid.conf
echo "coredump_dir /var/spool/squid" >>/etc/squid/squid.conf
echo "refresh_pattern ^ftp:       1440    20% 10080" >>/etc/squid/squid.conf
echo "refresh_pattern ^gopher:    1440    0%  1440" >>/etc/squid/squid.conf
echo "refresh_pattern -i (/cgi-bin/|\?) 0 0%  0" >>/etc/squid/squid.conf
echo "refresh_pattern .       0   20% 4320" >>/etc/squid/squid.conf
echo "request_header_access Via deny all">>/etc/squid/squid.conf
echo "request_header_access X-Forwarded-For deny all">>/etc/squid/squid.conf
echo "request_header_access From deny all">>/etc/squid/squid.conf

touch /etc/squid/passwd
echo "设置squid用户:${default_user} 密码";
/usr/bin/htpasswd -b -c /etc/squid/passwd $default_user $default_passwd
if [[ $? -ne 0 ]];then
    echo "设置squid用户:${default_user} 密码时发生错误";
    exit 1;
fi;
echo '验证配置文件...'
squid -k parse
if [[ $? -ne 0 ]];then
    echo 'squid配置文件验证失败,请检查'
    exit 1
fi;
systemctl enable squid
if [[ $? -ne 0 ]];then
    echo '设置squid服务自启动时发生错误,请检查'
    exit 1
fi;
echo '设置squid服务自启动完成'
systemctl start squid
if [[ $? -ne 0 ]];then
    echo 'squid服务启动时发生错误,请检查'
    exit 1
fi;
echo 'squid服务已启动'
ipaddr=`curl ifconfig.me`;
if [[ $? -ne 0 ]];then
    ipaddr='服务器IP地址'
fi;
echo ""
printf "代理服务地址: ${cred_start}${default_user}:${default_passwd}@${ipaddr}:3128${color_end}\n"
echo ""
echo "注意:如果代理服务无法正常访问,请检查防火墙是否放行代理端口:"
echo "放行特定端口参考如下命令:(仅适用于Centos7和8)"
echo "echo '列出已放行的端口'&&firewall-cmd --zone=public --list-ports"
echo "echo '开放3218端口'&&firewall-cmd --zone=public --add-port=3128/tcp --permanent"
echo "echo '使配置生效'&&firewall-cmd --reload"
