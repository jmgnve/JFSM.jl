
# Compute liquid precipitation from total precipitation

function precip_liquid(prec, ta, thres_prec, p_corr, m_prec)

	Tp      = (ta - thres_prec) / m_prec
	p_multi = p_corr * exp(Tp) / (1 + exp(Tp))
	pliquid = p_multi * prec

	return pliquid

end

# Compute solid precipitation from total precipitation

function precip_solid(prec, ta, thres_prec, p_corr, m_prec)

	Tp      = (ta - thres_prec) / m_prec
	p_multi = p_corr / (1 + exp(Tp))
	psolid  = p_multi * prec

	return psolid

end
