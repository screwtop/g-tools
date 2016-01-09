; G-code for testing spindle speed response and spin-up/-down timing
; CME 2015-10-07

; grep --invert-match ';.*' rpmtest.g | grep --invert-match '^$' > /mnt/ufd/rpmtest.g

; The VFD speed levels from the factory were what I would have programmed in anyway:
; 7=24k, 6=21k, 5=18k, 4=15k, 3=12k, 2=9k, 1=6k
; i.e. RPM = (speed + 1) * 3000

; NOTE: it seems my controller will spin up the spindle even before any M3 command?!  It will also insert a delay for spin-up (configurable in the controller setup).  BTW, I don't think the default 4 s is enough to allow it to reach full speed!  TODO: [ ] see if our postprocessor could include a suitable G4 Dwell after any spindle speed change.
; Also, it seems M5 does NOT stop the spindle motor on my controller.  Some machines apparently have a spindle speed override (presumably to avoid crashing the machine into the workpiece due to a forgotten M3 Spindle Start.  The Baileigh docs mention a "Line State when Spindle is off" setting, under "Input Spindle st 8e number", whatever that means.  This seems to be a 3-bit binary number, which I'm guessing might correspond to the default spindle speed grade (when no speed otherwise selected).  The default (on the Baileigh) is 8.  This could explain why it spins up at startup and why it doesn't spin down on M5 Spindle Stop.
; Ah: reading the DSPC-04 manual, it appears that the "spindle state number" setting is not the spindle state to use by default, it's actually the number of spindle states supported by the attached VFD!  You then get to set up the high-low pattern for the control lines for each of the states (depending on how many you set).  Nevertheless, M5 by itself clearly does NOT stop the spindle motor.  Could that be because speed grade 1 is programmed for a non-zero speed on the VFD?


; Do we need to home first?  Set co-ordinates, etc.?

; Unit = mm
G21

; Absolute distance mode (cf. G91, which is incremental):
G90
; Note that there is a G90.1 and G91.1 available for abs/inc arc mode!

; Path blending: best speed possible:
G64

; Disable cutter compensation:
G40

; Set default plane to X-Y:
G17

; Set spindle speed mode to RPM (cf. Constant Surface Speed):
G97

; OK, that's it for the preamble!


; Let's make the first speed command non-zero, just to make sure it's happening.
M3 S1
G4 P5000
; Yep; it's already spinning at full speed, and ramps down to speed grade 1.

; Does M5 actually stop the spindle, with a non-zero default spindle speed?
M5
G4 P5000
; No, it does not!

; Restart the spindle so we can detect following changes:
M3 S1
G4 P5000

; Check whether a spindle-speed of 0 causes the spindle to spin at all:
; M3 = start spindle clockwise
M3 S0
; Oh, note that S is actually a separate command, not a parameter of M3!  Probably reasonable to put both on one line, though.
; That does actually stop the spindle motor.

; Pause (dwell) a bit to give it time:
;G4 P5
;G4 S5
G4 P5000
; Hmm, "G4 P5" didn't seem to cause any wait.  Perhaps P is being treated as milliseconds, and we should be using S...TODO: try that. :)
; No, S5 didn't seem to pause either.  Perhaps we can only use P as milliseconds.  Note that the Baileigh docs note that the spindle spin-up delay setting is in milliseconds, so maybe the G4 Dwell parameter is too.

; Stop the spindle and pause for it to spin down (if it had event started up!):
M5 S0
G4 P10000


; Now the speed grade tests...

; Start spindle, spinning clockwise, speed 1:
M3 S1
G4 P5000
S0
G4 P5000

; The same, for speed 2:
M3 S2
G4 P5000
S0
G4 P5000

; Speed 3:
M3 S3
G4 P5000
S0
G4 P5000

; Speed 4:
M3 S4
G4 P5000
S0
G4 P5000

; Speed 5:
M3 S5
G4 P5000
S0
G4 P5000

; I'll skip 6 and 7 for now...

; End of program.  M2 should also stop the spindle, of course.  There's also M0, apparently, although that might be better considered Pause.
M2
; I see M30 also used, for production work where you want to load the next stock automatically.

