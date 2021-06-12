-- run any line with Ctl+enter
-- each line is valid lua
-- special functions are available to make it easier

-------------------- restart  -----------------------

norns.script.load("code/nornsdeck/nornsdeck.lua")

-------------------- nature  -----------------------

nature(0.0)


------------------ built-in drums -------------------

-- "kick", "oh", "hh", "sd", "clap" are available
-- drums are unaffected by the tape

-- er(<n>) creates 16-step euclidean rhythm with <n> beats
table.print(er(4))
-- prints: {1,,,,1,,,,1,,,,1,,,}

-- play(<ptn>,<er>,<measure>) will set pattern <ptn> to play 
-- the <er> rhythm on measure <measure>
play("kick",er(2),1)

-- er(<lua>,<n>) creates a 16-step rhythm with <n> beats 
-- that stores a <lua> command on each beat
table.print(er("print('hi')",4))
play("hello",er("print('hi')",4),1)
-- lets makae some lfos
play("kicklfo",er("kick.patch.oscDcy=lfo(12,400,1200)",4),1)
play("kicklfo2",er("kick.patch.distAmt=lfo(13,1,40)",4),1)

-- er_add(<er1>,<er2>) will combine two rhythms
-- rot(<er>,<amt>) will rotate a rhythm <er> by <amt>
play("kick",er_add(er(1),rot(er(1),3)),2)


-- er_sub(<er1>,<er2>) will subtract <er2> from <er1>
play("hh",er_sub(er(9),er(4)),1)
play("hhlfo",er("hh.patch.nEnvDcy=lfo(13,90,150)",4),1)

-- regular lua commands work
clap.patch.level=-8
play("clap",rot(er(2),4),1)

-- stop(<ptn>) will stop pattern named <ptn>
stop("kick")
stop("clap")
stop("hh")

-------------------- samples -----------------------

-- e = engine, it is quicker
-- e.sload(<bufnum>,<file>) loads <file> into <bufnum>
-- wav(<name>) loads /home/we/dust/audio/nornsdeck/<name>.wav
e.sload(1,wav("closer"))
-- set volume
e.samp(1,0.25)
-- set position (0,1)
e.spos(1,0) 
-- set position every measure
play("closer",er("e.spos(1,0)",1),1)
-- set position every 8 measures
expand("closer",8)


--------------- quantized samples -------------------

-- one sample can be "quantized" and with glitch and reverse fx

-- e.bload(<file>,<tempo>,<filetempo>) loads <file> at <filetempo> and plays it at <tempo>
-- wav(<name>) loads /home/we/dust/audio/nornsdeck/<name>.wav
e.bload(wav("120_1"),clock.get_tempo(),120) 

-- e.bamp(<vol>) raises volume
e.bamp(0.25)

-- beatsync(<num>) keeps sample containing <num> beats in sync
beatsync(8)

-- glitch(<prob>) glitch with probability <prob> (0,1)
glitch_prob(0.2)

-- reverse(<prob> reverses with probability <prob> (0,1)
reverse_prob(0.1)

-- turn off by setting volume to 0
e.bamp(0.0)

-------------------- tape  -----------------------

-- (nature and drums are not affected by tape)

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

-------------------- midi -----------------------

-- your norns screen shows the names, use any part of the name
-- e.g. if it says "op1 midi device" you can just write "op1"

-- play chord on measure 1
play("op1","G/B:3",1)

-- play a note on measure 1
play("op1","b2",1)

-- play multiple notes on measure 2
-- note distances are determined by euclidean rhythm
play("op1","b2 c2",2)

-- arp(<notes>,<num>) plays random arpegio with <notes> string of <num> notes
play("op1",arp("f#5 c#5 e5 .",8),1)

-- stop(<ptn>) stops the pattern
stop("op1")


-------------------- crow -----------------------

-- crow can be commanded similarly
-- crow out 1 is pitch
-- crow out 2 is envelope

-- define an envelope
crow.output[2].action="{ to(10,2),to(0,6) }"; crow.output[2]()

-- play("crow",<notes>,<measure>) will play crow notes on
-- specified measure, as before with midi
-- the envelope is triggered on every note.
play("crow","ab3",1)
play("crow","db4",3)
play("crow",". eb4",5)
play("crow","gb4",7)
play("crow","gb4",8)
