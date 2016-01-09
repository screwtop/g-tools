( Smithy suggested preamble:)
(G17 G20 G40 G49 G54 G80 G90 G94)
(XY plane, inch mode, cancel diameter compensation, cancel length offset, coordinate system 1, cancel motion, non-incremental motion, feed/minute mode)

(The CamBam default is similar, though different order)

; Set default plane to X-Y:
G17

; Unit = mm
G21

; Absolute distance mode (cf. G91, which is incremental):
G90
; Note that there is a G90.1 and G91.1 available for abs/inc arc mode!

; Path blending:
G64 (best speed possible/constant velocity mode)
; G61 (exact stop mode)

; Disable cutter compensation:
G40

; Cancel (tool?) length offset:
G49

; Set co-ordinate system 1
G54

; Cancel modal motion (stop until given a move word)
G80

; Feed/minute mode
G94

; Set spindle speed mode to RPM (cf. Constant Surface Speed):
G97

; Stop spindle (my DSP controller always starts the spindle, apparently):
S0
