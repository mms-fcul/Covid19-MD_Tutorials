load min1.pdb
load min2.pdb
cmd.hide("(solvent and (all))")
sel Na, resn NA*
cmd.hide("(Na and (all))")
cmd.disable('Na')
sel Prot1, min1 and chain A
sel Prot2, min2 and chain A
cmd.disable('Prot2')
align Prot2, Prot1
sel ligand, resn O6K
cmd.disable('ligand')
cmd.show("spheres"   ,"ligand")
set sphere_scale, 0.8

cmd.select("ligand","(byres (ligand around 5))",enable=1)
cmd.show("sticks"    ,"ligand")
cmd.hide("((byres (ligand))&(bb.&!(n. CA|n. N&r. PRO)))")
cmd.hide("(solvent and (ligand))")
cmd.disable('ligand')

set_view (\
    0.672535598,   -0.577913582,   -0.462287009,\
    0.032471038,    0.647099495,   -0.761712074,\
    0.739352286,    0.497266412,    0.453964263,\
   -0.000100151,   -0.000087008, -226.159362793,\
   82.004028320,   79.966133118,   37.524158478,\
  139.232284546,  313.112548828,  -20.000000000 )

