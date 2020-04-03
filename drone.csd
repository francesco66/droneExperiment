
; 3 aprile 2020

<CsoundSynthesizer>
<CsOptions>
-d
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 128
nchnls = 2
0dbfs  = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UDO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Declick - Steven Yi
opcode declick, a, a
  ain xin
  aenv = linseg:a(0, 0.01, 1, p3 - 0.02, 1, 0.01, 0, 0.01, 0)
  xout ain * aenv
endop

; Returns random item from karray - Steven Yi
opcode rand, i, k[]
  kvals[] xin
  indx = int(random(0, lenarray(kvals)))
  ival = i(kvals, indx)
  xout ival
endop

; Detection - Joachim Heintz
opcode OnDtct, kk, aOOOOo

	aIn, kDbDiff, kMinTim, kMinDb, kDelTim, iRmsFreq xin

	; resolving defaults
	kDbDiff = (kDbDiff==0) ? 10 : kDbDiff
	kMinTim = (kMinTim==0) ? 0.1 : kMinTim
	kMinDb = (kMinDb==0) ? -50 : kMinDb
	kDelTim = (kDelTim==0) ? 0.025 : kDelTim
	iRmsFreq = (iRmsFreq==0) ? 50 : iRmsFreq
	kPrevDetect init 0.1
	iMaxDelTim init 0.5
	kOnset init 0
	kRms rms aIn,iRmsFreq
	kDb = dbamp(kRms)
	kDelRms vdelayk kDb, kDelTim, iMaxDelTim

	if (kDb>kDelRms+kDbDiff) && (kDb>kMinDb) && (kPrevDetect>kMinTim) then
		kOnset = 1
		kPrevDetect = 0
	else
		kOnset = 0
	endif

	kPrevDetect += 1/kr

	xout kOnset, kDb
endop

; REVERBSC
opcode Reverbsc, aa, aakk

	al, ar, kReverbTime, kReverbLevel xin

	arl, arr reverbsc al, ar, kReverbTime, 10000
	aoutl ntrpol arl, al, kReverbLevel
	aoutr ntrpol arr, ar, kReverbLevel
	xout aoutl, aoutr
endop

; shimmer_reverb - Steven Yi
opcode shimmer_reverb, aa, aakkkkkk
	al, ar, kpredelay, krvbfblvl, krvbco, kfblvl, kfbdeltime, kratio  xin

  ; pre-delay
  al = vdelay3(al, kpredelay, 1000)
  ar = vdelay3(ar, kpredelay, 1000)
 
  afbl init 0
  afbr init 0

  al = al + (afbl * kfblvl)
  ar = ar + (afbr * kfblvl)

  ; important, or signal bias grows rapidly
  al = dcblock2(al)
  ar = dcblock2(ar)

	; tanh for limiting
  al = tanh(al)
  ar = tanh(ar)

  al, ar reverbsc al, ar, krvbfblvl, krvbco 

  ifftsize  = 2048 
  ioverlap  = ifftsize / 4 
  iwinsize  = ifftsize 
  iwinshape = 1; von-Hann window 

  fftin     pvsanal al, ifftsize, ioverlap, iwinsize, iwinshape 
  fftscale  pvscale fftin, kratio, 0, 1
  atransL   pvsynth fftscale

  fftin2    pvsanal ar, ifftsize, ioverlap, iwinsize, iwinshape 
  fftscale2 pvscale fftin2, kratio, 0, 1
  atransR   pvsynth fftscale2

  ;; delay the feedback to let it build up over time
  afbl = vdelay3(atransL, kfbdeltime, 4000)
  afbr = vdelay3(atransR, kfbdeltime, 4000)

  xout al, ar
endop

; Steven Yi - noise/vco synth instrument
opcode Noise, aa, iiii
	iCps, iAmp, iPan, iDur xin

	asig = pinker() * 0.1
	asig = zdf_2pole(asig, iCps, 24.8, 2)
	asig += zdf_ladder(vco2(0.25, iCps), 2000, 2)
	asig *= iAmp * oscili(1, 0.5 / iDur) ;* 0.5
	al, ar pan2 asig, iPan

	xout al, ar
endop

; Strumento synth che usa Noise di Steven Yi
; con 3 linee unisono, unisono 'alterato' e quinta 
opcode NoiseSynth, aa, iii
	iCps, iAmp, iDur xin

	iPan1 random 0.25, 0.75
	al1, ar1 Noise iCps, iAmp, iPan1, iDur
	iPan2 random 0.25, 0.75
	al2, ar2 Noise iCps*1.5, iAmp, iPan2, iDur
	iPan3 random 0.25, 0.75
	al3, ar3 Noise iCps*1.01, iAmp, iPan3, iDur
	al = (al1 + al2 + al3)
	ar = (ar1 + ar2 + ar3)
	alr, arr reverbsc al, ar, 0.9, 3000
  aoutl ntrpol al, alr, 0.4
  aoutr ntrpol ar, arr, 0.4

	xout aoutl, aoutr
