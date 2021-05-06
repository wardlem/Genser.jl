"""
    Genser.Tag{tag}

The type of genser tags.

Tags provide additional semantic metadata about a genser type.
They are particular useful for string values because some
(de)serializers are capable of including additional metadata
in their output.

Each tag is a singleton of a unique data type.
"""
struct Tag{tag} end

"""
    Genser.Tag(tag)

Construct a tag for a Genser type.
"""
Tag(tag) = Tag{Symbol(tag)}()
Base.show(io::IO, ::Tag{tag}) where {tag} = Base.print(io, "Genser.Tag(:$tag)")
Base.print(io::IO, ::Tag{tag}) where {tag} = Base.print(io, tag)

tags = [
    # Unit types
    :undefined,
    :null,

    # Primitive types
    :int8,
    :uint8,
    :int16,
    :uint16,
    :int32,
    :uint32,
    :int64,
    :uint64,
    :int128,
    :uint128,
    :bigint,
    :bool,
    :char,
    :float16,
    :float32,
    :float64,
    :rational,
    :bigfloat,

    # String types
    :str,
    :uri,

    # Binary types
    :binary,
    # TODO: Add string encoding suggestions (e.g. base64)

    # Other atoms
    :uuid,
    :symbol,

    # Array types
    :sequence,
    :tuple,
    :set,

    # Dict types
    :dict,
    :record,
    :namedtuple,

    # Union types
    :variant,
    :optional,

    # Any type
    :any,
]

for tag = tags
    tagstr = string(tag)
    @eval const $tag = Tag($tagstr)
end

"""
    Genser.GenserDataType{tag}

Base Genser data model type.
"""
abstract type GenserDataType{t} end

"""
    Genser.GenserValue{V, tag}

Base Genser data model type for simple values.
"""
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
"""
    Genser.GenserNumberValue{V <: Number, tag}

A category type for genser values that hold a Number.
"""
GenserNumberValue{V <: Number, t} = GenserValue{V, t}

"""
    Genser.GenserRealValue{V <: Real, tag}

A category type for genser values that hold a Real.
"""
GenserRealValue{V <: Real, t} = GenserValue{V, t}

"""
    Genser.GenserIntegerValue{V <: Integer, tag}

A category type for genser values that hold an Integer.
"""
GenserIntegerValue{V <: Integer, t} = GenserValue{V, t}

"""
    Genser.GenserSignedValue{V <: Signed, tag}

A category type for genser values that hold a Signed.
"""
GenserSignedValue{V <: Signed, t} = GenserValue{V, t}

"""
    Genser.GenserUnsignedValue{V <: Unsigned, tag}

A category type for genser values that hold an Unsigned.
"""
GenserUnsignedValue{V <: Unsigned, t} = GenserValue{V, t}

"""
    Genser.GenserFloatValue{V <: AbstractFloat, tag}

A category type for genser values that hold an AbstractFloat.
"""
GenserFloatValue{V <: AbstractFloat, t} = GenserValue{V, t}

"""
    Genser.GenserStringValue{tag}

A category type for genser values that hold an AbstractString.
"""
GenserStringValue{t} = GenserValue{AbstractString, t}

# Nothing types
"""
    Genser.GenserNothingValue{tag}

A category type for genser values that hold a Nothing.
"""
abstract type GenserNothingValue{t} <: GenserDataType{t} end

"""
    Genser.GenserUndefined()

A type that holds nothing, tagged to suggest that it holds an "undefined" value.
"""
struct GenserUndefined <: GenserNothingValue{undefined} end

"""
    Genser.GenserNull()

A type that holds nothing, tagged to suggest that it holds a "null" value.
"""
struct GenserNull <: GenserNothingValue{null} end

# Primitive types
"""
    Genser.GenserInt8(value::Int8)

A type that holds an Int8 value.
"""
const GenserInt8 = @genservalue(Int8)

"""
    Genser.GenserUInt8(value::UInt8)

A type that holds a UInt8 value.
"""
const GenserUInt8 = @genservalue(UInt8)

"""
    Genser.GenserInt16(value::Int16)

A type that holds an Int16 value.
"""
const GenserInt16 = @genservalue(Int16)

"""
    Genser.GenserUInt16(value::UInt16)

A type that holds a UInt16 value.
"""
const GenserUInt16 = @genservalue(UInt16)

"""
    Genser.GenserInt32(value::Int32)

A type that holds an Int32 value.
"""
const GenserInt32 = @genservalue(Int32)

"""
    Genser.GenserUInt32(value::Int32)

A type that holds a UInt32 value.
"""
const GenserUInt32 = @genservalue(UInt32)

"""
    Genser.GenserInt64(value::Int64)

A type that holds an Int64 value.
"""
const GenserInt64 = @genservalue(Int64)

"""
    Genser.GenserUInt64(value::UInt64)

A type that holds a UInt64 value.
"""
const GenserUInt64 = @genservalue(UInt64)

"""
    Genser.GenserInt128(value::Int128)

A type that holds an Int128 value.
"""
const GenserInt128 = @genservalue(Int128)

"""
    Genser.GenserUInt128(value::UInt128)

A type that holds a UInt128 value.
"""
const GenserUInt128 = @genservalue(UInt128)

"""
    Genser.GenserBigInt(value::BigInt)

A type that holds a BigInt value.
"""
const GenserBigInt = @genservalue(BigInt)

"""
    Genser.GenserBool(value::Bool)

A type that holds a Bool value.
"""
const GenserBool = @genservalue(Bool)

