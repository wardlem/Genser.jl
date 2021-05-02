@enum GenserTag begin
    # Unit types
    undefined=0
    null

    # Primitive types
    int8
    uint8
    int16
    uint16
    int32
    uint32
    int64
    uint64
    int128
    uint128
    bigint
    bool
    char
    float16
    float32
    float64

    # String types
    str
    uri

    # Binary types
    binary

    # Other atoms
    uuid
    symbol

    # Array types
    sequence
    tuple
    set

    # Dict types
    dict
    record
    namedtuple

    # Union types
    variant
    optional

    # Any type
    any
end

"Base Genser data model type"
abstract type GenserDataType{t} end

"A type for non-collection values"
struct GenserValue{V, t} <: GenserDataType{t}
    value::V
end

macro genservalue(T, tag = nothing)
    if isnothing(tag)
        tag = Symbol(lowercase(String(T)))
    end

    return quote
        const GenserType = GenserValue{$T, $tag}
        GenserType
    end
end

# Categories
GenserNumberValue{V <: Number, t} = GenserValue{V, t}
GenserIntegerValue{V <: Integer, t} = GenserValue{V, t}
GenserSignedValue{V <: Signed, t} = GenserValue{V, t}
GenserUnsignedValue{V <: Unsigned, t} = GenserValue{V, t}
GenserFloatValue{V <: AbstractFloat, t} = GenserValue{V, t}
GenserStringValue{V <: AbstractString, t} = GenserValue{V, t}

# Nothing types
abstract type GenserNothingType{t} <: GenserDataType{t} end
struct GenserUndefined <: GenserNothingType{undefined} end
struct GenserNull <: GenserNothingType{null} end

# Primitive types
const GenserInt8 = @genservalue(Int8)
const GenserUInt8 = @genservalue(UInt8)
const GenserInt16 = @genservalue(Int16)
const GenserUInt16 = @genservalue(UInt16)
const GenserInt32 = @genservalue(Int32)
const GenserUInt32 = @genservalue(UInt32)
const GenserInt64 = @genservalue(Int64)
const GenserUInt64 = @genservalue(UInt64)
const GenserInt128 = @genservalue(Int128)
const GenserUInt128 = @genservalue(UInt128)
const GenserBigInt = @genservalue(BigInt)
const GenserBool = @genservalue(Bool)
const GenserChar = @genservalue(Char)

const GenserFloat16 = @genservalue(Float16)
const GenserFloat32 = @genservalue(Float32)
const GenserFloat64 = @genservalue(Float64)

const GenserString = @genservalue(String, str)
const GenserURI = @genservalue(String, uri)

const GenserBinary = @genservalue(Vector{UInt8}, binary)
const GenserUUID = @genservalue(UUID, uuid)
const GenserSymbol = @genservalue(Symbol, symbol)

struct GenserSequence{T <: GenserDataType} <: GenserDataType{sequence}
    value::AbstractVector{T}
    # item_type::GenserDataType
end

struct GenserSet{T <: GenserDataType} <: GenserDataType{set}
    value::AbstractSet{T}
    # item_type::GenserDataType
end

struct GenserTuple{T <: Tuple} <: GenserDataType{tuple}
    value::T
end

struct GenserDict{K <: GenserDataType, V <: GenserDataType} <: GenserDataType{dict}
    value::AbstractDict{K,V}
end

struct GenserRecord{T <: NamedTuple} <: GenserDataType{record}
    value::T
    # item_types::Dict{Symbol, GenserDataType}
end

struct GenserOptional{T <: GenserDataType} <: GenserDataType{optional}
    value::Union{GenserUndefined,T}
end

struct GenserVariant{T} <: GenserDataType{variant}
    value::T
end

struct GenserAny <: GenserDataType{any}
    value::GenserDataType
end

@inline function tag(::GenserDataType{t}) :: GenserTag where {t}
    t
end

@inline function tag(::Type{<: GenserDataType{t}}) :: GenserTag where {t}
    t
end

(==)(a::T, b::T) where {T <: GenserNothingType} = tag(a) == tag(b) 
(==)(a::T, b::T) where {T <: GenserDataType} = tag(a) == tag(b) && a.value == b.value
