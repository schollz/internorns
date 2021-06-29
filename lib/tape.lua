local tape={
  bnds={1,1,90,90,180,180,270,270},
  levels={0.5,0.5,0.5},
  rates={1,1,1},
  slews={1,1,1},
}

function tape:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  self:reset()
  return o
end


function tape:init()
  -- setup three stereo loops
  softcut.reset()
  softcut.buffer_clear()
  audio.level_eng_cut(1)
  audio.level_tape_cut(1)
  audio.level_adc_cut(1)
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
    softcut.loop_start(i,self.bnds[i])
    softcut.loop_end(i,self.bnds[i+2])
    softcut.position(i,self.bnds[i])
    softcut.loop(i,1)

    softcut.level_slew_time(i,0.4)
    softcut.rate_slew_time(i,0.4)

    softcut.rec_level(i,0.0)
    softcut.pre_level(i,1.0)
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

function tape:loop(i,start,stop)
  for j=i*2-1,i*2 do
    softcut.loop_start(j,self.bnds[j]+start)
    softcut.loop_end(j,self.bnds[j]+stop)
    softcut.position(j,self.bnds[j]+start)
  end
end

function tape:stop(i)
  for j=i*2-1,i*2 do
    softcut.rate(j,0)
    softcut.level(j,0)
  end
end

function tape:rate(i,r)
  self.rates[i]=r
  for j=i*2-1,i*2 do
    softcut.rate(j,r)
  end
end

function tape:rec(i,v,v2)
  for j=i*2-1,i*2 do
    softcut.rec_level(j,v)
    softcut.pre_level(j,v2)
  end
end

function tape:slew(i,v)
  self.slews[i]=v
  for j=i*2-1,i*2 do
    softcut.rate_slew_time(j,v)
    softcut.level_slew_time(j,v)
  end
end

function tape:level(i,v)
  self.levels[i]=v
  for j=i*2-1,i*2 do
    softcut.level(j,v)
  end
end

function tape:pan(i,v)
  i1=i*2-1
  i2=i*2
  v=v*2
  if v>0 then
    softcut.pan(i*2,util.clamp(v-1,-1,1))
    softcut.pan(i*2-1,1)
  else
    softcut.pan(i*2,-1)
    softcut.pan(i*2-1,util.clamp(1+v,-1,1))
  end
end

function tape:start(i)
  for j=i*2-1,i*2 do
    softcut.rate_slew_time(j,0)
    softcut.rate(j,self.rates[i])
    softcut.level(j,self.levels[i])
    clock.run(function()
      clock.sleep(0.5)
      softcut.rate_slew_time(j,self.slews[i])
    end)
  end
end

function tape:seek(i,pos)
  for j=i*2-1,i*2 do
    softcut.position(j,self.bnds[j]+pos)
  end
end

return tape
