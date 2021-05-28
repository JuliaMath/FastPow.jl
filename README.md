# FastPow

This package provides a macro `@fastpow` that can speed up
the computation of *integer powers* in any block of Julia code
by transforming them into *optimal sequences of multiplications*,
with a slight sacrifice in accuracy compared to Julia's built-in
`x^n` function.

In particular, it uses optimal [addition-chain exponentiation](https://en.wikipedia.org/wiki/Addition-chain_exponentiation) for (literal) integer powers up to 255, and for larger powers uses [repeated
squaring](https://en.wikipedia.org/wiki/Exponentiation_by_squaring)
to first reduce the power to ≤ 255 and then use addition chains.

For example, `@fastpow z^25` requires 6 multiplications, and for `z = 0.73` it gives the correct answer to a relative error of `≈ 1.877e-15` (about 8 [ulps](https://en.wikipedia.org/wiki/Unit_in_the_last_place)), vs. the default `z^25` which gives the correct answer to a relative error of `≈ 6.03e-16` (about 3 ulps).
