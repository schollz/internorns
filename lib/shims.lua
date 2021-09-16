function wav(s)
  return s
  --return "/home/we/dust/audio/internorns/"..s..".wav"
end

local nature_loaded=false
bass_attack=0.1
bass_decay=5
bass_volume=0.5

function nature(vol)
  if vol==nil then
    vol=0
  end
  if not nature_loaded then
    engine.wav(6,wav("nature"))
    nature_loaded=true
  end
  clock.run(function()
    clock.sleep(0.5)
    engine.amp(6,vol)
  end)
  if vol==0 then
    clock.run(function()
      clock.sleep(8)
      engine.free(6)
      nature_loaded=false
    end)
  end
end

function expand(name,num)
  ta:expand(name,num)
end

function cclfo(name,ccnum,period,slo,shi)
  ta:add(name..ccnum,s(string.format('mp:cc("%s",%d,lfo(%2.2f,%d,%d))',name,ccnum,period,slo,shi),12),1)
end

function play(name,notes,i)
  print(string.sub(name,1,3))
  if name=="crow" then
    ta:add(name,ta:sound(notes,'crow.output[1].volts=<v>;crow.output[2]()'),i)
  elseif string.sub(name,1,3)=="mx/" then
    print(name)
    local foo=string.split(name,"/")
    if foo[3]==nil then
      foo[3]=""
    else
      foo[3]=","..foo[3]
    end
    print("mx:on({name='"..foo[2].."',midi=<m>,velocity=80"..foo[3].."})")
    ta:add(foo[1].."/"..foo[2],ta:sound(notes,
      "mx:on({name='"..foo[2].."',midi=<m>,velocity=80"..foo[3].."})",
    "mx:off({name='"..foo[2].."',midi=<m>})"),i)
  elseif name=="bass" then
    ta:add(name,ta:sound(notes,"engine.bassnote(<m>,bass_volume,bass_attack,bass_decay)"),i)
  elseif name=="piano" then
    ta:add(name,ta:sound(notes,"engine.pianonote(<m>)"),i)
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

xfade={}
xfade.measures=4

function xfade.rec(measures)
  xfade.measures=measures
  local beats=measures*4
  ta:add("xfaderec",s('print("xfade: recording loop");engine.xloop_rec(clock.get_tempo(),'..beats..'); ta:rm("xfaderec")',1),1)
  ta:expand("xfaderec",measures)
end

function xfade.buffer()
  ta.next='print("xfade: on"); engine.tapeamp(0); engine.xloop(clock.get_tempo(),xfade.measures*4,(ta.measure%xfade.measures)*4+((ta.pulse-1)/4));'
end

function xfade.live()
  ta.next='print("xfade: off"); engine.tapeamp(1);engine.xloop_off()'
end

tape={}

function tape.freeze()
  engine.tapebreak()
end

function tape.stop()
  engine.tapebreak()
  engine.taperate(0.01)
end

function tape.start()
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
  for _,ss in ipairs(t) do
    local notes=music.to_midi(ss)
    for _,n in ipairs(notes) do
      table.insert(notearray,string.lower(n.n))
    end
  end
  return arp(table.concat(notearray," "),num)
end

function carpr(s,num)
  local t=string.split(s)
  local notearray={}
  for _,ss in ipairs(t) do
    local notes=music.to_midi(ss)
    for _,n in ipairs(notes) do
      table.insert(notearray,string.lower(n.n))
    end
  end
  return arpr(table.concat(notearray," "),num)
end

sample={}

sample.memrate={}
sample.memsynced={}
sample.memclock={}

function sample.loop(i,u,v)
  engine.loop(i,u,v)
end

function sample.pos(i,v)
  if sample.memsynced[i]~=nil then
    local current_tempo=clock.get_tempo()
    if sample.memclock[i]==nil then
      sample.memclock[i]=current_tempo
    end
    if current_tempo~=sample.memclock[i] then
      sample.memclock[i]=current_tempo
      sample.rate(i,clock.get_tempo()/sample.memsynced[i])
    end
  end
  engine.pos(i,v,sample.memrate[i])
end

function sample.level(i,v,slew)
  if slew==nil then
    slew=0
  end
  engine.amp(i,v,slew)
end

function sample.open(i,v)
  sample.memrate[i]=1
  engine.wav(i,wav(v))
end

function sample.pan(i,v)
  engine.pan(i,v)
end

function sample.rate(i,v)
  sample.memrate[i]=v
  engine.rate(i,v)
end

function sample.release(i)
  engine.release(i)
end

function sample.reverse_rate(i)
  engine.rate(i,-1*sample.memrate[i])
end

function sample.sync(i,bpm,totalbeats)
  if bpm==nil then
    sample.memsynced[i]=nil
    ta:rm("bb"..i)
    do return end
  end
  sample.memsynced[i]=bpm
  sample.rate(i,clock.get_tempo()/bpm)
  local v=totalbeats*4
  ta:add("bb"..i,s("if math.random()<0.5 then sample.pos("..i..",(<sn>-1)%"..v.."/"..v..") end",4),1)
end

function sample.reverse(i,v)
  if v==nil then
    ta:rm("bbr"..i)
    do return end
  end
  play("bbr"..i,s("if math.random()<"..v.." then sample.reverse_rate("..i..") end",5))
end

function sample.glitch(i,v)
  if v==nil then
    ta:rm("bbb"..i)
    do return end
  end
  ta:add("bbb"..i,s("if math.random()<"..v.." then; v=math.random(); engine.loop("..i..",v,v+math.random()/40+0.01) end",4),1)
end

function hook(midiin,out)
  mp:hook(midiin,out)
end

function fullstart()
  if not ta.running then
    print("starting")
    ta:start()
    sched:hard_restart()
  end
end

function fullstop()
  print("stopping")
  ta:stop()
end
