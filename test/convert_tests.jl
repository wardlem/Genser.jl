@testset "Conversion" begin
    @testset "To Genser" begin
        @testset "Nothing types" begin
            @test togenser(GenserUndefined, 1) == GenserUndefined()
            @test togenser(GenserNull, 1) == GenserNull()
            @test togenser(GenserDataType, nothing) == GenserNull()
        end

        @testset "Primitive types" begin
            tests = (
                Int8 => GenserInt8,
                UInt8 => GenserUInt8,
                Int16 => GenserInt16,
                UInt16 => GenserUInt16,
                Int32 => GenserInt32,
                UInt32 => GenserUInt32,
                Int64 => GenserInt64,
                UInt64 => GenserUInt64,
                Int128 => GenserInt128,
                UInt128 => GenserUInt128,
                Bool => GenserBool,
                # Char => GenserChar,
                BigInt => GenserBigInt,
                Float16 => GenserFloat16,
                Float32 => GenserFloat32,
                Float64 => GenserFloat64,
            )

            for (T, DT) = tests
                @test togenser(GenserDataType, T(1)) == DT(T(1))
                @test togenser(DT, T(1)) == DT(T(1))
                @test togenser(DT, "1") == DT(T(1))
                @test togenser(DT, 1) == DT(T(1))
                @test togenser(DT, Char(1)) == DT(T(1))
            end
        end

        @testset "Char type" begin
            @test togenser(GenserDataType, 'c') == GenserChar('c')
            @test togenser(GenserChar, 'c') == GenserChar('c')
            @test togenser(GenserChar, 1) == GenserChar(Char(1))
            @test togenser(GenserChar, "c") == GenserChar('c')
        end

        @testset "String types" begin
            @test togenser(GenserDataType, "ABC") == GenserString("ABC")
            @test togenser(GenserString, "ABC") == GenserString("ABC")
            @test togenser(GenserURI, "ABC") == GenserURI("ABC")
            @test togenser(GenserDataType, SubString("ABC"))  == GenserStringValue{SubString{String}, Genser.str}(SubString("ABC"))
            @test togenser(GenserString, :a) == GenserString("a")
            @test togenser(GenserString, Base.UUID("f247354a-62cb-4b9b-8295-ce7b944a9669")) == GenserString("f247354a-62cb-4b9b-8295-ce7b944a9669")
        end

        @testset "Binary type" begin
            @test togenser(GenserDataType, [UInt8(1),UInt8(2)]) == GenserBinary([UInt8(1),UInt8(2)])
            @test togenser(GenserBinary, [UInt8(1),UInt8(2)]) == GenserBinary([UInt8(1),UInt8(2)])
            @test togenser(GenserBinary, [Int8(1),Int8(2)]) == GenserBinary([UInt8(1),UInt8(2)])
            @test togenser(GenserBinary, [Int8(-1),Int8(-2)]) == GenserBinary([UInt8(255),UInt8(254)])
            @test togenser(GenserBinary, [UInt16(1),UInt16(2)]) == GenserBinary([UInt8(0),UInt8(1),UInt8(0),UInt8(2)])
            @test togenser(GenserBinary, "abc") == GenserBinary([UInt8(0x61),UInt8(0x62),UInt8(0x63)])
        end

        @testset "UUID" begin
            uuid = Base.UUID("f247354a-62cb-4b9b-8295-ce7b944a9669")
            @test togenser(GenserDataType, uuid) == GenserUUID(uuid)
            @test togenser(GenserUUID, uuid) == GenserUUID(uuid)
            @test togenser(GenserUUID, uuid.value) == GenserUUID(uuid)
            uuidbuff = [reinterpret(UInt8, [hton(uuid.value)])...]
            @test togenser(GenserUUID, uuidbuff) == GenserUUID(uuid)
        end

        @testset "Symbol" begin
            @test togenser(GenserDataType, :a) == GenserSymbol(:a)
            @test togenser(GenserSymbol, :a) == GenserSymbol(:a)
            @test togenser(GenserSymbol, "a") == GenserSymbol(:a)
        end

        @testset "Sequence" begin
            # Normal Vectors
            v = [Int64(1),Int64(2),Int64(3)]
            ev = [GenserInt64(1), GenserInt64(2), GenserInt64(3)]
            @test togenser(GenserDataType, v) == GenserSequence{GenserInt64}(ev)
            @test togenser(GenserSequence{GenserInt64}, v) == GenserSequence{GenserInt64}(ev)

            # Strings
            @test togenser(GenserSequence{GenserChar}, "ABC") == GenserSequence{GenserChar}([GenserChar('A'), GenserChar('B'), GenserChar('C')])
            @test togenser(GenserSequence{GenserInt64}, "ABC") == GenserSequence{GenserInt64}([GenserInt64('A'), GenserInt64('B'), GenserInt64('C')])

            # Works with "binary" type if explicitly set
            @test togenser(GenserSequence{GenserUInt8}, [UInt8(1), UInt8(2)]) == GenserSequence{GenserUInt8}([GenserUInt8(1), GenserUInt8(2)])

            # Matrices are treated as one-dimensional arrays
            v = [
                Int64(1) Int64(2)
                Int64(3) Int64(5)
            ]
            ev = [GenserInt64(1), GenserInt64(3), GenserInt64(2), GenserInt64(5)]

            @test togenser(GenserDataType, v) == GenserSequence{GenserInt64}(ev)
        end

        @testset "Set" begin
            v = Set((Int64(1),Int64(2),Int64(3)))
            ev = Set((GenserInt64(1),GenserInt64(2),GenserInt64(3)))
            @test togenser(GenserDataType, v) == GenserSet{GenserInt64}(ev)
            @test togenser(GenserSet{GenserInt64}, v) == GenserSet{GenserInt64}(ev)
            @test togenser(GenserSet{GenserChar}, "ABC") == GenserSet{GenserChar}(Set((GenserChar('A'),GenserChar('B'),GenserChar('C'))))
        end

        @testset "Tuple" begin
            v = ('a', true)
            @test togenser(GenserDataType, v) == GenserTuple{Tuple{GenserChar,GenserBool}}(v)
            @test togenser(GenserTuple{Tuple{GenserChar,GenserBool}}, v) == GenserTuple{Tuple{GenserChar,GenserBool}}(v)
            @test togenser(GenserTuple{Tuple{GenserChar,GenserBool}}, ['a', true]) == GenserTuple{Tuple{GenserChar,GenserBool}}(v)
        end

        @testset "Dict" begin
            v = Dict("A" => Int64(1), "B" => Int64(2))
            ev = Dict(
                GenserString("A") => GenserInt64(1),
                GenserString("B") => GenserInt64(2),
            )

            ev2 = Dict(
                GenserString("A") => GenserUInt64(1),
                GenserString("B") => GenserUInt64(2),
            )
            @test togenser(GenserDataType, v) == GenserDict{GenserString,GenserInt64}(ev)
            @test togenser(GenserDict{GenserString,GenserInt64}, v) == GenserDict{GenserString,GenserInt64}(ev)
            @test togenser(GenserDict{GenserString,GenserUInt64}, v) == GenserDict{GenserString,GenserUInt64}(ev2)
        end

        @testset "Record" begin
            T = @NamedTuple{a::Int32, b::Bool}
            ET = @NamedTuple{a::GenserInt32, b::GenserBool}
            v = (a = Int32(12), b = true)
            ev = (a = GenserInt32(12), b = GenserBool(true))
            @assert v isa T
            @test togenser(GenserDataType, v) == GenserRecord{ET}(ev)
            @test togenser(GenserRecord{ET}, v) == GenserRecord{ET}(ev)
            @test togenser(GenserRecord{ET}, Dict(:a => 12, :b => true)) == GenserRecord{ET}(ev)
            @test togenser(GenserRecord{ET}, Dict("a" => 12, "b" => true)) == GenserRecord{ET}(ev)

            @testset "Record with optional values" begin
                T = @NamedTuple{a::Int32, b::Union{Bool,Nothing}}
                ET = @NamedTuple{a::GenserInt32, b::GenserOptional{GenserBool}}
                @assert gensertypefor(T) == GenserRecord{ET}
                ev1 = (a = GenserInt32(12), b = GenserOptional{GenserBool}(GenserBool(true)))
                ev2 = (a = GenserInt32(12), b = GenserOptional{GenserBool}(GenserUndefined()))
                @test togenser(GenserRecord{ET}, Dict("a" => 12, "b" => true)) == GenserRecord{ET}(ev1)
                @test togenser(GenserRecord{ET}, Dict("a" => 12)) == GenserRecord{ET}(ev2)
            end
        end

        @testset "Optional" begin
            @test togenser(GenserOptional{GenserBool}, true) == GenserOptional{GenserBool}(GenserBool(true))
            @test togenser(GenserOptional{GenserBool}, nothing) == GenserOptional{GenserBool}(GenserUndefined())
        end

        @testset "Variant" begin
            T = gensertypefor(Union{Char, Bool})
            @test togenser(T, true) == T(GenserBool(true))
            @test togenser(T, 'a') == T(GenserChar('a'))
        end

        @testset "Any" begin
            @test togenser(GenserAny, 'c') == GenserAny(GenserChar('c'))
        end

        @testset "Enums" begin
            @enum Planets tattoine degobah yavin
            @test togenser(tattoine) == GenserString("tattoine")
        end
    end
end
