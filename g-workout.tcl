#!/usr/bin/env tclsh

# Generate some motion tests for CNC machine. I'm gettng occasional skipping of at least one stepper motor and I'd like to troubleshoot further.
# Not sure whether to make the moves all relative so the operator can set the starting point, or home the machine first and operate in absolute co-ordinates.
# NOTE: probably wise to home and zero all axes before running this!

# Machine settings (note: negative value for Z would be typical for routers and mills):
array set extent {X 600 Y 900 Z -100}

# Move + and - around the initial point, or just away from home and then return?
set bipolar_motion false
set starting_step_size 0.07

# Acceleration will often prevent reaching these maxima:
set ::max_feed_rate 4800
set ::max_plunge_rate 900

set pause_time 500	;# On some controllers, the P parameter is ms, in others, seconds!

# Preamble includes spindle spinup in case it's run on a real machine!
# No need to include X0 Y0
# Don't need the spindle to be running.  On my router, you have to explicitly set S0 to stop it.
set preamble "G21
G90
G64 P0.001
G40
G17
M5
M3 S0
G28
F${::max_feed_rate}
G0 X0 Y0 Z0
"


# Is "postamble" even a word?!

set postamble {
M2
}

proc repeat {times script} {
	for {set i 0} {$i < $times} {incr i} {
	uplevel 1 $script
	}
}

proc sgn x {expr {$x<0? -1: $x>0}}	;# RS

# Increase step by some amount. Linear is probably not very useful; I think perhaps double every time, or maybe multiply by some constant between 1 and 2.
# TODO: maybe have it so you can specify the number of steps, and have it divide that down from the axis extent.
proc increase {varname} {
	upvar $varname val
	set val [expr {$val * 2.0}]
}


puts $preamble

if {$bipolar_motion} {
	# Move to the centre of the machine. We've just homed, so Z will be at full height, so it's fine to lower that last.
	foreach axis {X Y Z} {
		set midpoint [expr {$extent($axis) / 2.0}]
		puts "G1 ${axis}${midpoint}"
	}
}

if {$bipolar_motion} {
	# Move + and - about the midpoint for the axis:
	foreach axis {X Y Z} {
		set midpoint [expr {$extent($axis) / 2.0}]
		# TODO: maybe start with very small movements (like, fractions of a mm) and work up exponentially to larger sizes.
		for {set step $starting_step_size} {$step < [expr {$extent($axis) / 2.0}]} {increase step} {
			repeat 4 {
				# Midpoint-based motion:
				puts "G1 ${axis}[expr {$midpoint + $step}]"
				puts "G1 ${axis}[expr {$midpoint - $step}]"
			}
			# Return to midpoint:
			puts "G1 ${axis}${midpoint}"
			puts "G4 P$pause_time"
		}
		puts "G4 P$pause_time"
	}
} else {
	# Unipolar motion:
	foreach axis {X Y Z} {
		set direction [sgn $extent($axis)] ;# since Z moves are usually negative from home
		set abs_extent [expr {abs($extent($axis))}]
		if {$axis eq "Z"} {puts "F${::max_plunge_rate}"}
		# TODO: maybe start with very small movements (like, fractions of a mm) and work up exponentially to larger sizes.
		for {set step $starting_step_size} {$step < $abs_extent} {increase step} {
			repeat 2 {
				puts "G1 ${axis}[format {%02.4f} [expr {$step * $direction}]]"
				puts "G1 ${axis}0.00"
			}
			puts "G4 P$pause_time"
		}
		puts "G4 P$pause_time"
	}
}

puts $postamble

exit

