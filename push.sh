#!/bin/bash
## /*
#	@usage push [branch-name]
#
#	@description
#	This is a quick script that pushes a specified branch or the current branch to
#	the remote, if it exists. To push a specific branch, simply include it as the
#	first parameter when using this script.
#	description@
#
#	@options
#	-q, --quiet	Suppress the "Pushing not allowed" warning message and silently exit.
#	--tags ALSO pushes tags to remote
#	options@
#
#	@examples
#	1) push
#	   # pushes current branch
#	2) push some-other-branch
#	   # pushes some-other-branch...
#	3) push --tags
#	   # pushes current branch -AND- pushes any tags
#	examples@
#
#	@dependencies
#	functions/5000.branch_exists_local.sh
#	functions/5000.parse_git_branch.sh
#	functions/5000.set_remote.sh
#	dependencies@
#
#	@file push.sh
## */
$loadfuncs


# reset styles
echo ${X}

force=""

# parse params
numArgs=$#
if (( numArgs > 0 && numArgs < 6 )); then
	until [ -z "$1" ]; do
		[ "$1" = "--admin" ] && [ "$ADMIN" = "true" ] && isAdmin=true
		{ [ "$1" = "-a" ] ||  [ "$1" = "--all" ]; } && pushToAll=true
		{ [ "$1" = "-q" ] ||  [ "$1" = "--quiet" ]; } && isQuiet=true
		{ [ "$1" = "-f" ] ||  [ "$1" = "--force" ]; } && force="-f"
		[ "$1" = "--tags" ] && pushTags=true
		! echo "$1" | egrep -q "^-" && branch="$1"
		shift 1
	done
fi

# setup FAILURE conditions
# set pushing branch if specified, otherwise...
if [ -n "$branch" ]; then
	if ! __branch_exists_local "$branch"; then
		echo ${E}"  The branch \`${branch}\` does not exist locally! Aborting...  "${X}
		exit 1
	fi
# ...grab current branch and validate
else
	cb=$(__parse_git_branch)
	[ $cb ] && { branch="$cb"; } || {
		echo ${E}"  Could not determine current branch!  "${X}
		exit 1
	}
fi

if [ $pushToAll ]; then
	# if --all flag was passed, just push to all remotes. Otherwise, see if they want to choose a remote to push it to.
	# run loop. reads from temp file.
	# send branch data to temp file
	tmp="${gitscripts_temp_path}remotes"
	git remote > $tmp

	# run loop. reads from temp file.
	declare -a remoteNames
	while read remote; do
		pieces=( $remote )
		remoteNames[${#remoteNames[@]}]="${pieces[0]}"
	done <"$tmp"

	# temp file no longer necessary
	rm "$tmp"

	# let's get this party started...
	for (( i = 0; i < ${#remoteNames[@]}; i++ )); do
		echo "$ git push ${remoteNames[$i]} ${branch}"
		git push "${remoteNames[$i]}" "${branch}"
	done
else
	# a remote is required to push to
	if ! __set_remote; then
		echo ${E}"  Aborting...  "${X}
		exit 1
	fi


	# setup default answers
	if [ "$pushanswer" == "y" ] || [ "$pushanswer" == "Y" ]; then
		defO=" (y) n"
		defA="y"
	else
		defO=" y (n)"
		defA="n"
	fi

	# --quiet will use default answer
	if [ ! $isQuiet ]; then
		echo ${Q}"Would you like to $force push ${B}\`${branch}\`${Q} to ${COL_GREEN}${_remote}${Q}?${defO}"${X}
		read yn
	fi

	if [ -z "$yn" ]; then
		yn=$defA
	fi

	echo
	if [ "$yn" == "y" ] || [ "$yn" == "Y" ]; then
		if [ -n "$_remote" ]; then
			echo
			echo "Now $force ${A}pushing${X} to:${X} ${COL_GREEN} ${_remote} ${X}"
			echo ${O}${H2HL}
			echo "$ git push $force ${_remote} ${branch}"
			git push $force "${_remote}" "${branch}"
			echo ${O}${H2HL}${X}
			echo
		else
			echo ${E}"  No remote could be found. Push aborted.  "${X}
			exit 1
		fi
	fi

	if [ $pushTags ]; then
		echo
		echo "Now ${A}pushing${X} tags to: ${COL_GREEN} ${_remote} ${X}"
		echo "$ git push --tags ${_remote}"
		git push --tags ${_remote}
		echo ${O}${H2HL}${X}
	fi

	hasRemote=$(git config branch.$branch.remote 2> /dev/null)
	if [ -z "$hasRemote" ]; then
		echo
		echo ${Q}"Setup remote tracking of ${COL_GREEN}${_remote}${Q} for ${B}\`${branch}\`${Q}? (y) n"
		read yn
		if [ -z "$yn" ] || [ "$yn" = "y" ]; then
			git branch --set-upstream-to $_remote/$branch $branch
		fi
	fi
fi


exit
