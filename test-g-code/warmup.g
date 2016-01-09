( Warmup routine for my spindle. CME 2015-12-24 )
G21 G90 G64 G40 G17 G97
G0 Z0
G0 X0 Y0
M3 S1       (Spindle clockwise 6k RPM)
G4 P240000  (pause for 4 mins)
M3 S2       (9k RPM)
G4 P240000  (4-min pause)
M3 S3       (12k RPM)
G4 P240000  (4-min pause)
M5          (stop spindle)
M3 S0       (actually stop spindle)
M30
%

