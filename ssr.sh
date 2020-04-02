#!/usr/bin/env bash
#付费维护脚本，请勿破解修改                                                                                             
#===================================================================#
#   System Required:  CentOS 7                                      #
#   Description: Install sspanel for CentOS7                        #
#   Author: Azure <2894049053@qq.com>  TG:@Latte_Coffe                             #
#   github: @baiyutribe <https://github.com/baiyuetribe>            #
#   Blog:  佰阅部落 https://baiyue.one                               #
#===================================================================#
#
#  .______        ___       __  ____    ____  __    __   _______      ______   .__   __.  _______ 
#  |   _  \      /   \     |  | \   \  /   / |  |  |  | |   ____|    /  __  \  |  \ |  | |   ____|
#  |  |_)  |    /  ^  \    |  |  \   \/   /  |  |  |  | |  |__      |  |  |  | |   \|  | |  |__   
#  |   _  <    /  /_\  \   |  |   \_    _/   |  |  |  | |   __|     |  |  |  | |  . `  | |   __|  
#  |  |_)  |  /  _____  \  |  |     |  |     |  `--'  | |  |____  __|  `--'  | |  |\   | |  |____ 
#  |______/  /__/     \__\ |__|     |__|      \______/  |_______|(__)\______/  |__| \__| |_______|
#
#一键脚本
#version=v1.1
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#check root
[ $(id -u) != "0" ] && { echo "错误: 您必须以root用户运行此脚本"; exit 1; }
rm -rf all
rm -rf $0
#
# 设置字体颜色函数
function blue(){
    echo -e "\033[34m\033[01m $1 \033[0m"
}
function green(){
    echo -e "\033[32m\033[01m $1 \033[0m"
}
function greenbg(){
    echo -e "\033[43;42m\033[01m $1 \033[0m"
}
function red(){
    echo -e "\033[31m\033[01m $1 \033[0m"
}
function redbg(){
    echo -e "\033[37;41m\033[01m $1 \033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m $1 \033[0m"
}
function white(){
    echo -e "\033[37m\033[01m $1 \033[0m"
}
#密钥监测
#SSpass=baiyue.one996

#            
# @安装docker
install_docker() {
    docker version > /dev/null || curl -fsSL get.docker.com | bash 
    service docker restart 
    systemctl enable docker  
}

# 单独检测docker是否安装，否则执行安装docker。
check_docker() {
	if [ -x "$(command -v docker)" ]; then
		blue "docker is installed"
		# command
	else
		echo "Install docker"
		# command
		install_docker
	fi
}

#工具安装
install_tool() {
    echo "===> Start to install tool"    
    if [ -x "$(command -v yum)" ]; then
        command -v curl > /dev/null || yum install -y curl
        systemctl stop firewalld.service
        systemctl disable firewalld.service
    elif [ -x "$(command -v apt)" ]; then
        command -v curl > /dev/null || apt install -y curl
    else
        echo "Package manager is not support this OS. Only support to use yum/apt."
        exit -1
    fi 
}

# 以上步骤完成基础环境配置。
echo "恭喜，您已完成基础环境安装，可执行安装程序。"

backend_docking_set(){
    white "本骄脚本支持 green "webapi" 和 green "数据库对接" 两种对接方式"
    green "请选择对接方式(默认推荐webapi)"
    yellow "1.webapi对接(准备好域名就行)"
    yellow "2.数据库对接（需要提供完整的ip、数据库名、用户名、密码，且mysql要允许所有ip访问）"
    echo
    read -e -p "请输入数字[1~2](默认1)：" vnum
    [[ -z "${vnum}" ]] && vnum="1" 
	if [[ "${vnum}" == "1" ]]; then
        greenbg "当前对接模式：webapi"
        greenbg "使用前请准备好 redbg "节点ID、前端网站ip或url、前端token" "
        green "请输入网址，示例：https://google.com (网站域名，与config里的baseurl保持一致)"
        read -p "请输入网址:" web_url
        green "请输入网站mukey(与config里的mukey保持一致):如未修改默认的NimaQu,可直接回车下一步"
        read -e -p "请输入mukey(默认值NimaQu)：" webapi_token
        [[ -z "${webapi_token}" ]] && webapi_token="NimaQu"
        green "节点ID,示例: 6"
        read -p "请输入节点ID:" node_id
        yellow "配置已完成，正在部署后端。。。。"
        start=$(date "+%s")
        install_tool
        check_docker
        docker run -d --name=ssrmu -e NODE_ID=$node_id -e API_INTERFACE=modwebapi -e WEBAPI_URL=$web_url -e WEBAPI_TOKEN=$webapi_token --network=host --log-opt max-size=50m --log-opt max-file=3 --restart=always baiyuetribe/sspanel:ssr
        greenbg "恭喜您，后端节点已搭建成功"
        end=$(date "+%s")
        echo 安装总耗时:$[$end-$start]"秒"           
	elif [[ "${vnum}" == "2" ]]; then
        greenbg "当前对接模式：数据库对接"
        greenbg "使用前请准备好 redbg "节点ID、前端网站ip、数据库ROOT密码、数据库名称" "
        green "请输入前端网网站IP，示例：23.94.13.115 (前端服务器IP地址)"
        read -p "请输入ip:" web_ip
        green "节点ID：示例3"
        read -p "请输入节点ID:" node_id
        green "请输入数据库名（宝塔左侧、数据库、网站用的：数据库名）"
        read -p "请输入数据库名:" db_name
        green "请输入数据库用户名（宝塔左侧、数据库、网站用的：用户名）"
        read -p "请输入数据用户名:" db_user                        
        green "请输入前端网站数据库密码，（宝塔左侧、数据库、网站用的：密码）"
        read -p "请输入前端数据库密码:" user_pwd
        yellow "配置已完成，正在部署后端。。。。"
        start=$(date "+%s")
        install_tool
        check_docker
        docker run -d --name=ssrmu -e NODE_ID=$node_id -e API_INTERFACE=glzjinmod -e MYSQL_HOST=$web_ip -e MYSQL_USER=$db_user -e MYSQL_DB=$db_name -e MYSQL_PASS=$user_pwd --network=host --log-opt max-size=50m --log-opt max-file=3 --restart=always baiyuetribe/sspanel:ssr
        greenbg "恭喜您，后端节点已搭建成功"
        end=$(date "+%s")
        echo 安装总耗时:$[$end-$start]"秒"           
	fi       
}

