#!/bin/bash

space='%-10s %-10s %-10s %-10s %s\n'
space2='%-9s %-9s %-9s %-9s %s\n'
line='-----------------------------------------'
total="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
exp='0'
active='0'
lock='0'
echo "$line"
printf "$space" "user" "expire" "exp_date" "detail"
echo "$line"
cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/user.txt
count=`cat /tmp/user.txt | wc -l`
for((i=1; i<=$count; i++ ))
do
        serval=`head -n $i /tmp/user.txt | tail -n 1`
        username=`echo $serval |cut -f1 -d:`
        inexp=`echo $serval |cut -f2 -d:`
        second=$(($inexp * 86400))
        inday=`date -d @$second`
        expired="$(chage -l $username | grep "Account expires" | awk -F": " '{print $2}')"
        date=`echo $inday |awk -F" " '{print $2,$6}'`
        jam=`date '+%s'`
        week=$(( $jam + 604800 ))
        if [$second -ge $jam];then
                printf "$space2" "$username" "$expired"  "active"  "nolock"
                active=$(($active + 1))
        if [$second -le $week];then
                printf "$space2" "$username" "$expired" "active" "lock"
                lock=$(($lock + 1))
        fi
        else
                printf "$space2" "$username" "$expired" "expired" "nolock"
                exp=$(($exp + 1))
                passwd -1 $username
        fi
done
echo "$line"
printf "$space2" "user: $total" "active: $active" "expired: $exp"  "lock: $lock"
echo "$line"
