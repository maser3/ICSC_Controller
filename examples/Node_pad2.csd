<CsoundSynthesizer>
<CsOptions>
-b1024 -B4096 -odac ;-v
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 4

seed 0

maxalloc "pad", 10

giscale	ftgen	0,0,-9,-2,1,1.25992,1.49831,1.88775,2.0000,2.25992,2.49831,2.88775,3.0000;Maj pent
;giscale	ftgen	0,0,-5,-2,1,1.49831,2.0000,2.49831,3.0000;Maj pent
gindex init 0

;waveforms
giv1 ftgen 1,0,16384,10,1,1/2,1/3,1/4,1/5,1/6,1/7,1/8,1/9,1/10 ;sawtooth 
giv2 ftgen 2,0,16384,10,1,0,1/3,0,1/5,0,0,1/8,0,1/10 ;square
giv3 ftgen 3, 0, 16384, 10, 1 ;sine

;global variables
gaoutL init 0
gaoutR init 0
garevL init 0
garevR init 0

gkcoin init 1

gktime times

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
	
	printk2 gkpitch

endin

instr test

	kenv expon 1, p3, 0.0001
	aSig poscil kenv, 300
	
	outs aSig, aSig

endin


instr pad
	kyprev init 0
	gktime1 timeinsts
	
	index random 0, 9
	kband init 0.5
	klfo init 0.5
	
	
	kband = (gkx/1023)+0.1
	klfo = gky/1023
	kpitch = kband*4
	;ipitch = i(kpitch)
	kpitch portk kpitch, 0.2
	;printk2 kpitch
	
	
	index = int(index)
	
	;amplitude envelope settings
	ia random 500, 5000
	ib random 500, 10000
	idur random 1, 5
	irand random 0, 24
	
	
	kcps = (228/4)*p4 ;can be altered for relevant key
	
	;variation in individual oscillator's amplitude
	iamp1 random 0.1, 0.5
	iamp2 random 0.1, 0.5
	iamp3 random 0.1, 0.5
	iamp4 random 0.1, 0.5
	
	inote table index, giscale, 0, 0, 1 ;note picking device
	
	;filter envelopes
	kfreq1 linseg ia, idur, ib
	kfreq2 linseg ia, idur*0.5, ib, idur*0.5, ia
	kfreq3 linseg ia, idur*0.25, ib, idur*0.25, ia, idur*0.25, ib, idur*0.25, ia
	iband random 10, 800
	
	if (irand <= 10) then
		kfreq = kfreq1
	elseif (irand <= 20) && (irand >= 11) then
		kfreq = kfreq2
	else
		kfreq = kfreq3
	endif
	
	kcps = kcps *inote ;note multiplier (needed?)
	
	ifn1 random 1, 4
	ifn1 = int(ifn1)
	ifn2 random 1, 4
	ifn2 = int(ifn2)
	ifn3 random 1, 4
	ifn3 = int(ifn3)
	ifn4 random 1, 4
	ifn4 = int(ifn4)
	
	kycur = klfo
	
	;kmove = kycur-kyprev
	;kmove = abs(kmove)
	;
	;printk2 kmove
	
	kamp = kband-500
	kamp = abs(kband)
	;kamp portk kamp, 0.2
	
	ktune = ((gkyaw/360)*0.07)+1
	
	printk2 gkpitch/90
	
	aMod lfo (gkpitch/90), klfo*10, 3
	
	a1 poscil iamp1, kcps, ifn1
	a2 poscil iamp2, (kcps*2), ifn2
	a3 poscil iamp3, (kcps*ktune)*2, ifn3
	a4 poscil iamp4, (kcps*0.5), ifn4
	;endif
	
	asum sum a1, a2, a3, a4
	
	kfco = (klfo*500)+500
	kbw = (kband*400)+20
	
	kres = (gkx/1023)-0.3   
	 
	if (kres < 0.1) then
		kres = 0.1
	endif
	
	afil moogvcf2 asum, kfreq, kres
	afil2 butterbp afil, kfco, kbw
	afil3 butterhp afil2, 100
	abal balance afil2, asum
	ipan random 0, 1
	

	
	kwet = (abs(gkroll)*0.01)/2
	
	aL, aR pan2 abal, ipan
	
	
	irandL random 1, 25
	irandR random 1, 25
	
	
	itypea random -3, 3
	itypeb random -3, 3
	itypea = int(itypea)
	itypeb = int(itypeb)

	idur1 random 0.1, 0.9
	idur2 = 1 - idur1

	
	kout transeg 0.001, p3*idur1, itypea, 1, p3*idur2, itypeb, 0.0001
	

	garevL += ((aL)*kout)*kwet
	garevR += ((aR)*kout)*kwet
	gaoutL += (aL*kout)*0.5
	gaoutR += (aR*kout)*0.5
	

	
