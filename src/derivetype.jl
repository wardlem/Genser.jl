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
gensertypefor(T::Type{<: AbstractString}) = GenserStringValue{T, string}
gensertypefor(::Type{Vector{UInt8}}) = GenserBinary
gensertypefor(::Type{UUID}) = GenserUUID
gensertypefor(T::Type{<: AbstractArray}) = GenserSequence{T}
gensertypefor(T::Type{<: AbstractSet}) = GenserSet{T}
gensertypefor(T::Type{<: Tuple}) = GenserTuple{T}
gensertypefor(T::Type{<: AbstractDict}) = GenserDict{T}
gensertypefor(T::Type{<: NamedTuple}) = GenserRecord{T}

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
        # Assume a struct
        return GenserRecord{T}
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
