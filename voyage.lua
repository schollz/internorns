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

-----------
-- shims --
-----------

function nature(vol)
  if vol==nil then
    vol=0
  end
  engine.wav(4,wav("birds_eating"))
  engine.wav(5,wav("birds_morning"))
  engine.wav(6,wav("waves"))
  engine.amp(4,1*vol)
  engine.amp(5,2*vol)
  engine.amp(6,0.2*vol)
end

function expand(name,num)
  ta:expand(name,num)
end

function cclfo(name,ccnum,period,slo,shi)
  ta:add(name..ccnum,er(string.format('mp:cc("%s",%d,lfo(%2.2f,%d,%d))',name,ccnum,period,slo,shi),12),1)
end

function play(name,notes,i)
  if name=="crow" then
    ta:add(name,ta:sound(notes,'crow.output[1].volts=<v>;crow.output[2]()'),i)
  elseif name=="kick" or name=="hh" or name=="clap" or name=="sd" or name=="oh" then
    for i,v in ipairs(notes) do
      if v~="" then
        notes[i]=name..":hit()"
      end
    end
    ta:add(name,notes,i)
  elseif mp:ismidi(name) then
    ta:add(name,ta:sound(notes,"mp:on('"..name.."',<m>,<sn>)","mp:off('"..name.."',-1)"),i)
  else
    ta:add(name,notes,i)
  end
end

function stop(name)
  if mp:ismidi(name) then
    mp:off(name,-1)
  end
  ta:rm(name)
end

function tapebreak()
  engine.tapebreak()
end

function tapestop()
  engine.tapebreak()
  engine.taperate(0.01)
end

function tapestart()
  clock.run(function()
    engine.taperate(1)
    clock.sync(8)
    engine.tapebreak()
  end)
end

function arp(s,num)
  local t=string.split(s)
  if num==nil then
    num=16
  end
  local t2={}
  local tlen=#t
  for i=1,num do
    table.insert(t2,t[(i-1)%tlen+1])
  end
  return table.concat(t2," ")
end

function arpr(s,num)
  local t=string.split(s)
  if num==nil then
    num=16
  end
  local t2={}
  for i=1,num do
    table.insert(t2,t[math.random(#t)])
  end
  return table.concat(t2," ")
end

function carp(s,num)
  local t=string.split(s)
  local notearray={}
  for _, ss in ipairs(t) do
    local notes=music.to_midi(ss)
    for _, n in ipairs(notes) do
      table.insert(notearray,string.lower(n.n))
    end
  end
  return arp(table.concat(notearray," "),num)
end

function carpr(s,num)
  local t=string.split(s)
  local notearray={}
  for _, ss in ipairs(t) do
    local notes=music.to_midi(ss)
    for _, n in ipairs(notes) do
      table.insert(notearray,string.lower(n.n))
    end
  end
  return arpr(table.concat(notearray," "),num)
end

function reverse_prob(i,v)
  if v==nil then
    v=0
  end
  play("bbr",er("if math.random()<"..v.." then engine.reverse("..i..",1) end",5))
end

function glitch_prob(i,v)
  if v==nil then
    v=0
  end
  ta:add("bbb",er("if math.random()<"..v.." then; v=math.random(); engine.loop("..i..",v,v+math.random()/40+0.01) end",4),1)
end


function beatsync(i,totalbeats)
  local v = totalbeats*4
  ta:add("bb",er("if math.random()<0.5 then engine.pos("..i..",(<sn>-1)%"..v.."/"..v..") end",4),1)
end

function wav(s)
  return "/home/we/dust/audio/voyage/"..s..".wav"
end