backend_docking_netflix(){
    white "本骄脚本支持 green "webapi" 和 green "数据库对接" 两种对接方式"
    green "请选择对接方式(默认推荐webapi)"
    yellow "1.webapi对接(准备好域名就行)"
    yellow "2.数据库对接（需要提供完整的ip、数据库名、用户名、密码，且mysql要允许所有ip访问）"
    echo
    read -e -p "请输入数字[1~2](默认1)：" vnum
    [[ -z "${vnum}" ]] && vnum="1" 
	if [[ "${vnum}" == "1" ]]; then
        greenbg "当前对接模式：webapi"
        greenbg "使用前请准备好 redbg "节点ID、前端网站ip或url、前端token" "
        green "请输入网址，示例：https://google.com (网站域名，与config里的baseurl保持一致)"
        read -p "请输入网址:" web_url
        red "Netflix解锁设置，示例：47.240.68.180 （如果没有，可回车，保留系统默认）"
        read -p "Netflix等流媒体解锁DNS:" dnsip
        [[ -z "${dnsip}" ]] && dnsip="8.8.8.8"         
        green "请输入网站mukey(与config里的mukey保持一致):如未修改默认的NimaQu,可直接回车下一步"
        read -e -p "请输入mukey(默认值NimaQu)：" webapi_token
        [[ -z "${webapi_token}" ]] && webapi_token="NimaQu"
        green "节点ID,示例: 6"
        read -p "请输入节点ID:" node_id
        yellow "配置已完成，正在部署后端。。。。"
        start=$(date "+%s")
        install_tool
        check_docker
        docker run -d --name=ssrmu -e NODE_ID=$node_id -e API_INTERFACE=modwebapi -e WEBAPI_URL=$web_url -e WEBAPI_TOKEN=$webapi_token -e DNS_1="$dnsip" -e DNS_2="" --network=host --log-opt max-size=50m --log-opt max-file=3 --restart=always baiyuetribe/sspanel:ssr
        greenbg "恭喜您，后端节点已搭建成功"
        end=$(date "+%s")
        echo 安装总耗时:$[$end-$start]"秒"           
	elif [[ "${vnum}" == "2" ]]; then
        greenbg "当前对接模式：数据库对接"
        greenbg "使用前请准备好 redbg "节点ID、前端网站ip、数据库ROOT密码、数据库名称" "
        green "请输入前端网网站IP，示例：23.94.13.115 (前端服务器IP地址)"
        read -p "请输入ip:" web_ip
        red "Netflix解锁设置，示例：47.240.68.180 （如果没有，可回车，保留系统默认）"
        read -p "Netflix等流媒体解锁DNS:" dnsip
        [[ -z "${dnsip}" ]] && dnsip="8.8.8.8"          
        green "节点ID：示例3"
        read -p "请输入节点ID:" node_id        
        green "请输入数据库名（宝塔左侧、数据库、网站用的：数据库名）"
        read -p "请输入数据库名:" db_name
        green "请输入数据库用户名（宝塔左侧、数据库、网站用的：用户名）"
        read -p "请输入数据用户名:" db_user                        
        green "请输入前端网站数据库密码，（宝塔左侧、数据库、网站用的：密码）"
        read -p "请输入前端数据库密码:" user_pwd
        yellow "配置已完成，正在部署后端。。。。"
        start=$(date "+%s")
        install_tool
        check_docker
        docker run -d --name=ssrmu -e NODE_ID=$node_id -e API_INTERFACE=glzjinmod -e MYSQL_HOST=$web_ip -e MYSQL_USER=$db_user -e MYSQL_DB=$db_name -e MYSQL_PASS=$user_pwd -e DNS_1="$dnsip" -e DNS_2="" --network=host --log-opt max-size=50m --log-opt max-file=3 --restart=always baiyuetribe/sspanel:ssr
        greenbg "恭喜您，后端节点已搭建成功"
        end=$(date "+%s")
        echo 安装总耗时:$[$end-$start]"秒"           
	fi       
}


