
# Load packages

using JFSM
using PyPlot
using Distributions

# States for time correlated noise

type q_noise
	q_SW::Float64
	q_LW::Float64
	q_P::Float64
	q_Ta::Float64
	q_RH::Float64
	q_Ua::Float64
end


# Time correlated noise

function timecorr_noise(q, timestep, timedecorr)

	alfa = 1 - timestep/timedecorr;

	q = alfa*q + sqrt(1-alfa^2)*randn();

	return q

end

# Resampling function

function resample(wk)

	Ns = length(wk);

	u = cumprod(rand(Ns) .^ (1./collect(Float64, Ns:-1:1)));

	u = u[length(u):-1:1];

	wc = cumsum(wk);

	label = zeros(Int64, Ns);

	k = 1;
	for i = 1:Ns
		while wc[k] < u[i]
			k = k + 1;
		end
		label[i] = k;
	end

	return label

end

# Load data

metdata = readdlm(joinpath(dirname(@__FILE__), "..", "data", "met_CdP_0506.txt"), Float32);
valdata = readdlm(joinpath(dirname(@__FILE__), "..", "data", "obs_CdP_0506.txt"), Float32);

valdata[valdata .== -99] = NaN;

dates_met = map(DateTime, metdata[:,1], metdata[:,2], metdata[:,3], metdata[:,4]);
dates_val = map(DateTime, valdata[:,1], valdata[:,2], valdata[:,3]);

# Settings

npart = 500;

ntimes = size(metdata,1);

# Initial states

md = [FsmType(1, 1, 1, 1, 0) for i in 1:npart];

q_vec = [q_noise(randn(), randn(), randn(), randn(), randn(), randn()) for i in 1:npart];

# Allocate input array

ip = Array(FsmInput, npart);

# Allocate output array

od = zeros(Float32, ntimes, npart);

hs_sim = zeros(Float32, npart);

res = zeros(Float32, ntimes, 3);

# Initilize particles

wk = ones(npart) / npart;

# Loop over time

for itime = 1:ntimes

	# Assign inputs

	for ipart in 1:npart

		# Time

		year  = metdata[itime, 1];
		month = metdata[itime, 2];
		day   = metdata[itime, 3];
		hour  = metdata[itime, 4];

		# SW

		SW = metdata[itime, 5];

		if SW > 0.
			SW_noise = Normal(0, min(109.1, SW));
			SW = SW + Float32(rand(SW_noise));
			SW = max(0, SW);
		end

		# LW

		LW_noise = Normal(0, 20.8);
		LW = metdata[itime, 6] + Float32(rand(LW_noise));

		# Sf

		Sf_noise = Uniform(0.5, 1.5);
		Sf = metdata[itime, 7] * Float32(rand(Sf_noise));

		# Rf

		Rf_noise = Uniform(0.5, 1.5);
		Rf = metdata[itime, 8] * Float32(rand(Rf_noise));

		# Ta

		Ta_noise = Normal(0, 0.9);
		Ta = metdata[itime, 9] + Float32(rand(Ta_noise));


		RH    = metdata[itime, 10];
		Ua    = metdata[itime, 11];
		Ps    = metdata[itime, 12];


		ip[ipart] = FsmInput(year, month, day, hour, SW, LW, Sf, Rf, Ta, RH, Ua, Ps);

	end

	# Run model

	for ipart = 1:npart

		hs_sim[ipart] =  run_fsm(md[ipart], ip[ipart]);

	end

	# Find observation

	iobs = find(dates_val .== dates_met[itime]);

	hs_obs = valdata[iobs, 6];

	# Run particle filter

	if !isempty(hs_obs) && !isnan(hs_obs[1])

		for ipart = 1:npart
			wk[ipart] = pdf(Normal(hs_obs[1], max(0.1 * hs_obs[1], 0.05)), hs_sim[ipart]) * wk[ipart];
		end

		if sum(wk) > 0.0
			wk = wk / sum(wk);
		else
			wk = ones(npart) / npart;
		end

		# Perform resampling

		Neff = 1 / sum(wk.^2);

		if round(Int64, Neff) < round(Int64, npart * 0.8)

			println("Resampled at step: $itime")

			indx = resample(wk);

			md  = [deepcopy(md[i]) for i in indx];

			wk = ones(npart) / npart;

		end

	end

	# Store results

	res[itime, 1] = sum(wk .* hs_sim);
	res[itime, 2] = minimum(hs_sim);
	res[itime, 3] = maximum(hs_sim);

end

# Plot results

fig = plt[:figure](figsize = (12,7));

plt[:style][:use]("ggplot");

plt[:plot](dates_val, valdata[:,6], linewidth = 1.2, color = "k", label = "obs", zorder = 1);
plt[:fill_between](dates_met, res[:, 3], res[:, 2], facecolor = "r", edgecolor = "r", label = "sim", alpha = 0.55, zorder = 2);
