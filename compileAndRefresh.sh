#!/bin/sh

`dirname $0`/compileAll.sh "$@"
if [ $? -ne 0 ] ; then
  exit 1
fi
sleep 1

OSA=`which osascript`
if [ -x $OSA ] ; then
$OSA << HERE
tell application "Google Chrome"
  reload active tab of window 1
    activate
    end tell
HERE
fi

exit 0
