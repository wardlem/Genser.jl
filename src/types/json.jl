module GenserJSON
import JSON
using Genser

const typeid = Genser.TypeID("genserjson")
const TID = typeof(typeid)

function serialize_genser(io::IO, gdata::D; kwargs...) where D <: GenserDataType
    spaces = nothing
    if haskey(kwargs, :spaces)
        spaces = kwargs[:spaces]
    end

    data = convert_to_type(typeid, gdata)
    if data isa AbstractDict || true
        JSON.print(io, data, spaces)
    else
        JSON.print(io, data)
    end
end

function deserialize_genser(io::Union{IO,AbstractString}; kwargs...)
    dicttype = Dict
    inttype = Int64

    if haskey(kwargs, :dicttype)
        dicttype = kwargs[:dicttype]
    end

    if haskey(kwargs, :inttype)
        inttype = kwargs[:inttype]
    end

    raw = JSON.parse(io, dicttype=dicttype, inttype=inttype)
    togenser(raw)
end

Genser.convert_to_type(::TID, v::GenserUUID) = string(v.value)

end
