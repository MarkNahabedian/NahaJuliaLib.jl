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
```

```@example
ms.a
```

```@example
ms.b
```

```@example
propertynames(ms)
```