endin



instr trig

	krate = 0.1
	
	;krate randomh 0.1, 0.05, 0.01
	gkcoin randomh 1, 5, krate
	gkcoin = int(gkcoin)
	;printk2 kcoin
	
	;printk 1, krate
	kdur = 1/krate
	;printk 1, kdur
	;ktrig chnget "trig"
	;ktrig metro krate
	
	if gktrig > 500 then
		ktrig = 1
	else
		ktrig = 0
	endif
	

	
	if trigger(gktrig, 0.5, 0) == 1 then
		event "i", "pad", 0, kdur, 2
		event "i", "pad", 0, kdur, 1
		;event "i", "pad", 0, kdur, 4
		;event "i", "pad", 0, kdur, 4
		;event "i", "pad", kdur/4, kdur, 4
		;event "i", "pad", kdur/2, kdur, 4
	endif
	

endin



instr out;15

	kmute chnget "mute"
	kmute = kmute -1
	kmute = abs(kmute)
	
	;if gktrig > 500 then
	;ktrig = 1
	;else
	;ktrig = 0
	;endif
	
	ktrig = 1
	
	ktrig portk ktrig, 0.2 
	out (gaoutL*ktrig), (gaoutR*ktrig)
	clear gaoutL
	clear gaoutR

endin



instr reverb

	krand1 rspline 0.5, 0.9, 0.05, 0.1
	
	
	aoutL, aoutR reverbsc garevL, garevR, 0.9, 8000
	
	
	gaoutL = (aoutL*0.5)+gaoutL
	gaoutR = (aoutR*0.5)+gaoutR
	
	clear garevL
	clear garevR

endin

</CsInstruments>
<CsScore>
i "NODE_Listen" 0 3600
i "trig" 0 3600
;i "pad" 0 3600 2
;i "pad" 0 3600 1
i "out" 0 3600
i "reverb" 0 3600
</CsScore>
</CsoundSynthesizer>










<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>638</x>
 <y>212</y>
 <width>308</width>
 <height>425</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBButton">
  <objectName>trig</objectName>
  <x>5</x>
  <y>7</y>
  <width>100</width>
  <height>30</height>
  <uuid>{2441a907-fba8-47f5-aa1a-6bf2a2f92db8}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>GO</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>pitch</objectName>
  <x>142</x>
  <y>6</y>
  <width>20</width>
  <height>100</height>
  <uuid>{0e7b0702-23c5-4553-9712-6d60c891627d}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.37000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>pitch</objectName>
  <x>116</x>
  <y>111</y>
  <width>80</width>
  <height>25</height>
  <uuid>{bc6d75b9-c076-4a92-9b67-5a803d65eb65}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.370</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>mute</objectName>
  <x>6</x>
  <y>59</y>
  <width>100</width>
  <height>30</height>
  <uuid>{a8142c9b-3243-4347-b6f8-820dc15d1004}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>MUTE</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>false</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBController">
  <objectName>bw</objectName>
  <x>20</x>
  <y>171</y>
  <width>250</width>
  <height>190</height>
  <uuid>{6ac5951b-01d6-4d35-aefe-e4d4e21817e1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <objectName2>lfo</objectName2>
  <xMin>0.10000000</xMin>
  <xMax>1.00000000</xMax>
  <yMin>0.00000000</yMin>
  <yMax>1.00000000</yMax>
  <xValue>0.47800000</xValue>
  <yValue>0.90000000</yValue>
  <type>crosshair</type>
  <pointsize>1</pointsize>
  <fadeSpeed>0.00000000</fadeSpeed>
  <mouseControl act="press">jump</mouseControl>
  <bordermode>noborder</bordermode>
  <borderColor>#00FF00</borderColor>
  <color>
   <r>0</r>
   <g>234</g>
   <b>0</b>
  </color>
  <randomizable mode="both" group="0">false</randomizable>
  <bgcolor>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </bgcolor>
  <bgcolormode>true</bgcolormode>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>lfo</objectName>
  <x>65</x>
  <y>383</y>
  <width>80</width>
  <height>25</height>
  <uuid>{34e2fc48-536b-42c0-8f84-c81cbb3cf5b6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>0.900</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>10</fontsize>
  <precision>3</precision>
  <color>
   <r>0</r>
   <g>0</g>
   <b>0</b>
  </color>
  <bgcolor mode="nobackground">
   <r>255</r>
   <g>255</g>
   <b>255</b>
  </bgcolor>
  <bordermode>border</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>1</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBButton">
  <objectName>button</objectName>
  <x>5</x>
  <y>110</y>
  <width>100</width>
  <height>30</height>
  <uuid>{be263c69-26ea-4db6-ac96-18dcc7c7ed22}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>Button2</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
