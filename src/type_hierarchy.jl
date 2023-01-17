# Some utility functions to make it more convenient to explore the
# type hierarchy.

using InteractiveUtils
using Base.Iterators

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


"""
    common_supertypes(types...)

Return the closest common supertypes of all of the specified types.
"""
function common_supertypes(types::Type...)
    # get vectors of supertypes (most specific first):
    inheritance = pedigree.(types)
    # Reverse iterator for each vector:
    iterators = Stateful.(reverse.(inheritance))
    # Take elements from each iterator until there's a difference
    common = nothing
    while true
        current = first.(iterate.(iterators))
        if all(x -> x == current[1], current)
            common = current[1]
        else
            break
        end
    end
    common
end

