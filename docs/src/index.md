```@meta
CurrentModule = Genser
```

# Genser

Documentation for [Genser](https://github.com/wardlem/Genser.jl).

*Generic serialization and deserialization for Julia.*

## Package Features

- Serialize and deserialize structured data to and from any format via a plugin.
- Customization of how structs are serialized / deserialized.
- String encoding for binary data.

## Examples

### Automatic handling of structures

```julia
using Genser
import GenserJSON
import GenserCBOR

struct Person
    name::String
    age::Uint8
end

mary = Person("Mary", 35)
json = serialize(mary, "application/json")
@assert deserialize(Person, json, "application/json") == mary

cbor = serialize(mary, "application/cbor")
@assert deserialize(Person, cbor, "application/cbor") == mary
```

### Binary string encoding

```julia
using Genser
import GenserJSON

struct DataContainer
    contents::Vector{UInt8}
end

@propencoding DataContainer :contents :base64

data = DataContainer(UInt8[10,9,8,7])
json = serialize(data, "application/json")
@assert String(json) == "{\"contents\":\"CgkIBw==\"}"

deserialized = deserialize(DataContainer, json, "application/json")
@assert deserialized.contents == data.contents
```

```@index
```
