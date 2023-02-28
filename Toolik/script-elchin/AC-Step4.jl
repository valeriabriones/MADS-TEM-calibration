#STEP4
# parameters: nfall
# targets: VegStructuralNitrogen(Leaf,Stem,Root)[48:64]

import Mads
import PyCall
@show pwd()

PyCall.py"""

import sys,os
sys.path.append(os.path.join('/work','scripts'))
import TEM

def run_TEM(x):
    
    for j in range(len(dvmdostem.params)):
        dvmdostem.params[j]['val']=x[j]   
    # update param files
    dvmdostem.clean()
    dvmdostem.setup(calib=True)
    dvmdostem.update_params()
    dvmdostem.run()

    return dvmdostem.get_calibration_outputs()[48:64]

def get_param_targets():
    return dvmdostem.get_calibration_outputs(calib=True)[48:64]

dvmdostem=TEM.TEM_model()
dvmdostem.calib_mode='VEGC'
dvmdostem.opt_run_setup='--pr-yrs 100 --eq-yrs 200 --sp-yrs 0 --tr-yrs 0 --sc-yrs 0'
dvmdostem.set_params(cmtnum=5, params=['nfall(0)','nfall(0)','nfall(0)','nfall(0)','nfall(0)','nfall(0)','nfall(0)','nfall(0)', \
                                       'nfall(1)','nfall(1)','nfall(1)', \
                                       'nfall(2)','nfall(2)','nfall(2)','nfall(2)','nfall(2)'], \
                               pftnums=[0,1,2,3,4,5,6,7, \
                                        0,1,2, \
                                        0,1,2,3,4])
"""

initial_guess=[ 0.00001, 0.00002, 0.000014, 0.00007, 0.0001, 0.0010, 0.00353, 0.0001,
                0.000001, 0.000159, 0.000017,
                0.00001, 0.010048, 0.000008, 0.00688, 0.000013]

#y_init=PyCall.py"run_TEM"()

function TEM_pycall(parameters::AbstractVector)
        predictions = PyCall.py"run_TEM"(parameters)
        return predictions
end
obs=PyCall.py"get_param_targets"()
obs_time=1:length(obs)

md = Mads.createproblem(initial_guess, obs, TEM_pycall;
    paramkey=[
              "nfall00","nfall01","nfall02","nfall03","nfall04","nfall05","nfall06","nfall07",
              "nfall10","nfall11","nfall12",
              "nfall20","nfall21","nfall22","nfall23","nfall24"],
    paramdist=[
        "Uniform(1e-7, 0.2)","Uniform(1e-7, 0.2)","Uniform(1e-7, 0.2)","Uniform(1e-7, 0.2)","Uniform(1e-7, 0.2)",
        "Uniform(1e-7, 0.2)","Uniform(1e-7, 0.2)","Uniform(1e-7, 0.2)","Uniform(1e-7, 0.09)","Uniform(1e-7, 0.09)",
        "Uniform(1e-7, 0.09)","Uniform(1e-7, 0.09)","Uniform(1e-7, 0.09)","Uniform(1e-7, 0.09)","Uniform(1e-7, 0.09)",
        "Uniform(1e-7, 0.09)"],
    obstime=obs_time,
    paramlog=trues(16),
    problemname="Calibration_STEP4")

Mads.showparameters(md)
Mads.showobservations(md)

calib_param, calib_information = Mads.calibrate(md, tolOF=0.01, tolOFcount=4)

Mads.plotmatches(md, calib_param, 
                xtitle="# of observations", ytitle="VEGN",filename="Step4_matchplot.png")
