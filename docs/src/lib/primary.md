# Primary API

## Serialization

```@docs
Genser.serialize(::IO, value, ::Module; kwargs...)
Genser.serialize(::IO, value, ::MIME; kwargs...)
Genser.serialize(::IO, value, ::AbstractString; kwargs...)
```

## Deserialization
```@docs
Genser.deserialize(::Type, value, ::Module; kwargs...)
Genser.deserialize(::Type, value, ::MIME; kwargs...)
Genser.deserialize(::Type, value, ::AbstractString; kwargs...)
```
