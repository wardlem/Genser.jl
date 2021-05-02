# Main converter
function togenser(::Type{GenserDataType}, v::V) where V
    T = gensertypefor(V)
    togenser(T, v)
end

togenser(::Type{T}, v::T) where T <: GenserDataType = V
Base.convert(::Type{T}, v::T) where T <:GenserDataType = v
Base.convert(::Type{T}, v) where T <:GenserDataType = togenser(T, v)

togenser(v) = togenser(GenserDataType, v)

# Nothing
togenser(T::Type{<:GenserNothingType}, v) = T()

# Integer types
for (T, GT) = (
    Int8 => GenserInt8,
    UInt8 => GenserUInt8,
    Int16 => GenserInt16,
    UInt16 => GenserUInt16,
    Int32 => GenserInt32,
    UInt32 => GenserUInt32,
    Int64 => GenserInt64,
    UInt64 => GenserUInt64,
    Int128 => GenserInt128,
    UInt128 => GenserUInt128,
    Bool => GenserBool,
    BigInt => GenserBigInt,
    Float16 => GenserFloat16,
    Float32 => GenserFloat32,
    Float64 => GenserFloat64)

    @eval togenser(::Type{$GT}, v::$GT) = v
    @eval togenser(::Type{$GT}, v::V) where V <: Number = $GT($T(v))
    @eval togenser(::Type{$GT}, v::V) where V <: AbstractChar = $GT($T(v))
    @eval togenser(::Type{$GT}, v::V) where V <: AbstractString = $GT(parse($T, v))
end

# Char
togenser(::Type{GenserChar}, v::GenserChar) = v
togenser(::Type{GenserChar}, v::Char) = GenserChar(v)
togenser(::Type{GenserChar}, v::V) where V <: Number = GenserChar(Char(v))
togenser(::Type{GenserChar}, v::V) where V <: AbstractString = begin
    @assert length(v) == 1 "Cannot convert a multi-character or empty string to a char"
    GenserChar(v[1])
end

# Strings
# togenser(T::Type{<:GenserString}, v::GenserString) where V = v
togenser(T::Type{<:GenserStringValue{V}}, v) where V <: AbstractString = T(string(v))
# togenser(T::Type{<:GenserStringValue}, v) = beginT(string(v))

# Binary
togenser(::Type{GenserBinary}, v::Vector{UInt8}) = GenserBinary(v)
togenser(::Type{GenserBinary}, v::Array) = begin
    v = reinterpret(UInt8, hton.(v)[:])
    GenserBinary(v)
end
togenser(::Type{GenserBinary}, v::AbstractString) = begin
    v = Vector{UInt8}(v)
    GenserBinary(v)
end

# UUID
togenser(::Type{GenserUUID}, v::UUID) = GenserUUID(v)
togenser(::Type{GenserUUID}, v::AbstractString) = GenserUUID(UUID(v))
togenser(::Type{GenserUUID}, v::Vector{UInt8}) = begin
    @assert length(v) == 16 "Cannot convert a buffer to a uuid when its length is not 16 bytes"
    v = hton(reinterpret(UInt128, v)[1])
    GenserUUID(UUID(v))
end
togenser(::Type{GenserUUID}, v::UInt128) = GenserUUID(UUID(v))

# Sequences
togenser(::Type{GenserSequence{T}}, vs::AbstractVector{T}) where T <: GenserDataType = GenserSequence{T}(vs)
togenser(::Type{GenserSequence{T}}, vs::AbstractVector) where T <: GenserDataType = begin
    newvs = map(vs) do v 
        togenser(T, v)
    end

    GenserSequence{T}(newvs)
end
togenser(T::Type{<: GenserSequence}, vs::AbstractArray) = togenser(T, vs[:])
togenser(T::Type{<: GenserSequence}, v::AbstractString) = togenser(T, [v...])
togenser(T::Type{GenserSequence}, vs) = begin
    vs = Vector(vs)
    togenser(T, vs)
end

# Sets
togenser(::Type{GenserSet{T}}, vs::AbstractSet{T}) where T <: GenserDataType = GenserSet{T}(vs)
togenser(::Type{GenserSet{T}}, vs::AbstractSet) where T <: GenserDataType = begin
    newvs = map([vs...]) do v
        togenser(T, v)
    end

    GenserSet{T}(Set(newvs))
end
togenser(T::Type{<:GenserSet}, v) = togenser(T, Set(v))

# Tuples
togenser(::Type{GenserTuple{T}}, v::T) where T = GenserTuple{T}(v)
togenser(::Type{GenserTuple{T}}, v) where T = GenserTuple{T}(T(v))

# Dicts
togenser(::Type{GenserDict{K,V}}, vs::AbstractDict{K,V}) where K <: GenserDataType where V <: GenserDataType = GenserDict{K,V}(vs)
togenser(::Type{GenserDict{K,V}}, vs::AbstractDict) where K <: GenserDataType where V <: GenserDataType = begin
    pairs = []
    for (k,v) in vs
        k = togenser(K, k)
        v = togenser(V, v)
        push!(pairs, k => v)
    end
    newvs = Dict(pairs)
    GenserDict{K,V}(newvs)
end

# Records
togenser(::Type{GenserRecord{T}}, v::AbstractDict) where {T <: NamedTuple} = begin
    args = []
    for (key, type) = zip(fieldnames(T), T.types)
        if haskey(v, key)
            push!(args, togenser(type, v[key]))
        elseif haskey(v, string(key))
            push!(args, togenser(type, v[string(key)]))
        else
            # Attempt to convert from nothing
            push!(args, togenser(type, nothing))
        end
    end

    GenserRecord(T(args))
end
togenser(::Type{GenserRecord{T}}, v::T) where T = GenserRecord{T}(v)
togenser(::Type{GenserRecord{T}}, v::V) where T where V = begin
    args = []
    for (key, type) = zip(fieldnames(T), T.types)
        if hasfield(V, key)
            push!(args, togenser(type, getfield(v, key)))
        else
            # Attempt to convert from nothing
            push!(args, togenser(type, nothing))
        end
    end

    GenserRecord(T(args))
end

# Optionals
togenser(::Type{GenserOptional{T}}, v::T) where T = GenserOptional{T}(v)
togenser(::Type{GenserOptional{T}}, v::Nothing) where T = GenserOptional{T}(GenserUndefined())
togenser(::Type{GenserOptional{T}}, v) where T = GenserOptional{T}(togenser(T, v))

# Variants
togenser(::Type{GenserVariant{T}}, v::T) where T = GenserVariant{T}(v)
togenser(::Type{GenserVariant{T}}, v::V) where {T, V} = begin
    if V <: T
        return GenserVariant{T}(v)
    end

    GenserVariant{T}(togenser(v))
end

# Any
togenser(::Type{GenserAny}, v::T) where T <: GenserDataType = GenserAny(v)
togenser(::Type{GenserAny}, v::T) where T = GenserAny(togenser(v))

