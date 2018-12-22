<CsoundSynthesizer>
<CsInstruments>
; normalize to an arbitrary number of channels (1, 2, 4, 6, 8, 16, 32)
; with a resolution of 16, 24 or 32 bits integer
; force the SR=KR from the command line reading it from the sound file

; Command line (at best get the SR from the input file itself)
; GAIN: rescaled value in db (max = 0.0)
; RES: maximum amplitude for the given resolution
;		16bits = 32767, 24bits: 8388607, 32bits: 2147483647
; NCH: number of channels (1, 2, 4, 6, 8, 16, 32)
; in the command line: -s for 16bits, -3 for 24bits, -l for 32bits

; Ex: 24bits, 44100Hz, mono
; csound --omacro:GAIN=-6.0 --omacro:RES=8388607 --omacro:NCH=1 -isin441.aifc -3 -g  -R44100 -K44100 norm.csd

;NB: due to a bug in csound (int32 overflow?), the maximum duration of a file lies somewhere
;		between 9999 and 99999 secs.

; Marco Stroppa, based on work of Matt Ingalls und Karim Haddad
; 090203

ksmps = 1
nchnls = $NCH

0dbfs = $RES

instr 1

ipeak filepeak "-i"
print ipeak

igain = ampdbfs($GAIN)

if (ipeak == 0) then
	prints "WARNING: No peak data, cannot normalize!"
endif
print ipeak

isc = (ipeak == 0 ? 1.0 : igain/ipeak)

if (nchnls == 1) goto ch1
if (nchnls == 2) goto ch2
if (nchnls == 4) goto ch4
if (nchnls == 6) goto ch6
if (nchnls == 8) goto ch8
if (nchnls == 16) goto ch16
if (nchnls == 32) goto ch32
prints "Unknown number of channels!"
print nchnls
goto end

ch1:
a1	in
	outc	a1*isc
goto end

ch2:
a1, a2	ins
	outc	isc*a1, isc*a2
goto end

ch4:
a1, a2, a3, a4	inq
	outc	isc*a1, isc*a2, isc*a3, isc*a4
goto end

ch6:
a1, a2, a3, a4, a5, a6	inh
	outc	isc*a1, isc*a2, isc*a3, isc*a4, isc*a5, isc*a6
goto end

ch8:
a1, a2, a3, a4, a5, a6, a7, a8	ino
	outc	isc*a1, isc*a2, isc*a3, isc*a4, isc*a5, isc*a6, isc*a7, isc*a8
goto end

ch16:
a1, a2, a3, a4, a5, a6, a7, a8,	a9, a10, a11, a12, a13, a14, a15, a16	inx
	outc	isc*a1, isc*a2, isc*a3, isc*a4, isc*a5, isc*a6, isc*a7, isc*a8, \
			isc*a9, isc*a10, isc*a11, isc*a12, isc*a13, isc*a14, isc*a15, isc*a16
goto end

ch32:
a1, a2, a3, a4, a5, a6, a7, a8,	a9, a10, a11, a12, a13, a14, a15, a16, \
a17, a18, a19, a20, a21, a22, a23, a24,	a25, a26, a27, a28, a29, a30, a31, a32	in32
	outc	isc*a1, isc*a2, isc*a3, isc*a4, isc*a5, isc*a6, isc*a7, isc*a8, \
			isc*a9, isc*a10, isc*a11, isc*a12, isc*a13, isc*a14, isc*a15, isc*a16, \
			isc*a17, isc*a18, isc*a19, isc*a20, isc*a21, isc*a22, isc*a23, isc*a24, \
			isc*a25, isc*a26, isc*a27, isc*a28, isc*a29, isc*a30, isc*a31, isc*a32
end:
endin

; this instrument handles terminating the score
; add this to all effects that do not change
; the length of the file.
instr 9

     ilen filelen "-i" ; get the length of the file in seconds

     ktime init 0
     ktime times

     if (ktime < ilen) kgoto skip
          event "e", 0, 0   ; terminate now!

skip:
;      outvalue 111, times ; send out the time for a progress-bar

endin
</CsInstruments>
<CsScore>
i1 0 9999 ; maximum length
i9 0 9999 ; maximum length

</CsScore>

</CsoundSynthesizer>
