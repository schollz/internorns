--------------------------------------------------
------------------ beginning ---------------------
--------------------------------------------------

-- each line in this file is valid lua code
-- you can run it by selecting it and pressing Ctl+Enter
-- or just press Ctl+Enter and it will run the current line

-- highlight and run this code, you should see it below:
print("hello, world")

-- lets load the norns deck
norns.script.load("code/voyage/voyage.lua")

-- lets change the tempo to 120
params:set("clock_tempo",120)

-- the norns deck has special functions in addition to regular lua
-- that harness a built-in drum machine, a 6-voice sampler, and sequencer
-- nature(<vol>) is one example, it plays nature sounds
nature(1.0)

-- er(<n>) function creates 16-step euclidean rhythm the number "1" in <n> places
-- e.g., er(4) = {1,,,,1,,,,1,,,,1,,,}
table.print(er(4))

-- er(<lua>,<n>) creates 16-step euclidean rhythm with <lua> in <n> places
table.print(er("print('hi')",4))

-- play(<ptn>,<er>,<measure>) creates a sequence called <ptn> that executes code
play("hello",er("print('hi')",4),1)
-- stop(<ptn>) will stop the pattern
stop("hello")

-- lfo(<period>,<slo>,<shi>) returns value of a sine function evaluated
play("hello",er("print('lfo='..lfo(10,1,100))",4),1)
stop("hello")

--------------------------------------------------
---------------  built-in drums ------------------
--------------------------------------------------

-- if you use play(..) with <ptn> named with any of the following:
-- "kick" or "clap" or "sd" or "hh" or "oh",
-- it will utilize the built-in drums 

-- in each step of the <er> on the given <measure>
play("kick",er(2),1)


-- regular lua commands work
-- built-in drums have a bunch of properties you can modify
kick.patch.distAmt=60;
kick.patch.level=-5;
clap.patch.level=-2;
hh.patch.level=-5;
-- more: http://norns.local/maiden/#edit/dust/code/voyage/lib/drummer.lua

-- lets sequence some lua code
-- "kicklfo" is arbitrary, using er(..) to sequence lua that change the patch
play("kicklfo",er("kick.patch.oscDcy=lfo(12,400,1200)",4),1)
play("kicklfo2",er("kick.patch.distAmt=lfo(13,1,60)",4),1)

-- er_add(<er1>,<er2>) will combine two rhythms
-- rot(<er>,<amt>) will rotate a rhythm <er> by <amt>
play("kick",er_add(er(1),rot(er(1),3)),2)


-- er_sub(<er1>,<er2>) will subtract <er2> from <er1>
play("hh",er_sub(er(15),er(4)),1)
play("hhlfo",er("hh.patch.nEnvDcy=lfo(13,90,450)",4),1)
play("clap",rot(er(2),4),1)

-- stop(<ptn>) will stop pattern named <ptn>
stop("kick")
stop("clap")
stop("hh")


--------------------------------------------------
------------------  samples ----------------------
--------------------------------------------------

-- e = engine, it is quicker to access
-- e.wav(<bufnum>,<file>) loads <file> into <bufnum>
-- wav(<name>) loads /home/we/dust/audio/voyage/<name>.wav
e.wav(1,wav("closer"))
-- e.amp(<id>,<vol>) sets volume
e.amp(1,1.2)
-- e.pos(<id>,<pos>) sets position (in [0,1])
e.pos(1,13/28) 
-- e.pan(<id>,<pan>) sets pan (in [-1,1])
e.pan(1,0) 
-- set position every measure
play("closer",er("e.pos(1,13/28)",1),1)
play("closerpan",er("e.pan(1,lfo(6,-0.5,0.5))",8),1)
-- set position every 16 measures
expand("closer",16)
stop("closer")

-- one sample can be "quantized" and with glitch and reverse fx
-- e.wav(<id>,<filename>)
e.wav(2,wav("120_4")) 
-- e.rate(<id>,<rate>), can change rate to match bpm
e.rate(2,clock.get_tempo()/120)
-- beatsync(<id>,<num>) keeps sample containing <num> beats in sync
beatsync(2,8)
-- e.amp(<id>,<vol>) raises volume
e.amp(2,0.6)
-- e.pan(<id>,<pan>) will pan
e.pan(2,0.0)

