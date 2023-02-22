#!/bin/bash

# Storyline: Script to perform local security checks

function checks() {

	if [[ $2 != $3 ]]
	then

		echo -e "\e[1;31mThe $1 is not compliant. \nThe current policy should be: $2. \nThe current value is: $3.\nRemediation:\n$4\e[0m\n"

	else

		echo -e "\e[1;32mThe $1 is compliant. Current value is: $3.\e[0m\n"

	fi

}


# Check the password max days policy

pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' { print $2 } ')

# Check for password max

checks "Password Max Days" "365" "${pmax}" "Set the PASS_MAX_DAYS parameter to 365 in /etc/login.defs"

# Check the pass min days between changes

pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' { print $2 } ')

checks "Password Min Days" "14" "${pmin}" "Set the PASS_MIN_DAYS parameter to 14 in /etc/login.defs"

# Check the pass warn age

pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' { print $2 } ')

checks "Password Warn Age" "7" "${pwarn}" "Set the PASS_WARN_AGE parameter to 7 in /etc/login.defs"

# Check the SSH UsePam Configuration

chkSSHPAM=$(egrep -i "UsePAM" /etc/ssh/ssh_config | awk ' { print $2 } ' )
checks "SSH UsePAM" "yes" "${chkSSHPAM}" ""

# Check permissions on users' home directory

#echo ""
for eachDir in $(ls -l /home | egrep '^d' | awk ' { print $3 } ' )
do

	chDir=$(ls -ld /home/${eachDir} | awk ' { print $1 } ' )
	checks "Home directory ${eachDir}" "drwx------" "${chDir}" ""

done

# Ensure if IP forwarding is disabled

checkIPforward=$(egrep -i 'net\.ipv4\.ip_forward' /etc/sysctl.conf | cut -d '=' -f 2-)
checks "IP Forwarding" "0" "${checkIPforward}" "Edit /etc/sysctl.conf and set 'net.ipv4.ip_forward = 0'. Then run:\nsysctl -w net.ipv4.ip forward=0\nsysctl -w net.ipv4.route.flush=1"

# Ensure ICMP redirects are accepted or not

checkICMPredirect=$(grep "net\.ipv4\.conf\.all\.accept_redirects" /etc/sysctl.conf | awk ' { print $3 } ')
checks "ICMP Redirects" "0" "${checkICMPredirect}" "Edit /etc/sysctl.conf and set 'net.ipv4.conf.all.accept redirects = 0'. Then run:\nsysctl -w net.ipv4.conf.all.accept redirects=0\nsysctl -w net.ipv4.conf.default.accept redirects=0\nsysctl -w net.ipv4.route.flush=1"

# Ensure permissions on /etc/crontab are configured

checkCrontab=$(stat /etc/crontab | head -4 | tail -1)
checks "/etc/crontab Permissions" "\nAccess: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${checkCrontab}" "Run:\nchown root:root /etc/crontab\nchmod og-rwx /etc/crontab"

# Ensure permissions on /etc/cron.hourly are configured

checkCronhourly=$(stat /etc/cron.hourly | head -4 | tail -1 )
checks "/etc/cron.hourly Permissions" "\nAccess: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${checkCronhourly}" "Run:\nchown root:root /etc/cron.hourly\nchmod og-rwx /etc/cron.hourly"

# Ensure permissions on /etc/cron.daily are configured

chekCrondaily=$(stat /etc/cron.daily | head -4 | tail -1)
checks "/etc/cron.daily Permissions" "\nAccess: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${checkCrondaily}" "Run:\nchown root:root /etc/cron.daily\nchmod og-rwx /etc/cron.daily"

# Ensure permissions on /etc/cron.weekly are configured

checkCronweekly=$(stat /etc/cron.weekly | head -4 | tail -1)
checks "/etc/cron.weekly Permissions" "\nAccess: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "\n${checkCronweekly}" "Run:\nchown root:root /etc/cron.weekly\nchmod og-rwx /etc/cron.weekly"

# Ensure permissions on /etc/cron.monthly are configured

checkCronmonthly=$(stat /etc/cron.monthly | head -4 | tail -1)
checks "/etc/cron.monthly Permissions" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${checkCronmonthly}" "Run:\nchown root:root /etc/cron.monthly\nchmod og-rwx /etc/cron.monthly"

