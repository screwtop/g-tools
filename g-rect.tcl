#!/usr/bin/env tclsh

# Tcl script to generate a centred rectangular toolpath, CME 2016-01-02

# I'm doing this cos F-Engrave can become busy and unresponsive for minutes at a time when dealing with complex drawings, but checking the bounding box extent only requires loading the DXF file.

# TODO: get these from the command line args:
if {$argc != 2} {
	puts stderr "args: g-rect width height (dimensions in mm)"
	exit
}
set width [lindex $argv 0]
set height [lindex $argv 1]

# TODO: maybe add Z height as command line arg:
set ::z_height 0
set ::safe_z_height 20
set ::feed_rate 4800
set ::plunge_rate 1200


# Preamble includes spindle spinup in case it's run on a real machine!
# No need to include X0 Y0
set preamble {G21
G90
G64 P0.001
G40
G17
M3 S3
}


# Is "postamble" even a word?!

set postamble {
M5
M2
}

# TODO: get width and height from command-line arguments...

proc rect {width height} {
	set x [expr {$width / 2.0}]
	set y [expr {$height / 2.0}]
	set result [list]
	lappend result "G0 X0 Y${y} Z${::safe_z_height}"
	lappend result "G1 Z${::z_height} F${::plunge_rate}"

	lappend result "G1 X${x} F${::feed_rate}"
	lappend result "G1 Y-${y}"
	lappend result "G1 X-${x}"
	lappend result "G1 Y${y}"

	lappend result "G1 X0"

	lappend result "G0 Z${::safe_z_height}"

	return $result
}

puts $preamble
foreach line [rect $width $height] {
	puts $line
}
puts $postamble

exit

