module Genser

import Base: UUID, ==

export
    GenserTag, GenserDataType, GenserValue, GenserUndefined, GenserNull,
    GenserInt8, GenserUInt8, GenserInt16, GenserUInt16, GenserInt32, GenserUInt32,
    GenserInt64, GenserUInt64, GenserInt128, GenserUInt128,
    GenserFloat16, GenserFloat32, GenserFloat64,
    GenserBool, GenserChar, GenserBigInt,
    GenserStringValue, GenserString, GenserURI,
    GenserBinary, GenserUUID, GenserSymbol,
    GenserSequence, GenserSet, GenserTuple, GenserDict, GenserRecord,
    GenserOptional, GenserVariant, GenserAny,
    gensertypefor, togenser, fromgenser

    include("datamodel.jl")
    include("derivetype.jl")
    include("convert.jl")
end
