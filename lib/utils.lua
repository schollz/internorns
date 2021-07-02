function lfo(period,dlo,dhi)
  local m=math.sin(2*math.pi*os.time2()/period)
  return util.linlin(-1,1,dlo,dhi,m)
end

function os.time2()
  if clock~=nil then
    return clock.get_beat_sec()*clock.get_beats()
  else
    return os.time()
  end
end

function string.wrap(s,num)
  ss={}
  while #s>num do
    local s2=string.sub(s,1,num)
    table.insert(ss,s2)
    s=string.sub(s,num+1,#s)
    if s=="" then
      break
    end
  end
  return ss
end

function string.split(input_string,split_character)
  local s=split_character~=nil and split_character or "%s"
  local t={}
  if split_character=="" then
    for str in string.gmatch(input_string,".") do
      table.insert(t,str)
    end
  else
    for str in string.gmatch(input_string,"([^"..s.."]+)") do
      table.insert(t,str)
    end
  end
  return t
end

-- table.print prints the table
function table.print(t)
  local islist=false
  for k,v in pairs(t) do
    if type(k)=="number" then
      islist=true
    end
    break
  end
  if not islist then
    for k,v in pairs(t) do
      print(k,v)
    end
  else
    local s=""
    for i,v in ipairs(t) do
      if i==1 then
        s="{"..v
      else
        s=s..","..v
      end
    end
    s=s.."}"
    print(s)
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
function s(item,num,size)
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
function s_add(t,t2)
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
function s_sub(t,t2)
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
function s_rot(t,amt)
  local rotated={}
  for i=#t-amt+1,#t do
    table.insert(rotated,t[i])
  end
  for i=1,#t-amt do
    table.insert(rotated,t[i])
  end
  return rotated
end

--table.print(string.wrap("this is a long sentence",3))
--

function rerun()
  norns.script.load(norns.state.script)
end

