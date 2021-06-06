using FastPow, Test

let x = 3.7, z = 5.2, u = 0.988
    y = sin(x)^6 + z^8.3 + u^9
    @fastpow y2 = sin(x)^6 + z^8.3 + u^9
    @test y ≈ y2
end

@test @fastpow(0.73^25) ≈ big"0.73"^25 rtol=3e-15
@test @fastpow(0.6^-7) ≈ big"0.6"^-7 rtol=1e-15
@test @fastpow(0.6^0) === 1.0
@test @fastpow(0.6^1) === 0.6
