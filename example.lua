norns.script.load("code/gatherum/live.lua")

-- nature(volume)
nature(1.0)

-- tape stops
tapestop()
tapestart()
tapebreak()
clock.run(function() clock.sleep(1.5);tapestop();clock.sleep(2.5);tapestart() end)
clock.run(function() clock.sleep(1.5);tapebreak();clock.sleep(1.5);tapebreak() end)

-- clock
params:set("clock_tempo",165)

-- drums
-- "kick", "oh", "hh", "sd", "clap" are available
play("kick",er(1),1)
play("kick",er_add(er(1),rot(er(1),3)),2)
play("kicklfo",er("kick.patch.distAmt=lfo(10,1,80)",12))
stop("kick")

play("hh",er_sub(er(8),er(4)),1)
stop("hh")

play("clap",rot(er(2),4),1)
stop("clap")

-- sample
-- e.sload(<bufnum>,<file>) loads <file> into <bufnum>
-- wav(<name>) loads /home/we/dust/audio/nornsdeck/<name>.wav
e.sload(1,wav("closer"));
play("closer",er("e.spos(1,0)",1),1)
expand("closer",8)
e.samp(1,0.5)