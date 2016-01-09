; G-code for helping figure out the RZNC-0501 controller mainboard (so we can interface with it)
; NOT intended to be run on an actual machine!  Just disembodied mainboard and hand-held controller.
; CME 2015-11-01


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


G4 P2000

; Make sure the spindle is on:
M3

S1
G4 P2000
S2
G4 P2000
S3
G4 P2000
S4
G4 P2000
S5
G4 P2000
S6
G4 P2000
S7
G4 P2000

; Speed grades only go up to 7 cos 0 is stopped.


; IIRC, M5 doesn't stop the spindle!
M5
P2000
S0
P2000


; Now for some motion:

G1 F300
X10
X0
Y10
Y0
Z10
Z0

; End
M2
