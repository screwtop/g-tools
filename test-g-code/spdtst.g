; Made using CamBam - http://www.cambam.info
; SpdTst 10/8/2015 8:46:03 PM
; T101 : 21.93
G21 G90 G64 G40
G0 Z15.0
; T101 : 21.93
T101 M6
; Engrave1
G17
M3 S3
G0 X0.0 Y50.0
G0 Z1.0
G1 F300.0 Z-1.0
G1 F4800.0 Y-50.0
G3 X25.0 I12.5 J0.0
; Engrave2
S3
G0 Z15.0
G0 Y50.0
G0 Z1.0
G1 F300.0 Z-2.0
G1 F4800.0 Y-50.0
G0 Z15.0
G0 Y50.0
G0 Z-1.0
G1 F300.0 Z-2.0
G2 F4800.0 X50.0 I12.5 J0.0
; Engrave3
S3
G1 F300.0 Z-3.0
G1 F4800.0 Y-50.0
G3 X75.0 I12.5 J0.0
; Engrave4
S3
G0 Z15.0
G0 Y50.0
G0 Z1.0
G1 F300.0 Z-4.0
G1 F4800.0 Y-50.0
G0 Z15.0
M5
M30
