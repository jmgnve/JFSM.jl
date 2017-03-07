
# Type definitions

type FsmType

	albs::Array{Float64,1}
	Ds::Array{Float64,1}
	Nsnow::Array{Int64,1}
	Sice::Array{Float64,1}
	Sliq::Array{Float64,1}
	theta::Array{Float64,1}
	Tsnow::Array{Float64,1}
	Tsoil::Array{Float64,1}
	Tsurf::Array{Float64,1}

	am::Int64
	cm::Int64
	dm::Int64
	em::Int64
	hm::Int64

end

type FsmInput

	year::Float64
	month::Float64
	day::Float64
	hour::Float64
	SW::Float64
	LW::Float64
	Sf::Float64
	Rf::Float64
	Ta::Float64
	RH::Float64
	Ua::Float64
	Ps::Float64

end

# Outer constructor

function FsmType(am, cm, dm, em, hm)

	# Define state variables

	rho_wat = 1000.;     # Density of water (kg/m^3)
	Tm = 273.15;         # Melting point (K)

	Nsmax = 3;      # Maximum number of snow layers
	Nsoil = 4;      # Number of soil layers

	albs  = Array(Float64, 1);         # Snow albedo
	Ds    = Array(Float64, Nsmax);     # Snow layer thicknesses (m)
	Nsnow = Array(Int64, 1);           # Number of snow layers
	Sice  = Array(Float64, Nsmax);     # Ice content of snow layers (kg/m^2)
	Sliq  = Array(Float64, Nsmax);     # Liquid content of snow layers (kg/m^2)
	theta = Array(Float64, Nsoil);     # Volumetric moisture content of soil layers
	Tsnow = Array(Float64, Nsmax);     # Snow layer temperatures (K)
	Tsoil = Array(Float64, Nsoil);     # Soil layer temperatures (K)
	Tsurf = Array(Float64, 1);         # Surface skin temperature (K)

	# No snow in initial state

	albs[:] = 0.8;
	Ds[:] = 0;
	Nsnow[:] = 0;
	Sice[:] = 0;
	Sliq[:] = 0;
	Tsnow[:] = Tm;

	# Initial soil profiles

	fcly = 0.3;
	fsnd = 0.6;
	Vsat = 0.505 - 0.037*fcly - 0.142*fsnd;

	fsat = 0.5 * ones(Float64, Nsoil);  # Initial moisture content of soil layers as fractions of saturation
	Tsoil[:] = 285.;
	Tsurf[1] = Tsoil[1];
	for k = 1:Nsoil
	  theta[k] = fsat[k]*Vsat
	end

	FsmType(albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf, am, cm, dm, em, hm)

end

# Run fsm

function run_fsm(md::FsmType, metdata)

	# Allocate output arrays

	hs = zeros(Float64, size(metdata,1));

	# Loop over time

	for itime = 1:size(metdata,1)

		# Inputs

		year  = metdata[itime, 1];
		month = metdata[itime, 2];
		day   = metdata[itime, 3];
		hour  = metdata[itime, 4];
		SW    = metdata[itime, 5];
		LW    = metdata[itime, 6];
		Sf    = metdata[itime, 7];
		Rf    = metdata[itime, 8];
		Ta    = metdata[itime, 9];
		RH    = metdata[itime, 10];
		Ua    = metdata[itime, 11];
		Ps    = metdata[itime, 12];

		# Call fsm

		ccall((:fsm_, fsm), Void, (Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},
								   						 Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},
								   				 		 Ptr{Float64}, Ptr{Float64},
								   				 		 Ptr{Float64},Ptr{Float64},Ptr{Int64},Ptr{Float64},Ptr{Float64},
								   				 		 Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},
								   				 		 Ptr{Int64},Ptr{Int64},Ptr{Int64},Ptr{Int64},Ptr{Int64}),
								   				 		 &year, &month, &day, &hour, &SW, &LW, &Sf, &Rf, &Ta, &RH, &Ua, &Ps,
								   				 		 md.albs, md.Ds, md.Nsnow, md.Sice, md.Sliq, md.theta, md.Tsnow, md.Tsoil, md.Tsurf,
								   				 		 &md.am, &md.cm, &md.dm, &md.em, &md.hm)

		# Save results

		hs[itime] = sum(md.Ds);

	end

	return hs

end


# Run only one time step

function run_fsm(md::FsmType, id::FsmInput)

	# Call fsm

	ccall((:fsm_, fsm), Void, (Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},
														 Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},
														 Ptr{Float64}, Ptr{Float64},
														 Ptr{Float64},Ptr{Float64},Ptr{Int64},Ptr{Float64},Ptr{Float64},
														 Ptr{Float64},Ptr{Float64},Ptr{Float64},Ptr{Float64},
														 Ptr{Int64},Ptr{Int64},Ptr{Int64},Ptr{Int64},Ptr{Int64}),
														 &id.year, &id.month, &id.day, &id.hour, &id.SW, &id.LW, &id.Sf, &id.Rf, &id.Ta, &id.RH, &id.Ua, &id.Ps,
														 md.albs, md.Ds, md.Nsnow, md.Sice, md.Sliq, md.theta, md.Tsnow, md.Tsoil, md.Tsurf,
														 &md.am, &md.cm, &md.dm, &md.em, &md.hm)

	# Save results

	hs = sum(md.Ds);

	return hs

end
