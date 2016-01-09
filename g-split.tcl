#!/usr/bin/env tclsh

# Quick and dirty tool for splitting a large G-Code file into smaller chunks. Nothing fancy like geometric splitting or even splitting by size/line setting or number of output files - I just want something to get some large v-carve scripts into manageable chunks (my router controller seems to have a 64 MiB limit on G-Code).  The important thing is to add a header and footer to each output file, name them, and make sure the splits don't affect the resulting movement (e.g. split on Z-lifts and perhaps add an extra X,Y move) - this is why we don't just use `split`!

# Currently we blithely assume no more than 99 output files.

# Will accept output basename and suffix on the command line though.  Maybe approximate (minimum would be easiest) lines per output file.  Easy enough though to just modify the settings in this script directly, heh.


set Debugging false

set basename out
set suffix .ngc
set line_limit 500000
set safe_z_height 4
set default_feedrate 1234

set header "G21
G90
G64 P0.001
G40
G17
M3 S3
G0 Z${safe_z_height}
"

set footer "G0 Z${safe_z_height}
M5
M2
"
# TODO: The G0 Z4 is probably redundant there.


# TODO: factor out patterns and other comment-related code for re-use.
if {$Debugging} {puts "argv=\"$argv\""}

#set source_filename [lindex $argv 0]
#set basename [lindex $argv 1]
#set 

if {[llength $argv] != 4} {
	puts stderr "Usage: g-split input_filename num_lines output_basename output_suffix"
	exit
}
lassign $argv source_filename line_limit basename suffix


# No pipeline support: have to read from a true file:
set input_stream [open $source_filename r]


puts stderr "Splitting \"$source_filename\"..."

# Variables that need to be defined before processing the file:
set ::file_count 0
set ::line_count 0
set ::abs_line_count 0
#set z_lift_count 0
set ::last_feedrate $default_feedrate

# No, leave these unset:
#set last_x
#set last_y

# These however need to be set so that the first call to start_new_file works:
set line {}
set last_line {}

# This is called each time we create a new output file:
proc start_new_file {} {
	# Write footer to old (current) file:
	catch  {
		# The catch is just a lazy way of getting the first invocation to run cleanly when there is no output stream yet.
		# Don't need to duplicate the last two lines - they'll have been written anyway as part of normal copying.
		# This won't get called on the very last output file (which will already have the endgame G-Code) as start_new_file won't be called then.
	#	puts $::output_stream $::last_line
	#	puts $::output_stream $::line
		puts $::output_stream $::footer
		close $::output_stream
	}
	incr ::file_count
	set ::line_count 0
#	puts "file_count = $::file_count"
	set new_filename "${::basename}[format %02i ${::file_count}]${::suffix}"
	puts "Writing \"$new_filename\" from input line $::abs_line_count"
	set ::output_stream [open $new_filename w]
	# Write header and the initial positioning moves (the last two lines of the input) to the new file (but not the first output file, as it should already have that stuff):
	if {$::file_count > 1} {
		puts $::output_stream $::header
		# nject feedrate. F (and S) are modal, so it should be fine to issue them separately from G1.
		puts $::output_stream "F$::last_feedrate"
	#	puts $::output_stream "$::last_line ( last_line )"
	#	puts $::output_stream "$::line ( line )"
	}
}


start_new_file

# Main loop: process the input file and copy the lines to the output, starting a new output file every $line_limit lines (approximately - we split at Z-lifts to avoid mess).
while {true} {
	set line [gets $input_stream]
	if {[eof $input_stream]} {
		close $input_stream
		# No need for footer here: the last file doesn't need an extra one!
	#	puts $::output_stream $::footer
		close $::output_stream
		break
	}

	# Check line number and start a new output file if possible.  We'll need to look for a G0 with Z something positive.  Actually, maybe we don't need to store the original code: we can just generate a new G0 Zwhatever G0 Xn Yn.  However we did it, we'd have to keep a record of recent line data.  Though maybe avoiding several regexps per line would be good for efficiency - simply store the last line and only look for matching patterns if we've reached the line limit.

	# If the line contains a feedrate, make a note of it in case we need to start a new file:
	regexp -nocase "F(\[0-9\.\]+)" $line entire_match ::last_feedrate

	if {$line_count >= $line_limit} {
		# Look for a good point to split (Z-lift):
		if {[regexp -nocase "G0 .*Z(\[0-9\.\]+)" $line entire_match last_z]} {
			# Get X and Y from current line:
		#	regexp -nocase "G0 .*X(\[-0-9\.\]+)" $line entire_match last_x]
		#	regexp -nocase "G0 .*Y(\[-0-9\.\]+)" $line entire_match last_y]
			# Or just copy the lines verbatim, why not?!  Or, even better, have that done by start_new_file?
			start_new_file
		#	puts $::output_stream $::la
		}
		# otherwise still looking...hopefully won't be too far away!
	}

	# Otherwise, just copy input line to output:
	puts $::output_stream $line

	# Keep a copy of the last line, for cleaner splitting on Z-lifts:
	set prev_line $line

#	if {$Debugging} {puts stderr "\"$last_x $last_y\""}
	incr line_count
	incr abs_line_count
}

