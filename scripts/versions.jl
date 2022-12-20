
using TOML

"""
    package_versions()

Print to standard output one line for each instance of each package
installed in `~/.julia/packages`.  Output includes the package
directory name, the instance direectory name and the version string.
"""
function package_versions()
    PROJECTSDIR = joinpath(homedir(), ".julia", "packages")
    for package_dir in readdir(PROJECTSDIR, join=true)
        try
            for installed in readdir(package_dir, join=true)
                toml = TOML.parse(String(read(joinpath(installed, "Project.toml"))))
                version = get(toml, "version", nothing)
                println("$(basename(package_dir)) \t $(basename(installed)) \t $version")
            end
        catch e
            println(e)
        end
    end
end

