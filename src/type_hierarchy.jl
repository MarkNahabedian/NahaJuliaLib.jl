
using InteractiveUtils

export allsubtypes, showsubtypes, pedigree

"""
    allsubtypes(t::Type)
Return a Vector of `t` and all of its subtypes.
"""
function allsubtypes(t::Type, result=Vector{Type}())
    push!(result, t)
    for st in subtypes(t)
	allsubtypes(st, result)
    end
    return result
end

"""
   showsubtypes(t::Type)
Print a hierarchical list of `t` and all of its subtypes. 
"""
function showsubtypes(t::Type, level=0)
    indent1 = "  "
    println("$(repeat(indent1, level))$t")
    for st in subtypes(t)
        showsubtypes(st, level + 1)
    end
end

"""
    pedigree(t::Type)
Return a Vector of `t` and its supertypes.
"""
function pedigree(t::Type, result=Vector{Type}())
    push!(result, t)
    if supertype(t) != t
        pedigree(supertype(t), result)
    end
    result
end

