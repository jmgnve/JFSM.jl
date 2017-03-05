
using Distributions
using PyPlot

hs_obs = 0.2;
hs_sim = 0.0:0.01:2.0;

wk_old = Float64[];

for hs_tmp in hs_sim
  std_hs = 0.10*hs_obs;
  std_hs = max(std_hs,0.05);
  push!(wk_old, 1 / (sqrt(2*pi)*std_hs) * exp(-(hs_obs-hs_tmp).^2/(2*std_hs^2)));
end

wk_new = Float64[];

for hs_tmp in hs_sim
  push!(wk_new, pdf(Normal(hs_obs, max(0.1 * hs_obs, 0.05)), hs_tmp))
end

plot(collect(hs_sim), wk_new, "g")
plot(collect(hs_sim), wk_old, ":r")
