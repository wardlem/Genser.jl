@testset "Serialize" begin
    @testset "JSON" begin
        @testset "Nothing" begin
            @test String(take!(serialize(nothing, Genser.GenserJSON))) == "null"
        end

        @testset "Simple values" begin
            @test String(take!(serialize(1, Genser.GenserJSON))) == "1"
            @test String(take!(serialize(1.5, Genser.GenserJSON))) == "1.5"
            @test String(take!(serialize(true, Genser.GenserJSON))) == "true"
            @test String(take!(serialize("OK", Genser.GenserJSON))) == "\"OK\""
            @test String(take!(serialize('a', Genser.GenserJSON))) == "\"a\""
        end

        @testset "Binary" begin
            @test String(take!(serialize([UInt8(1),UInt8(2),UInt8(3)], Genser.GenserJSON))) == "[1,2,3]"
        end

        @testset "UUID" begin
            id = Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")
            @test String(take!(serialize(id, Genser.GenserJSON))) == "\"266945fa-8815-402a-ab1a-7701c5f53cc3\""
        end

        @testset "Symbol" begin
            @test String(take!(serialize(:tester, Genser.GenserJSON))) == "\"tester\""
        end

        @testset "Arrays" begin
            @test String(take!(serialize([1,2,3], Genser.GenserJSON))) == "[1,2,3]"
            @test String(take!(serialize([1,true,"Apple"], Genser.GenserJSON))) == "[1,true,\"Apple\"]"
            @test String(take!(serialize([Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")], Genser.GenserJSON))) == "[\"266945fa-8815-402a-ab1a-7701c5f53cc3\"]"
        end

        @testset "Sets" begin
            @test Set(JSON.parse(String(take!(serialize(Set([1,2,3]), Genser.GenserJSON))))) == Set([1,2,3])
            @test String(take!(serialize(Set([Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")]), Genser.GenserJSON))) == "[\"266945fa-8815-402a-ab1a-7701c5f53cc3\"]"
        end

        @testset "Dicts" begin
            v1 = Dict("a" => 1, "b" => 2, "c" => 3)
            v2 = Dict("a" => 1, "b" => true, "c" => "Apple")
            @test JSON.parse(String(take!(serialize(v1, Genser.GenserJSON)))) == v1
            @test JSON.parse(String(take!(serialize(v2, Genser.GenserJSON)))) == v2
            @test String(take!(serialize(Dict("A" => Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3")), Genser.GenserJSON))) == "{\"A\":\"266945fa-8815-402a-ab1a-7701c5f53cc3\"}"
        end

        struct JSONSerializeStruct
            a::Int64
            b::Bool
            c::String
        end

        @testset "Records" begin
            @test String(take!(serialize((a=1,b=true,c="Apple"), Genser.GenserJSON))) == "{\"a\":1,\"b\":true,\"c\":\"Apple\"}"
            @test String(take!(serialize(JSONSerializeStruct(1,true,"Apple"), Genser.GenserJSON))) == "{\"a\":1,\"b\":true,\"c\":\"Apple\"}"
            @test String(take!(serialize((a=Base.UUID("266945fa-8815-402a-ab1a-7701c5f53cc3"),), Genser.GenserJSON))) == "{\"a\":\"266945fa-8815-402a-ab1a-7701c5f53cc3\"}"

            @testset "Binary encoding" begin
                struct Base64EncodeStruct
                    data::Vector{UInt8}
                end
    
                Genser.gensertypefor(::Type{Base64EncodeStruct}) = GenserRecord{@NamedTuple{data::GenserBinaryType{Encoding{:base64}}}}
                @test String(take!(serialize(Base64EncodeStruct(Vector{UInt8}("bananas")), Genser.GenserJSON))) == "{\"data\":\"YmFuYW5hcw==\"}"
            end
        end

        @testset "Optionals" begin
            struct JSONOptional
                a::Union{Nothing,Int64}
            end

            @test String(take!(serialize(JSONOptional(Int64(12)), Genser.GenserJSON))) == "{\"a\":12}"
            @test String(take!(serialize(JSONOptional(nothing), Genser.GenserJSON))) == "{\"a\":null}"
        end

        @testset "Variants" begin
            struct JSONVariant
                a::Union{Bool,Int64}
            end

            @test String(take!(serialize(JSONVariant(Int64(12)), Genser.GenserJSON))) == "{\"a\":12}"
            @test String(take!(serialize(JSONVariant(true), Genser.GenserJSON))) == "{\"a\":true}"
        end

        @testset "With spaces" begin
            @test String(take!(serialize(JSONSerializeStruct(1,true,"Apple"), Genser.GenserJSON, spaces=2))) == "{\n  \"a\": 1,\n  \"b\": true,\n  \"c\": \"Apple\"\n}\n"
        end
    end
end
