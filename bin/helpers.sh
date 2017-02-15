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
         FF_curr=$(sed -n "$(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/r3s1tqtv.default-1461356328002/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nf.close()\nprint str(jdata["windows"][0]["selected"])')p" <(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/r3s1tqtv.default-1461356328002/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nfor win in jdata.get("windows"):\n\tfor tab in win.get("tabs"):\n\t\ti = tab.get("index") - 1\n\t\tprint tab.get("entries")[i].get("url")')|sed "s/www.//g" |awk  -F/ '{print $3}'|awk '!x[$0]++')
     fi
    if ps aux|grep "[f]irefox -P Nusha" >/dev/null; then
     FF_curr_nush=$(sed -n "$(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/f47o1j9v.Nusha/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nf.close()\nprint str(jdata["windows"][0]["selected"])')p" <(python2 <<< $'import json\nf = open("/home/speranza/.mozilla/firefox/f47o1j9v.Nusha/sessionstore-backups/recovery.js", "r")\njdata = json.loads(f.read())\nf.close()\nfor win in jdata.get("windows"):\n\tfor tab in win.get("tabs"):\n\t\ti = tab.get("index") - 1\n\t\tprint tab.get("entries")[i].get("url")')|sed "s/www.//g" |awk  -F/ '{print $3}'|awk '!x[$0]++')
    fi
    echo "tabs = {\"$FF_curr\", \"$FF_curr_nush\"}"
    ;;
esac
