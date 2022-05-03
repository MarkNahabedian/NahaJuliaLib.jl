using Documenter
using Pkg
using NahaJuliaLib

DocMeta.setdocmeta!(NahaJuliaLib, :DocTestSetup, :(using NahaJuliaLib); recursive=true)

makedocs(;
    modules=[NahaJuliaLib],
    authors="MarkNahabedian <naha@mit.edu> and contributors",
    repo="https://github.com/MarkNahabedian/NahaJuliaLib.jl/blob/{commit}{path}#{line}",
    sitename="NahaJuliaLib.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MarkNahabedian.github.io/NahaJuliaLib.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/NahaJuliaLib.jl",
    devbranch="master",
)
