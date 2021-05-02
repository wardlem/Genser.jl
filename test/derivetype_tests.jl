@testset "Derive type" begin
    @testset "Any type" begin
        @test Genser.gensertypefor(Any) == GenserAny
    end

    @testset "Nothing type" begin
        @test Genser.gensertypefor(Nothing) == GenserNull
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
            Char => GenserChar,
            BigInt => GenserBigInt,
            Float16 => GenserFloat16,
            Float32 => GenserFloat32,
            Float64 => GenserFloat64,
        )

        for (T, GT) in tests
            @test Genser.gensertypefor(T) == GT
        end
    end

    @testset "String types" begin
        @test Genser.gensertypefor(String) == GenserString
        @test Genser.gensertypefor(SubString) <: GenserStringValue
    end

    @testset "Binary type" begin
        @test Genser.gensertypefor(Vector{UInt8}) == GenserBinary
    end

    @testset "UUID type" begin
        @test Genser.gensertypefor(Base.UUID) == GenserUUID
    end

    @testset "Symbol type" begin
        @test Genser.gensertypefor(Symbol) == GenserSymbol
    end

    @testset "Sequence types" begin
        @test Genser.gensertypefor(Vector{Char}) == GenserSequence{GenserChar}
        @test Genser.gensertypefor(Matrix{Char}) == GenserSequence{GenserChar}
    end

    @testset "Set types" begin
        @test Genser.gensertypefor(Set{Char}) == GenserSet{GenserChar}
    end

    @testset "Tuple types" begin
        @test Genser.gensertypefor(Tuple{Int64, Bool}) == GenserTuple{Tuple{GenserInt64, GenserBool}}
    end

    @testset "Dict types" begin
        @test Genser.gensertypefor(Dict{Int64, Bool}) == GenserDict{GenserInt64, GenserBool}
    end

    @testset "Record types" begin
        T = @NamedTuple{a::Int64,b::Char}
        DT = @NamedTuple{a::GenserInt64,b::GenserChar}
        @test Genser.gensertypefor(T) == GenserRecord{DT}
        struct Person
            name::String
            age::UInt16
        end
        DT = @NamedTuple{name::GenserString,age::GenserUInt16}
        @test Genser.gensertypefor(Person) == GenserRecord{DT}
    end

    @testset "Optional types" begin
        @test Genser.gensertypefor(Union{Nothing,Char}) == GenserOptional{GenserChar}
        @test Genser.gensertypefor(Union{Nothing,Char,Int8}) == GenserOptional{GenserVariant{Union{GenserChar,GenserInt8}}}
    end

    @testset "Variant types" begin
        @test Genser.gensertypefor(Union{Char,Int8}) == GenserVariant{Union{GenserChar,GenserInt8}}
    end

    @testset "Enums as strings" begin
        @enum Fruits apple banana cherry
        @test Genser.gensertypefor(Fruits) == GenserString
    end

    @testset "Function" begin
        @test_throws ArgumentError Genser.gensertypefor(Function)
    end
end
