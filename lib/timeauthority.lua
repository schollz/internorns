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
        -- print(self.measure+1,self.qn,self.sn,self.pulse,k,cmd)
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

-- rc runs any code, even stupid code
function rc(code)
  local ok,f=pcall(load(code))
  if ok then
    if f~=nil then
      f()
    end
  else
    print(string.format("rc: could not run '%s': %s",code,f))
  end
end

-- returns an euclidean spaced array of "item"
function er(item,num,size)
  if size==nil then
    size=16
  end
  if num==nil then
	  num=item
item="1"
  end
  local ray={}
  local bucket=0
  for i=1,size do
    ray[size+1-i]=""
    bucket=bucket+num
    if bucket>=size then
      bucket=bucket-size
      ray[size+1-i]=item
    end
  end
  return ray
end


-- adds two arrays
function er_add(t,t2)
  local t3={}
  for i,v1 in ipairs(t) do
    local v2=t2[i]
    if v1~="" then
      table.insert(t3,v1)
    else
      table.insert(t3,v2)
    end
  end
  return t3
end

-- subtract two arrays
function er_sub(t,t2)
  local t3={}
  for i,v1 in ipairs(t) do
    local v2=t2[i]
    if v1~="" and v2~="" then
      table.insert(t3,"")
    else
      table.insert(t3,v1)
    end
  end
  return t3
end

-- rotates an array by amt
function rot(t,amt)
  local rotated={}
  for i=#t-amt+1,#t do
    table.insert(rotated,t[i])
  end
  for i=1,#t-amt do
    table.insert(rotated,t[i])
  end
  return rotated
end


function sound(s,ctx)
  local rays={}
  local lines=string.split(s,";")
  for i,line in ipairs(lines) do
    local words=string.split(line," ")
    local ray=er("-",#words)
    local cmds={}
    for j,word in ipairs(words) do
      local cmd=""
      if word~="." then
        local notes=music.to_midi(word)
        for _,note in ipairs(notes) do
          for _,ctxn in ipairs({"m","v","f","n"}) do
            if string.find(ctx,"<"..ctxn..">") then
              cmd=cmd..ctx:gsub("<"..ctxn..">",note[ctxn])..";"
            end
          end
        end
      end
      table.insert(cmds,cmd)

    end
    local k=1
    for j,rayw in ipairs(ray) do
      if rayw=="-" then
        ray[j]=cmds[k]
        k=k+1
      end
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