endop

; Synth by Steven Yi
opcode Synth, a, ii

	iAmp, iCps xin
	
	asig = vco2(1, iCps)
	asig += vco2(1, iCps * 1.005)
	asig += vco2(1, iCps * 0.997)
	asig = zdf_2pole(asig, expon(1400, p3, 120), 2)
	asig *= iAmp * 0.1
	asig = declick(asig)

	xout asig
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gSarray[] init 100
gSarray[60] = "NOISE SYNTH"
gSarray[70] = "SYNTH"

opcode Msg, 0, i
	id xin
	iinstr = int(id)
	inum = (id - iinstr) * 1000
	Sname = gSarray[iinstr]
	;prints "%s : %d durata %d\n", Sname, inum, p3
	prints "%s : durata %d\n", Sname, p3
endop


; GLOBALI
gaudio init 0

gal2 init 0
gar2 init 0

; DRONE
;giDroneDur chnexport "drone_duration", 2
giDroneSectionDur init 20

; durata della registrazione della nota
giNoteNumber init 1
giNoteDur init 1.5
giDroneTableNum init 0

; delayed time sampling (in sec.)
giattack init 0.5
gisample_dur = giNoteDur - giattack

; tempo di fade in/out (sec.)
gifade = 0.5

; tavole per amp, cps dell'analisi
giAmpTable ftgen 0, 0, -1000, 2, 0
giCpsTable ftgen 0, 0, -1000, 2, 0

instr 2

gaudio diskin2 "sample1.00.wav", p4
endin

instr 3

iNumberOfNotes = 20
iDur = rand(array(10, 12, 14, 16, 18, 20))
iStart = 0
iId = 1
while (iId <= iNumberOfNotes) do
   schedule(2, iStart, 3, rand(array(5,10,15,20))*0.1)
   iId += 1
   iStart += iDur
od
endin

; ascolta l'input e quando si supera il livello impostato
; attiva lo strumento 12 che registra la nota
instr 11

kDbDiff init 10
kMinTim init 0.5
kMinDb init -30

ktrig, kRms OnDtct gaudio, kDbDiff, kMinTim, kMinDb

ktime times
printf "Triggering at time: %f\n", ktrig, ktime

; analisi
schedkwhen ktrig, 0, 0, 50, 0, 0.1, giNoteNumber
endin

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ANALISI ...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
instr 50

prints "started analisys\n"

ifftsize = 2048
ioverlap = ifftsize / 4
iwinsize = ifftsize
iwinshape = 1
ifn = p4

fftin pvsanal gaudio, ifftsize, ioverlap, iwinsize, iwinshape

kfr, kamp pvspitch fftin, 0.01

tabw kfr, ifn, giCpsTable
tabw kamp, ifn, giAmpTable

; STRUMENTO CHE USA L'ANALISI
event_i "i", 52, 0.1, 0, ifn
endin

instr 52

prints "starting instruments\n"

ifn = p4
iamp tab_i ifn, giAmpTable
icps tab_i ifn, giCpsTable

iDroneDur chnget "drone_duration"
inoisesynthOn chnget "noisesynthOn"
isynthOn chnget "synthOn"

; NOISE SYNTH
if inoisesynthOn==1 then
	event_i "i", 60 + ifn*0.001, 0, iDroneDur, iamp, icps
endif

; SYNTH
if isynthOn==1 then
	event_i "i", 70 + ifn*0.001, 0, iDroneDur, iamp, icps
endif
endin

; NOISES
instr 60

Msg p1

iAmp = p4
iCps = p5

al, ar NoiseSynth iCps, iAmp, p3

; cambiato in instruments2.udo
kVol chnget "volumeNoisesynth"
outs al*kVol, ar*kVol
endin

; SYNTH - Steven Yi
instr 70

Msg p1

iAmp = p4
iCps = p5

asig Synth iAmp, iCps

kVol chnget "volumeSynth"
gal2 += asig*kVol
gar2 += asig*kVol
endin

; ShimmerReverb per synth
instr 900

kpredelay init 100 
krvbfblvl init 0.95
krvbco init 16000
kfblvl init 0.45
kfbdeltime init 100
kratio init 1.5

al, ar shimmer_reverb gal2, gar2, kpredelay, krvbfblvl, krvbco, kfblvl, kfbdeltime, kratio

kFxLev chnget "ReverbLevelSynth"

aoutl ntrpol al, gal2, kFxLev
aoutr ntrpol ar, gar2, kFxLev

outs aoutl, aoutr
gal2 = 0
gar2 = 0
endin

/*
; RECORD
instr 1200

al, ar monitor
fout "droneD3.wav", 6, al, ar
endin
*/

</CsInstruments>
<CsScore>

i 3 5 0

i 11 0 3600

i 900 0 3600

</CsScore>
</CsoundSynthesizer>
