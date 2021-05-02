using Genser
using Test

@testset "Genser.jl" begin
    include("datamodel_tests.jl")
    include("derivetype_tests.jl")
    include("convert_tests.jl")
end
