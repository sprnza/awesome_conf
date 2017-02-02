#!/bin/bash
days=3
if [ $# -eq 0 ]; then
	awk '{max = 21}
    FNR==NR{s1[FNR]=$0; next}{s2[FNR]=$0}
    END { format = "%-" max "s\t%-" max "s\n";
    numlines=(NR-FNR)>FNR?NR-FNR:FNR;
    for (i=1; i<=numlines; i++) { printf format, s1[i]?s1[i]:"", s2[i]?s2[i]:"" }
    }' <(/usr/bin/cal --color=always) <(/usr/bin/khal list today $(date -d "+$days days" "+%d.%m.%Y"))
else
    /usr/bin/cal $@
fi
