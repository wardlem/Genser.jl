struct TypeID{typeid} end
TypeID(typeid) = TypeID{Symbol(typeid)}()
show(io::IO, ::TypeID{typeid}) where {typeid} = print(io, "Genser.TypeID(", string(typeid), ")")
print(io::IO, ::TypeID{typeid}) where {typeid} = print(io, typeid)

# Main to converter
function togenser(::Type{GenserDataType}, v::V) where V
    T = gensertypefor(V)
    togenser(T, v)
end

# Main from converter
function fromgenser(::Type{T}, v::GenserDataType) where T
    throw(ArgumentError("unable to convert from $(typeof(v)) to $(T)"))
end

# Default convert_to_type
function convert_to_type(type, v::GenserDataType) where T
    if type isa TypeID
        fromgenser(Any, v)
    else
        fromgenser(type, v)
    end
end

togenser(::Type{T}, v::T) where T <: GenserDataType = v

Base.convert(::Type{T}, v::T) where T <:GenserDataType = v
Base.convert(::Type{T}, v) where T <:GenserDataType = togenser(T, v)
Base.convert(::Type{T}, v::V) where T where V <:GenserDataType = fromgenser(T, v)
Base.convert(::Type{Any}, v::V) where V <:GenserDataType = fromgenser(Any, v)

togenser(v) = togenser(GenserDataType, v)
fromgenser(v::V) where V <: GenserDataType = fromgenser(Any, v)
fromgenser(::Type{T}, v::GenserValue{T}) where T = v.value

# Any
fromgenser(::Type{Any}, v::GenserAny) = fromgenser(v.value)

# Nothing
togenser(T::Type{<:GenserNothingType}, v) = T()
fromgenser(::Type{>:Nothing}, v::GenserNothingType) = nothing
fromgenser(::Type{Any}, v::GenserNothingType) = nothing

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

    @eval fromgenser(T::Type{<:Number}, v::$GT) = T(v.value)
    @eval fromgenser(T::Type{Char}, v::$GT) = T(v.value)
    # @eval fromgenser(T::Type{Any}, v::$GT) = v.value
    @eval fromgenser(T::Type{>:$T}, v::$GT) = v.value
end

# Char
togenser(::Type{GenserChar}, v::GenserChar) = v
togenser(::Type{GenserChar}, v::Char) = GenserChar(v)
togenser(::Type{GenserChar}, v::V) where V <: Number = GenserChar(Char(v))
togenser(::Type{GenserChar}, v::V) where V <: AbstractString = begin
    @assert length(v) == 1 "cannot convert a multi-character or empty string to a char"
    GenserChar(v[1])
end

fromgenser(::Type{Char}, v::GenserChar) = v.value
fromgenser(::Type{AbstractString}, v::GenserChar) = Base.string(v.value)
fromgenser(::Type{String}, v::GenserChar) = Base.string(v.value)
fromgenser(T::Type{<:Number}, v::GenserChar) = T(v.value)
fromgenser(::Type{>:Char}, v::GenserChar) = v.value

# Strings
togenser(T::Type{<:GenserStringValue{V}}, v) where V <: AbstractString = T(string(v))

fromgenser(::Type{AbstractString}, v::V) where V <: GenserStringValue = v.value
fromgenser(T::Type{<:Number}, v::V) where V <:GenserStringValue = parse(T, v.value)
fromgenser(T::Type{<:AbstractChar}, v::V) where V <: GenserStringValue = begin
    @assert length(v.value) == 1 "cannot convert a multi-character or empty string to a $T"
    T(v.value[1])
end
fromgenser(::Type{Symbol}, v::V) where V <:GenserStringValue = Symbol(v.value)
fromgenser(::Type{>:AbstractString}, v::V) where V <: GenserStringValue = v.value
fromgenser(::Type{>:String}, v::V) where V <: GenserStringValue = string(v.value)
fromgenser(T::Type{<:AbstractString}, v::V) where V <: GenserStringValue = begin
    T = T.isconcretetype ? T : typeof(v.value)
    T(v.value)
end
fromgenser(::Type{Base.UUID}, v::V) where V <: GenserStringValue = UUID(v.value)
fromgenser(::Type{Vector{UInt8}}, v::V) where V <: GenserStringValue = Vector{UInt8}(v.value)

