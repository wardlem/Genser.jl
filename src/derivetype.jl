function fieldtype(t, f) nothing end

gensertypefor(T::Type{<:GenserDataType}; kwargs...) = T
gensertypefor(::Type{Any}; kwargs...) = GenserAny
gensertypefor(::Type{Nothing}; kwargs...) = GenserNull
gensertypefor(::Type{Int8}; kwargs...) = GenserInt8
gensertypefor(::Type{UInt8}; kwargs...) = GenserUInt8
gensertypefor(::Type{Int16}; kwargs...) = GenserInt16
gensertypefor(::Type{UInt16}; kwargs...) = GenserUInt16
gensertypefor(::Type{Int32}; kwargs...) = GenserInt32
gensertypefor(::Type{UInt32}; kwargs...) = GenserUInt32
gensertypefor(::Type{Int64}; kwargs...) = GenserInt64
gensertypefor(::Type{UInt64}; kwargs...) = GenserUInt64
gensertypefor(::Type{Int128}; kwargs...) = GenserInt128
gensertypefor(::Type{UInt128}; kwargs...) = GenserUInt128
gensertypefor(::Type{Char}; kwargs...) = GenserChar
gensertypefor(::Type{Bool}; kwargs...) = GenserBool
gensertypefor(::Type{BigInt}; kwargs...) = GenserBigInt
gensertypefor(::Type{Float16}; kwargs...) = GenserFloat16
gensertypefor(::Type{Float32}; kwargs...) = GenserFloat32
gensertypefor(::Type{Float64}; kwargs...) = GenserFloat64
gensertypefor(::Type{String}; kwargs...) = GenserString
gensertypefor(T::Type{<: AbstractString}; kwargs...) = GenserStringValue{T, str}
gensertypefor(::Type{Vector{UInt8}}; kwargs...) = begin
    if haskey(kwargs, :containertype) && haskey(kwargs, :fieldkey)
        containertype = kwargs[:containertype]
        fieldname = kwargs[:fieldkey]
        encoding = fieldencoding(containertype, Val{fieldname})
        if encoding <: Encoding
            GenserBinaryValue{encoding}
        else
            GenserBinary
        end
    else
        GenserBinary
    end
end
gensertypefor(::Type{UUID}; kwargs...) = GenserUUID
gensertypefor(::Type{Symbol}; kwargs...) = GenserSymbol
gensertypefor(::Type{<: AbstractArray{V}}; kwargs...) where V = GenserSequence{gensertypefor(V)}
gensertypefor(::Type{<: AbstractSet{V}}; kwargs...) where V = GenserSet{gensertypefor(V)}
gensertypefor(T::Type{<: Tuple}; kwargs...) = begin
    types = Base.map(gensertypefor, [T.parameters...])
    GenserTuple{Tuple{types...}}
end
gensertypefor(::Type{<: AbstractDict{K,V}}; kwargs...) where K where V = GenserDict{gensertypefor(K),gensertypefor(V)}
gensertypefor(T::Type{<: NamedTuple}; kwargs...) = begin
    keys = fieldnames(T)
    vals = Base.map(gensertypefor, [T.types...])
    vals = Tuple{vals...}
    NewT = NamedTuple{keys, vals}
    GenserRecord{NewT}
end

function gensertypefor(T::Type; kwargs...)
    # Could be a struct or union
    ttype = typeof(T)

    if ttype == Union
        if Nothing <: T
            # optional type
            return GenserOptional{gensertypefor(unoptionalize(T); kwargs...)}
        end

        # variant type
        return GenserVariant{mapuniontype(T; kwargs...)}
    elseif ttype === DataType
        if T <: Enum
            return GenserString
        end
        # Assume a struct
        keys = fieldnames(T)
        vals = Base.map(zip(keys, T.types)) do (fieldkey, type)
            definedtype = fieldtype(T, Val{fieldkey})
            if definedtype isa DataType && definedtype <: GenserDataType && definedtype.isconcretetype
                definedtype
            else
                gensertypefor(type, fieldkey=fieldkey, containertype=T)
            end
        end
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

function mapuniontype(T::Type; kwargs...)
    subtypes = []
    while typeof(T) === Union
        push!(subtypes, gensertypefor(T.a; kwargs...))
        T = T.b
    end
    push!(subtypes, gensertypefor(T; kwargs...))

    Union{subtypes...}
end
