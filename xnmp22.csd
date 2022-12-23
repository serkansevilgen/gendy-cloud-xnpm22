<CsoundSynthesizer>
<CsOptions>
-odac --m-amps=0 
</CsOptions>
<CsInstruments>
;; Serkan Sevilgen
;; https://serkansevilgen.com
;; XNPM22
;; Xenakis Networked Performance Marathon
;; Athens Conservatory
;; 17 Dec 2022
;; Organized by Ionian University
;; and Athens Conservatory
;; for the Meta-Xenakis Consortium.

#include "./settings.csd"

sr = 44100
ksmps = 100
0dbfs = 1
nchnls = 2

;; 8-channel Setup
;; giOutChn_1 = 1
;; giOutChn_2 = 2
;; giOutChn_3 = 4
;; giOutChn_4 = 6
;; giOutChn_5 = 8
;; giOutChn_6 = 7
;; giOutChn_7 = 5
;; giOutChn_8 = 3

;; Stereo mix
giOutChn_1 = 1
giOutChn_2 = 2
giOutChn_8 = 1
giOutChn_3 = 2
giOutChn_7 = 1
giOutChn_4 = 2
giOutChn_6 = 1
giOutChn_5 = 2
;; giOut[] init 9
;; giOut[] fillarray 0, giOutChn_1, giOutChn_2, giOutChn_3, giOutChn_4, giOutChn_5, giOutChn_6, giOutChn_7, giOutChn_8
giOut[] init 3
giOut[] fillarray 0, giOutChn_1, giOutChn_2

;; seed 745

;; OSC globals
;; gSaddress = "/xnpm22"
;; giPort = 7770
gSparamtypes = "isf" ;; userid, param_name, param_val
giOscHandle OSCinit giPort

;; TOTAL NUMBER OF PERFORMERS
;; gitotal_num_perf = 2
gitotal_perf_params = 4
;; ARRAY FOR PERFORMANCE PARAMETERS (OSC)
gkPerfArr[][] init gitotal_num_perf, gitotal_perf_params
;; TODO: How to assign defaults programmatically below (with UDO?)
;; gkPerfArr[][] fillarray 1, 1, 1, 1, 1, 1, 1, 1
;; arr[userid] = [gate, note_dur, rest_dur, trig_gendy] 

;; Global stereo reverb
gaReverbL init 0
gaReverbR init 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UDOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

opcode setDefaults, 0, 0 ;; sets sane defaults to performance array
  ;; Default values in array is 0 when it is first created
  ;; note_dur can not be 0
  ;; gate should be 0
  ;; trig_gendy 1
;; gate, note_dur_indx, rest_dur_indx, trig_gendy 
  kRow[] init 4
  kRow[] fillarray 0, 10, 10, 1
  kuserid init 0  ;; also userid
  while kuserid <  gitotal_num_perf do    
  gkPerfArr setrow kRow, kuserid
  kuserid += 1    
  od    
endop

opcode getPerfIndx, k, S ;; returns index of a named parameter in perf array
  Sname xin
  kindx init 0
  kgate strcmpk "gate", Sname
  knote_dur strcmpk "note_dur", Sname
  krest_dur strcmpk "rest_dur", Sname
  ktrig_gendy strcmpk "trig_gendy", Sname

  if kgate == 0 then
  kindx = 0
  elseif knote_dur == 0 then
kindx = 1
elseif krest_dur == 0 then
kindx = 2
elseif ktrig_gendy == 0 then
kindx = 3
endif  
 xout kindx      
endop

opcode getPerfVal, k, kS ;; shortcut to get value from gkPerfArr, ins: userid and param index
  kuserid, Sname xin
  kindx getPerfIndx Sname 
  kRow[] getrow gkPerfArr, kuserid
  xout kRow[kindx]
endop

opcode setPerfVal, 0, kSk
  kuserid, Sname, kval xin
  kindx getPerfIndx Sname 
  kRow[] getrow gkPerfArr, kuserid
  kRow[kindx] = kval
;; printarray kRow
  gkPerfArr setrow kRow, kuserid
endop

opcode noteDurArr, k[], 0
  kArr[] fillarray 0.01,0.11,0.21,0.31,0.41,0.51,0.61,0.71,0.81, 0.91,1.,1.5,2.,2.5,3.,3.5,4.,4.5,5.,6.,7.,8.,9.,10.,11.,12.,13.,14.,15.,16.,17.,18.,19.
xout kArr
endop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEST UDOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO: DEFINE MOCK GLOBALS FOR ARRAYS AND VALUES. DO NOT WORK ON PROD VARIABLES

;; OPCODE TESTING HELPERS
gSsuccess = "SUCCESS"
gSfail = "FAIL"

