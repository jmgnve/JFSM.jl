using JFSM
using Base.Test

# Load driving data

metdata = readdlm(joinpath(Pkg.dir("JFSM"), "data\\met_CdP_0506.txt"), Float32);

# Model data

md = FsmType();

# Run model

hs = run_fsm(md, metdata);

# Tests

@test minimum(hs) >= 0

