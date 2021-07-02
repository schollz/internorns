ooo = {}

local ooomem={
  bnds={1,1,90,90,180,180,270,270},
  levels={0.5,0.5,0.5},
  rates={1,1,1},
  slews={1,1,1},
}


function ooo.reset()
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
    softcut.loop_start(i,ooomem.bnds[i])
    softcut.loop_end(i,ooomem.bnds[i+2])
    softcut.position(i,ooomem.bnds[i])
    softcut.loop(i,1)

    softcut.level_slew_time(i,0.4)
    softcut.rate_slew_time(i,0.4)
    softcut.pan_slew_time(i,0.4)
    softcut.recpre_slew_time(i,0.4)

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

function ooo.loop(i,start,stop)
  for j=i*2-1,i*2 do
    softcut.loop_start(j,ooomem.bnds[j]+start)
    softcut.loop_end(j,ooomem.bnds[j]+stop)
    softcut.position(j,ooomem.bnds[j]+start)
  end
end

function ooo.stop(i)
  for j=i*2-1,i*2 do
    softcut.rate(j,0)
    softcut.level(j,0)
  end
end

function ooo.rate(i,r)
  ooomem.rates[i]=r
  for j=i*2-1,i*2 do
    softcut.rate(j,r)
  end
end

function ooo.rec(i,v,v2)
  for j=i*2-1,i*2 do
    softcut.rec_level(j,v)
    softcut.pre_level(j,v2)
  end
end

function ooo.slew(i,v)
  ooomem.slews[i]=v
  for j=i*2-1,i*2 do
    softcut.rate_slew_time(j,v)
    softcut.level_slew_time(j,v)
    softcut.pan_slew_time(j,v)
    softcut.recpre_slew_time(j,v)
  end
end

function ooo.level(i,v)
  ooomem.levels[i]=v
  for j=i*2-1,i*2 do
    softcut.level(j,v)
  end
end

function ooo.pan(i,v)
  v=v*2
  if v>0 then
    softcut.pan(i*2,util.clamp(v-1,-1,1))
    softcut.pan(i*2-1,1)
  else
    softcut.pan(i*2,-1)
    softcut.pan(i*2-1,util.clamp(1+v,-1,1))
  end
end

function ooo.start(i)
  for j=i*2-1,i*2 do
    softcut.rate_slew_time(j,0)
    softcut.rate(j,ooomem.rates[i])
    softcut.level(j,ooomem.levels[i])
    clock.run(function()
      clock.sleep(0.5)
      softcut.rate_slew_time(j,ooomem.slews[i])
    end)
  end
end

function ooo.seek(i,pos)
  for j=i*2-1,i*2 do
    softcut.position(j,ooomem.bnds[j]+pos)
  end
end

