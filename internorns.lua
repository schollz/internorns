-- plonky v1.4.0
-- keyboard + sequencer
--
-- llllllll.co/t/plonky
--
--
--
--    ▼ instructions below ▼
--
-- e1 changes voice
-- k1+(k2 or k3) records pattern
-- k2 or k3 plays pattern
-- (e2 or e3) changes latch/arp


local plonky=include("plonky/lib/plonky")
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
