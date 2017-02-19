module JFSM

const fsm = joinpath(dirname(@__FILE__), "..", "deps", "FSM")

export FsmType

export run_fsm

include("run_fsm.jl")

end
