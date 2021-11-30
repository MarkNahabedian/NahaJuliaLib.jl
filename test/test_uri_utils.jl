
@testset "uri_utils" begin
    @test string(uri_add_path("http://foo/bar", "baz", "bam")) ==
        "http://foo/bar/baz/bam"
end

