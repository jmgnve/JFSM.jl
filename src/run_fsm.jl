function test_run()

	cd(Pkg.dir("JFSM"))

	# Load driving data

	data = readdlm("data\\met_CdP_0506.txt", Float64);

	# State variables

	rho_wat = Float32(1000.);     # Density of water (kg/m^3)
	Tm = Float32(273.15);         # Melting point (K)

	Nsmax = 3;      # Maximum number of snow layers
	Nsoil = 4;      # Number of soil layers

	albs  = Array(Float32, 1);         # Snow albedo
	Ds    = Array(Float32, Nsmax);     # Snow layer thicknesses (m)
	Nsnow = Array(Int32, 1);           # Number of snow layers 
	Sice  = Array(Float32, Nsmax);     # Ice content of snow layers (kg/m^2)
	Sliq  = Array(Float32, Nsmax);     # Liquid content of snow layers (kg/m^2)
	theta = Array(Float32, Nsoil);     # Volumetric moisture content of soil layers
	Tsnow = Array(Float32, Nsmax);     # Snow layer temperatures (K)
	Tsoil = Array(Float32, Nsoil);     # Soil layer temperatures (K)
	Tsurf = Array(Float32, 1);         # Surface skin temperature (K)

	# No snow in initial state

	albs[:] = 0.8;
	Ds[:] = 0;
	Nsnow[:] = 0;
	Sice[:] = 0;
	Sliq[:] = 0;
	Tsnow[:] = Tm;

	# Initial soil profiles

	fcly = Float32(0.3);
	fsnd = Float32(0.6);
	Vsat = 0.505 - 0.037*fcly - 0.142*fsnd;

	fsat = 0.5 * ones(Float32, Nsoil);  # Initial moisture content of soil layers as fractions of saturation
	Tsoil[:] = 285.;
	Tsurf[1] = Tsoil[1];
	for k = 1:Nsoil
	  theta[k] = fsat[k]*Vsat
	end

	# Allocate output arrays

	hs = zeros(Float32, size(data,1));


	# Loop over time

	for itime = 1:size(data,1)

		# Inputs
		
		year  = data[itime, 1];
		month = data[itime, 2];
		day   = data[itime, 3];
		hour  = data[itime, 4];
		SW    = data[itime, 5];
		LW    = data[itime, 6];
		Rf    = data[itime, 8];
		Sf    = data[itime, 7];
		Ta    = data[itime, 9];
		RH    = data[itime, 10];
		Ua    = data[itime, 11];
		Ps    = data[itime, 12];

		# Call fsm
		
		ccall((:fsm_, fsm), Void, (Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},
								   Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},
								   Ptr{Float32}, Ptr{Float32},
								   Ptr{Float32},Ptr{Float32},Ptr{Int32},Ptr{Float32},Ptr{Float32},
							       Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32}),
								   &year, &month, &day, &hour, &SW, &LW, &Rf, &Sf, &Ta, &RH, &Ua, &Ps,
								   albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf)

		# Save results

		hs[itime] = sum(Ds);
			
	end

	# Compare against original code

	orig = readdlm("out_CdP_0506.txt", Float32)

	plot(orig[:,6], linewidth = 2)
	plot!(hs, linestyle = :dot, linecolor = :red, linewidth = 2)

end