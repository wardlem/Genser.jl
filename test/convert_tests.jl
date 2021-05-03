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
                BigInt => GenserBigInt,
                Float16 => GenserFloat16,
                Float32 => GenserFloat32,
                Float64 => GenserFloat64,
            )

            for (T, DT) = tests
                @testset "$T type" begin
                    @test togenser(GenserDataType, T(1)) == DT(T(1))
                    @test togenser(DT, T(1)) == DT(T(1))
                    @test togenser(DT, "1") == DT(T(1))
                    @test togenser(DT, 1) == DT(T(1))
                    @test togenser(DT, Char(1)) == DT(T(1))
                end
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
            @assert typeof(v) <: Matrix
            ev = [GenserInt64(1), GenserInt64(3), GenserInt64(2), GenserInt64(5)]

            @test togenser(GenserDataType, v) == GenserSequence{GenserInt64}(ev)

            # Ranges
            v = 1:3
            ev = [GenserInt64(1), GenserInt64(2), GenserInt64(3)]
            @test togenser(GenserDataType, v) == GenserSequence{GenserInt64}(ev)
        end

        @testset "Set" begin
            v = Set((Int64(1),Int64(2),Int64(3)))
            ev = Set((GenserInt64(1),GenserInt64(2),GenserInt64(3)))
            @test togenser(GenserDataType, v) == GenserSet{GenserInt64}(ev)
            @test togenser(GenserDataType, Test.GenericSet(v)) == GenserSet{GenserInt64}(Test.GenericSet(ev))
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

            v = Base.ImmutableDict("A" => Int64(1), "B" => Int64(2))
            ev = Base.ImmutableDict(
                GenserString("A") => GenserInt64(1),
                GenserString("B") => GenserInt64(2),
            )
            @test togenser(GenserDataType, v) == GenserDict{GenserString,GenserInt64}(ev)
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

            struct ToGenserTest
                a::Int32
                b::Bool
            end

            v = ToGenserTest(12, true)
            @assert gensertypefor(ToGenserTest) == GenserRecord{ET}
            @test togenser(GenserDataType, v) == GenserRecord{ET}(ev)
            @test togenser(GenserRecord{ET}, v) == GenserRecord{ET}(ev)

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

    @testset "From genser" begin
        @testset "Nothing types" begin
            @test fromgenser(Nothing, GenserUndefined()) === nothing
            @test fromgenser(Nothing, GenserNull()) === nothing
            @test fromgenser(Union{Int,Nothing}, GenserUndefined()) == nothing
            @test fromgenser(Any, GenserUndefined()) == nothing
            @test fromgenser(Union{Nothing,Char}, GenserUndefined()) == nothing
            @test_throws ArgumentError fromgenser(Int, GenserUndefined())
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
                BigInt => GenserBigInt,
                Float16 => GenserFloat16,
                Float32 => GenserFloat32,
                Float64 => GenserFloat64,
            )

            for (T, DT) = tests
                @testset "$T type" begin
                    @test fromgenser(T, DT(T(0))) == T(0)
                    @test fromgenser(T, DT(T(1))) == T(1)
                    @test fromgenser(Any, DT(T(1))) == T(1)
                    @test fromgenser(BigInt, DT(T(1))) == BigInt(1)
                    @test fromgenser(UInt8, DT(T(1))) == UInt8(1)
                    @test fromgenser(Union{T,Char}, DT(T(0))) == T(0)
                end
            end
        end

        @testset "Char type" begin
            @test fromgenser(Char, GenserChar('c')) == 'c'
            @test fromgenser(Any, GenserChar('c')) == 'c'
            @test fromgenser(Union{Char,Int}, GenserChar('c')) == 'c'
            @test fromgenser(String, GenserChar('c')) == "c"
            @test fromgenser(AbstractString, GenserChar('c')) == "c"
            @test fromgenser(Int32, GenserChar('c')) == Int32('c')
        end

        @testset "String types" begin
            @test fromgenser(String, GenserString("abc")) == "abc"
            @test fromgenser(Any, GenserString("abc")) == "abc"
            @test fromgenser(Union{String,Char}, GenserString("abc")) == "abc"
            @test fromgenser(Union{AbstractString,Char}, GenserString("abc")) == "abc"
            @test fromgenser(String, GenserURI("abc")) == "abc"
            @test fromgenser(Symbol, GenserString("abc")) == :abc
            @test fromgenser(AbstractString, GenserString("abc")) == "abc"
            @test fromgenser(Int32, GenserString("123")) == Int32(123)
            @test fromgenser(Bool, GenserString("true")) == true
            @test fromgenser(Char, GenserString("a")) == 'a'
        end

        @testset "Binary types" begin
            @test fromgenser(Vector{UInt8}, GenserBinary([UInt8(1), UInt8(2)])) == [UInt8(1), UInt8(2)]
            @test fromgenser(Any, GenserBinary([UInt8(1), UInt8(2)])) == [UInt8(1), UInt8(2)]
            @test fromgenser(Union{Vector{UInt8}, String}, GenserBinary([UInt8(1), UInt8(2)])) == [UInt8(1), UInt8(2)]
            @test fromgenser(Vector{UInt16}, GenserBinary([UInt8(0),UInt8(1),UInt8(0),UInt8(2)])) == [UInt16(1),UInt16(2)]
            @test fromgenser(String, GenserBinary([UInt8(0x61),UInt8(0x62),UInt8(0x63)])) == "abc"
            uuid = Base.UUID("f247354a-62cb-4b9b-8295-ce7b944a9669")
            uuidbuff = [reinterpret(UInt8, [hton(uuid.value)])...]
            @test fromgenser(Base.UUID, GenserBinary(uuidbuff)) == uuid
        end

        @testset "UUID" begin
            uuid = Base.UUID("f247354a-62cb-4b9b-8295-ce7b944a9669")
            @test fromgenser(Base.UUID, GenserUUID(uuid)) == uuid
            @test fromgenser(Any, GenserUUID(uuid)) == uuid
            @test fromgenser(Union{Base.UUID,String}, GenserUUID(uuid)) == uuid
            @test fromgenser(String, GenserUUID(uuid)) == "f247354a-62cb-4b9b-8295-ce7b944a9669"
            @test fromgenser(AbstractString, GenserUUID(uuid)) == "f247354a-62cb-4b9b-8295-ce7b944a9669"
            uuidbuff = [reinterpret(UInt8, [hton(uuid.value)])...]
            @test fromgenser(Vector{UInt8}, GenserUUID(uuid)) == uuidbuff
            @test fromgenser(UInt128, GenserUUID(uuid)) == uuid.value
        end

        @testset "Symbol" begin
            @test fromgenser(Symbol, GenserSymbol(:test)) === :test
            @test fromgenser(Any, GenserSymbol(:test)) === :test
            @test fromgenser(Union{String,Symbol}, GenserSymbol(:test)) === :test
            @test fromgenser(String, GenserSymbol(:test)) === "test"
            @test fromgenser(AbstractString, GenserSymbol(:test)) === "test"
        end

        @testset "Sequence" begin
            v = GenserSequence([GenserInt64(1), GenserInt64(2), GenserInt64(3)])
            ev = [Int64(1),Int64(2),Int64(3)]

            @test fromgenser(Vector{Int64}, v) == ev
            @test fromgenser(Any, v) == ev
            @test fromgenser(Union{Int64,Vector{Int64}}, v) == ev
            @test fromgenser(Union{Int64,Vector{Int32}}, v) == ev
            @test eltype(fromgenser(Union{Int64,Vector{Int32}}, v)) == Int32
            # This doesn't work right now
            # @test fromgenser(Union{Vector{Int64},Vector{Int32}}, v) == ev
            @test fromgenser(AbstractVector{Int64}, v) == ev
            @test fromgenser(Set{Int64}, v) == Set(ev)
            @test fromgenser(AbstractSet{Int64}, v) == Set(ev)
        end

        @testset "Set" begin
            v = GenserSet(Set((GenserInt64(1),GenserInt64(2),GenserInt64(3))))
            ev = Set((Int64(1),Int64(2),Int64(3)))

            @test fromgenser(Set{Int64}, v) == ev
            @test fromgenser(Any, v) == ev
            @test fromgenser(Union{Char, Set{Int64}}, v) == ev
            @test fromgenser(Union{Char, Set{Int32}}, v) == ev
            @test eltype(fromgenser(Union{Char, Set{Int32}}, v)) == Int32
            @test fromgenser(AbstractSet{Int64}, v) == ev
            @test fromgenser(Vector{Int64}, v) isa Vector{Int64}
            @test Set(fromgenser(Vector{Int64}, v)) == ev
            @test fromgenser(AbstractVector{Int64}, v) isa Vector{Int64}
            @test Set(fromgenser(AbstractVector{Int64}, v)) == ev
        end

        @testset "Tuple" begin
            ev = ('a', true)
            v = GenserTuple{Tuple{GenserChar,GenserBool}}((GenserChar('a'), GenserBool(true)))
            @test fromgenser(typeof(ev), v) == ev
            @test fromgenser(Any, v) == ev
            # @test fromgenser(Union{typeof(ev), Char}, v) == ev
            @test fromgenser(Tuple{String, UInt8}, v) == ("a", UInt8(1))
            # @test fromgenser(Union{Tuple{String, UInt8}, Char}, v) == ("a", UInt8(1))
            @test fromgenser(Vector{Any}, v) == [ev...]
            @test fromgenser(Vector, v) == [ev...]
        end

        @testset "Dict" begin
            v = GenserDict(Dict(
                GenserString("A") => GenserInt64(1),
                GenserString("B") => GenserInt64(2),
            ))
            ev = Dict("A" => Int64(1), "B" => Int64(2))
            ev2 = Dict(:A => Int32(1), :B => Int32(2))
            @test fromgenser(typeof(ev), v) == ev
            @test fromgenser(Union{typeof(ev), Char}, v) == ev
            @test fromgenser(Union{typeof(ev2), Char}, v) == ev2
            @test fromgenser(Any, v) == ev
        end

        @testset "Record" begin
            ET = @NamedTuple{a::Int32, b::Bool}
            T = GenserRecord{@NamedTuple{a::GenserInt32, b::GenserBool}}
            ev = (a = Int32(12), b = true)
            e = T((a = GenserInt32(12), b = GenserBool(true)))

            @test fromgenser(ET, e) == ev
            @test fromgenser(Any, e) == ev

            # Struct conversion
            struct FromGenserTest
                a::Int32
                b::Bool
            end

            ev = FromGenserTest(12, true)
            @test fromgenser(FromGenserTest, e) == ev

            # Dict conversion
            ev = Dict(:a => 12, :b => true)
            @test fromgenser(typeof(ev), e) == ev
            @test fromgenser(Dict, e) == ev
            @test fromgenser(AbstractDict, e) == ev

            ev = Dict("a" => 12, "b" => true)
            @test fromgenser(typeof(ev), e) == ev

            ev = Dict("a" => UInt8(12), "b" => UInt8(1))
            @test fromgenser(typeof(ev), e) == ev

            @testset "Record with optional values" begin
                ET = @NamedTuple{a::Int32, b::Union{Bool,Nothing}}
                T = GenserRecord{@NamedTuple{a::GenserInt32, b::GenserOptional{GenserBool}}}
                v1 = T((a = GenserInt32(12), b = GenserOptional{GenserBool}(GenserBool(true))))
                v2 = T((a = GenserInt32(12), b = GenserOptional{GenserBool}(GenserUndefined())))
                @test fromgenser(ET, v1) == ET([12, true])
                @test fromgenser(ET, v2) == ET([12, nothing])
            end
        end

        @testset "Optional" begin
            @test fromgenser(Union{Nothing,Bool}, GenserOptional{GenserBool}(GenserBool(true))) == true
            @test fromgenser(Union{Nothing,Bool}, GenserOptional{GenserBool}(GenserUndefined())) == nothing
        end

        @testset "Variant" begin
            T = gensertypefor(Union{Char, Bool})
            ET = Union{Char, Bool}

            @test fromgenser(ET, T(GenserBool(true))) == true
            @test fromgenser(ET, T(GenserChar('a'))) == 'a'
        end
    end
end
