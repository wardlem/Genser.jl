module Genser

import Base: UUID, ==
using Requires

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
    gensertypefor, togenser, fromgenser, convert_to_type,
    genser_type_for_mime, serialize, deserialize,
    TypeID

    include("datamodel.jl")
    include("derivetype.jl")
    include("convert.jl")
    include("serialize.jl")
    include("deserialize.jl")
    include("registry.jl")

    function __init__()
        @require JSON="682c06a0-de6a-54ab-a142-c8b1cf79cde6" include("types/json.jl")
    end
end
