<CsoundSynthesizer>
<CsOptions>
-odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

giscale	ftgen	0,0,-7,-2,45, 47, 48, 50, 52,  54, 55 ;A  Dorian


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


instr synth

	kFreq_lfo = (abs(gkpitch)/3)
	kAmp_lfo = 1 
	 
	index random 0, 9
	index = int(index)
	inote table index, giscale, 0, 0, 1 ;note picking device
	iamp random 0.1, 0.5
	ifreq = cpsmidinn(inote-12)
	 
	aSine poscil 0.3, 1000 ; a reference for balance
	 
	kLfo poscil kAmp_lfo, kFreq_lfo ; a squarewave lfo
	kLfo = (kLfo+1)/2
	
	a1 vco2 iamp*kLfo, ifreq+kLfo
	a2 vco2 iamp*kLfo, ifreq*0.5
	a3 vco2 iamp*kLfo, ifreq*3
	 
	a4 vco2 iamp*kLfo, ifreq*1.002
	a5 vco2 iamp*kLfo, ifreq*0.5002
	a6 vco2 iamp*kLfo, ifreq*5.012
	 
	aMixL sum a1, a2, a3
	aMixR sum a4, a5, a6
	 
	kres = (gkx/1023)-0.3   
	 
	if (kres < 0.1) then
		kres = 0.1
	endif
	
	//printk2 kres 
	 
	aFilL lpf18 aMixL, (gky*2)+500, kres, 0.5
	aFilR lpf18 aMixR, (gky*2)+500, kres, 0.5
	 
	aOutL balance aFilL, aSine
	aOutR balance aFilR, aSine
	 
	 	itypea random -3, 3
	itypeb random -3, 3
	itypea = int(itypea)
	itypeb = int(itypeb)
	;print itypea
	idur1 random 0.1, 0.9
	idur2 = 1 - idur1
	 
	kOut transeg 0.001, p3*idur1, itypea, 1, p3*idur2, itypeb, 0.0001
	 
	aOL = (aOutL*kOut)
	aOR = (aOutR*kOut)
	 
	gaoutL+=aOL
	gaoutR+=aOR
	  

endin


instr trig

	krate = 0.1
	
	gkcoin randomh 1, 5, krate
	gkcoin = int(gkcoin)
	
	kdur = 1/krate
	
	
	if trigger(gktrig, 0.5, 0) == 1 then
		event "i", "synth", 0, kdur
		;event "i", "synth", 0, kdur
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
	
	ktrig = 1
	
	ktrig portk ktrig, 0.2 
	out (gaoutL*ktrig), (gaoutR*ktrig)
	clear gaoutL
	clear gaoutR

endin


instr reverb

	krand1 rspline 0.5, 0.9, 0.05, 0.1
	
	
	aoutL, aoutR reverbsc garevL, garevR, krand1, 8000
	
	
	gaoutL = (aoutL)+gaoutL
	gaoutR = (aoutR)+gaoutR
	
	clear garevL
	clear garevR

endin

</CsInstruments>
<CsScore>
i "NODE_Listen" 0 3600
i "trig" 0 3600
i "out" 0 3600
i "reverb" 0 3600
</CsScore>
</CsoundSynthesizer>




<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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
