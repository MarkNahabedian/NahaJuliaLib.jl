
using CompatHelper
using TOML
using DataStructures

export add_compat_entries!


function add_compat_entries!(project_file::AbstractString)
    deps = CompatHelper.get_project_deps(project_file;
                                         include_jll=true)
    toml = TOML.parsefile(project_file)
    compat = toml["compat"]
    for dep in deps
        name = dep.package.name
        # We should merge with the existing compat entries, but in the
        # new package case we can just generate them and rely on the
        # package developer to checks the diffs in Project.toml.
        if dep.version_verbatim != nothing
            compat[name] = dep.version_verbatim
        end
    end
    # Sort compat by key, but put "julia" last
    new_compat = OrderedDict()
    for k in sort(collect(keys(compat)))
        if k == "julia"
            continue
        end
        new_compat[k] = compat[k]
    end
    new_compat["julia"] = compat["julia"]
    toml["compat"] = new_compat
    open(project_file, "w") do io
        TOML.print(io, toml)
    end
end
