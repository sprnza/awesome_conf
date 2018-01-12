# AwesomeWM configuration file
# Requirements
## Apps
* [light](https://github.com/haikarainen/light)
* sysstat
* xfce4-screenshooter
* redshift
* xcmenu

## Libraries
lain
##Scripts
###server_status.sh
This script have to create a `server_status` file. Example:

```
up 1 week, 3 days, 22 hours, 59 minutes
0.01, 0.06, 0.08
+52.0°C
36% 60% 49% 
10
04
941M
11:25
```

###checkmail.sh
A script that checks mail and unread Telegram messages and echos the numbers to awesome-client using these variables `pr_mail` `wrk_mail` `telegram` for private, work mails and telegram respectively.