#开始菜单
start_menu(){
    clear
    greenbg "==============================================================="
    greenbg "程序：sspanel后端对接【破解付费授权版】 v1.3                           "
    greenbg "系统：Centos7.x、Ubuntu、Debian等                              "
    #greenbg "脚本作者：Azure  联系QQ：2894049053 TG:@Latte_Coffe            "
    #greenbg "项目来源：Nimaqu Github:Anankke/SSPanel-Uim                    "
    #greenbg "TG群：https://t.me/baiyueGroup                                 "
    #greenbg "主题：专注分享优质web资源                                          "
    #greenbg "更新摘要：新增DNS流媒体解锁。计划新增状态检测、使脚本更智能            "
    greenbg "==============================================================="
    echo
    green "Netflix解锁设置，示例：47.240.68.180 #【如果没有，可以去TVCAT官网解锁，月费低质3元一个ip】"
    #green "TVCAT官网地址：https://my.tvcat.net/aff.php?aff=47   购买时输入优惠码:TVCAT"    
    echo
    white "-------------程序安装（二选一）-------------"
    green "1.SSPANEL后端对接（默认：支持SS\SSR）"
    green "2.SSPANEL后端安装（Netflix等流媒体解锁版）"
    yellow "以上模式支持普通端口和单端口多用户，也就是1个IP对应1个节点"
    white "------单端口多用户（新功能，不懂勿动）-------"
    yellow "此处适合一个ip对应多个节点或对接到不同机场"
    green "3.SSPANEL后端对接（默认：支持SS\SSR）"
    green "4.SSPANEL后端安装（Netflix等流媒体解锁版）"
    white "-------------杂项管理（此处3、4选项不适用）-------------"
    white "5.查看日志（故障查看、问题解决）"
    white "6.重启节点"
    white "7.卸载节点"
    white "-------------后端BBr加速-------------" 
    green "8.节点bbr加速（需要按情况自己调试，非必须）"
    green ""
    blue "0.退出脚本"
    echo
    echo
    read -p "请输入数字:" num
    #echo -n -e " \033[32m 请输入授权码\033[0m ："
    #read PASSWD
    #key=`echo -n $PASSWD`
    #if [[ ${key%%\ *} == $SSpass ]]
     #   then
      #  echo
       # echo 授权成功！
        #else
        #echo
       # echo "授权失败！请联系QQ：2894049053查看最新授权码"
      #  echo "一次授权，永久维护，请支持正版"
     #   echo "请扫码购买或访问https://mall.baiyue.one/product/18.html 自助购买，随时下单"
    #    printf "https://mall.baiyue.one/product/18.html" | curl -F-=\<- qrenco.de                
    #exit 0;
     #fi
    case "$num" in
    1)
    greenbg "您选择了默认对接方式"
    backend_docking_set
	;;
    2)
    greenbg "您选择了默认的Netflix解锁对接"
    backend_docking_netflix
	;;
    3)
    greenbg "开发中。。。。"
	;;
    4)
    greenbg "开发中。。。。"
	;;
	5)
    docker logs --tail 10 ssrmu
    white "以下内容未提示信息"
    green "================================================================================="
    green "如果没有ERRO信息，则代表运行正常"
    white "正常情况示例："
    white "2019-07-18 07:38:42 INFO     server_pool.py:176 starting server at 0.0.0.0:49206"
    white "2019-07-18 07:38:42 WARNING  server_pool.py:190 IPV4 [Errno 98] Address in use "
    red "其它情况则检查前端设置或填写的域名ip是否正确"
    green "================================================================================="
	;;
	6)
    docker restart ssrmu
    green "节点已重启完毕"
	;;
	7)
    redbg "正在卸载本机节点。。。"
    docker rm -f ssrmu
	;;
	8)
    yellow "bbr加速选用94ish.me的轮子"
    bash <(curl -L -s https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh)
	;;            
	0)
	exit 1
	;;
	*)
	clear
	echo "请输入正确数字[0~5],退出请按0"
	sleep 3s
	start_menu
	;;
    esac
}

start_menu

