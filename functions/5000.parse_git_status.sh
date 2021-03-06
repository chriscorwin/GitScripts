## /* @function
#	@usage __parse_git_status <state_flag>
#
#	@output false
#
#	@description
#	Determine various states of files in your current working tree and your current
#	repository. Currently supported <state_flag> values are below.
#	(see __parse_git_branch_state function definition for how states are determined)
#
#	ahead, behind, clean, deleted, modified, newfile, onremote, renamed, staged,
#	*tracking, untracked
#	description@
#
#	@notes
#	- If no parameter or an invalid parameter is given, the failure is logged and the
#	the function returns status 1.
#	- The output of the egrep command is intentionally suppressed as this function
#	is intended to be used as a boolean in conditional expressions.
#	- The data parsed is git status with the --short and -b flags included. This
#	format will remain constant through Git versions and was intended for script
#	parsing.
#	notes@
#
#	@examples
#	# ... user makes some changes and attempts to switch branches ...
#
#	if __parse_git_status modified; then
#		echo "Are you sure you want to change branches? You have uncommitted changes."
#		read answer
#		# ... parse answer and act accordingly ...
#	fi
#
#	# ...
#	examples@
#
#	@dependencies
#	functions/0200.gslog.sh
#	functions/0500.is_repo.sh
#	functions/1000.parse_git_branch.sh
#	dependencies@
#
#	@file functions/5000.parse_git_status.sh
## */
function __parse_git_status {
	! __is_repo && exit

	if [ -z "$1" ]; then
		__gslog "__parse_git_status: Invalid usage. A parameter matching status type is required."
		return 1
	fi

	# these are required when checking for these specific states (not "all")
	local ahead="\[ahead [[:digit:]]+\]$"
	local behind="\[behind [[:digit:]]+\]$"
	local deleted="^([ A-Z]D|D[ A-Z])"
	local modified="^[ A-Z]M"
	local newfile="^A[ A-Z]"
	local renamed="^R[ A-Z]"
	local staged="^[A-Z]"
	local untracked="^\?\?"

	local grepstates=( ahead behind deleted modified newfile renamed staged untracked )
	local statestring=( "$ahead" "$behind" "$deleted" "$modified" "$newfile" "$renamed" "$staged" "$untracked" )

	case $1 in
		all)
			local gs=$(git status -sb)
			local i
			local val
			for (( i = 0; i < ${#grepstates[@]}; i++ )); do
				val=
				if echo "$gs" | egrep -q "${statestring[i]}"; then
					val="true"
				fi
				eval "export _pgs_${grepstates[i]}=$val"
			done

			# non-grepping statuses
			_pgs_onremote=
			[ "$showremotestate" = "y" ] && [ -n "$(git branch -r --list */$(__parse_git_branch))" ] && _pgs_onremote=true
			export _pgs_onremote

			# should this be an option?
			# _pgs_tracking=
			# [ "$showtrackingstatus" = "y" ] && git config branch.$(__parse_git_branch).remote >/dev/null && _pgs_tracking=true
			# export _pgs_tracking

			return 0
			;;

		# the vast majority of states can be grepped directly
		ahead | behind | deleted | modified | newfile | renamed | staged | untracked)
			eval "searchstr=$"$1;;

		clean)
			! git status -sb 2>/dev/null | egrep -q '^[^#]'  2>/dev/null
			return $?
			;;

		# is a version of this branch on the remote?
		onremote)
			[ -n "$(git branch -r --list */$(__parse_git_branch))" ]
			return $?
			;;

		tracking)
			git config branch.$(__parse_git_branch).remote >/dev/null
			return $?
			;;

		*)
			__gslog "__parse_git_status: Invalid parameter given  <$1>"
			return 1
			;;
	esac

	# use the return value of the grep as the return value of the function
	git status -sb 2> /dev/null | egrep -q "$searchstr" 2> /dev/null
}
