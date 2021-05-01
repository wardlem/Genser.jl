module Genser

import Base.UUID

export
    GenserTag, GenserDataType, GenserValue, GenserUndefined, GenserNull,
    GenserInt8, GenserUInt8, GenserInt16, GenserUInt16, GenserInt32, GenserUInt32,
    GenserInt64, GenserUInt64, GenserInt128, GenserUInt128, GenserFloat32, GenserFloat64,
    GenserBool, GenserChar,
    GenserStringValue, GenserString, GenserURI,
    GenserBinary, GenserUUID,
    GenserSequence, GenserSet, GenserDict, GenserRecord,
    GenserOptional, GenserVariant, GenserAny

    include("datamodel.jl")
end
