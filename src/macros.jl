"""
    Genser.@fieldtype(type, fieldkey, gensertype)

Override the genser type for a struct field.

```@example
using Genser

struct Person
    id::Base.UUID
    name::String
end

# Always convert the UUID to a string
@fieldtype Persion :id GenserString
```
"""
macro fieldtype(type, field, gensertype)
    type = esc(type)
    # gensertype = esc(gensertype)
    return quote
        Genser.fieldtype(::Type{$type}, ::Type{Val{$field}}) = $gensertype
    end
end

"""
    Genser.@fieldencoding(type, fieldkey, encodingkey)

Set the string encoding for a binary value.

```@example
using Genser

struct DataContainer
    contents::Vector{UInt8}
end

# Encode as base64 when serialized as a string
@fieldencoding DataContainer :contents :base64
```
"""
macro fieldencoding(type, field, encoding)
    type = esc(type)
    return quote
        Genser.fieldencoding(::Type{$type}, ::Type{Val{$field}}) = Encoding{$encoding}
    end
end
