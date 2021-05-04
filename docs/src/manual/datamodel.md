# Data Model

A large amount of Genser's functionality is provided by transforming primary data into an intermediate representation.
This intermediate representation is called the "Genser Data Model."

For the most part, you willn not need to think about the data model unless you need to implement custom behavior for your project's types or are implementing a (de)serializer plugin.
Genser knows how to automatically derive it's data model from most Julia's built-in types.

!!! note

    Genser is currently in an early stage of development and the data model is likely to be refined as time goes on. A goal of Genser is to provide built-in support for all or most of the data types provided in Julia's base and standard library. If you run into a situation where a data type you need in your project is not yet supported, please [file an issue](https://github.com/wardlem/Genser.jl/issues) so the type can be implemented.

## Tags

All Genser data model types have tag as part of their type.
These tags typically match the type of data they contain, but may also be utilized to provide additional context.
The tag for a genser value or type can be retrieved with the `tag` function.

```julia
julia> using Genser

julia> Genser.tag(GenserInt64)
Genser.Tag(:int64)

julia> Genser.tag(GenserURI)
Genser.Tag(:uri)
```

Tags can be used for dispatching.

```julia
handle_uri(::GenserDataType{Genser.uri}) = "a URI tagged value"
```

It is possible to create custom Genser data model types with custom tags, though care must be taken to ensure the (de)serialization plugins know how to handle the value.

## Base type

The base type for all Genser data model types is `GenserDataType{tag}`.

## Nothing types

- `GenserUndefined()`
- `GenserNull()`

The default type for nothing values is `GenserNull`.

The parent type for nothing values is `GenserNothingType{tag}`.

## Basic types

- `GenserInt8(::Int8)`
- `GenserUInt8(::UInt8)`
- `GenserInt16(::Int16)`
- `GenserUInt16(::UInt16)`
- `GenserInt32(::Int32)`
- `GenserUInt32(::UInt32)`
- `GenserInt64(::Int64)`
- `GenserUInt64(::UInt64)`
- `GenserInt128(::Int128)`
- `GenserUInt128(::UInt128)`
- `GenserBigInt(::BigInt)`
- `GenserFloat16(::Float16)`
- `GenserFloat32(::Float32)`
- `GenserFloat64(::Float64)`
- `GenserBool(::Bool)`
- `GenserChar(::Char)`

The parent type for basic types is `GenserValue{V, tag}` where `V` is the type of the value held by the type.

Additional, the following category types are available for dispatching.

- `GenserNumberValue{V <: Number}`
- `GenserIntegerValue{V <: Integer}`
- `GenserSignedValue{V <: Signed}`
- `GenserUnsignedValue{V <: Unsigned}`
- `GenserFloatValue{V <: AbstractFloat}`

## String types

Strings are handle much like basic types, though the tag is used to provide additional context about the meaning of contained value.

- `GenserString(::String)`
- `GenserURI(::String)`

The category type `GenserStringValue{V <: AbstractString}` may be used to dispatch on all genser string types.

The default type for all string values is `GenserString`.

## Binary types

A binary type is a type that represents `Vector{UInt8}` data.
In general, they work in a similar manner to basic types.
However, they contain an additional `Encoding` parameter that acts as a hint to deserializers about how to convert the value to a string if the format (e.g. JSON) does not support binary values natively.

- `GenserBinary(::Vector{UInt8})`

The base type for binary values is `GenserBinaryValue{E <: Encoding}`.  This type can be used to dispatch on all binary types regardless of the intended encoding.  The encoding for `GenserBinary` is `Genser.Encoding{:none}` which indicates that the value should not be stringified (in JSON it is serialized as an array of bytes).

The default type for all `Vector{Uint8}` values is `GenserBinary`.

## Additional value types

- `GenserUUID(::Base.UUID)`
- `GenserSymbol(::Symbol)`

## Sequence types

A sequence represents any array type other than `Vector{UInt8}`.
All Genser sequence types are one-dimensional.

- `GenserSequence{T <: GenserDataType}`

The value of a sequence type is an `AbstractVector`.

As an example, a `Vector{Char}` would be be derived as a `GenserSequence{VectorChar}`.

## Set types

A sequence represents an abstract set of values

- `GenserSet{T <: GenserDataType}`

The value of a set type is an `AbstractSet`.

As an example, a `Set{Char}` would be be derived as a `GenserSet{VectorChar}`.

A set type is typically serialized in the same format as a sequence type.

## Tuple types

A tuple type is a fixed-length sequence of heterogenous values.

- `GenserTuple{T <: Tuple}` where each type in the tuple is a `GenserDataType`

A tuple type is typically serialized in the same format as a sequence type.

This is the default type for all `Tuple` values.

## Dict types

A dict type is a non-fixed sized container of key-value pairs.

- `GenserDict{K <: GenserDataType, V <: GenserDataType}`

For compatibility with (de)serializers, it is recommended that serialized dictionarys contain keys that can be converted to and from a string.

A dict type is the default type for all `AbstractDict` values.

## Record types

A record type is a fixed length sequence of heterogenous key-value pairs.

- `GensorRecord{T <: NamedTuple}` where each type in the named tuple is a `GenserDataType`

The keys of a record type are always symbol values.
Genser always stores the record as a named tuple internally.

A record type is the default type for all `NamedTuple` and `struct` values.

## Optional types

An optional type is a type that may or may not have a value.

- `GenserOptional{T <: GenserDataType}`

An optional type is the default type for all `Union` types that include `Nothing`.

## Variant types

A variant is a value that can contain a value of one or more different types.

- `GenserVariant{T <: GenserDataType}` where T is a Union.

A variant type is the default for all `Union` types that do not include `Nothing`.
