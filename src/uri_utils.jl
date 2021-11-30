
using URIs

export uri_add_path


"""
    uri_add_path(::URI, ::String...)
Return a new `URI` with the original path extended by the
specified additional components.
"""
function uri_add_path(uri::URI, subs::String...)::URI
    path = ["", URIs.splitpath(uri)..., subs...]
    URI(uri; path=join(path, "/"))
end

function uri_add_path(uri::AbstractString, subs::String...)::URI
    uri_add_path(URI(uri), subs...)
end

