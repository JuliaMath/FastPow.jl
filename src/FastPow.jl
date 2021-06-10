module FastPow
export @fastpow

include("addition-chain-pow.jl")
include("exp_n.jl")

fastpow(x) = x
function fastpow(expr::Expr)
    if Meta.isexpr(expr, :call, 3) && expr.args[1] == :^
        if expr.args[2] === 1
            return :($exp_1($(expr.args[3])))
        elseif expr.args[2] === -1
            return :($exp_minus1($(expr.args[3])))
        elseif expr.args[2] === 2
            if expr.args[3] isa Integer && expr.args[3] < 0
                return :(inv($exp_2($(-expr.args[3]))))
            else
                return :($exp_2($(expr.args[3])))
            end
        elseif expr.args[2] === 10
            if expr.args[3] isa Integer && expr.args[3] < 0
                return :(inv($exp_10($(-expr.args[3]))))
            else
                return :($exp_10($(expr.args[3])))
            end
        elseif expr.args[3] isa Integer
            return addition_chain_pow(expr.args[2], expr.args[3])
        end
    end
    return Expr(expr.head, fastpow.(expr.args)...)
end

macro fastpow(expr)
    return esc(fastpow(expr))
end

end # module
