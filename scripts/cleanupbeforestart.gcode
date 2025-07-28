; ==========================================================
; Advanced Nozzle Wipe Start G-code
; For PrusaSlicer, SuperSlicer, or compatible
; ==========================================================
;
; SAFETY WARNING: This script moves to X=205.
; Make sure your printers build plate is wide enough.
; For an Ender 3 at 235mm wide, this is safe.
; For a Prusa Mini at 180mm wide, this will crash.
; Adjust the X values below if needed.

G90 ; Use absolute coordinates
G21 ; Set units to millimeters
M82 ; Set extruder to absolute mode

G28 ; Home all axes

; --- Heat up and wait using expression syntax ---
; The curly braces are required to access vector elements like the first extruder.
M190 S{first_layer_bed_temperature[0]} ; Set bed temp and wait
M109 S{first_layer_temperature[0]}     ; Set nozzle temp and wait

; --- Start the purge and wipe process ---
G1 Z0.3 F3000 ; Move nozzle to a safe height above the bed

M83 ; Set extruder to RELATIVE mode for the purge lines
G92 E0.0 ; Reset extruder

; --- Draw the two thick purge lines ---
G1 Y1.0 F3000 ; Move to the front of the bed
G1 X205.0 E19.0 F1000 ; Draw line 1 left to right, extruding 19mm
G1 Y1.6 F5000 ; Move over for the second line
G1 X5.0 E19.0 F1000  ; Draw line 2 right to left, extruding another 19mm

; --- Draw the final, precise intro line ---
M82 ; Set extruder back to ABSOLUTE mode for the rest of the print
G92 E0.0 ; Reset extruder position to 0

; Move to the start of the intro line.
; first_layer_height is a scalar value.
G1 Y2.0 Z{first_layer_height} F1000
G1 X65.0 E9.0 F1000   ; Draw a short, clean line
G1 X105.0 E12.5 F1000 ; Continue and taper the line to stabilize pressure

; --- Final prep for the print ---
G92 E0.0 ; Reset extruder one last time before the print starts
G1 Z2.0 F3000 ; Move Z up slightly to avoid leaving a blob