#!/bin/sh -e
GERNERAL_BIN=`pwd`/axerabin/tools/bin
image=$1

blkdevparts="
768K(spl)
512K(ddrinit)
256K(atf)
256K(atf_b)
1536K(uboot)
1536K(uboot_b)
1M(env)
6M(logo)
6M(logo_b)
1M(optee)
1M(optee_b)
1M(dtb)
1M(dtb_b)
64M(kernel)
64M(kernel_b)"

[ "X$image" != "X" ] || exit 1
[ -e $image ] || exit 1

base=$(dirname $image)/$(basename $image | cut -d '.' -f 1)
loader=$base-loader.bin

o=0
for part in $blkdevparts ; do
  s=$(echo $part | cut -d '(' -f 1)
  if echo $s | grep -q M ; then
    k=$(echo $s | sed s/'M$'/''/g)
    k=$(($k * 1024))
  else
    k=$(echo $s | sed s/'K$'/''/g)
  fi
  o=$(($o + k))
done

echo 0 $o $(basename $loader)
if file $image | grep -q 'XZ compressed' ; then
  xz -cd $image | dd of=$loader bs=1024 count=$o
else
  dd if=$image of=$loader bs=1024 count=$o
fi

mkdir -p $base-dump

o=0
for part in $blkdevparts ; do
  s=$(echo $part | cut -d '(' -f 1)
  n=$(echo $part | cut -d '(' -f 2 | cut -d ')' -f 1)
  if echo $s | grep -q M ; then
    k=$(echo $s | sed s/'M$'/''/g)
    k=$(($k * 1024))
  else
    k=$(echo $s | sed s/'K$'/''/g)
  fi
  echo $o $k $n.bin
  f=$base-dump/$n.bin
  dd if=$loader of=$f bs=1024 skip=$o count=$k | true
  if echo $n | grep -q -E '^env|^logo' ; then
    if file $f | grep -q 'PC bitmap' ; then
      a=$(hexdump -s 2 -n 4 -e '"%d"' $f)
      b=$(($k * 1024))
      if [ $a -le $b ]; then
        echo copy $a bytes
        dd if=$f of=$f.unpacked bs=1 count=$a
      else
        echo copy
        cp -p $f $f.unpacked
      fi
    else
      echo copy
      cp -p $f $f.unpacked
    fi
  else
    a=$(hexdump -s 12 -n 4 -e '"%d"' $f)
    b=$(($k * 1024))
    if [ $a -le $b ]; then
      echo unsign $a bytes
      dd if=$f of=$f.unsigned bs=1 skip=1024 count=$a
    else
      echo unsign
      dd if=$f of=$f.unsigned bs=1024 skip=1
    fi
    if echo $n | grep -q -E '^fdl|^ddrinit|^spl' ; then
      mv $f.unsigned $f.unpacked
    else
      echo unpack
      g=$base-dump/copy-of-$n.bin
      mv $f.unsigned $g.unsigned
      ${GERNERAL_BIN}/ax_gzip -d $g.unsigned
      mv $g $f.unpacked
      rm -f $g.unsigned*
    fi
  fi
  o=$(($o + k))
done
