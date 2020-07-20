/cmd.set('bg_rgb',0,'',0)

load traj.pdb, init
util.color_deep("gray80", 'init', 0)
util.cnc("init",_self=cmd)
cmd.dss("init")

sel ligand, resn O6K
cmd.disable('ligand')
cmd.show("spheres"   ,"ligand")
set sphere_scale, 0.8
util.color_deep("forest", 'ligand', 0)
util.cnc("ligand",_self=cmd)

cmd.select("ligand","(byres (ligand around 5))",enable=1)
cmd.show("sticks"    ,"ligand")
cmd.hide("((byres (ligand))&(bb.&!(n. CA|n. N&r. PRO)))")
cmd.hide("(solvent and (ligand))")
cmd.disable('ligand')

#/cmd.set('movie_fps',5.0,'',0)
#smooth init, 25, 5

set_view (\
     0.710883975,   -0.486547977,   -0.507851303,\
     0.176332861,    0.822326541,   -0.541002393,\
     0.680845439,    0.295036942,    0.670374274,\
    -0.000145553,   -0.000157952, -226.153640747,\
    83.648757935,   76.023117065,   35.596557617,\
   139.232284546,  313.112548828,  -20.000000000 )
