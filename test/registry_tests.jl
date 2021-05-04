module DummyModule end

dummymime = MIME("dummy/dummy")
DummyMime = typeof(dummymime)
Genser.genser_type_for_mime(::Type{DummyMime}) = DummyModule

dummyencoding = Encoding("dummy")
DummyEncoding = typeof(dummyencoding)
Genser.genser_converter_for_encoding(::Type{DummyEncoding}) = DummyEncoding

@testset "Registry" begin
    @testset "types" begin
        @testset "With mime type" begin
            @test genser_type_for_mime(DummyMime) == DummyModule
        end
    
        @testset "With mime value" begin
            @test genser_type_for_mime(MIME("dummy/dummy")) == DummyModule
        end
    
        @testset "With mime string" begin
            @test genser_type_for_mime("dummy/dummy") == DummyModule
        end
    
        @testset "Unregistered" begin
            @test_throws ArgumentError genser_type_for_mime("dummy/unregistered")
        end
    end

    @testset "encoding converters" begin
        @testset "With encoding type" begin
            genser_converter_for_encoding(DummyEncoding) == DummyModule
        end

        @testset "With encoding value" begin
            genser_converter_for_encoding(Encoding("dummy")) == DummyModule
        end

        @testset "With encoding string" begin
            genser_converter_for_encoding("dummy") == DummyModule
        end

        @testset "Unregistered" begin
            @test_throws ArgumentError genser_converter_for_encoding("unregistered")
        end
    end
end
