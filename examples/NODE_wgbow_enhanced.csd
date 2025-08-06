<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>
sr      =       44100
ksmps   =       32
nchnls  =       2
0dbfs   =       1
        seed    0

gisine  ftgen   0,0,4096,10,1

giosc OSCinit 9000
gktrig init 0
gkx init 0
gky init 0
gkyaw init 0
gkpitch init 0
gkroll init 0
gkspeed_P init 0
gkspeed_R init 0
gkdir_P init 0
gkdir_R init 0

instr NODE_Listen
	
	/*
	gkx = joystick x-axis
	gky = joystick y-axis
	gktrig = joystick switch
	gkspeed = speed of pitch
	gkdir = 0 is stationary, > 0 is forward, < 0 is backward
	
	*/

	kans OSClisten giosc, "/Node", "ffffffffff", gkx, gky, gktrig, gkyaw, gkpitch, gkroll, gkspeed_P, gkspeed_R, gkdir_P, gkdir_R
	
	gkx portk gkx, 0.02
	gky portk gky, 0.02
	
	gkpitch portk gkpitch, 0.02
	gkdir_P portk gkdir_P, 0.02
	
	;printk2 gkroll

endin

gaSend init 0

instr Bowie ; wgbow instrument
iMax = 10000
iMin = 80
kpitch = (gkpitch+90)/180
kroll = abs(gkroll+180) / 360
ky = gky/1024

kx = (gkx/1024)

kamp     =        0.1
kfreq    =        p4
kpres    =        kpitch
krat     rspline  0.006,0.988,0.1,0.4
kvibf    =        4.5
kvibamp  =        kroll*0.005
iminfreq =        20
aSig     wgbow    kamp,kfreq,kpres,krat,kvibf,kvibamp,gisine,iminfreq
ifc = iMax/iMin
kcut = iMin * pow(ifc, kx) 
printk2 kx
aSig     butlp     aSig,kcut
aSig     pareq    aSig,80,6,0.707


aOutL, aOutR pan2 aSig, ky
         outs     aOutL,aOutR
gaSend   =        gaSend + aSig/3
 endin

 instr Verb ; reverb
aRvbL,aRvbR reverbsc gaSend,gaSend,0.9,7000
            outs     aRvbL,aRvbR
            clear    gaSend
 endin

</CsInstruments>
<CsScore>
; instr. 1 (wgbow instrument)
;  p4 = pitch (hertz)
; wgbow instrument
i "NODE_Listen" 0 z

i "Bowie"  0 480  20
i "Bowie" 0 480  40
i "Bowie" 0 480  80
i "Bowie" 0 480  160
i "Bowie" 0 480  320
i "Bowie" 0 480  640
i "Bowie" 0 480  1280
i "Bowie" 0 480  2460
; reverb instrument
i "Verb" 0 480
</CsScore>
</CsoundSynthesizer>
;example by Iain McCurdy




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
