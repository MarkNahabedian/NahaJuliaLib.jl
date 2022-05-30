# NahaJuliaLib.jl

NahaJuliaJib is a library of small utilities that I wish Julia had,
but, near as I can tell, doesn't yet.


## Type Hierarchy

```@docs
allsubtypes
showsubtypes
pedigree
```

## Defining Object Properties

Rather than use a condirional tree to determine which peoperty is
being queried by `getproperty`, we can method specialize on Val types.
We should then be able to automate `propertynames` based on the
defined methods.

A struct might have fields, which are exposed as properties.  The
`Val` methods will not shadow the method that implements that.


```@docs
@njl_getprop
```

Here'sa trivial, but illustrative example:

```@example
using NahaJuliaLib

struct MyStruct
    a::Int
end

@njl_getprop MyStruct

function Base.getproperty(o::MyStruct, prop::Val{:b})
    o.a * 2
end

ms = MyStruct(3)
MyStruct(3)

ms.a

ms.b

propertynames(ms)
```

## Tracing functions

Sometimes when debugging one wants to track the call and return of
certain specified functions.

```@docs
@trace
analyze_traces
show_trace
```

```@example
using Logging
using VectorLogging
using NahaJuliaLib

@trace(trace_hanoi,
       function hanoi(from, to, other, count)
           if count == 0
               return nothing
           else
               hanoi(from, other, to, count - 1)
               println("move 1 from $from to $to")
               hanoi(other, to, from, count - 1)
               return (from, to)   # arbitrary result to show
           end
       end
       )

trace_hanoi = true

logger = VectorLogger()

with_logger(logger) do
    hanoi(:a, :b, :c, 3)
end

begin
    traces = analyze_traces(logger)
    show_trace(traces[1])
end


```
