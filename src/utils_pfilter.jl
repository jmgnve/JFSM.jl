
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

	alfa = 1 - timestep / timedecorr

	q = alfa*q + sqrt(1-alfa^2)*randn()

	return q

end


# Resampling function

function resample(wk)

	Ns = length(wk)

	u = cumprod(rand(Ns) .^ (1./collect(Float64, Ns:-1:1)))

	u = u[length(u):-1:1]

	wc = cumsum(wk)

	label = zeros(Int64, Ns)

	k = 1
	for i = 1:Ns
		while wc[k] < u[i]
			k = k + 1
		end
		label[i] = k
	end

	return label

end


# Perturb input data

function perturb_input(q_vec, ipart, timestep, SW, LW, P, Ta, RH, Ua)

  # Shortwave radiation - random errors

  decorr_SW = 3.0

  error_SW = min(SW, 109.1)

  q_vec[ipart].q_SW = timecorr_noise(q_vec[ipart].q_SW, timestep, decorr_SW)

  SW_noise = error_SW * q_vec[ipart].q_SW

  SW = SW + SW_noise

  SW = max(0.0, SW)

  # Longwave radiation - random errors

  decorr_LW = 4.7

  error_LW = 20.8

  q_vec[ipart].q_LW = timecorr_noise(q_vec[ipart].q_LW, timestep, decorr_LW)

  LW_noise = error_LW * q_vec[ipart].q_LW

  LW = LW + LW_noise

  # Precipitation - random errors

  decorr_P = 2.0

  mu_P = -0.19
  sigma_P = 0.61

  q_vec[ipart].q_P = timecorr_noise(q_vec[ipart].q_P, timestep, decorr_P)

  P_noise = exp(mu_P + sigma_P * q_vec[ipart].q_P)

  P = max(P * P_noise, 0.0)

  # Air temperature - random errors

  decorr_Ta = 4.8

  error_Ta = 0.9

  q_vec[ipart].q_Ta = timecorr_noise(q_vec[ipart].q_Ta, timestep, decorr_Ta)

  Ta_noise = error_Ta * q_vec[ipart].q_Ta

  Ta = Ta + Ta_noise

  # Relative humidity - random noise

  decorr_RH = 8.4

  error_RH = 8.9

  q_vec[ipart].q_RH = timecorr_noise(q_vec[ipart].q_RH, timestep, decorr_RH)

  RH_noise = error_RH * q_vec[ipart].q_RH

  RH = RH + RH_noise

  RH = max(0.0, RH)
  RH = min(100.0, RH)

  # Wind speed - random noise

  decorr_Ua = 8.2

  mu_Ua = -0.14
  sigma_Ua = 0.53

  q_vec[ipart].q_Ua = timecorr_noise(q_vec[ipart].q_Ua, timestep, decorr_Ua)

  Ua_noise = exp(mu_Ua + sigma_Ua * q_vec[ipart].q_Ua)

  Ua = Ua * Ua_noise

  Ua = max(0.5, Ua)
  Ua = min(25.0, Ua)

  return SW, LW, P, Ta, RH, Ua

end
