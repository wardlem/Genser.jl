# Data Model API

The genser data model is the intermediate representation between the
application data and types serializable by a serialization format.

## Base Types

```@docs
Genser.GenserDataType
Genser.GenserValue
```

## Category Types

```@docs
Genser.GenserNothingValue
Genser.GenserNumberValue
Genser.GenserRealValue
Genser.GenserIntegerValue
Genser.GenserSignedValue
Genser.GenserUnsignedValue
Genser.GenserFloatValue
Genser.GenserStringValue
Genser.GenserBinaryValue
```

## Nothing Types

```@docs
Genser.GenserUndefined
Genser.GenserNull
```

## Value Types

```@docs
Genser.GenserAny
Genser.GenserInt8
Genser.GenserUInt8
Genser.GenserInt16
Genser.GenserUInt16
Genser.GenserInt32
Genser.GenserUInt32
Genser.GenserInt64
Genser.GenserUInt64
Genser.GenserInt128
Genser.GenserUInt128
Genser.GenserBigInt
Genser.GenserFloat16
Genser.GenserFloat32
Genser.GenserFloat64
Genser.GenserBigFloat
Genser.GenserRational
Genser.GenserBool
Genser.GenserChar
Genser.GenserSymbol
Genser.GenserUUID
Genser.GenserString
Genser.GenserURI
Genser.GenserBinary
```

## Complex Types

```@docs
Genser.GenserSequence
Genser.GenserSet
Genser.GenserTuple
Genser.GenserDict
Genser.GenserRecord
Genser.GenserOptional
Genser.GenserVariant
```

## Metadata Types

```@docs
Genser.Tag
Genser.Tag(tag)
Genser.Encoding
Genser.Encoding(encoding)
```

## Functions

```@docs
Genser.gensertypefor
Genser.tag
Genser.encoding
```

## Macros

```@docs
Genser.@fieldtype
Genser.@fieldencoding
```
