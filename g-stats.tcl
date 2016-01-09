#!/usr/bin/env tclsh

# Report simple G-Code statistics:
# - dimensions of the machining extent (what about arcs?!)
# - maybe start and end points
# - number of (non-comment) lines
# - number of Z-lifts (identified by going above 0? 3D printer jobs wouldbe different, though.)
# - rough estimate of total distance travelled? time?

set Debugging false

set ::varnames {line_count x_min x_max x_total y_min y_max y_total z_min z_max z_total z_lift_count}

# TODO: factor out patterns and other comment-related code for re-use.
if {$Debugging} {puts "argv=\"$argv\""}

set source_filename [lindex $argv 0]

if {$source_filename ne ""} {
	# open it, and use instead of stdin
	set Input_Stream [open $source_filename r]
} else {
	set Input_Stream stdin
}

# Q: Does this make more fasterer?
chan configure $Input_Stream -buffering full -buffersize 524288
# A: 1:56 first time, 1:57 primed buffers, 1:57 buffering above added.  So not much point. ;)

proc report_variable {varname} {
	global $varname
	if {[info exists $varname]} {
		puts "$varname = [set $varname]"
	} else {
		puts "$varname undefined"
	}
}

proc report {} {
	global {*}$::varnames
	# TODO: and others

	catch {set x_total [expr {$x_max - $x_min}]}
	catch {set y_total [expr {$y_max - $y_min}]}
	catch {set z_total [expr {$z_max - $z_min}]}
	foreach varname $::varnames {
		report_variable $varname
	}
}

puts stderr "Working..."

set line_count 0
set z_lift_count 0

while {true} {
	set line [gets $Input_Stream]
	if {[eof $Input_Stream]} {
		close $Input_Stream
		break
	}
	if {$Debugging} {puts -nonewline stderr "\"$line\" -> "}

	# Update max/min for each axis (if exceeded):
	foreach axis {x y z} {
		if {[regexp -nocase "G1 .*${axis}(\[-0-9\.\]+)" $line entire_match $axis]} {
			if {[info exists ${axis}_max]} {
				if {[set $axis] > [set ${axis}_max]} {set ${axis}_max [set $axis]}
			} else {
				set ${axis}_max [set $axis]
			}
			if {[info exists ${axis}_min]} {
				if {[set $axis] < [set ${axis}_min]} {set ${axis}_min [set $axis]}
			} else {
				set ${axis}_min [set $axis]
			}
		}
	}

	# Count z-lifts (note that we sometimes see negative zero!):
	if {[regexp -nocase "G0 .*X(\[-0-9\.\]+)" $line entire_match $axis]} {
	}

	if {$Debugging} {puts stderr "\"$line\""}
	incr line_count
}

report

