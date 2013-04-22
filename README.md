A series of shell scripts that simplify and streamline the use of Git. Works across all major OSes (Win/Mac/Linux).

GitScripts gains you:

1. Indicator flags on your shell that let you know if you are ahead of/behind the remote etc
1. Simplified commands and automation for common, often complex, tasks (commit, status, merge, checkout, branch creation, etc)
1. Ability to enforce branch protection (ie. Never allow merge from QA to Dev, or Dev to master, etc)
1. A more colorful prompt

GitScripts does not replace Git. It's kind of a wrapper for Git, or more, an extension to Git's built in shell scripts. If you install GitScripts, you can still access all of your git commands exactly the same way you used to. However, now you have an extra library of commands at your disposal.

# Installation

Clone down the repo somewhere on your machine:

    git clone git://github.com/cmcculloh/GitScripts.git

Modify your .bash_profile or .bashrc file. One of these should be in your home (~/) directory. If not, just create one (flip a coin to decide which ;) ). Add the following line to the file:

	source [path to your local version of the GitScripts repo]/_gsinit.sh

So, if your local GitScripts repo is in ~/Dev/GitScripts, the line would look like this:

	source ~/Dev/GitScripts/_gsinit.sh

Restart your terminal, BAM! your DONE!


### Configuration Notes

GitScripts comes with some intelligent defaults, so, this is for those that are just not satisfied with defaults.

Any config adjustments you want to make should be made in a file that you create:

    cp cfg/user.overrides.example cfg/user.overrides

This file is ignored by default, so, mod away!



### GSMAN

GitScripts comes with a nifty little used documentation center called "gsman".

In order to use this system, just type "gsman " followed by any command you'd like to know more about; example:

    gsman commit

Before you can actually *use* this system, you have to configure it, by issuing the following command from your terminal:

    gsman gsman



# Usage

GitScripts helps make git more user friendly and more user safe. It is a set of bash scripts that will make your life much easier and streamline your use of Git.


### Status

The most basic example is as follows. To see which files have changes, you would normally type:

    git status

With GitScripts you can just do:

	status


### Commit

Say you have changes to 5 tracked files that you want to commit. Normally you would have to do the following:

	git commit -a -m "my comments on my changes"

With GitScripts you can just do:

	commit "my comments on my changes" -a


I know, these doesn't seem much different. But it *did* save just a little bit of time. Two paper cuts (in a world of Windows, that's two paper cuts less in the death by a thousand paper cuts that you suffer every day).


### New Branch

Here's where the real magic happens though. Let's say you want to create a new branch. Normally you would have to do all of the following (if being safe):

	git status
	git stash (or) git add -A, git commit -m "your commit"
	git push origin branch
	git checkout master
	git fetch --all --prune
	git checkout -b newbranch


Whew! OK, with gitscripts, you just do:

	new branch from branch


That's it. It jumps into an intelligent guided numeric menu driven process that does everything that you would normally have to do by hand with nominal intervention from you only when absolutely necessary with intelligent defaults so that 90% of the time you are just hitting "Enter".


### Merge

Let's say you want to merge two branches. Normally you would have to do all of the following (if being safe):

	git status
	git stash (or) git add -A, git commit -m "your commit"
	git push origin branch
	git fetch --all --prune
	git checkout branchtomergefrom
	git pull origin branchtomergefrom
	git checkout branchtomergeto
	git pull origin branchtomergeto
	git merge branchtomergefrom
	git add .
	git commit -m "merging branchtomergefrom"
	git push origin branchtomergeto

Yikes! Again, GitScripts to the rescue! Here's what you would do in GitScripts:

	merge branchtomergefrom into branchtomergeto


:D


