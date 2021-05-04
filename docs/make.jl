using Genser
using Documenter

push!(LOAD_PATH,"../src/")

DocMeta.setdocmeta!(Genser, :DocTestSetup, :(using Genser); recursive=true)

makedocs(;
    modules=[Genser],
    authors="Mark Wardle <mark@potient.com> and contributors",
    repo="https://github.com/wardlem/Genser.jl/blob/{commit}{path}#{line}",
    sitename="Genser.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://wardlem.github.io/Genser.jl",
        assets=String[],
    ),
    pages=[
        "Genser" => "index.md",
        "Manual" => any[
            "manual/overview.md",
            "manual/datamodel.md"
        ],
        "Library" => any[
            "lib/public.md"
        ]
    ],
)

deploydocs(;
    repo="github.com/wardlem/Genser.jl",
    devbranch="main",
)
