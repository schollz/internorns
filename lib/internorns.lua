
function internorns_init()
  print("initializing internorns")
  audio.level_monitor(0)

  os.execute("mkdir -p /home/we/dust/audio/internorns/")
  os.execute("cp -u /home/we/dust/code/internorns/data/*.wav /home/we/dust/audio/internorns/")
  os.execute("mkdir -p /home/we/dust/data/internorns")
  os.execute("cp -u /home/we/dust/code/internorns/data/getting-started.lua /home/we/dust/data/internorns/")

  local drummer=include("internorns/lib/drummer")
  local patches_=include("internorns/lib/patches")
  local patches=patches_:new()
  local patches_loaded=patches:load("/home/we/dust/code/internorns/data/default.mtpreset")
  kick=drummer:new({id=1})
  sd=drummer:new({id=2})
  hh=drummer:new({id=3})
  oh=drummer:new({id=4})
  clap=drummer:new({id=5})
  kick:update_patch_manually(patches_loaded[1])
  sd:update_patch_manually(patches_loaded[2])
  hh:update_patch_manually(patches_loaded[3])
  oh:update_patch_manually(patches_loaded[4])
  clap:update_patch_manually(patches_loaded[5])
  kick.patch.oscDcy=500
  kick.patch.level=-1
  hh.patch.level=1
  clap.patch.level=0

  -- scheduling
  sched=lattice:new{
    ppqn=16
  }
  local redrawer=1
  sched:new_pattern({
    action=function(t)
      ta:step()
      redrawer=redrawer+1
      if redrawer%10==0 then
        redraw()
      end
    end,
    division=1/16,
  })

  ooo.reset()

  -- start scheduler
  ta:start()
  sched:start()

end