# Ensure permissions on /etc/passwd are configured
checkpasswd=$(stats /etc/passw | head -4 | tail -1)
checks "/etc/passwd Permissions" "Access: (0644/-rw-r--r--) Uid: ( 0/ root) Gid: ( 0/ root)" "${checkpasswd}" "Run:\nchown root:root /etc/passwd\nchmod 644 /etc/passwd"

# Ensure permissions on /etc/shadow are configured
checkshadow=$(stat /etc/shadow | head -4 | tail -1)
checks "/etc/shadow Permissions" "Access: (0640/-rw-r-----) Uid: ( 0/ root) Gid: ( 42/ shadow)" "${checkshadow}" "Run:\nchown root:shadow /etc/shadow\nchmod o-rwx,g-wx /etc/shadow"

# Ensure permissions on /etc/group are configured
checkgroup=$(stat /etc/group | head -4 | tail -1)
checks "/etc/group Permissions" "Access: (0644/-rw-r--r--) Uid: ( 0/ root) Gid: ( 0/ root)" "${checkgroup}" "Run:\nchown root:root /etc/group\nchmod 644 /etc/group"

# Ensure permissions on /etc/gshadow are configured
checkgshadow=$(stats /etc/gshadow | head -4 | tail -1)
checks "/etc/gshadow Permissions" "Access: (0640/-rw-r-----) Uid: ( 0/ root) Gid: ( 42/ shadow)" "${checkgshadow}" "Run:\nchown root:shadow /etc/gshadow\nchmod o-rwx,g-rw /etc/gshadow"

# Ensure permissions on /etc/passwd- are configured
checkpasswdm=$(stats /etc/passwd- | head -4 | tail -1)
checks "/etc/passwd- Permissions" "Access: (0644/-rw-r--r--) Uid: ( 0/ root) Gid: ( 0/ root)" "${checkpasswdm}" "Run:\nchwon root:root /etc/passwd-\nchmod u-x,go-wx /etc/passwd-"

# Ensure permissions on /etc/shadow- are configured
checkshadowm=$(stats /etc/shadow- | head -4 | tail -1)
checks "/etc/shadow- Permissions " "Access: (0640/-rw-r-----) Uid: ( 0/ root) Gid: ( 42/ shadow)" "${checkshadowm}" "Run:\nchown root:shadow /etc/shadow-\nchmod o-rwx,g-rw /etc/shadow-"

# Ensure permissions on /etc/group- are configured
checkgroupm=$(stats /etc/group- | head -4 | tail -1)
checks "/etc/group- Permissions" "Access: (0644/-rw-r--r--) Uid: ( 0/ root) Gid: ( 0/ root)" "${checkgroupm}" "Run:\nchown root:root /etc/group\nchmod u-x,go-wx /etc/group-"

# Ensure permissions on /etc/gshadow- are congfigured
checkgshadowm=$(stats /etc/gshadow- | head -4 | tail -1)
checks "/etc/gshadow- Permissions" "Access: (0640/-rw-r-----) Uid: ( 0/ root) Gid: ( 42/ shadow)" "${checkgshaodwm}" "Run:\nchown root:shadow /etc/gshadow-\nchmod o-rwx,g-rw /etc/gshadow-"

# Ensure no legacy "+" entries exists in /etc/passwd
checketcpasswdlegacy=$(grep '^\+:' /etc/passwd)
checks "/etc/passwd Legacy Entries" "" "${checketcpasswdlegacy}" "Remove any legacy '+' entries if they exist"

# Ensure no legacy "+" entries exists in /etc/shadow
checketcshadowlegacy=$(grep '^\+:' /etc/shadow)
checks "/etc/shadow Legacy Entries" "" "${checketcshadowlegacy}" "Remove any legacy '+' entries if they exist" 

# Ensure no legacy "+" entries exists in /etc/group
checketcgrouplegacy=$(grep '^\+:' /etc/group)
checks "/etc/group Legacy Entries" "" "${checketcgrouplegacy}" "Remove any legacy '+' entries if they exist" 

# Ensure root is the onlu UID 0 account
checkRoot=$(cat /etc/passwd | awk -F: '($3 == 0) { print $1 }')
checks "UID 0" "root" "${checkRoot}" "Remove any users other than root with UID 0"
