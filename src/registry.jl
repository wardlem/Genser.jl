function genser_type_for_mime(::Type{M}) where M <: MIME
    throw(ArgumentError("no genser type registered for $M"))
end

@inline function genser_type_for_mime(m::MIME{s}) where s
    genser_type_for_mime(typeof(m))
end

@inline function genser_type_for_mime(m::S) where S <: AbstractString
    genser_type_for_mime(MIME(m))
end
