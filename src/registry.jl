function genser_type_for_mime(::Type{M}) where M <: MIME
    throw(ArgumentError("no genser type registered for $M"))
end

@inline function genser_type_for_mime(m::MIME{s}) where s
    genser_type_for_mime(typeof(m))
end

@inline function genser_type_for_mime(m::M) where M <: AbstractString
    genser_type_for_mime(MIME(m))
end

function genser_converter_for_encoding(::Type{E}) where E <: Encoding
    throw(ArgumentError("no genser encoder registered for $E"))
end

@inline function genser_converter_for_encoding(e::Encoding{s}) where s
    genser_converter_for_encoding(typeof(e))
end

@inline function genser_converter_for_encoding(e::E) where E <: AbstractString
    genser_converter_for_encoding(Encoding(e))
end
