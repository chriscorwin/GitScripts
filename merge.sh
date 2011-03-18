echo "##########################################"
echo Merging from $1 into $3
echo "##########################################"
echo
echo

if [ "$1" = "dev" ] || [ "$1" = "qa" ]
	then
	echo "merging from $1 not allowed. You may only merge INTO $1."
	exit -1
fi

if [ "$3" = "stage" ] || [ "$3" = "master" ]
	then
	echo "merging into $3 not allowed. You may only merge FROM $3."
	exit -1
fi

if [ "$3" = "dev" ] || [ "$3" = "qa" ]
	then
	echo "Delete $3 before merging into it? (y) n"
	read decision
	if [ -z "$decision" ] || [ "$decision" = "y" ]
		then
		${gitscripts_path}delete.sh $3
	fi
fi

echo
echo
checkbranch=`git status | grep "nothing to commit (working directory clean)"`
echo "$checkbranch"

if [ -z "$checkbranch" ]
	then
	echo
	echo "git status"
	git status
	echo
	echo

	echo "You appear to have uncommited changes."
	echo "(1). Continue with merging from $1 into $3 anyways"
	echo "2. Commit changes and continue with merging from $1 into $3"
	echo 3. Stash Changes and continue with merging from $1 into $3
	echo 4. Revert all changes to tracked files \(ignores untracked files\), and continue with merging from $1 into $3
	echo 5. Abort merging from $1 into $3
	read decision
	echo You chose: $decision
	if [ -z "$decision" ] || [ $decision -eq 1 ]
		then
		echo continuing...
	elif [ $decision -eq 2 ]
		then
		echo "please enter a commit message"
		read commitmessage
		${gitscripts_path}commit.sh "$commitmessage" -a
	elif [ $decision -eq 3 ]
		then
		echo This stashes any local changes you might have made and forgot to commit
		echo git stash
		git stash
		echo
		echo

		echo git status
		git status
		echo
		echo
	elif [ $decision -eq 4 ]
		then
		echo This attempts to reset your current branch to the last checkin
		echo if you have made changes to untracked files, this will not affect those
		echo git reset --hard
		git reset --hard
		echo
		echo

		echo git status
		git status
		echo
		echo
	else
		exit 1
	fi
fi




if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	exit -1
fi

echo This tells your local git about all changes on fl remote
echo git fetch --all --prune
git fetch --all --prune
echo
echo

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git fetch --all --prune failed"
	exit -1
fi

echo This checks out the $1 branch
echo git checkout $1
git checkout $1
echo
echo

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "checkout of branch $1 failed"
	exit -1
fi

echo This makes sure the $1 branch is up to date
echo \(if it doesn't exist on the remote yet, don't worry about the warnings\)
echo git pull fl $1
git pull fl $1

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git pull fl $1 failed"
	exit -1
fi

echo This checks out the $3 branch
echo git checkout $3
git checkout $3
echo
echo

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git checkout $3 failed"
	exit -1
fi

echo This makes sure the $3 branch is up to date
echo \(if it doesn't exist on the remote yet, don't worry about the warnings\)
echo git pull fl $3
git pull fl $3

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git pull fl $3 failed"
	exit -1
fi

echo
echo
echo This merges from $1 into $3
echo git merge $1
git merge $1

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git merge $1 failed"
	exit -1
fi

echo
echo
echo git status
git status
echo
echo

echo
echo

echo "Would you like to push? y (n)"
read YorN
if [ "$YorN" = "y" ]
	then
	remote=$(git remote)
	git push $remote head
fi

if [ $? -lt 0 ]
	then
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	git status
	echo "FAILED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "git push $remote $3 failed"
	exit -1
fi