opcode test_getPerfIndx, S, 0
  kval getPerfIndx "note_dur"
  Sout init ""
  if kval == 1 then
  Sout = gSsuccess 
  else
  Sout =  gSfail;
  endif
  Sout strcat "test_getPerfIndx: " , Sout
    xout Sout
endop

opcode test_setPerfVal, S, 0 
setPerfVal 1, "note_dur", 3
kArr[] getrow gkPerfArr, 1
kval = kArr[1]
  if kval == 3 then
  Sout = gSsuccess 
  else
  Sout =  gSfail;
  endif
  Sout strcat "test_setPerfVal: " , Sout
    xout Sout
endop

instr TestSuite
  Sresult1 test_getPerfIndx
  prints  Sresult1
  Sresult2 test_setPerfVal
  prints  Sresult2  
endin
;schedule "TestSuite", 0, 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INIT INSTR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr initAll
setDefaults
endin

schedule "initAll", 0, 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ALWAYS ON INSTR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr MessageRec ;; Listens incoming OSC msg. Always ON
  kuserid init 0
  Sname  init ""
  kval init 0
  kans OSClisten giOscHandle, gSaddress, "isf",  kuserid, Sname, kval
  if kans == 1 then
    ;; kindx getPerfIndx Sname
    kindx = 99    
    printf "userid: %i name: '%s' val: %f index: %i" , 1, kuserid, Sname, kval, kindx
      kgate strcmpk "gate", Sname      
      printk 1, kgate      
      setPerfVal kuserid, Sname, kval
    printarray gkPerfArr    
  endif    
endin

schedule "MessageRec", 0, -1
; schedule "stop", 0, 1, "MessageRec", 8

; schedule "msend", 0, 1, 1, "rest_dur", 2.4

instr Reverb
  kRoomSize init 0.5
  kHFDamp init 0.35 
  aL, aR  freeverb gaReverbL, gaReverbR, kRoomSize, kHFDamp, sr, 0
  outs aL, aR
  clear gaReverbL
  clear gaReverbR  
endin  

schedule "Reverb", 0, -1

instr 99 ;; initiates patgen for each user  
  print gitotal_num_perf  
  iuserid init 0  ;; also userid
  while iuserid <  gitotal_num_perf do    
    iinstr_num = 8000 + (iuserid/100)
    ;; print iinstr_num    
    schedule iinstr_num, 0, -1, iuserid    
    ;; schedule "PatGen", 0, -1, icount    
    iuserid += 1    
  od    
endin

schedule 99, 0, 1



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HELPER INSTRUMENTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr stop
  Sname = p4  
  imode = p5
  irel = 1
  insno nstrnum Sname  
  ;; imode
  ;; turn off all instances (0), oldest only (1), or newest only (2)
  ;; 4: only turn off notes with exactly matching (fractional) instrument number
  ;; 8: only turn off notes with indefinite duration (p3 < 0 or MIDI)  
  turnoff2 insno, imode, irel   
endin  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INSTRUMENTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr 8 ;; Xenakis gendy
  kamp = p4 ;; 0.2 - 0.7
  kampdist = p5 ;; 1 - 6
  kdurdist = p6 ;; 0.0001 - 1
  kadpar = p7 ;;  0.0001 - 1
  kddpar = p8 ;;  0.0001 - 1
  kminfreq = p9 ;; 20 - 20000 
  kmaxfreq = p10 ;; 20 - 20000 
  kampscl = p11 ;; 0.1 - 1
  kdurscl = p12 ;; 0.1 - 1
  ideg = p13
  iuserid = p14
  kUserArr[] getrow gkPerfArr, iuserid
  kgate = kUserArr[0]
  
  asig gendy kamp, kampdist, kdurdist, kadpar, kddpar, kminfreq, kmaxfreq,kampscl, kdurscl

  ;; kenv1 linsegr 0, 0.001, 1, p3-0.002, 1, 0.001, 0
  ;; kenv2 linsegr 0, 0.05, 1, p3-0.1, 1, 0.05, 0
  kenv linsegr 0, 0.01, 1, p3-0.02, 1, 0.01, 0  
  ;; if p3 < 0.1 then
  ;;   kenv = kenv1
  ;;   else
  ;;   kenv = kenv2
  ;; endif    
 
  asig alpass asig, 1, 0.1
  ilevel random 0.2, 0.8  
  asig = asig * kgate
  asig = asig*kenv*ilevel      
  aL, aR pan2 asig, ideg
  outs aL, aR
  ;; send to reverb  
  iRvbAmt random 0.1, 0.8
  gaReverbL = gaReverbL + (aL * iRvbAmt)
  gaReverbR = gaReverbR + (aR * iRvbAmt)
endin

