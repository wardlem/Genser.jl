using Genser
using Test
import JSON

@testset "Genser.jl" begin
    include("datamodel_tests.jl")
    include("derivetype_tests.jl")
    include("convert_tests.jl")
    include("registry_tests.jl")
    include("serialize_tests.jl")
    include("deserialize_tests.jl")
end
