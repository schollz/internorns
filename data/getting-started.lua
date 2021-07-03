--------------------------------------------------
------------------ beginning ---------------------
--------------------------------------------------

-- each line in this file is valid lua code
-- if in maiden:
-- you can run it by selecting it and pressing Ctl+Enter 
-- or just press Ctl+Enter and it will run the current line

-- highlight and run this code, it should print "hello, world"
print("hello, world")

-- lets load internorns
norns.script.load("code/internorns/internorns.lua")

-- lets change the tempo to 120
params:set("clock_tempo",120)

-- the norns deck has special functions in addition to regular lua
-- that harness a built-in drum machine, a 6-voice sampler, and sequencer
-- nature(<vol>) is one example, it plays nature sounds
nature(1.0)

-- a very useful function is the s(..) function
-- s(<lua>,<n>) returns a table with 16-steps, where
-- <n> steps contain the <lua>, spaced according to an euclidean rhythm
table.print(s("print('hi')",4))

-- another useful function is the play(..) function
-- play(<ptn>,<s>,<measure>) specifies a pattern named <ptn>
-- which contains the <s> data (16 steps of code) for measure <measure>
-- the <measure> is optional, and if omitted will just add to current measure
play("hello",s("print('hi')",4),1)

-- stop(<ptn>) will stop the pattern named <ptn>
stop("hello")

-- example:
-- lfo(<period>,<slo>,<shi>) returns value of a sine function with period
-- <period> that oscillates between <slo> and <shi>
play("hello",s("print('lfo='..lfo(10,1,100))",4),1)

--------------------------------------------------
---------------  built-in drums ------------------
--------------------------------------------------

-- if you use play(..) with <ptn> named with any of the following:
-- "kick" or "clap" or "sd" or "hh" or "oh",
-- it will utilize the built-in drums 

-- we can use s(..) without the lua code to sequence these drums
-- s(<n>) function creates 16-step euclidean rhythm the number "1" in <n> places
-- e.g., s(4) = {1,,,,1,,,,1,,,,1,,,}
table.print(s(4))

-- example, lets play a kick
play("kick",s(2),1)
-- more: http://norns.local/maiden/#edit/dust/code/internorns/lib/drummer.lua

-- regular lua commands work
-- built-in drums have a bunch of properties you can modify
kick.patch.distAmt=60;
kick.patch.level=-5;
clap.patch.level=-2;
hh.patch.level=-5;

-- lets sequence some lua code
-- "kicklfo" is an arbitrary name, but we will
-- use s(..) to sequence lua that change the patch
play("kicklfo",s("kick.patch.oscDcy=lfo(12,400,1200)",4),1)
play("kicklfo2",s("kick.patch.distAmt=lfo(13,1,60)",4),1)

-- s_add(<s1>,<s2>) will combine these tables of steps
-- s_rot(<s>,<amt>) will rotate a steps by <amt>
play("kick",s_add(s(1),s_rot(s(1),3)),2)


-- s_sub(<s1>,<s2>) will subtract <s2> from <s1>
play("hh",s_sub(s(15),s(4)),1)
play("hhlfo",s("hh.patch.nEnvDcy=lfo(13,90,450)",4),1)
play("clap",s_rot(s(2),4),1)

-- stop(<ptn>) will stop pattern named <ptn>
stop("kick")
stop("clap")
stop("hh")


--------------------------------------------------
------------------  samples ----------------------
--------------------------------------------------

-- you can load up to 6 samples, which are continuously
-- running and can be seamlessly cut or looped

-- sample.open(<id>,<name>) loads 
-- /home/we/dust/audio/internorns/<name>.wav into sample <id>
sample.open(1,"closer")

-- sample.level(<id>,<vol>) sets volume for sample <id>
sample.level(1,0.5)

-- sample.pos(<id>,<pos>) sets position (in [0,1])
sample.pos(1,13/28)

-- sample.loop(<id>,<1>,<2>) sets loop points between
-- <1> and <2> (in range [0,1])
sample.loop(1,13.2/28,14.2/28)
sample.loop(1,0,1)

-- sample.pan(<id>,<pan>) sets pan (in [-1,1])
sample.pan(1,0)

-- set position every measure
play("closer",s("sample.pos(1,13/28)",1),1)
play("closerpan",s("sample.pan(1,lfo(6,-0.5,0.5))",8),1)
-- set position every 16 measures
expand("closer",16)
stop("closer")

-- one sample can be "quantized" and with glitch and reverse fx
sample.open(2,"120_4")
sample.level(2,0.5)
-- sample.rate(<id>,<rate>), can change rate to match bpm
sample.rate(2,clock.get_tempo()/120)
-- sample.sync(<id>,<num>) keeps sample containing <num> beats in sync
sample.sync(2,8)

