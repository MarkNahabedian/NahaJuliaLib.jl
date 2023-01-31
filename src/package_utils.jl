
using TOML

export newest_instantiated_version

function newest_instantiated_version(package_name)
    package_dir = joinpath(homedir(), ".julia/packages", package_name)
    best = nothing
    for f in readdir(package_dir)
        jp = joinpath(package_dir, f)
        toml = TOML.parse(read(joinpath(jp, "Project.toml"), String))
        v = toml["version"]
        if best == nothing || best[1] < v
            best = (v, jp)
        end
    end
    best[2], best[1]
end

