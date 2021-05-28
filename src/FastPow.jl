module FastPow
export @fastpow

include("addition-chain-pow.jl")

fastpow(x) = x
function fastpow(expr::Expr)
    if Meta.isexpr(expr, :call, 3) && expr.args[1] == :^ && expr.args[3] isa Integer
        return addition_chain_pow(expr.args[2], expr.args[3])
    else
        return Expr(expr.head, fastpow.(expr.args)...)
    end
end

macro fastpow(expr)
    return esc(fastpow(expr))
end

end # module
