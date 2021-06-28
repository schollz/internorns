local tape={}

function tape:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.midis={}
  o.names={}
  for _,dev in pairs(midi.devices) do
    local name=string.lower(dev.name)
    name=name:gsub("-","")
    table.insert(o.names,name)
    print("connected to "..name)
    o.midis[name]={notes={}}
    o.midis[name].conn=midi.connect(dev.port)
  end
  return o
end


function tape:reset()
  -- setup three stereo loops
  softcut.reset()
  softcut.buffer_clear()
  for i=1,6 do
    softcut.enable(i,1)
    softcut.level(i,0.5)

    if i%2==1 then
      softcut.pan(i,1)
      softcut.buffer(i,1)
      softcut.level_input_cut(1,i,1)
      softcut.level_input_cut(2,i,0)
    else
      softcut.pan(i,-1)
      softcut.buffer(i,2)
      softcut.level_input_cut(1,i,0)
      softcut.level_input_cut(2,i,1)
    end

    softcut.rec(i,1)
    softcut.play(i,1)
    softcut.rate(i,1)
    softcut.loop_start(i,loop_start)
    softcut.loop_end(i,loop_start+loop_length)
    softcut.loop(i,1)

    softcut.level_slew_time(i,0.4)
    softcut.rate_slew_time(i,0.4)

    softcut.rec_level(i,0.0)
    softcut.pre_level(i,1.0)
    softcut.position(i,loop_start)
    softcut.phase_quant(i,0.025)

    softcut.post_filter_dry(i,0.0)
    softcut.post_filter_lp(i,1.0)
    softcut.post_filter_rq(i,1.0)
    softcut.post_filter_fc(i,20000)

    softcut.pre_filter_dry(i,1.0)
    softcut.pre_filter_lp(i,1.0)
    softcut.pre_filter_rq(i,1.0)
    softcut.pre_filter_fc(i,20000)
  end
end


function tape:ismidi(name)
  for k,v in pairs(self.midis) do
    if string.find(k,name) then
      do return true end
    end
  end
  return false
end

function tape:on(name,note,r)
  for k,v in pairs(self.midis) do
    if string.find(k,name) then
      -- turn off all previous notes
      self:off(k,r)
      -- turn on
      print(name.." playing "..note)
      self.midis[k].conn:note_on(note,127)
      self.midis[k].notes[note]=r
    end
  end
end

function tape:cc(name,cc,val)
  for k,v in pairs(self.midis) do
    if string.find(k,name) then
      print("sending cc to "..k)
      self.midis[k].conn:cc(cc,math.floor(val))
    end
  end
end

function tape:off(name,r)
  for k,v in pairs(self.midis) do
    if string.find(k,name) then
      local devname=k
      for note,noter in pairs(self.midis[devname].notes) do
        if noter~=r then
          print(name.." stopping "..note)
          self.midis[devname].conn:note_off(note)
          self.midis[devname].notes[note]=nil
        end
      end
    end
  end
end


return tape
