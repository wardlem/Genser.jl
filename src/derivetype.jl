gensertypefor(T::Type{<:GenserDataType}) = T
gensertypefor(::Type{Any}) = GenserAny
gensertypefor(::Type{Nothing}) = GenserNull
gensertypefor(::Type{Int8}) = GenserInt8
gensertypefor(::Type{UInt8}) = GenserUInt8
gensertypefor(::Type{Int16}) = GenserInt16
gensertypefor(::Type{UInt16}) = GenserUInt16
gensertypefor(::Type{Int32}) = GenserInt32
gensertypefor(::Type{UInt32}) = GenserUInt32
gensertypefor(::Type{Int64}) = GenserInt64
gensertypefor(::Type{UInt64}) = GenserUInt64
gensertypefor(::Type{Int128}) = GenserInt128
gensertypefor(::Type{UInt128}) = GenserUInt128
gensertypefor(::Type{Char}) = GenserChar
gensertypefor(::Type{Bool}) = GenserBool
gensertypefor(::Type{BigInt}) = GenserBigInt
gensertypefor(::Type{Float16}) = GenserFloat16
gensertypefor(::Type{Float32}) = GenserFloat32
gensertypefor(::Type{Float64}) = GenserFloat64
gensertypefor(::Type{String}) = GenserString
gensertypefor(T::Type{<: AbstractString}) = GenserStringValue{T, str}
gensertypefor(::Type{Vector{UInt8}}) = GenserBinary
gensertypefor(::Type{UUID}) = GenserUUID
gensertypefor(::Type{Symbol}) = GenserSymbol
gensertypefor(::Type{<: AbstractArray{V}}) where V = GenserSequence{gensertypefor(V)}
gensertypefor(::Type{<: AbstractSet{V}}) where V = GenserSet{gensertypefor(V)}
gensertypefor(T::Type{<: Tuple}) = begin
    types = Base.map(gensertypefor, [T.parameters...])
    GenserTuple{Tuple{types...}}
end
gensertypefor(::Type{<: AbstractDict{K,V}}) where K where V = GenserDict{gensertypefor(K),gensertypefor(V)}
gensertypefor(T::Type{<: NamedTuple}) = begin
    keys = fieldnames(T)
    vals = Base.map(gensertypefor, [T.types...])
    vals = Tuple{vals...}
    NewT = NamedTuple{keys, vals}
    GenserRecord{NewT}
end

function gensertypefor(T::Type)
    # Could be a struct or union
    ttype = typeof(T)

    if ttype == Union
        if Nothing <: T
            # optional type
            return GenserOptional{gensertypefor(unoptionalize(T))}
        end

        # variant type
        return GenserVariant{mapuniontype(T)}
    elseif ttype === DataType
        if T.isbitstype
            # Store as binary?
            throw(ArgumentError("unable to derive a genser type for a bits type"))
        end
        # Assume a struct
        keys = fieldnames(T)
        vals = Base.map(gensertypefor, [T.types...])
        vals = Tuple{vals...}
        NewT = NamedTuple{keys, vals}
        return GenserRecord{NewT}
    else
        throw(ArgumentError("unable to derive genser type for $T"))
    end
end

function unoptionalize(T::Type)
    @assert typeof(T) === Union
    @assert Nothing <: T
    subtypes = []
    while T.a !== Nothing
        push!(subtypes, T.a)
        T = T.b
    end
    push!(subtypes, T.b)

    return Union{subtypes...}
end

function mapuniontype(T::Type)
    subtypes = []
    while typeof(T) === Union
        push!(subtypes, gensertypefor(T.a))
        T = T.b
    end
    push!(subtypes, gensertypefor(T))

    Union{subtypes...}
end
