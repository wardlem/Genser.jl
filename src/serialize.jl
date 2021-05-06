"""
    Genser.serialize([io::IO,] value, M::Module; kwargs...)

Serialize a value with an explicit serialization module.

If `io` is not provided, a `Vector{UInt8}` of the contents is returned.

The keyword arguments are passed to the serialization module.
"""
function serialize(io::IO, value, M::Module; kwargs...)
    if !isdefined(M, :serialize_genser)
        throw(ArgumentError("$M cannot serialize data"))
    end
    genserdata = togenser(value)

    M.serialize_genser(io, genserdata; kwargs...)
end

function serialize(io::IO, value, ::Type{M}; kwargs...) where M <: MIME
    Mod = genser_type_for_mime(M)
    serialize(io, value, Mod::Module; kwargs...)
end

"""
    Genser.serialize([io::IO,] value, mime::MIME; kwargs...)

Serialize a value using the registered serialization module for a mime type.
"""
@inline function serialize(io::IO, value, m::MIME; kwargs...)
    serialize(io, value, typeof(m); kwargs...)
end

"""
    Genser.serialize([io::IO,] value, mime::AbstractString; kwargs...)

Serialize a value using the registered serialization module for a mime type provided as a string.
"""
@inline function serialize(io::IO, value, m::AbstractString; kwargs...)
    serialize(io, value, MIME(m); kwargs...)
end

@inline function serialize(value, m; kwargs...)
    io = IOBuffer()
    serialize(io, value, m; kwargs...)
    take!(io)
end
