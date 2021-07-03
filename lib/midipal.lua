local midipal={}

function midipal:new(o)
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

--- Pads str to length len with char from right
string.lpad = function(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

function midipal:print()
  for _, name in ipairs(self.names) do
    print("---------------------------")
    print("| connnected midi devices |")
    print("---------------------------")
    print(string.format("| - %s |",string.lpad(name,21," ")))
    print("---------------------------")
  end
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
