#!/bin/bash
case $1 in
xset)
    xset q|awk '/  timeout:|  DPMS is / {if(++i%4==0) printf RS; printf $NF FS }'
;;
mpstat)
    mpstat 1 1 |tail -1| awk '{ printf("%d",100 - $12) }'
;;
esac
