#!/bin/bash
echo "dnspod"


#此脚本定时修改dnspod的IP

# 全局变量表
arPass=arMail=""

# 获得外网地址
arIpAddress() {
    local extip
    extip=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 | grep -Ev '(^127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.1[6-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.2[0-9]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^172\.3[0-1]{1}[0-9]{0,1}\.[0-9]{1,3}\.[0-9]{1,3}$)|(^192\.168\.[0-9]{1,3}\.[0-9]{1,3}$)')
    if [ "x${extip}" = "x" ]; then
        extip=$(ip -o -4 addr list | grep -Ev '\s(docker|lo)' | awk '{print $4}' | cut -d/ -f1 )
    fi
    echo $extip
}

# 查询域名地址
# 参数: 待查询域名
arNslookup() {
    local dnsvr="114.114.114.114"
    busybox nslookup ${1} $dnsvr | tr -d '\n[:blank:]' | sed 's/.\+1 [0-9\.]\+/\1/'
}

# 读取接口数据
# 参数: 接口类型 待提交数据
arApiPost() {
    local agent="AnripDdns/5.07(mail@anrip.com)"
    local inter="https://dnsapi.cn/${1:?'Info.Version'}"
    local param="login_email=${arMail}&login_password=${arPass}&format=json&${2}"
    wget --quiet --no-check-certificate --output-document=- --user-agent=$agent --post-data $param $inter
}

# 更新记录信息
# 参数: 主域名 子域名
arDdnsUpdate() {
    local domainID recordID recordRS recordCD myIP
    # Get domain ID
    domainID=$(arApiPost "Domain.Info" "domain=${1}")
    domainID=$(echo $domainID | sed 's/.*{"id":"\([0-9]*\)".*/\1/')

    # Get Record ID
    recordID=$(arApiPost "Record.List" "domain_id=${domainID}&sub_domain=${2}")
    recordID=$(echo $recordID | sed 's/.*\[{"id":"\([0-9]*\)".*/\1/')

    # Update IP
    myIP=$(arIpAddress)
    recordRS=$(arApiPost "Record.Ddns" "domain_id=${domainID}&record_id=${recordID}&sub_domain=${2}&record_type=A&value=${myIP}&record_line=默认")
    recordCD=$(echo $recordRS | sed 's/.*{"code":"\([0-9]*\)".*/\1/')

    # Output IP
    if [ "$recordCD" = "1" ]; then
        echo $recordRS | sed 's/.*,"value":"\([0-9\.]*\)".*/\1/'
        return 1
    fi
    # Echo error message
    echo $recordRS | sed 's/.*,"message":"\([^"]*\)".*/\1/'
}

# 动态检查更新
# 参数: 主域名 子域名
arDdnsCheck() {
    local postRS
    local hostIP=$(arIpAdress)
    local lastIP=$(arNslookup "${2}.${1}")
    echo "hostIP: ${hostIP}"
    echo "lastIP: ${lastIP}"
    if [ "$lastIP" != "$hostIP" ]; then
        postRS=$(arDdnsUpdate $1 $2)
        echo "postRS: ${postRS}"
        if [ $? -ne 1 ]; then
            return 0
        fi
    fi
    return 1
}

###################################################

# 设置用户参数 账号密码
arMail="xxx@xxx.com"
arPass="password"

# 检查更新域名 一个参数不带www的域名，第二个是二级子域名
arDdnsCheck "163.com" "mail"



####################
#
# 最后加入 crontab
# 0 2 * * * sh /tmp/ddnspod.sh > /tmp/ddnspod.log #更新域名解析地址 每天凌晨2点执行，并且输出日志
#
####################
exit 0
