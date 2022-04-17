#!/bin/ash

list_pkgs() {
  opkg list-installed | cut -f 1 -d " "
}

show_deps() {
  opkg depends $1 | sed -e 1d -e 's/^\s*//'
}

if [ $(id -u) != 0 ]; then
  echo 'you must be root.'
  exit 1
fi

TMPDIR=/tmp/$$
if [ -d $TMPDIR ]; then
  rm -rf $TMPDIR
fi
mkdir $TMPDIR

trap "rm -rf $TMPDIR; exit 1" 1 2 3 15

# listup default packages
echo "entware-opt" > $TMPDIR/defaults
show_deps entware-opt >> $TMPDIR/defaults

# listup installed, but not default
touch $TMPDIR/pkgs_not_default
mkdir $TMPDIR/deps
for p in $(list_pkgs); do
  egrep "^$p\$" $TMPDIR/defaults > /dev/null
  if [ $? != 0 ]; then
    echo $p >> $TMPDIR/pkgs_not_default
    # listup depends
    show_deps $p > $TMPDIR/deps/$p.deps
  fi
done

# listup not depended by any others from not defaults
for p in $(cat $TMPDIR/pkgs_not_default); do
  egrep "^$p\$" $TMPDIR/deps/* > /dev/null
  if [ $? != 0 ]; then
    echo $p
  fi
done

rm -rf $TMPDIR

exit 0
