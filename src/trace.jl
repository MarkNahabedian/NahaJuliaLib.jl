using MacroTools
using Logging

export @trace

abstract type RFTContext end

struct RFTFunc <: RFTContext end
struct RFTCall <: RFTContext end
struct RFTParam <: RFTContext end
struct RFTKw <: RFTContext end

rewrite_for_trace(def::Expr) =rewrite_for_trace(RFTFunc(), def)

rewrite_for_trace(ctx::RFTContext, def::Expr) =
    # Dispatch on def.head
    rewrite_for_trace(ctx, Val(def.head), def)

rewrite_for_trace(ctx::RFTFunc, head::Val{:function}, def::Expr) =
    Expr(:quote, rewrite_for_trace(RFTCall(), def.args[1]))

rewrite_for_trace(ctx::RFTCall, head::Val{:call}, expr::Expr) =
    Expr(:call, map(expr.args) do param
             rewrite_for_trace(RFTParam(), param)
         end...)

rewrite_for_trace(ctx::RFTParam, pexp::Symbol) = Expr(:$, pexp)

rewrite_for_trace(ctx::RFTContext, head::Val{Symbol("::")}, pexp::Expr) =
    rewrite_for_trace(ctx, pexp.args[1])  # Discard the specializer

rewrite_for_trace(ctx::RFTParam, head::Val{:parameters}, pexp::Expr) =
    Expr(:parameters, map(pexp.args) do p
             rewrite_for_trace(ctx, p)
             end...)

rewrite_for_trace(ctx::RFTParam, head::Val{:kw}, pexp::Expr) =
    Expr(:kw,
         rewrite_for_trace(RFTKw(), pexp.args[1]),
         Expr(:$, pexp.args[1]))

rewrite_for_trace(ctx::RFTKw, kw::Symbol) = kw


trace_enter(call) =
    @info("Trace enter", call=call)

trace_exit(f, result) =
    @info("Trace exit ", func=f, result=result)


"""
    @trace(global_flag, definition)
Cause the call arguments and return values of the function defined by
`definition` to be logged if `global_flag` is true at run time.
`definition` should define a method.
"""
macro trace(global_flag, definition)
    definition = longdef(definition)
    pieces = splitdef(definition)
    result = gensym("result")
    bodyfunction = gensym("bodyfunction")
    Expr(:escape,
         Expr(definition.head,
              definition.args[1],   # function signature
              Expr(:block,
                   Expr(:function,
                        Expr(:call, bodyfunction),
                        pieces[:body]),
                   Expr(:if, global_flag,
                        Expr(:call, trace_enter,
                             rewrite_for_trace(definition))),
                   Expr(:(=), result, Expr(:call, bodyfunction)),
                   Expr(:if, global_flag,
                        Expr(:call, trace_exit,
                             pieces[:name], result)),
                   result)))
end

