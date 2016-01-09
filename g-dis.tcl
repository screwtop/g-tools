#!/usr/bin/env tclsh

# Basic G-code disassembler, CME 2015-10-22
# Should this operate on a file or on stdin?

package require sqlite3
# Hmm, problems when using the database over NFS. :(  -vfs unix-dotfile? -readonly?
sqlite3 db g-code.sqlite3 -readonly true -vfs unix-dotfile

proc gcode_to_title {word address} {
	global db
	set sql "select Title from Code where Word = '${word}' and Address = '${address}'"
#	puts stderr $sql
	db eval $sql {return $Title}
}


# To normalise, convert to all caps, normalise letters to have a single space before them, then split on the spaces.  Then iterate and disassemble. Oh, note that G and M commands are normalised to 2 digits.

proc disassemble {line} {
	# TODO: factor out comment code/patterns for re-use in different programs.
	# Strip out comments first?  Comments can't be nested, and there must be at most one per line, at least.  Should comments be associated with blocks?
	regexp {\((.*)\)} $line entire_match comment
	# TODO: if ...
	set line [regsub {\(.*\)} $line ""]
	# TODO: regexp ...
	set line [regsub {;.*$} $line ""]
	if {$line eq ""} {return}
#	puts stderr "<<<$line>>>"
	# TODO: also recognise disabled g-code lines that use the leading "/" notation (optionally with number).  TODO: is that supported by my DSP controller?
	puts "{"
	foreach code [regsub -all "\[\t \]*(\[A-Za-z\])" $line { \1}] {
	#	puts "code = $code"
		# TODO: split word into separate letter and address
		regexp {([A-Za-z])([+-]?[0-9]*\.?[0-9]*)} $code entire_match word address
		set word [string toupper $word]
		# Hmm, what about decimal addresses?  Seems we need some conditionality here...
		catch {set address [format {%02i} $address]}
	#	puts "word = $word"
	#	puts "address = $address"
		# TODO: decode using database here
		puts "\t$code = [gcode_to_title $word $address]"
	}
	puts "}"
}



proc test {} {
	# Testing things:
	set line {G0 X100.00 Y-50.00 Z-1 F6000}
	set line {G0X100.00Y-50.00Z-1F6000}
	set preamble {G17 G21 G40 G49 G54 G80 G90 G94}

	disassemble $line
	disassemble $preamble
}
#test


# Process stdin:

while {true} {
	set line [gets stdin]
	if {[eof stdin]} {
		close stdin
		break
	}
	puts stderr "<<$line>>"
	# Check for comments and stuff that might otherwise break things...
	# It'd be kinda sensible to retain comments, actually.  Although, some comments could be attached to a specific G-code block, so should be recognisably attached to that block somehow in the output.
	# Blank lines similarly: if they're in the code, they might help break things up when reading.
	if {$line eq ""} {continue}
	disassemble $line
}

db close

