# fast exp_n functions for particular n

# 1^p:
exp_1(p) = 1^p
exp_1(p::Number) = one(p)

# (-1)^p:
exp_minus1(p) = (-1)^p # fallback
exp_minus1(n::Integer) = isodd(n) ? -1 : 1
exp_minus1(p::Complex) = exp(-imag(p)*π) * cispi(real(p))
if VERSION ≥ v"1.7" # for isodd of non-Integer types (julia#38976)
    _isodd(p) = isodd(p)
else
    _isodd(x::AbstractFloat) = isinteger(x) && abs(x) ≤ maxintfloat(x) && isodd(Integer(x))
    _isodd(n::Real) = isinteger(n) && !iszero(rem(Integer(n), 2))
end
exp_minus1(p::Real) = isinteger(p) ? (_isodd(p) ? -1 : 1) : Base.Math.throw_exp_domainerror(p)

# 2^p
exp_2(p) = 2^p
exp_2(n::Integer) = n ≥ 0 ? (first(promote(1,n)) << n) : Base.throw_domerr_powbysq(2, n)
exp_2(p::Union{AbstractFloat,Complex,Rational}) = exp2(p)

# 10^p
exp_10(p) = 10^p
exp_10(p::Union{AbstractFloat,Complex,Rational}) = exp10(p)