"""
    Genser.GenserChar(value::Char)

A type that holds a Char value.
"""
const GenserChar = @genservalue(Char)

"""
    Genser.GenserFloat16(value::Float16)

A type that holds a Float16 value.
"""
const GenserFloat16 = @genservalue(Float16)

"""
    Genser.GenserFloat32(value::Float32)

A type that holds a Float32 value.
"""
const GenserFloat32 = @genservalue(Float32)

"""
    Genser.GenserFloat64(value::Float64)

A type that holds a Float64 value.
"""
const GenserFloat64 = @genservalue(Float64)

"""
    Genser.GenserBigFloat(value::BigFloat)

A type that holds a BigFloat value.
"""
const GenserBigFloat = @genservalue(BigFloat)

"""
    Genser.GenserRational(value::Rational)

A type that holds a Rational value.
"""
const GenserRational = @genservalue(Rational)

"""
    Genser.GenserString(value::AbstractString)

A type that holds a String value.
"""
const GenserString = GenserStringValue{str}

"""
    Genser.GenserURI(value::AbstractString)

A type that holds a String value tagged as a URI value.
"""
const GenserURI = GenserStringValue{uri}

"""
    Genser.GenserBinaryValue{E <: Encoding}(value::Vector{UInt8})

A category type for genser values that hold binary data.
The encoding type parameter is used to convert the data to and from
a string representation for formats that do not support binary types.
"""
struct GenserBinaryValue{E<:Encoding} <: GenserDataType{binary}
    value::Vector{UInt8}
end

"""
    Genser.GenserBinary(value::Vector{UInt8})

A binary type with no string encoding.

This is the default Genser type for Vector{UInt8} value.
"""
const GenserBinary = GenserBinaryValue{Encoding{:none}}

"""
    Genser.GenserUUID(value::Base.UUID)

A type that holds a UUID value.

Typically, a UUID is serialized into its string representation
for text-based formats and binary representation for binary formats.
Some formats may have built-in support for the type.
"""
const GenserUUID = @genservalue(UUID, uuid)

"""
    Genser.GenserSymbol(value::Symbol)

A type that holds a Symbol value.

Typically, a Symbol is serialized into its string representation, 
but formats may have built-in support for type type.
"""
const GenserSymbol = @genservalue(Symbol, symbol)

"""
    Genser.GenserSequence{V <: GenserDataType}(AbstractVector{V})

A type that holds an AbstractVector of values.
"""
struct GenserSequence{T <: GenserDataType} <: GenserDataType{sequence}
    value::AbstractVector{T}
end

"""
    Genser.GenserSet{V <: GenserDataType}(AbstractSet{V})

A type that holds an AbstractSet of values.

Typically, a set is serialized in the same format as a sequence.
"""
struct GenserSet{T <: GenserDataType} <: GenserDataType{set}
    value::AbstractSet{T}
end

"""
    Genser.GenserSet{V <: Tuple}(value::V)

A type that holds a Tuple of values.

Typically, a tuple is serialized in the same format as a sequence.
"""
struct GenserTuple{T <: Tuple} <: GenserDataType{tuple}
    value::T
end

"""
    Genser.GenserDict{K <: GenserDataType, V <: GenserDataType}(value::AbstractDict{K,V}())

A type that holds an AbstractDict of values.

For compatibility, the K type should be type that can be stringified.
"""
struct GenserDict{K <: GenserDataType, V <: GenserDataType} <: GenserDataType{dict}
    value::AbstractDict{K,V}
end

"""
    Genser.GenserRecord{V <: NamedTuple}(value::V)

A type that holds a fixed set of key-value pairs.

The is the default type for all structs.
"""
struct GenserRecord{T <: NamedTuple} <: GenserDataType{record}
    value::T
end

"""
    Genser.GenserOptional{V <: GenserDataType}(value::Union{GenserUndefined, V})

A type that may or may not hold a value.

The is the default type for all Union types that include Nothing.
"""
struct GenserOptional{T <: GenserDataType} <: GenserDataType{optional}
    value::Union{GenserUndefined,T}
end

"""
    Genser.GenserVariant{V <: GenserDataType}(value::V)

A type that may contain a value of one or more types.

The `V` type parameter is always a Union type.

The is the default type for all Union types that do not include Nothing.
"""
struct GenserVariant{T <: GenserDataType} <: GenserDataType{variant}
    value::T
end

"""
    Genser.GenserAny(value::GenserDataType)

A type that may or may hold any type of value.

The is the default type for the Any type.
"""
struct GenserAny <: GenserDataType{any}
    value::GenserDataType
end

"""
    Genser.tag(v) :: Genser.Tag

Get the tag of a Genser data type or Genser value.
"""
@inline function tag(::GenserDataType{t}) :: Tag where {t}
    t
end

@inline function tag(::Type{<: GenserDataType{t}}) :: Tag where {t}
    t
end

"""
    Genser.encoding(::Type{<: GenserDataType}) :: Genser.Encoding

Get the string encoding of a genser data type or value.
"""
@inline function encoding(::Type{<: GenserDataType}) :: Encoding
    Encoding("none")
end

@inline function encoding(::Type{<: GenserBinaryValue{E}}) :: Encoding where E
    E()
end

(==)(a::T, b::T) where {T <: GenserNothingValue} = tag(a) == tag(b) 
(==)(a::T, b::T) where {T <: GenserDataType} = tag(a) == tag(b) && a.value == b.value
