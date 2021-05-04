module DummyModule end

dummymime = MIME("dummy/dummy")
DummyMime = typeof(dummymime)
Genser.genser_type_for_mime(::Type{DummyMime}) = DummyModule

@testset "Registry" begin
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