# Binary
togenser(T::Type{<:GenserBinaryType}, v::Vector{UInt8}) = T(v)
togenser(T::Type{<:GenserBinaryType}, v::Array) = begin
    v = map(UInt8, v)
    T(v)
end
togenser(::Type{GenserBinary}, v::AbstractString) = begin
    v = Vector{UInt8}(v)
    GenserBinary(v)
end
togenser(::Type{GenserBinaryType{E}}, v::AbstractString) where E = begin
    C = genser_converter_for_encoding(E)
    v = C.decode(v)
    GenserBinaryType{E}(v)
end

fromgenser(::Type{Vector{UInt8}}, v::V) where {V <: GenserBinaryType} = v.value
fromgenser(T::Type{<:Vector}, v::V) where {V <: GenserBinaryType} = begin
    v = map(eltype(T), (v.value))
    v
end
fromgenser(T::Type{<:Matrix}, v::V) where {V <: GenserBinaryType} = begin
    v = map(eltype(T), (v.value))
    # Unknown dimensions...
    hcat(v)
end
fromgenser(::Type{AbstractString}, v::GenserBinary) = String(v.value)
fromgenser(T::Type{<:AbstractString}, v::GenserBinary) = T(v.value)
fromgenser(::Type{AbstractString}, v::GenserBinaryType{E}) where E = begin
    C = genser_converter_for_encoding(E)
    v = C.encode(v.value)
    v
end
fromgenser(T::Type{<:AbstractString}, v::GenserBinaryType{E}) where E = begin
    C = genser_converter_for_encoding(E)
    v = C.encode(v.value)
    T(v)
end
fromgenser(::Type{UUID}, v::V) where {V <: GenserBinaryType} = begin
    @assert length(v.value) == 16 "cannot convert a binary to a uuid when its length is not  16 bytes"
    v = ntoh(reinterpret(UInt128, v.value)[1])
    UUID(v)
end
fromgenser(::Type{>:Vector{UInt8}}, v::V) where {V <: GenserBinaryType} = v.value

# UUID
togenser(::Type{GenserUUID}, v::UUID) = GenserUUID(v)
togenser(::Type{GenserUUID}, v::AbstractString) = GenserUUID(UUID(v))
togenser(::Type{GenserUUID}, v::Vector{UInt8}) = begin
    @assert length(v) == 16 "cannot convert a binary to a uuid when its length is not 16 bytes"
    v = hton(reinterpret(UInt128, v)[1])
    GenserUUID(UUID(v))
end
togenser(::Type{GenserUUID}, v::UInt128) = GenserUUID(UUID(v))

fromgenser(::Type{String}, v::GenserUUID) = string(v.value)
fromgenser(::Type{AbstractString}, v::GenserUUID) = string(v.value)
fromgenser(::Type{T}, v::GenserUUID) where T <: AbstractString = T(string(v.value))
fromgenser(::Type{Vector{UInt8}}, v::GenserUUID) = [reinterpret(UInt8, [hton(v.value.value)])...]
fromgenser(::Type{UInt128}, v::GenserUUID) = v.value.value
fromgenser(::Type{>:UUID}, v::GenserUUID) = v.value
fromgenser(::Type{<:UUID}, v::GenserUUID) = v.value

# Symbol
togenser(::Type{GenserSymbol}, v::Symbol) = GenserSymbol(v)
togenser(::Type{GenserSymbol}, v) = GenserSymbol(Symbol(v))

fromgenser(::Type{String}, v::GenserSymbol) = String(v.value)
fromgenser(::Type{AbstractString}, v::GenserSymbol) = String(v.value)
fromgenser(T::Type{<:AbstractString}, v::GenserSymbol) = T(String(v.value))
fromgenser(::Type{>:Symbol}, v::GenserSymbol) = v.value

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

fromgenser(T::Type{<: AbstractVector}, v::GenserSequence) = begin
    E = eltype(T)
    vs = map(v.value) do subv
        fromgenser(E, subv)
    end

    T(vs)
end

fromgenser(T::Type{>: Vector{E}}, v::GenserSequence) where E = begin
    vs = map(v.value) do subv
        fromgenser(E, subv)
    end

    vs::T
