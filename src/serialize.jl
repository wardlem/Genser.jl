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

@inline function serialize(value, m::MIME; kwargs...)
    serialize(value, typeof(m); kwargs...)
end

@inline function serialize(value, m::AbstractString; kwargs...)
    serialize(value, MIME(m); kwargs...)
end

@inline function serialize(value, m; kwargs...)
    io = IOBuffer()
    serialize(io, value, m; kwargs...)
    io
end
