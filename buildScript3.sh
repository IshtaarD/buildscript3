#!/bin/bash

# Ishtaar Desravines
# 2022-08-18
# Build Script 3

# Objectives: To add and commit a file in local repository, check for sensitive information in the file, then push to remote repository. 

# Flow:
# i. Allows the to create a git repository on your local machine if they don't already have one. 
# ii. Allows the user to change directories into their local repository if they already have one on their local machine.    
# iii. Allows the user to create a file in their local repository or choose a file that already exists in it, and gives them the choice to edit or not. 
# iv. After deciding whether or not to edit the file, the user can decide whether or not to add the file. If the user decides not to, they must run the script again and follow prompts. 
# v. After file has been added and committed, the script checks for sensitive inforamtion and keeps opening nano editor until all sensitive info is either X out of deleted. 
# vi. Once it passes the check, the script pushes the file to the remote repostiory. 


# Breaks in the Script:
# i.If the user tries to create a file or repositories in a folder they do not have permission in, they will get permission denied errors. Script will still run. To avoid, user must be in a directory they can write to and execute in. 
# ii. the absolute path needs to be typed out correctly and can't be shortcut with ~. (example: works- /home/ishtaar/...   does not work- ~/... 
# iii. if the user says they are in a repository when they are not, the script will still run but they will get errors later in the script. 
# iv. if the user is creating a new repository for the script, they will have to link their remote repository to their local one. The script will still run to the end but will not be able to push changes to the remote repository.  


# MOST SUCCESSFUL FUN: when the user has a repository that is already linked to a remote repository. The user can create a file to have checked for sensitive info or use an existing one in their repo. 


read -p "Do you have a git repo on your local machine? " answer ; echo #takes user input and assigns it to varibale $answer. 
answer=$(echo $answer | cut -c 1 | tr [A-Z] [a-z]) #takes the user input and cuts everything but the first character then translates any uppercase to lowercase to ensure that yes, no, y, n, in uppercase or lower case will still be read. The output is reassigned to the variable
while [[ $answer != 'y' && $answer != 'n' ]] #while loop to keep prompting the user to enter in valid choices (Yes or No).
do 
	read -p "Enter Yes or No" answer
	answer=$(echo $answer | cut -c 1 | tr [A-Z] [a-z])
done

if [ $answer = 'y' ] # if/elif statement to ask the user if they have a repository and change directory into it if they are not currently in it. If they do not have an existing repository, it allows them to create one and initalize git. 
then 
	read -p "Are you in your repo? " answer ; echo 
	answer=$(echo $answer | cut -c 1 | tr [A-Z] [a-z])
	if [ $answer = 'n' ] 
	then
		read -p "What is the absolute path to your repo?" aPath ; echo
		cd $aPath 
		read -p  "What is the name of the existing file or the file you want to create? " fileName ; echo
	elif [ $answer = 'y' ] #script will continue to run if you are not in your rep but you will get fatal errors from git
	then
		read -p  "What is the name of the existing file or the file you want to create? " fileName ; echo
		
	fi
elif [ $answer = 'n' ] #if the user does not have a repository, the elif statement will allow them to create one,  and initialize git.
then  
	read -p "Enter in a directory name to create a repo: " dirName ; echo
	mkdir $dirName
	cd $dirName
	echo "Initializing git to create a repository..." ; echo 
	echo "------------------------------------------------------------"
	git init
	echo "------------------------------------------------------------"
	echo "$dirName repository created." ; echo
 	read -p "Enter in a file name to create a file." fileName ; echo 
	touch $fileName 

fi

read -p "Would you like to edit your file before adding and committing?" answer ; echo 
answer=$(echo $answer | cut -c 1 | tr [A-Z] [a-z])
if [ $answer = 'y' ] #if statement opens nano in case the user wants to make any edits or if they are creating a new file.
then
	echo "Nano editor will open so you can add changes and save them.." ; echo
	sleep 4
	nano $fileName
elif [ $answer = 'n' ]
then
	echo "No additional changes are being made." ; echo 
else 
	read -p 'Please enter valid option: "Yes or No"' answer
	answer=$(echo $answer | cut -c 1 | tr [A-Z] [a-z])
fi


read -p "Would you like to add your file to the staging area now? " answer ; echo
answer=$(echo $answer | cut -c 1 | tr [A-Z] [a-z])
if [ $answer = 'y' ] # if statement adds the file  then commits it and checks for sensitive data. 
then 
	git add $fileName 
	echo "File has been added to staging area" ; echo
	read -p "Please enter a commit message: " message ; echo
	git commit -m "$message"
	echo "------------------------------------------------------------------------"
	echo "Checking your file for sensitive information before pushing it to your remote repository..."
	sleep 4
	sensNum=$(grep -o '\(\(([0-9]\{3\})\|[0-9]\{3\}\)[ -]\?\)\{2\}[0-9]\{4\}' $fileName) #variable takes the file name the user inputs a checks for various formatting of phone numbers to get matches from each line of the file. 
	while [[ -n $sensNum ]] #if the variable keeps returning any value (phone numbers), it will keep going going through the loop and opening the nano editor. It stop when it returns nothing. 
        do  
                echo "This file is not secure.  Please edit the file and X out all sensitive information."
                echo "Nano editor will open in 4 seconds...."
                sleep 4
                nano $fileName
		sensNum=$(grep -o '\(\(([0-9]\{3\})\|[0-9]\{3\}\)[ -]\?\)\{2\}[0-9]\{4\}' $fileName ) 	
	done

	if [[ -z  $sensNum ]] #if the variable does not return any value (phone numbers), then it will move on to pushing the file to the remote repository.
	then 
		echo "There isn't any sensitive information in this file. You are good to push to remote repository."
		read -p "What is the name of the branch you would like to push to? " branch
		echo "---------------------------------------------------------------------------------------------"
		echo "PUSHING TO MAIN REPOSITORY..."
		echo "--------------------------------------------------------------------------------------------"
		sleep 4
		git push origin $branch 
		echo "Your file $fileName has been pushed to the $branch branch of your remote repository."
		echo "--------------------------------------------------------------------------------------------"  
		echo "Your git status is displayed below:" ; echo
		git status
		echo "------------------------------------------------------------------------"
	fi

elif [ $answer = 'n'] #if the user does not want to add their file or commit changes, the script will exit and the user will have to start again.
then
	echo "Run the script again when you're ready to add and commit changes "	
else 
	echo "Enter valid option Yes or No" 
fi

