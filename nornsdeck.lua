-- nornsdeck v0.0.0
--
--

engine.name="NornsDeck"

-- this order matters
include("nornsdeck/lib/utils")
music=include("nornsdeck/lib/music")
timeauthority_=include("nornsdeck/lib/timeauthority")
ta=timeauthority_:new()
lattice=require("lattice")
midipal_=include("nornsdeck/lib/midipal")
mp=midipal_:new()

e=engine
last_command=""

function init()
  audio.level_monitor(0)

  os.execute("mkdir -p /home/we/dust/audio/nornsdeck/")
  os.execute("cp -u /home/we/dust/code/nornsdeck/data/*.wav /home/we/dust/audio/nornsdeck/")

  local drummer=include("nornsdeck/lib/drummer")
  local patches_=include("nornsdeck/lib/patches")
  local patches=patches_:new()
  local patches_loaded=patches:load("/home/we/dust/code/nornsdeck/data/default.mtpreset")
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
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end

-----------
-- shims --
-----------

local naturevol=-1
function nature(vol)
  if naturevol<0 then
    e.sload(2,wav("birds_eating"))
    e.sload(3,wav("birds_morning"))
    e.sload(4,wav("waves"))
  end
  if naturevol>0 then
    naturevol=0
  else
    naturevol=4
  end
  if vol~=nil then
    naturevol=vol
  end
  for i=2,4 do
    e.samp(i,6*vol/(i*i))
  end
end

function expand(name,num)
  ta:expand(name,num)
end

function cclfo(name,ccnum,period,slo,shi)
  ta:add(name..ccnum,er(string.format('mp:cc("%s",%d,lfo(%2.2f,%d,%d))',name,ccnum,period,slo,shi),12),1)
end

function play(name,notes,i)
  if name=="crow" then
    ta:add(name,sound(notes,'crow.output[1].volts=<v>;crow.output[2]()'),i)
  elseif name=="kick" or name=="hh" or name=="clap" or name=="sd" or name=="oh" then
    for i,v in ipairs(notes) do
      if v~="" then
        notes[i]=name..":hit()"
      end
    end
    ta:add(name,notes,i)
  elseif mp:ismidi(name) then
    ta:add(name,sound(notes,"mp:on('"..name.."',<m>,<sn>)"),i)
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
  e.bl()
end

function tapestop()
  e.bl()
  e.blrate(0.01)
end

function tapestart()
  clock.run(function()
    e.blrate(1)
    clock.sync(8)
    e.bl()
  end)
end

function arp(s,num)
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


function glitch(v)
  if v==nil then
    v=0
  end
  ta:add("bbb",er("if math.random()<"..v.." then; v=math.random(); e.bbreak(v,v+math.random()/40+0.01) end",4),1)
end


function beatsync(totalbeats)
  local v = totalbeats*4
  ta:add("bb",er("if math.random()<0.5 then e.bsync((<sn>-1)%"..v.."/"..v..") end",4),1)
end

function wav(s)
  return "/home/we/dust/audio/nornsdeck/"..s..".wav"
end