instr 8000 ;; Pattern generator for instr 8
  kuserid = p4
  loop:
    ktrig getPerfVal kuserid, "trig_gendy"
    kalert = 5    
    if ktrig == 1 then      
      kampdist random 1, 6
      kamp random 0.05, 0.1
      kdurdist random 0.0001, 1
      kadpar random 0.0001, 1
      kddpar random 0.0001, 1
      kminfreq random 20, 2000
      kfreqdiff random 10, 1000     
      kmaxfreq = kminfreq + kfreqdiff
      kampscl random 0.1, 1
      kdurscl random 0.1, 1      
      setPerfVal kuserid, "trig_gendy", 0           
    endif      

      kdeg random -1.0, 1.0    
      ;; TODO use  getPerfVal
      kUserArr[] getrow gkPerfArr, kuserid
      knotedur_lambda = kUserArr[1]
      krestdur_lambda = kUserArr[2]

      kDurArr[] noteDurArr
      ilenarr lenarray kDurArr
      ;; print ilenarr      
      knotedurIndx poisson knotedur_lambda
      if knotedurIndx > ilenarr-1 then
	knotedurIndx = ilenarr-1
      endif	
	knotedur =  kDurArr[knotedurIndx]

      krestdurIndx poisson krestdur_lambda
      if krestdurIndx > ilenarr-1 then
	krestdurIndx = ilenarr-1
      endif	
	krestdur =  kDurArr[krestdurIndx]

	kdurloop = knotedur+krestdur
	idurloop = i(kdurloop)
	
	timout    0, idurloop, play
	reinit    loop
      play:
	inotedur = i(knotedur)
	irestdur = i(krestdur)
      ;; printf "note: %f, rest: %f\n", 1, inotedur, irestdur      
	iamp = i(kamp)
	iampdist = i(kampdist)
	idurdist = i(kdurdist)
	iadpar = i(kadpar)
	iddpar = i(kddpar)
	iminfreq = i(kminfreq)
	imaxfreq = i(kmaxfreq)
	iampscl = i(kampscl)
	idurscl = i(kdurscl)
	ideg = i(kdeg)
	iuserid = i(kuserid)
	inum = 8+((iuserid+1)/100)
	;; print inum      
	event_i "i", inum, 0, inotedur, iamp, iampdist, idurdist, iadpar, iddpar, iminfreq, imaxfreq, iampscl, idurscl, ideg, iuserid
endin

;; Schedule 8000, 0, 20, 0

;; schedule "print_arr", 0, 1

;; schedule "stop", 0, 1, "PatGen", 0


;; schedule "msend", 0, 1, 0, "note_dur", 1
;; schedule "msend", 0, 1, 0, "gate", 1
;; schedule "msend", 0, 1, 0, "rest_dur", 1
;; schedule "msend", 0, 1, 0, "trig_gendy", 1
;; schedule "stop", 0, 1, 8, 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEMP INSTRUMENTS TO CHECK
;; STUFF DURING DEVELOPMENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

instr msend
  iport = giPort
  ;; "/xenakis-net/user1-HZHa7DqBQwyn", "f", kdur1
  iuserid = p4
  Sparam =  p5;; 0: "gate", 1: "note_dur", 2: "rest_dur", 3: "trig_timbre" [0, 1]    
  ival = p6  
  
  OSCsend 1, "localhost", iport, gSaddress, "isf", iuserid, Sparam, ival
endin  

;; schedule "msend", 0, 1, 0, "note_dur", 10
;; schedule "msend", 0, 1, 0, "gate", 1
;; schedule "msend", 0, 1, 0, "rest_dur", 1
;; schedule "msend", 0, 1, 0, "trig_gendy", 1
;; schedule "stop", 0, 1, "PatGen", 0

instr concArr
  ;; iArr1[] fillarray 1,1
  ;; iArr2[] fillarray 2,2
  ;; iArr1[] genarray 1, 2, 3 
  ;; iArr2[] genarray 4, 5
  ;; iArrFinal[] interleave iArr1, iArr2
  ;; iSorted[] sorta iArrFinal  
  ;; printarray iSorted
  iArr[] fillarray 0.01,0.11,0.21,0.31,0.41,0.51,0.61,0.71,0.81, 0.91,1.,1.5,2.,2.5,3.,3.5,4.,4.5,5.,6.,7.,8.,9.,10.,11.,12.,13.,14.,15.,16.,17.,18.,19.
  ilen lenarray iArr
  print ilen  
  printarray iArr  
endin  

schedule "concArr", 0, 1

instr print_arr
  iPerfArr[] = gkPerfArr
  printarray iPerfArr  
endin  

;; schedule "print_arr", 0, 1

</CsInstruments>
<CsScore>
;i "MidiInput" 0 999
;; i "CheckArr" 0 999
;; i "OSCListener" 0 300
;; i "Run" 0 10
;; i 8000 0 1 0
;; i 2 0 5 5
;; i "msend" 0 1
;; i "mrec" 0 1
;; i 99 0 3600
f 0 3600
</CsScore>
</CsoundSynthesizer>