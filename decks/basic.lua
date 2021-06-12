-- run any line with Ctl+C
-- each line is valid lua
-- special functions are available to make it easier

-------------------- restart  -----------------------

norns.script.load("code/nornsdeck/nornsdeck.lua")

-------------------- nature  -----------------------

nature(1.0)

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


-------------------- drums -----------------------

-- "kick", "oh", "hh", "sd", "clap" are available
-- drums are unaffected by the tape

-- play(<ptn>,<er>,<measure>) will set pattern <ptn> to play the <er> rhythm on measure <measure>
-- er(<n>) creates 16-step euclidean rhythm with <n> beats
play("kick",er(2),1)

-- er(<lua>,<n>) creates a 16-step rhythm with <n> beats that run the <lua> command
play("kicklfo",er("kick.patch.distAmt=lfo(4,5,99)",4))

-- er_add(<er1>,<er2>) will combine two rhythms
-- rot(<er>,<amt>) will rotate a rhythm <er> by <amt>
play("kick",er_add(er(1),rot(er(1),3)),2)

-- stop(<ptn>) will stop pattern named <ptn>
stop("kick")

-- er_sub(<er1>,<er2>) will subtract <er2> from <er1>
play("hh",er_sub(er(8),er(4)),1)
stop("hh")

play("clap",rot(er(2),4),1)
stop("clap")

-------------------- samples -----------------------

-- e.sload(<bufnum>,<file>) loads <file> into <bufnum>
-- wav(<name>) loads /home/we/dust/audio/nornsdeck/<name>.wav
e.sload(1,wav("closer"))
-- set position
e.spos(1,0) 
-- set volume
e.samp(1,1)
-- set position every measure
play("closer",er("e.spos(1,0)",1),1)
-- set position every 8 measures
expand("closer",8)
