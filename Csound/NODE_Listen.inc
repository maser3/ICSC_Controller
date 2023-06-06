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
	
	//printk2 gkpitch

endin
