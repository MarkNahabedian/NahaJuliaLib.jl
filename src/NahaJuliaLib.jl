module NahaJuliaLib

include("type_hierarchy.jl")
include("uri_utils.jl")
include("properties.jl")
include("trace.jl")
include("trace_analysis.jl")
# include("export_subtypes.jl")
include("package_utils.jl")

# Fails in CI workflow.  Only needed interactively on local host.
if isinteractive()
    include("my_package_template.jl")
end

end
