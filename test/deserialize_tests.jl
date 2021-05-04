@testset "Deserialize" begin
    @testset "JSON" begin
        @testset "Nothing" begin
            @test deserialize("null", Genser.GenserJSON) === nothing
            @test deserialize(Nothing, "null", Genser.GenserJSON) === nothing
            @test deserialize(Union{Nothing,Int64}, "null", Genser.GenserJSON) === nothing
            @test_throws MethodError deserialize(Int64, "null", Genser.GenserJSON)
        end

        @testset "Simple values" begin
            @test deserialize("1", Genser.GenserJSON) === Int64(1)
            @test deserialize(Int32, "1", Genser.GenserJSON) === Int32(1)
            @test deserialize(Float16, "1", Genser.GenserJSON) === Float16(1)
            @test deserialize("1.5", Genser.GenserJSON) === Float64(1.5)
            @test deserialize(Float32, "1.5", Genser.GenserJSON) === Float32(1.5)
            @test deserialize("true", Genser.GenserJSON) === true
            @test deserialize("\"OKAY!\"", Genser.GenserJSON) === "OKAY!"
            @test deserialize(Char, "\"A\"", Genser.GenserJSON) === 'A'
        end

        @testset "Binary" begin
            @test deserialize(Vector{UInt8}, "[0,1,2]", Genser.GenserJSON) isa Vector{UInt8}
            @test deserialize(Vector{UInt8}, "[2,5,7]", Genser.GenserJSON) == [2,5,7]
        end

        @testset "UUID" begin
            id = Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")
            @test deserialize(Base.UUID, "\"266945fa-8815-402a-ab1a-7701c5f53cc3\"", Genser.GenserJSON) === id
        end

        @testset "Symbol" begin
            @test deserialize(Symbol, "\"tester\"", Genser.GenserJSON) === :tester
        end

        @testset "Arrays" begin
            @test deserialize("[1,2,3]", Genser.GenserJSON) == [1,2,3]
            @test deserialize(Vector{Int64}, "[1,2,3]", Genser.GenserJSON) == [1,2,3]
            @test eltype(deserialize(Vector{Int32}, "[1,2,3]", Genser.GenserJSON)) === Int32
            @test deserialize(Vector{Int32}, "[1,2,3]", Genser.GenserJSON) == [1,2,3]
        end

        @testset "Sets" begin
            @test deserialize(Set{Int64}, "[1,2,3]", Genser.GenserJSON) == Set([1,2,3])
            @test eltype(deserialize(Set{Int32}, "[1,2,3]", Genser.GenserJSON)) === Int32
            @test deserialize(Set{Int32}, "[1,2,3]", Genser.GenserJSON) == Set([1,2,3])
        end

        @testset "Dicts" begin
            v1 = Dict("a" => 1, "b" => 2, "c" => 3)
            v2 = Dict("a" => 1, "b" => true, "c" => "Apple")

            @test deserialize("{\"a\":1,\"b\":2,\"c\":3}", Genser.GenserJSON) == v1
            @test deserialize(typeof(v1), "{\"a\":1,\"b\":2,\"c\":3}", Genser.GenserJSON) == v1
            @test deserialize(Dict{Symbol,UInt8}, "{\"a\":1,\"b\":2,\"c\":3}", Genser.GenserJSON) == Dict(:a => 1, :b => 2, :c => 3)
            @test keytype(deserialize(Dict{Symbol,UInt8}, "{\"a\":1,\"b\":2,\"c\":3}", Genser.GenserJSON)) === Symbol
            @test valtype(deserialize(Dict{Symbol,UInt8}, "{\"a\":1,\"b\":2,\"c\":3}", Genser.GenserJSON)) === UInt8
            @test deserialize("{\"a\":1,\"b\":true,\"c\":\"Apple\"}", Genser.GenserJSON) == v2
            @test deserialize(typeof(v2), "{\"a\":1,\"b\":true,\"c\":\"Apple\"}", Genser.GenserJSON) == v2
        end

        @testset "Records" begin
            NamedJSONTuple = @NamedTuple{a::Int64,b::Bool,c::String}
            @test deserialize(NamedJSONTuple, "{\"a\":1,\"b\":true,\"c\":\"Apple\"}", Genser.GenserJSON) == (a=1,b=true,c="Apple")
            struct JSONDeserializeStruct
                a::Int64
                b::Bool
                c::String
            end
            @test deserialize(JSONDeserializeStruct, "{\"a\":1,\"b\":true,\"c\":\"Apple\"}", Genser.GenserJSON) == JSONDeserializeStruct(1,true,"Apple")

            @testset "Binary encoding" begin
                struct Base64DecodeStruct
                    data::Vector{UInt8}
                end
    
                Genser.gensertypefor(::Type{Base64DecodeStruct}) = GenserRecord{@NamedTuple{data::GenserBinaryValue{Encoding{:base64}}}}
                @test deserialize(Base64DecodeStruct, "{\"data\":\"YmFuYW5hcw==\"}", Genser.GenserJSON).data == Base64DecodeStruct(Vector{UInt8}("bananas")).data
            end
        end
    end
end
