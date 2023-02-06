module NahaJuliaLib

include("type_hierarchy.jl")
include("uri_utils.jl")
include("properties.jl")
include("trace.jl")
include("trace_analysis.jl")
# include("export_subtypes.jl")
include("package_utils.jl")
include("compat.jl")

# Fails in CI workflow.  Only needed interactively on local host.
# This doesn't even happen in an interactive julia.
if isinteractive()
    println("Including my_package_template.jl")
    include("my_package_template.jl")
end

end
