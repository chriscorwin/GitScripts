echo "##########################################"
echo Deleting new branch $1
echo "##########################################"

echo
echo
checkbranch=`git status | grep "$1"`
echo "$checkbranch"

if [ -n "$checkbranch" ]
	then
	echo
	echo
	echo "You are currently on branch $1. You cannot delete a branch you are on."
	echo "(1) Checkout master"
	echo "2 Checkout another branch"
	echo "3 Abort"
	read choice

	if [ -z "$choice" ] || [ $choice -eq 1 ]
		then
		echo
		echo "git checkout master"
		${gitscripts_path}checkout.sh master
		echo
		echo
	elif [ $choice -eq 2 ]
		then
		echo "please specify the branch you wish to check out,"
		echo "or enter \"abort\" to quit"
		read enteredBranchName
		if [ "$enteredBranchName" = "abort" ]
			then
			exit 0
		fi
		echo
		echo checking out $enteredBranchName before deleting branch $1
		echo
		echo

		${gitscripts_path}checkout.sh $enteredBranchName
	elif [ $choice -eq 3 ]
		then
		exit 0
	fi

	if [ $? -lt 0 ]
		then
		echo
		echo "something went wrong!"
		echo
		echo "git status"
		git status

		exit -1
	fi
fi


trydelete=`git branch -d $1 2>&1 | grep "error"`
echo "$trydelete"
echo
if [ -n "$trydelete" ]
	then
	echo "Delete failed!"
	echo "force delete? y (n)"
	read forcedelete
	if [ "$forcedelete" = "y" ]
		then
		trydelete=`git branch -D $1 2>&1 | grep "error"`
		echo "$trydelete"
		echo
		if [ -n "$trydelete" ]
			then
			echo "force delete failed!"
			exit -1
		else
			echo "force delete succeeded!"
			echo
		fi
	fi
else
	echo "delete succeeded!"
	echo
fi

#if it is master or stage, don't even prompt them to delete remote...
if [ "$1" != "master" ] && [ "$1" != "stage" ] && [ "$1" != "dev" ] && [ "$1" != "qa" ] && [ "$1" != "dev2" ]
	then

	onremote=`git branch -r | grep "$1"`
	if [ -n "$onremote" ]
		then
		echo
		echo "delete remote copy of branch? y (n)"
		read deleteremote

		if [ -n "$deleteremote" ] && [ "$deleteremote" = "y" ]
			then
			echo
			echo "deleting remote!"
			echo
			remote=$(git remote)
			echo "git push $remote :$1"
			git push $remote :$1
		fi
	fi
fi

exit 1