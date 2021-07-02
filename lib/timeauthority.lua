local TA={}

function TA:new(o)
  o=o or {} -- create object if user does not provide one
  setmetatable(o,self)
  self.__index=self
  o.patterns={}
  o.pulse=0
  o.sn=0
  o.qn=0
  o.measure=0
  o.last_command=""
  return o
end

function TA:step()
  self.pulse=self.pulse+1
  self.sn=self.sn+1
  if self.pulse>16 then
    self.pulse=1
    self.measure=self.measure+1
  end
  if self.pulse%4==1 then
    self.qn=self.qn+1
  end

  -- emit anything in the time authority
  local next_command=""
  for k,v in pairs(self.patterns) do
    local current=self.measure%#v+1
    if v[current][self.pulse]~="" then
      local cmd=v[current][self.pulse]
      if cmd~=nil then
        cmd=cmd:gsub("<qn>",self.qn)
        cmd=cmd:gsub("<sn>",self.sn)
        print(self.measure+1,self.qn,self.sn,self.pulse,k,cmd)
        next_command=string.format("%s %s/%s ",next_command,k,cmd)
        rc(cmd)
      end
    end
  end
  if next_command~="" then
    self.last_command=self.last_command..string.format("%d/%d/%d %s",self.measure+1,self.qn,self.pulse,next_command)
  end
end

function TA:get_last()
  local lc=self.last_command
  self.last_command=""
  return lc
end

-- add row or rows to the time authority for instrument s
function TA:add(s,t,i)
  if i~=nil then
    self:expand(s,i)
    if type(t[1])=="table" then
      for j,t2 in ipairs(t) do
        self.patterns[s][i+j-1]=t2
      end
    else
      self.patterns[s][i]=t
    end
    do return end
  end
  if self.patterns[s]==nil then
    self.patterns[s]={}
  end
  if type(t[1])=="table" then
    for _,t2 in ipairs(t) do
      table.insert(self.patterns[s],t2)
    end
  else
    table.insert(self.patterns[s],t)
  end
end

-- rm will remove instrument s from the time authority
function TA:rm(s,i)
  if self.patterns[s]==nil then
    do return end
  end
  if i~=nil then
    if self.patterns[s][i]==nil then
      do return end
    end
    self.patterns[s][i]={"","","","","","","","","","","","","","","",""}
  else
    self.patterns[s]=nil
  end
end

-- expand will expand instrument s to n rows
function TA:expand(s,n)
  if self.patterns[s]==nil then
    self.patterns[s]={}
  end
  for j=1,n do
    if self.patterns[s][j]==nil then
      self.patterns[s][j]={"","","","","","","","","","","","","","","",""}
    end
  end
end


function TA:sound(s,ctx,ctxoff)
  local rays={}
  local lines=string.split(s,";")
  for i,line in ipairs(lines) do
    local words=string.split(line," ")
    local ray=er("-",#words)
    local cmds={}
    local cmdsoff={}
    local last_midi=nil
    for j,word in ipairs(words) do
      local cmd=""
      local cmdoff={}
      if word~="." then
        local notes,note_len=music.to_midi(word,last_midi)
        for ni,note in ipairs(notes) do
          last_midi=note.m
          for _,ctxn in ipairs({"m","v","f","n"}) do
            if string.find(ctx,"<"..ctxn..">") then
              cmd=cmd..ctx:gsub("<"..ctxn..">",note[ctxn])..";"
              if ni==1 and note_len>0 and ctxoff~=nil then
                cmdoff={cmd=ctxoff:gsub("<"..ctxn..">",note[ctxn])..";",offset=note_len}
              end
            end
          end
        end
      end
      table.insert(cmds,cmd)
      table.insert(cmdsoff,cmdoff)
    end
    local k=1
    for j,rayw in ipairs(ray) do
      if rayw~="" then
        ray[j]=cmds[k]
        k=k+1
      end
    end
    local k=0
    local toadd={}
    for j,rayw in ipairs(ray) do
      if rayw~="" then
        k=k+1
        if cmdsoff[k]~=nil and cmdsoff[k].cmd~=nil then
          local m=cmdsoff[k].offset+j
          if m<16 then
            if ray[m]~="" then
              ray[m]=";"..ray[m]
            end
            table.insert(toadd,{pos=m,cmd=cmdsoff[k].cmd})
          end
        end
      end
    end
    for i,v in ipairs(toadd) do
      ray[v.pos]=v.cmd..ray[v.pos]
    end
    table.insert(rays,ray)
  end

  if #rays==1 then
    return rays[1]
  else
    return rays
  end
end

return TA
