-- voyage v0.0.0
--
--

engine.name="NornsDeck"

-- this order matters
include("voyage/lib/utils")
include("voyage/lib/oooooo")
init_oooooo()
music=include("voyage/lib/music")
timeauthority_=include("voyage/lib/timeauthority")
ta=timeauthority_:new()
lattice=require("lattice")
midipal_=include("voyage/lib/midipal")
mp=midipal_:new()

e=engine
last_command=""

function init()
  audio.level_monitor(0)

  os.execute("mkdir -p /home/we/dust/audio/voyage/")
  os.execute("cp -u /home/we/dust/code/voyage/data/*.wav /home/we/dust/audio/voyage/")

  local drummer=include("voyage/lib/drummer")
  local patches_=include("voyage/lib/patches")
  local patches=patches_:new()
  local patches_loaded=patches:load("/home/we/dust/code/voyage/data/default.mtpreset")
  kick=drummer:new({id=1})
  sd=drummer:new({id=2})
  hh=drummer:new({id=3})
  oh=drummer:new({id=4})
  clap=drummer:new({id=5})
  kick:update_patch_manually(patches_loaded[1])
  sd:update_patch_manually(patches_loaded[2])
  hh:update_patch_manually(patches_loaded[3])
  oh:update_patch_manually(patches_loaded[4])
  clap:update_patch_manually(patches_loaded[5])
  kick.patch.oscDcy=500
  kick.patch.level=-1
  hh.patch.level=1
  clap.patch.level=0

  -- scheduling
  sched=lattice:new{
    ppqn=16
  }
  local redrawer=1
  sched:new_pattern({
    action=function(t)
      ta:step()
      redrawer=redrawer+1
      if redrawer%10==0 then
        redraw()
      end
    end,
    division=1/16,
  })


  -- and initiate recording on incoming audio on input 1
  p_amp_in=poll.set("amp_in_l")
  -- set period low when primed, default 1 second
  p_amp_in.time=1
  p_amp_in.callback=function(val)
    for i=1,6 do
      if uS.recording[i]==1 and (params:get("input type")==1 or params:get("input type")>=4) then
        if val>params:get("rec thresh")/10000 then
          tape_rec(i)
        end
      end
    end
  end
  p_amp_in:start()

  -- and initiate recording on incoming on audio input 2
  p_amp_in2=poll.set("amp_in_r")
  -- set period low when primed, default 1 second
  p_amp_in2.time=1
  p_amp_in2.callback=function(val)
    for i=1,6 do
      if uS.recording[i]==1 and (params:get("input type")==2 or params:get("input type")>=4) then
        if val>params:get("rec thresh")/10000 then
          tape_rec(i)
        end
      end
    end
  end
  p_amp_in2:start()


  -- start scheduler
  sched:start()
end

function key(k,z)
  if k==2 and z==1 then
    sched:start()
  elseif k==3 and z==1 then
    sched:stop()
  end
end

function redraw()
  screen.clear()
  screen.font_size(6)
  local print_command=last_command..ta:get_last()
  for i,s in ipairs(string.wrap(print_command,36)) do
    screen.move(1,8+8*(i-1))
    screen.text(s)
  end
  if last_command=="" then
    screen.font_size(8)
    screen.move(64,8)
    screen.text_center("available midi:")
    for i,v in ipairs(mp.names) do
      screen.move(64,8+(10*i))
      screen.text_center(v)
    end
  end

  if uS.message~="" then
    screen.level(0)
    x=64
    y=28
    w=string.len(uS.message)*6
    screen.rect(x-w/2,y,w,10)
    screen.fill()
    screen.level(15)
    screen.rect(x-w/2,y,w,10)
    screen.stroke()
    screen.move(x,y+7)
    screen.text_center(uS.message)
  end

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