end

fromgenser(::Type{Any}, v::GenserSequence) = begin
    vs = map(v.value) do subv
        fromgenser(Any, subv)
    end

    vs
end

fromgenser(T::Type{<: AbstractSet}, v::GenserSequence) = begin
    E = eltype(T)
    vs = map(v.value) do subv
        fromgenser(E, subv)
    end

    T = T.isconcretetype ? T : Set
    T(vs)
end

convert_to_type(m, v::GenserSequence) = begin
    map(v.value) do subv
        convert_to_type(m, subv)
    end
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

fromgenser(T::Type{Any}, v::GenserSet) = begin
    vs = map([v.value...]) do subv
        fromgenser(Any, subv)
    end

    Set(vs)
end

fromgenser(T::Type{<: AbstractSet}, v::GenserSet) = begin
    E = eltype(T)
    vs = map([v.value...]) do subv
        fromgenser(E, subv)
    end

    T = T.isconcretetype ? T : Set
    T(vs)
end

fromgenser(T::Type{<: AbstractVector}, v::GenserSet) = begin
    E = eltype(T)
    vs = map([v.value...]) do subv
        fromgenser(E, subv)
    end

    T(vs)
end

fromgenser(T::Type{>: Set{E}}, v::GenserSet) where E = begin
    vs = map([v.value...]) do subv
        fromgenser(E, subv)
    end
    Set(vs)::T
end

convert_to_type(m, v::GenserSet) = begin
    newv = map([v.value...]) do subv
        convert_to_type(m, subv)
    end

    Set(newv)
end


# Tuples
togenser(::Type{GenserTuple{T}}, v::T) where T = GenserTuple{T}(v)
togenser(::Type{GenserTuple{T}}, v) where T = GenserTuple{T}(T(v))

fromgenser(T::Type{<:Tuple}, v::GenserTuple) = begin
    @assert length(v.value) >= length(T.types)

    vals = []
    for (pos, E) in pairs(T.types)
        push!(vals, fromgenser(E, v.value[pos]))
    end

    T(vals)
end

fromgenser(T::Type{<:AbstractVector}, v::GenserTuple) = begin
    E = eltype(T)
    v = Base.map(v.value) do subv
        fromgenser(E, subv)
    end

    T([v...])
end

convert_to_type(m, v::GenserTuple) = begin
    v = Base.map(v.value) do subv
        convert_to_type(m, subv)
    end

    v
end

fromgenser(T::Type{Any}, v::GenserTuple) = begin
    v = Base.map(v.value) do subv
        fromgenser(Any, subv)
    end

    v
end

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

togenser(::Type{GenserDict{K,V}}, vs::T) where {K,V,T} = begin
    pairs = []
    for k = fieldnames(T)
        v = getfield(vs, k)
        k = togenser(K, k)
        v = togenser(V, v)
        push!(pairs, k => v)
    end
    newvs = Dict(pairs)
    GenserDict{K,V}(newvs)
end

fromgenser(T::Type{<:AbstractDict}, vs::GenserDict{K,V}) where K where V = begin
    TK = keytype(T)
    TV = valtype(T)
    pairs = []
    for (k,v) in vs.value
        k = fromgenser(TK, k)
        v = fromgenser(TV, v)
        push!(pairs, k => v)
    end
    T(pairs)
end

fromgenser(T::Type{>:Dict{DK, DV}}, vs::GenserDict{K,V}) where {DK, DV, K, V} = begin
    pairs = []
    for (k,v) in vs.value
        k = fromgenser(DK, k)
        v = fromgenser(DV, v)
        push!(pairs, k => v)
    end
    Dict(pairs)
end

fromgenser(T::Type{<:NamedTuple}, vs::GenserDict{K,V}) where {K, V} = begin
    args = []
    for (key, type) = zip(fieldnames(T), T.types)
        gkey = togenser(K, key)
        if haskey(vs.value, gkey)
            push!(args, fromgenser(type, vs.value[gkey]))
        else
            # Attempt to convert from nothing
            push!(args, fromgenser(type, GenserUndefined()))
        end
    end
    T(args)
end

