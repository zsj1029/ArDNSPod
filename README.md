# ArDNSPod
基于DNSPod用户API实现的纯Shell动态域名客户端，适配潘多拉等路由器。

原作者的shell脚本，在路由器执行会有错误提示，导致crontab中无法运行
```
Linux
/tmp/ddnspod.sh: line 96: command: not found
/tmp/ddnspod.sh: line 96: command: not found
/tmp/ddnspod.sh: line 96: command: not found
/tmp/ddnspod.sh: line 96: command: not found
/tmp/ddnspod.sh: line 96: command: not found
```
# Usage
使用方法：修改ddnspod.sh文件 82行~87行

执行时直接运行`ddnspod.sh`，支持cron任务。


感谢原作者anrip提供的思路方法
