#!/bin/bash

if [ $# -lt 1 ] ; then
  echo "Usage: compileAll.sh <rootdir>" >&2
  exit 1
fi

ROOTDIR=$1
if [ ! -d "$ROOTDIR" ] ; then
  echo "There is no directory $ROOTDIR" >&2
  exit 1
fi

dir=`dirname $0`
if [ -z "$NODE_BIN" ] ; then
  NODE_BIN=node
fi

$NODE_BIN $dir/transpilerServer &
NODETS=$!
$NODE_BIN $dir/handlebarsServer &
NODEHB=$!
sleep 1

cd $ROOTDIR
# rm -rf dist
# mkdir dist

cp index.html unicornSandbox.html dist
cp -r vendor dist

compileOne() {
  DIST=`pwd`/dist
  if [ $# -ge 2 ] ; then
    if [ ! -d "$2" ] ; then
      echo "There is no directory $2"
      return
    fi
    cd "$2"
    DIST="$DIST/$2"
  fi

  if [ ! -d "$1" ] ; then
    echo "There is no directory $1"
    return
  fi
  echo "Transpiling files in $1 ..."
  (
    cd $1
    for f in `find . -name '*.js'` ; do
      mn=`echo $f | sed -e 's%\./%%' -e 's%\.js%%'`
      curl -s "-HX-Module-Name:$1/$mn" --data-binary "@$f" localhost:10061
      echo ""
    done
    for f in `find . -name '*.handlebars'` ; do
      mn=`echo $f | sed -e 's%\./%%' -e 's%\.handlebars%%'`
      curl -s "-HX-Module-Name:$1/$mn" --data-binary "@$f" localhost:10062
      echo ""
    done
  ) > $DIST/`basename $1`-amd.js
}

compile() {
  for n in "$@" ; do
    compileOne $n
  done
}

(compileOne unicornlib vendor)
compile \
  archetypes \
  contract \
  container \
  unicorn/receipt/whotels/expense/member

kill $NODETS $NODEHB

exit 0
