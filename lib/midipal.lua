local midipal={}

function midipal:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.midis={}
  o.names={}
  o.events={}
  for _,dev in pairs(midi.devices) do
    local name=string.lower(dev.name)
    name=name:gsub("-","")
    table.insert(o.names,name)
    print("connected to "..name)
    o.midis[name]={notes={}}
    o.midis[name].conn=midi.connect(dev.port)
    o.midis[name].conn.event=function(data)
      local d=midi.to_msg(data)
      if d.ch~=nil and d.type~="clock" then
        for _,ev in ipairs(o.events) do
          if ev.name==name and ev.ch==d.ch then
            ev.func(d)
          end
        end
      end
    end
  end
  return o
end

--- Pads str to length len with char from right
string.lpad=function(str,len,char)
  if char==nil then char=' ' end
  return str..string.rep(char,len-#str)
end

-- hook will hook up midi notes from one midi device to another
function midipal:hook(midiin,out)
  -- midiin = {name="op-z",ch=1}
  -- out = {name="op-z" (optional), ch=1 (optional), note_on=..., note_off=.., crow=..}
  midiin.name=self:get_name(midiin.name)
  if midiin.name==nil then
    print("no hook available")
    do return end
  end
  out.name=self:get_name(out.name)

  local event={}
  event.name=midiin.name
  event.ch=midiin.ch
  event.func=function(d)
    if d.type=="note_on" then
      if out.name~=nil then
        self.midis[out.name].conn:note_on(d.note,d.velocity,out.ch)
      end
      if out.note_on~=nil then
        out.note_on(d.note,d.velocity,d.ch)
      end
      if out.crowout~=nil then
        crow.output[out.crowout].volts=(d.note-21)/12
        crow.output[out.crowout+1]()
      end
    elseif d.type=="note_off" then
      if out.name~=nil then
        self.midis[out.name].conn:note_off(d.note,d.velocity,out.ch)
      end
      if out.note_off~=nil then
        out.note_off(d.note,d.velocity,d.ch)
      end
      if out.crowout~=nil then
        crow.output[out.crowout].volts=(d.note-21)/12
        crow.output[out.crowout+1]()
      end
    elseif d.type=="cc" then
      if out.cc~=nil then
        out.cc(d.cc,d.val,d.ch)
      end
    end
  end
  -- add new event
  table.insert(self.events,event)
end

function midipal:get_name(name)
  if name==nil then 
    do return nil end 
  end
  for k,v in pairs(self.midis) do
    if string.find(k,name) then
      do return k end
    end
  end
  return nil
end

function midipal:print()
  print("---------------------------")
  print("| connnected midi devices |")
  print("---------------------------")
  for _,name in ipairs(self.names) do
    print(string.format("| - %s |",string.lpad(name,21," ")))
  end
  print("---------------------------")
end

function midipal:ismidi(name)
  for k,v in pairs(self.midis) do
    if string.find(k,name) then
      do return true end
    end
  end
  return false
end

function midipal:on(name,note,r)
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

function midipal:cc(name,cc,val)
  for k,v in pairs(self.midis) do
    if string.find(k,name) then
      print("sending cc to "..k)
      self.midis[k].conn:cc(cc,math.floor(val))
    end
  end
end

function midipal:off(name,r)
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

return midipal
