#!/bin/sh

TARGET=/usr/local/bin

sudo cp -v g-copy.sh $TARGET/g-copy
sudo cp -v g-dis.tcl $TARGET/g-dis
sudo cp -v g-split.tcl $TARGET/g-split
sudo cp -v g-stats.tcl $TARGET/g-stats
sudo cp -v g-strip.tcl $TARGET/g-strip
sudo cp -v g-rect.tcl $TARGET/g-rect

sudo chmod 775 $TARGET/g-*
