--------------------------------------------------
-------------------- welome ----------------------
--------------------------------------------------

-- run any line with Ctl+enter
-- each line is valid lua
-- special functions are available to make it easier

--------------------------------------------------
-------------------- restart ---------------------
--------------------------------------------------

norns.script.load("code/nornsdeck/nornsdeck.lua")


--------------------------------------------------
-------------------- nature ----------------------
--------------------------------------------------

-- nature is an example of a special function

-- nature(<vol>) sets nature sounds to volume <vol>
nature(1.0)

--------------------------------------------------
---------------  built-in drums ------------------
--------------------------------------------------

-- er(<n>) creates 16-step euclidean rhythm with <n> beats
-- e.g., er(4) = {1,,,,1,,,,1,,,,1,,,}
table.print(er(4))

-- play(<ptn>,<er>,<measure>) will set pattern <ptn> to play 
-- the <er> rhythm on measure <measure>
play("kick",er(2),1)

-- er(<lua>,<n>) creates a 16-step rhythm with <n> beats 
-- that stores a <lua> command on each beat
table.print(er("print('hi')",4))
play("hello",er("print('hi')",4),1)
-- use er(..) to make lfos
play("kicklfo",er("kick.patch.oscDcy=lfo(12,400,1200)",4),1)
play("kicklfo2",er("kick.patch.distAmt=lfo(13,1,40)",4),1)

-- er_add(<er1>,<er2>) will combine two rhythms
-- rot(<er>,<amt>) will rotate a rhythm <er> by <amt>
play("kick",er_add(er(1),rot(er(1),3)),2)


-- er_sub(<er1>,<er2>) will subtract <er2> from <er1>
play("hh",er_sub(er(15),er(4)),1)
play("hhlfo",er("hh.patch.nEnvDcy=lfo(13,90,150)",4),1)

-- regular lua commands work
hh.patch.level=-10
clap.patch.level=-8
play("clap",rot(er(2),4),1)

-- stop(<ptn>) will stop pattern named <ptn>
stop("kick")
stop("clap")
stop("hh")


--------------------------------------------------
------------------  samples ----------------------
--------------------------------------------------

-- e = engine, it is quicker
-- e.wav(<bufnum>,<file>) loads <file> into <bufnum>
-- wav(<name>) loads /home/we/dust/audio/nornsdeck/<name>.wav
e.wav(1,wav("closer"))
-- set volume
e.amp(1,0.25)
-- set position (0,1)
e.pos(1,0.5) 
-- set position every measure
play("closer",er("e.spos(1,0)",1),1)
-- set position every 8 measures
expand("closer",8)


-- one sample can be "quantized" and with glitch and reverse fx
e.wav(2,wav("120_1")) 
-- change rate to match bpm
e.rate(2,clock.get_tempo()/120)
-- e.bamp(<vol>) raises volume
e.amp(2,0.15)
-- beatsync(<num>) keeps sample containing <num> beats in sync
beatsync(2,8)
-- once beat synced, you can do
-- glitching and reversing:
-- glitch(<prob>) glitch with probability <prob> (0,1)
glitch_prob(2,0.01)
-- reverse(<prob> reverses with probability <prob> (0,1)
reverse_prob(2,0.01)

-- turn off by setting volume to 0
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
-- midi                                         --
-- easily play outboard gear, set ccs           --
--------------------------------------------------


-- your norns screen shows the names, use any part of the name
-- e.g. if it says "op1 midi device" you can just write "op1"

-- play chord on measures 1 and 4
-- chords begin with uppercase letter and ":<octave>" denotes octave
play("op1","Abm/Eb:3",1)
play("op1","Ebm:3",4)

-- play notes on measure 2
-- notes begin with lowercase letter
play("bou","e3 g#3 b3 g#3",2)

-- arp(<notes>,<num>) plays random arpegio with <notes> string of <num> notes
play("op1",arp("gb3 bb3 db3 .",8),3)

-- cclfo(<name>,<cc>,<period>,<slo>,<shi>) sets a lfo on a cc value <cc>
-- with sine lfo with period <period> oscillating between <slo> and <shi>
cclfo("op1",1,11,60,80)
cclfo("op1",4,3,10,60)

-- stop(<name>) will stop all patterns and notes for that instruments
stop("op1")


--------------------------------------------------
-- crow                                         --
-- easily play outboard gear, set ccs           --
--------------------------------------------------

-- crow can be commanded similarly
-- crow out 1 is pitch
-- crow out 2 is envelope

-- define an envelope
crow.output[2].action="{ to(10,2),to(0,6) }"; crow.output[2]()

-- play("crow",<notes>,<measure>) will play crow notes on
-- specified measure, as before with midi
-- the envelope is triggered on every note.
play("crow","ab3",1)
play("crow","gb3",3)
play("crow","eb4",4)

-- stop(<name>) will stop crow
stop("crow")