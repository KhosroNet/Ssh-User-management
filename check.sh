#!/bin/bash
clear
if [[ -e /usr/lib/licence ]]; then
    database="/root/usuarios.db"
    echo -e "\E[44;1;37m◇ User          ◇ Status  ◇ Connections ◇ Time \E[0m"
    echo ""
    echo ""
    while read usline
    do
        user="$(echo $usline | cut -d' ' -f1)"
        s2ssh="$(echo $usline | cut -d' ' -f2)"
        if [ "$(cat /etc/passwd| grep -w $user| wc -l)" = "1" ]; then
            sqd="$(ps -u $user | grep sshd | wc -l)"
        else
            sqd=0
        fi
        cnx=$(($sqd))
        if [[ $cnx -gt 0 ]]; then
            tst="$(ps -o etime $(ps -u $user |grep sshd |awk 'NR==1 {print $1}')|awk 'NR==2 {print $1}')"
            tst1=$(echo "$tst" | wc -c)
            if [[ "$tst1" == "9" ]]; then
                timerr="$(ps -o etime $(ps -u $user |grep sshd |awk 'NR==1 {print $1}')|awk 'NR==2 {print $1}')"
            else
                timerr="$(echo "00:$tst")"
            fi
            status=$(echo -e "\033[1;32mOnline\033[1;33m         ")
            echo -ne "\033[1;33m"
            printf '%-16s%-10s%-13s%s\n' " $user"      "$status" "$cnx/$s2ssh" "$timerr"
            echo -e "\033[0;34m◇───────────────────────────────────────────────◇\033[0m"
        fi
    done < "$database"
fi
