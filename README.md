[![Build status](https://github.com/JuliaMath/FastPow.jl/workflows/CI/badge.svg)](https://github.com/JuliaMath/FastPow.jl/actions)

# FastPow

This package provides a macro `@fastpow` that can speed up
the computation of *integer powers* in any Julia expression
by transforming them into *optimal sequences of multiplications*,
with a slight sacrifice in accuracy compared to Julia's built-in
`x^n` function.   It also optimizes powers of the form `1^p`, `(-1)^p`, `2^p`, and `10^p`.

In particular, it uses optimal [addition-chain exponentiation](https://en.wikipedia.org/wiki/Addition-chain_exponentiation) for (literal) integer powers up to 255, and for larger powers uses [repeated
squaring](https://en.wikipedia.org/wiki/Exponentiation_by_squaring)
to first reduce the power to ≤ 255 and then use addition chains.

For example, `@fastpow z^25` requires 6 multiplications, and for `z = 0.73` it gives the correct answer to a relative error of `≈ 1.877e-15` (about 8 [ulps](https://en.wikipedia.org/wiki/Unit_in_the_last_place)), vs. the default `z^25` which gives the correct answer to a relative error of `≈ 6.03e-16` (about 3 ulps) but is about 10× slower.

Note that you can apply the `@fastpow` macro to a whole *block*
of Julia code at once.  For example,
```jl
@fastpow function foo(x,y)
    z = sin(x)^3 + sqrt(y)
    return z^7 - 4x^5.3 + 3y^12
end
```
applies the `@fastpow` transformation to *every* literal integer
exponent (`^3`, `^7`, and `^12`) in the function `foo`.

An alternative to `@fastpow` is to use Julia's built-in
[`@fastmath`](https://docs.julialang.org/en/v1/base/math/#Base.FastMath.@fastmath) macro, which enables various LLVM optimizations
including, in some cases, faster integer powers using
repeated multiplication.  The advantages of `@fastpow` are that
it *guarantees* optimal addition-chain exponentiation
and that it works for exponentiating *any* Julia type
(e.g. complex numbers, matrices, …), whereas LLVM will only
optimize a small set of hardware numeric types.
