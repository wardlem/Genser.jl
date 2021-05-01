@testset "Data model" begin
    @testset "Type dispatch" begin
        function thingwithstring(::GenserStringValue) true end

        @test thingwithstring(GenserString("OK"))
        intv = GenserInt8(1)
        @test_throws MethodError thingwithstring(intv)
    end

    @testset "Tag dispatch" begin
        function thingwithuri(::GenserDataType{Genser.uri}) true end

        @test thingwithuri(GenserURI("OK"))
        strv = GenserString("OK")
        @test_throws MethodError thingwithuri(strv)
    end

    @testset "Tag" begin
        @test Genser.tag(GenserURI) == Genser.uri
        @test Genser.tag(GenserNull()) == Genser.null
        @test Genser.tag(GenserNull) == Genser.null
        @test Genser.tag(GenserSequence{Vector{Int8}}) == Genser.sequence
    end
end
