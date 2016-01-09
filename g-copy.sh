#!/bin/sh

# Utility to do all the shenanigans to copy a G-Code file to my USB flash drive.
# Wow, we're almost looking like a CNC production outfit!

# TODO: check #args
# TDOO: mount such that $USER can write.
# TODO: maybe support copying multiple files at a time?  Bit tedious otherwise - the `eject` means you have to replug the UFD to have it appear.

#echo $USER
MOUNTPOINT=/mnt/ufd
TARGET="$MOUNTPOINT/$2"

# Makes sense to have a single command to copy a G-Code file 
echo Mounting drive...
sudo mount -o umask=000 /dev/disk/by-label/CNC "$MOUNTPOINT"
# cp -v -p ...
# Or, better, use my g-strip utility...
echo Stripping...
g-strip < "$1" > "$TARGET"

# TODO: split, if necessary?  Optionally?  Need to get g-split injecting feedrates first, though!

# Show quick preview of code
head -n 12 "$TARGET"
tail -n 12 "$TARGET"
# Oh, do g-stats analysis too!
echo Analysing...
# ...
g-stats < "$TARGET"

# Um, if splitting, maybe analysis should take place on each output file.
# ...

echo Syncing...
sync

echo Unmounting...
sudo umount /mnt/ufd
echo Ejecting...
sudo eject /dev/disk/by-label/CNC
echo Done!

