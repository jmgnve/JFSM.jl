module JFSM

using Plots

const fsm = joinpath(dirname(@__FILE__), "..", "deps", "FSM")

export test_run

include("run_fsm.jl")

end # module
