var documenterSearchIndex = {"docs":
[{"location":"#NahaJuliaLib.jl","page":"Home","title":"NahaJuliaLib.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"NahaJuliaJib is a library of small utilities that I wish Julia had, but, near as I can tell, doesn't yet.","category":"page"},{"location":"#Type-Hierarchy","page":"Home","title":"Type Hierarchy","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"allsubtypes\nshowsubtypes\npedigree","category":"page"},{"location":"#NahaJuliaLib.allsubtypes","page":"Home","title":"NahaJuliaLib.allsubtypes","text":"allsubtypes(t::Type)\n\nReturn a Vector of t and all of its subtypes.\n\n\n\n\n\n","category":"function"},{"location":"#NahaJuliaLib.showsubtypes","page":"Home","title":"NahaJuliaLib.showsubtypes","text":"showsubtypes(t::Type) Print a hierarchical list of t and all of its subtypes. \n\n\n\n\n\n","category":"function"},{"location":"#NahaJuliaLib.pedigree","page":"Home","title":"NahaJuliaLib.pedigree","text":"pedigree(t::Type)\n\nReturn a Vector of t and its supertypes.\n\n\n\n\n\n","category":"function"},{"location":"#Defining-Object-Properties","page":"Home","title":"Defining Object Properties","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Rather than use a condirional tree to determine which peoperty is being queried by getproperty, we can method specialize on Val types. We should then be able to automate propertynames based on the defined methods.","category":"page"},{"location":"","page":"Home","title":"Home","text":"A struct might have fields, which are exposed as properties.  The Val methods will not shadow the method that implements that.","category":"page"},{"location":"","page":"Home","title":"Home","text":"@njl_getprop","category":"page"},{"location":"#NahaJuliaLib.@njl_getprop","page":"Home","title":"NahaJuliaLib.@njl_getprop","text":"@njl_getprop MyStruct\n\nDefine the methods necessary so that ValgetpropertiesofMyStructwill findVal` specialized properties.\n\n\n\n\n\n","category":"macro"},{"location":"","page":"Home","title":"Home","text":"Here'sa trivial, but illustrative example:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using NahaJuliaLib\n\nstruct MyStruct\n    a::Int\nend\n\n@njl_getprop MyStruct\n\nfunction Base.getproperty(o::MyStruct, prop::Val{:b})\n    o.a * 2\nend\n\nms = MyStruct(3)\nMyStruct(3)","category":"page"},{"location":"","page":"Home","title":"Home","text":"ms.a","category":"page"},{"location":"","page":"Home","title":"Home","text":"ms.b","category":"page"},{"location":"","page":"Home","title":"Home","text":"propertynames(ms)","category":"page"}]
}
