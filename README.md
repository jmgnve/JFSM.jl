# JFSM

[![Build Status](https://travis-ci.org/jmgnve/JFSM.jl.svg?branch=master)](https://travis-ci.org/jmgnve/JFSM.jl)

[![Coverage Status](https://coveralls.io/repos/github/jmgnve/JFSM.jl/badge.svg?branch=master)](https://coveralls.io/github/jmgnve/JFSM.jl?branch=master)


[![Coverage Status](https://coveralls.io/repos/jmgnve/JFSM.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/jmgnve/JFSM.jl?branch=master)

[![codecov.io](http://codecov.io/github/jmgnve/JFSM.jl/coverage.svg?branch=master)](http://codecov.io/github/jmgnve/JFSM.jl?branch=master)

Julia wrapper for the Factorial Snow Model (original code available on this [homepage](https://github.com/RichardEssery/FSM)). For installing the package, run the following code:

```julia
Pkg.clone("https://github.com/jmgnve/JFSM.jl")
```

The example below runs one model combination and plots the results (requires the PyPlot.jl and Plots.jl packages).

```julia
using JFSM
using PyPlot

am = 0;
cm = 0;
dm = 0;
em = 0;
hm = 0;

metdata = readdlm(joinpath(Pkg.dir("JFSM"), "data\\met_CdP_0506.txt"), Float32);

md = FsmType(am, cm, dm, em, hm);

hs = run_fsm(md, metdata);

plot(hs)

```

The example folder contains code for running all model combinations and also a simple particle filter implementation:

```julia
cd(joinpath(Pkg.dir("JFSM"), "examples"))

include("run_all_combinations.jl")

include("test_pfilter.jl")
```






