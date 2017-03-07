module JFSM

const fsm = joinpath(dirname(@__FILE__), "..", "deps", "FSM")

export FsmType, FsmInput

export run_fsm

export q_noise, timecorr_noise, resample, perturb_input

export precip_liquid, precip_solid

include("run_fsm.jl")
include("utils_pfilter.jl")
include("utils_meteo.jl")

end
