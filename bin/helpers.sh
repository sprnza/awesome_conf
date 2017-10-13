#!/bin/bash
case $1 in
xset)
    xset q|awk '/  timeout:|  DPMS is / {if(++i%4==0) printf RS; printf $NF FS }'
;;
mpstat)
    mpstat 1 1 |tail -1| awk '{ printf("%d",100 - $12) }'
;;
firefox_tabs)
    if ps aux|grep "[f]irefox -P Sprnza" >/dev/null; then
         FF_curr=$(sed -n "$(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/a8s1f1wm.default/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nf.close()\nprint str(jdata["windows"][0]["selected"])')p" <(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/a8s1f1wm.default/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nfor win in jdata.get("windows"):\n\tfor tab in win.get("tabs"):\n\t\ti = tab.get("index") - 1\n\t\tprint tab.get("entries")[i].get("url")')|sed "s/www.//g" |awk  -F/ '{print $3}'|awk '!x[$0]++')
     fi
    if ps aux|grep "[f]irefox -P Nusha" >/dev/null; then
     FF_curr_nush=$(sed -n "$(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/f47o1j9v.Nusha/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nf.close()\nprint str(jdata["windows"][0]["selected"])')p" <(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/f47o1j9v.Nusha/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nfor win in jdata.get("windows"):\n\tfor tab in win.get("tabs"):\n\t\ti = tab.get("index") - 1\n\t\tprint tab.get("entries")[i].get("url")')|sed "s/www.//g" |awk  -F/ '{print $3}'|awk '!x[$0]++')
    fi
    echo "tabs = {\"$FF_curr\", \"$FF_curr_nush\"}"
    ;;
mon)
    output="$HOME/.bin/temp/local_status"
    uptime -p > $output
    uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print $3" "$4" "$5}' >> $output
    checkupdates|wc -l >> $output
    df --output=pcent|sed -n -e 4p -e 8p|sed s/" "//g|tr '\n' ' '>> $output
    echo "" >> $output
    sensors|awk '/^Core 0/{print $3}' >>$output
    ;;
vpn)
    ifconfig|grep -q "ppp0" && echo 1 || echo 0
    ;;
esac
