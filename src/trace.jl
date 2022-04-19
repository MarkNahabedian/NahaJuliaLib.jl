using MacroTools
using Logging
using Markdown

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
                          func=$(pieces[:name]),
                          args=[$(map(first, args)...)],
                          kwargs=[$(map(first, kwargs)...)])
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


# postwalk(rmlines, @macroexpand @trace(foo, f(x::Int, y::Float32; c::Int=3) = x + y))



md"""

I've not found a function tracing facility for Julia so I'm
trying to implement a simple one.  My idea is to have a macro,
@trace, that prefixes a method definition and alters that
definition to start with a log message that prints the function
and arguments and ends with a log message that prints the return
values.  The macro also takes a global variable name as argument.
Logging will only occur if that variable is true at execution
time.

```

@trace(trace_hanoi, function hanoi(from, to, other, count)
    if count == 1
        println("move 1 from $from to $to")
        return
    else
        hanoi(from, other, to, count - 1)
        println("move 1 from $from to $to")
        hanoi(other, to, from, count - 1)
        return (from, to)   # arbitrary result to show
    end
end)

trace_hanoi = true

hanoi(:a, :b, :c, 2)
(:a, :b)

```

How do I get the log to include the values of the function arguments
rather than the names?

Why is `result` always `nothing`?

"""

# Re arguments: the function arguments have gotten alphatized.  How do
# we map the names from the expression to the alphatized formal
# parameters?

