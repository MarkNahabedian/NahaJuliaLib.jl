

struct MyStruct
    a::Int
end

@njl_getprop MyStruct

function Base.getproperty(o::MyStruct, prop::Val{:b})
    o.a * 2
end

@testset "Val dispatch for properties" begin
    ms = MyStruct(3)
    @test ms.a == 3
    @test ms.b == 6
    @test Set(propertynames(ms)) == Set([:a, :b])
    @test hasproperty(ms, :a)
    @test hasproperty(ms, :b)
    @test !hasproperty(ms, :c)
end

