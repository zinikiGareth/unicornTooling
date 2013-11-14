#!/bin/bash -e

if [ $# -lt 2 ] ; then
  echo "Usage: compileAll.sh <rootdir> <distdir>" >&2
  exit 1
fi

ROOTDIR=$1
if [ ! -d "$ROOTDIR" ] ; then
  echo "There is no directory $ROOTDIR" >&2
  exit 1
fi
DISTDIR=$2
if [ ! -d "`dirname $DISTDIR`" ] ; then
  echo "There is no base for directory $DISTDIR" >&2
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

# rm -rf $DISTDIR
if [ ! -d $DISTDIR ] ; then
  mkdir $DISTDIR
fi

cp $ROOTDIR/index.html $ROOTDIR/unicornSandbox.html $DISTDIR
cp -r $ROOTDIR/vendor $DISTDIR

compileOne() {
  DIST=$DISTDIR
  FROM=$ROOTDIR
  if [ $# -ge 2 ] ; then
    if [ ! -d "$FROM/$2" ] ; then
      echo "There is no directory $FROM/$2"
      return
    fi
    FROM="$FROM/$2"
    DIST="$DIST/$2"
  fi

  if [ ! -d "$FROM/$1" ] ; then
    echo "There is no directory $FROM/$1"
    return
  fi
  echo "Transpiling files in $FROM/$1 ..."
  mkdir -p $DIST/`dirname $1`
  (
    cd $FROM/$1
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
  ) > "$DIST/$1-amd.js"
}

compile() {
  for n in "$@" ; do
    compileOne $n
  done
}

(compileOne unicornlib vendor)
# (compileOne archetypes vendor)
compile \
  contract \
  envelope \
  container \
  unicorn/receipt/whotels/expense/member \
  unicorn/expenseReport/basic

kill $NODETS $NODEHB

exit 0
