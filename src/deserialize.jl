function deserialize(to::Type, value, M::Module; kwargs...)
    if !isdefined(M, :deserialize_genser)
        throw(ArgumentError("$M cannot deserialize data"))
    end

    genserdata = M.deserialize_genser(value; kwargs...)

    fromgenser(to, genserdata::GenserDataType)
end

function deserialize(to::Type, value, ::Type{M}; kwargs...) where M <: MIME
    Mod = genser_type_for_mime(M)
    deserialize(to, value, Mod::Module; kwargs...)
end

@inline function deserialize(to::Type, value, m::MIME; kwargs...)
    deserialize(to, value, typeof(m); kwargs...)
end

@inline function deserialize(to::Type, value, m::AbstractString; kwargs...)
    deserialize(to, value, MIME(m); kwargs...)
end

@inline function deserialize(value, m; kwargs...)
    deserialize(Any, value, m; kwargs...)
end 
