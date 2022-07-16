from BigDFT.Systems import System
from BigDFT.Fragments import Fragment
from BigDFT.Atoms import Atom

at = Atom({"He": [0, 0, 0]})
frag = Fragment([at])
sys = System({"FRA:0": frag})

from BigDFT.Calculators import SystemCalculator
code = SystemCalculator()

from BigDFT.Inputfiles import Inputfile
inp = Inputfile()
inp.set_xc("PBE")
inp.set_hgrid(0.4)

log = code.run(sys=sys, input=inp)
print(log.energy)

