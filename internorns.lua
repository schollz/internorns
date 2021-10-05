-- internorns v1.2.0
-- live-coding all norns
--
-- llllllll.co/t/internorns
--
--
--
--    ▼ instructions below ▼
--
-- open maiden and edit 
-- dust/data/internorns/
--         getting-started.lua


local shift=false
local arplatch=0

-- internorns stuff
-- this order matters
include("internorns/lib/utils")
music=include("internorns/lib/music")
timeauthority_=include("internorns/lib/timeauthority")
ta=timeauthority_:new()
lattice=require("lattice")
midipal_=include("internorns/lib/midipal")
mp=midipal_:new()
include("internorns/lib/ooo")
e=engine
last_command=""
include("internorns/lib/internorns")
include("internorns/lib/shims")
mxsamples=include("mx.samples/lib/mx.samples")
mx=mxsamples:new()




engine.name="MxInternorns"

function init()
    internorns_init()
    print([[
 ___ __    _ _______ _______ ______   __    _ _______ ______   __    _ _______ 
|   |  |  | |       |       |    _ | |  |  | |       |    _ | |  |  | |       |
|   |   |_| |_     _|    ___|   | || |   |_| |   _   |   | || |   |_| |  _____|
|   |       | |   | |   |___|   |_||_|       |  | |  |   |_||_|       | |_____ 
|   |  _    | |   | |    ___|    __  |  _    |  |_|  |    __  |  _    |_____  |
|   | | |   | |   | |   |___|   |  | | | |   |       |   |  | | | |   |_____| |
|___|_|  |__| |___| |_______|___|  |_|_|  |__|_______|___|  |_|_|  |__|_______|

]])
    mp:print()

   --  clock.run(function()
			-- sample.open(1,"/home/we/dust/audio/opz/20210828/samplepacks/3-perc/04/172-16-100.wav") 
			-- sample.open(3,"/home/we/dust/audio/opz/20210828/samplepacks/1-kick/06/172-32-63.wav") 
			-- sample.open(2,"/home/we/dust/audio/opz/20210828/samplepacks/4-fx/06/all_the_time_ab.aif") 
			-- clock.sleep(0.5)
			-- -- sample.open(2,"opz/172-32-18")
			-- --
			-- -- -- -- drums
			-- hook({name="opz",ch=3},{note_on=function(note,vel,ch)  if math.random()<1.9 then  sample.level(1,0.5,0); sample.pos(1,(note-53)/16); sample.rate(1,1); end end})
			-- hook({name="opz",ch=3},{note_off=function(note,vel,ch)  sample.level(1,0,1); print("off") end})

			-- hook({name="opz",ch=1},{note_on=function(note,vel,ch)  if math.random()<1.9 then  sample.level(3,0.5,0); sample.pos(3,(note-53)/16); sample.rate(1,1); end end})
			-- hook({name="opz",ch=1},{note_off=function(note,vel,ch)  sample.level(3,0,1) end})
			-- -- sample.glitch(1,0.1)
			-- -- sample.reverse(1,0.1)

			-- -- -- vocals
			-- hook({name="opz",ch=4},{note_on=function(note,vel,ch) print((note-53)/16); sample.pos(2,(note-53)/16); sample.level(2,0.6,0) end})
			-- hook({name="opz",ch=4},{note_off=function(note,vel,ch)  sample.level(2,0,2) end})
			-- -- sample.glitch(2,0.1)
			-- -- sample.reverse(2,0.1)

			-- -- bass
			-- hook({name="opz",ch=5},{note_on=function(note,vel,ch) engine.bassnote(note,0.8,0.1,2);end})

			-- -- strings
			-- hook({name="opz",ch=8},{note_on=function(note,vel,ch) mx:on({name="string_spurs_swells",midi=note-12,velocity=120,amp=0.2}) end})
			-- hook({name="opz",ch=8},{note_off=function(note,vel,ch) mx:off({name="string_spurs_swells",midi=note-12})  end})
			-- hook({name="opz",ch=8},{note_on=function(note,vel,ch)  mx:on({name="sweep_violins",midi=note-12,velocity=120,amp=0.2}) end})
			-- hook({name="opz",ch=8},{note_off=function(note,vel,ch) mx:off({name="sweep_violins",midi=note-12})  end})

			-- -- lead piano
			-- hook({name="opz",ch=6},{note_on=function(note,vel,ch)  mx:on({name="fender_rhodes",midi=note-12,velocity=120,amp=1.3}) end})
			-- hook({name="opz",ch=6},{note_off=function(note,vel,ch) mx:off({name="fender_rhodes",midi=note-12})  end})
			-- --
			-- -- -- -- arp
			-- -- -- crow.output[2].action="{ to(10,0.005),to(0,0.02) }";crow.output[2]()
			-- -- -- crow.output[2].action="{ to(10,0.01),to(0,0.05) }";crow.output[2]()
			-- -- -- hook({name="opz",ch=7},{crowout=1})
   --  end)

   --  clock.run(function()
			-- sample.open(1,"/home/we/dust/audio/opz/20210916/samplepacks/2-snare/06/174-32-140.wav") 
			-- clock.sleep(0.5)
			-- -- sample.open(2,"opz/172-32-18")
			-- --
			-- -- -- -- drums
			-- hook({name="opz",ch=2},{note_on=function(note,vel,ch)  if math.random()<1.9 then print((note-53)/16); sample.level(1,0.5,0); sample.pos(1,(note-53)/16); sample.rate(1,1); end end})
			-- hook({name="opz",ch=2},{note_off=function(note,vel,ch)  sample.level(1,0,1); print("off") end})
			-- sample.glitch(1,0.1)
			-- sample.reverse(1,0.1)
			-- -- sample.level(1,0.5)

			-- -- -- -- vocals
			-- -- -- hook({name="opz",ch=4},{note_on=function(note,vel,ch) engine.amplag(1,0.01); sample.pos(1,(note-53)/16); sample.level(1,0.6) end})
			-- -- -- hook({name="opz",ch=4},{note_off=function(note,vel,ch)  engine.amplag(1,2); sample.level(1,0) end})
			-- --
			-- -- -- -- bass
			-- hook({name="opz",ch=5},{note_on=function(note,vel,ch) engine.bassnote(note,0.8,0.1,2);end})
			-- --
			-- -- strings
			-- hook({name="opz",ch=8},{note_on=function(note,vel,ch) mx:on({name="string_spurs_swells",midi=note-12,velocity=120,amp=0.2}) end})
			-- hook({name="opz",ch=8},{note_off=function(note,vel,ch) mx:off({name="string_spurs_swells",midi=note-12})  end})
			-- hook({name="opz",ch=8},{note_on=function(note,vel,ch)  mx:on({name="sweep_violins",midi=note-12,velocity=120,amp=0.2}) end})
			-- hook({name="opz",ch=8},{note_off=function(note,vel,ch) mx:off({name="sweep_violins",midi=note-12})  end})
			-- --
			-- -- -- -- lead piano
			-- hook({name="opz",ch=6},{note_on=function(note,vel,ch)  mx:on({name="fender_rhodes",midi=note-12,velocity=120,amp=1.3}) end})
			-- hook({name="opz",ch=6},{note_off=function(note,vel,ch) mx:off({name="fender_rhodes",midi=note-12})  end})
			-- --
			-- -- -- -- arp
			-- -- -- crow.output[2].action="{ to(10,0.005),to(0,0.02) }";crow.output[2]()
			-- -- -- crow.output[2].action="{ to(10,0.01),to(0,0.05) }";crow.output[2]()
			-- -- -- hook({name="opz",ch=7},{crowout=1})
   --  end)
end


function redraw()
  screen.clear()
  screen.font_size(6)
  local print_command=last_command..ta:get_last()
  for i,s in ipairs(string.wrap(print_command,36)) do
    screen.move(1,8+8*(i-1))
    screen.text(s)
  end
  if print_command=="" then
    screen.font_size(8)
    screen.move(64,8)
    screen.text_center("available midi:")
    for i,v in ipairs(mp.names) do
      screen.move(64,8+(10*i))
      screen.text_center(v)
    end
  end

  -- if uS.message~="" then
  --   screen.level(0)
  --   x=64
  --   y=28
  --   w=string.len(uS.message)*6
  --   screen.rect(x-w/2,y,w,10)
  --   screen.fill()
  --   screen.level(15)
  --   screen.rect(x-w/2,y,w,10)
  --   screen.stroke()
  --   screen.move(x,y+7)
  --   screen.text_center(uS.message)
  -- end

  screen.update()
end
