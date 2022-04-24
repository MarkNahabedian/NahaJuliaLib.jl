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
    functionSignature(pieces)::Expr
Return an expression represesenting the signature (function name and
formal parameters) of a function definition.  `pieces` is the result
of calling MacroTools.splitdef on the function definition.
"""
function functionSignature(pieces)::Expr
    function rtype()
        if haskey(pieces, :rtype)
            Expr(:(::),
                 call(),
                 pieces[:rtype])
        else
            call()
        end
    end
    function call()
        if length(pieces[:kwargs]) > 0
            Expr(:foo)  # TBD
        else
            Expr(:call, pieces[:name],
                 pieces[:args]...)
        end
    end
    rtype()
end

# We probably cant define an external function that will give the
# function call expression because we don't have a way to get the
# argument values.


"""
    @trace(global_flag, definition)
Cause the call arguments and return values of the definition to be
logged if `global_flag` is true at run time.
`definition` should define a method.
"""
macro trace(global_flag, definition)
    definition = longdef(definition)
    pieces = splitdef(definition)
    result = gensym("result")
    bodyfunction = gensym("bodyfunction")
    arg = gensym("arg")
    call = gensym("call")
    function gsarg(arg)
        gs = find_name(arg)
        (gs, arg)   # replace_name(arg, gs))
    end
    args = map(gsarg, pieces[:args])
    kwargs = map(gsarg, pieces[:kwargs])
    # We must suppress hygiene because the function being traced could
    # refer to variables defined in an outer scope.
    Expr(:escape,
         Expr(definition.head,
              definition.args[1],   # function signature
              Expr(:block,
                   Expr(:function,
                        Expr(:call, bodyfunction),
                        pieces[:body]),
                   Expr(:if, global_flag,
                        #=
                        # ERROR: LoadError: LoadError: MethodError: no method matching logmsg_code(::Module, ::String, ::Int64, ::Symbol)
                        # Closest candidates are:
                        # logmsg_code(::Any, ::Any, ::Any, ::Any, !Matched::Any, !Matched::Any...) at logging.jl:303
                        Expr(:macrocall, :(@info), "Trace Enter"
                             ) =#
                        # This gives
                        # (println)("Trace Enter ", (string)($(Expr(:copyast, :($(QuoteNode(:(hanoi(from, to, other, count)))))))))
                        # but we want the values of the arguments, not their names.
                        Expr(:call, println,
                             "Trace Enter ",
                             Expr(:call, string,
                                  Expr(:quote,
                                       Expr(:call, pieces[:name],
                                            map(find_name, pieces[:args])...))))),
                   Expr(:(=), result, Expr(:call, bodyfunction)),
                   Expr(:if, global_flag,
                        #=
                        Expr(:macrocall, :(@info), "Trace Exit"
                             ) =#
                        Expr(:call, println, "Trace Exit ", result)
                        )),
              result))
end

