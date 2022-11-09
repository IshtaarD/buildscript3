#!/bin/bash 
# Ishtaar Desravines
# 2022-08-18
# Objective: This script checks to see if there is already a GitAcc group. If there is, it creates a user and adds the user to this group. If there is not, the script creates the group then creates a new user and adds to the group. 
#Breaks in Script
# i. if the user enters a bad password, the script outputs an error and then exits the script. The user and group are still created. 
# ii. the script does not 
if [ $UID != 0 ]; #if statement to check if the user is logged in as root user. If not, the script exits and must be run again with sudo. 
then 
	echo "Please log in as a superuser to continue.";
else
	
	echo "---------------------------------------------"
	echo "Please enter a username: " 
	read userName
	echo "---------------------------------------------"
	userList=$(awk -F ":" '{if($1=="'"$userName"'") print $1}' /etc/passwd)
	while [[ $userName == $userList ]];
	do 
		echo -e "Username: '$userName' already exists \nPlease enter another username: "
		read userName ; echo
		userList=$(awk -F ":" '{if($1=="'"$userName"'") print $1}' /etc/passwd)
	done
	if [[ -z $userList ]];
	then  
		echo  "Username '$userName' is available to use!" ; echo
	fi
	echo "---------------------------------------------" ; echo
	echo "Please enter a shell: "
	read shell; shell=$(echo $shell | tr [A-Z] [a-z]) ; echo
	echo "----------------------------------------------"
	echo ; echo "Please enter a group: "
	read group; echo 
	echo "Scanning your system to see if $group exists..."
        sleep 3
        groupList=$(grep "$group" /etc/group)
        if [[ -z $groupList ]];
        then 
                echo "$group group does not exist." ; echo
                read -p "Create new user group: $group?" ans
                ans=$(echo $ans | cut -c 1 | tr [A-Z] [a-z])
                while [[ $ans != 'y' && $ans != 'no' ]]
                do
                        read -p "Please enter Yes or N" ans ; echo
                done;        
		if [ $ans = 'y' ]
                then 
			groupadd $group
		else 
			read -p "Enter the name of an existing group." group
		fi
	else 
		echo "$group exists." ; echo
		echo "-------------------------------------------" ; echo
	fi

	echo "Please create a password: "
	read password ; echo 
	echo "---------------------------------------------" ; echo

	case $shell in
		bash) shell="/bin/bash";;
		"/bin/bash") shell=$shell;;
	esac

	useradd -m -g "$group" -s "$shell" "$userName"
	echo $userName:$password | chpasswd 
	
	echo " YOUR USER ACCOUNT HAS SUCCESSFULLY BEEN CREATED." ; echo
	echo "----------------------SUMMARY--------------------" ; echo
	echo "user: $userName" ; echo 
	echo "shell: $shell" ; echo 
	echo "group: $group" ; echo 
	echo "password: Hidden for security purposes" ; echo 
	echo "-------------------------------------------------" ; echo
	echo " YOUR USER ACCOUNT HAS SUCCESSFULLY BEEN CREATED." ; echo
	echo "--------------------------------------------------"

	#do a check to see if the user account + group account was actually created 

fi
exit 0