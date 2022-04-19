using MacroTools
using Logging

export @trace

"""
    find_name(expr)
Return the variable name of a function argument or struct field
expression.
"""
function find_name(expr) end

find_name(s::Symbol) = s

replace_name(s::Symbol, with) = with

function find_name(exp::Expr)
    @assert length(exp.args) >= 1
    find_name(exp.args[1])
end

function replace_name(exp::Expr, with)
    @assert length(exp.args) >= 1
    Expr(exp.head,
         replace_name(exp.args[1], with),
         exp.args[2:end]...)
end


"""
    @trace(global_flag, definition)
Cause the call arguments and return values of the definition to be
logged if `global_flag` is true at run time.
`definition` should define a method.
"""
macro trace(global_flag, definition)
    pieces = splitdef(definition)
    result = gensym("result")
    function gsarg(arg)
        gs = find_name(arg)
        (gs, arg)   # replace_name(arg, gs))
    end
    args = map(gsarg, pieces[:args])
    kwargs = map(gsarg, pieces[:kwargs])
    # We must suppress hygiene because the function being traced could
    # refer to variables defined in an outer scope.
    esc(
        quote
            function $(pieces[:name])(
                $(map(last, args)...) ;
                $(map(last, kwargs)...))
                if $global_flag
                    @info("Trace Enter",
                          Expr(:call, $(pieces[:name]),
                               Expr(:parameters,
                                    Expr(:kw,
                                         $(map(first, kwargs)...)),
                                    $(map(first, args)...)))
                          #=
                          :($$(pieces[:name])(
                              $$(map(first, args)...);
                              $$(map(first, kwargs)...)))
                          =#
                          )
                end
                $result = nothing
                try
                    $result = $(pieces[:body])
                finally
                    if $global_flag
                        @info("Trace Exit", result=$result)
                    end
                end
                $result
            end
        end)
end

