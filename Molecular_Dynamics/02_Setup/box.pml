/cmd.set('bg_rgb',0,'',0)
load dode_solv.pdb, box
util.cba(154,"box",_self=cmd)
sel ligand, resn O6K
cmd.disable('ligand')
cmd.show("spheres"   ,"ligand")
set sphere_scale, 0.8
util.cba(33,"ligand",_self=cmd)

sel solvent, resn SOL
cmd.hide("lines"     ,"solvent_")
cmd.disable('solvent_')
show spheres, name OW
set sphere_scale, 0.15, name OW
util.color_deep("marine", 'solvent_', 0)

set_view (\
    -0.760618091,   -0.647607684,   -0.045359507,\
    -0.026038757,   -0.039381415,    0.998882473,\
    -0.648672521,    0.760953546,    0.013089151,\
     0.000621408,    0.000099808, -405.741729736,\
    73.883834839,   76.226196289,   35.777469635,\
   327.483581543,  483.975830078,  -20.000000000 )
