
#-----------------------------------------------------------------------------# json
function json_join(io::IO, itr, sep, left, right)
    print(io, left)
    for (i, item) in enumerate(itr)
        i == 1 || print(io, sep)
        json(io, item)
    end
    print(io, right)
end

json(io::IO, x) = json_join(io, x, ',', '[', ']')  # ***FALLBACK METHOD***

struct JSON{T}
    x::T
end
json(io::IO, x::JSON) = print(io, x.x)


json(x) = sprint(json, x)
json(io::IO, args...) = foreach(x -> json(io, x), args)

# Strings
json(io::IO, x::Union{AbstractChar, AbstractString, Symbol}) = print(io, '"', x, '"')
json(io::IO, x::DateTime) = json(io, Dates.format(x, "YYYY-mm-dd HH:MM:SS"))
json(io::IO, x::Date) = json(io, Dates.format(x, "YYYY-mm-dd"))

# Numbers
json(io::IO, x::Real) = isfinite(x) ? print(io, x) : print(io, "null")
json(io::IO, x::Rational) = json(io, float(x))

# Nulls
json(io::IO, ::Union{Missing, Nothing}) = print(io, "null")

# Bools
json(io::IO, x::Bool) = print(io, x ? "true" : "false")

# Arrays
json(io::IO, x::AbstractVector) = json_join(io, x, ',', '[', ']')
json(io::IO, x::AbstractArray) = json(io, eachslice(x; dims=1))

# Objects
json(io::IO, x::Pair) = json(io, x.first, JSON(':'), x.second)
json(io::IO, x::Union{NamedTuple, AbstractDict}) = json_join(io, pairs(x), ',', '{', '}')
