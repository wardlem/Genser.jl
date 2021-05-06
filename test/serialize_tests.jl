@testset "Serialize" begin
    @testset "JSON" begin
        @testset "Nothing" begin
            @test String(serialize(nothing, Genser.GenserJSON)) == "null"
        end

        @testset "Simple values" begin
            @test String(serialize(1, Genser.GenserJSON)) == "1"
            @test String(serialize(1.5, Genser.GenserJSON)) == "1.5"
            @test String(serialize(true, Genser.GenserJSON)) == "true"
            @test String(serialize("OK", Genser.GenserJSON)) == "\"OK\""
            @test String(serialize('a', Genser.GenserJSON)) == "\"a\""
            @test String(serialize(3//2, Genser.GenserJSON)) == "1.5"
        end

        @testset "Binary" begin
            @test String(serialize([UInt8(1),UInt8(2),UInt8(3)], Genser.GenserJSON)) == "[1,2,3]"
        end

        @testset "UUID" begin
            id = Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")
            @test String(serialize(id, Genser.GenserJSON)) == "\"266945fa-8815-402a-ab1a-7701c5f53cc3\""
        end

        @testset "Symbol" begin
            @test String(serialize(:tester, Genser.GenserJSON)) == "\"tester\""
        end

        @testset "Arrays" begin
            @test String(serialize([1,2,3], Genser.GenserJSON)) == "[1,2,3]"
            @test String(serialize([1,true,"Apple"], Genser.GenserJSON)) == "[1,true,\"Apple\"]"
            @test String(serialize([Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")], Genser.GenserJSON)) == "[\"266945fa-8815-402a-ab1a-7701c5f53cc3\"]"
        end

        @testset "Sets" begin
            @test Set(JSON.parse(String(serialize(Set([1,2,3]), Genser.GenserJSON)))) == Set([1,2,3])
            @test String(serialize(Set([Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")]), Genser.GenserJSON)) == "[\"266945fa-8815-402a-ab1a-7701c5f53cc3\"]"
        end

        @testset "Dicts" begin
            v1 = Dict("a" => 1, "b" => 2, "c" => 3)
            v2 = Dict("a" => 1, "b" => true, "c" => "Apple")
            @test JSON.parse(String(serialize(v1, Genser.GenserJSON))) == v1
            @test JSON.parse(String(serialize(v2, Genser.GenserJSON))) == v2
            @test String(serialize(Dict("A" => Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")), Genser.GenserJSON)) == "{\"A\":\"266945fa-8815-402a-ab1a-7701c5f53cc3\"}"
        end

        struct JSONSerializeStruct
            a::Int64
            b::Bool
            c::String
        end

        @testset "Records" begin
            @test String(serialize((a=1,b=true,c="Apple"), Genser.GenserJSON)) == "{\"a\":1,\"b\":true,\"c\":\"Apple\"}"
            @test String(serialize(JSONSerializeStruct(1,true,"Apple"), Genser.GenserJSON)) == "{\"a\":1,\"b\":true,\"c\":\"Apple\"}"
            @test String(serialize((a=Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3"),), Genser.GenserJSON)) == "{\"a\":\"266945fa-8815-402a-ab1a-7701c5f53cc3\"}"

            @testset "Binary encoding" begin
                struct Base64EncodeStruct
                    data::Vector{UInt8}
                end
    
                Genser.gensertypefor(::Type{Base64EncodeStruct}) = GenserRecord{@NamedTuple{data::GenserBinaryValue{Encoding{:base64}}}}
                @test String(serialize(Base64EncodeStruct(Vector{UInt8}("bananas")), Genser.GenserJSON)) == "{\"data\":\"YmFuYW5hcw==\"}"
            end
        end

        @testset "Optionals" begin
            struct JSONOptional
                a::Union{Nothing,Int64}
            end

            @test String(serialize(JSONOptional(Int64(12)), Genser.GenserJSON)) == "{\"a\":12}"
            @test String(serialize(JSONOptional(nothing), Genser.GenserJSON)) == "{\"a\":null}"
        end

        @testset "Variants" begin
            struct JSONVariant
                a::Union{Bool,Int64}
            end

            @test String(serialize(JSONVariant(Int64(12)), Genser.GenserJSON)) == "{\"a\":12}"
            @test String(serialize(JSONVariant(true), Genser.GenserJSON)) == "{\"a\":true}"
        end

        @testset "With spaces" begin
            @test String(serialize(JSONSerializeStruct(1,true,"Apple"), Genser.GenserJSON, spaces=2)) == "{\n  \"a\": 1,\n  \"b\": true,\n  \"c\": \"Apple\"\n}\n"
        end
    end
end
