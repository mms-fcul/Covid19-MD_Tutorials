/cmd.set('bg_rgb',0,'',0)

load traj_all-skip10.pdb, traj
util.color_deep("gray90", 'traj', 0)
util.cnc("traj",_self=cmd)
cmd.dss("traj")
cmd.show("cartoon"   ,"traj")
cmd.hide("ribbon"    ,"traj")

sel ligand, resn O6K
cmd.disable('ligand')
cmd.show("spheres"   ,"ligand")
set sphere_scale, 0.8
util.color_deep("forest", 'ligand', 0)
util.cnc("ligand",_self=cmd)

sel chainA, resi 1-301
sel 13bA, resi 605
sel chainB, resi 302-604
sel 13bB, resi 606
cmd.disable('chainA')
cmd.disable('chainB')
cmd.disable('13bA')
cmd.disable('13bB')
util.color_deep("gray20", 'chainA', 0)
util.cnc("chainA",_self=cmd)

cmd.select("ligand","(byres (ligand around 5))",enable=1)
cmd.show("sticks"    ,"ligand")
cmd.hide("((byres (ligand))&(bb.&!(n. CA|n. N&r. PRO)))")
cmd.hide("(solvent and (ligand))")
cmd.disable('ligand')

/cmd.set('movie_fps',15.0,'',0)

smooth traj, 25, 5

set_view (\
     0.813408017,   -0.334831595,   -0.475660622,\
     0.229681209,    0.936148524,   -0.266214341,\
     0.534427941,    0.107288368,    0.838375807,\
     0.000048913,   -0.000139385, -226.153121948,\
    85.135375977,   75.252372742,   37.126396179,\
   -35.931407928,  488.276245117,  -20.000000000 )
