
# This table represents the optimal "power tree"
# based on Knuth's "TAOCP vol 2: Seminumerical Algorithms",
# third edition, section 4.6.3, Fig. 15.  It was
# transcribed into this array form in the gcc source
# code (tree-ssa-math-opts.c), but since this is just
# a table of mathematical facts it should not be copyrightable.
#
# To compute x^q in a minimal number of multiplications
# for 1 ≤ q ≤ 255, you compute x^r * x^s for
# r = power_tree[i] and s = i-q, recursively
# (memoizing each power computation), and we implicitly
# define power_tree[0] = 0.
const power_tree = [
      1,   1,   2,   2,   3,   3,   4,       #   1 -   7
      4,   6,   5,   6,   6,  10,   7,   9,  #   8 -  15
      8,  16,   9,  16,  10,  12,  11,  13,  #  16 -  23
     12,  17,  13,  18,  14,  24,  15,  26,  #  24 -  31
     16,  17,  17,  19,  18,  33,  19,  26,  #  32 -  39
     20,  25,  21,  40,  22,  27,  23,  44,  #  40 -  47
     24,  32,  25,  34,  26,  29,  27,  44,  #  48 -  55
     28,  31,  29,  34,  30,  60,  31,  36,  #  56 -  63
     32,  64,  33,  34,  34,  46,  35,  37,  #  64 -  71
     36,  65,  37,  50,  38,  48,  39,  69,  #  72 -  79
     40,  49,  41,  43,  42,  51,  43,  58,  #  80 -  87
     44,  64,  45,  47,  46,  59,  47,  76,  #  88 -  95
     48,  65,  49,  66,  50,  67,  51,  66,  #  96 - 103
     52,  70,  53,  74,  54, 104,  55,  74,  # 104 - 111
     56,  64,  57,  69,  58,  78,  59,  68,  # 112 - 119
     60,  61,  61,  80,  62,  75,  63,  68,  # 120 - 127
     64,  65,  65, 128,  66, 129,  67,  90,  # 128 - 135
     68,  73,  69, 131,  70,  94,  71,  88,  # 136 - 143
     72, 128,  73,  98,  74, 132,  75, 121,  # 144 - 151
     76, 102,  77, 124,  78, 132,  79, 106,  # 152 - 159
     80,  97,  81, 160,  82,  99,  83, 134,  # 160 - 167
     84,  86,  85,  95,  86, 160,  87, 100,  # 168 - 175
     88, 113,  89,  98,  90, 107,  91, 122,  # 176 - 183
     92, 111,  93, 102,  94, 126,  95, 150,  # 184 - 191
     96, 128,  97, 130,  98, 133,  99, 195,  # 192 - 199
    100, 128, 101, 123, 102, 164, 103, 138,  # 200 - 207
    104, 145, 105, 146, 106, 109, 107, 149,  # 208 - 215
    108, 200, 109, 146, 110, 170, 111, 157,  # 216 - 223
    112, 128, 113, 130, 114, 182, 115, 132,  # 224 - 231
    116, 200, 117, 132, 118, 158, 119, 206,  # 232 - 239
    120, 240, 121, 162, 122, 147, 123, 152,  # 240 - 247
    124, 166, 125, 214, 126, 138, 127, 153,  # 248 - 255
]

# return the inlined/unrolled expression to compute x^p
# by repeated multiplications (using an optimal addition
# chain for |p|<256 and power-by-squaring thereafter.
function addition_chain_pow(x::Symbol, p::Int)
    p == 0 && return :(one($x))
    ex = Union{Expr,Symbol}[] # expressions to compute intermediate powers
    if p < 0
        x′ = gensym()
        push!(ex, :($x′ = inv($x)))
        x = x′
        p = -p
    end
    pows_computed = Dict(1 => x) # powers q => variable storing x^q
    pows_to_compute = [p]
    while !isempty(pows_to_compute)
        q = pop!(pows_to_compute)
        if !haskey(pows_computed, q)
            if q ≤ length(power_tree) # use optimal addition chain
                q1 = power_tree[q]
                q2 = q-q1
                @assert q1 > 0 && q2 > 0
                has1 = haskey(pows_computed, q1)
                has2 = haskey(pows_computed, q2)
                if has1 && has2
                    xq = gensym()
                    push!(ex, :($xq = $(pows_computed[q1]) * $(pows_computed[q2])))
                    pows_computed[q] = xq
                else
                    push!(pows_to_compute, q) # try again after computing q1, q2
                    has1 || push!(pows_to_compute, q1)
                    has2 || push!(pows_to_compute, q2)
                end
            else # q too big, use power-by-squaring algorithm
                q1 = q >> 1
                if haskey(pows_computed, q1)
                    xq = gensym()
                    xq1 = pows_computed[q1]
                    push!(ex, iseven(q) ? :($xq = $xq1 * $xq1) : :($xq = $xq1 * $xq1 * $x))
                    pows_computed[q] = xq
                else
                    push!(pows_to_compute, q) # try again after computing q1
                    push!(pows_to_compute, q1)
                end
            end
        end
    end
    push!(ex, pows_computed[p]) # the variable for the final result x^p
    return Expr(:block, ex...)
end
addition_chain_pow(x::Symbol, p::Integer) = addition_chain_pow(x, Int(p))

function addition_chain_pow(expr, p::Integer)
    x = gensym()
    return Expr(:let, Expr(:(=), x, expr), Expr(:block, addition_chain_pow(x, p)))
end
