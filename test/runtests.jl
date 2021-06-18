using FastPow, Test

@testset "integer powers" begin
    let x = 3.7, z = 5.2, u = 0.988
        y = sin(x)^6 + z^8.3 + u^9
        @fastpow y2 = sin(x)^6 + z^8.3 + u^9
        @test y ≈ y2
    end

    @test @fastpow(0.73^25) ≈ big"0.73"^25 rtol=3e-15
    @test @fastpow(0.6^-7) ≈ big"0.6"^-7 rtol=1e-15
    @test @fastpow(0.6^0) === 1.0
    @test @fastpow(0.6^1) === 0.6
end

struct DummyType; end
Base.:^(x::Int, ::DummyType) = "$x^dummy"
const dummy = DummyType()

@testset "1^p" begin
    for p in (-10,-9,0,9,10,0.2,2//3,0.3+0.4im)
        @test @fastpow(1^p) === one(p)
    end
    @test @fastpow(1^dummy) == "1^dummy"
end

@testset "(-1)^p" begin
    for n in (-10,-9,0,9,10)
        correct = iseven(n) ? 1 : -1
        @test @fastpow((-1)^n) === correct
        @test @fastpow((-1)^float(n)) == correct
        @test @fastpow((-1)^Rational(n)) == correct
    end
    for p in (0.2, 2//3)
        @test_throws DomainError @fastpow((-1)^p)
    end
    z = 0.3 + 0.4im
    @test @fastpow((-1)^z) ≈ (-1)^z ≈ 0.16728929223461353 + 0.23025395732014076im
    @test @fastpow((-1)^dummy) == "-1^dummy"
end

@testset "2^p" begin
    for p in Any[Int64.(0:65); big(100)]
        @test @fastpow(2^p)::typeof(2^p) == 2^p
    end
    p = -2
    @test_throws DomainError @fastpow(2^p)
    @test @fastpow(2^-2) === 0.25
    @test @fastpow(2^-100) === 7.888609052210118e-31
    for p in (0.3, -0.5, 4//3, 0.3+4im)
        @test @fastpow(2^p) == exp2(p)
    end
    @test @fastpow(2^dummy) == "2^dummy"
end

@testset "10^p" begin
    for p in Int64.(0:30)
        @test @fastpow(10^p) === 10^p
    end
    p = -2
    @test_throws DomainError @fastpow(10^p)
    @test @fastpow(10^-2) == 0.01
    for p in (0.3, -0.5, 4//3, 0.3+4im)
        @test @fastpow(10^p) == exp10(p)
    end
    @test @fastpow(10^dummy) == "10^dummy"
end
