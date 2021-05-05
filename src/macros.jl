macro fieldencoding(type, field, encoding)
    type = esc(type)
    return quote
        Genser.fieldencoding(::Type{$type}, ::Type{Val{$field}}) = Encoding{$encoding}
    end
end