-- once beat synced, you can do
-- glitching and reversing:
-- glitch(<prob>) glitch with probability <prob> (0,1)
glitch_prob(2,0.02)
-- reverse(<prob> reverses with probability <prob> (0,1)
reverse_prob(2,0.05)

-- e.amp(<id>,<vol>) lets you turn on/off the sound
e.amp(1,0)
e.amp(2,0)


--------------------------------------------------
--------------------  tape -----------------------
--------------------------------------------------

-- tape can add cool stops and starts

-- tape stop
tapestop()
-- tape start (run after stop)
tapestart()
-- tape break (run twice to get normal)
tapebreak()

-- put them together
clock.run(function() clock.sleep(1.5);tapestop();clock.sleep(2.5);tapestart() end)
clock.run(function() clock.sleep(1.5);tapebreak();clock.sleep(1.5);tapebreak() end)

-- clock
params:set("clock_tempo",120)



--------------------------------------------------
--------------------  midi -----------------------
--------------------------------------------------

-- your norns screen shows the names, use any part of the name
-- e.g. if it says "op1 midi device" you can just write "op1"

-- cclfo(<name>,<cc>,<period>,<slo>,<shi>) sets a lfo on a cc value <cc>
-- with sine lfo with period <period> oscillating between <slo> and <shi>
cclfo("op1",1,7,50,80)
cclfo("op1",4,7.1,10,70)

-- play chord on measures 1 and 4
-- chords begin with uppercase letter and ":<octave>" denotes octave
play("op1","Abm/Eb:4",1)
play("op1","E:4",2)
play("op1","Gb/Db:4",3)
play("op1","Ebm:4",4)

-- play notes on measure 2
-- notes begin with lowercase letter
play("op1","e4 g#4 b4 g#4",2)

-- there are some apecial arrangement functions
-- arp(<notes>,<div>) will play an arpeggio of those <notes> at <div>
-- default <div> is 16
play("op1",arp("ab4 b4 eb4"),1)
-- arpr(<notes>,<div>) will play a random arp of <notes> at <div>
play("op1",arpr("e4 g#4 b4 e5 ."),2)
-- carp(<chord>,<div>) will play an arpeggio of the <chord> at <div>
play("op1",carp("Gb/Db:4"),3)
-- carp(<chord>,<div>) will play an random arp of the <chord> at <div>
play("op1",carpr("Ebm:4 Ebm:5"),4)

-- stop(<name>) will stop all patterns and notes for that instruments
stop("op1")




--------------------------------------------------
--------------------  crow -----------------------
--------------------------------------------------

-- crow can be commanded similar to midi
-- crow out 1 is pitch
-- crow out 2 is envelope, triggered on each note

-- define an envelope
crow.output[2].action="{ to(10,3),to(0,5) }";

-- play("crow",<notes>,<measure>) will play crow notes on
-- specified measure, as before with midi
-- the envelope is triggered on every note.
play("crow","ab1",1)
play("crow","ab3",1)
play("crow","gb4",3)
play("crow","bb4",5)
play("crow","eb5",7)
expand("crow",8)

crow.output[2].action="{ to(10,0),to(0,0.07) }"; crow.output[2]()
stop("crow"); play("crow",arpr("ab4 eb5 ab5"),1)

-- stop(<name>) will stop crow
stop("crow")

-- quick tuning!
-- this loads the tuner and sets the volts to 1
norns.script.load("code/tuner/tuner.lua"); crow.output[1].volts=3 -- A3; 



params:set("clock_tempo",125)

stop("op1")
play("op1","Dm",1)
play("op1","Am:3",2)
play("op1","Bb:3",3)
play("op1","C Am/C",4)
cclfo("op1",1,7,30,60)
cclfo("op1",4,7.1,10,60)

stop("op1")
crow.output[2].action="{ to(10,0.5),to(0.0,1.0) }";
stop("crow")
play("crow","f4 f4 . f4 f4 . .",1)
play("crow","e4 e4 f d d . .",2)
play("crow","g4 g4 f . .",3)
play("crow","e4 e4 f  e e . .",4)
play("crow","f4 f4 . f4 f4 . .",5)
play("crow","e4 e4 f d d . .",6)
play("crow","f4 g4",7)
play("crow","a4 a4",8)
crow.output[2].action="{ to(10,0.0),to(0,0.06) }";
stop("crow"); play("crow",arp("a4 a4 a4"),1)


stop("usb")
play("usb","d1 d1 a1 d d d1 a1 d",1)
play("usb","a1 a1 e1 a a e1 a1 e",2)
play("usb","bb1 bb f1 bb bb bb1 f1 bb",3)
play("usb","c1 c g c c a c1 a",4)
stop("usb")
play("usb",arpr("d2 a2 ."),1)
play("usb",arpr("a2 e2 a2 e1 f4 ."),2)
play("usb",arpr("bb2 bb2 bb2 bb2 f4 d3 ."),3)
play("usb",arpr("a3 e4 c2 c1 g4 ."),4)



-- one sample can be "quantized" and with glitch and reverse fx
-- e.wav(<id>,<filename>)
e.wav(2,wav("120_3")) 
-- e.rate(<id>,<rate>), can change rate to match bpm
e.rate(2,clock.get_tempo()/120)
-- beatsync(<id>,<num>) keeps sample containing <num> beats in sync
beatsync(2,8)
-- e.amp(<id>,<vol>) raises volume
e.amp(2,0.8)
-- e.pan(<id>,<pan>) will pan
e.pan(2,0.0)

-- once beat synced, you can do
-- glitching and reversing:
-- glitch(<prob>) glitch with probability <prob> (0,1)
glitch_prob(2,0.05)
-- reverse(<prob> reverses with probability <prob> (0,1)
reverse_prob(2,0.05)