-- once beat synced, you can do
-- glitching and reversing:
-- sample.glitch(<id>,<prob>) glitch with probability <prob> (0,1)
sample.glitch(2,0.02)
-- sample.reverse(<id>,<prob>) reverses with probability <prob> (0,1)
sample.reverse(2,0.1)

-- sample.level(<id>,0) will turn off the samples
sample.level(1,0)
sample.level(2,0)


--------------------------------------------------
----------------------- tape ---------------------
--------------------------------------------------

-- "tape" is a special utility that keeps a 
-- buffer of everything in the engine
-- and can do tape breaks/stops/starts

-- all stop in a stylish way
tape.stop()
-- all start, after running all stop
tape.start()
-- all break breaks everything
tape.freeze()

-- put them together
clock.run(function() clock.sync(2);tape.stop();clock.sync(6);tape.start() end)
clock.run(function() clock.sync(2);tape.freeze();clock.sync(2);tape.freeze() end)



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
------------------ mx.samples---------------------
--------------------------------------------------

-- mx.samples can be played directly
-- define instrument using "mx/<instrument_name>/<other_params>"
play("mx/steinway_model_b/amp=1.0,attack=0","Abm/Eb:4",1)
play("mx/steinway_model_b/amp=1.0,attack=0","E:4",2)
play("mx/steinway_model_b/amp=1.0,attack=0.0","Gb/Db:4",3)
play("mx/steinway_model_b/amp=1.0,attack=0.0","Ebm:4",4)
stop("mx/steinway_model_b")

play("mx/kalimba/amp=1.2,attack=0.0,release=0.1",arp("ab4 b4 eb4",8),1)
play("mx/kalimba/amp=1.2,attack=0.0,release=0.1",arpr("e4 g#4 b4 e5 .",8),2)
play("mx/kalimba/amp=1.2,attack=0.0,release=0.1",carp("Gb/Db:4",8),3)
play("mx/kalimba/amp=1.2,attack=0.0,release=0.1",carpr("Ebm:4 Ebm:3",8),4)
stop("mx/kalimba")

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
-- this loads the tuner and sets the volts to 3 (A3)
norns.script.load("code/tuner/tuner.lua"); crow.output[1].volts=3 -- A3; 


--------------------------------------------------
---------------------- ooo -----------------------
--------------------------------------------------

-- ooo is like oooooo - it is a wrapper around softcut
-- that allows you to playback/record anything playing.
-- ooo only allow three loops,
-- each 90 seconds, of stereo audio.

-- ooo.start(<tape>) starts the tape.
-- <tape> can be 1, 2, or 3
-- will start playing at that last rate (default 1)
-- if recording is active, it will record
ooo.start(1)

-- ooo.stop(<tape>) stops the tape
-- <tape> can be 1, 2, or 3
ooo.stop(1)

-- ooo.pan(<tape>,<pan>) changes the pan
-- <tape> can be 1, 2, or 3
-- <pan> is between -1 and 1
ooo.pan(1,1)

-- ooo.rate(<tape>,<rate>) changes the rate
-- <tape> can be 1, 2, or 3
-- <rate> can be from -? to +?
ooo.rate(1,1)

-- ooo.level(<tape>,<level>) changes the rate
-- <tape> can be 1, 2, or 3
-- <level> can be from 0 to 1
ooo.level(1,1)

-- ooo.slew(<tape>,<slew>) changes the slew of rate/level/pan/rec
-- <tape> can be 1, 2, or 3
-- <slew> can be from 0 to ??
ooo.slew(1,4)

-- ooo.rec(<tape>,<rec_level>,<pre_level>) activates/deactivates recording
-- which will record at level <rec_leve> and keep previous material
-- at <pre_level>
-- both levels can be from 0 to 1
-- example: turn on recording with full overdub
ooo.rec(1,1,0.0)
-- example: turn off recording (keepinpp 100% of previous recordings)
ooo.rec(1,0,1)
-- example: record and only keep 50% of the previous recordings
ooo.rec(1,1,0.5)

-- ooo.rec(<tape>,<loop_end>,<loop_end>) creates a loop between
-- <loop_start> and <loop_end> (denoted in seconds). 
-- both points can be between 0 and 90 (90-second max)
ooo.loop(1,0,2) -- a two-second loop between timestamps 0 and 2s, on tape 1

-- example:
-- a delay!
ooo.level(1,0.25); ooo.start(1);ooo.loop(1,0,clock.get_beat_sec()/2);ooo.rec(1,1,0.1);
ooo.pan(1,0)
ooo.stop(1)

-- you can add lfos to the loops easily
play("loopy",s("ooo.pan(1,lfo(3.5,-1,1))",16),1)
stop("loopy")
