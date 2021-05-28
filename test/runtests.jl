using FastPow, Test

let x = 3.7, z = 5.2, u = 0.988
    y = sin(x)^6 + z^8.3 + u^9
    @fastpow y2 = sin(x)^6 + z^8.3 + u^9
    @test y ≈ y2
end
