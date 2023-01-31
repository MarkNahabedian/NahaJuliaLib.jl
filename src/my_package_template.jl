
NEWEST_PKGTEMPLATES, _ = newest_instantiated_version("PkgTemplates")

MY_PACKAGE_TEMPLATE = Template(;
         authors = ["MarkNahabedian <naha@mit.edu> and contributors"],
         dir = "C:/Users/Mark Nahabedian/.julia/dev",
         host = "github.com",
         julia = v"1.8.0",
         user = "MarkNahabedian",
         plugins = [
             License(
                 path = joinpath(NEWEST_PKGTEMPLATES,
                                 "templates/licenses/MIT"),
                 destination = "LICENSE"
             ),
             ProjectFile(version = v"0.1.0"),
             Readme(;
                    file = joinpath(NEWEST_PKGTEMPLATES,
                                    "templates/README.md"),
                    destination = "README.md",
                    inline_badges = true,
                    badge_order = DataType[Documenter{GitHubActions},
                                           Documenter{GitLabCI},
                                           Documenter{TravisCI},
                                           GitHubActions, GitLabCI,
                                           TravisCI, AppVeyor,
                                           DroneCI, CirrusCI,
                                           Codecov,
                                           Coveralls,
                                           BlueStyleBadge,
                                           ColPracBadge],
                    badge_off = DataType[]
                    ),
             SrcDir(
                 file = "NEWEST_PKGTEMPLATES/templates/src/module.jl"
             ),
             TagBot(
                 file = joinpath(NEWEST_PKGTEMPLATES,
                                 "templates/github/workflows/TagBot.yml"),
                 destination = "TagBot.yml",
                 trigger = "JuliaTagBot",
                 token = Secret("GITHUB_TOKEN"),
                 ssh = Secret("DOCUMENTER_KEY"),
                 ssh_password = nothing,
                 changelog = nothing,
                 changelog_ignore = nothing,
                 gpg = nothing,
                 gpg_password = nothing,
                 registry = nothing,
                 branches = nothing,
                 dispatch = nothing,
                 dispatch_delay = nothing
                 ),
             Tests(
                 file = joinpath(NEWEST_PKGTEMPLATES,
                                 "templates/test/runtests.jl"),
                 project = false
             ),
             GitHubActions(),
             Documenter{GitHubActions}()
         ]
         )
