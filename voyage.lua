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

function init()
  mg=plonky:new({grid_on=true,toggleable=true})

  drawing=metro.init()
  drawing.time=0.1
  drawing.count=-1
  drawing.event=function()
    redraw()
  end
  drawing:start()

  inject_param_method_extensions(params,{
    read=function(filename,name)
      mg:reset_toggles()
    end,
  })
end


function cleanup()
  uninject_param_method_extensions(params)
  params:clear()
end


function enc(k,d)
  if k==3 and mg.grid64 then do return end end
if k==1 then
    mg:update_voice_step(sign(d))
  elseif k>1 and params:get((k-1+mg.voice_set).."record")==0 then
    -- toggle arp/latch
    d=sign(d)
    arplatch=util.clamp(arplatch+d,0,3)
    if arplatch==0 then
      params:set((k-1+mg.voice_set).."arp",0)
      params:set((k-1+mg.voice_set).."latch",0)
      params:set((k-1+mg.voice_set).."mute_non_arp",0)
    elseif arplatch==1 then
      params:set((k-1+mg.voice_set).."arp",1)
      params:set((k-1+mg.voice_set).."latch",0)
      params:set((k-1+mg.voice_set).."mute_non_arp",0)
    elseif arplatch==2 then
      params:set((k-1+mg.voice_set).."arp",1)
      params:set((k-1+mg.voice_set).."latch",1)
      params:set((k-1+mg.voice_set).."mute_non_arp",0)
    else
      params:set((k-1+mg.voice_set).."arp",1)
      params:set((k-1+mg.voice_set).."latch",1)
      params:set((k-1+mg.voice_set).."mute_non_arp",1)
    end
  elseif k>1 and params:get((k-1+mg.voice_set).."record")==1 then
    mg.voices[(k-1+mg.voice_set)].record_step_adj=util.clamp(mg.voices[(k-1+mg.voice_set)].record_step_adj+sign(d),-1*mg.voices[(k-1+mg.voice_set)].record_step,0)
    print("mg.voices[k-1].record_step_adj",mg.voices[(k-1+mg.voice_set)].record_step_adj)
  end
end

function key(k,z)
  if k==3 and mg.grid64 then do return end end
if k==1 then
    shift=z==1
  elseif shift and z==1 then
    params:delta((k-1+mg.voice_set).."record")
    params:set((k-1+mg.voice_set).."play",0)
  elseif params:get((k-1+mg.voice_set).."record")==1 and z==1 then
    mg:record_add_rest_or_legato(k-1+mg.voice_set)
  elseif z==1 then -- stop/start
    params:delta((k-1+mg.voice_set).."play")
    params:set((k-1+mg.voice_set).."record",0)
  end
end


function redraw()
  screen.clear()
  screen.level(1)
  if shift then
    screen.level(15)
  end
  screen.move(64,1)
  screen.line(64,64)
  screen.stroke()
  screen.move(65,1)
  screen.line(65,64)
  screen.stroke()
  screen.level(0)
  for i=0,1 do
    screen.move(64+i,10)
    screen.line(64+i,36)
    screen.stroke()
  end
  screen.level(15)
  local imax=2
  if mg.grid64 then
    imax=1
  end
  for i=1,imax do
    screen.font_size(8)

    if params:get(i.."record")==1 then
      screen.move(26+72*(i-1),10)
      screen.text_center(mg:get_cluster(i+mg.voice_set))
    else
      screen.move(26+72*(i-1),10)
      screen.text_center(mg.voices[i+mg.voice_set].current_note)
    end
    screen.move(30+72*(i-1),54)
    if params:get(i+mg.voice_set.."play")==1 then
      screen.text_center("playing")
    elseif params:get(i+mg.voice_set.."record")==1 then
      screen.text_center("recording")
    end
    screen.move(30+72*(i-1),63)
    if params:get(i+mg.voice_set.."arp")==1 and params:get(i+mg.voice_set.."latch")==1 and params:get(i+mg.voice_set.."mute_non_arp")==1 then
      screen.text_center("arp+latch only")
    elseif params:get(i+mg.voice_set.."arp")==1 and params:get(i+mg.voice_set.."latch")==1 then
      screen.text_center("arp+latch")
    elseif params:get(i+mg.voice_set.."arp")==1 then
      screen.text_center("arp")
    end
    -- show the voice number
    screen.level(7)
    if shift then
      screen.level(15)
    end
    screen.font_size(14)
    screen.move(52+16*(i-1),34)
    screen.text(i+mg.voice_set)
    screen.move(63,22)
    screen.text_center("voice")
    screen.level(15)
    if shift then
      screen.level(4)
    end
    screen.move(28+72*(i-1),46)
    screen.font_size(48)
    if params:get(i+mg.voice_set.."record")==1 then
      screen.text_center(mg.voices[i+mg.voice_set].record_step+mg.voices[i+mg.voice_set].record_step_adj+1)
    else
      screen.text_center(mg.voices[i+mg.voice_set].play_step)
    end

  end
  screen.update()
end

-- general utilities

function rerun()
  norns.script.load(norns.state.script)
end

function sign(x)
  if x>0 then
    return 1
  elseif x<0 then
    return-1
  else
    return 0
  end
end


-- from https://github.com/tlubke/shapes/blob/049b6ef68dd80c04e2181ef349afee2939784fe5/shapes.lua
function clone_function(fn)
  local dumped=string.dump(fn)
  local cloned=load(dumped)
  local i=1
  while true do
    local name=debug.getupvalue(fn,i)
    if not name then
      break
    end
    debug.upvaluejoin(cloned,i,fn,i)
    i=i+1
  end
  return cloned
end

function inject_param_method_extensions(pset,fns)
  -- extend paramset:write()
  if pset.write2==nil then
    pset.write2=clone_function(pset.write)
    pset.write=function(paramset,filename,name)
      pset:write2(filename,name)
      if fns.write~=nil then
        fns.write(filename,name)
      end
    end
  end

  -- extend paramset:read()
  if pset.read2==nil then
    pset.read2=clone_function(pset.read)
    pset.read=function(paramset,filename)
      pset:read2(filename)
      if fns.read~=nil then
        fns.read(filename,name)
      end
    end
  end
end

function uninject_param_method_extensions(pset)
  -- reverse paramset:write() extension
  if pset.write2~=nil then
    pset.write=clone_function(pset.write2)
    pset.write2=nil
  end

  -- reverse paramset:read() extension
  if pset.read2~=nil then
    pset.read=clone_function(pset.read2)
    pset.read2=nil
  end
end

