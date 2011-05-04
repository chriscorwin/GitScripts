#!/bin/sh

branch="master"
if [ -n $1 ] && [ "$1" != " " ] && [ "$1" != "" ]
    then
    branch=$1
fi

log1=$(git rev-parse --short $branch)
log2=$(git rev-parse --short HEAD)

echo About to run:
echo =========================
echo git difftool $log1..$log2
echo -------------------------
echo "Do it? (y) n "
read decision
if [ -z $decision ]
    then
    git difftool $log1..$log2
    exit 0
elif [ $decision = "y" ]
    then
    git difftool $log1..$log2
    exit 0
else
    echo Aborting...
    echo
    exit 1
fi




