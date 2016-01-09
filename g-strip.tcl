#!/usr/bin/env tclsh

# Strip extraneous code from G-code via stdin/out or input/output files.

# TODO: some option flags on the command line (e.g. whether to strip whitespace within blocks or normalise to a single space).

set Debugging false

# TODO: factor out patterns and other comment-related code for re-use.
if {$Debugging} {puts "argv=\"$argv\""}

set source_filename [lindex $argv 0]
set target_filename [lindex $argv 1]
# TODO: print usage if too many args

if {$source_filename ne ""} {
	# open it, and use instead of stdin
	set Input_Stream [open $source_filename r]
} else {
	set Input_Stream stdin
}

if {$target_filename ne ""} {
	# open it for writing, instead of stdout
	set Output_Stream [open $target_filename w]
} else {
	set Output_Stream stdout
}


while {true} {
	set line [gets $Input_Stream]
	if {[eof $Input_Stream]} {
		close $Input_Stream
		break
	}
	if {$Debugging} {puts -nonewline stderr "\"$line\" -> "}
	# Remove comments.  The syntax varies somewhat for these, but parentheses seem to be the "most official".
	set line [regsub -all {\(.*\)} $line ""]
	# "#" is definitely not: it can be used for formulae.
	# ";" and "%" seem fairly common. Currently this also strips G-code blocks disabled with "/".
	set line [regsub -all {[;%/].*$} $line ""]
	# TODO: normalise case?
	# Normalise or strip whitespace?  Line-breaks should be preserved, as they define blocks.
	set line [regsub -all {[	 ]+} $line " "]
	if {$Debugging} {puts stderr "\"$line\""}
	if {$line eq ""} {continue}
	puts $Output_Stream $line
}

close $Output_Stream

