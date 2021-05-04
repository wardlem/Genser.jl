struct Encoding{encoding} end
Encoding(encoding) = Encoding{Symbol(encoding)}()
show(io::IO, ::Encoding{encoding}) where {encoding} = print(io, "Genser.Encoding(", string(encoding), ")")
print(io::IO, ::Encoding{encoding}) where {encoding} = print(io, encoding)

function genser_converter_for_encoding end

module Base64Converter
    using Base64
    using Genser

    base64encoding = Genser.Encoding("base64")
    Base64Encoding = typeof(base64encoding)

    function decode(str::AbstractString)
        base64decode(str)
    end

    function encode(buff::Vector{UInt8})
        base64encode(buff)
    end

    Genser.genser_converter_for_encoding(::Type{Base64Encoding}) = Base64Converter
end

module HexConverter
    using Genser

    hexencoding = Genser.Encoding("hex")
    HexEncoding = typeof(hexencoding)

    function decode(str::AbstractString)
        length(str) % 2 == 0 || throw(ArgumentError("malformed hex sequence"))

        bytes = Vector{UInt8}()
        for i = 1:2:length(str)
            push!(bytes, parse(UInt8, str[i:i+1], base=16))
        end

        bytes
    end

    function encode(buff::Vector{UInt8})
        strs = map(buff) do byte
            string(byte, base=16, pad = 2)
        end

        join(strs)
    end

    Genser.genser_converter_for_encoding(::Type{HexEncoding}) = HexConverter
end
