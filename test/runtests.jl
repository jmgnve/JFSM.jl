using JFSM
using Base.Test

# Load driving data

metdata = readdlm(joinpath(dirname(@__FILE__), "..", "data", "met_CdP_0506.txt"), Float32);

# Load data from fortran run

valdata = readdlm(joinpath(dirname(@__FILE__), "..", "data", "out_CdP_0506.txt"), Float32);

# Model data

md = FsmType(0, 0, 0, 0, 0);

# Run model

hs_new = run_fsm(md, metdata);

# From fortran run

hs_old = valdata[:, 6];

# Tests

hs_new = round(hs_new, 3);
hs_old = round(hs_old, 3);

@test all(hs_new .== hs_old)
