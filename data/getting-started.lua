--------------------------------------------------
------------------ beginning ---------------------
--------------------------------------------------

-- each line in this file is valid lua code
-- if in maiden or vs code:
-- you can run it by selecting it and pressing Ctl+Enter
-- or just press Ctl+Enter and it will run the current line

-- highlight and run this code, it should print "hello, world"
print("hello, world")

-- lets load internorns
norns.script.load("code/internorns/internorns.lua")

-- lets change the tempo to 120
params:set("clock_tempo",120)

-- internorns has special functions in addition to regular lua
-- that harness a built-in drum machine, a 6-voice sampler, and sequencer
-- one such function:
-- nature(<vol>) plays nature sounds at volume <vol>
nature(0.5) -- turns on
nature(0.0) -- turns off

-- a very useful function is the s(..) function
-- s(<lua>,<n>) returns a table with 16 values - 1 value for
-- each 16th note in a measure.
-- the <lua> code you put will be spaced out in this table
-- according to a euclidean pattern with <n> entries
table.print(s("print('hi')",4))

-- the s(..) function becomes most useful when combined with play(..)
-- play(<ptn>,<s>,<measure>) specifies a pattern named <ptn>
-- which contains the <s> data (16 steps of code) for measure <measure>
-- the <measure> is optional, and if omitted will just add to current measure
-- the following will run `print('hi')` on each beat (4 times per measure)
-- on measure 1
play("hello",s("print('hi')",4),1)

-- stop(<ptn>) will stop the pattern named <ptn>
stop("hello")

-- lfo(<period>,<slo>,<shi>) returns value of a sine function with period
-- <period> that oscillates between <slo> and <shi>
print(lfo(10,1,100))

-- example: combine the lfo and the print statement to print out
-- a lfo number every 4 beats
play("hello",s("print('lfo='..lfo(10,1,100))",4),1)

--------------------------------------------------
------------  stop/start sequencer ---------------
--------------------------------------------------

-- by default the sequencer starts when internorns starts
-- you can stop and start it with:

fullstop()

fullstart()

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

-- built-in drums have a bunch of properties you can modify via .patch
-- level    [-10,10] level (dB)
-- distAmt  [0,100] dist amt
-- eQFreq   [20,20000] eq freq
-- eQGain   [-10,10] eq gain
-- oscAtk   [0,10]  oscillator attack
-- oscDcy   [0,10]  oscillator decay
-- nEnvAtk  [0,10]  noise attack
-- nEnvDcy  [0,10]  noise decay
-- mix      [0,100] 0 = oscillator, 100 = only noise
kick.patch.distAmt=60
kick.patch.level=-5
kick.patch.oscDcy=0.9

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

-- you can load up to ?? samples, which are continuously
-- running and can be seamlessly cut or looped

-- sample.open(<id>,<name>) loads
-- /home/we/dust/audio/internorns/<name>.wav into sample <id>
-- note: need to load sample before running other commands
-- in a block
sample.open(1,"closer")

-- sample.level(<id>,<vol>) sets volume for sample <id>
sample.level(1,0.5)

-- sample.pos(<id>,<pos>) sets position (in [0,1])
sample.pos(1,0)

-- sample.rate(<id>,<rate>) changes rate
sample.rate(1,-1)

-- sample.loop(<id>,<1>,<2>) sets loop points between
-- <1> and <2> (in range [0,1])
sample.loop(1,0.7,0.9)
sample.loop(1,0,1)

-- sample.pan(<id>,<pan>) sets pan (in [-1,1])
sample.pan(1,0)
-- example: lfo on the pan
play("closerpan",s("sample.pan(1,lfo(6,-0.5,0.5))",8),1)

-- set position every 8 measures by setting the first measure and then
-- expanding to 8 measures
play("closerpos",s("sample.pos(1,0)",1),1)
expand("closerpos",8)

-- quantizing samples
-- samples can easily be quantized to allow you to keep
-- a sample perfectly in sync with the norns internal clock
-- this is useful for drum loops or other specific loops.
-- to utilize, make sure you have a loop with known bpm and
-- known number of beats.

-- you can easily quantize samples, e.g. drums, to the beat of the norns
sample.open(2,"120_8") -- opens /home/we/dust/audio/internorns/120_4.wav
-- drum beat at 120bpm for 8 beats

-- turn up the volume
sample.level(2,0.4)

-- sample.sync(<id>,<source_bpm>,<source_beats>) keeps sample synced with tempo
-- given the <source_bpm> and the <source_beats>
sample.sync(2,120,8) -- the source loop has 8 beats at 120 bpm (i.e. 4 seconds long)
sample.sync(2) -- turns off syncing

-- example: another beat
sample.open(2,"165_8") -- opens /home/we/dust/audio/internorns/165_8.wav
sample.sync(2,165,8) -- syncs to source of 165 bpm and 8 beats

-- it will stay in sync even if you change the clock!
params:set("clock_tempo",130)

-- once beat synced, you can do
-- glitching and reversing:
-- sample.glitch(<id>,<prob>) glitch with probability <prob> (0,1)
sample.glitch(2,0.1)
sample.glitch(2) -- turns off glitching

-- sample.reverse(<id>,<prob>) reverses with probability <prob> (0,1)
sample.reverse(2,0.1)
sample.reverse(2) -- turns off reversing

-- sample.level(<id>,0) will turn off the samples
sample.level(1,0)
sample.level(2,0)

-- you can also "release" a sample which will unload and and save cpu
sample.release(1)
sample.release(2)

--------------------------------------------------
--------------------  midi -----------------------
--------------------------------------------------

-- when you start internorns, you will see a list of
-- available midi devices in the console and on the norns.
-- you can use any part of their name as the <name> to designate it.
-- i.e. if you see "op1 usb device" you can simply write "op1".

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
------------------- midi hooks -------------------
--------------------------------------------------


