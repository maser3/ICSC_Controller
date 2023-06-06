<CsoundSynthesizer>
<CsOptions>
-b1024 -B4096 -odac -d
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1.0


gaoutL init 0
gaoutR init 0

giscale1	ftgen	0,0,32,-2,6.08,6.10,7.01,7.03,7.06,7.08,7.10,8.01,8.03,8.06,8.08;,8.10,9.01,9.03,9.06,9.08
giscale2	ftgen	0,0,32,-2,4.08,4.10,5.01,5.03,5.06,5.08,5.10,6.01,6.03,6.06,6.08;,8.10,9.01,9.03,9.06,9.08

gindex1 = 5
gindex2 = 5
seed 0



#include "NODE_Listen.inc"



instr sound

kyaw = (gkyaw/360)+.05

kfa = 1
inum random -8, 8
inum=int(inum)

if gindex1+inum>12 then
gindex1 = gindex1%12
endif

if gindex1+inum<0 then
gindex1 = gindex1%12
endif

ifreq table gindex1, giscale1
kfm = ifreq;*kyaw;kpitch  ;using pitch invalue for this effects the modulation, NICE!!
inum = (inum)+2
iamp random 0.05, 0.5

kenv expon iamp, p3, 0.001
amod oscil kfa*kfm, kfm
asig oscil kenv, (cpspch(ifreq)*p4)+amod

gaoutL+=(asig)*0.5
gaoutR+=(asig)*0.5
;printk2 gkroll
gindex1 = gindex1+inum

endin


instr trig
kpitch = abs((gkpitch/90)*3)+2

kswitch0 = 1
;kmul invalue "metro"

kroll = abs((gkroll/180)*9)+1 ;Roll determines the frequncy of events
kmul = kroll+0.5

kmetro = p4*kmul
gkmet1 metro kmetro

if kswitch0 == 1 then
schedkwhen gkmet1, 0, 10*kmul, "sound", 0.5, 4, kpitch
endif

if kswitch0 == 0 then
schedkwhen 0, 0, 10, "sound", 0, 1, 4
endif
;printk2 kswitch1
endin


instr out
;fout "WEC_Twinkle.wav", 4, gaoutL, gaoutR
out gaoutL, gaoutR
clear gaoutL
clear gaoutR
endin


</CsInstruments>
<CsScore>
i "NODE_Listen" 0 3600
i "trig" 0 3600 1
i "out" 0 3600

</CsScore>
</CsoundSynthesizer>










<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>671</x>
 <y>253</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBButton">
  <objectName>switch0</objectName>
  <x>84</x>
  <y>196</y>
  <width>100</width>
  <height>30</height>
  <uuid>{ad9f236f-d92e-4d26-937a-dac8eccdfb01}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <type>value</type>
  <pressedValue>1.00000000</pressedValue>
  <stringvalue/>
  <text>On
</text>
  <image>/</image>
  <eventLine>i1 0 10</eventLine>
  <latch>true</latch>
  <momentaryMidiButton>false</momentaryMidiButton>
  <latched>false</latched>
  <fontsize>10</fontsize>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>90</x>
  <y>14</y>
  <width>80</width>
  <height>25</height>
  <uuid>{fda86cd5-84b3-49c7-8cc2-e878501e44c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Roll
</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>metro</objectName>
  <x>82</x>
  <y>41</y>
  <width>100</width>
  <height>20</height>
  <uuid>{d2462f54-a36a-4d8f-af43-1efefb0487c0}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>1.00000000</minimum>
  <maximum>10.00000000</maximum>
  <value>8.92000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>pitch</objectName>
  <x>86</x>
  <y>94</y>
  <width>100</width>
  <height>20</height>
  <uuid>{4f4f0351-367d-45fa-85cd-ed336c1ee5a3}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>1.00000000</minimum>
  <maximum>4.00000000</maximum>
  <value>3.70000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>93</x>
  <y>65</y>
  <width>80</width>
  <height>25</height>
  <uuid>{c47f11c6-23d0-4da0-88ba-48508a7ce802}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Pitch

</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBHSlider">
  <objectName>yaw</objectName>
  <x>86</x>
  <y>151</y>
  <width>100</width>
  <height>20</height>
  <uuid>{a1bff87d-e4f4-4658-9130-beead442f14f}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <minimum>0.05000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.05000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
 <bsbObject version="2" type="BSBLabel">
  <objectName/>
  <x>93</x>
  <y>122</y>
  <width>80</width>
  <height>25</height>
  <uuid>{dbfbae41-6aa1-4d27-a08b-15a5c34d48c6}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>Yaw
</label>
  <alignment>left</alignment>
  <valignment>top</valignment>
  <font>Arial</font>
  <fontsize>14</fontsize>
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
  <bordermode>noborder</bordermode>
  <borderradius>1</borderradius>
  <borderwidth>0</borderwidth>
 </bsbObject>
 <bsbObject version="2" type="BSBDisplay">
  <objectName>pitch</objectName>
  <x>217</x>
  <y>98</y>
  <width>80</width>
  <height>25</height>
  <uuid>{ba163005-56de-4454-ad1f-389cd61d389b}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>0</midicc>
  <description/>
  <label>3.700</label>
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
</bsbPanel>
<bsbPresets>
</bsbPresets>
