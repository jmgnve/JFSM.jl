

# Type definitions

type FsmType

	albs::Array{Float32,1}
	Ds::Array{Float32,1}
	Nsnow::Array{Int32,1}
	Sice::Array{Float32,1}
	Sliq::Array{Float32,1}
	theta::Array{Float32,1}
	Tsnow::Array{Float32,1}
	Tsoil::Array{Float32,1}
	Tsurf::Array{Float32,1}
	
	function FsmType()
		
		# Define state variables
		
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
		
		new(albs, Ds, Nsnow, Sice, Sliq, theta, Tsnow, Tsoil, Tsurf)
	
	end

end

# Run fsm

function run_fsm(md::FsmType, metdata)

	# Allocate output arrays

	hs = zeros(Float32, size(metdata,1));

	# Loop over time

	for itime = 1:size(metdata,1)

		# Inputs
		
		year  = metdata[itime, 1];
		month = metdata[itime, 2];
		day   = metdata[itime, 3];
		hour  = metdata[itime, 4];
		SW    = metdata[itime, 5];
		LW    = metdata[itime, 6];
		Rf    = metdata[itime, 8];
		Sf    = metdata[itime, 7];
		Ta    = metdata[itime, 9];
		RH    = metdata[itime, 10];
		Ua    = metdata[itime, 11];
		Ps    = metdata[itime, 12];

		# Call fsm
		
		ccall((:fsm_, fsm), Void, (Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},
								   Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32},
								   Ptr{Float32}, Ptr{Float32},
								   Ptr{Float32},Ptr{Float32},Ptr{Int32},Ptr{Float32},Ptr{Float32},
								   Ptr{Float32},Ptr{Float32},Ptr{Float32},Ptr{Float32}),
								   &year, &month, &day, &hour, &SW, &LW, &Rf, &Sf, &Ta, &RH, &Ua, &Ps,
								   md.albs, md.Ds, md.Nsnow, md.Sice, md.Sliq, md.theta, md.Tsnow, md.Tsoil, md.Tsurf)

		# Save results

		hs[itime] = sum(md.Ds);
			
	end
	
	return hs

end






