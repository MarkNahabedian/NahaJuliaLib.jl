
using Pkg
using HTTP
using URIs

export webactivate

"""
    webactivate(workspace::AbstractSTring)
    webactivate(workspace::URI)
Activate the workspace whose Project and Manifest files are
located at the specified URI.
This is done by creating a local temporary directory, copying
the files there and activating it.
The path to the temporary directory is returned.
"""
function webactivate end

function webactivate(workspace::AbstractString)
    webactivate(URI(workspace))
end

function webactivate(workspace::URI)
    local = mktempdir()
    for f in ["Project.toml", "Manifest.toml"]
	from = uri_add_path(workspace, f)
	to = joinpath(local, f)
	response = HTTP.request("GET", from)
	@assert response.status == 200
	open(to, "w") do f
	    write(f, String(response.body))
	end
    end
    Pkg.activate(local)
    local
end

