macro fieldtype(type, field, gensertype)
    type = esc(type)
    # gensertype = esc(gensertype)
    return quote
        Genser.fieldtype(::Type{$type}, ::Type{Val{$field}}) = $gensertype
    end
end

macro fieldencoding(type, field, encoding)
    type = esc(type)
    return quote
        Genser.fieldencoding(::Type{$type}, ::Type{Val{$field}}) = Encoding{$encoding}
    end
end