norns.script.load("code/internorns/internorns.lua")


-- midi hooks allow you to easily funnel messages
-- between midi devices

-- send note events from op-z to op-1
hook({name="opz",ch=1},{name="op1",ch=1})

-- midi can use crow as well (pitch/envelope)
-- and multiple hooks can be assigned to the same device
hook({name="opz",ch=1},{crowout=1})

-- midi hooks allow customizable hooks as well
hook({name="opz",ch=5},{note_on=function(note,vel,ch) engine.bassamp(0.2);engine.bassnote(note);end})
hook({name="opz",ch=5},{note_off=function(note,vel,ch) engine.bassamp(0) end})
play("basslfo",s("engine.bassamp(lfo(10.13,0.3,0.6))",4),1)
play("basslfo2",s("engine.basslpf(lfo(7.13,2,4))",4),1)

-- in this example we can use a full stop to stop the sequencer
-- and have the op-z activate internorns on the first note
fullstop()
hook({name="opz",ch=1},{note_on=function(note,vel,ch) fullstart() end})
hook({name="opz",ch=1},{cc=function(cc,val,ch) if val==0 and cc==123 then fullstop() end end})

-------------------------------------------------
------------------ mx.samples---------------------
--------------------------------------------------

-- mx.samples can be played directly
-- define instrument using "mx/<instrument_name>/<other_params>"
play("mx/steinway_model_b/amp=1.3,attack=0","Abm/Eb:4",1)
play("mx/steinway_model_b/amp=1.2,attack=0","E:4",2)
play("mx/steinway_model_b/amp=1.1,attack=0.0","Gb/Db:4",3)
play("mx/steinway_model_b/amp=1.2,attack=0.0","Ebm:4",4)

-- stopping only needs to refernce the first two parts
stop("mx/steinway_model_b")

play("mx/kalimba/amp=1.4,attack=0.0,release=0.1",arp("ab4 b4 eb4",8),1)
play("mx/kalimba/amp=1.2,attack=0.0,release=0.1",arpr("e4 g#4 b4 e5 .",8),2)
play("mx/kalimba/amp=1.3,attack=0.0,release=0.1",carp("Gb/Db:4",8),3)
play("mx/kalimba/amp=1.2,attack=0.0,release=0.1",carpr("Ebm:4 Ebm:3",8),4)

-- stopping only needs to refernce the first two parts
stop("mx/kalimba")

--------------------------------------------------
--------------------  crow -----------------------
--------------------------------------------------

-- any crow code can be used at any time.

-- if you use play("crow","<pitches>",<measure>)
-- you can automatically sequence pitches and trigger envelopes
-- crow out 1 is pitch
-- crow out 2 is envelope, triggered on each note

-- define an envelope
crow.output[2].action=string.format("{ to(10,%2.2f,exponential),to(0,%2.2f,exponential) }",(clock.get_beat_sec()*3),(clock.get_beat_sec()*2));

-- play("crow",<notes>,<measure>) will play crow notes on
-- specified measure, as before with midi
-- the envelope is triggered on every note.
play("crow","ab2",1)
play("crow","gb3",3)
play("crow","bb3",5)
play("crow","eb4",7)
expand("crow",8)

crow.output[2].action="{ to(10,0.0),to(0,0.07) }";crow.output[2]()
stop("crow");play("crow",arpr("ab4 eb5 ab5"),1)

-- stop(<name>) will stop crow
stop("crow")

-- quick tuning!
-- this one-liner will load the tuner and sets the volts to 3 (A3)
norns.script.load("code/tuner/tuner.lua");crow.output[1].volts=3 -- A3;

--------------------------------------------------
----------------------- tape ---------------------
--------------------------------------------------

-- "tape" is a special utility that keeps a
-- buffer of everything in the engine
-- and can do tape breaks/stops/starts

-- tape stop
tape.stop()
-- tape start, after a stop
tape.start()
-- tape free breaks everything
-- run it again to unfreeze
tape.freeze()

-- put them together
clock.run(function() clock.sync(2);tape.stop();clock.sync(8);tape.start() end)
clock.run(function() clock.sync(2);tape.freeze();clock.sync(2);tape.freeze() end)

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
ooo.level(1,0.1);ooo.start(1);ooo.loop(1,0,clock.get_beat_sec()/1);ooo.rec(1,1,0.1);
-- turn delay off
ooo.stop(1)

-- like everything else, you can sequence parameters of ooo
-- e.g., you can add lfos to the loops easily
play("loopy",s("ooo.pan(1,lfo(3.5,-1,1));ooo.level(1,lfo(3.3,0.2,0.8))",16),1)
stop("loopy")

--------------------------------------------------
----------------------- bass ---------------------
--------------------------------------------------

-- there is a built-in bass that you can access
-- via engine or using play:
play("bass","ab1",1)
play("bass","e1",2)
play("bass","gb1",3)
play("bass","eb1",4)

-- set globals for the bass attack and decay and volume
bass_attack=0
bass_decay=0.1
bass_volume=0.5

-- stop bass
stop("bass")

--------------------------------------------------
---------------------- piano ---------------------
--------------------------------------------------

-- synthesized piano
play("piano","Abm/Eb:4",1)
play("piano","E:4",2)
play("piano","Gb/Db:4",3)
play("piano","Ebm:4",4)

stop("piano")

--------------------------------------------------
---------------------- xfade ---------------------
--------------------------------------------------

-- record 4 measures of live input (in sync)
xfade.rec(4)

-- crossfades from live input to the recorded buffer
xfade.buffer()

-- crossfades from the recorded buffer to live input
xfade.live()
