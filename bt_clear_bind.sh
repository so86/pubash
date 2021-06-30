#/bin/bash
##宝塔去除账号绑定:(分别运行以下4句命令行, 针对7.6.0版本有效)
which perl
if [[ $? -ne 0 ]];then
  echo '准备安装Perl';
  yum install -q -y perl
fi;
if [[ ! -f "/www/server/panel/BTPanel/static/js/index.js" ]];then
  echo '/www/server/panel/BTPanel/static/js/index.js 文件不存在 无法执行任务'
  exit 1;
fi;
perl -pi -e 's|function show_force_bind\(\)\{|function show_force_bind\(\)\{\n    return;|g' /www/server/panel/BTPanel/static/js/index.js
if [[ $? -ne 0 ]];then
  echo '清除js弹窗绑定脚本时发生错误，请手工排查问题';
  exit 1
else
  echo '清除js弹窗绑定脚本 完成';
fi;
if [[ ! -f "/www/server/panel/BTPanel/__init__.py" ]];then
  echo '/www/server/panel/BTPanel/__init__.py 文件不存在 无法执行任务'
  exit 1;
fi;
perl -pi -e 's|return redirect\('\''\/bind'\'',302\)|pass;|g' /www/server/panel/BTPanel/__init__.py
if [[ $? -ne 0 ]];then
  echo '清除Py强制绑定用户的跳转代码时发生错误，请手工排查问题';
  exit 1
else
  echo '清除Py强制绑定用户的跳转代码 完成';
fi;
if [[ ! -f "/www/server/panel/class/common.py" ]];then
  echo '/www/server/panel/class/common.py 文件不存在 无法执行任务'
  exit 1;
fi;
perl -pi -e 's|return redirect\('\''https:\/\/www.baidu.com'\''\)|pass;|g' /www/server/panel/class/common.py
if [[ $? -ne 0 ]];then
  echo '清除蜘蛛UA跳转代码时发生错误，请手工排查问题';
  exit 1
else
  echo '清除蜘蛛UA跳转代码 完成';
fi;
echo '重启宝塔服务...'
bt 1
if [[ $? -ne 0 ]];then
  echo '宝塔服务重启过错中发送错误，请手工排查问题';
  exit 1
fi;
echo '清除宝塔用户绑定 任务已完成';