fromgenser(T::Type{Any}, vs::GenserDict{K,V}) where {K, V} = begin
    pairs = []
    for (k,v) in vs.value
        k = fromgenser(Any, k)
        v = fromgenser(Any, v)
        push!(pairs, k => v)
    end
    Dict(pairs)
end

fromgenser(::Type{T}, v::GenserDict{K,V}) where {T,K,V} = begin
    args = []
    for (key, type) = zip(fieldnames(T), T.types)
        gkey = togenser(K, key)
        if haskey(v.value, gkey)
            push!(args, fromgenser(type, v.value[gkey]))
        else
            # Attempt to convert from nothing
            push!(args, fromgenser(type, GenserUndefined()))
        end
    end

    # TODO: Need a way to set an instantiation strategy for the type
    T(args...)
end

convert_to_type(m, vs::GenserDict{K,V}) where {K, V} = begin
    pairs = []
    for (k,v) in vs.value
        k = convert_to_type(m, k)
        v = convert_to_type(m, v)
        push!(pairs, k => v)
    end
    Dict(pairs)
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

fromgenser(T::Type{<:NamedTuple}, v::GenserRecord) = begin
    args = []
    for (key, type) = zip(fieldnames(T), T.types)
        if hasfield(typeof(v.value), key)
            push!(args, fromgenser(type, getfield(v.value, key)))
        else
            # Attempt to convert from nothing
            push!(args, fromgenser(type, GenserUndefined()))
        end
    end

    T(args)
end

fromgenser(T::Type{<:AbstractDict}, v::GenserRecord) = begin
    TK = typeof(T) == UnionAll ? Symbol : keytype(T)
    TV = typeof(T) == UnionAll ? Any : valtype(T)
    entries = []
    for (k,v) = Base.pairs(v.value)
        k = fromgenser(TK, GenserSymbol(k))
        v = fromgenser(TV, v)
        push!(entries, k => v)
    end
    T = T === AbstractDict ? Dict : T
    T(entries)
end

fromgenser(T::Type{Any}, v::GenserRecord) = begin
    Base.map(v.value) do subv
        fromgenser(Any, subv)
    end
end

fromgenser(::Type{T}, v::GenserRecord) where T = begin
    args = []
    for (key, type) = zip(fieldnames(T), T.types)
        if hasfield(typeof(v.value), key)
            push!(args, fromgenser(type, getfield(v.value, key)))
        else
            # Attempt to convert from nothing
            push!(args, fromgenser(type, GenserUndefined()))
        end
    end

    # TODO: Need a way to set an instantiation strategy for the type
    T(args...)
end

convert_to_type(m, v::GenserRecord) = begin
    Base.map(v.value) do subv
        convert_to_type(m, subv)
    end
end

# Optionals
togenser(::Type{GenserOptional{T}}, v::T) where T = GenserOptional{T}(v)
togenser(::Type{GenserOptional{T}}, v::Nothing) where T = GenserOptional{T}(GenserUndefined())
togenser(::Type{GenserOptional{T}}, v) where T = GenserOptional{T}(togenser(T, v))

fromgenser(T::Type{>: Nothing}, v::V) where V <: GenserOptional = begin
    if v.value isa GenserNothingType
        nothing
    elseif typeof(T) == Union
        fromgenser(unoptionalize(T), v.value)
    else
        fromgenser(T, v.value)
    end
end

convert_to_type(m, v::GenserOptional) = convert_to_type(m, v.value)

# Variants
togenser(::Type{GenserVariant{T}}, v::T) where T = GenserVariant{T}(v)
togenser(::Type{GenserVariant{T}}, v::V) where {T, V} = begin
    if V <: T
        return GenserVariant{T}(v)
    end

    GenserVariant{T}(togenser(v))
end

fromgenser(::Type{T}, v::V) where T where V <: GenserVariant = begin
    # TODO: Fix this
    fromgenser(T, v.value)
end
convert_to_type(m, v::GenserVariant) = convert_to_type(m, v.value)

# Any
togenser(::Type{GenserAny}, v::T) where T <: GenserDataType = GenserAny(v)
togenser(::Type{GenserAny}, v::T) where T = GenserAny(togenser(v))
fromgenser(::Type{T}, v::GenserAny) where T = fromgenser(T, v.value)
